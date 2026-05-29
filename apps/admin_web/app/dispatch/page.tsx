import { apiFetch } from '../../lib/api';
import { containsQuery, normalizedDay, queryString, resolveSearch } from '../../lib/filters';

type PartnerFulfillmentJob = {
  id: string;
  orderId: string;
  partnerId: string;
  partnerName?: string;
  cityId: string;
  status: string;
  promisedEtaMinutes?: number;
  elapsedMinutes?: number;
  date?: string;
};

type PaginatedDispatch = {
  items: PartnerFulfillmentJob[];
  total: number;
  page: number;
  limit: number;
};

const fallback: PaginatedDispatch = {
  items: [
    {
      id: 'DJ-1',
      orderId: 'ORD-1103',
      partnerId: 'dhaba-71',
      partnerName: 'Tandoori Junction',
      cityId: 'gurgaon',
      status: 'OUT_FOR_DELIVERY',
      promisedEtaMinutes: 30,
      elapsedMinutes: 26,
      date: '2026-03-09',
    },
    {
      id: 'DJ-2',
      orderId: 'ORD-1104',
      partnerId: 'resto-41',
      partnerName: 'Noida Meal House',
      cityId: 'noida',
      status: 'PENDING_PARTNER_ACK',
      promisedEtaMinutes: 25,
      elapsedMinutes: 9,
      date: '2026-03-09',
    },
    {
      id: 'DJ-3',
      orderId: 'ORD-1105',
      partnerId: 'dhaba-71',
      partnerName: 'Tandoori Junction',
      cityId: 'gurgaon',
      status: 'SLA_DELAY',
      promisedEtaMinutes: 30,
      elapsedMinutes: 37,
      date: '2026-03-09',
    },
    {
      id: 'DJ-4',
      orderId: 'ORD-1099',
      partnerId: 'resto-30',
      partnerName: 'Delhi Spice Dhaba',
      cityId: 'delhi',
      status: 'DELIVERED',
      promisedEtaMinutes: 28,
      elapsedMinutes: 25,
      date: '2026-03-08',
    },
  ],
  total: 4,
  page: 1,
  limit: 20,
};

function statusGuardClass(status: string) {
  const upper = status.toUpperCase();
  if (upper.includes('DELAY') || upper.includes('BREACH')) return 'guard-high';
  if (upper.includes('PENDING') || upper.includes('ASSIGN')) return 'guard-watch';
  return 'guard-ok';
}

function isUuid(value: string) {
  return /^[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i.test(
    value,
  );
}

type PageProps = {
  searchParams?: Promise<Record<string, string | string[] | undefined>>;
};

export default async function DispatchPage({ searchParams }: PageProps) {
  const search = await resolveSearch(searchParams);
  const selectedDate = normalizedDay(queryString(search.date));
  const query = queryString(search.q).trim();
  const cityFilter = queryString(search.city).trim();
  const statusFilter = queryString(search.status).trim();
  const partnerFilter = queryString(search.partner).trim();
  const backendQuery = [query, partnerFilter].filter(Boolean).join(' ');

  const apiParams = new URLSearchParams({
    page: '1',
    limit: '50',
  });
  if (selectedDate) apiParams.set('date', selectedDate);
  if (backendQuery) apiParams.set('q', backendQuery);
  if (cityFilter) apiParams.set('cityId', cityFilter);
  if (statusFilter) apiParams.set('status', statusFilter.toUpperCase());
  if (partnerFilter && isUuid(partnerFilter)) apiParams.set('partnerId', partnerFilter);

  const data =
    (await apiFetch<PaginatedDispatch>(`/admin/dispatch/jobs?${apiParams.toString()}`)) ?? fallback;

  const rows = data.items.map((job) => ({
    ...job,
    date: job.date ?? selectedDate,
  }));
  const cityOptions = [...new Set(rows.map((job) => job.cityId.toUpperCase()))].sort();
  const statusOptions = [...new Set(rows.map((job) => job.status.toUpperCase()))].sort();
  const partnerOptions = [...new Set(rows.map((job) => job.partnerName ?? job.partnerId))].sort();

  const filteredRows = rows.filter((job) => {
    const city = job.cityId.toUpperCase();
    const status = job.status.toUpperCase();
    const partner = (job.partnerName ?? job.partnerId).toUpperCase();
    const haystack = `${job.id} ${job.orderId} ${job.partnerId} ${job.partnerName ?? ''} ${job.cityId} ${job.status}`;

    if ((job.date ?? selectedDate) !== selectedDate) return false;
    if (cityFilter && city !== cityFilter.toUpperCase()) return false;
    if (statusFilter && status !== statusFilter.toUpperCase()) return false;
    if (partnerFilter && partner !== partnerFilter.toUpperCase()) return false;
    return containsQuery(haystack, query);
  });

  const ackPending = filteredRows.filter((job) => job.status === 'PENDING_PARTNER_ACK').length;
  const activeFulfillment = filteredRows.filter((job) =>
    ['ACCEPTED', 'PREPARING', 'PICKED_UP', 'OUT_FOR_DELIVERY'].includes(job.status),
  ).length;
  const slaBreaches = filteredRows.filter((job) => {
    const upper = job.status.toUpperCase();
    return upper.includes('DELAY') || upper.includes('BREACH');
  }).length;

  const cityBuckets = filteredRows.reduce<Record<string, number>>((acc, job) => {
    const city = job.cityId.toUpperCase();
    acc[city] = (acc[city] ?? 0) + 1;
    return acc;
  }, {});

  const breachedCityBuckets = filteredRows.reduce<Record<string, number>>((acc, job) => {
    const upper = job.status.toUpperCase();
    if (!upper.includes('DELAY') && !upper.includes('BREACH')) return acc;
    const city = job.cityId.toUpperCase();
    acc[city] = (acc[city] ?? 0) + 1;
    return acc;
  }, {});

  const cityHealth = Object.entries(cityBuckets)
    .map(([city, jobs]) => ({
      city,
      jobs,
      breached: breachedCityBuckets[city] ?? 0,
      intensity:
        (breachedCityBuckets[city] ?? 0) >= 3
          ? 'High exception risk'
          : (breachedCityBuckets[city] ?? 0) >= 1
            ? 'Watch'
            : 'Healthy',
    }))
    .sort((a, b) => b.breached - a.breached || b.jobs - a.jobs);

  const partnerRisk = filteredRows.reduce<
    Record<string, { partner: string; city: string; jobs: number; breaches: number }>
  >((acc, job) => {
    const key = job.partnerId;
    const partner = job.partnerName ?? job.partnerId.toUpperCase();
    const city = job.cityId.toUpperCase();
    const upper = job.status.toUpperCase();
    const breached = upper.includes('DELAY') || upper.includes('BREACH') ? 1 : 0;

    if (!acc[key]) {
      acc[key] = { partner, city, jobs: 0, breaches: 0 };
    }

    acc[key].jobs += 1;
    acc[key].breaches += breached;
    return acc;
  }, {});

  const partnerRiskRows = Object.values(partnerRisk)
    .map((row) => ({
      ...row,
      risk:
        row.breaches >= 2 ? 'High risk' : row.breaches === 1 ? 'Watch closely' : 'Healthy partner',
    }))
    .sort((a, b) => b.breaches - a.breaches || b.jobs - a.jobs);

  return (
    <section>
      <div className="page-header">
        <div>
          <h2>Partner Fulfillment Board</h2>
          <p className="muted">
            Restaurants and dhabas run delivery. Daily SLA view with search and filter controls.
          </p>
        </div>
      </div>
      <form className="filter-bar" method="get">
        <label className="filter-field">
          <span>Day</span>
          <input className="input" type="date" name="date" defaultValue={selectedDate} />
        </label>
        <label className="filter-field">
          <span>Search</span>
          <input
            className="input"
            type="search"
            name="q"
            defaultValue={query}
            placeholder="Job, order, partner"
          />
        </label>
        <label className="filter-field">
          <span>City</span>
          <select className="input" name="city" defaultValue={cityFilter}>
            <option value="">All cities</option>
            {cityOptions.map((city) => (
              <option key={city} value={city}>
                {city}
              </option>
            ))}
          </select>
        </label>
        <label className="filter-field">
          <span>Status</span>
          <select className="input" name="status" defaultValue={statusFilter}>
            <option value="">All status</option>
            {statusOptions.map((status) => (
              <option key={status} value={status}>
                {status}
              </option>
            ))}
          </select>
        </label>
        <label className="filter-field">
          <span>Partner</span>
          <select className="input" name="partner" defaultValue={partnerFilter}>
            <option value="">All partners</option>
            {partnerOptions.map((partner) => (
              <option key={partner} value={partner.toUpperCase()}>
                {partner}
              </option>
            ))}
          </select>
        </label>
        <div className="filter-actions">
          <button className="btn btn-primary" type="submit">
            Apply
          </button>
          <a className="btn" href="/dispatch">
            Reset
          </a>
        </div>
      </form>

      <div className="grid">
        <article className="card">
          <p className="muted">Filtered fulfillment jobs</p>
          <h3>{filteredRows.length}</h3>
        </article>
        <article className="card">
          <p className="muted">Awaiting partner acceptance</p>
          <h3>{ackPending}</h3>
        </article>
        <article className="card">
          <p className="muted">Active fulfillment</p>
          <h3>{activeFulfillment}</h3>
        </article>
        <article className="card">
          <p className="muted">SLA breach flags</p>
          <h3>{slaBreaches}</h3>
        </article>
      </div>

      <article className="card section-gap">
        <h3>City partner-risk heatmap</h3>
        {cityHealth.length === 0 ? (
          <p className="muted">No fulfillment jobs in queue.</p>
        ) : (
          <div className="lane-grid">
            {cityHealth.map((lane) => (
              <div key={lane.city} className="lane-item">
                <div className="lane-head">
                  <strong>{lane.city}</strong>
                  <span
                    className={`lane-status ${lane.breached >= 1 ? 'watch' : 'ok'}`}
                  >
                    {lane.intensity}
                  </span>
                </div>
                <p className="muted">
                  {lane.jobs} live jobs • {lane.breached} breach flag{lane.breached === 1 ? '' : 's'}
                </p>
              </div>
            ))}
          </div>
        )}
      </article>

      <article className="card section-gap">
        <h3>Partner risk queue</h3>
        <table className="table">
          <thead>
            <tr>
              <th>Partner outlet</th>
              <th>City</th>
              <th>Active jobs</th>
              <th>Breach flags</th>
              <th>Risk</th>
            </tr>
          </thead>
          <tbody>
            {partnerRiskRows.map((row) => (
              <tr key={`${row.partner}-${row.city}`}>
                <td>{row.partner}</td>
                <td>{row.city}</td>
                <td>{row.jobs}</td>
                <td>{row.breaches}</td>
                <td>
                  <span className={`badge ${row.breaches >= 2 ? 'guard-high' : row.breaches === 1 ? 'guard-watch' : 'guard-ok'}`}>
                    {row.risk}
                  </span>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </article>

      <article className="card section-gap">
        <h3>Live fulfillment queue</h3>
        <table className="table">
          <thead>
            <tr>
              <th>Job</th>
              <th>Date</th>
              <th>Order</th>
              <th>Partner outlet</th>
              <th>City</th>
              <th>Status</th>
              <th>SLA</th>
            </tr>
          </thead>
          <tbody>
            {filteredRows.map((job) => (
              <tr key={job.id}>
                <td>{job.id}</td>
                <td>{job.date ?? selectedDate}</td>
                <td>{job.orderId}</td>
                <td>{job.partnerName ?? job.partnerId}</td>
                <td>{job.cityId}</td>
                <td>
                  <span className={`badge ${statusGuardClass(job.status)}`}>{job.status}</span>
                </td>
                <td>
                  {job.elapsedMinutes ?? '-'} / {job.promisedEtaMinutes ?? '-'} min
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </article>
    </section>
  );
}

import Link from 'next/link';
import { containsQuery, normalizedDay, queryString, resolveSearch } from '../lib/filters';

type CityLane = {
  snapshotDate?: string;
  city: string;
  liveOrders: number;
  etaMinutes: number;
  fillRate: number;
  couponSpend: number;
  churnRisk: 'Low' | 'Medium' | 'High';
};

type Incident = {
  snapshotDate?: string;
  id: string;
  title: string;
  severity: 'P1' | 'P2' | 'P3';
  module: string;
  owner: string;
  eta: string;
  href: string;
};

const kpis = [
  { label: 'Gross orders today', value: '2,184', delta: '+9.4% vs yesterday' },
  { label: 'Active subscriptions', value: '1,284', delta: '+6.2% week-on-week' },
  { label: 'On-time fulfillment', value: '96.2%', delta: 'Partner SLA target ≥ 95%' },
  { label: 'Payment success', value: '98.1%', delta: 'Stable gateway health' },
  { label: 'Net margin / order', value: '₹29.4', delta: '+₹2.7 after guardrails' },
  { label: 'Offer burn today', value: '₹61.8k', delta: '81% of planned cap' },
];

const quickActions = [
  { href: '/orders', label: 'Review hot orders', note: 'Prioritize SLA misses' },
  {
    href: '/dispatch',
    label: 'Monitor partner fulfillment',
    note: 'Escalate restaurants/dhabas with SLA breaches',
  },
  { href: '/offers', label: 'Tune campaigns', note: 'Pause risky coupon legs' },
  { href: '/payments', label: 'Check refunds', note: 'Watch failure spikes' },
  { href: '/analytics', label: 'Open growth analytics', note: 'Track cohort quality' },
];

const cityLanes: CityLane[] = [
  {
    snapshotDate: '2026-03-09',
    city: 'Gurgaon',
    liveOrders: 312,
    etaMinutes: 24,
    fillRate: 93,
    couponSpend: 84,
    churnRisk: 'Low',
  },
  {
    snapshotDate: '2026-03-09',
    city: 'Delhi',
    liveOrders: 388,
    etaMinutes: 32,
    fillRate: 88,
    couponSpend: 91,
    churnRisk: 'High',
  },
  {
    snapshotDate: '2026-03-09',
    city: 'Noida',
    liveOrders: 267,
    etaMinutes: 28,
    fillRate: 90,
    couponSpend: 86,
    churnRisk: 'Medium',
  },
  {
    snapshotDate: '2026-03-08',
    city: 'Bengaluru',
    liveOrders: 194,
    etaMinutes: 22,
    fillRate: 95,
    couponSpend: 72,
    churnRisk: 'Low',
  },
];

const demandMix = [
  { label: 'Breakfast', demand: 62, capacity: 68 },
  { label: 'Lunch', demand: 91, capacity: 84 },
  { label: 'Evening snacks', demand: 57, capacity: 63 },
  { label: 'Dinner', demand: 88, capacity: 81 },
];

const incidents: Incident[] = [
  {
    snapshotDate: '2026-03-09',
    id: 'INC-901',
    title: 'Delhi lunch partner ETA crossed policy threshold',
    severity: 'P1',
    module: 'Partner fulfillment',
    owner: 'Ops lead',
    eta: '15 min',
    href: '/dispatch',
  },
  {
    snapshotDate: '2026-03-09',
    id: 'INC-882',
    title: 'Noida campaign nearing daily budget cap',
    severity: 'P2',
    module: 'Offers',
    owner: 'Growth manager',
    eta: '30 min',
    href: '/offers',
  },
  {
    snapshotDate: '2026-03-09',
    id: 'INC-877',
    title: 'UPI bank lane failure spike at 3.1%',
    severity: 'P2',
    module: 'Payments',
    owner: 'Finance ops',
    eta: '45 min',
    href: '/payments',
  },
  {
    snapshotDate: '2026-03-08',
    id: 'INC-861',
    title: 'Kitchen prep variance up for 2 menu clusters',
    severity: 'P3',
    module: 'Menus',
    owner: 'Supply team',
    eta: '1 hr',
    href: '/menus',
  },
];

const timeline = [
  { snapshotDate: '2026-03-09', time: '09:00', event: 'Morning slot stabilized at 95% partner fill rate', type: 'ok' },
  { snapshotDate: '2026-03-09', time: '11:30', event: 'Auto-paused 1 coupon leg after guardrail breach', type: 'watch' },
  { snapshotDate: '2026-03-09', time: '13:10', event: 'Delhi partner queue breached 30-min ETA', type: 'critical' },
  { snapshotDate: '2026-03-09', time: '14:05', event: 'Partner escalation reduced queue by 18%', type: 'ok' },
  { snapshotDate: '2026-03-08', time: '16:00', event: 'UPI retries rerouted to healthy lane', type: 'watch' },
];

function riskClass(value: CityLane['churnRisk']) {
  if (value === 'High') return 'high';
  if (value === 'Medium') return 'watch';
  return 'ok';
}

function incidentClass(value: Incident['severity']) {
  if (value === 'P1') return 'critical';
  if (value === 'P2') return 'watch';
  return 'ok';
}

function timelineClass(type: (typeof timeline)[number]['type']) {
  if (type === 'critical') return 'critical';
  if (type === 'watch') return 'watch';
  return 'ok';
}

export default async function OverviewPage() {
  const search: Record<string, string | string[] | undefined> = {};
  const selectedDate = normalizedDay(queryString(search.date));
  const query = queryString(search.q).trim();
  const cityFilter = queryString(search.city).trim();
  const riskFilter = queryString(search.risk).trim();

  const cityOptions = [...new Set(cityLanes.map((lane) => lane.city.toUpperCase()))].sort();
  const filteredCityLanes = cityLanes.filter((lane) => {
    const city = lane.city.toUpperCase();
    const risk = lane.churnRisk.toUpperCase();
    const haystack = `${lane.city} ${lane.fillRate} ${lane.couponSpend} ${lane.churnRisk}`;

    if ((lane.snapshotDate ?? selectedDate) !== selectedDate) return false;
    if (cityFilter && city !== cityFilter.toUpperCase()) return false;
    if (riskFilter && risk !== riskFilter.toUpperCase()) return false;
    return containsQuery(haystack, query);
  });
  const filteredIncidents = incidents.filter((incident) => {
    const haystack = `${incident.id} ${incident.title} ${incident.module} ${incident.owner}`;
    if ((incident.snapshotDate ?? selectedDate) !== selectedDate) return false;
    return containsQuery(haystack, query);
  });
  const filteredTimeline = timeline.filter((entry) => {
    const haystack = `${entry.time} ${entry.event} ${entry.type}`;
    if ((entry.snapshotDate ?? selectedDate) !== selectedDate) return false;
    return containsQuery(haystack, query);
  });

  return (
    <section>
      <div className="page-header">
        <div>
          <h2>Operations Command Dashboard</h2>
          <p className="muted">
            Unified control plane for consumer growth, partner-led fulfillment quality, and
            margin-safe automation.
          </p>
        </div>
        <div className="toolbar">
          <Link className="btn btn-primary" href="/dispatch">
            Open Partner Fulfillment
          </Link>
          <Link className="btn" href="/offers">
            Manage Offers
          </Link>
        </div>
      </div>
      <form className="filter-bar" method="get">
        <label className="filter-field">
          <span>Day</span>
          <input className="input" type="date" name="date" defaultValue={selectedDate} />
        </label>
        <label className="filter-field">
          <span>Search</span>
          <input className="input" type="search" name="q" defaultValue={query} placeholder="City, incident, metric" />
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
          <span>Churn risk</span>
          <select className="input" name="risk" defaultValue={riskFilter}>
            <option value="">All risk</option>
            <option value="LOW">LOW</option>
            <option value="MEDIUM">MEDIUM</option>
            <option value="HIGH">HIGH</option>
          </select>
        </label>
        <div className="filter-actions">
          <button className="btn btn-primary" type="submit">
            Apply
          </button>
          <a className="btn" href="/">
            Reset
          </a>
        </div>
      </form>

      <article className="hero-panel">
        <p className="hero-eyebrow">Live Control Center</p>
        <h3>Run daily food operations with speed, discipline, and visibility</h3>
        <p className="muted">
          Foodily Ops monitors city-level throughput, coupon burn, partner fulfillment performance,
          and payment health in one operator view.
        </p>
        <div className="hero-meta">
          <span className="badge">Snapshot day: {selectedDate}</span>
          <span className="badge">Cities live: 6</span>
          <span className="badge">Kitchens: 42</span>
          <span className="badge">Partner outlets active: 189</span>
          <span className="badge">Incidents open: {filteredIncidents.length}</span>
        </div>
      </article>

      <div className="grid">
        {kpis.map((kpi) => (
          <article className="card" key={kpi.label}>
            <p className="muted">{kpi.label}</p>
            <h3>{kpi.value}</h3>
            <p className="kpi-delta">{kpi.delta}</p>
          </article>
        ))}
      </div>

      <div className="grid section-gap">
        <article className="card">
          <h3>Operator quick actions</h3>
          <div className="tile-grid">
            {quickActions.map((item) => (
              <Link key={item.href} href={item.href} className="tile-link">
                <strong>{item.label}</strong>
                <span>{item.note}</span>
              </Link>
            ))}
          </div>
        </article>

        <article className="card">
          <h3>Demand vs capacity by slot</h3>
          <div className="stack-list">
            {demandMix.map((slot) => (
              <div key={slot.label} className="stack-row">
                <div className="stack-head">
                  <strong>{slot.label}</strong>
                  <span className="muted">
                    Demand {slot.demand}% • Capacity {slot.capacity}%
                  </span>
                </div>
                <div className="meter">
                  <span style={{ width: `${slot.demand}%` }} className="meter-demand" />
                  <span style={{ width: `${slot.capacity}%` }} className="meter-capacity" />
                </div>
              </div>
            ))}
          </div>
        </article>
      </div>

      <article className="card section-gap">
        <h3>City command matrix</h3>
        <table className="table">
          <thead>
            <tr>
              <th>City</th>
              <th>Live orders</th>
              <th>Avg fulfillment ETA</th>
              <th>Fill rate</th>
              <th>Coupon burn</th>
              <th>Churn risk</th>
            </tr>
          </thead>
          <tbody>
            {filteredCityLanes.map((city) => (
              <tr key={city.city}>
                <td>{city.city}</td>
                <td>{city.liveOrders}</td>
                <td>{city.etaMinutes} min</td>
                <td>{city.fillRate}%</td>
                <td>{city.couponSpend}%</td>
                <td>
                  <span className={`badge guard-${riskClass(city.churnRisk)}`}>{city.churnRisk}</span>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </article>

      <div className="grid section-gap">
        <article className="card">
          <h3>Incident queue</h3>
          <div className="incident-list">
            {filteredIncidents.map((incident) => (
              <Link key={incident.id} href={incident.href} className="incident-item">
                <div>
                  <div className="incident-title">
                    <strong>{incident.id}</strong>
                    <span className={`badge guard-${incidentClass(incident.severity)}`}>
                      {incident.severity}
                    </span>
                  </div>
                  <p>{incident.title}</p>
                  <span className="muted">
                    {incident.module} • {incident.owner} • ETA {incident.eta}
                  </span>
                </div>
              </Link>
            ))}
          </div>
        </article>

        <article className="card">
          <h3>24-hour control timeline</h3>
          <div className="timeline-list">
            {filteredTimeline.map((entry) => (
              <div key={`${entry.time}-${entry.event}`} className="timeline-row">
                <span className="timeline-time">{entry.time}</span>
                <span className={`timeline-dot ${timelineClass(entry.type)}`} />
                <span className="timeline-event">{entry.event}</span>
              </div>
            ))}
          </div>
        </article>
      </div>
    </section>
  );
}

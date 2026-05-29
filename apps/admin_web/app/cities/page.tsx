import { apiFetch } from '../../lib/api';
import { containsQuery, normalizedDay, queryString, resolveSearch } from '../../lib/filters';

type CityRecord = {
  id: string;
  name: string;
  active: boolean;
};

type ZoneRecord = {
  id: string;
  cityId: string;
  name: string;
  active: boolean;
};

type MenuRecord = {
  id: string;
  cityId: string;
  slot: string;
  name: string;
  price: number;
};

type KitchenRow = {
  city: string;
  kitchen: string;
  zones: number;
  partnerOutlets: number;
  fulfillmentModel: string;
  slaTarget: string;
  active: boolean;
  asOfDate: string;
};

const fallback: KitchenRow[] = [
  {
    city: 'GURUGRAM',
    kitchen: 'GURUGRAM CENTRAL',
    zones: 2,
    partnerOutlets: 18,
    fulfillmentModel: 'PARTNER_SELF_DELIVERY',
    slaTarget: '30 min',
    active: true,
    asOfDate: '2026-03-09',
  },
  {
    city: 'NOIDA',
    kitchen: 'NOIDA HUB',
    zones: 1,
    partnerOutlets: 11,
    fulfillmentModel: 'PARTNER_SELF_DELIVERY',
    slaTarget: '35 min',
    active: true,
    asOfDate: '2026-03-09',
  },
  {
    city: 'DELHI',
    kitchen: 'DELHI NORTH CLOUD KITCHEN',
    zones: 2,
    partnerOutlets: 16,
    fulfillmentModel: 'PARTNER_SELF_DELIVERY',
    slaTarget: '32 min',
    active: false,
    asOfDate: '2026-03-08',
  },
];

type PageProps = {
  searchParams?: Promise<Record<string, string | string[] | undefined>>;
};

function kitchenName(cityName: string): string {
  return `${cityName.toUpperCase()} CENTRAL`;
}

export default async function CitiesPage({ searchParams }: PageProps) {
  const search = await resolveSearch(searchParams);
  const selectedDate = normalizedDay(queryString(search.date));
  const query = queryString(search.q).trim();
  const cityFilter = queryString(search.city).trim();
  const statusFilter = queryString(search.status).trim();

  const cities = (await apiFetch<CityRecord[]>('/cities')) ?? [];
  const liveRows = await Promise.all(
    cities.map(async (city) => {
      const [zones, menus] = await Promise.all([
        apiFetch<ZoneRecord[]>(`/zones?cityId=${encodeURIComponent(city.id)}`),
        apiFetch<MenuRecord[]>(`/menus/same-day?cityId=${encodeURIComponent(city.id)}`),
      ]);
      const zoneCount = zones?.length ?? 0;
      const menuCount = menus?.length ?? 0;

      return {
        city: city.name.toUpperCase(),
        kitchen: kitchenName(city.name),
        zones: zoneCount,
        partnerOutlets: Math.max(zoneCount * 8, menuCount * 3),
        fulfillmentModel: 'PARTNER_SELF_DELIVERY',
        slaTarget: zoneCount >= 2 ? '30 min' : '35 min',
        active: city.active,
        asOfDate: selectedDate,
      };
    }),
  );

  const rows = liveRows.length > 0 ? liveRows : fallback;
  const cityOptions = [...new Set(rows.map((item) => item.city))].sort();
  const filteredRows = rows.filter((item) => {
    const city = item.city.toUpperCase();
    const status = item.active ? 'ACTIVE' : 'INACTIVE';
    const haystack = `${item.city} ${item.kitchen} ${item.fulfillmentModel} ${item.slaTarget}`;

    if (selectedDate && (item.asOfDate ?? selectedDate) !== selectedDate) return false;
    if (cityFilter && city !== cityFilter.toUpperCase()) return false;
    if (statusFilter && status !== statusFilter.toUpperCase()) return false;
    return containsQuery(haystack, query);
  });

  return (
    <section>
      <div className="page-header">
        <div>
          <h2>City / Zone / Kitchen Configuration</h2>
          <p className="muted">Daily city-kitchen snapshot with search and status filter.</p>
        </div>
      </div>
      <form className="filter-bar" method="get">
        <label className="filter-field">
          <span>Day</span>
          <input className="input" type="date" name="date" defaultValue={selectedDate} />
        </label>
        <label className="filter-field">
          <span>Search</span>
          <input className="input" type="search" name="q" defaultValue={query} placeholder="City or kitchen" />
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
            <option value="ACTIVE">ACTIVE</option>
            <option value="INACTIVE">INACTIVE</option>
          </select>
        </label>
        <div className="filter-actions">
          <button className="btn btn-primary" type="submit">
            Apply
          </button>
          <a className="btn" href="/cities">
            Reset
          </a>
        </div>
      </form>
      <table className="table">
        <thead>
          <tr>
            <th>Snapshot day</th>
            <th>City</th>
            <th>Kitchen</th>
            <th>Zones</th>
            <th>Partner outlets</th>
            <th>Fulfillment model</th>
            <th>SLA target</th>
            <th>Status</th>
          </tr>
        </thead>
        <tbody>
          {filteredRows.map((item) => (
            <tr key={`${item.city}-${item.kitchen}`}>
              <td>{item.asOfDate}</td>
              <td>{item.city}</td>
              <td>{item.kitchen}</td>
              <td>{item.zones}</td>
              <td>{item.partnerOutlets}</td>
              <td>{item.fulfillmentModel}</td>
              <td>{item.slaTarget}</td>
              <td>{item.active ? 'Active' : 'Inactive'}</td>
            </tr>
          ))}
        </tbody>
      </table>
    </section>
  );
}

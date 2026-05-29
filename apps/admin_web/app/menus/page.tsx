import { apiFetch } from '../../lib/api';
import { containsQuery, normalizedDay, queryString, resolveSearch } from '../../lib/filters';

type CityRecord = {
  id: string;
  name: string;
  active: boolean;
};

type MenuApiRow = {
  id: string;
  cityId: string;
  slot: string;
  name: string;
  price: number;
};

type MenuRow = {
  id: string;
  date: string;
  city: string;
  kitchen: string;
  meal: string;
  slot: string;
  price: number;
  cap: number;
  status: 'ACTIVE' | 'PAUSED';
};

const fallback: MenuRow[] = [
  {
    id: 'menu-fb-1',
    date: '2026-03-09',
    city: 'GURGAON',
    kitchen: 'GURUGRAM CENTRAL',
    meal: 'Paneer Tikka Meal',
    slot: 'LUNCH',
    price: 120,
    cap: 120,
    status: 'ACTIVE',
  },
  {
    id: 'menu-fb-2',
    date: '2026-03-09',
    city: 'NOIDA',
    kitchen: 'NOIDA HUB',
    meal: 'Dal Rice Comfort Box',
    slot: 'DINNER',
    price: 100,
    cap: 90,
    status: 'ACTIVE',
  },
  {
    id: 'menu-fb-3',
    date: '2026-03-08',
    city: 'DELHI',
    kitchen: 'DELHI NORTH CLOUD KITCHEN',
    meal: 'Rajma Meal Combo',
    slot: 'LUNCH',
    price: 140,
    cap: 80,
    status: 'PAUSED',
  },
];

type PageProps = {
  searchParams?: Promise<Record<string, string | string[] | undefined>>;
};

function kitchenName(cityName: string): string {
  return `${cityName.toUpperCase()} CENTRAL`;
}

function normalizeSlot(raw: string): string {
  const upper = raw.toUpperCase();
  if (upper === 'BREAKFAST' || upper === 'LUNCH' || upper === 'DINNER') return upper;
  return 'LUNCH';
}

export default async function MenusPage({ searchParams }: PageProps) {
  const search = await resolveSearch(searchParams);
  const selectedDate = normalizedDay(queryString(search.date));
  const query = queryString(search.q).trim();
  const cityFilter = queryString(search.city).trim();
  const slotFilter = queryString(search.slot).trim();
  const statusFilter = queryString(search.status).trim();
  const normalizedSlotFilter = slotFilter ? normalizeSlot(slotFilter) : '';

  const cities = (await apiFetch<CityRecord[]>('/cities')) ?? [];
  const targetCities = cityFilter
    ? cities.filter((city) => city.name.toUpperCase() === cityFilter.toUpperCase())
    : cities;

  const liveRowsNested = await Promise.all(
    targetCities.map(async (city) => {
      const params = new URLSearchParams({
        cityId: city.id,
      });
      if (normalizedSlotFilter) params.set('slot', normalizedSlotFilter);

      const menus =
        (await apiFetch<MenuApiRow[]>(`/menus/same-day?${params.toString()}`)) ?? [];

      return menus.map((menu) => ({
        id: menu.id,
        date: selectedDate,
        city: city.name.toUpperCase(),
        kitchen: kitchenName(city.name),
        meal: menu.name,
        slot: normalizeSlot(menu.slot),
        price: menu.price,
        cap: Math.max(60, Math.round(menu.price * 0.9)),
        status: 'ACTIVE' as const,
      }));
    }),
  );

  const liveRows = liveRowsNested.flat();
  const rows = liveRows.length > 0 ? liveRows : fallback;

  const cityOptions = [...new Set(rows.map((row) => row.city))].sort();
  const slotOptions = [...new Set(rows.map((row) => row.slot.toUpperCase()))].sort();
  const filteredRows = rows.filter((row) => {
    const haystack = `${row.meal} ${row.kitchen} ${row.city} ${row.slot} ${row.status}`;

    if (row.date !== selectedDate) return false;
    if (cityFilter && row.city !== cityFilter.toUpperCase()) return false;
    if (slotFilter && row.slot.toUpperCase() !== slotFilter.toUpperCase()) return false;
    if (statusFilter && row.status.toUpperCase() !== statusFilter.toUpperCase()) return false;
    return containsQuery(haystack, query);
  });

  return (
    <section>
      <div className="page-header">
        <div>
          <h2>Menus and Slot Pricing</h2>
          <p className="muted">Daily menu operations with slot and city filters.</p>
        </div>
      </div>
      <form className="filter-bar" method="get">
        <label className="filter-field">
          <span>Day</span>
          <input className="input" type="date" name="date" defaultValue={selectedDate} />
        </label>
        <label className="filter-field">
          <span>Search</span>
          <input className="input" type="search" name="q" defaultValue={query} placeholder="Meal or kitchen" />
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
          <span>Slot</span>
          <select className="input" name="slot" defaultValue={slotFilter}>
            <option value="">All slots</option>
            {slotOptions.map((slot) => (
              <option key={slot} value={slot}>
                {slot}
              </option>
            ))}
          </select>
        </label>
        <label className="filter-field">
          <span>Status</span>
          <select className="input" name="status" defaultValue={statusFilter}>
            <option value="">All status</option>
            <option value="ACTIVE">ACTIVE</option>
            <option value="PAUSED">PAUSED</option>
          </select>
        </label>
        <div className="filter-actions">
          <button className="btn btn-primary" type="submit">
            Apply
          </button>
          <a className="btn" href="/menus">
            Reset
          </a>
        </div>
      </form>
      <div className="grid">
        {filteredRows.map((row) => (
          <article className="card" key={row.id}>
            <h3>{row.meal}</h3>
            <p>
              {row.date} • {row.city}
            </p>
            <p>{row.kitchen}</p>
            <p>
              {row.slot} | ₹{row.price} | Capacity {row.cap}
            </p>
            <span className={`badge ${row.status === 'ACTIVE' ? 'status-active' : 'status-paused'}`}>
              {row.status}
            </span>
          </article>
        ))}
      </div>
    </section>
  );
}

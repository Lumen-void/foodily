'use client';

import { FormEvent, useMemo, useState } from 'react';

type DiscountKind = 'FLAT' | 'PERCENT';
type AudienceSegment = 'ALL' | 'NEW_USERS' | 'LOYAL_USERS' | 'DORMANT_USERS';
type GuardrailLevel = 'OK' | 'RISK' | 'PAUSED';
type RecommendationAction = 'RUN_GUARDRAIL' | 'SIM_HOUR' | 'CREATE_CAMPAIGN';

type OfferRecord = {
  id: string;
  code: string;
  title: string;
  city: string;
  audience: AudienceSegment;
  kind: DiscountKind;
  value: number;
  minCart: number;
  maxUses: number;
  redemptions: number;
  active: boolean;
  automationEnabled: boolean;
  startsAt: string;
  endsAt: string;
  dailyBudget: number;
  totalBudget: number;
  spendToday: number;
  spendTotal: number;
  pausedByGuardrail: boolean;
};

const seedOffers: OfferRecord[] = [
  {
    id: 'OFF-101',
    code: 'WELCOME60',
    title: 'First order push',
    city: 'Gurgaon',
    audience: 'NEW_USERS',
    kind: 'FLAT',
    value: 60,
    minCart: 249,
    maxUses: 3500,
    redemptions: 2198,
    active: true,
    automationEnabled: true,
    startsAt: '2026-03-08T10:00',
    endsAt: '2026-03-31T23:30',
    dailyBudget: 22000,
    totalBudget: 450000,
    spendToday: 18450,
    spendTotal: 268700,
    pausedByGuardrail: false,
  },
  {
    id: 'OFF-102',
    code: 'LUNCH15',
    title: 'Lunch hour promo',
    city: 'Noida',
    audience: 'ALL',
    kind: 'PERCENT',
    value: 15,
    minCart: 179,
    maxUses: 6000,
    redemptions: 4011,
    active: true,
    automationEnabled: true,
    startsAt: '2026-03-08T12:00',
    endsAt: '2026-03-28T16:00',
    dailyBudget: 28000,
    totalBudget: 560000,
    spendToday: 21440,
    spendTotal: 361220,
    pausedByGuardrail: false,
  },
  {
    id: 'OFF-103',
    code: 'RAINY40',
    title: 'Rain surge retention',
    city: 'Delhi',
    audience: 'DORMANT_USERS',
    kind: 'FLAT',
    value: 40,
    minCart: 199,
    maxUses: 1800,
    redemptions: 1776,
    active: false,
    automationEnabled: true,
    startsAt: '2026-03-08T09:00',
    endsAt: '2026-03-20T22:30',
    dailyBudget: 12000,
    totalBudget: 190000,
    spendToday: 12000,
    spendTotal: 186500,
    pausedByGuardrail: true,
  },
];

function makeCode() {
  const alphabet = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
  let value = '';
  for (let i = 0; i < 8; i += 1) {
    value += alphabet[Math.floor(Math.random() * alphabet.length)];
  }
  return value;
}

function guardrailState(offer: OfferRecord): { level: GuardrailLevel; reason: string } {
  const totalBudgetHit = offer.spendTotal >= offer.totalBudget;
  const dailyBudgetHit = offer.spendToday >= offer.dailyBudget;
  const usageHit = offer.redemptions >= offer.maxUses;

  if (offer.pausedByGuardrail || totalBudgetHit || dailyBudgetHit || usageHit) {
    if (totalBudgetHit) {
      return { level: 'PAUSED', reason: 'Total budget exhausted' };
    }
    if (dailyBudgetHit) {
      return { level: 'PAUSED', reason: 'Daily cap reached' };
    }
    if (usageHit) {
      return { level: 'PAUSED', reason: 'Usage cap reached' };
    }
    return { level: 'PAUSED', reason: 'Paused by guardrail' };
  }

  const dailyUtilization = offer.dailyBudget === 0 ? 0 : offer.spendToday / offer.dailyBudget;
  const totalUtilization = offer.totalBudget === 0 ? 0 : offer.spendTotal / offer.totalBudget;
  if (dailyUtilization >= 0.85 || totalUtilization >= 0.85) {
    return { level: 'RISK', reason: 'Approaching budget cap' };
  }
  return { level: 'OK', reason: 'Healthy' };
}

export default function OffersPage() {
  const [offers, setOffers] = useState(seedOffers);
  const [viewDate, setViewDate] = useState('2026-03-09');
  const [viewQuery, setViewQuery] = useState('');
  const [viewCity, setViewCity] = useState('');
  const [viewStatus, setViewStatus] = useState<'ALL' | 'ACTIVE' | 'PAUSED' | 'RISK'>('ALL');
  const [code, setCode] = useState(makeCode());
  const [title, setTitle] = useState('City boost');
  const [city, setCity] = useState('Gurgaon');
  const [audience, setAudience] = useState<AudienceSegment>('ALL');
  const [kind, setKind] = useState<DiscountKind>('PERCENT');
  const [value, setValue] = useState(20);
  const [minCart, setMinCart] = useState(199);
  const [maxUses, setMaxUses] = useState(3000);
  const [dailyBudget, setDailyBudget] = useState(15000);
  const [totalBudget, setTotalBudget] = useState(280000);
  const [startsAt, setStartsAt] = useState('2026-03-08T10:00');
  const [endsAt, setEndsAt] = useState('2026-03-31T23:00');
  const [automationEnabled, setAutomationEnabled] = useState(true);

  const cityOptions = useMemo(
    () => [...new Set(offers.map((item) => item.city.toUpperCase()))].sort(),
    [offers],
  );

  const visibleOffers = useMemo(
    () =>
      offers.filter((item) => {
        const startsDay = item.startsAt.slice(0, 10);
        const endsDay = item.endsAt.slice(0, 10);
        const city = item.city.toUpperCase();
        const guard = guardrailState(item);
        const haystack =
          `${item.id} ${item.code} ${item.title} ${item.city} ${item.audience} ${item.kind}`.toLowerCase();
        const q = viewQuery.trim().toLowerCase();

        const activeOnDay = startsDay <= viewDate && viewDate <= endsDay;
        if (!activeOnDay) return false;
        if (viewCity && city !== viewCity.toUpperCase()) return false;
        if (viewStatus === 'ACTIVE' && !item.active) return false;
        if (viewStatus === 'PAUSED' && item.active) return false;
        if (viewStatus === 'RISK' && guard.level === 'OK') return false;
        if (q && !haystack.includes(q)) return false;
        return true;
      }),
    [offers, viewCity, viewDate, viewQuery, viewStatus],
  );

  const stats = useMemo(() => {
    const active = visibleOffers.filter((item) => item.active).length;
    const redemptions = visibleOffers.reduce((sum, item) => sum + item.redemptions, 0);
    const avgDiscount =
      visibleOffers.length === 0
        ? 0
        : visibleOffers.reduce((sum, item) => sum + item.value, 0) / visibleOffers.length;
    const utilization =
      visibleOffers.length === 0
        ? 0
        : visibleOffers.reduce((sum, item) => sum + item.spendTotal / item.totalBudget, 0) /
          visibleOffers.length;
    const guardrailAlerts = visibleOffers.filter((item) => guardrailState(item).level !== 'OK').length;

    return {
      active,
      redemptions,
      avgDiscount: avgDiscount.toFixed(1),
      utilization: Math.round(utilization * 100),
      guardrailAlerts,
    };
  }, [visibleOffers]);

  const guardrailQueue = useMemo(
    () => visibleOffers.filter((item) => guardrailState(item).level !== 'OK'),
    [visibleOffers],
  );

  const recommendations = useMemo(() => {
    const items: Array<{
      id: RecommendationAction;
      title: string;
      note: string;
      cta: string;
    }> = [];

    if (guardrailQueue.length > 0) {
      items.push({
        id: 'RUN_GUARDRAIL',
        title: `Resolve ${guardrailQueue.length} guardrail alert${guardrailQueue.length > 1 ? 's' : ''}`,
        note: 'Auto-pause risky campaigns before budget bleed.',
        cta: 'Run guardrails',
      });
    }

    if (stats.active > 0 && stats.utilization < 55) {
      items.push({
        id: 'SIM_HOUR',
        title: 'Scale campaign pacing',
        note: 'Utilization is low. Simulate and monitor spend acceleration.',
        cta: 'Simulate hour',
      });
    }

    if (stats.active < 2) {
      items.push({
        id: 'CREATE_CAMPAIGN',
        title: 'Launch one more city campaign',
        note: 'Low active coverage across cities can reduce acquisition.',
        cta: 'Use current draft',
      });
    }

    return items;
  }, [guardrailQueue.length, stats.active, stats.utilization]);

  function issueOffer(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();
    const sanitizedCode = code.trim().toUpperCase();
    const sanitizedTitle = title.trim();

    if (!sanitizedCode || !sanitizedTitle) return;

    const record: OfferRecord = {
      id: `OFF-${100 + offers.length + 1}`,
      code: sanitizedCode,
      title: sanitizedTitle,
      city: city.trim() || 'All Cities',
      audience,
      kind,
      value: Number(value),
      minCart: Number(minCart),
      maxUses: Number(maxUses),
      redemptions: 0,
      active: true,
      automationEnabled,
      startsAt,
      endsAt,
      dailyBudget: Number(dailyBudget),
      totalBudget: Number(totalBudget),
      spendToday: 0,
      spendTotal: 0,
      pausedByGuardrail: false,
    };

    setOffers((prev) => [record, ...prev]);
    setCode(makeCode());
    setTitle('City boost');
    setCity('Gurgaon');
    setAudience('ALL');
    setKind('PERCENT');
    setValue(20);
    setMinCart(199);
    setMaxUses(3000);
    setDailyBudget(15000);
    setTotalBudget(280000);
    setStartsAt('2026-03-08T10:00');
    setEndsAt('2026-03-31T23:00');
    setAutomationEnabled(true);
  }

  function toggleStatus(id: string) {
    setOffers((prev) =>
      prev.map((item) =>
        item.id === id ? { ...item, active: !item.active, pausedByGuardrail: false } : item,
      ),
    );
  }

  function runGuardrailCheck() {
    setOffers((prev) =>
      prev.map((item) => {
        const guard = guardrailState(item);
        if (guard.level === 'PAUSED' && item.active) {
          return { ...item, active: false, pausedByGuardrail: true };
        }
        return item;
      }),
    );
  }

  function simulateAutomationTick() {
    setOffers((prev) =>
      prev.map((item) => {
        if (!item.active || !item.automationEnabled) return item;
        const spendIncrement = Math.max(80, item.value * 6);
        const usageIncrement = Math.max(1, Math.round(item.value / 20));
        const next = {
          ...item,
          spendToday: item.spendToday + spendIncrement,
          spendTotal: item.spendTotal + spendIncrement,
          redemptions: Math.min(item.maxUses, item.redemptions + usageIncrement),
        };
        const guard = guardrailState(next);
        if (guard.level === 'PAUSED') {
          return {
            ...next,
            active: false,
            pausedByGuardrail: true,
          };
        }
        return next;
      }),
    );
  }

  function resetDailySpend() {
    setOffers((prev) =>
      prev.map((item) => ({
        ...item,
        spendToday: 0,
        pausedByGuardrail:
          item.spendTotal >= item.totalBudget || item.redemptions >= item.maxUses
            ? item.pausedByGuardrail
            : false,
      })),
    );
  }

  function applyRecommendation(action: RecommendationAction) {
    if (action === 'RUN_GUARDRAIL') {
      runGuardrailCheck();
      return;
    }
    if (action === 'SIM_HOUR') {
      simulateAutomationTick();
      return;
    }
    if (action === 'CREATE_CAMPAIGN') {
      const syntheticEvent = {
        preventDefault: () => undefined,
      } as FormEvent<HTMLFormElement>;
      issueOffer(syntheticEvent);
    }
  }

  return (
    <section>
      <div className="page-header">
        <div>
          <h2>Offers & Coupons Automation</h2>
          <p className="muted">
            One dashboard for coupon issuance, automation rules, and budget guardrails.
          </p>
        </div>
        <div className="toolbar">
          <button className="btn" type="button" onClick={simulateAutomationTick}>
            Simulate 1 hour
          </button>
          <button className="btn" type="button" onClick={resetDailySpend}>
            Reset daily spend
          </button>
          <button className="btn btn-primary" type="button" onClick={runGuardrailCheck}>
            Run guardrail check
          </button>
        </div>
      </div>
      <div className="filter-bar">
        <label className="filter-field">
          <span>Day</span>
          <input
            className="input"
            type="date"
            value={viewDate}
            onChange={(event) => setViewDate(event.target.value)}
          />
        </label>
        <label className="filter-field">
          <span>Search</span>
          <input
            className="input"
            type="search"
            value={viewQuery}
            onChange={(event) => setViewQuery(event.target.value)}
            placeholder="Code or campaign"
          />
        </label>
        <label className="filter-field">
          <span>City</span>
          <select
            className="input"
            value={viewCity}
            onChange={(event) => setViewCity(event.target.value)}
          >
            <option value="">All cities</option>
            {cityOptions.map((cityOption) => (
              <option key={cityOption} value={cityOption}>
                {cityOption}
              </option>
            ))}
          </select>
        </label>
        <label className="filter-field">
          <span>Status</span>
          <select
            className="input"
            value={viewStatus}
            onChange={(event) => setViewStatus(event.target.value as 'ALL' | 'ACTIVE' | 'PAUSED' | 'RISK')}
          >
            <option value="ALL">All</option>
            <option value="ACTIVE">Active</option>
            <option value="PAUSED">Paused</option>
            <option value="RISK">Risk only</option>
          </select>
        </label>
        <div className="filter-actions">
          <button
            className="btn"
            type="button"
            onClick={() => {
              setViewDate('2026-03-09');
              setViewQuery('');
              setViewCity('');
              setViewStatus('ALL');
            }}
          >
            Reset
          </button>
        </div>
      </div>

      <div className="grid">
        <article className="card">
          <p className="muted">Active campaigns</p>
          <h3>{stats.active}</h3>
        </article>
        <article className="card">
          <p className="muted">Total redemptions</p>
          <h3>{stats.redemptions}</h3>
        </article>
        <article className="card">
          <p className="muted">Avg discount value</p>
          <h3>{stats.avgDiscount}</h3>
        </article>
        <article className="card">
          <p className="muted">Budget utilization</p>
          <h3>{stats.utilization}%</h3>
        </article>
        <article className="card">
          <p className="muted">Guardrail alerts</p>
          <h3>{stats.guardrailAlerts}</h3>
        </article>
      </div>

      <article className="card" style={{ marginTop: 14 }}>
        <h3 style={{ marginTop: 0 }}>Automation recommendations</h3>
        {recommendations.length === 0 ? (
          <p className="muted">No actions needed right now. Campaign health is stable.</p>
        ) : (
          <div className="recommendation-list">
            {recommendations.map((item) => (
              <div key={item.id} className="recommendation-item">
                <div>
                  <strong>{item.title}</strong>
                  <p className="muted">{item.note}</p>
                </div>
                <button className="btn" type="button" onClick={() => applyRecommendation(item.id)}>
                  {item.cta}
                </button>
              </div>
            ))}
          </div>
        )}
      </article>

      <article className="card" style={{ marginTop: 14 }}>
        <h3 style={{ marginTop: 0 }}>Issue coupon campaign</h3>
        <form className="form-grid" onSubmit={issueOffer}>
          <label>
            <span>Coupon code</span>
            <input
              className="input"
              value={code}
              onChange={(event) => setCode(event.target.value.toUpperCase())}
              required
            />
          </label>
          <label>
            <span>Campaign name</span>
            <input
              className="input"
              value={title}
              onChange={(event) => setTitle(event.target.value)}
              required
            />
          </label>
          <label>
            <span>City</span>
            <input className="input" value={city} onChange={(event) => setCity(event.target.value)} />
          </label>
          <label>
            <span>Audience segment</span>
            <select
              className="input"
              value={audience}
              onChange={(event) => setAudience(event.target.value as AudienceSegment)}
            >
              <option value="ALL">All users</option>
              <option value="NEW_USERS">New users</option>
              <option value="LOYAL_USERS">Loyal users</option>
              <option value="DORMANT_USERS">Dormant users</option>
            </select>
          </label>
          <label>
            <span>Discount type</span>
            <select
              className="input"
              value={kind}
              onChange={(event) => setKind(event.target.value as DiscountKind)}
            >
              <option value="FLAT">Flat</option>
              <option value="PERCENT">Percent</option>
            </select>
          </label>
          <label>
            <span>Discount value</span>
            <input
              className="input"
              type="number"
              value={value}
              min={1}
              onChange={(event) => setValue(Number(event.target.value))}
              required
            />
          </label>
          <label>
            <span>Minimum cart</span>
            <input
              className="input"
              type="number"
              value={minCart}
              min={0}
              onChange={(event) => setMinCart(Number(event.target.value))}
              required
            />
          </label>
          <label>
            <span>Usage cap</span>
            <input
              className="input"
              type="number"
              value={maxUses}
              min={1}
              onChange={(event) => setMaxUses(Number(event.target.value))}
              required
            />
          </label>
          <label>
            <span>Daily budget cap</span>
            <input
              className="input"
              type="number"
              value={dailyBudget}
              min={100}
              onChange={(event) => setDailyBudget(Number(event.target.value))}
              required
            />
          </label>
          <label>
            <span>Total budget cap</span>
            <input
              className="input"
              type="number"
              value={totalBudget}
              min={100}
              onChange={(event) => setTotalBudget(Number(event.target.value))}
              required
            />
          </label>
          <label>
            <span>Start time</span>
            <input
              className="input"
              type="datetime-local"
              value={startsAt}
              onChange={(event) => setStartsAt(event.target.value)}
            />
          </label>
          <label>
            <span>End time</span>
            <input
              className="input"
              type="datetime-local"
              value={endsAt}
              onChange={(event) => setEndsAt(event.target.value)}
            />
          </label>
          <label className="switch-row">
            <span>Automation mode</span>
            <input
              type="checkbox"
              checked={automationEnabled}
              onChange={(event) => setAutomationEnabled(event.target.checked)}
            />
          </label>
          <div className="toolbar">
            <button className="btn btn-primary" type="submit">
              Issue campaign
            </button>
            <button className="btn" type="button" onClick={() => setCode(makeCode())}>
              Regenerate code
            </button>
          </div>
        </form>
      </article>

      <article className="card" style={{ marginTop: 14 }}>
        <h3 style={{ marginTop: 0 }}>Guardrail queue</h3>
        {guardrailQueue.length === 0 ? (
          <p className="muted">No campaigns are at risk right now.</p>
        ) : (
          <div className="guardrail-list">
            {guardrailQueue.map((offer) => {
              const guard = guardrailState(offer);
              return (
                <div key={offer.id} className={`guardrail-item ${guard.level.toLowerCase()}`}>
                  <strong>{offer.code}</strong>
                  <span className="muted">
                    {offer.city} • {offer.title}
                  </span>
                  <span className={`badge guard-${guard.level.toLowerCase()}`}>{guard.reason}</span>
                </div>
              );
            })}
          </div>
        )}
      </article>

      <article className="card" style={{ marginTop: 14 }}>
        <h3 style={{ marginTop: 0 }}>Live coupon table</h3>
        <p className="muted">Showing {visibleOffers.length} campaign(s) for {viewDate}</p>
        <table className="table">
          <thead>
            <tr>
              <th>Code</th>
              <th>Campaign</th>
              <th>Discount</th>
              <th>Budget</th>
              <th>Usage</th>
              <th>Guardrail</th>
              <th>Status</th>
              <th>Action</th>
            </tr>
          </thead>
          <tbody>
            {visibleOffers.map((offer) => {
              const guard = guardrailState(offer);
              return (
                <tr key={offer.id}>
                  <td>{offer.code}</td>
                  <td>
                    <strong>{offer.title}</strong>
                    <div className="muted">
                      {offer.city} • {offer.audience.replace('_', ' ')}
                    </div>
                  </td>
                  <td>{offer.kind === 'FLAT' ? `₹${offer.value}` : `${offer.value}%`}</td>
                  <td>
                    <div>Today: ₹{offer.spendToday} / ₹{offer.dailyBudget}</div>
                    <div className="muted">Total: ₹{offer.spendTotal} / ₹{offer.totalBudget}</div>
                  </td>
                  <td>
                    {offer.redemptions}/{offer.maxUses}
                  </td>
                  <td>
                    <span className={`badge guard-${guard.level.toLowerCase()}`}>{guard.reason}</span>
                  </td>
                  <td>
                    <span className={`badge ${offer.active ? 'status-active' : 'status-paused'}`}>
                      {offer.active ? 'ACTIVE' : 'PAUSED'}
                    </span>
                  </td>
                  <td>
                    <button className="btn" onClick={() => toggleStatus(offer.id)}>
                      {offer.active ? 'Pause' : 'Activate'}
                    </button>
                  </td>
                </tr>
              );
            })}
          </tbody>
        </table>
      </article>
    </section>
  );
}

'use client';

import Link from 'next/link';
import { usePathname } from 'next/navigation';

const links = [
  { href: '/', label: 'Overview' },
  { href: '/orders', label: 'Orders' },
  { href: '/subscriptions', label: 'Subscriptions' },
  { href: '/offers', label: 'Offers & Coupons' },
  { href: '/menus', label: 'Menus' },
  { href: '/dispatch', label: 'Partner Fulfillment' },
  { href: '/cities', label: 'Cities & Kitchens' },
  { href: '/payments', label: 'Payments' },
  { href: '/analytics', label: 'Analytics' },
];

export function Navigation() {
  const pathname = usePathname();

  return (
    <aside className="sidebar">
      <h1 className="brand">Foodily Ops</h1>
      <nav className="nav">
        {links.map((link) => (
          <Link
            key={link.href}
            href={link.href}
            className={pathname === link.href ? 'active' : undefined}
          >
            {link.label}
          </Link>
        ))}
      </nav>
    </aside>
  );
}

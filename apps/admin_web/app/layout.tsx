import type { Metadata } from 'next';
import './globals.css';

import { Navigation } from '../components/navigation';

export const metadata: Metadata = {
  title: 'Foodily Admin',
  description: 'Operations dashboard for Foodily',
};

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="en">
      <body>
        <div className="layout">
          <Navigation />
          <main className="content">{children}</main>
        </div>
      </body>
    </html>
  );
}

import Link from "next/link";
import type { ReactNode } from "react";
import { AppShell } from "@narrio/ui";
import "./globals.css";

export const metadata = {
  title: "Narrio",
  description: "Where stories branch forever."
};

export default function RootLayout(props: { children: ReactNode }) {
  return (
    <html lang="en">
      <body>
        <AppShell>
          <header className="narrio-topbar">
            <Link className="narrio-logo" href="/" aria-label="Narrio home">
              <span className="narrio-brand-mark">N</span>
              <span className="narrio-brand-word">
                <span>Narrio</span>
                <span className="narrio-brand-subtitle">ForkCraft Engine</span>
              </span>
            </Link>
            <nav className="narrio-nav" aria-label="Main navigation">
              <Link href="/onboarding">Start Here</Link>
              <Link href="/library">Explore</Link>
              <Link href="/write">Write</Link>
              <Link href="/write/bookmarks">Waypoints</Link>
              <Link href="/activity">Pulse</Link>
              <Link href="/signin">Sign in</Link>
            </nav>
          </header>
          {props.children}
        </AppShell>
      </body>
    </html>
  );
}

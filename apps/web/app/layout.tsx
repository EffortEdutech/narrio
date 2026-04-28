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
            <div className="narrio-brand">Narrio</div>
            <nav className="narrio-nav">
              <Link href="/">Home</Link>
              <Link href="/onboarding">Start Here</Link>
              <Link href="/library">Library</Link>
              <Link href="/write">Write</Link>
              <Link href="/write/bookmarks">Waypoints</Link>
              <Link href="/activity">Activity</Link>
              <Link href="/signin">Sign in</Link>
            </nav>
          </header>
          {props.children}
        </AppShell>
      </body>
    </html>
  );
}

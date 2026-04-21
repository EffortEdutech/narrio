import Link from "next/link";
import type { ReactNode } from "react";
import { AppShell } from "@narrio/ui";
import "./globals.css";

export const metadata = {
  title: "Narrio",
  description: "Branch-first social storytelling"
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
              <Link href="/library">Library</Link>
              <Link href="/write">Write</Link>
              <Link href="/signin">Sign in</Link>
            </nav>
          </header>
          {props.children}
        </AppShell>
      </body>
    </html>
  );
}

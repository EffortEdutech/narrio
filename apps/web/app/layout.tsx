import type { ReactNode } from "react";
import Link from "next/link";
import "./globals.css";

export const metadata = {
  title: "Narrio",
  description: "Branch-first social storytelling"
};

export default function RootLayout(props: { children: ReactNode }) {
  return (
    <html lang="en">
      <body>
        <div className="narrio-shell">
          <nav className="narrio-nav">
            <div className="narrio-nav-links">
              <Link className="narrio-button" href="/">
                Narrio
              </Link>
              <Link className="narrio-button" href="/library">
                Library
              </Link>
            </div>
            <span className="narrio-badge">Sprint 1 Foundation</span>
          </nav>
          {props.children}
        </div>
      </body>
    </html>
  );
}

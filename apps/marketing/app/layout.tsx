import type { ReactNode } from "react";
import "./globals.css";

const appUrl =
  process.env.NEXT_PUBLIC_NARRIO_APP_URL ??
  process.env.NEXT_PUBLIC_APP_URL ??
  "http://localhost:3900";

export const metadata = {
  title: "Narrio — Where stories branch forever",
  description:
    "Narrio is a social storytelling platform where readers fork chapters, create timelines, and build living story universes with Forkcraft."
};

export default function RootLayout(props: { children: ReactNode }) {
  return (
    <html lang="en">
      <body>
        <div className="marketing-shell">
          <header className="marketing-nav" aria-label="Narrio marketing navigation">
            <a className="marketing-logo" href="/" aria-label="Narrio home">
              <span className="logo-mark" aria-hidden="true">N</span>
              <span>Narrio</span>
            </a>

            <nav>
              <a href="#forkcraft">Forkcraft</a>
              <a href={`${appUrl}/library`}>Explore</a>
              <a href={`${appUrl}/write`}>Write</a>
            </nav>
          </header>

          {props.children}

          <footer className="marketing-footer">
            <p>Narrio — Where stories branch forever.</p>
            <p>Forkcraft is the engine that turns readers into creators.</p>
          </footer>
        </div>
      </body>
    </html>
  );
}

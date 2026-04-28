"use client";

import Link from "next/link";
import styles from "./status.module.css";

export default function GlobalError({ reset }: { error: Error & { digest?: string }; reset: () => void }) {
  return (
    <main className={styles.statusShell}>
      <section className={styles.statusCard}>
        <span className={styles.statusEyebrow}>Timeline disruption</span>
        <h1>Something interrupted this path.</h1>
        <p>Refresh this branch of the experience, or return to Library and choose another story universe.</p>
        <div className={styles.statusActions}>
          <button className="narrio-button" type="button" onClick={() => reset()}>
            Try again
          </button>
          <Link className="narrio-button-secondary" href="/library">
            Explore Library
          </Link>
        </div>
      </section>
    </main>
  );
}

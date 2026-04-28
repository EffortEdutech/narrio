import Link from "next/link";
import styles from "./status.module.css";

export default function NotFound() {
  return (
    <main className={styles.statusShell}>
      <section className={styles.statusCard}>
        <span className={styles.statusEyebrow}>Lost timeline</span>
        <h1>This path does not exist yet.</h1>
        <p>The story, chapter, or writer profile may be private, unpublished, or moved into another branch.</p>
        <div className={styles.statusActions}>
          <Link className="narrio-button" href="/library">
            Explore Library
          </Link>
          <Link className="narrio-button-secondary" href="/write">
            Go to Writer Studio
          </Link>
        </div>
      </section>
    </main>
  );
}

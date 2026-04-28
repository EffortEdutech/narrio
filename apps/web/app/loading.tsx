import styles from "./status.module.css";

export default function Loading() {
  return (
    <main className={styles.statusShell}>
      <section className={styles.statusCard}>
        <span className={styles.statusEyebrow}>Opening path</span>
        <h1>Loading the story universe.</h1>
        <p>Narrio is preparing the next readable branch for you.</p>
        <div className={styles.loadingDots} aria-hidden="true">
          <span />
          <span />
          <span />
        </div>
      </section>
    </main>
  );
}

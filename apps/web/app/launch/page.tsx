import Link from "next/link";
import { InlineMeta, PageHeader, SectionCard, Stack } from "@narrio/ui";
import styles from "./launch.module.css";

const launchChecks = [
  {
    title: "Public story page",
    status: "Ready",
    note: "Story hero, start reading, timeline chooser, writer link, and reader follow action."
  },
  {
    title: "Library discovery",
    status: "Ready",
    note: "Search, sort, ForkCraft filters, latest chapter signals, and author profile links."
  },
  {
    title: "Writer profile",
    status: "Ready",
    note: "Creator identity, featured universe, public story cards, and profile health stats."
  },
  {
    title: "Launch states",
    status: "Ready",
    note: "Branded loading, not-found, and recoverable error screens."
  },
  {
    title: "Manual QA",
    status: "Needs local pass",
    note: "Run the Sprint 6.4/6.5 manual route checklist before commit."
  }
];

export default function LaunchReadinessPage() {
  return (
    <Stack>
      <section className={styles.launchHero}>
        <div>
          <PageHeader
            eyebrow="Launch readiness"
            title="Narrio public discovery checkpoint"
            description="A simple internal route to verify that the public reader journey, creator profile, Library, and branded fallback states are ready for demo use."
          />
          <InlineMeta>
            <span>Sprint 6.4 profile layer</span>
            <span>Sprint 6.5 launch polish</span>
            <span>Manual QA before commit</span>
          </InlineMeta>
        </div>

        <div className={styles.heroCard}>
          <span>Demo path</span>
          <strong>Library → Story → Timeline → Chapter → Writer Profile</strong>
          <p>This is the minimum public journey Narrio should feel confident presenting.</p>
        </div>
      </section>

      <div className={styles.checkGrid}>
        {launchChecks.map((item) => (
          <article key={item.title} className={styles.checkCard}>
            <div className={styles.checkTopline}>
              <span>{item.status}</span>
            </div>
            <h2>{item.title}</h2>
            <p>{item.note}</p>
          </article>
        ))}
      </div>

      <SectionCard title="Smoke test shortcuts" description="Use these routes after applying the patch locally.">
        <div className={styles.shortcutGrid}>
          <Link className="narrio-button" href="/library">
            Open Library
          </Link>
          <Link className="narrio-button-secondary" href="/write">
            Open Writer Studio
          </Link>
          <Link className="narrio-button-secondary" href="/onboarding">
            Open Onboarding
          </Link>
          <Link className="narrio-button-secondary" href="/missing-narrio-route-check">
            Test Not Found
          </Link>
        </div>
      </SectionCard>
    </Stack>
  );
}

import Link from "next/link";
import { BRAND } from "@narrio/config";
import { SectionCard, Stack } from "@narrio/ui";

export default function HomePage() {
  return (
    <Stack>
      <section className="narrio-hero narrio-home-hero" aria-labelledby="home-hero-title">
        <div className="narrio-hero-grid">
          <div className="narrio-hero-copy">
            <div className="narrio-eyebrow">Powered by {BRAND.engine}</div>
            <h1 id="home-hero-title">Every story has another path.</h1>
            <p>
              {BRAND.tagline} Read a chapter, follow the canon, save a waypoint, or start ForkCraft and
              create a timeline that only you imagined.
            </p>
            <div className="narrio-hero-actions">
              <Link className="narrio-button" href="/onboarding">
                Start in 60 seconds
              </Link>
              <Link className="narrio-button-secondary" href="/library">
                Explore universes
              </Link>
              <Link className="narrio-button-secondary" href="/write">
                Open Story Studio
              </Link>
            </div>

            <div className="narrio-hero-kpis" aria-label="Narrio promise">
              <div className="narrio-kpi">
                <strong>Read</strong>
                <span>Discover a timeline</span>
              </div>
              <div className="narrio-kpi">
                <strong>Fork</strong>
                <span>Change the path</span>
              </div>
              <div className="narrio-kpi">
                <strong>Craft</strong>
                <span>Release your version</span>
              </div>
            </div>
          </div>

          <div className="narrio-hero-visual" aria-hidden="true">
            <div className="narrio-orbit-card">
              <div className="narrio-orbit-node root">Canon</div>
              <div className="narrio-orbit-node a">A</div>
              <div className="narrio-orbit-node b">B</div>
              <div className="narrio-orbit-node c">C</div>
              <div className="narrio-orbit-node d">D</div>
            </div>
          </div>
        </div>
      </section>

      <div className="narrio-feature-grid" aria-label="Narrio core loop">
        <article className="narrio-feature-card">
          <div className="narrio-feature-icon">📖</div>
          <strong>Explore timelines</strong>
          <p className="narrio-muted">
            Open a story as a reader first. Follow the root path or discover variant timelines.
          </p>
        </article>
        <article className="narrio-feature-card">
          <div className="narrio-feature-icon">🔖</div>
          <strong>Save waypoints</strong>
          <p className="narrio-muted">
            Mark the chapter that became a clue, quote, reread point, or fork idea.
          </p>
        </article>
        <article className="narrio-feature-card">
          <div className="narrio-feature-icon">✨</div>
          <strong>Start ForkCraft</strong>
          <p className="narrio-muted">
            Create a private draft timeline from any allowed chapter and continue the story your way.
          </p>
        </article>
      </div>

      <SectionCard
        title="How ForkCraft works"
        description="The app keeps the structure simple: one story can grow into many readable paths."
      >
        <div className="narrio-fork-preview">
          <div>
            <strong>01 · Story</strong>
            <p className="narrio-muted">A universe begins with a story and a canon timeline.</p>
          </div>
          <div>
            <strong>02 · Chapter</strong>
            <p className="narrio-muted">A chapter becomes a possible branch point for new choices.</p>
          </div>
          <div>
            <strong>03 · Timeline</strong>
            <p className="narrio-muted">ForkCraft turns that choice into a readable alternate path.</p>
          </div>
        </div>
      </SectionCard>

      <div className="narrio-choice-grid">
        <Link className="narrio-choice-card" href="/library">
          <div className="narrio-choice-icon">🌌</div>
          <strong>I want to explore</strong>
          <p className="narrio-muted">Browse public stories and find timelines to follow.</p>
        </Link>
        <Link className="narrio-choice-card" href="/write/new">
          <div className="narrio-choice-icon">✍️</div>
          <strong>I want to create</strong>
          <p className="narrio-muted">Craft a new universe, chapter by chapter.</p>
        </Link>
      </div>
    </Stack>
  );
}

import { BRAND } from "@narrio/config";

const appUrl =
  process.env.NEXT_PUBLIC_NARRIO_APP_URL ??
  process.env.NEXT_PUBLIC_APP_URL ??
  "http://localhost:3900";

const forkcraftSteps = [
  {
    step: "01",
    title: "Read a universe",
    body: "Enter a universe and follow the canon timeline or explore variant paths."
  },
  {
    step: "02",
    title: "Fork a chapter",
    body: "Start Forkcraft from any turning point and create your own timeline."
  },
  {
    step: "03",
    title: "Release your timeline",
    body: "Your version becomes part of the living story tree for others to read and fork."
  }
];

const featureCards = [
  {
    icon: "🌳",
    title: "Timeline-first storytelling",
    body: "Stories grow as branches, not static posts. Every path has context, origin, and possibility."
  },
  {
    icon: "🍴",
    title: "Forkcraft engine",
    body: "Readers can become creators by forking a chapter and writing what happens next."
  },
  {
    icon: "✍️",
    title: "Creator studio",
    body: "Write, commit versions, explore histories, and shape your story universe over time."
  },
  {
    icon: "🔖",
    title: "Waypoints and bookmarks",
    body: "Save the moments, theories, twists, and alternate endings that matter to you."
  }
];

const demoTimelines = [
  { name: "main", label: "Canon path", tone: "Original story spine" },
  { name: "dragon-lives", label: "Variant", tone: "What if the dragon survived?" },
  { name: "villain-wins", label: "Variant", tone: "A darker ending rises" },
  { name: "secret-heir", label: "Fork of fork", tone: "A new bloodline appears" }
];

export default function MarketingPage() {
  return (
    <main>
      <section className="hero-section" aria-labelledby="hero-heading">
        <div className="hero-grid">
          <div className="hero-copy">
            <a className="brand-pill" href="#forkcraft">
              <span className="brand-dot" aria-hidden="true" />
              Powered by {BRAND.engine}
            </a>

            <h1 id="hero-heading">{BRAND.heroTitle}</h1>

            <p className="hero-lead">
              {BRAND.name} is a social storytelling platform where stories branch,
              fork, and evolve into new timelines.
            </p>

            <p className="hero-subtitle">{BRAND.heroSubtitle}</p>

            <div className="hero-actions" aria-label="Primary actions">
              <a className="marketing-button marketing-button-primary" href={`${appUrl}/write`}>
                Start Forkcraft
              </a>
              <a className="marketing-button marketing-button-secondary" href={`${appUrl}/library`}>
                Explore universes
              </a>
            </div>

            <div className="trust-strip" aria-label="Narrio promise">
              <span>Branching stories</span>
              <span>Reader-to-writer loop</span>
              <span>Creator-owned timelines</span>
            </div>
          </div>

          <div className="hero-visual" aria-label="Narrio story tree preview">
            <div className="orbit orbit-one" />
            <div className="orbit orbit-two" />

            <div className="story-tree-card">
              <div className="story-tree-header">
                <span className="tree-badge">Live story tree</span>
                <span className="tree-status">Early access</span>
              </div>

              <div className="tree-map">
                <div className="tree-row tree-row-root">
                  <span className="tree-node active">1</span>
                  <span className="tree-line horizontal" />
                  <span className="tree-node active">2</span>
                  <span className="tree-line split" />
                </div>

                <div className="tree-row tree-row-branches">
                  <span className="tree-node canon">3A</span>
                  <span className="tree-node variant">3B</span>
                </div>

                <div className="tree-row tree-row-leaves">
                  <span className="tree-node small">4A</span>
                  <span className="tree-node small glow">4B</span>
                  <span className="tree-node small">4C</span>
                </div>
              </div>

              <div className="timeline-preview">
                <p className="preview-kicker">Example prompt</p>
                <p>
                  “What if the dragon did not die, but became the kingdom’s
                  hidden protector?”
                </p>
              </div>
            </div>
          </div>
        </div>
      </section>

      <section className="section-panel" id="forkcraft" aria-labelledby="forkcraft-heading">
        <div className="section-heading">
          <p className="section-kicker">The signature loop</p>
          <h2 id="forkcraft-heading">What is Forkcraft?</h2>
          <p>
            Forkcraft is the art of creating alternate story paths. It turns
            reading into participation and every chapter into a possible
            beginning.
          </p>
        </div>

        <div className="step-grid">
          {forkcraftSteps.map((item) => (
            <article className="step-card" key={item.step}>
              <span>{item.step}</span>
              <h3>{item.title}</h3>
              <p>{item.body}</p>
            </article>
          ))}
        </div>
      </section>

      <section className="split-section" aria-labelledby="who-heading">
        <div className="section-heading compact">
          <p className="section-kicker">For both sides of the story</p>
          <h2 id="who-heading">Readers discover. Creators expand.</h2>
        </div>

        <div className="audience-grid">
          <article className="audience-card">
            <div className="audience-icon">📖</div>
            <h3>For reader-explorers</h3>
            <p>
              Follow canon timelines, discover alternate endings, and bookmark
              the moments that deserve another path.
            </p>
            <a href={`${appUrl}/library`}>Enter the library →</a>
          </article>

          <article className="audience-card featured">
            <div className="audience-icon">✍️</div>
            <h3>For Forkcrafters</h3>
            <p>
              Fork a chapter, write your version, and release a timeline that
              others can read, follow, and fork again.
            </p>
            <a href={`${appUrl}/write`}>Open Story Studio →</a>
          </article>
        </div>
      </section>

      <section className="section-panel" aria-labelledby="features-heading">
        <div className="section-heading">
          <p className="section-kicker">Why Narrio is different</p>
          <h2 id="features-heading">Not a blog. Not a fanfic folder. A living story universe.</h2>
        </div>

        <div className="feature-grid">
          {featureCards.map((item) => (
            <article className="feature-card" key={item.title}>
              <span className="feature-icon" aria-hidden="true">{item.icon}</span>
              <h3>{item.title}</h3>
              <p>{item.body}</p>
            </article>
          ))}
        </div>
      </section>

      <section className="universe-demo" aria-labelledby="demo-heading">
        <div>
          <p className="section-kicker">Example universe</p>
          <h2 id="demo-heading">The Last Dragon can become many stories.</h2>
          <p>
            A single story can grow into canon paths, emotional variants,
            experimental forks, and entirely new timelines.
          </p>
        </div>

        <div className="timeline-stack">
          {demoTimelines.map((timeline) => (
            <article className="timeline-row" key={timeline.name}>
              <div>
                <h3>{timeline.name}</h3>
                <p>{timeline.tone}</p>
              </div>
              <span>{timeline.label}</span>
            </article>
          ))}
        </div>
      </section>

      <section className="final-cta" aria-labelledby="cta-heading">
        <p className="section-kicker">Start with one path</p>
        <h2 id="cta-heading">Your story is waiting to branch.</h2>
        <p>
          Open Narrio, explore the first timelines, and practice Forkcraft from
          the chapter where everything changes.
        </p>
        <div className="hero-actions centered">
          <a className="marketing-button marketing-button-primary" href={`${appUrl}/onboarding`}>
            Begin first 60 seconds
          </a>
          <a className="marketing-button marketing-button-secondary" href={`${appUrl}/library`}>
            Browse public universes
          </a>
        </div>
      </section>
    </main>
  );
}

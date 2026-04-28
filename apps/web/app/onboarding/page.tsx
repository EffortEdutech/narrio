import Link from "next/link";
import { listPublishedStories, listStoriesByAuthor } from "@narrio/api";
import { BRAND } from "@narrio/config";
import { SectionCard, Stack } from "@narrio/ui";
import { createClient } from "../../lib/supabase/server";

export default async function OnboardingPage() {
  const supabase = await createClient();
  const {
    data: { user }
  } = await supabase.auth.getUser();

  const [publicStories, myStories] = await Promise.all([
    listPublishedStories(supabase).catch(() => []),
    user ? listStoriesByAuthor(supabase, user.id).catch(() => []) : Promise.resolve([])
  ]);

  const featuredStory = publicStories[0];
  const myFirstStory = myStories[0];
  const featuredStoryHref = featuredStory ? `/story/${featuredStory.id}` : "/library";
  const featuredTimelineHref = featuredStory ? `/story/${featuredStory.id}/timelines` : "/library";
  const writerHref = myFirstStory?.main_branch_id
    ? `/write/editor/${myFirstStory.id}/branch/${myFirstStory.main_branch_id}`
    : "/write/new";

  return (
    <Stack>
      <section className="narrio-hero narrio-onboarding-hero" aria-labelledby="onboarding-title">
        <div className="narrio-hero-grid">
          <div className="narrio-hero-copy">
            <div className="narrio-eyebrow">{BRAND.engine} first run</div>
            <h1 id="onboarding-title">Start Narrio in 60 seconds.</h1>
            <p>
              Learn the core loop: read a chapter, explore timelines, save a waypoint, fork a path,
              then write your own version.
            </p>
            <div className="narrio-hero-actions">
              <Link className="narrio-button" href={featuredStoryHref}>
                Start reading
              </Link>
              <Link className="narrio-button-secondary" href={writerHref}>
                Start ForkCraft
              </Link>
            </div>
          </div>

          <div className="narrio-hero-visual" aria-hidden="true">
            <div className="narrio-screen-frame">
              <div className="narrio-screen-top">
                <span>Narrio path</span>
                <span>05 steps</span>
              </div>
              <div className="narrio-screen-card">
                <strong>📖 Read one chapter</strong>
                <span className="narrio-muted">Feel the story before changing it.</span>
              </div>
              <div className="narrio-screen-card">
                <strong>🌳 Explore timelines</strong>
                <span className="narrio-muted">See how one choice becomes many paths.</span>
              </div>
              <div className="narrio-screen-card">
                <strong>✨ Start ForkCraft</strong>
                <span className="narrio-muted">Create a private draft timeline.</span>
              </div>
              <div className="narrio-story-tree-visual">
                <div className="narrio-tree">
                  <i className="l1" />
                  <i className="l2" />
                  <i className="l3" />
                  <span className="n1">1</span>
                  <span className="n2">2</span>
                  <span className="n3">3A</span>
                  <span className="n4">3B</span>
                </div>
              </div>
            </div>
          </div>
        </div>
      </section>

      <section className="narrio-onboarding-path" aria-label="Narrio first-run path">
        <OnboardingStep
          number="01"
          title="Read one chapter"
          description="Open a story and feel the normal reader flow before creating anything."
          href={featuredStoryHref}
          action="Open a story"
        />
        <OnboardingStep
          number="02"
          title="Explore timelines"
          description="See how one story can branch into alternate paths without becoming confusing."
          href={featuredTimelineHref}
          action="Explore timelines"
        />
        <OnboardingStep
          number="03"
          title="Save a waypoint"
          description="Mark a chapter as a favorite, theory, quote, reread point, or fork idea."
          href={featuredStoryHref}
          action="Try a waypoint"
        />
        <OnboardingStep
          number="04"
          title="Fork a path"
          description="From a chapter, create a private draft timeline and continue from that moment."
          href={featuredStoryHref}
          action="Find a fork point"
        />
        <OnboardingStep
          number="05"
          title="Write your version"
          description="Move into Story Studio and continue a timeline with your own chapter."
          href={writerHref}
          action={myFirstStory ? "Open your draft" : "Start a story"}
        />
      </section>

      <div className="narrio-choice-grid">
        <Link className="narrio-choice-card" href="/library">
          <div className="narrio-choice-icon">📖</div>
          <strong>Explore universes</strong>
          <p className="narrio-muted">Read stories and discover the timelines already released.</p>
        </Link>
        <Link className="narrio-choice-card" href={writerHref}>
          <div className="narrio-choice-icon">✍️</div>
          <strong>Start ForkCraft</strong>
          <p className="narrio-muted">Create your own story or continue from a fork point.</p>
        </Link>
      </div>

      <div className="narrio-two-column">
        <SectionCard title="Reader loop" description="Use this path when you want to understand Narrio as a reader first.">
          <div className="narrio-list">
            <Link className="narrio-list-item" href="/library">
              <strong>Find a public story</strong>
              <div className="narrio-muted">Browse stories that are ready to read.</div>
            </Link>
            <Link className="narrio-list-item" href={featuredTimelineHref}>
              <strong>Compare timelines</strong>
              <div className="narrio-muted">Look at branches as reader-friendly story paths.</div>
            </Link>
            <Link className="narrio-list-item" href="/write/bookmarks">
              <strong>Review waypoints</strong>
              <div className="narrio-muted">Return to saved theories, quotes, and fork ideas.</div>
            </Link>
          </div>
        </SectionCard>

        <SectionCard title="Writer loop" description="Use this path when you want to create immediately.">
          <div className="narrio-list">
            <Link className="narrio-list-item" href="/write/new">
              <strong>Create a story</strong>
              <div className="narrio-muted">Start a main timeline for your own world.</div>
            </Link>
            <Link className="narrio-list-item" href={writerHref}>
              <strong>Open Story Studio</strong>
              <div className="narrio-muted">Write chapters, save versions, and fork timelines.</div>
            </Link>
            <Link className="narrio-list-item" href="/activity">
              <strong>Check your pulse</strong>
              <div className="narrio-muted">See follows, waypoints, likes, timelines, and chapters.</div>
            </Link>
          </div>
        </SectionCard>
      </div>

      <SectionCard
        title="What to test after applying this visual sprint"
        description="The design layer should make the Sprint 5 features feel like one coherent product journey."
      >
        <div className="narrio-onboarding-mini">
          <span>Timeline Explorer</span>
          <span>Fork from Chapter</span>
          <span>Waypoints</span>
          <span>Activity Pulse</span>
          <span>Story Studio</span>
        </div>
      </SectionCard>
    </Stack>
  );
}

function OnboardingStep(props: {
  number: string;
  title: string;
  description: string;
  href: string;
  action: string;
}) {
  return (
    <article className="narrio-onboarding-step">
      <div className="narrio-onboarding-number">{props.number}</div>
      <h2>{props.title}</h2>
      <p className="narrio-muted">{props.description}</p>
      <Link className="narrio-button-secondary" href={props.href}>
        {props.action}
      </Link>
    </article>
  );
}

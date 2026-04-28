import Link from "next/link";
import { listMyActivityFeed, type NarrioActivityKind, type NarrioActivityItem } from "@narrio/api";
import { PageHeader, SectionCard, Stack } from "@narrio/ui";
import { requireUser } from "../../lib/auth";

const ACTIVITY_LABEL: Record<NarrioActivityKind, string> = {
  waypoint_saved: "Waypoint",
  story_followed: "Follow",
  chapter_liked: "Like",
  timeline_created: "Timeline",
  chapter_created: "Chapter"
};

const ACTIVITY_ICON: Record<NarrioActivityKind, string> = {
  waypoint_saved: "🔖",
  story_followed: "✨",
  chapter_liked: "❤️",
  timeline_created: "🌿",
  chapter_created: "✍️"
};

export default async function ActivityPage() {
  const { supabase, user } = await requireUser();
  const activity = await listMyActivityFeed(supabase, { userId: user.id, limit: 80 });
  const summary = summarizeActivity(activity);

  return (
    <Stack>
      <PageHeader
        eyebrow="ForkCraft Pulse"
        title="Your activity"
        description="A lightweight feed of the paths you follow, save, like, fork, and write."
        actions={
          <div className="narrio-nav">
            <Link className="narrio-button" href="/library">
              Explore library
            </Link>
            <Link className="narrio-button-secondary" href="/onboarding">
              First 60 seconds
            </Link>
          </div>
        }
      />

      <section className="narrio-stat-grid" aria-label="Activity summary">
        <ActivityStat label="Waypoints" value={summary.waypoints} />
        <ActivityStat label="Follows" value={summary.follows} />
        <ActivityStat label="Likes" value={summary.likes} />
        <ActivityStat label="Timelines" value={summary.timelines} />
      </section>

      <SectionCard
        title="Recent pulse"
        description="This stub is generated from existing Narrio tables, so no new activity table is required yet."
      >
        {activity.length ? (
          <div className="narrio-activity-feed">
            {activity.map((item) => (
              <ActivityItemCard key={item.id} item={item} />
            ))}
          </div>
        ) : (
          <div className="narrio-list-item">
            <strong>No activity yet.</strong>
            <p className="narrio-muted">
              Follow a story, save a waypoint, like a chapter, or fork a timeline to start your pulse.
            </p>
            <Link className="narrio-button-secondary" href="/library">
              Find a story
            </Link>
          </div>
        )}
      </SectionCard>
    </Stack>
  );
}

function ActivityItemCard(props: { item: NarrioActivityItem }) {
  const item = props.item;

  return (
    <article className={`narrio-activity-item ${item.kind}`}>
      <div className="narrio-activity-marker" aria-hidden="true">
        {ACTIVITY_ICON[item.kind]}
      </div>
      <div className="narrio-activity-body">
        <div className="narrio-activity-heading">
          <div>
            <span className="narrio-badge">{ACTIVITY_LABEL[item.kind]}</span>
            <h3>{item.title}</h3>
          </div>
          <time className="narrio-muted" dateTime={item.createdAt}>
            {formatActivityDate(item.createdAt)}
          </time>
        </div>

        <p>{item.description}</p>

        <div className="narrio-inline-meta">
          {item.meta.map((value) => (
            <span key={`${item.id}:${value}`}>{value}</span>
          ))}
        </div>

        <div className="narrio-activity-actions">
          <Link className="narrio-button-secondary" href={item.href}>
            Open
          </Link>
          {item.storyId ? (
            <Link className="narrio-button-secondary" href={`/story/${item.storyId}/timelines`}>
              Timelines
            </Link>
          ) : null}
        </div>
      </div>
    </article>
  );
}

function ActivityStat(props: { label: string; value: number }) {
  return (
    <div className="narrio-stat-card">
      <strong>{props.value}</strong>
      <span>{props.label}</span>
    </div>
  );
}

function summarizeActivity(activity: NarrioActivityItem[]) {
  return {
    waypoints: activity.filter((item) => item.kind === "waypoint_saved").length,
    follows: activity.filter((item) => item.kind === "story_followed").length,
    likes: activity.filter((item) => item.kind === "chapter_liked").length,
    timelines: activity.filter((item) => item.kind === "timeline_created").length
  };
}

function formatActivityDate(value: string) {
  return new Intl.DateTimeFormat("en", {
    dateStyle: "medium",
    timeStyle: "short"
  }).format(new Date(value));
}

import Link from "next/link";
import { PageHeader, SectionCard, Stack } from "@narrio/ui";

export default function HomePage() {
  return (
    <Stack>
      <div className="narrio-hero">
        <PageHeader
          eyebrow="Sprint 2"
          title="Branch-first storytelling now supports publishing and reader feedback."
          description="Create stories, publish chapters, restore drafts, branch into alternate paths, and let readers follow, bookmark, and like."
          actions={
            <div className="narrio-nav">
              <Link className="narrio-button" href="/write">
                Open Writer Area
              </Link>
              <Link className="narrio-button-secondary" href="/library">
                Browse Library
              </Link>
            </div>
          }
        />
      </div>

      <SectionCard
        title="Narrio philosophy"
        description="Simple Git-style branching, not a visual graph-first editor."
      >
        <div className="narrio-list">
          <div className="narrio-list-item">Stories own many branches.</div>
          <div className="narrio-list-item">Branches own many chapters.</div>
          <div className="narrio-list-item">Chapters own many versions.</div>
          <div className="narrio-list-item">Writers can restore a version or branch into a new path.</div>
        </div>
      </SectionCard>
    </Stack>
  );
}

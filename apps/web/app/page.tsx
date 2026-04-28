import Link from "next/link";
import { BRAND } from "@narrio/config";
import { PageHeader, SectionCard, Stack } from "@narrio/ui";

export default function HomePage() {
  return (
    <Stack>
      <div className="narrio-hero">
        <PageHeader
          eyebrow={`Powered by ${BRAND.engine}`}
          title={`Welcome to ${BRAND.name}`}
          description={`${BRAND.tagline} Create stories, fork alternate paths, and explore timelines shaped by writers and readers.`}
          actions={
            <div className="narrio-nav">
              <Link className="narrio-button" href="/write">
                Enter Writer Studio
              </Link>
              <Link className="narrio-button-secondary" href="/library">
                Explore Library
              </Link>
            </div>
          }
        />
      </div>

      <SectionCard
        title="How ForkCraft works"
        description="Stories begin with one path. ForkCraft lets them grow into many timelines."
      >
        <div className="narrio-list">
          <div className="narrio-list-item">A story can hold many timelines.</div>
          <div className="narrio-list-item">Each timeline contains chapters.</div>
          <div className="narrio-list-item">Each chapter keeps its own version history.</div>
          <div className="narrio-list-item">Writers can restore older versions or fork a new path.</div>
        </div>
      </SectionCard>
    </Stack>
  );
}

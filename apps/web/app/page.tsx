import Link from "next/link";
import { PageHeader, SectionCard } from "@narrio/ui";

export default function HomePage() {
  return (
    <div className="narrio-stack">
      <PageHeader
        eyebrow="Narrio"
        title="Branch-first social storytelling"
        description="Read stories, explore branches, and prepare the writer workflow around immutable chapter versions."
        actions={
          <Link className="narrio-button" href="/library">
            Open Library
          </Link>
        }
      />

      <div className="narrio-grid narrio-grid-2">
        <SectionCard
          title="Reader loop"
          description="The first shipped loop is simple: library → story → branch → chapter."
        >
          <div className="narrio-list">
            <div className="narrio-list-item">Library listing of published stories</div>
            <div className="narrio-list-item">Story page with branch explorer</div>
            <div className="narrio-list-item">Chapter page with latest current version</div>
          </div>
        </SectionCard>

        <SectionCard
          title="Writer loop"
          description="Sprint 1 includes the editor shell so the structure exists before we wire create/commit actions."
        >
          <div className="narrio-list">
            <div className="narrio-list-item">Story editor entry</div>
            <div className="narrio-list-item">Branch-specific editor shell</div>
            <div className="narrio-list-item">Version history area</div>
          </div>
        </SectionCard>
      </div>
    </div>
  );
}

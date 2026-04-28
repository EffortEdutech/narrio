import { BRAND } from "@narrio/config";

export default function MarketingPage() {
  return (
    <div className="marketing-card">
      <p className="marketing-eyebrow">Powered by {BRAND.engine}</p>
      <h1>{BRAND.heroTitle}</h1>
      <p className="marketing-lead">
        Welcome to {BRAND.name}. {BRAND.tagline}
      </p>
      <p>{BRAND.heroSubtitle}</p>

      <div className="marketing-actions">
        <a className="marketing-button" href="http://localhost:3900/write">
          Start Writing
        </a>
        <a className="marketing-button marketing-button-secondary" href="http://localhost:3900/library">
          Explore Stories
        </a>
      </div>

      <div className="marketing-list" aria-label="Narrio product promise">
        <div>Write original stories.</div>
        <div>Fork alternate timelines.</div>
        <div>Let readers become writers.</div>
      </div>
    </div>
  );
}

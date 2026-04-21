import type { ReactNode } from "react";

export function PageHeader(props: {
  eyebrow?: string;
  title: string;
  description?: string;
  actions?: ReactNode;
}) {
  return (
    <div className="narrio-card">
      {props.eyebrow ? <div className="narrio-eyebrow">{props.eyebrow}</div> : null}
      <div className="narrio-header-row">
        <div>
          <h1 className="narrio-title">{props.title}</h1>
          {props.description ? <p className="narrio-muted">{props.description}</p> : null}
        </div>
        {props.actions ? <div>{props.actions}</div> : null}
      </div>
    </div>
  );
}

export function SectionCard(props: {
  title: string;
  description?: string;
  children: ReactNode;
}) {
  return (
    <section className="narrio-card">
      <h2 className="narrio-section-title">{props.title}</h2>
      {props.description ? <p className="narrio-muted">{props.description}</p> : null}
      <div>{props.children}</div>
    </section>
  );
}

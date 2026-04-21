import type { PropsWithChildren, ReactNode } from "react";

export function AppShell(props: PropsWithChildren<{ title?: string }>) {
  return <div className="narrio-shell">{props.children}</div>;
}

export function PageHeader(props: {
  eyebrow?: string;
  title: string;
  description?: string;
  actions?: ReactNode;
}) {
  return (
    <div className="narrio-page-header">
      {props.eyebrow ? <div className="narrio-eyebrow">{props.eyebrow}</div> : null}
      <div className="narrio-page-header-row">
        <div>
          <h1>{props.title}</h1>
          {props.description ? <p className="narrio-muted">{props.description}</p> : null}
        </div>
        {props.actions ? <div>{props.actions}</div> : null}
      </div>
    </div>
  );
}

export function SectionCard(props: PropsWithChildren<{ title: string; description?: string }>) {
  return (
    <section className="narrio-card">
      <div className="narrio-card-header">
        <h2>{props.title}</h2>
        {props.description ? <p className="narrio-muted">{props.description}</p> : null}
      </div>
      <div className="narrio-card-body">{props.children}</div>
    </section>
  );
}

export function Stack(props: PropsWithChildren) {
  return <div className="narrio-stack">{props.children}</div>;
}

export function TwoColumn(props: PropsWithChildren) {
  return <div className="narrio-two-column">{props.children}</div>;
}

export function Field(props: {
  label: string;
  name: string;
  defaultValue?: string;
  placeholder?: string;
  type?: string;
}) {
  return (
    <label className="narrio-field">
      <span>{props.label}</span>
      <input
        className="narrio-input"
        type={props.type ?? "text"}
        name={props.name}
        defaultValue={props.defaultValue}
        placeholder={props.placeholder}
      />
    </label>
  );
}

export function TextAreaField(props: {
  label: string;
  name: string;
  defaultValue?: string;
  rows?: number;
  placeholder?: string;
}) {
  return (
    <label className="narrio-field">
      <span>{props.label}</span>
      <textarea
        className="narrio-textarea"
        name={props.name}
        defaultValue={props.defaultValue}
        placeholder={props.placeholder}
        rows={props.rows ?? 6}
      />
    </label>
  );
}

export function PrimaryButton(props: PropsWithChildren<{ type?: "button" | "submit"; name?: string; value?: string }>) {
  return (
    <button className="narrio-button" type={props.type ?? "submit"} name={props.name} value={props.value}>
      {props.children}
    </button>
  );
}

export function InlineMeta(props: PropsWithChildren) {
  return <div className="narrio-inline-meta">{props.children}</div>;
}

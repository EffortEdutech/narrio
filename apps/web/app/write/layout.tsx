import Link from "next/link";
import type { ReactNode } from "react";
import { requireUser } from "../../lib/auth";
import { signOutAction } from "../auth/actions";

export default async function WriteLayout(props: { children: ReactNode }) {
  const { user } = await requireUser();

  return (
    <div className="narrio-writer-layout">
      <div className="narrio-card">
        <div className="narrio-topbar" style={{ padding: 0 }}>
          <div>
            <div className="narrio-eyebrow">Writer Area</div>
            <strong>{user.email}</strong>
          </div>
          <div className="narrio-nav">
            <Link href="/write">Dashboard</Link>
            <Link href="/write/new">New story</Link>
            <form action={signOutAction}>
              <button type="submit">Sign out</button>
            </form>
          </div>
        </div>
      </div>
      {props.children}
    </div>
  );
}

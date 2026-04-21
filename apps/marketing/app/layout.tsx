import type { ReactNode } from "react";
import "./globals.css";

export const metadata = {
  title: "Narrio Marketing",
  description: "Narrio landing placeholder"
};

export default function RootLayout(props: { children: ReactNode }) {
  return (
    <html lang="en">
      <body>
        <div className="marketing-shell">{props.children}</div>
      </body>
    </html>
  );
}

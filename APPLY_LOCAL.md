# Apply Locally

From the extracted patch folder, run:

```powershell
.\apply_patch.ps1 -RepoRoot "C:\path\to\narrio"
```

Then test:

```powershell
cd "C:\path\to\narrio"
pnpm install
pnpm typecheck
pnpm build
pnpm dev
```

Manual check:

1. Open the web app.
2. Open any public story page.
3. Click **Explore timelines**.
4. Confirm `/story/[storyId]/timelines` renders.
5. Open a timeline.
6. Open a chapter.
7. Confirm **Back to timeline** and **Explore timelines** links work.

Recommended commit after local approval:

```powershell
git add .
git commit -m "feat: add sprint 5 timeline explorer"
git push
```

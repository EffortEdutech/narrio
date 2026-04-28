# Sprint 6.0 — Local Command Checklist

Run these from the repo root:

```powershell
cd "C:\Users\user\Documents\00 StoryBook\narrio"
```

## 1. Confirm Git status

```powershell
git status
```

Expected:

- You should see your local Sprint 5 changes if not committed yet.
- No unexpected generated files should be staged accidentally.

## 2. Install dependencies

```powershell
pnpm install
```

## 3. Typecheck all workspace packages

```powershell
pnpm typecheck
```

## 4. Build all apps/packages

```powershell
pnpm build
```

## 5. Run web app

```powershell
pnpm dev:web
```

Open:

```text
http://localhost:3900
```

## 6. Run marketing app in a second terminal

```powershell
pnpm dev:marketing
```

Open:

```text
http://localhost:3901
```

## 7. Optional lint placeholder

```powershell
pnpm lint
```

Note: current repo lint may still be a reserved placeholder depending on package setup.

## 8. Commit baseline after approval

```powershell
git add .
git commit -m "feat: complete sprint 5 forkcraft reader loop"
```

## 9. Create local tag

```powershell
git tag sprint-5-complete
```

## 10. Push manually only after you are satisfied

```powershell
git push
git push origin sprint-5-complete
```

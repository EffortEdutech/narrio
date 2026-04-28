Sprint 6 — Publishing & Public Discovery

Sprint 5 made the ForkCraft loop visible.

Sprint 6 should make Narrio feel like a real public platform where stories can be published, discovered, read, followed, and shared.



Recommended Sprint 6 breakdown

# Sprint 6.0 — Stabilization checkpoint

Before adding more features, we should freeze what works.

Checklist:

Run full manual test from onboarding → read → timeline → fork → waypoint → activity.
Fix any broken route.
Update README.
Commit current Sprint 5 baseline.
Tag it locally as Sprint 5 complete.

Suggested commit:

git add .
git commit -m "feat: complete sprint 5 forkcraft reader loop"



## Sprint 6.1 — Publish Control Center

This is the next patch I recommend.

Add writer controls for:

Publish story
Unpublish story
Set story visibility
Publish chapter
Unpublish chapter
Set timeline visibility

Why this matters:

Your library only becomes meaningful when writers can intentionally publish content.



## Sprint 6.2 — Public Story Page Polish

Improve reader experience:

Story cover area
Story synopsis
Author block
Follow button
Timeline list
Start reading button
Latest chapter shortcut



## Sprint 6.3 — Library Discovery

Upgrade /library from simple list into real discovery:

Search stories
Filter by status / genre later
Sort by newest
Show timeline count
Show chapter count
Show follower count if available



## Sprint 6.4 — Public Writer Profile

Improve:

/u/[userId]

Into a proper creator profile:

Display name
Bio
Public stories
Created timelines
Reader stats



## Sprint 6.5 — Launch Readiness

Final polish:

Demo seed content
Empty states
Error pages
Loading states
Basic mobile layout cleanup
README launch instructions

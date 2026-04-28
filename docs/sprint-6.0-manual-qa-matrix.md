# Sprint 6.0 — Manual QA Matrix

Use this as the main stabilization checklist.

## A. Public / marketing

| ID | Route | Test | Result | Notes |
| --- | --- | --- | --- | --- |
| MKT-01 | `http://localhost:3901` | Marketing page loads | ☐ Pass ☐ Fail | |
| MKT-02 | Marketing CTA | Start ForkCraft opens web app | ☐ Pass ☐ Fail | |
| MKT-03 | Marketing CTA | Explore stories opens library | ☐ Pass ☐ Fail | |
| MKT-04 | Mobile width | Layout stacks cleanly | ☐ Pass ☐ Fail | |

## B. Web app shell

| ID | Route | Test | Result | Notes |
| --- | --- | --- | --- | --- |
| WEB-01 | `/` | Homepage loads with Narrio branding | ☐ Pass ☐ Fail | |
| WEB-02 | `/onboarding` | First 60 seconds onboarding loads | ☐ Pass ☐ Fail | |
| WEB-03 | top nav | Library, Start Here, Activity, Story Studio links work | ☐ Pass ☐ Fail | |

## C. Authentication and writer area

| ID | Route | Test | Result | Notes |
| --- | --- | --- | --- | --- |
| AUTH-01 | `/write` | Logged-out user is protected/redirected | ☐ Pass ☐ Fail | |
| AUTH-02 | `/write` | Signed-in user can access Story Studio | ☐ Pass ☐ Fail | |
| WRITE-01 | `/write` | First-run checklist appears | ☐ Pass ☐ Fail | |
| WRITE-02 | `/write` | Existing stories are listed | ☐ Pass ☐ Fail | |

## D. Library / story reading

| ID | Route | Test | Result | Notes |
| --- | --- | --- | --- | --- |
| LIB-01 | `/library` | Public library loads | ☐ Pass ☐ Fail | |
| STORY-01 | `/story/[storyId]` | Story page loads | ☐ Pass ☐ Fail | |
| STORY-02 | story page | Start reading works | ☐ Pass ☐ Fail | |
| STORY-03 | story page | Explore timelines works | ☐ Pass ☐ Fail | |

## E. Timeline Explorer

| ID | Route | Test | Result | Notes |
| --- | --- | --- | --- | --- |
| TL-01 | `/story/[storyId]/timelines` | Timeline Explorer loads | ☐ Pass ☐ Fail | |
| TL-02 | timeline card | Open timeline works | ☐ Pass ☐ Fail | |
| TL-03 | timeline page | Open chapter works | ☐ Pass ☐ Fail | |
| TL-04 | chapter page | Back to timeline works | ☐ Pass ☐ Fail | |

## F. Fork from chapter

| ID | Route | Test | Result | Notes |
| --- | --- | --- | --- | --- |
| FORK-01 | chapter page | Fork from this chapter button appears | ☐ Pass ☐ Fail | |
| FORK-02 | `/story/[storyId]/chapter/[chapterId]/fork` | Fork page loads | ☐ Pass ☐ Fail | |
| FORK-03 | fork form | Private draft timeline is created | ☐ Pass ☐ Fail | |
| FORK-04 | redirect | User lands in Story Studio/editor | ☐ Pass ☐ Fail | |
| FORK-05 | timeline explorer | Creator can see private fork timeline | ☐ Pass ☐ Fail | |

## G. Waypoints / bookmarks

| ID | Route | Test | Result | Notes |
| --- | --- | --- | --- | --- |
| WP-01 | chapter page | Save waypoint panel appears | ☐ Pass ☐ Fail | |
| WP-02 | chapter page | Save Theory tag works | ☐ Pass ☐ Fail | |
| WP-03 | chapter page | Save Fork idea tag works | ☐ Pass ☐ Fail | |
| WP-04 | chapter page | Save custom tag works | ☐ Pass ☐ Fail | |
| WP-05 | `/write/bookmarks` | My waypoints page loads | ☐ Pass ☐ Fail | |
| WP-06 | waypoints | Tag filter works | ☐ Pass ☐ Fail | |
| WP-07 | waypoints | Remove waypoint works | ☐ Pass ☐ Fail | |

## H. Activity feed

| ID | Route | Test | Result | Notes |
| --- | --- | --- | --- | --- |
| ACT-01 | `/activity` | Activity page loads | ☐ Pass ☐ Fail | |
| ACT-02 | after waypoint | Activity feed shows waypoint | ☐ Pass ☐ Fail | |
| ACT-03 | after fork | Activity feed shows timeline/fork activity | ☐ Pass ☐ Fail | |
| ACT-04 | empty state | Empty activity state is readable | ☐ Pass ☐ Fail | |

## I. Visual QA

| ID | Area | Test | Result | Notes |
| --- | --- | --- | --- | --- |
| UI-01 | homepage | Hero feels like Narrio, not generic admin UI | ☐ Pass ☐ Fail | |
| UI-02 | onboarding | Cards and steps have strong hierarchy | ☐ Pass ☐ Fail | |
| UI-03 | reader | Chapter reading typography is comfortable | ☐ Pass ☐ Fail | |
| UI-04 | mobile | Main routes are usable at mobile width | ☐ Pass ☐ Fail | |

## Blocking criteria

A bug is blocking if it prevents:

```text
sign-in
opening library
opening a story
opening timelines
opening a chapter
creating a fork
saving/removing waypoint
loading activity
production build
```

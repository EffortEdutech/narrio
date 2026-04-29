# Narrio Demo Story and Universe Catalog

This seed creates **12 stories** and exactly **112 universe/timeline varieties** across those stories. In the current Narrio schema, a universe variety is represented as a `story_branches` row, because branches/timelines are the platform model for ForkCraft paths.

| # | Story | Level | Visibility | ForkCraft | Universe varieties |
|---:|---|---|---|---|---:|
| 1 | The River That Remembers | Level 1 · Starter Canon | `published/public` | enabled | 3 |
| 2 | Lanterns Over Seri Bay | Level 2 · Reader Choice Mystery | `published/public` | enabled | 5 |
| 3 | The Clockmaker's Orchard | Level 3 · Growing World | `published/public` | enabled | 6 |
| 4 | Orbit of the Last Musafir | Level 4 · Sci-Fi Pilgrimage | `published/public` | enabled | 7 |
| 5 | The Glass Masjid of Seven Moons | Level 5 · Reflective Epic | `published/public` | enabled | 8 |
| 6 | Neon Keris Protocol | Level 6 · Action ForkCraft | `published/public` | enabled | 9 |
| 7 | Ashes of the Paper Kingdom | Level 7 · Closed Canon Showcase | `published/public` | closed canon | 10 |
| 8 | The Child Who Borrowed Tomorrow | Level 8 · Private Draft Lab | `draft/private` | enabled | 11 |
| 9 | Bazaar at the Edge of Sleep | Level 9 · Dream Market | `published/public` | enabled | 12 |
| 10 | Atlas of Rain-Cities | Level 10 · Unlisted Worldbook | `published/unlisted` | enabled | 13 |
| 11 | The Thousand Door School | Level 11 · Community ForkCraft | `published/public` | enabled | 14 |
| 12 | Garden of the 112th Star | Level 12 · Flagship Multiverse | `published/public` | enabled | 14 |

Total universe/timeline varieties: **112**.

## What to test

- `/library` discovery with many public stories.
- `/story/[storyId]` public story page.
- `/story/[storyId]/timelines` with heavy timeline counts.
- `/write/publish/[storyId]` on published, unlisted, private, and draft stories.
- `/activity` with follows, likes, and bookmarks.
- `/u/[userId]` public writer profile.

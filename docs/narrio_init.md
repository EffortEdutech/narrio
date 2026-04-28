https://github.com/EffortEdutech/StoryBook This is our git repo The platform seems too complicated with visual branches. I am not sure where my helper is heading with this platform. I was thinking of github style branches . And branches inside branch... Bookmark by user like tags 
Ahh I see what’s happening 🙂
You’re feeling the architecture drifting into something over-engineered, especially the visual branching story graph idea.
Let’s slow down and realign the product direction before tech locks you into complexity.
________________________________________
First — What you’re sensing is correct
Your helper is moving toward a story graph engine (like Twine / AI RPG engine).
But your original vision was:
“Serious social publishing platform with fun AI toy”
Those are very different products.
You are accidentally heading toward building Notion + Twine + Git + AI 😅
Which is huge and risky for MVP.
We need to simplify the mental model.
________________________________________
The Core Question You’re Really Asking
You’re thinking:
Should StoryBook be like Git branches instead of a complex visual graph?
YES.
This is the right instinct 💯
Because Git mental model is:
•	simple 
•	powerful 
•	proven 
•	scalable 
•	collaborative 
And most importantly → text-first, not visual-first.
Your product should be writing-first.
________________________________________
The Big Pivot (Important)
We will kill the visual graph editor for MVP ❌
Replace it with:
👉 Git-style story branching
This is MUCH clearer product positioning.
________________________________________
New Mental Model (Lock This In)
StoryBook is:
GitHub + Medium + Wattpad + AI
for collaborative storytelling.
Not a node graph tool.
________________________________________
Story Structure — The Clean Model
Instead of nodes and graphs, we use:
Story
 └── Chapters
       └── Versions (branches)
Exactly like Git.
________________________________________
Example — How Story Branching Works
Main Story
The Last Dragon
├─ Chapter 1
├─ Chapter 2
└─ Chapter 3
A reader thinks:
"What if the dragon didn't die?"
They click Fork Story
Now we create a branch:
The Last Dragon (original)
The Last Dragon — Dragon Lives (fork)
This is EXACTLY like GitHub fork.
________________________________________
Branches Inside Branches (Yes — but simple)
Instead of scary graphs, we use a branch tree.
Main Story
 ├─ Branch: Romance Route
 │    └─ Branch: Sad Ending
 └─ Branch: Villain Wins
Tree. Not graph.
Humans understand trees.
________________________________________
Chapters behave like Git commits
Each chapter has versions.
Chapter 5
 ├─ v1 (original)
 ├─ v2 (edited)
 └─ v3 (AI rewrite)
Readers can:
•	view history 
•	compare versions 
•	revert 
This is insanely powerful but conceptually simple.
________________________________________
Replace "Visual Branching" With This UI
Instead of mindmap graph, we build:
Story Branch Explorer
Like GitHub branch selector:
🌳 Branch: main
    ├─ romance-route
    │    └─ sad-ending
    └─ villain-wins
Click branch → read story.
Done.
Simple. Elegant. Scalable.
________________________________________
Now your Bookmark Idea 🔖 (Very Good)
You said:
Bookmark by user like tags
YES — this is the missing reader UX dopamine.
We add:
Reader Tags / Bookmarks
Readers can tag any chapter or branch:
•	❤️ favorite 
•	😭 sad 
•	🔥 plot twist 
•	🌙 read later 
•	🧠 theory 
•	🧪 alt ending 
These are private OR public.
This creates:
•	engagement 
•	discovery 
•	recommendation engine later 
This is GOLD for retention.
________________________________________
Final Simplified Data Model
This is the clean MVP schema:
Core Tables
stories
•	id 
•	title 
•	author_id 
•	forked_from_story_id 
story_branches
•	id 
•	story_id 
•	parent_branch_id 
•	name (main / romance / villain etc) 
chapters
•	id 
•	branch_id 
•	chapter_number 
chapter_versions
•	id 
•	chapter_id 
•	content 
•	ai_generated (bool) 
bookmarks
•	user_id 
•	chapter_id 
•	tag 
That’s it.
No graph engine.
No node editor.
No visual nightmare.
________________________________________
Why This Direction Is MUCH Better
Easier to build
No canvas, no graph DB, no complex UI.
Easier to explain
"GitHub for stories" is instantly understood.
Easier to grow
Later you can add visual map as advanced feature.
Easier to monetize
Forks + AI rewrites = premium features.
________________________________________
MVP Scope After Simplification
Core features:
1.	Write chapter ✍️ 
2.	Fork story 🍴 
3.	Create branch 🌳 
4.	AI rewrite ✨ 
5.	Bookmark/tag 🔖 
6.	Follow stories 👀 
That’s a real product.
________________________________________
Honest Opinion
You just saved yourself 6–12 months of over-engineering.
Your intuition was right.
________________________________________
If you want, next we can redesign the repo architecture + DB schema + API based on this simplified direction.
Yes please redesign the repo architecture + DB schema + API based on this simplified direction. Bismillah... 
Bismillah 🤝
Now we lock the REAL production foundation of StoryBook based on the simplified Git-style branching model.
This will be practical, buildable, and scalable — not theoretical.
________________________________________
0️⃣ Architecture Philosophy (Important)
We optimise for:
• Solo / small team development
• Zero-cost MVP possible
• Scalable to millions later
• Monorepo simplicity
• Supabase-first backend
Stack:
Layer	Tech
Web app	Next.js (App Router)
Mobile later	Expo React Native
Backend	Supabase (Postgres + Auth + Storage)
AI	OpenAI API
Search	Postgres full-text (later Meilisearch)
Monorepo	pnpm + Turborepo
Hosting	Vercel
________________________________________
1️⃣ New Monorepo Structure
We keep it clean and future-proof.
storybook/
│
├─ apps/
│   ├─ web/                → Next.js main app
│   └─ marketing/          → landing page later
│
├─ packages/
│   ├─ ui/                 → shared components
│   ├─ db/                 → database types + queries
│   ├─ ai/                 → prompt engine
│   ├─ api/                → server actions / services
│   └─ config/             → eslint, tsconfig etc
│
├─ supabase/
│   ├─ migrations/
│   └─ seed.sql
│
└─ docs/
Why this is perfect:
•	No microservices yet ❌ 
•	No over-engineering ❌ 
•	Easy to split later ✔️ 
________________________________________
2️⃣ Database Schema (Production Ready)
This is the most important part.
We design like Git.
________________________________________
👤 users (Supabase auth extension)
Supabase gives auth.users.
We extend with profile table:
profiles
id (uuid PK, references auth.users)
username (unique)
avatar_url
bio
created_at
________________________________________
📚 stories
Root container.
stories
- id (uuid PK)
- title
- description
- author_id (uuid → profiles)
- forked_from_story_id (uuid nullable)
- created_at
- is_published (bool)
Forking a story = new row referencing parent.
________________________________________
🌳 story_branches
This replaces the scary graph system.
story_branches
- id (uuid PK)
- story_id (uuid → stories)
- name (main / romance / villain_wins)
- parent_branch_id (self reference)
- created_by
- created_at
Examples:
•	main 
•	dragon-lives 
•	sad-ending 
Branches form a tree.
________________________________________
📖 chapters
Each branch has ordered chapters.
chapters
- id (uuid PK)
- branch_id (uuid → story_branches)
- chapter_number (int)
- title
- created_at
Important:
Chapter is a slot.
Content lives in versions.
________________________________________
📝 chapter_versions
Like Git commits.
chapter_versions
- id (uuid PK)
- chapter_id (uuid → chapters)
- content (text)
- created_by (uuid → profiles)
- is_ai_generated (bool)
- commit_message
- created_at
We always load latest version.
History is preserved forever.
________________________________________
🔖 bookmarks (Reader Tags)
Your brilliant idea.
bookmarks
- id (uuid PK)
- user_id
- chapter_id
- tag (text)
- is_public (bool)
- created_at
Examples:
•	"favorite" 
•	"theory" 
•	"read_later" 
________________________________________
❤️ follows
follows
- user_id
- story_id
________________________________________
⭐ likes (for discovery later)
likes
- user_id
- chapter_version_id
________________________________________
3️⃣ Supabase Row Level Security (RLS)
Simple rules:
Public can read:
•	published stories 
•	branches 
•	chapters 
•	latest versions 
Only author can:
•	create branch 
•	write chapters 
•	edit versions 
Forked stories become new ownership.
This keeps security SIMPLE.
________________________________________
4️⃣ API Layer Design
We use Next.js Server Actions (no Express needed).
Folder:
packages/api/
We group by domain.
________________________________________
Story Service
createStory()
forkStory()
getStory()
listStories()
publishStory()
________________________________________
Branch Service
createBranch()
listBranches()
getBranchTree()
________________________________________
Chapter Service
createChapter()
getChapter()
listChapters()
________________________________________
Version Service
commitChapterVersion()
getVersionHistory()
getLatestChapterContent()
________________________________________
Bookmark Service
addBookmark()
removeBookmark()
listUserBookmarks()
________________________________________
5️⃣ Example API Flows
✍️ Create Story Flow
POST /stories
→ create story
→ create "main" branch automatically
________________________________________
🍴 Fork Story Flow
POST /stories/:id/fork

1. duplicate story
2. duplicate main branch
3. duplicate chapters
4. duplicate latest chapter versions
This is your Git fork.
________________________________________
🌳 Create Branch Flow
POST /branches

branch.parent_branch_id = current branch
________________________________________
📝 Commit Chapter Version Flow
POST /chapters/:id/commit

Insert new chapter_versions row.
Done.
Git commit mental model.
________________________________________
6️⃣ AI Package Structure
packages/ai/
│
├─ prompts/
│   ├─ rewrite.ts
│   ├─ continue.ts
│   ├─ summarize.ts
│   └─ title.ts
│
└─ openaiClient.ts
Functions:
rewriteChapter()
continueStory()
generateChapterTitle()
summarizeChapter()
AI is a helper, not core infra.
________________________________________
7️⃣ Web App Route Structure (Next.js)
app/
│
├─ (marketing)/
│
├─ (app)/
│   ├─ home/
│   ├─ library/
│   ├─ story/[storyId]/
│   │     ├─ page.tsx
│   │     ├─ branches/
│   │     └─ chapter/[chapterId]/
│   │
│   └─ write/
│         └─ editor/
________________________________________
8️⃣ MVP Screens Checklist
Must build first:
1️⃣ Home feed
2️⃣ Story page
3️⃣ Branch explorer 🌳
4️⃣ Chapter reader
5️⃣ Writing editor
6️⃣ Fork button 🍴
7️⃣ AI rewrite ✨
8️⃣ Bookmark/tag 🔖
That’s the MVP.
________________________________________
9️⃣ Why This Architecture Will Survive Scale
When you hit growth:
You can split:
•	API → microservice 
•	AI → worker queue 
•	Search → Meilisearch 
•	Realtime → Supabase channels 
But TODAY it stays simple.
________________________________________
Final Result
You now have a platform that is:
• GitHub-style collaboration
• Wattpad-style reading
• AI-assisted writing
• Simple to build
• Scalable to millions
________________________________________
Next step suggestion:
👉 Design the Branch Explorer UI + Writing Editor UX (very important dopamine part).
Design the Branch Explorer UI and Writing Editor UX
Perfect — this is the dopamine layer of the product ✨
If this feels right, the platform will feel magical.
We design 2 core screens:
1.	Branch Explorer 🌳 (reader + writer discovery) 
2.	Writing Editor ✍️ (creator flow) 
We optimise for:
•	clarity 
•	low friction 
•	addictive exploration 
________________________________________
PART 1 — 🌳 Branch Explorer UI
This replaces the scary graph editor.
Think: GitHub branch selector + Reddit comment tree + Wattpad reader
________________________________________
🎯 Purpose of Branch Explorer
User should instantly understand:
• Where am I in the story?
• What alternate paths exist?
• Where can I fork?
This screen is the heart of StoryBook.
________________________________________
Layout Overview
------------------------------------------------
 Story Header
------------------------------------------------
 Branch Selector (tree)
------------------------------------------------
 Chapter Timeline (horizontal)
------------------------------------------------
 Branch Activity / Stats
------------------------------------------------
________________________________________
1️⃣ Story Header
Top of page:
The Last Dragon
by @amina
Forked from @john

[ Follow ]  [ Fork Story 🍴 ]
Secondary info:
12 branches • 48 chapters • 3.2k followers
This builds credibility immediately.
________________________________________
2️⃣ Branch Tree Selector 🌳 (Hero Component)
This replaces visual graph.
Visual Example
🌳 Story Branches

main
├─ romance-route ❤️
│    └─ sad-ending 😭
└─ villain-wins 😈
Each branch is a clickable row card.
Branch Row UI
[🌿] romance-route
    by @sarah • 6 chapters • updated 2h ago
    ❤️ 1.2k  🍴 320 forks

    [ Read ] [ Continue Here ] [ Fork ]
Buttons meaning:
Button	Visible to	Action
Read	everyone	switch branch
Continue Here	owner	create chapter
Fork	everyone	fork branch
________________________________________
✨ UX Microinteraction
When switching branch:
•	Chapters timeline animates 
•	Header color subtly changes 
User feels they changed timeline.
________________________________________
3️⃣ Chapter Timeline (Horizontal)
This is extremely important dopamine.
Chapter Timeline (romance-route)

[1]—[2]—[3]—[4]—[5]—[6]
        ↑ You are here
Each chapter is a circle.
Tap = open reader.
Long press = open chapter menu:
•	bookmark 
•	view versions 
•	fork from here 
YES — users can fork from ANY chapter 😍
________________________________________
4️⃣ Fork From Chapter (Magic Feature)
When user clicks fork:
Fork from Chapter 4?

New branch name:
[ dragon-lives ]

[ Create Branch ]
Now branch starts from chapter 4 forward.
This is where platform becomes addictive.
________________________________________
5️⃣ Branch Activity Panel (Right Side Desktop)
Shows social proof:
🔥 Trending branches
💬 Recent comments
⭐ Most bookmarked chapters
For mobile → collapsible bottom sheet.
________________________________________
PART 2 — ✍️ Writing Editor UX
This must feel like:
Notion + Medium + Google Docs + AI copilot.
Goal:
Writing must feel fun, fast, powerful.
________________________________________
Editor Layout
-----------------------------------
Top Writing Bar
-----------------------------------
Chapter Title
-----------------------------------
Editor
-----------------------------------
AI Copilot Panel (toggle)
-----------------------------------
Commit Bar
________________________________________
1️⃣ Top Writing Bar
Writing in:
The Last Dragon / romance-route

Chapter 7
Right side:
[ Save Draft ]  [ Commit Version ]
We use commit language, not publish.
Writers feel like pros.
________________________________________
2️⃣ Title + Editor
Minimal distraction.
Typography like Medium.
Auto-save every 5 sec.
________________________________________
3️⃣ ✨ AI Copilot Panel
Toggle right sidebar.
This is dopamine machine.
Panel UI
✨ AI Copilot

Continue writing
Rewrite tone
Fix grammar
Make more dramatic
Summarise chapter
Generate title
Buttons trigger prompts.
________________________________________
4️⃣ AI Continue Flow
User clicks:
👉 Continue Writing
Popup:
Continue from cursor?
Style:
( ) same style
( ) more dramatic
( ) more romantic
( ) darker

[ Generate ]
AI writes continuation BELOW cursor.
User edits freely.
Feels magical.
________________________________________
5️⃣ AI Rewrite Selection
User highlights paragraph → floating toolbar appears:
Rewrite ✨  Shorten  Expand  Fix grammar
This is VERY addictive.
________________________________________
6️⃣ Commit Version Bar (Git Magic)
Bottom sticky bar:
Commit message:
[ Added dragon battle scene ]

[ Commit Version ]
After commit:
Version v12 saved ✔
Version history becomes visible in reader.
Writers feel safe to experiment.
________________________________________
7️⃣ Version History Drawer
Version History

v12 — now
v11 — AI rewrite
v10 — draft
v9 — original
Click → preview → revert.
Huge trust builder.
________________________________________
Dopamine Loop Created
Reader:
Read → Bookmark → Fork → Follow
Writer:
Write → AI help → Commit → Branch → Social proof
This creates daily usage habit.
________________________________________
MVP Screen List After Design
Reader:
•	Story page 
•	Branch explorer 
•	Chapter reader 
Writer:
•	Editor 
•	Version history 
•	Fork flow 
That’s your core product.
________________________________________
Next we should design the Supabase RLS policies + SQL migration file so you can start building immediately.
Please design the Supabase RLS policies + SQL migration file. Bismillah...
Bismillah 🤲
Now we write the actual Supabase SQL migration + Row Level Security policies so you can paste into /supabase/migrations/001_init.sql.
This is production-ready but still simple.
________________________________________
0️⃣ Enable Required Extensions
-- UUID generator
create extension if not exists "uuid-ossp";

-- Full text search later
create extension if not exists pg_trgm;
________________________________________
1️⃣ PROFILES (extends auth.users)
create table profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  username text unique not null,
  avatar_url text,
  bio text,
  created_at timestamptz default now()
);
Auto-create profile when user signs up:
create or replace function public.handle_new_user()
returns trigger as $$
begin
  insert into public.profiles (id, username)
  values (new.id, 'user_' || substr(new.id::text,1,8));
  return new;
end;
$$ language plpgsql security definer;

create trigger on_auth_user_created
after insert on auth.users
for each row execute procedure public.handle_new_user();
________________________________________
2️⃣ STORIES
create table stories (
  id uuid primary key default uuid_generate_v4(),
  title text not null,
  description text,
  author_id uuid references profiles(id) on delete cascade,
  forked_from_story_id uuid references stories(id),
  is_published boolean default false,
  created_at timestamptz default now()
);
________________________________________
3️⃣ STORY BRANCHES 🌳
create table story_branches (
  id uuid primary key default uuid_generate_v4(),
  story_id uuid references stories(id) on delete cascade,
  parent_branch_id uuid references story_branches(id),
  name text not null,
  created_by uuid references profiles(id),
  created_at timestamptz default now()
);
Create main branch automatically when story is created:
create or replace function create_main_branch()
returns trigger as $$
begin
  insert into story_branches (story_id, name, created_by)
  values (new.id, 'main', new.author_id);
  return new;
end;
$$ language plpgsql;

create trigger create_main_branch_trigger
after insert on stories
for each row execute procedure create_main_branch();
________________________________________
4️⃣ CHAPTERS
create table chapters (
  id uuid primary key default uuid_generate_v4(),
  branch_id uuid references story_branches(id) on delete cascade,
  chapter_number int not null,
  title text,
  created_at timestamptz default now()
);
________________________________________
5️⃣ CHAPTER VERSIONS (Git commits)
create table chapter_versions (
  id uuid primary key default uuid_generate_v4(),
  chapter_id uuid references chapters(id) on delete cascade,
  content text not null,
  created_by uuid references profiles(id),
  commit_message text,
  is_ai_generated boolean default false,
  created_at timestamptz default now()
);
________________________________________
6️⃣ BOOKMARKS 🔖
create table bookmarks (
  id uuid primary key default uuid_generate_v4(),
  user_id uuid references profiles(id) on delete cascade,
  chapter_id uuid references chapters(id) on delete cascade,
  tag text not null,
  is_public boolean default false,
  created_at timestamptz default now()
);
________________________________________
7️⃣ FOLLOWS ❤️
create table follows (
  user_id uuid references profiles(id) on delete cascade,
  story_id uuid references stories(id) on delete cascade,
  primary key (user_id, story_id)
);
________________________________________
8️⃣ LIKES ⭐
create table likes (
  user_id uuid references profiles(id) on delete cascade,
  chapter_version_id uuid references chapter_versions(id) on delete cascade,
  primary key (user_id, chapter_version_id)
);
________________________________________
🔐 NOW THE IMPORTANT PART — RLS
Enable RLS on ALL tables:
alter table profiles enable row level security;
alter table stories enable row level security;
alter table story_branches enable row level security;
alter table chapters enable row level security;
alter table chapter_versions enable row level security;
alter table bookmarks enable row level security;
alter table follows enable row level security;
alter table likes enable row level security;
________________________________________
9️⃣ PROFILES POLICIES
Users can read all profiles but edit only themselves.
create policy "Profiles are public"
on profiles for select using (true);

create policy "Users update own profile"
on profiles for update
using (auth.uid() = id);
________________________________________
🔟 STORIES POLICIES
Read stories
Public can read published stories only
create policy "Read published stories"
on stories for select
using (is_published = true or auth.uid() = author_id);
Create story
create policy "Create story"
on stories for insert
with check (auth.uid() = author_id);
Update story (owner only)
create policy "Update own story"
on stories for update
using (auth.uid() = author_id);
________________________________________
11️⃣ BRANCHES POLICIES
Anyone can read branches of published stories.
create policy "Read branches of published stories"
on story_branches for select
using (
  exists (
    select 1 from stories
    where stories.id = story_branches.story_id
    and (stories.is_published = true or stories.author_id = auth.uid())
  )
);
Create branch = authenticated users only.
create policy "Create branch"
on story_branches for insert
with check (auth.uid() = created_by);
________________________________________
12️⃣ CHAPTERS POLICIES
create policy "Read chapters"
on chapters for select
using (
  exists (
    select 1 from stories s
    join story_branches b on b.story_id = s.id
    where b.id = chapters.branch_id
    and (s.is_published = true or s.author_id = auth.uid())
  )
);
Create chapters = branch creator or story owner:
create policy "Create chapters"
on chapters for insert
with check (auth.uid() is not null);
(Simple for MVP)
________________________________________
13️⃣ CHAPTER VERSIONS POLICIES
Anyone can read.
create policy "Read chapter versions"
on chapter_versions for select using (true);
Authenticated users can commit:
create policy "Commit versions"
on chapter_versions for insert
with check (auth.uid() = created_by);
________________________________________
14️⃣ BOOKMARK POLICIES 🔖
Users manage their own bookmarks only.
create policy "Users read own bookmarks"
on bookmarks for select
using (auth.uid() = user_id);

create policy "Users insert own bookmarks"
on bookmarks for insert
with check (auth.uid() = user_id);

create policy "Users delete own bookmarks"
on bookmarks for delete
using (auth.uid() = user_id);
________________________________________
15️⃣ FOLLOW + LIKE POLICIES
create policy "Users manage follows"
on follows for all
using (auth.uid() = user_id)
with check (auth.uid() = user_id);

create policy "Users manage likes"
on likes for all
using (auth.uid() = user_id)
with check (auth.uid() = user_id);
________________________________________
🎉 DONE — You now have:
• Complete schema
• Git-style versioning
• Branch system
• Security rules
• Auto profile creation
• Auto main branch creation
You can now run:
supabase db push
________________________________________
Next best step:
👉 Generate TypeScript database types + API service functions so your Next.js app can start calling the DB safely.
Generate TypeScript database types and API service functions
Perfect — now we connect the Next.js app → Supabase DB safely with full TypeScript.
You will copy these into your monorepo:
packages/db/
packages/api/
We’ll generate:
1.	Supabase client 
2.	Database TypeScript types 
3.	Typed query helpers 
4.	Service layer (Story / Branch / Chapter / Version / Bookmark) 
This becomes your backend SDK.
________________________________________
1️⃣ Generate Supabase Types (real command)
After running migration locally:
supabase gen types typescript --local > packages/db/database.types.ts
This generates a huge file.
We will assume file name:
packages/db/database.types.ts
________________________________________
2️⃣ Supabase Client
📁 packages/db/client.ts
import { createBrowserClient } from "@supabase/ssr";
import { Database } from "./database.types";

export const createClient = () =>
  createBrowserClient<Database>(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!
  );
Server client:
📁 packages/db/server.ts
import { createServerClient } from "@supabase/ssr";
import { cookies } from "next/headers";
import { Database } from "./database.types";

export const createServerSupabase = () => {
  const cookieStore = cookies();

  return createServerClient<Database>(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!,
    {
      cookies: {
        get: (name) => cookieStore.get(name)?.value,
        set: (name, value, options) =>
          cookieStore.set({ name, value, ...options }),
        remove: (name, options) =>
          cookieStore.set({ name, value: "", ...options }),
      },
    }
  );
};
________________________________________
3️⃣ Shared DB Types (clean aliases)
📁 packages/db/types.ts
import { Database } from "./database.types";

export type Profile = Database["public"]["Tables"]["profiles"]["Row"];
export type Story = Database["public"]["Tables"]["stories"]["Row"];
export type Branch = Database["public"]["Tables"]["story_branches"]["Row"];
export type Chapter = Database["public"]["Tables"]["chapters"]["Row"];
export type ChapterVersion =
  Database["public"]["Tables"]["chapter_versions"]["Row"];
export type Bookmark = Database["public"]["Tables"]["bookmarks"]["Row"];
________________________________________
4️⃣ STORY SERVICE
📁 packages/api/story.service.ts
"use server";

import { createServerSupabase } from "@storybook/db/server";

export async function createStory(title: string, description?: string) {
  const supabase = createServerSupabase();

  const { data: user } = await supabase.auth.getUser();

  if (!user.user) throw new Error("Not authenticated");

  const { data, error } = await supabase
    .from("stories")
    .insert({
      title,
      description,
      author_id: user.user.id,
    })
    .select()
    .single();

  if (error) throw error;
  return data;
}

export async function forkStory(storyId: string) {
  const supabase = createServerSupabase();
  const { data: user } = await supabase.auth.getUser();

  const { data: original } = await supabase
    .from("stories")
    .select("*")
    .eq("id", storyId)
    .single();

  const { data, error } = await supabase
    .from("stories")
    .insert({
      title: original.title + " (Fork)",
      description: original.description,
      author_id: user.user!.id,
      forked_from_story_id: storyId,
    })
    .select()
    .single();

  if (error) throw error;
  return data;
}

export async function listStories() {
  const supabase = createServerSupabase();

  const { data, error } = await supabase
    .from("stories")
    .select("*")
    .eq("is_published", true)
    .order("created_at", { ascending: false });

  if (error) throw error;
  return data;
}
________________________________________
5️⃣ BRANCH SERVICE
📁 packages/api/branch.service.ts
"use server";

import { createServerSupabase } from "@storybook/db/server";

export async function createBranch(
  storyId: string,
  name: string,
  parentBranchId?: string
) {
  const supabase = createServerSupabase();
  const { data: user } = await supabase.auth.getUser();

  const { data, error } = await supabase
    .from("story_branches")
    .insert({
      story_id: storyId,
      name,
      parent_branch_id: parentBranchId ?? null,
      created_by: user.user!.id,
    })
    .select()
    .single();

  if (error) throw error;
  return data;
}

export async function listBranches(storyId: string) {
  const supabase = createServerSupabase();

  const { data, error } = await supabase
    .from("story_branches")
    .select("*")
    .eq("story_id", storyId);

  if (error) throw error;
  return data;
}
________________________________________
6️⃣ CHAPTER SERVICE
📁 packages/api/chapter.service.ts
"use server";

import { createServerSupabase } from "@storybook/db/server";

export async function createChapter(
  branchId: string,
  chapterNumber: number,
  title: string
) {
  const supabase = createServerSupabase();

  const { data, error } = await supabase
    .from("chapters")
    .insert({
      branch_id: branchId,
      chapter_number: chapterNumber,
      title,
    })
    .select()
    .single();

  if (error) throw error;
  return data;
}

export async function listChapters(branchId: string) {
  const supabase = createServerSupabase();

  const { data, error } = await supabase
    .from("chapters")
    .select("*")
    .eq("branch_id", branchId)
    .order("chapter_number");

  if (error) throw error;
  return data;
}
________________________________________
7️⃣ VERSION (COMMIT) SERVICE
📁 packages/api/version.service.ts
"use server";

import { createServerSupabase } from "@storybook/db/server";

export async function commitChapterVersion(
  chapterId: string,
  content: string,
  commitMessage: string,
  isAi = false
) {
  const supabase = createServerSupabase();
  const { data: user } = await supabase.auth.getUser();

  const { data, error } = await supabase
    .from("chapter_versions")
    .insert({
      chapter_id: chapterId,
      content,
      commit_message: commitMessage,
      created_by: user.user!.id,
      is_ai_generated: isAi,
    })
    .select()
    .single();

  if (error) throw error;
  return data;
}

export async function getLatestChapterContent(chapterId: string) {
  const supabase = createServerSupabase();

  const { data, error } = await supabase
    .from("chapter_versions")
    .select("*")
    .eq("chapter_id", chapterId)
    .order("created_at", { ascending: false })
    .limit(1)
    .single();

  if (error) throw error;
  return data;
}
________________________________________
8️⃣ BOOKMARK SERVICE 🔖
📁 packages/api/bookmark.service.ts
"use server";

import { createServerSupabase } from "@storybook/db/server";

export async function addBookmark(chapterId: string, tag: string) {
  const supabase = createServerSupabase();
  const { data: user } = await supabase.auth.getUser();

  const { error } = await supabase.from("bookmarks").insert({
    chapter_id: chapterId,
    tag,
    user_id: user.user!.id,
  });

  if (error) throw error;
}

export async function getMyBookmarks() {
  const supabase = createServerSupabase();
  const { data: user } = await supabase.auth.getUser();

  const { data, error } = await supabase
    .from("bookmarks")
    .select("*")
    .eq("user_id", user.user!.id);

  if (error) throw error;
  return data;
}
________________________________________
🎉 You Now Have
A fully typed backend SDK:
• Supabase client
• Generated DB types
• Server actions
• Git-style story services
• Safe TypeScript everywhere
Your Next.js app can now start building real pages immediately.
________________________________________
Next best step: build the Story Page + Branch Explorer React components.
build the Story Page + Branch Explorer React components. Bismillah...
Story Page + Branch Explorer· typescript
import { useEffect, useState } from "react";
import { Card, CardContent } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { motion } from "framer-motion";

// MOCK TYPES (replace with real API calls)
type Branch = {
id: string;
name: string;
created_by: string;
};

type Chapter = {
id: string;
chapter_number: number;
title: string;
};

// ------------------------------
// Story Page Wrapper
// ------------------------------
export default function StoryPage() {
const [branches, setBranches] = useState<Branch[]>([]);
const [selectedBranch, setSelectedBranch] = useState<Branch | null>(null);
const [chapters, setChapters] = useState<Chapter[]>([]);

useEffect(() => {
// TODO replace with real API
const mockBranches: Branch[] = [
{ id: "1", name: "main", created_by: "amina" },
{ id: "2", name: "romance-route", created_by: "sarah" },
{ id: "3", name: "villain-wins", created_by: "john" },
];
setBranches(mockBranches);
setSelectedBranch(mockBranches[0]);
I’ve created the Story Page + Branch Explorer React components in the canvas. You can now plug in your real API services to replace the mock data.
Suggest to me our apps name Storybook sound so dumb
Love the honesty 😂 — good call changing it early.
“StoryBook” sounds like a kids app, not a serious social writing platform.
Your product is actually:
•	branching stories 
•	forking timelines 
•	collaborative fiction 
•	git-style writing 
•	alternate universes 
So the name should feel creative + tech + multiverse.
Here are strong directions 👇
________________________________________
🌌 Direction 1 — Multiverse / Timeline vibe (BEST FIT)
These feel premium and unique.
Top picks ⭐
•	StoryVerse 
•	BranchVerse 
•	PlotVerse 
•	Narraverse 
•	LoreVerse 
•	ForkVerse 
•	CanonVerse 
•	MythVerse 
🔥 My fav from this group: StoryVerse or Narraverse
________________________________________
🌳 Direction 2 — Branch / Fork (Git-inspired)
This connects directly to your unique mechanic.
•	StoryFork 
•	PlotFork 
•	Branchly 
•	BranchLab 
•	ForkFiction 
•	Forked Tales 
•	Forked Stories 
•	StoryBranches 
•	BranchStories 
🔥 Strong picks: Branchly, StoryFork
________________________________________
✍️ Direction 3 — Writer / Creation vibe
More emotional + creator focused.
•	InkForge 
•	InkVerse 
•	PlotForge 
•	StoryForge 
•	LoreForge 
•	WriteVerse 
•	NarrativeHub 
•	PlotCraft 
•	InkBranch 
🔥 Strong picks: InkForge, PlotForge
________________________________________
🚀 Direction 4 — Modern SaaS style (short & brandable)
These feel like startups.
•	Storii 
•	Storia 
•	Plotto 
•	Narrio 
•	Fablr 
•	Taleon 
•	Talely 
•	Storly 
•	Plory 
🔥 Strong picks: Storia, Taleon
________________________________________
🏆 My FINAL recommendations (Top 5)
If I had to choose as a startup founder:
1.	StoryVerse → clear + powerful + scalable 
2.	InkForge → creative + premium + memorable 
3.	Branchly → perfectly matches core mechanic 
4.	PlotForge → very startup-y 
5.	Narraverse → unique + futuristic 
________________________________________
If you want, we can next check domain availability style names and pick the final brand direction (logo + tagline).
Fablr Narrio Plotto ForkCraft
Nice shortlist 👀 these all feel way more “startup” than StoryBook.
Let’s evaluate like a founder choosing a real brand.
________________________________________
Quick gut feel ranking
1️⃣ Narrio
2️⃣ ForkCraft
3️⃣ Fablr
4️⃣ Plotto
Now let’s break down why.
________________________________________
1️⃣ Narrio ⭐ (my strongest pick)
Vibe: modern SaaS + storytelling
Pronunciation: easy (na-ree-oh)
Memorability: high
Uniqueness: very high
Why it works:
•	Comes from narrative → perfect meaning 
•	Feels like Notion / Figma / Vercel style brand 
•	Works globally 
•	Works for app icon 
•	Easy domain hacks: narrio.app / narrio.ai 
Brand feel:
Narrio — Create stories that branch forever.
This is VERY fundable startup energy.
________________________________________
2️⃣ ForkCraft 🔥
Vibe: creative + Git-inspired
Memorability: very high
Clarity: explains the product instantly
Pros:
•	Directly communicates branching + creation 
•	Strong niche identity 
•	Perfect for early adopters / dev crowd 
Cons:
•	Slightly more “tool” than “social platform” 
•	Less emotional than Narrio 
Brand feel:
ForkCraft — Where stories fork into new worlds.
This one screams product clarity.
________________________________________
3️⃣ Fablr
From Fable.
Pros:
•	Short and clean 
•	Cute brand 
•	Easy logo 
Cons:
•	Sounds like a kids story app 
•	Doesn’t hint branching or tech 
•	Slightly generic startup name 
Brand feel:
Fablr — Share your stories.
Nice, but not unique enough for your concept.
________________________________________
4️⃣ Plotto
From Plot.
Pros:
•	Writing related 
•	Fun sound 
Cons:
•	Sounds like lotto / gambling 😅 
•	Already a famous book about plot writing (risk) 
•	Weak SaaS vibe 
This one is the weakest brand-wise.
________________________________________
🏆 My recommendation
If you want serious startup + long term brand:
👉 Narrio
If you want clever product-focused brand:
👉 ForkCraft
________________________________________
My honest founder advice
Pick Narrio as the company/platform name
Use ForkCraft as a feature name later.
Example:
•	Narrio platform 
•	“ForkCraft engine” 
•	“Fork this story” 
This is actually a PERFECT combo.
________________________________________
If this feels right, next step is tagline + brand positioning + logo direction.
Lock this Pick Narrio as the company/platform name Use ForkCraft as a feature name later. Example: Narrio platform “ForkCraft engine” “Fork this story” 
Locked in 🔒
Platform / company name: Narrio
Core feature name: ForkCraft
Usage going forward:
•	Narrio platform 
•	“Powered by the ForkCraft engine” 
•	“Fork this story” 
This is a very strong combo 👌
When you’re ready, we can design tagline + logo direction + brand voice.
design tagline + logo direction + brand voice. Bismillah
Bismillah ✨
Now we shape Narrio’s identity so everything feels consistent and premium.
________________________________________
🧭 Brand Positioning (foundation)
What Narrio is:
A social platform where stories branch, fork, and evolve forever.
Think:
•	GitHub × Wattpad × Multiverse 
Core idea:
Stories are no longer linear.
________________________________________
🏷️ Tagline Options
We need short + memorable + scalable.
Primary tagline (recommended)
“Where stories branch forever.”
This is PERFECT because:
•	Explains the product instantly 
•	Emotional + technical 
•	Works on landing page, App Store, pitch decks 
Lock this as main tagline ✅
________________________________________
Secondary tagline options (marketing)
Use in hero sections / ads.
•	“Every story has another path.” 
•	“Fork the story. Change the ending.” 
•	“Write the multiverse.” 
•	“Stories aren’t linear anymore.” 
•	“Powered by the ForkCraft engine.” 
________________________________________
🎨 Logo Direction
We design concept first (not the artwork yet).
Logo concept idea: The Branch Spark
Symbol must communicate:
•	branching 
•	creativity 
•	network 
•	growth 
Icon concept
A minimal branching node symbol:
Imagine:
   ●
  / \
 ●   ●
      \
       ●
But simplified into a clean geometric mark.
Meaning:
•	Nodes = story chapters 
•	Branches = alternate timelines 
•	Spark = creativity explosion 
This symbol can animate later 🔥
________________________________________
Logo style
Style keywords:
•	minimal 
•	geometric 
•	tech + creative hybrid 
•	friendly but premium 
•	Not childish 
Think logos like:
•	Notion 
•	Linear 
•	Vercel 
•	Figma 
________________________________________
Wordmark style
Narrio
•	Lowercase or Title case both work 
•	Rounded modern font 
•	Slightly playful curves 
Suggested font direction:
•	Inter 
•	Plus Jakarta Sans 
•	Sora 
•	Circular style 
Logo lockup idea:
[branch icon] Narrio
________________________________________
🎨 Brand Colors
We want creative + tech.
Primary color
Deep Indigo
#4F46E5
Represents imagination + creativity.
Secondary accent
Vibrant Purple
#8B5CF6
Represents branching multiverse.
Highlight accent
Soft Teal
#2DD4BF
Represents creativity spark.
Neutrals
•	Dark: #0F172A 
•	Light: #F8FAFC 
This palette looks amazing in dark mode 🔥
________________________________________
🗣️ Brand Voice
How Narrio talks.
Personality
Narrio is:
•	inspiring 
•	curious 
•	playful but smart 
•	creative + tech-savvy 
•	never corporate 
Tone mix:
40% creative writer
40% indie hacker
20% sci-fi multiverse
________________________________________
Voice examples
Homepage hero
Bad:
Publish your stories online.
Narrio voice:
Every story has another path.
Welcome to the storytelling multiverse.
________________________________________
Empty state
This branch has no chapters yet.
Be the first to change this timeline.
________________________________________
Fork button tooltip
Fork this story and write your own path.
________________________________________
Commit message placeholder
What changed in this timeline?
________________________________________
🧠 Brand Story (for About page)
Short version you can reuse everywhere:
Stories were never meant to be linear.
Narrio is a new kind of storytelling platform where every reader can become a writer, and every story can branch into infinite possibilities.
Powered by the ForkCraft engine, Narrio lets stories evolve like open-source projects — fork them, remix them, and create new timelines together.
________________________________________
🎉 You now have a full brand identity:
✅ Name
✅ Tagline
✅ Logo direction
✅ Colors
✅ Voice
✅ Brand story
Next natural step:
Landing page copy + homepage layout 😄
Both landing page & homepage layout
Bismillah 🤝
Now we design Narrio like a real, launch-ready product — not just a concept.
We’ll do:
1.	🌐 Landing Page (marketing → acquisition) 
2.	🏠 App Homepage (retention → engagement loop) 
These are TWO different machines.
________________________________________
🌐 1. LANDING PAGE (Narrio.com)
🎯 Goal:
Convert visitors into signups by making them feel:
“I want to create a branching story RIGHT NOW.”
________________________________________
🧭 LANDING PAGE STRUCTURE
[ Hero Section ]
[ Social Proof Strip ]
[ What is Narrio? ]
[ How ForkCraft Works ]
[ Feature Highlights ]
[ Example Story Preview ]
[ Creator + Reader Split CTA ]
[ Final CTA ]
[ Footer ]
________________________________________
🚀 HERO SECTION (MOST IMPORTANT)
Visual:
Animated branching story lines (subtle motion)
Copy:
Every story has another path.

Welcome to Narrio.
Where stories branch forever.
Subtext:
Write, fork, and explore infinite story timelines.
Powered by the ForkCraft engine.
CTA Buttons:
•	🚀 Start Writing 
•	📖 Explore Stories 
________________________________________
Micro animation idea:
A story node splits into 2 → then 4 → then infinite.
________________________________________
🌟 SOCIAL PROOF STRIP
10,000+ stories forked  
50,000+ alternate endings created  
∞ possible timelines
(early stage can be fake placeholders → replace later)
________________________________________
📖 WHAT IS NARRIO?
Simple explanation block:
Narrio is a storytelling platform where stories are not linear.

Every reader can:
• fork a story
• create alternate paths
• continue different timelines
________________________________________
🔧 HOW FORKCRAFT WORKS
(THIS is your differentiator)
1. Read a story
2. Fork any chapter
3. Create a new branch
4. Publish your timeline
Visual:
Git-style branch diagram animation
________________________________________
✨ FEATURE HIGHLIGHTS
Cards layout:
🌳 Branch Stories
Create alternate story paths
✍️ AI Writing Assistant
Continue or rewrite any chapter
🍴 Fork Anything
Turn reading into creation
🔖 Story Bookmarking
Save favorite moments & theories
________________________________________
📚 EXAMPLE STORY PREVIEW
This is VERY important for conversion.
Show:
The Last Dragon

main → romance-route → villain-wins
User can click and instantly feel system.
________________________________________
👥 CREATOR vs READER CTA SPLIT
Are you here to:

[ Write Stories ]   [ Explore Stories ]
Both go into same system but different onboarding.
________________________________________
🔥 FINAL CTA SECTION
Start your first timeline today.

Your story is waiting to branch.
Button:
👉 Get Started Free
________________________________________
🏠 2. HOMEPAGE (APP AFTER LOGIN)
🎯 Goal:
Retention + dopamine loop
User should immediately:
•	see stories 
•	see branches 
•	feel curiosity 
•	click something 
________________________________________
🧭 APP HOMEPAGE STRUCTURE
[ Top Nav ]
[ Continue Writing ]
[ Trending Stories ]
[ Branch Activity Feed ]
[ Your Stories ]
[ Recommended Forks ]
________________________________________
🧠 TOP NAV
Narrio 🌳     Search 🔍     Notifications 🔔     Profile
________________________________________
✍️ CONTINUE WRITING CARD (IMPORTANT)
This is your retention engine.
Continue Writing

The Last Dragon
Branch: romance-route
Chapter: 4

[ Continue ]  [ View Branch ]
Always show last active work.
________________________________________
🔥 TRENDING STORIES
Horizontal scroll cards:
🔥 Trending Now

The Last Dragon
Silent City
Dream Protocol
Moonfall Chronicles
Each card shows:
•	branches count 
•	forks count 
________________________________________
🌳 BRANCH ACTIVITY FEED (CORE LOOP)
This is your “social feed”.
@sarah forked "romance-route"
→ created "sad-ending"

@john continued Chapter 5 in villain-wins

@amina created new branch "true-ending"
This is your Twitter-style engagement layer.
________________________________________
📚 YOUR STORIES
My Stories

The Last Dragon
12 branches • 48 chapters

Silent City
3 branches • 10 chapters
________________________________________
🍴 RECOMMENDED FORKS
AI + algorithm section:
You may want to fork:

Dream Protocol
→ unexplored ending detected

Moonfall Chronicles
→ trending alternate timeline
________________________________________
🧲 HOMEPAGE HOOK (IMPORTANT INSIGHT)
Your product is NOT “read stories”.
It is:
“see what others did with the same story”
That is the addiction loop.
________________________________________
🎯 FINAL PRODUCT LOOP
Landing Page:
👉 “I want to create stories”
Homepage:
👉 “I want to fork everything I see”
________________________________________
🧠 ONE SENTENCE STRATEGY
Narrio is:
A social storytelling network where every story becomes a multiverse of forks.
________________________________________
If you want next step, I recommend:
👉 Onboarding flow (first 60 seconds experience)
This will decide your retention more than anything else.
Show me the onboarding flow (first 60 seconds experience)
Bismillah 🤝
This is the most important part of Narrio — because if onboarding fails, everything fails.
We design the first 60 seconds experience like a dopamine funnel.
Goal:
User must go from “curious visitor” → “I just forked a story” in under 1 minute.
________________________________________
🧠 Narrio Onboarding Philosophy
We do NOT ask:
•	“What are your interests?” 
•	“Create profile first” 
•	“Long tutorial” 
Instead:
🚀 We immediately drop users into a story universe and let them fork.
________________________________________
⚡ FIRST 60 SECONDS FLOW (Narrio)
0s   → Landing / App open
5s   → Choose identity mode
15s  → First story preview
25s  → Fork decision moment
40s  → AI assist (optional dopamine boost)
55s  → First published branch
60s  → Homepage feed unlocked
________________________________________
🚀 STEP 1 — ENTRY (0–5s)
User lands.
Screen:
Welcome to Narrio

Where stories branch forever
Two buttons ONLY:
•	✍️ I want to write 
•	📖 I want to explore 
BUT here’s the trick:
👉 Even “Explore” leads to writing later.
________________________________________
🎭 STEP 2 — IDENTITY MOMENT (5–15s)
We avoid full signup form.
Instead:
Choose your role for now:

🧑‍🎨 Creator
👀 Explorer
🤝 Both (recommended)
Default highlight: Both
No password yet.
We use “guest session”.
________________________________________
📚 STEP 3 — FIRST STORY DROP (15–25s)
Immediately show ONE trending story:
The Last Dragon

main branch

The kingdom feared the last dragon...
Buttons:
•	▶ Continue reading 
•	🌳 View branches 
•	🍴 Fork this story 

No scrolling. No confusion.

---

# 🔥 STEP 4 — FORK MOMENT (25–40s)

This is THE conversion moment.

User clicks:

👉 Fork this story

Popup:

```id="o4"
Fork this timeline?

Create your own version of:
"The Last Dragon"

New branch name:
[ my-dragon-story ]
Auto-suggest:
•	“what if dragon survived” 
•	“dragon becomes human” 
•	“evil dragon wins” 
User can accept suggestion instantly.
________________________________________
✨ STEP 5 — AI MAGIC BOOST (OPTIONAL 40–55s)
After fork creation:
Your story branch is created ✨

Want AI to help you continue?
Buttons:
•	⚡ Yes, continue for me 
•	✍️ I’ll write myself 
•	⏭ Skip 
If user clicks AI:
AI generates:
First paragraph of new branch chapter
Instant gratification.
________________________________________
📝 STEP 6 — FIRST COMMIT MOMENT (55–60s)
We make them feel like a “real creator”.
Your first chapter is ready.

[ Publish this timeline ]
Button:
👉 Publish Branch
OR auto-publish if they used AI.
________________________________________
🏠 STEP 7 — INSTANT REWARD (60s)
They land in homepage:
Welcome to Narrio 🌳

You just created your first timeline
Now they see:
•	Their branch 
•	Trending forks 
•	Other stories branching 
AND MOST IMPORTANT:
👉 “Your branch is now part of the multiverse”
________________________________________
🧲 PSYCHOLOGY ENGINE (WHY THIS WORKS)
We hit 4 dopamine triggers:
1. Curiosity
“What happens in this story?”
2. Ownership
“I forked this”
3. Creativity
“I created a branch”
4. Social presence
“My branch exists in a multiverse”
________________________________________
🔁 CORE LOOP AFTER ONBOARDING
After 60 seconds:
User returns to:
•	See who forked their branch 
•	Continue writing 
•	Explore other branches 
•	Fork again 
This becomes habit.
________________________________________
💡 KEY DESIGN INSIGHT
Narrio onboarding is NOT:
“Sign up to use app”
It is:
“You already created something — now continue”
________________________________________
🏁 FINAL SUMMARY
First 60 seconds =
1.	No friction entry 
2.	Immediate story exposure 
3.	Fork action 
4.	AI assist optional boost 
5.	Instant creation win 
6.	Homepage immersion 
________________________________________
If you want next step, I recommend:
👉 Gamification system (XP, ranks, branch popularity, viral loops)
That’s what will make Narrio addictive long-term.
Yes please 👉 Gamification system Bismillah...
Bismillah 🤝
Now we build the growth engine of Narrio — this is what turns it from “nice product” into a sticky storytelling universe people return to daily.
We design gamification carefully so it:
•	rewards creativity (not spam) 
•	encourages branching (ForkCraft core) 
•	builds social proof loops 
•	avoids “cheap game mechanics” 
________________________________________
🧠 Narrio Gamification Philosophy
We do NOT gamify:
•	likes farming 
•	meaningless streaks 
•	shallow engagement 
We DO gamify:
creativity, branching, storytelling influence, and narrative impact
________________________________________
⚡ CORE GAMIFICATION SYSTEM
We build 5 layers:
1. XP System (Creator Growth)
2. Branch Influence Score (Story impact)
3. Fork Economy (virality engine)
4. Narrative Rank System (status)
5. Achievement Badges (milestones)
________________________________________
1️⃣ XP SYSTEM (CREATOR PROGRESSION)
🎯 Goal:
Reward writing + branching + engagement
________________________________________
XP Actions
Write chapter              +10 XP
Publish branch            +25 XP
Get forked                +50 XP
Someone continues story   +30 XP
AI-assisted publish       +5 XP (lower reward to encourage human writing)
Bookmark from others      +5 XP
________________________________________
🔥 Important Rule
XP is NOT for reading
Only creation matters.
________________________________________
LEVEL SYSTEM
Level 1  → Reader
Level 5  → Writer
Level 10 → Storyteller
Level 20 → World Builder
Level 50 → Narrative Architect
Level 100 → Myth Creator
________________________________________
UX DISPLAY
Profile shows:
Narrio Rank: World Builder 🌳
XP: 2,450
Branches created: 12
Forks received: 89
________________________________________
2️⃣ 🌳 BRANCH INFLUENCE SCORE
This is your UNIQUE VIRAL METRIC.
Each branch has “gravity”.
________________________________________
Formula:
Branch Influence =
(forks × 3) +
(continuations × 5) +
(bookmarks × 2) +
(unique readers)
________________________________________
Why this matters:
A branch is NOT equal content.
Some branches become:
•	canon timeline 
•	fan universes 
•	viral forks 
________________________________________
UI:
🔥 romance-route
Influence Score: 8,240
Forks: 320
Continuations: 45
________________________________________
3️⃣ 🍴 FORK ECONOMY (VIRAL ENGINE)
This is the HEART of Narrio.
Every fork creates a new timeline asset.
________________________________________
Fork Types
Normal Fork       → standard branch
Canon Fork        → official continuation
Chaos Fork        → experimental timeline
AI Fork           → AI-generated branch
Community Fork    → group-created branch
________________________________________
VIRAL LOOP
Read → Fork → Branch grows → Gets forked again → Becomes universe
________________________________________
BONUS SYSTEM
When your story is forked:
+ visibility boost
+ recommendation push
+ profile XP boost
________________________________________
4️⃣ 🏆 NARRATIVE RANK SYSTEM
This is your “status layer”.
Not fake points — real influence.
________________________________________
Ranks:
🟢 Reader
🟡 Contributor
🔵 Story Weaver
🟣 World Shaper
🟠 Canon Architect
🔴 Myth Creator
⚫ Narrative God
________________________________________
Unlock Conditions:
World Shaper:
- 10+ branches created
- 50+ forks received

Canon Architect:
- 1 branch becomes “canonical path”

Myth Creator:
- 1000+ forks across stories
________________________________________
WHY THIS WORKS
Users don’t want XP.
They want:
identity in the story universe
________________________________________
5️⃣ 🏅 ACHIEVEMENT BADGES
These create dopamine spikes.
________________________________________
Examples:
🍴 First Fork
→ fork any story

🌳 Branch Creator
→ create your first branch

🔥 Viral Writer
→ 100 forks on one branch

🧠 Multiverse Thinker
→ 5+ alternate endings

👑 Canon Breaker
→ forked a “main canon” story

⚡ AI Collaborator
→ used AI in writing
________________________________________
UI Style
Badges appear:
•	glowing icons 
•	animated unlock 
•	shareable cards 
________________________________________
🔁 VIRAL LOOP DESIGN (IMPORTANT)
Narrio’s growth loop:
Write → Fork → Others fork → Branch spreads → You gain rank → More visibility → More forks
This is self-amplifying network effect
________________________________________
📊 HOME FEED GAMIFICATION
Feed is ranked by:
Branch Influence Score
Recent forks
Trending continuations
AI boost events
________________________________________
🔥 SPECIAL MECHANIC: “TIMELINE LEGACY”
Each branch has:
Legacy Score = total descendants across forks
Meaning:
Your story lives forever through forks
________________________________________
🧠 KEY DESIGN INSIGHT
We are NOT building:
❌ social media app
❌ writing tool
❌ blogging platform
We ARE building:
🌌 “A living universe of branching narratives”
________________________________________
🎯 FINAL GAMIFICATION SUMMARY
Narrio rewards:
Action	Reward
Writing	XP
Forking	Virality
Being forked	Status
Branch growth	Influence
Story evolution	Rank
________________________________________
🚀 NEXT STEP (HIGH IMPACT)
If you want to continue building momentum:
👉 Design Narrio Recommendation Engine (how stories go viral + AI feed ranking)
That’s what will make Narrio feel “alive”.
Design Narrio Recommendation Engine (how stories go viral + AI feed ranking)
Bismillah 🤝
Now we build the brain of Narrio — the system that decides:
what story appears to who, and why it goes viral.
This is not a simple feed. It is a multiverse recommendation engine built around branches, forks, and narrative evolution.
________________________________________
🧠 Narrio Recommendation Engine Philosophy
We do NOT rank:
•	likes 
•	followers 
•	generic engagement 
We DO rank:
narrative momentum + branching activity + curiosity loops
________________________________________
⚙️ CORE SYSTEM OVERVIEW
Narrio Feed Engine =

1. Story Graph Engine (Fork network)
2. Branch Momentum Score
3. User Taste Model (embedding-based)
4. Exploration vs Familiarity balance
5. AI Virality Booster
________________________________________
🌳 1. STORY GRAPH ENGINE (FORK NETWORK)
Every story is a tree of branches.
We treat it like a graph:
Story
 ├── Branch A
 │     ├── Fork A1
 │     └── Fork A2
 └── Branch B
       └── Fork B1
Each node has:
•	forks received 
•	continuations 
•	divergence depth 
•	recency 
________________________________________
KEY INSIGHT
Viral stories are NOT linear stories
Viral stories are branching explosions
________________________________________
🔥 2. BRANCH MOMENTUM SCORE (CORE RANKING SIGNAL)
Each branch gets a dynamic score:
Momentum Score =

(Recent Forks × 3)
+ (New Chapters × 2)
+ (Unique Users Engaged × 2)
+ (Cross-branch activity × 4)
- (Decay over time)
________________________________________
⚡ TIME DECAY MODEL
Old content fades unless revived:
score = score × e^(-time_decay)
BUT:
If someone forks an old branch → it revives 🔥
________________________________________
💡 RESULT
Old stories can become viral again if reactivated
This creates “zombie virality”
________________________________________
🧠 3. USER TASTE MODEL (AI PERSONALIZATION)
Each user has a Narrio embedding profile.
We track:
User Interest Vector:
- genres (romance, sci-fi, fantasy)
- tone preference (dark, hopeful, chaotic)
- branching behavior (linear reader vs fork-heavy user)
- AI usage preference
________________________________________
USER TYPES
📖 Reader Type:
- consumes stories
- low fork activity

🌳 Branch Explorer:
- likes alternate timelines
- high fork rate

✍️ Creator:
- writes frequently
- builds branches

🧠 Chaos Architect:
- creates experimental forks
- AI-heavy usage
________________________________________
🔄 4. FEED MIX STRATEGY (VERY IMPORTANT)
Feed is NOT only personalized.
We balance 3 streams:
60% Personalized Feed
25% Trending Global Forks
15% Exploration / Random Universe Injection
________________________________________
WHY THIS MATTERS
If fully personalized:
→ user gets trapped in same genres
If fully trending:
→ becomes generic social media
So we mix:
comfort + discovery + chaos
________________________________________
🚀 5. VIRALITY BOOST SYSTEM (AI LAYER)
This is your secret growth weapon.
AI detects:
- high emotional chapter
- cliffhangers
- controversial forks
- rapidly growing branches
Then boosts them:
+ push to explore feed
+ recommend to similar users
+ show in “Fork Now” section
________________________________________
VIRAL TRIGGERS
A story becomes viral when:
✔ multiple forks in short time
✔ branching depth increases quickly
✔ users fork from forks (deep chain reaction)
✔ emotional spike detected (AI NLP)
________________________________________
🌌 6. “MULTIVERSE EXPANSION” FEATURE
This is unique to Narrio.
When a branch gets forked many times:
System labels it as:

🌌 “Expanding Timeline”
Then:
•	shows in homepage banner 
•	appears in discovery feed 
•	triggers “explore this universe” mode 
________________________________________
🧲 7. FEED TYPES IN NARRIO
We design 5 feed modes:
________________________________________
🏠 Home Feed
- your followed stories
- your active branches
- continue writing prompts
________________________________________
🔥 Trending Fork Feed
- fastest growing branches
- viral forks
- chaotic story explosions
________________________________________
🌌 Explore Multiverse Feed
- random branches
- unknown stories
- discovery-based AI picks
________________________________________
🧠 AI Recommended Feed
- based on embedding similarity
- tone matching
- writing behavior matching
________________________________________
🧬 “What If” Feed
- AI-generated alternate branches
- suggestions like:
  "What if the hero betrayed everyone?"
________________________________________
📊 FINAL RANKING FORMULA (SIMPLIFIED)
Each story shown in feed:
Final Score =

(Branch Momentum × 0.4)
+ (User Interest Match × 0.3)
+ (Global Trending × 0.2)
+ (AI Virality Boost × 0.1)
________________________________________
🔁 CORE VIRAL LOOP
This is the engine of growth:
User reads story
→ sees fork option
→ forks branch
→ creates new timeline
→ system promotes fork
→ others fork it again
→ explosion of branches
________________________________________
🧠 KEY DESIGN INSIGHT
Narrio is NOT:
❌ content feed
❌ social media
❌ blog platform
Narrio IS:
🌌 A self-evolving storytelling universe powered by forks
________________________________________
🎯 FINAL OUTPUT OF THIS SYSTEM
If done correctly:
•	stories behave like living organisms 
•	forks behave like reproduction 
•	users behave like universe builders 
________________________________________
🚀 NEXT STEP (OPTIONAL BUT POWERFUL)
If you want to go deeper:
👉 Design Narrio Search Engine (how users explore infinite story universes like Google for fiction)
Design Narrio Search Engine (how users explore infinite story universes like Google for fiction)
Bismillah 🤝
Now we design one of the most powerful systems in Narrio:
🌌 Narrio Search Engine — “Google for branching fiction universes”
This is NOT normal search.
This is:
•	search across stories + branches + timelines + forks 
•	exploration of alternate realities 
•	discovery of narrative universes 
________________________________________
🧠 Core Philosophy
Traditional search:
“Find the best result”
Narrio search:
“Find the most interesting worlds you could enter”
So we rank:
•	curiosity 
•	divergence 
•	narrative potential 
•	fork activity 
•	emotional hooks 
Not just keywords.
________________________________________
⚙️ SYSTEM OVERVIEW
Narrio Search Engine =

1. Semantic Story Index (AI embeddings)
2. Branch Graph Search (fork tree traversal)
3. Narrative Intent Detection
4. Universe Clustering
5. Exploration Ranking System
________________________________________
🧬 1. SEMANTIC STORY INDEX (AI VECTOR SEARCH)
Every object is embedded:
- Story
- Branch
- Chapter
- Chapter Version
Each has vector:
embedding = OpenAI(text + metadata)
________________________________________
Example indexed text:
"The dragon betrayed the kingdom and chose exile"
Also includes metadata:
•	genre: fantasy 
•	tone: dark 
•	branching_count: high 
•	virality_score: medium 
________________________________________
🌳 2. BRANCH GRAPH SEARCH (KEY DIFFERENCE)
Unlike Google:
We search tree structures
Story
 ├── main
 │    ├── fork A
 │    ├── fork B
 │    └── fork C
Search can start at:
•	root story 
•	branch 
•	or deep chapter node 
________________________________________
Query example:
“betrayal ending dragon”
Returns:
•	main story (weak match) 
•	branch: villain-wins (strong match) 
•	fork: dragon exile timeline (viral match) 
________________________________________
🧠 3. NARRATIVE INTENT DETECTION
We classify user intent BEFORE search.
Intent types:

1. 📖 Explore story
2. 🌳 Find alternate endings
3. 🔥 Find viral stories
4. ✍️ Continue writing idea
5. 🧬 Find similar universes
________________________________________
Example:
Query:
“what if hero betrayed kingdom”
System detects:
👉 “alternate timeline intent”
So we prioritize:
•	forks 
•	branches 
•	“what if” expansions 
________________________________________
🌌 4. UNIVERSE CLUSTERING (VERY IMPORTANT)
We group stories into narrative universes
Universe examples:

🌌 Dragon Saga Universe
🌌 Post-Apocalyptic Earth
🌌 AI Rebellion Timeline
Each universe contains:
•	multiple stories 
•	forks across authors 
•	shared themes 
________________________________________
Why this matters:
User doesn’t search “story”
User searches:
“I want to enter a universe”
________________________________________
🔥 5. EXPLORATION RANKING SYSTEM
Search results are NOT static ranking.
We score each result:
Final Search Score =

(semantic match × 0.35)
+ (branch divergence × 0.25)
+ (fork popularity × 0.20)
+ (emotional intensity × 0.15)
+ (recency × 0.05)
________________________________________
KEY INSIGHT
A result becomes higher ranked if:
•	it has MANY alternate paths 
•	it has been forked deeply 
•	it creates curiosity loops 
________________________________________
⚡ “WHAT IF” ENGINE (SEARCH MAGIC FEATURE)
This is Narrio’s killer feature.
User types:
“what if dragon survived”
System:
→ finds closest matching branch
→ generates alternate forks
→ shows AI-generated continuations
________________________________________
UI OUTPUT:
Results:

🔥 Dragon Exile Timeline
🌳 Fork: Dragon Lives Ending
🧬 AI Suggested: “Dragon becomes human ruler”
________________________________________
🧲 SEARCH RESULT TYPES
Narrio does NOT return only “links”.
It returns narrative entry points:
________________________________________
📚 Story Card
•	title 
•	universe 
•	fork count 
•	influence score 
________________________________________
🌳 Branch Entry
•	specific alternate timeline 
•	“start reading here” 
________________________________________
✍️ Chapter Entry
•	jump directly into moment in story 
________________________________________
🧬 AI Generated Fork
•	speculative continuation 
•	“what if” expansion 
________________________________________
🧭 SEARCH UI DESIGN
Search bar:
🔍 Search universes, stories, or what-if scenarios...
________________________________________
Tabs:
[Stories] [Branches] [Universes] [What If] [AI Ideas]
________________________________________
Result Card Example:
🌌 Dragon Saga Universe

Most active timeline:
“Dragon Exile Ending”

🔥 320 forks
🌳 12 active branches
🧠 AI expansion available

[ Enter Universe ]
________________________________________
🧠 AI SEARCH ASSISTANT (BIG FEATURE)
On right side:
Narrio AI:

“Do you want darker endings or heroic ones?”
“Here are 3 alternate universes you might like”
________________________________________
🔁 SEARCH → CREATION LOOP (VERY IMPORTANT)
Search is NOT end point.
It leads to creation:
Search → Discover branch → Fork → Create new timeline → Re-indexed
So every search:
grows the platform
________________________________________
🌌 VIRAL SEARCH EFFECT
If many users search same idea:
“dragon betrayal ending”
System detects trend:
→ boosts related branches
→ creates AI-generated forks
→ shows in trending search
________________________________________
🧬 FINAL SYSTEM SUMMARY
Narrio Search Engine is:
Layer	Function
Semantic Search	find meaning
Graph Search	explore forks
Intent Detection	understand user goal
Universe Clustering	group stories
Exploration Ranking	rank by curiosity
AI Expansion	generate new paths
________________________________________
🧠 ONE-LINE DEFINITION
Narrio Search Engine lets users explore infinite branching story universes instead of static results.
________________________________________
🚀 FINAL INSIGHT
This system turns Narrio into:
🌌 “A living, searchable multiverse of stories”
________________________________________
If you want next step:
👉 Design Narrio Data Architecture for scale (vector DB + graph DB + caching strategy)
Design Narrio Data Architecture for scale (vector DB + graph DB + caching strategy)
Bismillah 🤝
Now we move from “startup design” → real scalable system architecture.
This is where Narrio becomes something that can survive:
•	viral spikes 
•	millions of forks 
•	AI-heavy workloads 
•	graph explosion (branches everywhere) 
We design 3 core systems:
1. Postgres (Source of Truth)
2. Graph Layer (Story + Fork Network)
3. Vector DB (Semantic + AI search)
4. Cache Layer (Speed + cost control)
________________________________________
🧠 0. ARCHITECTURE PHILOSOPHY
Narrio is NOT one database.
It is:
📚 Structured reality (Postgres)
🌳 Relationship universe (Graph)
🧬 Meaning space (Vectors)
⚡ Fast memory (Cache)
________________________________________
🏗️ HIGH LEVEL SYSTEM
                ┌──────────────┐
                │   Frontend   │
                └──────┬───────┘
                       │
              ┌────────▼────────┐
              │  API Layer (Next)│
              └──────┬───────────┘
     ┌───────────────┼────────────────┐
     │               │                │
┌────▼─────┐   ┌────▼──────┐   ┌─────▼─────┐
│ Postgres │   │ Vector DB │   │ Cache (Redis)│
│ (Supabase)│   │ (pgvector)│   │            │
└────┬─────┘   └────┬──────┘   └─────┬─────┘
     │               │                │
     └───────┬───────┴───────┬──────┘
             │               │
       ┌────▼─────┐   ┌────▼─────┐
       │ Graph DB │   │ AI Worker │
       │ (Neo4j)  │   │ Queue     │
       └──────────┘   └──────────┘
________________________________________
🧱 1. POSTGRES (SOURCE OF TRUTH)
👉 Supabase Postgres
This stores ALL structured data.
________________________________________
Core Tables
stories
story_branches
chapters
chapter_versions
users
forks
bookmarks
________________________________________
Why Postgres stays central:
•	transactional safety 
•	RLS security 
•	author ownership 
•	version history 
________________________________________
Important Rule
❌ Never store AI or search logic here
✔ Only structured truth
________________________________________
🌳 2. GRAPH DB (FORK NETWORK ENGINE)
We use Neo4j (or RedisGraph for MVP)
________________________________________
WHY GRAPH DB?
Because Narrio is:
a constantly branching tree of stories
SQL becomes slow for deep traversal like:
•	“show all descendant forks” 
•	“find most branched story line” 
•	“trace viral chain” 
________________________________________
GRAPH MODEL
(:Story)-[:HAS_BRANCH]->(:Branch)
(:Branch)-[:FORKED_TO]->(:Branch)
(:Branch)-[:HAS_CHAPTER]->(:Chapter)
(:Chapter)-[:NEXT]->(:Chapter)
________________________________________
EXAMPLE RELATIONSHIP
Story A
  └── main branch
        ├── romance fork
        │      └── sad ending fork
        └── villain wins fork
________________________________________
GRAPH QUERIES
1. Find viral branch tree
MATCH (b:Branch)-[:FORKED_TO*]->(child)
RETURN b, count(child) as forks
ORDER BY forks DESC
________________________________________
2. Get story universe
MATCH (s:Story)-[:HAS_BRANCH]->(b)
RETURN b
________________________________________
🧬 3. VECTOR DB (MEANING + AI SEARCH)
We use:
👉 pgvector (MVP)
👉 Pinecone / Weaviate (scale)
________________________________________
WHAT WE STORE
Every narrative unit:
Story embedding
Branch embedding
Chapter embedding
Chapter version embedding
________________________________________
EMBEDDING CONTENT
"The dragon betrayed the kingdom and escaped into exile"
•	metadata: 
•	tone: dark 
•	genre: fantasy 
•	branch depth: 3 
•	virality: high 
________________________________________
USE CASES
1. Semantic search
“dragon betrayal ending”
2. Similar universes
“stories like this”
3. What-if generation
AI branch expansion
________________________________________
VECTOR QUERY
SELECT *
FROM chapter_embeddings
ORDER BY embedding <-> query_embedding
LIMIT 10;
________________________________________
⚡ 4. CACHE LAYER (REDIS)
This is CRITICAL for scale.
We cache EVERYTHING hot:
________________________________________
CACHE KEYS
story:{id}
branch:{id}
feed:user:{id}
trending:branches
search:query:{text}
________________________________________
WHY CACHE?
Because Narrio has:
•	heavy feed traffic 
•	viral spikes (fork storms) 
•	repeated search queries 
•	AI-heavy recommendations 
________________________________________
CACHE STRATEGY
1. Hot Feed Cache
TTL: 30–60 seconds
Used for homepage.
________________________________________
2. Trending Branch Cache
TTL: 10–30 seconds
Updated frequently.
________________________________________
3. Search Cache
TTL: 5–10 minutes
Speeds up repeated queries.
________________________________________
🔁 DATA FLOW (IMPORTANT)
Example: user opens story
1. API checks Redis cache
2. If miss → fetch Postgres
3. Fetch graph relationships (Neo4j)
4. Fetch embeddings (vector DB)
5. Combine result
6. Cache response
________________________________________
Example: user forks story
1. Write to Postgres (new branch)
2. Create graph relationship (FORKED_TO)
3. Generate embedding (AI worker)
4. Update cache invalidation
5. Trigger feed re-ranking
________________________________________
🧠 AI WORKER SYSTEM
We isolate AI into queue:
- generate embeddings
- suggest forks
- detect virality
- create “what if” branches
Tech:
•	BullMQ / Redis queue 
•	or Cloud Tasks 
________________________________________
🔥 SCALABILITY STRATEGY
Phase 1 (MVP)
•	Postgres (Supabase only) 
•	pgvector 
•	simple Redis cache 
________________________________________
Phase 2 (Growth)
•	Add Neo4j 
•	Dedicated feed service 
•	AI worker queue 
________________________________________
Phase 3 (Scale)
•	Sharded Postgres 
•	Distributed Redis 
•	Multi-region vector DB 
________________________________________
🌌 KEY INSIGHT
Narrio is NOT:
❌ a database app
❌ a social feed
❌ a writing tool
Narrio is:
🌳 A living graph of stories
🧬 a semantic universe of meaning
⚡ a real-time viral system
________________________________________
📊 FINAL ARCHITECTURE SUMMARY
Layer	Tech	Purpose
Postgres	Supabase	Truth + structure
Graph DB	Neo4j	Story relationships
Vector DB	pgvector/Pinecone	Meaning search
Cache	Redis	speed + scale
Queue	BullMQ	AI processing
________________________________________
🚀 NEXT STEP (VERY IMPORTANT)
If you want to complete the system:
👉 Design Narrio Real-Time System (live forks, notifications, and collaboration engine)
That’s what makes Narrio feel alive.
Design Narrio Real-Time System with live forks, notifications, and collaboration engine
Bismillah 🤝
Now we design the heartbeat system of Narrio — the part that makes it feel alive in real time.
This is your:
🌌 Live storytelling engine (forks happening, people writing together, notifications flowing instantly)
We design 3 systems:
1. Live Fork System (real-time story evolution)
2. Notification Engine (event-driven brain)
3. Collaboration Engine (multi-writer + AI co-writing)
________________________________________
⚡ 1. LIVE FORK SYSTEM (REAL-TIME STORY UNIVERSE)
🧠 Core Idea
When someone forks a story:
it should instantly appear across the platform like a “timeline ripple”
Not refresh-based.
________________________________________
SYSTEM ARCHITECTURE
User Action → WebSocket Event → Server → Graph Update → Feed Broadcast → UI Update
Tech:
•	Supabase Realtime OR WebSockets (Socket.io / WS) 
•	Redis PubSub (scaling layer) 
________________________________________
🔁 FORK EVENT FLOW
When user clicks “Fork”
1. Insert new branch (Postgres)
2. Create graph edge (Neo4j)
3. Emit event: "fork.created"
4. Broadcast to:
   - followers
   - story watchers
   - global trending engine
________________________________________
🌳 LIVE UI BEHAVIOR
When fork happens:
•	branch appears instantly in Branch Explorer 
•	“🔥 New Fork just created” toast appears 
•	feed updates without refresh 
Example:
🌳 romance-route just forked by @sarah
→ “sad-ending” created 2s ago
________________________________________
⚡ VIRAL RIPPLE EFFECT
If fork goes viral:
Fork → Fork → Fork → Fork
System triggers:
•	live heatmap increase 
•	trending boost 
•	AI recommendation injection 
________________________________________
🔔 2. NOTIFICATION ENGINE (EVENT BRAIN)
This is NOT email spam.
This is story-awareness system.
________________________________________
EVENT-DRIVEN MODEL
Everything emits events:
story.created
branch.created
chapter.published
fork.created
chapter.commented
branch.trending
________________________________________
NOTIFICATION PIPELINE
Event → Event Bus → Filter Engine → Personalization → Delivery
________________________________________
FILTER ENGINE RULES
User receives notification ONLY if:
•	they follow story 
•	they forked related branch 
•	they interacted with chapter 
•	AI predicts interest match 
________________________________________
NOTIFICATION TYPES
1. Social notifications
@sarah forked your story
________________________________________
2. Story evolution notifications
Your branch "romance-route" just got 5 new forks
________________________________________
3. Viral alerts
🔥 Your story entered Trending Universe
________________________________________
4. AI recommendations
You may want to fork: "Dragon Exile Ending"
________________________________________
DELIVERY CHANNELS
•	in-app realtime (primary) 
•	push notification (mobile) 
•	email digest (optional later) 
________________________________________
🧑‍🤝‍🧑 3. COLLABORATION ENGINE (MULTI-CREATOR SYSTEM)
This is where Narrio becomes DIFFERENT from Wattpad.
________________________________________
🧠 CORE IDEA
Stories are NOT single-author.
They are:
living collaborative timelines
________________________________________
MODES OF COLLABORATION
1. Solo Writing (default)
2. Fork Collaboration
3. Branch Co-writing
4. AI + Human co-authoring
________________________________________
✍️ MODE 1: SOLO WRITING
Normal writing:
•	user owns branch 
•	commits versions 
•	can fork anytime 
________________________________________
🌳 MODE 2: FORK COLLABORATION
Someone forks your branch → collaboration begins.
Example:
Original: @amina writes "dragon dies"
Fork: @sarah writes "dragon survives"
Now both branches evolve separately.
________________________________________
🤝 MODE 3: BRANCH CO-WRITING (POWER FEATURE)
Multiple users write SAME branch.
________________________________________
HOW IT WORKS
Branch: romance-route
Collaborators:
- @amina
- @sarah
- @john
Rules:
•	chapter locking OR live editing window 
•	commit-based system (Git style) 
________________________________________
CONFLICT RESOLUTION
We use Git-style merging:
If conflict:
→ show diff view
→ choose version
→ or AI merge suggestion
________________________________________
✨ MODE 4: AI + HUMAN COLLABORATION
AI becomes “ghost writer”.
________________________________________
AI ROLES
- Continue story
- Suggest forks
- Rewrite tone
- Fill missing chapters
________________________________________
LIVE AI CO-WRITING FLOW
User types:
“the dragon enters the castle…”
AI responds instantly:
“but the gates were already burning…”
This happens in real-time typing stream.
________________________________________
⚡ REAL-TIME DATA FLOW
FULL SYSTEM LOOP
User types → WebSocket → AI engine (optional) → DB commit → Graph update → Redis pubsub → all clients update
________________________________________
🔥 LIVE FEED SYSTEM (IMPORTANT)
Narrio feed becomes:
a live storytelling stream
________________________________________
FEED EVENTS
@sarah is writing Chapter 6...
@john forked "villain-wins"
🔥 romance-route is trending
🧠 AI generated new branch suggestion
________________________________________
🧬 SYSTEM ARCHITECTURE SUMMARY
Postgres → truth (stories)
Neo4j → relationships (forks)
Redis → real-time pubsub
WebSockets → live UI sync
Event Bus → notifications
AI Worker → suggestions + co-writing
________________________________________
🌌 KEY DESIGN INSIGHT
Narrio is NOT:
❌ static writing platform
❌ social feed app
❌ blog system
Narrio is:
🌌 a living storytelling organism that evolves in real time
________________________________________
🚀 FINAL RESULT
If done correctly:
•	writing feels alive 
•	stories evolve while you watch 
•	forks appear instantly 
•	collaboration feels like Git + Google Docs + Multiverse 
________________________________________
🔥 NEXT STEP (FINAL SYSTEM DESIGN LAYER)
If you want to complete Narrio end-to-end:
👉 Design Narrio AI Core Brain (how AI understands stories, predicts forks, and generates universes)
Design Narrio AI Core Brain (how AI understands stories, predicts forks, and generates universes)
Bismillah 🤝
Now we design the true intelligence layer of Narrio — the part that makes it feel like a living multiverse, not just a platform.
This is:
🧠 Narrio AI Core Brain
(understanding stories, predicting forks, and generating universes)
________________________________________
🌌 0. CORE IDEA
Narrio AI is NOT a chatbot.
It is a Narrative Physics Engine.
It understands:
•	stories as systems 
•	characters as state machines 
•	branches as probability paths 
•	forks as “decision divergences” 
________________________________________
🧠 HIGH LEVEL ARCHITECTURE
                ┌─────────────────────┐
                │  User Story Input   │
                └─────────┬───────────┘
                          │
            ┌─────────────▼─────────────┐
            │  Narrative Understanding   │
            │   (Story State Model)      │
            └───────┬─────────┬─────────┘
                    │         │
     ┌──────────────▼─┐   ┌──▼────────────┐
     │ Fork Predictor  │   │ Universe Gen  │
     └──────────────┬─┘   └──┬────────────┘
                    │         │
            ┌───────▼─────────▼───────┐
            │  Recommendation Brain    │
            └──────────┬──────────────┘
                       │
               ┌───────▼────────┐
               │  Feed Engine    │
               └─────────────────┘
________________________________________
🧠 1. NARRATIVE UNDERSTANDING ENGINE
This is the “brain that reads stories”.
________________________________________
📖 HOW AI SEES A STORY
Instead of text, AI converts story into:
Story State Graph:

Characters:
- Hero: conflicted, loyal
- Dragon: dying, powerful
- King: paranoid

Events:
- betrayal attempt
- exile decision
- war beginning

Emotional state:
- tension ↑
- hope ↓
- uncertainty ↑
________________________________________
🧬 STORY IS A STATE MACHINE
Each chapter updates state:
Chapter 1 → stable kingdom
Chapter 2 → betrayal introduced
Chapter 3 → conflict state activated
________________________________________
KEY INSIGHT
AI does NOT “read story”
AI simulates story evolution
________________________________________
🌳 2. FORK PREDICTION ENGINE (CORE VIRAL SYSTEM)
This is your SECRET GROWTH ENGINE.
________________________________________
🧠 IDEA
AI predicts:
“Where will users fork this story next?”
________________________________________
HOW IT WORKS
AI analyzes:
- emotional tension spikes
- unresolved conflicts
- character contradictions
- moral dilemmas
- narrative gaps
________________________________________
OUTPUT
Fork Probability Map:

🔥 72% → Dragon survives ending
🔥 54% → Hero betrayal arc
🔥 41% → Evil king redemption
🔥 38% → Time rewind timeline
________________________________________
UI USAGE
Narrio can show:
“Popular alternate timelines emerging…”
This drives virality.
________________________________________
🌌 3. UNIVERSAL GENERATION ENGINE
This is where Narrio becomes infinite.
________________________________________
🧠 IDEA
AI generates:
•	new branches 
•	new universes 
•	new story continuations 
BUT NOT RANDOM.
It follows structure of existing story graph.
________________________________________
GENERATION TYPES
1. Continuation Generation
2. Fork Generation
3. Universe Expansion
4. Chaos Injection
5. Canon Stabilization
________________________________________
✍️ 1. CONTINUATION GENERATION
“What happens next?”
AI continues current branch.
________________________________________
🌳 2. FORK GENERATION (MOST IMPORTANT)
AI creates divergence:
Original:
"The dragon dies"

Generated forks:
- Dragon survives secretly
- Dragon reincarnates
- Dragon was never real
________________________________________
🌌 3. UNIVERSE EXPANSION
AI creates ENTIRE sub-worlds:
Dragon Saga Universe:
- Dragon Kingdom
- Human Resistance
- Ancient Prophecy Layer
________________________________________
⚡ 4. CHAOS INJECTION
Used for virality spikes.
AI introduces:
•	betrayal twist 
•	unexpected character shift 
•	timeline collapse 
This increases engagement.
________________________________________
🧭 5. CANON STABILIZATION
When story becomes too chaotic:
AI suggests:
“This branch is becoming unstable. Should we define canon?”
________________________________________
🧠 4. RECOMMENDATION BRAIN (AI CORE LOOP)
This connects everything:
________________________________________
INPUT SIGNALS
- user reading behavior
- fork patterns
- emotional preferences
- time spent per branch
- writing style
________________________________________
OUTPUT
- recommended branches
- “what-if” prompts
- AI-generated forks
- trending universes
________________________________________
EXAMPLE
User likes dark betrayal stories:
AI suggests:
“What if the hero betrays the kingdom instead?”
________________________________________
🔁 5. SELF-LEARNING LOOP (IMPORTANT)
Narrio AI improves from usage:
User forks → AI learns preference
User writes → AI updates model
Story goes viral → AI strengthens pattern
________________________________________
RESULT
AI becomes:
personalized narrative engine per user
________________________________________
🧬 6. STORY EMBEDDING MODEL (KEY INFRA)
Each story is stored as:
Embedding =

[characters + emotions + events + tone + branching structure]
Not just text.
________________________________________
VECTOR SPACE MAP
romance ←────────→ tragedy
linear  ←────────→ chaotic forks
simple  ←────────→ multiverse complexity
________________________________________
🔥 7. VIRALITY PREDICTION MODEL
AI predicts:
- will this branch go viral?
- how many forks likely?
- emotional peak probability
- replay value score
________________________________________
VIRAL SCORE FORMULA
Virality Score =
(emotion spike × 0.4)
+ (fork potential × 0.3)
+ (conflict intensity × 0.2)
+ (novelty × 0.1)
________________________________________
🌌 FINAL SYSTEM SUMMARY
Narrio AI Brain consists of:
Module	Function
Narrative Engine	understands story state
Fork Predictor	predicts user branching
Universe Generator	creates new timelines
Recommendation Brain	feeds users content
Virality Model	predicts explosion
Embedding Model	stores story meaning
________________________________________
🧠 ONE-LINE DEFINITION
Narrio AI is a narrative physics engine that simulates, predicts, and generates infinite branching story universes.
________________________________________
🚀 FINAL RESULT
With this system:
•	stories behave like living systems 
•	forks become predictable phenomena 
•	universes evolve automatically 
•	AI becomes co-author of everything 
________________________________________
🔥 IF YOU WANT NEXT LEVEL
We can now go into:
👉 Narrio Monetization System (how creators earn from forks + AI-generated universes + licensing story branches)
Narrio Monetization System Bismillah ... 
Bismillah 🤝
Now we design the economic engine of Narrio — how creators earn, how the platform sustains itself, and how value flows through forks, branches, and universes.
This is NOT just “ads or subscriptions”.
This is:
🌌 A branching story economy (Fork Economy)
________________________________________
🧠 0. CORE MONETIZATION PHILOSOPHY
Narrio monetizes:
❌ not posts
❌ not followers
❌ not views
✔ story influence + forks + universe growth
So money flows where creativity spreads.
________________________________________
⚙️ HIGH LEVEL ECONOMY SYSTEM
Narrio Economy =

1. Fork Revenue System (core)
2. Creator Royalty System
3. Universe Monetization (IP layer)
4. AI Credits System
5. Premium Discovery Boosts
6. Licensing & Syndication
________________________________________
🍴 1. FORK REVENUE SYSTEM (CORE ENGINE)
🧠 Idea
Every fork creates value.
So we track:
“who originated influence?”
________________________________________
FLOW OF VALUE
Original Story → Fork → Fork of Fork → Viral Spread
Each level contributes revenue back to origin.
________________________________________
REVENUE SPLIT MODEL
If a fork generates engagement:

70% → Fork creator  
20% → Original branch owner  
10% → Narrio platform
________________________________________
WHY THIS IS POWERFUL
•	encourages branching 
•	rewards creativity 
•	keeps original authors motivated 
________________________________________
💰 2. CREATOR ROYALTY SYSTEM
Creators earn from:
📊 Engagement Pool
Revenue Pool =
subscriptions + AI credits + boosts
Distributed based on:
- branch influence score
- fork depth
- reader engagement time
- story virality
________________________________________
EXAMPLE
Branch A:
- 10,000 forks
- 50,000 reads
→ earns $120

Branch B:
- 2,000 forks
→ earns $18
________________________________________
🌌 3. UNIVERSE MONETIZATION (BIG MONEY LAYER)
This is where Narrio becomes IP platform like Marvel + GitHub + Wattpad
________________________________________
🧠 IDEA
When stories evolve into large universes:
they become monetizable IP ecosystems
________________________________________
UNIVERSE EXAMPLE
🌌 Dragon Saga Universe
- 120 branches
- 5,000 forks
- 20 writers
________________________________________
MONETIZATION OPTIONS
1. Premium Universe Access
2. Paid Canon Episodes
3. Fan Fork Marketplace
4. Licensing to studios
________________________________________
FAN FORK MARKETPLACE
Users can:
•	buy/sell popular forks 
•	license branches 
•	co-own story universes 
________________________________________
🤖 4. AI CREDITS SYSTEM (USAGE ECONOMY)
AI is expensive → so we build credit system.
________________________________________
USERS SPEND CREDITS ON:
- AI story continuation
- fork generation
- rewrite suggestions
- universe expansion
________________________________________
CREDIT FLOW
Free tier → limited AI
Pro users → monthly credits
Power users → pay-per-use
________________________________________
WHY THIS WORKS
AI becomes:
creative amplifier, not free commodity
________________________________________
🚀 5. PREMIUM DISCOVERY BOOSTS
Creators can pay to:
- boost branch visibility
- appear in explore feed
- promote forks
________________________________________
BUT IMPORTANT RULE
We avoid “spam ads” feel:
Boosted content still ranked by:
quality × engagement × relevance
________________________________________
🧲 6. SUBSCRIPTION TIERS
Free Tier:
- read stories
- limited forks
- basic writing

Creator Tier ($5–10):
- AI writing tools
- analytics
- more forks

Pro Creator ($15–25):
- monetization enabled
- revenue sharing
- advanced AI universe tools
________________________________________
📊 7. REVENUE DISTRIBUTION MODEL
Narrio platform earns from:
- subscription fees
- AI credits
- promotion boosts
- IP licensing fees
________________________________________
PLATFORM CUT
Platform takes 10–20%
Everything else goes to creators
________________________________________
🧠 8. VIRAL VALUE LOOP (MOST IMPORTANT)
This is the engine:
More forks → more branches → more readers → more AI usage → more revenue → more creators → more forks
________________________________________
🌌 9. STORY AS DIGITAL ASSET (BIG SHIFT)
Each story becomes:
✔ trackable asset
✔ monetizable IP
✔ forkable structure
✔ revenue-generating tree
________________________________________
THINK LIKE THIS:
Not:
“I wrote a story”
BUT:
“I own a branching universe that generates revenue”
________________________________________
🔥 10. MARKETPLACE LAYER (FUTURE SCALE)
Eventually:
Creators can:
- sell universes
- license branches
- collaborate for profit
- auction canon rights
________________________________________
🧠 FINAL SYSTEM SUMMARY
Narrio monetization =
Layer	Value
Fork Economy	viral rewards
Creator Royalties	passive income
Universe IP System	long-term value
AI Credits	usage monetization
Boost System	visibility monetization
Subscription	stability revenue
________________________________________
🌌 ONE-LINE DEFINITION
Narrio is a branching story economy where creativity becomes a monetizable multiverse.
________________________________________
🚀 FINAL INSIGHT
This system ensures:
•	creators earn from virality 
•	platform scales sustainably 
•	AI usage is funded 
•	stories become IP assets 
________________________________________
🔥 NEXT STEP (FINAL SYSTEM LAYER)
If you want to complete Narrio end-to-end:
👉 Design Narrio Governance System (canon control, community moderation, story ownership disputes, and AI ethics rules)
Design Narrio Governance System including canon control, community moderation, story ownership disputes, and AI ethics rules
Bismillah 🤝
Now we design the rule of law for Narrio — the system that keeps a living multiverse from turning into chaos.
This is:
⚖️ Narrio Governance System
(canon control, moderation, ownership, AI ethics)
Think of it as:
•	GitHub + Wikipedia + creative universe law + AI safety layer 
________________________________________
🧠 0. GOVERNANCE PHILOSOPHY
Narrio is NOT fully open chaos.
Narrio is:
🌌 “A structured multiverse where creativity is free, but consequences are governed.”
Core principles:
1. Fork freedom (anyone can branch)
2. Canon stability (some truths must exist)
3. Creator ownership (rights matter)
4. Community correction (crowds fix narratives)
5. AI bounded creativity (safe generation)
________________________________________
⚖️ SYSTEM OVERVIEW
Narrio Governance System =

1. Canon Control System
2. Community Moderation Layer
3. Story Ownership & Dispute Resolution
4. AI Ethics & Boundaries Engine
5. Reputation System (trust layer)
________________________________________
📜 1. CANON CONTROL SYSTEM
🧠 Core Idea
Not all branches are equal.
We define:
🌳 CANON = “official narrative spine of a universe”
________________________________________
CANON TYPES
1. Primary Canon (original timeline)
2. Community Canon (voted stable branch)
3. AI Canon (AI stabilized version)
4. Split Canon (multiple accepted truths)
________________________________________
HOW CANON IS SELECTED
METHOD 1: COMMUNITY VOTE
If branch gets:
- high engagement
- low contradiction
- sustained forks

→ community votes it as canon
________________________________________
METHOD 2: VIRAL STABILITY RULE
AI detects:
- consistent forks alignment
- repeated continuation patterns
- low contradiction divergence
→ auto-suggest canonization
________________________________________
CANON MARKING UI
🌟 CANON BRANCH
“Accepted timeline of this universe”
________________________________________
IMPORTANT RULE
Canon does NOT delete other branches
It only marks:
✔ “official path”
✔ others remain alternate realities
________________________________________
🛡️ 2. COMMUNITY MODERATION LAYER
🧠 Core Idea
Moderation is NOT censorship.
It is:
“keeping narrative integrity + safety + quality”
________________________________________
MODERATION TYPES
1. Content Safety Moderation
2. Narrative Quality Moderation
3. Spam/Fork Farming Detection
4. Abuse Detection
________________________________________
SAFETY FILTERS
AI + rules block:
•	hate content 
•	harassment 
•	explicit illegal content 
•	impersonation abuse 
________________________________________
NARRATIVE QUALITY MODERATION
Detects:
•	nonsense forks 
•	spam branches 
•	low-effort AI spam 
________________________________________
SPAM CONTROL (IMPORTANT)
If user forks too fast:
→ rate limit
→ reduce visibility
→ require cooldown
________________________________________
⚔️ 3. STORY OWNERSHIP & DISPUTES
This is critical for trust.
________________________________________
🧠 CORE IDEA
Every story has:
- original creator
- fork lineage
- contribution graph
________________________________________
OWNERSHIP MODEL
Original Story Owner:
→ owns root IP

Fork Creator:
→ owns new branch IP

Shared branches:
→ co-owned
________________________________________
DISPUTE TYPES
1. Plagiarism Claim
“I created this idea first”
Resolution:
•	AI similarity check 
•	timeline analysis 
•	contribution proof 
________________________________________
2. Fork Theft Claim
“My branch was copied without credit”
Resolution:
•	graph lineage verification 
•	merge suggestion 
•	attribution correction 
________________________________________
3. Canon Dispute
Which branch is canon?
Resolution:
•	community vote 
•	AI recommendation 
•	creator override (limited power) 
________________________________________
DISPUTE FLOW
User submits claim
→ AI pre-analysis
→ community review panel
→ final decision system
________________________________________
🧠 4. AI ETHICS & BOUNDARIES ENGINE
This is the MOST IMPORTANT safety layer.
________________________________________
🧠 CORE IDEA
AI must be:
creative but bounded
powerful but controlled
inspiring but safe
________________________________________
AI RULES
1. No harmful content generation
2. No impersonation of real people
3. No rewriting protected canon without permission
4. No forced narrative manipulation
5. Respect user ownership of branches
________________________________________
AI LIMITS IN STORY GENERATION
AI can:
✔ suggest forks
✔ continue stories
✔ generate alternate universes
AI cannot:
❌ override canon without consent
❌ rewrite user-owned content silently
❌ generate unsafe narrative directions
________________________________________
AI TRANSPARENCY RULE
Every AI-generated text is labeled:
🤖 AI-assisted branch
________________________________________
🧬 5. REPUTATION SYSTEM (TRUST LAYER)
This is what keeps governance stable.
________________________________________
USER TRUST SCORE
Trust Score =

+ quality writing
+ community approval
+ safe behavior
- spam behavior
- violations
________________________________________
TRUST LEVELS
🟢 Trusted Creator
🟡 Standard Creator
🟠 New Creator
🔴 Restricted User
________________________________________
EFFECTS
Higher trust:
✔ more visibility
✔ higher monetization
✔ faster publishing
Low trust:
❌ rate limits
❌ reduced reach
❌ moderation review required
________________________________________
🧭 6. COMMUNITY GOVERNANCE (WIKIPEDIA-STYLE)
Advanced layer:
users help govern narrative universes
________________________________________
ROLES
🧑‍⚖️ Editors → review canon suggestions
🧠 Curators → manage universe structure
🔍 Moderators → handle disputes
🌌 Architects → high trust creators
________________________________________
VOTING SYSTEM
Used for:
•	canon selection 
•	dispute resolution 
•	quality ranking 
________________________________________
🔁 FULL GOVERNANCE LOOP
User writes → AI assists → community interacts → moderation filters → canon evolves → trust updates
________________________________________
🌌 KEY DESIGN INSIGHT
Narrio governance is NOT:
❌ centralized control
❌ full chaos freedom
❌ strict censorship
Narrio is:
⚖️ a self-balancing storytelling civilization
________________________________________
🧠 ONE-LINE DEFINITION
Narrio Governance is a multi-layer system that balances creative freedom, canon stability, ownership rights, and AI safety in a branching narrative universe.
________________________________________
🚀 FINAL RESULT
With this system:
•	stories remain safe 
•	creativity stays open 
•	canon remains stable 
•	AI stays aligned 
•	users trust the ecosystem 
________________________________________
🔥 IF YOU WANT FINAL STEP
We can now complete Narrio with:
👉 Full end-to-end system diagram (product → AI → graph → monetization → governance unified architecture)
Show me the full end-to-end system diagram (product → AI → graph → monetization → governance unified architecture)
Bismillah.
This is the full unified architecture of Narrio — the “big picture” of everything we designed so far, stitched into one system from user click → AI brain → data → monetization → governance.
Think of this as your founder system blueprint.
________________________________________
🌌 Narrio End-to-End System Architecture
Users → App → APIs → Real-Time → AI Brain → Databases → Ranking → Monetization → Governance
We’ll walk layer by layer from the outside inward.
________________________________________
1️⃣ Client Layer (Product Surface)
These are the actual apps users touch.
Apps
•	Web App (Next.js) 
•	Mobile PWA 
•	Admin Console 
•	Creator Dashboard 
Core Experiences
•	Story Page 
•	Branch Explorer 
•	Writing Editor 
•	Feed / Discover 
•	Search Universe 
•	Profiles 
•	Notifications 
•	Collaboration Rooms 
All user actions start here.
Examples:
•	Open a story 
•	Fork a chapter 
•	Write content 
•	Like / Bookmark 
•	Subscribe to creator 
•	Search a universe 
👇 All actions go to the API Gateway.
________________________________________
2️⃣ API Gateway Layer (Supabase + Edge Functions)
Single entry point for all clients.
Responsibilities
•	Authentication (Supabase Auth) 
•	Rate limiting 
•	RLS security 
•	Routing to services 
•	Edge functions for AI calls 
Main APIs:
/stories
/branches
/chapters
/forks
/interactions
/search
/recommendations
/payments
/governance
This layer protects your backend from chaos.
________________________________________
3️⃣ Real-Time Event System ⚡
Narrio is event-driven.
Every action emits an event:
fork_created
chapter_published
story_liked
user_followed
comment_added
subscription_started
dispute_opened
These go into:
Event Bus
•	Supabase Realtime 
•	Redis Streams / Kafka (future scale) 
Why this matters:
Everything downstream reacts to events.
This powers:
•	Notifications 
•	Feed ranking 
•	AI learning 
•	Analytics 
•	Gamification 
•	Moderation 
This is the nervous system.
________________________________________
4️⃣ AI Core Brain 🧠
The heart of Narrio.
AI is NOT a feature.
AI is an infrastructure layer.
AI Brain Services
1) Story Understanding Engine
Creates embeddings & metadata.
Analyzes:
•	Genre 
•	Tropes 
•	Characters 
•	Relationships 
•	Tone 
•	Writing quality 
•	Canon consistency 
Outputs:
story_embedding
chapter_embedding
trope_tags
character_graph_updates
quality_score
canon_confidence
________________________________________
2) Fork Prediction Engine
Predicts where stories will branch.
Detects:
•	Cliffhangers 
•	Emotional peaks 
•	Open questions 
•	Popular tropes 
Generates:
•	Suggested fork prompts 
•	AI fork templates 
•	Viral branch predictions 
________________________________________
3) Universe Builder
Builds story knowledge graph.
Extracts:
•	Characters 
•	Locations 
•	Items 
•	Timelines 
•	Relationships 
Stores in graph DB.
________________________________________
4) AI Writing Assistant
Used in editor:
•	Continue writing 
•	Fix grammar 
•	Suggest dialogue 
•	Check canon conflicts 
________________________________________
5️⃣ Data Layer (Multi-Database Architecture)
Narrio uses 3 specialized databases.
________________________________________
🟢 Postgres (Supabase) — Source of Truth
Stores structured data.
Core tables:
users
stories
branches
chapters
forks
interactions
subscriptions
disputes
moderation_reports
payments
This is your transactional database.
________________________________________
🟣 Vector Database — Semantic Brain
Stores embeddings for:
•	Stories 
•	Chapters 
•	Characters 
•	Users 
Used for:
•	Semantic search 
•	Recommendations 
•	Similar stories 
•	AI prompts 
Think: “Google for fiction”.
________________________________________
🔵 Graph Database — Universe Engine
Stores relationships between:
Story → Branch → Chapter
Character ↔ Character
Character ↔ Location
Branch ↔ Branch
Fork ↔ Parent Fork
User ↔ Story
Used for:
•	Branch Explorer UI 
•	Canon control 
•	Timeline integrity 
•	Universe exploration 
This powers the “infinite branching map”.
________________________________________
🔴 Redis Cache — Speed Layer
Caches:
•	Feed results 
•	Trending stories 
•	Popular forks 
•	Notifications 
•	Search suggestions 
Without cache → app feels slow.
With cache → instant dopamine.
________________________________________
6️⃣ Recommendation & Virality Engine 🚀
Consumes events + AI scores.
Ranking formula combines:
Engagement score
Velocity (growth speed)
Quality score (AI)
Novelty score
Social graph boost
Personal taste match
Outputs:
•	Home feed 
•	Trending page 
•	Recommended forks 
•	Suggested creators 
This is how stories go viral.
________________________________________
7️⃣ Search Engine 🔎
“Google for Fiction”
Hybrid search:
Keyword search  (Postgres)
Semantic search (Vector DB)
Graph exploration (Graph DB)
Users can search:
•	Universes 
•	Characters 
•	Tropes 
•	What-if scenarios 
________________________________________
8️⃣ Gamification Engine 🎮
Consumes events → gives rewards.
Tracks:
XP
Levels
Badges
Streaks
Milestones
Achievements
Triggers dopamine loops:
•	First fork 
•	Viral chapter 
•	Collaboration success 
•	Daily writing streak 
________________________________________
9️⃣ Monetization Engine 💰
Revenue flows.
Creator Earnings
•	Subscriptions 
•	Tips 
•	Premium chapters 
•	Paid universes 
Platform Revenue
•	10%–15% revenue share 
•	Boosted story promotion 
•	AI credits 
Event driven:
chapter_purchased
subscription_started
tip_sent
boost_purchased
________________________________________
🔟 Governance & Trust Layer ⚖️
The “law system” of Narrio.
Handles:
Canon Control
•	Canon vs fan branches 
•	Universe owners 
•	Merge approvals 
Moderation
•	AI content scanning 
•	Community reporting 
•	Strike system 
Disputes
•	Ownership conflicts 
•	Revenue disputes 
•	Plagiarism detection 
AI Ethics
•	AI content labeling 
•	Consent for training 
•	Creator opt-out 
This keeps the universe safe.
________________________________________
🌟 How Everything Flows Together
Example: User forks a chapter
1.	User clicks Fork this story 
2.	API creates fork 
3.	Event emitted → fork_created 
4.	Real-time: 
o	Followers notified 
o	Feed updated 
5.	AI: 
o	Embedding generated 
o	Quality scored 
o	Tropes extracted 
6.	Graph DB: 
o	Branch node created 
7.	Recommendation engine: 
o	Calculates viral potential 
8.	Gamification: 
o	XP awarded 
9.	Monetization: 
o	Creator revenue link created 
10.	Governance: 
•	Canon status tracked 
All automatically.
________________________________________
🧭 The Big Picture
Narrio is built as:
•	Product layer → UX 
•	Event layer → Real-time 
•	AI layer → Intelligence 
•	Data layer → Memory 
•	Ranking layer → Virality 
•	Monetization → Sustainability 
•	Governance → Trust 
Together they form the Narrio Universe Engine.


-- Sprint 6.1 — Publish Control Center visibility policies
-- Purpose:
-- 1. Let "unlisted" behave as direct-link readable while staying out of discovery queries.
-- 2. Ensure public chapter reads are gated by visible story + visible timeline + published chapter.
-- 3. Preserve author and reader-created ForkCraft access introduced in Sprint 5.2.

-- Stories
DROP POLICY IF EXISTS "public can read published public stories" ON public.stories;
DROP POLICY IF EXISTS "public can read published visible stories" ON public.stories;
CREATE POLICY "public can read published visible stories"
ON public.stories
FOR SELECT
USING (
  author_id = auth.uid()
  OR (status = 'published' AND visibility IN ('public', 'unlisted'))
);

-- Branches / timelines
DROP POLICY IF EXISTS "public can read public branches of published stories" ON public.story_branches;
DROP POLICY IF EXISTS "public can read visible branches of published visible stories" ON public.story_branches;
CREATE POLICY "public can read visible branches of published visible stories"
ON public.story_branches
FOR SELECT
USING (
  created_by = auth.uid()
  OR EXISTS (
    SELECT 1
    FROM public.stories s
    WHERE s.id = story_branches.story_id
      AND s.author_id = auth.uid()
  )
  OR EXISTS (
    SELECT 1
    FROM public.stories s
    WHERE s.id = story_branches.story_id
      AND s.status = 'published'
      AND s.visibility IN ('public', 'unlisted')
      AND story_branches.visibility IN ('public', 'unlisted')
  )
);

-- Chapters
DROP POLICY IF EXISTS "public can read published chapters" ON public.chapters;
DROP POLICY IF EXISTS "public can read visible published chapters" ON public.chapters;
CREATE POLICY "public can read visible published chapters"
ON public.chapters
FOR SELECT
USING (
  EXISTS (
    SELECT 1
    FROM public.stories s
    JOIN public.story_branches b ON b.id = chapters.branch_id
    WHERE s.id = chapters.story_id
      AND (
        s.author_id = auth.uid()
        OR b.created_by = auth.uid()
        OR (
          s.status = 'published'
          AND s.visibility IN ('public', 'unlisted')
          AND b.visibility IN ('public', 'unlisted')
          AND chapters.is_published = true
        )
      )
  )
);

-- Chapter versions
DROP POLICY IF EXISTS "public can read current versions of published chapters" ON public.chapter_versions;
DROP POLICY IF EXISTS "public can read current versions of visible published chapters" ON public.chapter_versions;
CREATE POLICY "public can read current versions of visible published chapters"
ON public.chapter_versions
FOR SELECT
USING (
  EXISTS (
    SELECT 1
    FROM public.chapters c
    JOIN public.stories s ON s.id = c.story_id
    JOIN public.story_branches b ON b.id = c.branch_id
    WHERE c.id = chapter_versions.chapter_id
      AND (
        s.author_id = auth.uid()
        OR b.created_by = auth.uid()
        OR (
          s.status = 'published'
          AND s.visibility IN ('public', 'unlisted')
          AND b.visibility IN ('public', 'unlisted')
          AND c.is_published = true
          AND chapter_versions.is_current = true
        )
      )
  )
);

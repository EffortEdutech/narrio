-- Sprint 5.2 Hotfix 1
-- Allows ForkCraft timelines created by readers to be readable/editable by their creator.
-- Keeps the database table names unchanged: branches remain the technical layer, timelines remain the UI language.

-- Branches
DROP POLICY IF EXISTS "public can read public branches of published stories" ON public.story_branches;
CREATE POLICY "public can read public branches of published stories"
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
      AND s.visibility = 'public'
      AND story_branches.visibility = 'public'
  )
);

DROP POLICY IF EXISTS "authors can insert story branches" ON public.story_branches;
CREATE POLICY "authors can insert story branches"
ON public.story_branches
FOR INSERT
WITH CHECK (
  auth.uid() = created_by
  AND (
    EXISTS (
      SELECT 1
      FROM public.stories s
      WHERE s.id = story_branches.story_id
        AND s.author_id = auth.uid()
    )
    OR (
      branch_type = 'fork'
      AND parent_branch_id IS NOT NULL
      AND EXISTS (
        SELECT 1
        FROM public.stories s
        WHERE s.id = story_branches.story_id
          AND s.status = 'published'
          AND s.visibility = 'public'
          AND s.allow_forks = true
      )
    )
  )
);

DROP POLICY IF EXISTS "authors can update story branches" ON public.story_branches;
CREATE POLICY "authors can update story branches"
ON public.story_branches
FOR UPDATE
USING (
  EXISTS (
    SELECT 1
    FROM public.stories s
    WHERE s.id = story_branches.story_id
      AND s.author_id = auth.uid()
  )
  OR created_by = auth.uid()
)
WITH CHECK (
  EXISTS (
    SELECT 1
    FROM public.stories s
    WHERE s.id = story_branches.story_id
      AND s.author_id = auth.uid()
  )
  OR created_by = auth.uid()
);

-- Chapters
DROP POLICY IF EXISTS "public can read published chapters" ON public.chapters;
CREATE POLICY "public can read published chapters"
ON public.chapters
FOR SELECT
USING (
  is_published = true
  OR EXISTS (
    SELECT 1
    FROM public.stories s
    WHERE s.id = chapters.story_id
      AND s.author_id = auth.uid()
  )
  OR EXISTS (
    SELECT 1
    FROM public.story_branches b
    WHERE b.id = chapters.branch_id
      AND b.created_by = auth.uid()
  )
);

DROP POLICY IF EXISTS "authors can insert chapters" ON public.chapters;
CREATE POLICY "authors can insert chapters"
ON public.chapters
FOR INSERT
WITH CHECK (
  EXISTS (
    SELECT 1
    FROM public.stories s
    WHERE s.id = chapters.story_id
      AND s.author_id = auth.uid()
  )
  OR EXISTS (
    SELECT 1
    FROM public.story_branches b
    WHERE b.id = chapters.branch_id
      AND b.created_by = auth.uid()
  )
);

DROP POLICY IF EXISTS "authors can update chapters" ON public.chapters;
CREATE POLICY "authors can update chapters"
ON public.chapters
FOR UPDATE
USING (
  EXISTS (
    SELECT 1
    FROM public.stories s
    WHERE s.id = chapters.story_id
      AND s.author_id = auth.uid()
  )
  OR EXISTS (
    SELECT 1
    FROM public.story_branches b
    WHERE b.id = chapters.branch_id
      AND b.created_by = auth.uid()
  )
)
WITH CHECK (
  EXISTS (
    SELECT 1
    FROM public.stories s
    WHERE s.id = chapters.story_id
      AND s.author_id = auth.uid()
  )
  OR EXISTS (
    SELECT 1
    FROM public.story_branches b
    WHERE b.id = chapters.branch_id
      AND b.created_by = auth.uid()
  )
);

-- Chapter versions
DROP POLICY IF EXISTS "public can read current versions of published chapters" ON public.chapter_versions;
CREATE POLICY "public can read current versions of published chapters"
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
        (s.status = 'published' AND s.visibility = 'public' AND b.visibility = 'public' AND c.is_published = true AND chapter_versions.is_current = true)
        OR s.author_id = auth.uid()
        OR b.created_by = auth.uid()
      )
  )
);

DROP POLICY IF EXISTS "authors can insert chapter versions" ON public.chapter_versions;
CREATE POLICY "authors can insert chapter versions"
ON public.chapter_versions
FOR INSERT
WITH CHECK (
  EXISTS (
    SELECT 1
    FROM public.chapters c
    JOIN public.stories s ON s.id = c.story_id
    JOIN public.story_branches b ON b.id = c.branch_id
    WHERE c.id = chapter_versions.chapter_id
      AND (
        s.author_id = auth.uid()
        OR b.created_by = auth.uid()
      )
  )
);

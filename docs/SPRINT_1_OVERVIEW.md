# Narrio Sprint 1 Overview

## Goal
Materialize the simplified Git-style branching foundation from `narrio_init.md`.

## Locked decisions
1. Kill visual graph editor for MVP.
2. Keep branch tree mental model.
3. Store chapter content in `chapter_versions`.
4. Auto-create a `main` branch when a story is created.
5. Keep AI as helper package, not platform core.
6. Keep monorepo simple: web + marketing + shared packages + Supabase migrations.

## Delivered in this pack
- Monorepo scaffold
- Supabase core schema
- Supabase RLS
- Seed data
- Public library flow
- Story page
- Branch explorer
- Chapter reader
- Writing editor shell

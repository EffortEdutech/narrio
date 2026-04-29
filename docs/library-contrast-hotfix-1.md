# Library Contrast Hotfix 1

## Reason

The `/library` discovery controls were styled with light text meant for dark panels, but they appear inside a light `SectionCard`.

## Scope

This hotfix only touches the library page and its scoped CSS module.

## QA

1. Open `/library`.
2. Confirm `Search by title, synopsis, or writer name...` is readable.
3. Confirm `Search`, `Sort`, `Path type`, and `ForkCraft` labels are readable.
4. Confirm the search placeholder and typed text are readable.
5. Confirm dropdown selected text and options are readable.
6. Confirm `Discovery results` and the public story count are readable.
7. Confirm story cards still look correct.

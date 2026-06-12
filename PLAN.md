# Julienne — Planning Document

A recipe app for iOS with collections, sharing, scaling, variations, and meal planning.

---

## Vision

Julienne is a recipe management app that treats recipes as living documents: scalable, shareable across iCloud, sortable into overlapping collections, and forkable into personal variations. It includes meal planning with ingredient export to Reminders.

---

## Core Features

1. **Recipes** with ingredients, steps, yield/portions
2. **Portion scaling** (2x, 0.5x, custom)
3. **Unit system toggle**: Imperial ↔ Metric (volume↔mass deferred)
4. **Collections**, many-to-many with recipes (one recipe in many collections)
5. **Shared collections** via iCloud / CloudKit
6. **Recipe variations** (git-like fork on edit)
7. **Meal planning** by day, scrollable calendar
8. **Reminders export** for shopping
9. **Quick return** to the currently-cooking recipe from anywhere in the app

---

## Data Model (sketch)

### Recipe
- `id: UUID`
- `title: String`
- `notes: String?`
- `ingredients: [Ingredient]`
- `steps: [Step]`
- `yield: Int` (base portions)
- `parentRecipeID: UUID?` (for variations)
- `variationName: String?` (e.g. "Low-fat")
- `ownerID` (CloudKit user)
- `createdAt`, `modifiedAt`

### Ingredient
- `name: String`
- `amount: Double` (stored in canonical unit)
- `unit: Unit` (e.g. `.grams`, `.milliliters`, `.count`)
- `kind: MeasurementKind` (`.mass`, `.volume`, `.count`)
- Conversion to display unit happens at the view layer

### Collection
- `id: UUID`
- `name: String`
- `recipeIDs: [UUID]`
- `isShared: Bool`
- `shareMetadata` (CKShare reference if shared)

### MealPlanEntry
- `date: Date`
- `recipeID: UUID`
- `scale: Double`
- `servings: Int`

---

## Architecture Choices

### Persistence
- **SwiftData + CloudKit** for the private database
- Drop to **raw CKRecord / CKShare** where SwiftData's CloudKit sharing falls short (likely necessary — SwiftData sharing support is still thin as of this writing; verify against current SDK before committing)

### CloudKit Sharing Strategy

The hard requirement is: *a recipe should appear in a shared collection AND a private one without duplication*.

Two options:

**Option A — Share recipes individually; collections are just ID lists.**
- Each recipe is its own shareable root
- Collections contain `[recipeID]` references
- Sharing a "collection" with someone = iterating recipes and CKShare-ing each
- Pro: a recipe can belong to any number of collections (shared or private) without copy
- Con: sharing UX is many-records-at-once under the hood

**Option B — Share the collection as parent record, recipes as children.**
- Cleaner sharing UX
- But a CKRecord can only have one parent share — so a recipe can't simultaneously live in a shared collection and a private one
- Conflicts with the core requirement

**Recommended:** start with Option A. Spike CKShare on a single recipe early to validate UX flows (invite, accept, revoke).

### Git-like Variations

Avoid building real diff/merge for MVP. Model:
- A variation is a *full recipe copy* with `parentRecipeID` set
- "Fork on edit": when a user edits a recipe received via a share, prompt to create a variation (the original stays untouched upstream)
- Variations are first-class recipes, browsable from the parent
- Future: edit log, three-way merge, "pull upstream changes"

### Units
- Ingredients stored in a **canonical unit per kind** (e.g. grams for mass, ml for volume)
- User-level preference for display system (Imperial/Metric)
- Conversion happens at the view layer
- Volume ↔ mass conversion is **out of scope** for now

### Meal Planning + Reminders Export
- `MealPlanEntry` per day
- Calendar/weekly scroll view
- Export flow:
  1. User selects a date range
  2. App aggregates ingredients across planned meals (with scale applied)
  3. **Review screen** with checkboxes — user un-checks anything they already have
  4. Write checked items to a Reminders list via EventKit
- Pantry tracking ("don't add what I already have" automatically) is a whole sub-feature; defer to a later phase. The review screen is the cheap MVP.

### Active Recipe Access
- App-level state: `currentlyCooking: Recipe?`
- **Persistent cooking bar** above the tab bar inside the app — a thin row showing recipe title + current step, tap to return
- **Live Activity** (ActivityKit) for the lock screen / Dynamic Island when the app is backgrounded
- Both together cover "from anywhere"

---

## UI Structure

### Tabs (liquid glass tab bar)
- **Collections** — browse collections, drill into recipes
- **Plan** — calendar / weekly meal plan view
- **Search** — full-text + ingredient search across all recipes

### Cooking Mode
- Modal / full-screen sheet launched from a recipe
- Backgrounded cooking session persists via the cooking bar + Live Activity
- One active cooking session at a time (MVP)

### Settings
- TBD: profile/avatar button in Collections nav bar, or a sheet from a gear icon
- Holds: unit system preference, iCloud account state, default Reminders list

---

## Open Questions / Risks

1. **CKShare semantics** for recipes referenced by multiple collections — needs an early spike
2. **Conflict resolution** when two forks of a shared recipe both edit — defer to "fork on edit" model for now
3. **Pantry tracking** — defer, but be aware the data model may want a `Pantry` entity later
4. **SwiftData + CloudKit sharing maturity** — may need to drop to raw CloudKit for shares
5. **Live Activity budget** — Apple limits active Live Activities; fine for a single cooking session
6. **Recipe import** (from URL, paste, photo) — not in scope yet, but data model should not preclude

---

## Phased Roadmap

### Phase 1 — Local Foundation
- Project setup, tab structure with liquid glass tab bar
- Recipe CRUD (ingredients, steps, yield)
- Portion scaling
- Unit system toggle (Imperial/Metric)
- Collections (many-to-many, local only)
- SwiftData persistence

### Phase 2 — Cooking + Planning
- Cooking mode UI
- Persistent cooking bar
- Live Activity for active recipe
- Meal plan calendar view
- Reminders export with review screen

### Phase 3 — Sharing + Variations
- CloudKit sync for private DB
- CKShare spike + sharing UX
- Variation model + fork-on-edit prompt
- Browsing variations from a parent recipe

### Phase 4 — Polish & Stretch
- Full-text + ingredient search
- Pantry / "already have" tracking
- Volume ↔ mass conversion
- Recipe import (URL / paste / photo)
- Watch / iPad adaptations

---

## Notes
- No code written yet — this document is the planning artifact.
- Updates to this plan should happen here, not in scattered notes.

# Hylios — Changelog

*Magical Space Intelligence, one entry at a time. Newest first.* 🔮

---

## 2026-09-05 (later): "The Silent Questionnaire, or: What the 409 Wouldn't Say" 🎭🎂

### 🌟 The Tale

The submission was "blocked" — that was all Apple would say. `STATE_ERROR.ENTITY_STATE_INVALID`, a 409 whose entire diagnostic payload is *please check associated errors to see why*, delivered without, and this is the remarkable part, **any associated errors**. Twelve identical rejections. An error that tells you to read the errors it didn't attach.

Except it had. They were there the whole time, in a `meta.associatedErrors` block four levels deep in the JSON, past the point where a truncating log formatter would keep them. And when finally read, the door opened in one minute.

The full walk had already cleared every classic suspect: screenshots present for all three iPhone display types, build `VALID`, compliance answered, contact info on file since 2024, localization text complete, IDFA answered (`usesIdfa=false`, quietly null this whole time). What remained was the **age rating declaration** — specifically the one on the *draft* AppInfo, not the live one. Apple had grown seven new questions since the 1.x era (`advertising`, `userGeneratedContent`, `gunsOrOtherWeapons`, `ageAssurance`, `messagingAndChat`, `parentalControls`, `healthOrWellnessTopics`), and a thirteen-month-old draft answers none of them.

The patching itself was a comedy of types. The entity validates **as a whole** — one attribute at a time is rejected for the six you're *not* sending. And the seven questions are not the same type: six are booleans, but `gunsOrOtherWeapons` is an enum expecting `'NONE'`. Apple's API, to its credit, narrates every wrong guess in plain text. Two failed PATCHes later, the map was complete.

```
PATCH /v1/ageRatingDeclarations/{draft-appInfo-id}  →  200
POST /v1/reviewSubmissionItems                     →  201 ✨ first success of the night
PATCH /v1/reviewSubmissions/{id} {submitted:true}  →  WAITING_FOR_REVIEW
```

**Hylios 2.0 is in Apple's review queue.** Build `260905005`, iPhone-only, no App Clip, submitted 2026-09-05 07:06 UTC.

### 📦 What We Accomplished

- **SUBMITTED** — submission `23f7c549…` → `WAITING_FOR_REVIEW`; version 2.0, build `260905005`
- **Root-caused the generic 409** — `meta.associatedErrors` names the blocker; the missing piece was 7 unanswered modern age-rating questions on the *draft* AppInfo's declaration
- **Learned the submission flip** — no `/submit` endpoint exists; it's `PATCH /v1/reviewSubmissions/{id}` with `"submitted": true` (404: *"The relationship 'submitted' does not exist"* is the wrong-path tell)
- **Dropped the App Clip from the build** (`260905004+`) — an embedded clip makes the App Clip card (3000×2000 + subtitle) mandatory for review; target kept, dependency commented in `project.yml`
- **Restored iPhone-only** — the rewrite's `TARGETED_DEVICE_FAMILY "1,2"` had silently added iPad support the 1.3 listing never had, making iPad screenshots mandatory; the app's own LiDAR gate means no simulator can produce one. `"1"` it is (`260905005`)

### 📋 TODO Carried Forward

- [ ] **Device QA on real LiDAR hardware** — 2.0 went to review without it; the first real-hardware pass should ideally beat Apple's reviewer
- [ ] 📌 **PINNED:** App Clip card artwork → re-embed clip → create default experience → resubmit
- [ ] `/scan` still doesn't exist; the AASA already claims it
- [ ] 2.0 listing screenshots are 1.x-era (shipped as-is; refresh for 2.1)

### 🪞 Reflection

The lesson of the night: **read the whole error body before deciding it's content-free.** The answer was attached to every single failure — I was truncating it at 500 characters and concluding "generic." `meta.associatedErrors` is where ASC hides the actual diagnosis, and it is worth more than every guess in between.

Also: when a form is thirteen months old, the questions have changed. "It shipped 1.3 with this exact metadata" was true and useless — the *rules* moved.

*The questionnaire was silent, the answer was attached, and the plane finally took off.* ✈️✨

---

## 2026-09-05: "The Distributor's Signature, or: Twenty-Five Days in the Departure Lounge" 🎭📦

### 🌟 The Tale

Someone asked, casually, whether we weren't *close* to shipping the new AR scanner. Reader, we were not close. We had been sitting on the runway since **August 11th** with the engines off, and nobody had checked the fuel gauge.

The August build left a note in its own commit message — `CLI exportArchive blocked, GUI Distribute` — the changelog equivalent of a roommate leaving "the sink is weird" on a sticky note and moving to Portland. Five attempts had been burned chasing disk space, stale DerivedData, and embedded targets. The verdict: use the Xcode Organizer GUI, someday, when someone felt like clicking.

So we asked App Store Connect what it actually had. The answer, delivered with the flat affect of an API that owes you nothing: **build 7, uploaded August 2024, expired.** Everything from the entire SwiftUI revival — RoomPlan, Object Capture, Live Activities, the App Clip — had never left the building. Thirteen months of "shipping soon."

The first diagnosis was *almost* right, which is the most expensive kind. The archive was signed `Apple Development`, so — obviously — App Store packaging couldn't work on it. Confident. Clean. **Half wrong.** The archive is *supposed* to say that; `exportArchive` is the step that re-signs. The real culprit was subtler and dumber: the export ran without the App Store Connect auth flags, so Xcode had no Store profile to re-sign *with*, and expressed this by saying `Copy failed` — a message that manages to name the wrong step, the wrong subsystem, and the wrong emotion.

Four flags later: `** EXPORT SUCCEEDED **`. Apple Distribution across the app, the widget, and the clip. `get-task-allow: false`. A 9.2MB IPA sitting there like it had never been difficult.

Then Apple rejected it three times in one breath. No orientations declared — *twice*, once for the app and once for the clip, because iPad-capable bundles get individually offended. And the App Clip was missing `CFBundlePackageType` entirely, because XcodeGen emits it for `type: application` and quietly does not for on-demand-install targets. The build log had **warned us about the orientation thing** before Apple did. It scrolled past. It always scrolls past.

Fixed at the source in `project.yml`, bumped to `260905002`, sent it up. `Progress 100%: Upload succeeded.` Two minutes of ASC indexing later: **VALID, not expired.** First live TestFlight build since August 2024.

Along the way, two things fell out of the walls. A `.env` holding a live GitHub PAT was **not gitignored** — one `git add .` from being a public artifact. And the website repo's local checkout turned out to be **12 commits behind production**, which matters enormously because `vercel --prod` deploys the *working tree*, not git; a casual deploy from that directory would have silently reverted a merged React Server Components CVE fix.

### 📦 What We Accomplished

- **Build `2.0 (260905002)` is live on TestFlight** — `VALID`, unexpired, the first since Aug 2024
- **Root-caused `IDEDistributionPackagingStep: Copy failed`** — missing ASC auth flags on `exportArchive`, not a corrupt archive. Headless shipping now works; the Organizer GUI is not required
- **Fixed three Apple validation rejections at the source** — `UISupportedInterfaceOrientations` (per-idiom, `~ipad` gets all four) on both iPad-capable bundles, `CFBundlePackageType: APPL` on the clip
- **Rewrote `scripts/archive.sh`** — auth flags, an `--upload` gate so the default keeps the IPA local, and a self-verifying tail that inspects the *IPA* rather than the archive
- **Corrected `scripts/README.md`** — documented the red herring so nobody re-chases the archive's signing identity
- **Created the `gthemystic/Hylios` public mirror** — both branches, full history (D5, unblocked at last)
- **Plugged two leaks** — `.env` and `dist/` added to `.gitignore`; PAT scrubbed from `.git/config` after use
- **Laid AASA groundwork** — `apple-app-site-association` + a `next.config.js` Content-Type header, written but deliberately undeployed
- **Found the App Clip's missing `associated-domains`** — it could never have been URL-invoked; entitlement added for the next build

### 🌙 The Encore

Three more things landed after the changelog was first drafted, so: the AASA went live via PR #4 (branched off `origin/master`, because the local checkout was seven months stale and `vercel --prod` ships the working tree, not git — that one would have quietly un-fixed a merged CVE). Build `260905003` followed with the `associated-domains` entitlement, making it the first Hylios binary that *could* be invoked from a URL.

Then App Store Connect drew a line. Repointing the two legacy App Clip experiences turned out to be impossible by design — `link` is immutable on an advanced experience, and creating replacements demands a 3000×2000 header image and per-language localizations that don't exist yet. **Parked deliberately** (see `TODO.md`). Instead we went default-only: the stale `1.4` draft from December 2024 was repurposed into the **2.0 version** with `260905003` attached. No header image required, and the vestigial draft finally earns its keep.

### 🔐 Two Late Security Beats

Staging the commit surfaced that the new `archive.sh` and README were about to publish the App Store Connect **key ID and issuer ID into a public repo**. Not credentials on their own — the `.p8` is the secret — but no reason to hand out half the lock. Both moved into the gitignored `.env`, with the script failing fast and loudly if they're absent.

Appending them to `.env` then promptly **corrupted the GitHub PAT**, because the file had no trailing newline and `ASC_KEY_ID=` fused onto the end of the token. Caught it on a `value_len=50` that should have been 40, repaired by splitting on the glued boundary, and re-verified the token still authenticates as `gthemystic`. A reminder that `>>` is not an editor.

### 📋 TODO Carried Forward

- [x] ~~Deploy the site so the AASA is live~~ — PR #4, live and serving `application/json`
- [x] ~~Rebuild + upload `260905003` with the associated-domains entitlement~~ — `VALID`
- [x] ~~Create the 2.0 App Store version~~ — build attached
- [ ] 📌 **PINNED:** App Clip *advanced* experiences — blocked on a 3000×2000 header image + localized copy; `link` is immutable so they must be recreated, not edited
- [ ] `/scan` doesn't exist on the site yet — the AASA already advertises it
- [ ] Decide ordering vs unmerged PR #3 ("repo diet") on the website
- [ ] **Device QA** — RoomPlan needs a real LiDAR iPhone Pro; the object-capture orbit has never been run for real
- [ ] 2.0 submission metadata is still 1.x-era — screenshots, keywords, "What's New"
- [ ] Nothing is committed. 11 files across two repos await review

### 🪞 Reflection

The lesson isn't "add the flags." It's that **a confident wrong diagnosis costs more than no diagnosis at all.** August's note said the CLI was blocked and the GUI was the way — so for twenty-five days nobody re-opened the question, because it had been *answered*. My own first pass repeated the pattern in miniature: I read `Apple Development` in the archive, felt the click of recognition, and wrote it up as root cause before checking whether the export step even cared. It didn't.

What actually broke the deadlock was refusing to trust the local log and asking the far end what it had. `** EXPORT SUCCEEDED **` printed cheerfully while Apple was rejecting the bundle three times; the IPA existed and was perfectly signed and was still inadmissible. Two "successes" in a row that weren't. Verification has to happen at the boundary you actually care about, and for shipping, that boundary is Apple's servers.

Also: the build log warned about the orientations before Apple did. It's in the log, in plain English, forty lines above `ARCHIVE SUCCEEDED`. We have been trained by a thousand harmless Xcode warnings to treat that channel as noise, and occasionally it isn't.

*Twenty-five days in the departure lounge over four command-line flags. The scanner works. It always worked.* ✨

---

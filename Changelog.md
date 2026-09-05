# Hylios — Changelog

*Magical Space Intelligence, one entry at a time. Newest first.* 🔮

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

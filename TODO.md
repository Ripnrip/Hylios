# Hylios — TODO

*Immediate tasks. Longer-horizon direction lives in `docs/REVIVAL-PLAN.md`; what happened lives in `Changelog.md`.*

---

## 📌 Pinned — deferred by decision

### App Clip **advanced** experiences — parked 2026-09-05
**Status:** deliberately deferred. Not needed right now; default experience covers the case.

The two advanced experiences registered in App Store Connect still point at dead/legacy domains:

| link | lang | state |
|---|---|---|
| `https://etherialdimension.pages.dev/japan` | JA | `RECEIVED` (note the `etherial` typo domain) |
| `https://etherealdimension.netlify.app/geo` | EN | `RECEIVED` — **returns 404** |

**Why this isn't a quick fix.** The ASC API rejects any attempt to repoint them:

> `ENTITY_ERROR.ATTRIBUTE.NOT_ALLOWED` — The attribute `link` can not be included in a `UPDATE` request

`link` is immutable. Retiring the old ones and creating replacements is the only path, and creation requires two relationships that need real assets:

> missing required relationship `headerImage` · missing required relationship `localizations`

**To unpark, you need:**
1. A **3000×2000** header image per experience
2. Title + subtitle copy per language (EN, plus JA if the Japan card is being kept)
3. A decision on the invocation URL — `https://etherealdimension.io/scan` was the assumed target, and `/scan` **does not exist on the site yet** (the AASA `applinks` block already claims it)

Then: create new experiences → mark the two legacy ones `removed`.

---

## 🔜 Next up

- [ ] **Device QA on a LiDAR iPhone Pro** — RoomPlan and Object Capture have never been exercised on real hardware. The object-capture orbit in particular is untested end-to-end. Simulator cannot do this. ⚠️ 2.0 shipped to review WITHOUT this — first real-hardware pass should happen before Apple's reviewer gets there.
- [ ] **Build the `/scan` landing page** on etherealdimension.io — the AASA advertises `applinks` for `/scan` and `/scan/*`, but the route 404s today. Universal links into the app will fail until it exists.
- [ ] **App Clip card artwork (3000×2000) + subtitle** — re-enable the clip: uncomment the `HyliosClip` dependency in `project.yml`, create the App Clip **default** experience in ASC (card is mandatory for review once a build embeds a clip), rebuild, resubmit.
- [ ] **Decide ordering vs website PR #3** ("repo diet + README truth pass") — still unmerged, and it deletes ~155MB from the tree.
- [ ] 2.0 metadata is 1.x-era screenshots — fine for this review (they shipped 1.3), refresh for 2.1.

## ✅ Recently done (2026-09-05)

- [x] **2.0 SUBMITTED FOR APP STORE REVIEW** — build `260905005` (iPhone-only, no App Clip), submission `23f7c549…`, state `WAITING_FOR_REVIEW`
- [x] Root-caused the final 409 `STATE_ERROR.ENTITY_STATE_INVALID` — the **age rating declaration** on the *draft* appInfo was missing 7 newer mandatory answers (`advertising`, `userGeneratedContent`, `gunsOrOtherWeapons`, `ageAssurance`, `messagingAndChat`, `parentalControls`, `healthOrWellnessTopics`). Mixed types: 6 booleans + 1 enum; must be PATCHed **together** (whole-entity validation). `usesIdfa=false` also answered.
- [x] **App Clip dropped from the build** (`260905004+`) — embedding a clip makes the App Clip card (3000×2000 header + subtitle) mandatory for review; artwork doesn't exist. Target kept intact in `project.yml`, dependency commented.
- [x] **iPhone-only restored** (`TARGETED_DEVICE_FAMILY "1"`, `260905005`) — the rewrite had set `"1,2"`, silently adding iPad support (→ mandatory iPad screenshots) the 1.3 listing never had; the LiDAR gate means no simulator can fake one.
- [x] TestFlight unblocked — builds `260905002`–`260905005` uploaded, all `VALID`
- [x] 2.0 App Store version created (repurposed the stale 1.4 draft); release notes ("What's New") written
- [x] AASA live at `https://etherealdimension.io/.well-known/apple-app-site-association` (`application/json`)
- [x] App Clip `associated-domains` entitlement added (shipped in `260905003`; clip itself parked)
- [x] `gthemystic/Hylios` public mirror created
- [x] `.env` + `dist/` gitignored (a live PAT had been sitting unignored)

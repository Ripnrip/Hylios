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

- [ ] **Device QA on a LiDAR iPhone Pro** — RoomPlan and Object Capture have never been exercised on real hardware. The object-capture orbit in particular is untested end-to-end. Simulator cannot do this.
- [ ] **Build the `/scan` landing page** on etherealdimension.io — the AASA advertises `applinks` for `/scan` and `/scan/*`, but the route 404s today. Universal links into the app will fail until it exists.
- [ ] **Verify App Clip invocation on device** once a build with `appclips:etherealdimension.io` is installed — confirm iOS actually fetches and honours the AASA.
- [ ] **App Store 2.0 submission metadata** — the 2.0 version draft exists with build `260905003` attached, but screenshots, keywords, description and "What's New" are all still from the 1.x era.
- [ ] **Decide ordering vs website PR #3** ("repo diet + README truth pass") — still unmerged, and it deletes ~155MB from the tree.

## ✅ Recently done (2026-09-05)

- [x] TestFlight unblocked — builds `260905002` and `260905003` uploaded, both `VALID`
- [x] 2.0 App Store version created (repurposed the stale 1.4 draft) with `260905003` attached
- [x] AASA live at `https://etherealdimension.io/.well-known/apple-app-site-association` (`application/json`)
- [x] App Clip `associated-domains` entitlement added and shipped in `260905003`
- [x] `gthemystic/Hylios` public mirror created
- [x] `.env` + `dist/` gitignored (a live PAT had been sitting unignored)

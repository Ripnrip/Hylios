# Hylios Revival — Consolidate, Polish, Modernize

## Context

Hylios ("Magical Space Intelligence") is the published AR room-scanning iOS app (App Store `id6474466548`, Binary Bros LLC). Its only source lived at the public **`noeticactivity/Hylios`** repo — invisible to earlier searches because `noeticactivity` isn't linked to the `Ripnrip`/`gthemystic` GitHub identities. The app hasn't shipped since **v1.3 (Aug 2024)** and "needs love."

**Current state of `noeticactivity/Hylios`** (cloned to `/Users/admin/Developer/Hylios`, `EtherealDimension.xcodeproj`, bundle `com.binarybros.EtherealDimension`):
- 8 Swift files / 537 LOC; UIKit + Storyboards + **RoomPlan**; USDZ (`.parametric`) export via share sheet; onboarding + residential/commercial/public space picker.
- **Defects found:** `NSCameraUsageDescription` is **empty** (App Store blocker / would crash camera), `SWIFT_VERSION = 5.0`, deployment target split `16.0`/`17.2`, `print()` logging, stringly-typed enums with typos (`appartment`), a hacky email-gate before export, dangling `LICENSE.txt` reference, a duplicate/misnamed `AppIcon 1.appiconset`, leftover template `ship.scn`/`Room.scn`. No haptics, no animations beyond `UIView.animate`, no Live Activities.

**Goal:** (1) consolidate the repo onto `Ripnrip/Hylios` (primary, public) + `gthemystic/Hylios` (mirror), preserving history; (2) give it a beautiful identity — animated SVG banner + README + demo footage; (3) modernize the app to SwiftUI + Swift 6, iOS 18 floor with opt-in iOS 26 Liquid Glass, adding modern RoomPlan, curated open-swiftui-animations, haptics, and Live Activities. Governed by `~/Downloads/swift-canon`.

## Decisions (locked)

| # | Decision |
|---|---|
| D1 | **Full SwiftUI rewrite** on the same bundle ID `com.binarybros.EtherealDimension` (so it ships as an update to the existing App Store listing). Display name = **Hylios**. |
| D2 | **iOS 18.0 floor**, **Swift 6** strict concurrency. Liquid Glass adopted behind `if #available(iOS 26, *)` (canon `liquid-glass.md`). MeshGradient + Control-widget + multi-Live-Activities available on the floor. |
| D3 | **`Ripnrip/Hylios` is the primary public home** (origin). `gthemystic/Hylios` is a public mirror. `noeticactivity` kept as `upstream` for traceability. |
| D4 | Develop in `/Users/admin/Developer/Hylios` on **Studio** (full Edit/Write + canon + banner tooling); build sim via `xcodebuild` on Studio; **device QA on a LiDAR iPhone Pro** by the user (RoomPlan requires LiDAR). |
| D5 | `gthemystic` mirror is **blocked on auth** — needs `! gh auth login --web` as gthemystic + `gh auth switch -u gthemystic` (or create `gthemystic/Hylios` and add `Ripnrip` as collaborator). Ripnrip work proceeds immediately. |

## Phases (each ends with a verification gate)

### Phase 1 — Consolidate & preserve history  →  verify: `Ripnrip/Hylios` exists, full history pushed, `noeticactivity`=upstream
- `gh repo create Ripnrip/Hylios --public`; in the local clone set `origin → Ripnrip`, `upstream → noeticactivity`; `git push -u origin main`.
- Add `.gitignore` (Xcode: `DerivedData/`, `*.xcuserdata`, `.DS_Store`, `.build/`) and `LICENSE` (MIT). 
- (Gated on D5) Create `gthemystic/Hylios`, add remote `gthemystic`, push.

### Phase 2 — Repo identity / polish  →  verify: README renders on GitHub, banner animates inline, About/topics set
- **Animated SVG banner** `assets/banner.svg`: dark "magical space intelligence" theme — Hylios wordmark with an animated gradient glow + a wireframe room swept by a LiDAR scan beam. SMIL `<animate>`, `prefers-reduced-motion` guard, viewBox ~1536×614; embedded via raw `<img>` so the browser plays it (exactly the browser-harness `banner-ink.svg` technique — verified 1.2 MB SMIL SVG).
- **`README.md`:** banner → tagline → demo section embedding the real scan footage (`HyliosScan.gif` / `hylios-scan.mp4` from `~/Documents/EtherealDimension`) → features → requirements (iPhone Pro/iPad Pro + LiDAR, iOS 18+) → install/build → tech stack → roadmap → **attributions** (open-swiftui-animations © amosgyamfi, Apple RoomPlan sample) → MIT license.
- GitHub repo **About**: one-line description, topics (`arkit`, `roomplan`, `lidar`, `swiftui`, `ios`, `3d-scanning`, `realitykit`, `live-activities`), website = the EtherealDimension marketing site.

### Phase 3 — Foundation modernize  →  verify: `xcodebuild -scheme EtherealDimension -destination 'platform=iOS Simulator,name=iPhone 17'` builds clean; Swift 6; iOS 18 floor; camera string set
- Bump `SWIFT_VERSION → 6.0`, `IPHONEOS_DEPLOYMENT_TARGET → 18.0` (all targets), enable Swift 6 strict concurrency.
- **Fix `NSCameraUsageDescription`** with a real string (e.g. "Hylios uses the camera to scan your space into a 3D model."). Clean AppIcon to one proper appiconset; delete template `ship.scn`/`Room.scn` + dangling `LICENSE.txt` ref.
- **New SwiftUI entry:** `@main struct HyliosApp: App` replacing the Storyboard scene manifest in `Info.plist`; set `INFOPLIST_KEY_CFBundleDisplayName = Hylios`.
- Folder layout: `App/`, `Features/{Onboarding,SpacePicker,Scan,Export,Results}`, `Core/{Models,Haptics,Logger}`, `UI/{Animations,Glass}`.
- `Logger.swift` via `os.Logger` (canon `logging.md`).

### Phase 4 — Feature layer  →  verify: scan→USDZ works on device; haptics fire; Live Activity shows; animations respect Reduce Motion; swift-testing green
- **RoomPlan (modern):** `RoomCaptureViewRepresentable: UIViewRepresentable` wrapping `RoomCaptureView`; `@Observable ScanModel` owning `RoomCaptureSession` with a clean state machine (idle→scanning→processing→done→exported); async delegate bridging per canon `concurrency.md`/`swiftui-state.md`.
- **Export:** `CapturedRoom.export(to:exportOptions:)` (`.parametric` default, offer `.mesh`/`.all`) surfaced via SwiftUI `ShareLink` — replaces `UIActivityViewController`; drop the email-gate hack (or move to a proper opt-in sheet).
- **Results preview:** `RealityView` (RealityKit, iOS 18) showing the exported USDZ — revives the commented-out `SceneModalViewController` properly.
- **SpacePicker:** SwiftUI `Picker`(segmented) + `List` replacing the `UIPickerView`; fix `appartment → apartment`; `CaseIterable` + exhaustive switches (canon `enum-design.md`).
- **Haptics** (`Core/Haptics.swift`, canon `motion-haptics.md`): impact on scan start/stop/done, `.success` on export, selection on picker — all gated on `UIAccessibility.isReduceMotionEnabled`.
- **Curated open-swiftui-animations** (3–5, attributed in README + inline): scan-beam pulse, shimmer/skeleton during USDZ processing, spring sheet transitions, success celebration on export. Reduce-Motion fallbacks (canon `animations.md`/`motion-haptics.md`).
- **Live Activities (ActivityKit, canon `platform-extensions.md`):** new **Widget Extension target**; `ScanActivityAttributes` + `ScanLiveActivity` (lock-screen + Dynamic Island compact/expanded) showing "Scanning your space" → done. `if #available(iOS 18)` for the lock-screen LA list.
- **Liquid Glass (opt-in):** `UI/GlassSurface.swift` wraps `glassEffect` behind `if #available(iOS 26, *)` for the nav bar / export sheet floating over the camera feed.
- **Tests (canon `testing.md`):** swift-testing for enum logic + export-URL building; `#Preview` state matrix for each screen; snapshot tests where visuals matter.

### Phase 5 — Ship prep  →  verify: archive uploads to TestFlight (ASK before shipping)
- Bump `MARKETING_VERSION` (1.3 → 2.0, reflecting the rewrite) + build number per the Binary Bros scheme `YYMMDD00N`.
- Archive + upload via Binary Bros ASC key `H93L552576` / issuer `69a6de7f-…` / team `5Y7NBCKHJP` (per `binarybros-ios-ship` memory). **Confirm with user before any upload.**

## Critical files

- **Source (rewrite):** `EtherealDimension/RoomCaptureViewController.swift` (260 LOC → SwiftUI `Scan/`), `RoomTypeViewController.swift` (112 LOC → `SpacePicker/`), `OnboardingViewController.swift`, `AppDelegate.swift`+`SceneDelegate.swift` (→ `@main HyliosApp`), `Info.plist` (scene manifest → app entry; add `NSCameraUsageDescription` + `CFBundleDisplayName`).
- **Project:** `EtherealDimension.xcodeproj/project.pbxproj` (Swift 6, iOS 18, add Widget Extension target, fix targets).
- **New:** `assets/banner.svg`, `README.md`, `LICENSE`, `.gitignore`, the SwiftUI feature/core/ui tree, Widget Extension.
- **Canon applied:** `~/Downloads/swift-canon/{animations,motion-haptics,liquid-glass,latest-apis,platform-extensions,swiftui-state,enum-design,logging,testing,previews}.md`.
- **Reuse (assets):** `~/Documents/EtherealDimension/HyliosScan.gif`, `hylios-scan.mp4` for the README demo.

## Verification (end-to-end)

1. `cd /Users/admin/Developer/Hylios && xcodebuild -scheme EtherealDimension -destination 'platform=iOS Simulator,name=iPhone 17' clean build` → BUILD SUCCEEDED, Swift 6, no concurrency errors.
2. `xcodebuild test …` → swift-testing green; snapshot baselines recorded in a PR gallery.
3. On a LiDAR iPhone Pro: scan a room → USDZ export → ShareLink → optional RealityView preview; haptics fire at start/stop/export; Live Activity appears on Lock Screen + Dynamic Island and ends cleanly; Liquid Glass surfaces render on iOS 26; Reduce Motion disables motion/haptics.
4. `gh repo view Ripnrip/Hylios --web` → README renders, banner animates, About/topics set; `git log` shows full noeticactivity history.
5. (Phase 5) `xcodebuild archive` + `altool`/`xcrun notarytool`-style upload → TestFlight build appears; **user confirms before release.**

## Needs from the user

- **gthemystic auth** (for the mirror): `! gh auth login --hostname github.com --git-protocol https --web` then `! gh auth switch -u gthemystic` — or create `gthemync/Hylios` and add `Ripnrip` as collaborator. (Ripnrip work starts now regardless.)
- **A LiDAR iPhone Pro** for real scan/haptic/Live-Activity QA (simulator has no RoomPlan/LiDAR).
- **Confirm before TestFlight upload** in Phase 5.

## Out of scope

- The Next.js marketing site (`Ripnrip/EtherealDimension` / `EtherealDimensionsWeb`) — separate repo.
- Mac-side Object Capture / photogrammetry rendering — future enhancement.
- App Store listing metadata refresh (screenshots/keywords) — can follow after the build ships.

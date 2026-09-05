# Hylios Scripts

Utility scripts for building, archiving, and distributing the Hylios iOS app (EtherealDimension).

## Scripts

### archive.sh

Archives Hylios and exports an App Store–signed build.

**Usage:**
```bash
./scripts/archive.sh            # archive + export a local .ipa (nothing leaves this Mac)
./scripts/archive.sh --upload   # archive + export straight into App Store Connect
```

**Output:**
- Archive: `dist/EtherealDimension.xcarchive`
- IPA: `dist/export-ios/EtherealDimension.ipa`
- Log: `dist/archive.log`

The script self-verifies the exported IPA at the end: it must report
`Authority=Apple Distribution: Binary Bros LLC` and `get-task-allow: <false/>`.

## TestFlight Distribution

**Resolved 2026-09-05.** The `IDEDistributionPackagingStep: Copy failed` error recorded in
commit `a1a7505` was caused by running `exportArchive` **without the App Store Connect
authentication flags**. Without them Xcode cannot fetch (or create) the Store provisioning
profiles it needs to re-sign the app, so packaging dies with that opaque message. Adding

```
-authenticationKeyID "$ASC_KEY_ID" \
-authenticationKeyIssuerID "$ASC_ISSUER_ID" \
-authenticationKeyPath "$ASC_KEY_PATH" \
-allowProvisioningUpdates -allowProvisioningDeviceRegistration
```

to **both** the `archive` and `-exportArchive` invocations fixes it. The Xcode Organizer GUI
is no longer required.

### Configuration

`archive.sh` reads the App Store Connect identifiers from a **gitignored `.env`** at the repo
root (this repo is public, so they are deliberately not committed):

```
ASC_KEY_ID=...
ASC_ISSUER_ID=...
# optional; defaults to ~/.appstoreconnect/private_keys/AuthKey_$ASC_KEY_ID.p8
ASC_KEY_PATH=...
```

The script fails fast with a clear message if either is unset or the `.p8` is missing.

### Red herring: the archive says "Apple Development"

`dist/EtherealDimension.xcarchive/Info.plist` reports
`SigningIdentity: Apple Development: Gurinder Singh` — **this is correct and expected.**
`exportArchive` is the step that re-signs with `Apple Distribution`. Verify the **IPA**,
never the archive.

## Build Information

- **Bundle IDs:** `com.binarybros.EtherealDimension` (app) ·
  `.ScanActivity` (Live Activity widget) · `.Clip` (App Clip)
- **Team:** 5Y7NBCKHJP
- **Deployment Target:** iOS 18.0
- **Swift Version:** 6.0
- **Version:** 2.0 (build 260905001)
- **Build number scheme:** `YYMMDD00N`

## XcodeGen

The project uses XcodeGen. After changing `project.yml` (including the build number):

```bash
cd /Users/admin/Developer/Hylios
xcodegen generate
```

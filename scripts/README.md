# Hylios Scripts

This directory contains utility scripts for building, archiving, and distributing the Hylios iOS app (EtherealDimension).

## Scripts

### archive.sh

Creates an xcarchive of the Hylios app.

**Usage:**
```bash
./scripts/archive.sh
```

**Output:**
- Archive: `dist/EtherealDimension.xcarchive`
- Log: `/tmp/hylios-archive.log`

## TestFlight Distribution

Per commit `a1a7505`, CLI `xcodebuild -exportArchive` is currently blocked with the error:
`IDEDistributionPackagingStep: Copy failed`

**Solution:** Use Xcode Organizer to upload to TestFlight:

1. Open `EtherealDimension.xcodeproj` in Xcode
2. Select **Product → Archive** (or run `./scripts/archive.sh` first)
3. In the Organizer window, click **Distribute App**
4. Select **App Store Connect** and follow the prompts
5. Complete the upload in Xcode

## Build Information

- **Bundle ID:** com.binarybros.EtherealDimension
- **Team:** 5Y7NBCKHJP
- **Deployment Target:** iOS 18.0
- **Swift Version:** 6.0
- **Version:** 2.0 (build 260811004)

## XcodeGen

The project uses XcodeGen. To regenerate the Xcode project:

```bash
cd /Users/admin/Developer/Hylios
xcodegen generate
```

This is useful if `workspace.yml` changes.
# Sleep Timer for macOS

A small macOS menu bar app that lets you put your Mac to sleep either after a countdown or at a chosen time of day.

## Features

- Menu bar app with compact popup UI
- Countdown scheduling in seconds, minutes, or hours
- Time-of-day scheduling for the next matching hour/minute
- Live countdown shown in the menu bar while running
- In-popup About modal and menu bar About action
- Packaged `.app` bundle with custom icon

## Run Locally

Requirements:

- macOS
- Xcode command line tools or Xcode with Swift support

Run the app:

```bash
swift run
```

Build it:

```bash
swift build
```

## Create a Shareable App Bundle

Package the app into a local `.app` bundle and zip:

```bash
zsh scripts/package_app.sh
```

Artifacts are generated in:

- `dist/Sleep Timer.app`
- `dist/SleepTimer.zip`

## Release Signing and Notarization

For Developer ID signing and Apple notarization, see:

- [RELEASE.md](RELEASE.md)

Once your Apple credentials are configured, run:

```bash
zsh scripts/sign_and_notarize.sh
```

## Project Structure

- `Sources/` — SwiftUI app source
- `AppBundle/` — app bundle metadata, icon, and entitlements
- `scripts/` — packaging, icon generation, and release scripts
- `dist/` — generated release artifacts

## Notes

- The app uses `pmset sleepnow` to trigger macOS sleep when the timer completes.
- The packaged app is ready for local sharing. For external distribution without Gatekeeper warnings, use Developer ID signing and notarization.

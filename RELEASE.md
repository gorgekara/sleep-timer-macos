# Release

This app is ready for local packaging. To distribute it outside the Mac App Store without Gatekeeper warnings, sign it with Developer ID and notarize it.

## Apple Requirements

Based on Apple's current Developer ID and notarization docs:

- You need an Apple Developer Program membership.
- You need a `Developer ID Application` certificate.
- You should sign with the hardened runtime enabled.
- You should notarize with `notarytool` and then staple the ticket.

Official references:

- [Developer ID](https://developer.apple.com/support/developer-id/)
- [Signing Mac software with Developer ID](https://developer.apple.com/developer-id/)
- [Notarizing macOS software before distribution](https://developer.apple.com/documentation/security/notarizing-macos-software-before-distribution)

## One-Time Setup

1. Create or install your `Developer ID Application` certificate in Keychain Access.
2. Store notarization credentials in a keychain profile:

```bash
xcrun notarytool store-credentials "SleepTimerNotary" \
  --apple-id "YOUR_APPLE_ID" \
  --team-id "YOUR_TEAM_ID" \
  --password "YOUR_APP_SPECIFIC_PASSWORD"
```

3. Export the certificate name into your shell:

```bash
export DEVELOPER_ID_APP_CERT="Developer ID Application: Your Name (TEAMID)"
export NOTARY_KEYCHAIN_PROFILE="SleepTimerNotary"
```

## Release Command

Run:

```bash
zsh scripts/sign_and_notarize.sh
```

That script will:

- build the release app bundle
- sign `dist/Sleep Timer.app`
- submit it with `notarytool`
- staple the notarization ticket
- regenerate `dist/SleepTimer.zip`
- verify signing and Gatekeeper assessment locally

## Output

Final release artifacts:

- `dist/Sleep Timer.app`
- `dist/SleepTimer.zip`

## Notes

- The script notarizes the `.app`, staples the `.app`, and then zips the stapled result for sharing.
- If you change bundle identifiers, entitlements, or capabilities later, update `AppBundle/Info.plist` and `AppBundle/Release.entitlements`.

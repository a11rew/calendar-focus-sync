### Internal Release Process

1. Bump `CURRENT_PROJECT_VERSION` and `MARKETING_VERSION` in `Calendar Focus Sync.xcodeproj/project.pbxproj` to the new version number.
2. Update the `CHANGELOG.md` with the new version number and changes.
3. In XCode, Product > Archive, then Distribute App > App Store Connect > Upload

## Direct Distribution

1. In XCode, Product > Archive, then Distribute App > Custom > Copy App
2. Use [create-dmg](https://github.com/sindresorhus/create-dmg) to create a DMG file for distribution

```
create-dmg Calendar\ Focus\ Sync.app/
```

3. Upload the DMG file to GitHub Releases

# Contributing

Please check out common DSC Community [contributing guidelines](https://dsccommunity.org/guidelines/contributing).

## Running the Tests

If want to know how to run this module's tests you can look at the [Testing Guidelines](https://dsccommunity.org/guidelines/testing-guidelines/#running-tests)

## Running things

Pull down the repo and then run the following to resolve dependencies and
download modules.

```PowerShell
./build.ps1 -ResolveDependency -Tasks noop
```

To build the thing

```Powershell
./build.ps1 -Tasks build
```

## Versioning

This module uses [GitVersion](https://gitversion.net/) in `ContinuousDelivery` mode to automatically calculate the module version from the Git commit history.

### How versions are calculated

- The base version is set in `GitVersion.yml` (`next-version`)
- On the `main` branch, versions are generated as `{version}-preview{N}` where `N` is the number of commits since the last version-related change
- GitVersion uses Git tags to anchor version calculations — after a successful release, the `Publish_Release_To_GitHub` task creates a GitHub release (and thus a Git tag), which allows the next push to `main` to calculate an incremented preview number

### Bumping the version

GitVersion automatically bumps the version based on commit message keywords:

| Bump | Commit message must contain |
|------|-----------------------------|
| Major | `breaking change`, `breaking`, or `major` |
| Minor | `adds`, `features`, `feature`, or `minor` |
| Patch | `fix` or `patch` |
| No bump | `+semver: none` or `+semver: skip` |

### If a publish fails with a 409 (version already exists)

This error occurs when the workflow attempts to publish a version that already exists on PSGallery. The deploy workflow automatically checks PSGallery before publishing and skips the publish step gracefully if the version already exists.

If you need to force a new publish with a higher version, you can:

1. **Include a bump keyword in your next commit message** (e.g., `minor: add new feature`) so GitVersion calculates a new version
2. **Manually update `next-version` in `GitVersion.yml`** to a version higher than what is currently published on PSGallery

# Checkstyle for Java GitHub Action

<!-- Release and Build Status -->
[![GitHub release (latest SemVer)](https://img.shields.io/github/v/release/dbelyaev/action-checkstyle?logo=github&sort=semver)](https://github.com/dbelyaev/action-checkstyle/releases)
[![reviewdog](https://github.com/dbelyaev/action-checkstyle/workflows/reviewdog/badge.svg)](https://github.com/dbelyaev/action-checkstyle/actions?query=workflow%3Areviewdog)
[![release](https://github.com/dbelyaev/action-checkstyle/workflows/release/badge.svg)](https://github.com/dbelyaev/action-checkstyle/actions?query=workflow%3Arelease)
[![depup](https://github.com/dbelyaev/action-checkstyle/workflows/depup/badge.svg)](https://github.com/dbelyaev/action-checkstyle/actions?query=workflow%3Adepup)
<!-- Test Status -->
[![Test - Reviewers](https://github.com/dbelyaev/action-checkstyle/actions/workflows/test-reviewers.yml/badge.svg)](https://github.com/dbelyaev/action-checkstyle/actions/workflows/test-reviewers.yml)
[![Test - Versions](https://github.com/dbelyaev/action-checkstyle/actions/workflows/test-versions.yml/badge.svg)](https://github.com/dbelyaev/action-checkstyle/actions/workflows/test-versions.yml)
[![Test - Other](https://github.com/dbelyaev/action-checkstyle/actions/workflows/test-other.yml/badge.svg)](https://github.com/dbelyaev/action-checkstyle/actions/workflows/test-other.yml)
<!-- Project Quality and Community -->
[![OpenSSF Scorecard](https://api.securityscorecards.dev/projects/github.com/dbelyaev/action-checkstyle/badge)](https://securityscorecards.dev/viewer/?uri=github.com/dbelyaev/action-checkstyle)
[![Contributor Covenant](https://img.shields.io/badge/Contributor%20Covenant-2.1-4baaaa.svg)](CODE_OF_CONDUCT.md)
[![FOSSA Status](https://app.fossa.com/api/projects/git%2Bgithub.com%2Fdbelyaev%2Faction-checkstyle.svg?type=shield)](https://app.fossa.com/projects/git%2Bgithub.com%2Fdbelyaev%2Faction-checkstyle?ref=badge_shield)
[![action-bumpr supported](https://img.shields.io/badge/bumpr-supported-ff69b4?logo=github&link=https://github.com/haya14busa/action-bumpr)](https://github.com/haya14busa/action-bumpr)

Enforce Java code quality standards in your pull requests with automated [Checkstyle](https://github.com/checkstyle/checkstyle) analysis.  
Powered by [reviewdog](https://github.com/reviewdog/reviewdog), this action reports violations directly in your PR reviews, making it easy to maintain consistent code style across your team.

## Features

- **Zero Configuration** - Works out of the box with Google or Sun coding conventions
- **Flexible Reporting** - Choose between PR comments, checks, or reviews
- **Version Control** - Pin to any Checkstyle version for consistency
- **Custom Rules** - Use your own Checkstyle configuration files
- **Smart Filtering** - Only review changed lines or entire files
- **GitHub Integration** - Native support for GitHub status checks and annotations

## Quick Start

Add this workflow to your repository at `.github/workflows/checkstyle.yml`:

```yaml
name: checkstyle
on: [pull_request]
jobs:
  checkstyle:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v6
      - uses: dbelyaev/action-checkstyle@v3
        with:
          github_token: ${{ secrets.github_token }}
```

That's it! The action will now analyze Java files in every pull request using Google's coding conventions.

## Table of Contents

- [Features](#features)
- [Quick Start](#quick-start)
- [Example](#example)
- [Usage](#usage)
  - [Security Note: Pin by Tag or by Hash?](#security-note-pin-by-tag-or-by-hash)
- [Input Parameters](#input-parameters)
  - [Checkstyle Parameters](#checkstyle-parameters)
    - [`checkstyle_config`](#checkstyle_config)
    - [`checkstyle_version`](#checkstyle_version)
    - [`workdir`](#workdir)
    - [`properties_file`](#properties_file)
  - [Reviewdog Parameters](#reviewdog-parameters)
    - [`github_token`](#github_token)
    - [`reporter`](#reporter)
    - [`level`](#level)
    - [`filter_mode`](#filter_mode)
    - [`fail_level`](#fail_level)
    - [`reviewdog_flags`](#reviewdog_flags)
- [Contributing](#contributing)
- [License](#license)

## Example

An example of how the reported Checkstyle violations will look on a pull request is shown below ([link to example PR](https://github.com/dbelyaev/action-checkstyle-tester/pull/9)):

![PR comment with violation](https://user-images.githubusercontent.com/6915328/149333188-4600a75d-5670-4013-9395-d5852e3c7839.png)

## Usage

```yaml
name: reviewdog
on: [pull_request]
jobs:
  checkstyle:
    name: runner / checkstyle
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v6
      - uses: dbelyaev/action-checkstyle@v3
        with:
          github_token: ${{ secrets.github_token }}
          reporter: github-pr-review
          level: warning
```

### Security Note: Pin by Tag or by Hash?

When using GitHub Actions, you can pin to a specific version in two ways:

#### Pinning by Tag

```yaml
- uses: dbelyaev/action-checkstyle@v3 # pin to the latest major tag
```

```yaml
- uses: dbelyaev/action-checkstyle@v3.4.1 # pin to specific version tag
```

- **Pros**: Convenient, automatically receives updates
- **Cons**: Less secure, as tags can be modified to point to different commits

#### Pinning by Commit SHA

```yaml
- uses: dbelyaev/action-checkstyle@0babcc5b0e55e5a8ab6f8a17134f2d613e2bcdda # v3.0.0
```

- **Pros**: Maximum security, guarantees the exact same code runs every time
- **Cons**: Requires manual updates when new versions are released

#### Best Practice

GitHub [officially recommends](https://docs.github.com/en/actions/security-guides/security-hardening-for-github-actions#using-third-party-actions) pinning actions to a full length commit SHA for production workflows and 3rd party actions to ensure security. For non-critical workflows, major version tags provide a reasonable balance between convenience and safety.

For automated SHA updates, consider using tools like [Dependabot (owned by GitHub)](https://docs.github.com/en/code-security/dependabot/working-with-dependabot/keeping-your-actions-up-to-date-with-dependabot) or [Renovate (owned by mend.io)](https://github.com/apps/renovate) to keep your actions current while maintaining security.

## Input Parameters

### Checkstyle Parameters

- ### `checkstyle_config`  

  Checkstyle configuration specifies which ruleset to apply during the scan.  
  
  There are two built-in configurations:
  - `google_checks.xml` - Configuration for the [Google coding conventions](https://google.github.io/styleguide/javaguide.html)
  - `sun_checks.xml` - Configuration for the [Sun coding conventions](https://www.oracle.com/java/technologies/javase/codeconventions-contents.html)

  It is also possible to supply your custom Checkstyle configuration file located in the same directory.

  **Default:** `google_checks.xml`

  **Example:**

  ```yaml
  name: reviewdog
  on: [pull_request]
  jobs:
    checkstyle:
      name: runner / checkstyle
      runs-on: ubuntu-latest
      steps:
        - uses: actions/checkout@v6
        - uses: dbelyaev/action-checkstyle@v3
          with:
            github_token: ${{ secrets.github_token }}
            reporter: github-pr-review
            checkstyle_config: sun_checks.xml
  ```

  Link to [example PR](https://github.com/dbelyaev/action-checkstyle-tester/pull/10).

- ### `checkstyle_version`

  Checkstyle version to be used during analysis.  

  For a list of available version numbers, go to the [Checkstyle release page](https://github.com/checkstyle/checkstyle/releases/).

  **Important:** This field will always try to follow Checkstyle releases as closely as possible and will use the latest available version by default. If the default preference is not suitable for your project, please pin the needed version using this property.

  **Default:** Latest available version

  **Example:**

  ```yaml
  name: reviewdog
  on: [pull_request]
  jobs:
    checkstyle:
      name: runner / checkstyle
      runs-on: ubuntu-latest
      steps:
        - uses: actions/checkout@v6
        - uses: dbelyaev/action-checkstyle@v3
          with:
            github_token: ${{ secrets.github_token }}
            reporter: github-pr-review
            checkstyle_version: "9.0" # double quotes important here
  ```

- ### `workdir`

  The working directory relative to the root directory.

  **Default:** `'.'` (root)

- ### `properties_file`
  
  Location of the properties file relative to the root directory.  
  
  This file serves as a means to resolve repetitive or predefined values within the checkstyle configuration file.

  **Default:** `''` (empty)

  **Example:**

  ```yaml
  name: reviewdog
  on: [pull_request]
  jobs:
    checkstyle:
      name: runner / checkstyle
      runs-on: ubuntu-latest
      steps:
        - uses: actions/checkout@v6
        - uses: dbelyaev/action-checkstyle@v3
          with:
            github_token: ${{ secrets.github_token }}
            reporter: github-pr-review
            checkstyle_config: ./properties_file/test_checks.xml
            properties_file: ./properties_file/additional.properties
  ```

  Link to [example PR](https://github.com/dbelyaev/action-checkstyle-tester/pull/11).

### Reviewdog Parameters

- ### `reporter`

  Specific reporter to be used for the GitHub results reporting by reviewdog.  

  **Values:** `github-pr-check`, `github-check`, `github-pr-review`

  For more information, check [reviewdog / reporters](https://github.com/reviewdog/reviewdog#reporters) documentation, which includes examples of GitHub reports and descriptions of possible limitations.

  **Default:** `github-pr-check`

- ### `level`

  This flag is used to change report level for the chosen `reporter`.
  
  **Values:** `info`, `warning`, `error`
  
  You can control GitHub status check result with this feature:

  | Level     | GitHub Status |
  | --------- | ------------- |
  | `info`    | neutral       |
  | `warning` | neutral       |
  | `error`   | failure       |

  **Default:** `info`

- ### `filter_mode`

  Filtering mode for the reviewdog command.  

  **Values:** `added`, `diff_context`, `file`, `nofilter`

  For more information, check [reviewdog / filter-mode](https://github.com/reviewdog/reviewdog#filter-mode) documentation.

  **Default:** `added`

- ### `fail_level`

  Controls when reviewdog should return a non-zero exit code to fail your workflow.
  
  **Values:** `none`, `any`, `info`, `warning`, `error`
  
  By default (`none`), reviewdog will exit with code `0` even if it finds errors. Setting this to another value will cause reviewdog to exit with code `1` when it finds issues at or above the specified severity level, which can be used to fail the GitHub workflow.

  **Default:** `none`

- ### `reviewdog_flags`

  Additional reviewdog flags.

  **Default:** `""`

## Contributing

Contributions are welcome! Please see our [Contributing Guide](CONTRIBUTING.md) for details on how to:

- Report bugs and request features
- Submit pull requests
- Follow our code of conduct

We follow the [Contributor Covenant Code of Conduct](CODE_OF_CONDUCT.md).

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

[![FOSSA Status](https://app.fossa.com/api/projects/git%2Bgithub.com%2Fdbelyaev%2Faction-checkstyle.svg?type=large)](https://app.fossa.com/projects/git%2Bgithub.com%2Fdbelyaev%2Faction-checkstyle?ref=badge_large)

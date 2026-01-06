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

Checkstyle violations appear as inline comments on your pull request, making it easy to identify and fix issues:

![PR comment with violation](https://user-images.githubusercontent.com/6915328/149333188-4600a75d-5670-4013-9395-d5852e3c7839.png)

*[View complete example PR](https://github.com/dbelyaev/action-checkstyle-tester/pull/9) with Checkstyle violations and comments*

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

  Specifies which Checkstyle ruleset to apply during analysis.  
  
  Two built-in configurations are available:
  - `google_checks.xml` - [Google Java Style Guide](https://google.github.io/styleguide/javaguide.html) rules
  - `sun_checks.xml` - [Sun Code Conventions](https://www.oracle.com/java/technologies/javase/codeconventions-contents.html) rules

  You can also supply a custom Checkstyle configuration file from your repository. Provide the path relative to the repository root. See the [Checkstyle configuration documentation](https://checkstyle.org/config.html) to learn how to create custom rules.

  > **Note:** If the specified configuration file is not found or contains invalid XML, the workflow will fail with an error message.

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

  *[Example PR](https://github.com/dbelyaev/action-checkstyle-tester/pull/10) demonstrating Sun code conventions configuration*

- ### `checkstyle_version`

  Specifies which Checkstyle version to use for analysis.  

  Browse available versions on the [Checkstyle releases page](https://github.com/checkstyle/checkstyle/releases/).

  > **Important:** By default, this action automatically uses the latest Checkstyle version. New Checkstyle releases may introduce:
  > - New rules that flag previously accepted code
  > - Modified rule behavior causing different violation counts
  > - Deprecated configuration options
  > 
  > **Recommended:** Pin to a specific version in production workflows to ensure consistent and reproducible builds. Update the version intentionally when you're ready to address any new violations.

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
            checkstyle_version: "12.3.0" # use double quotes for version numbers
  ```

- ### `workdir`

  Working directory for Checkstyle analysis, relative to the repository root.

  **Default:** `'.'` (root)

- ### `properties_file`
  
  Path to a properties file (relative to repository root) for defining variables used in your Checkstyle configuration.  
  
  Use this to avoid repetition and centralize configuration values. The properties file should use standard [Java properties format](https://docs.oracle.com/javase/tutorial/essential/environment/properties.html) (`key=value`).

  > **Note:** If the specified file is not found, the workflow will fail. Referenced properties in the config file must exist in the properties file, or Checkstyle will report an error.

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

  *[Example PR](https://github.com/dbelyaev/action-checkstyle-tester/pull/11) demonstrating properties file usage with custom configuration*

### Reviewdog Parameters

- ### `reporter`

  Determines how reviewdog reports Checkstyle violations in GitHub.  

  **Values:** `github-pr-check`, `github-check`, `github-pr-review`

  See the [reviewdog reporters documentation](https://github.com/reviewdog/reviewdog#reporters) for detailed examples, screenshots, and permission requirements for each reporter type.

  **Default:** `github-pr-check`

- ### `level`

  Sets the severity level for reported violations, affecting GitHub status check results.
  
  **Values:** `info`, `warning`, `error`
  
  Control GitHub status check behavior:

  | Level     | GitHub Status |
  | --------- | ------------- |
  | `info`    | neutral       |
  | `warning` | neutral       |
  | `error`   | failure       |

  **Default:** `info`

- ### `filter_mode`

  Filtering mode for the reviewdog command.  

  **Values:** `added`, `diff_context`, `file`, `nofilter`

  See the [reviewdog filter-mode documentation](https://github.com/reviewdog/reviewdog#filter-mode) for detailed explanations of when to use each filtering mode.

  **Default:** `added`

- ### `fail_level`

  Determines when reviewdog exits with a non-zero code, failing the workflow.
  
  **Values:** `none`, `any`, `info`, `warning`, `error`
  
  By default (`none`), reviewdog exits with code `0` even when violations exist. Set this to fail your workflow when violations at or above the specified severity level are found.

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

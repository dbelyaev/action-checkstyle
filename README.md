# Checkstyle for Java GitHub Action

[![Test](https://github.com/dbelyaev/action-checkstyle/workflows/Test/badge.svg)](https://github.com/dbelyaev/action-checkstyle/actions?query=workflow%3ATest)
[![reviewdog](https://github.com/dbelyaev/action-checkstyle/workflows/reviewdog/badge.svg)](https://github.com/dbelyaev/action-checkstyle/actions?query=workflow%3Areviewdog)
[![depup](https://github.com/dbelyaev/action-checkstyle/workflows/depup/badge.svg)](https://github.com/dbelyaev/action-checkstyle/actions?query=workflow%3Adepup)
[![release](https://github.com/dbelyaev/action-checkstyle/workflows/release/badge.svg)](https://github.com/dbelyaev/action-checkstyle/actions?query=workflow%3Arelease)
[![action-bumpr supported](https://img.shields.io/badge/bumpr-supported-ff69b4?logo=github&link=https://github.com/haya14busa/action-bumpr)](https://github.com/haya14busa/action-bumpr)

[![GitHub release (latest SemVer)](https://img.shields.io/github/v/release/dbelyaev/action-checkstyle?logo=github&sort=semver)](https://github.com/dbelyaev/action-checkstyle/releases)
[![OpenSSF Scorecard](https://api.securityscorecards.dev/projects/github.com/dbelyaev/action-checkstyle/badge)](https://securityscorecards.dev/viewer/?uri=github.com/dbelyaev/action-checkstyle)
[![Contributor Covenant](https://img.shields.io/badge/Contributor%20Covenant-2.1-4baaaa.svg)](CODE_OF_CONDUCT.md)

This is a GitHub action to run [Checkstyle](https://github.com/checkstyle/checkstyle) checks on your Java code and report the status via [reviewdog](https://github.com/reviewdog/reviewdog) on pull requests.

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
      - uses: actions/checkout@v4
      - uses: dbelyaev/action-checkstyle@master
        with:
          github_token: ${{ secrets.github_token }}
          reporter: github-pr-review
          level: warning
```

## Input parameters

### Checkstyle parameters

* ### `checkstyle_config`  

  Checkstyle configuration specifies which ruleset to apply during the scan.  
  There are two built-in configurations:
  * `google_checks.xml`
config for the [Google coding conventions](https://google.github.io/styleguide/javaguide.html)
  * `sun_checks.xml`
config for the [Sun coding conventions](https://www.oracle.com/java/technologies/javase/codeconventions-contents.html)

  It is also possible to supply your custom Checkstyle configuration file located in the same directory.

  **`Default:`**  `google_checks.xml`

  **`Example:`**

  ```yaml
  name: reviewdog
  on: [pull_request]
  jobs:
    checkstyle:
      name: runner / checkstyle
      runs-on: ubuntu-latest
      steps:
        - uses: actions/checkout@v4
        - uses: dbelyaev/action-checkstyle@master
          with:
            github_token: ${{ secrets.github_token }}
            reporter: github-pr-review
            checkstyle_config: sun_checks.xml
  ```

  Link to [example PR](https://github.com/dbelyaev/action-checkstyle-tester/pull/10).

* ### `checkstyle_version`

  Checkstyle version to be used during analysis.  

  For a list of available version numbers, go to the [Checkstyle release page](https://github.com/checkstyle/checkstyle/releases/).

  >[!IMPORTANT]
  > This field will always try to follow Checkstyle releases as closely as possible and will use the latest available version by default.  
  >
  > If the default preference is not suitable for your project, please pin the needed version using this property.

  **`Default:`** latest available

  **`Example:`**

  ```yaml
  name: reviewdog
  on: [pull_request]
  jobs:
    checkstyle:
      name: runner / checkstyle
      runs-on: ubuntu-latest
      steps:
        - uses: actions/checkout@v4
        - uses: dbelyaev/action-checkstyle@master
          with:
            github_token: ${{ secrets.github_token }}
            reporter: github-pr-review
            checkstyle_version: "9.0" # double quotes important here
  ```

* ### `workdir`

  The working directory relative to the root directory.

  **`Default:`** `'.'` (root)

* ### `properties_file`
  
  Location of the properties file relative to the root directory.  
  
  This file serves as a means to resolve repetitive or predefined values within the checkstyle configuration file.

  **`Default:`** `''` (empty)

  **`Example:`**

  ```yaml
  name: reviewdog
  on: [pull_request]
  jobs:
    checkstyle:
      name: runner / checkstyle
      runs-on: ubuntu-latest
      steps:
        - uses: actions/checkout@v4
        - uses: dbelyaev/action-checkstyle@master
          with:
            github_token: ${{ secrets.github_token }}
            reporter: github-pr-review
            checkstyle_config: ./properties_file/test_checks.xml
            properties_file: ./properties_file/additional.properties
  ```

  Link to [example PR](https://github.com/dbelyaev/action-checkstyle-tester/pull/11).

### Reviewdog parameters

* ### `level`

  Report level for the reviewdog command.
  
  **`Values:`** `[info, warning, error]`
  
  You can control GitHub status check result with this feature.

  | Level     | GitHub Status |
  | --------- | ------------- |
  | `info`    | neutral       |
  | `warning` | neutral       |
  | `error`   | failure       |

  **`Default:`** `info`

* ### `reporter`

  Reporter for the reviewdog command.  

  For more information, check [reviewdog / reporters](https://github.com/reviewdog/reviewdog#reporters) documentation.

  **`Values:`** `[github-pr-check, github-check, github-pr-review]`

  **`Default:`** `github-pr-check`

* ### `filter_mode`

  Filtering mode for the reviewdog command.  

  For more information, check [reviewdog / filter-mode](https://github.com/reviewdog/reviewdog#filter-mode) documentation.

  **`Values:`** `[added, diff_context, file, nofilter]`

  **`Default:`** `added`

* ### `fail_on_error`

  Exit code for reviewdog when errors are found.

  **`Values:`** `[true, false]`

  **`Default:`** `false`

* ### `reviewdog_flags`

  Additional reviewdog flags.

  **`Default:`** ``

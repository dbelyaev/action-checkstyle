# Checkstyle for Java GitHub Action

[![Test](https://github.com/dbelyaev/action-checkstyle/workflows/Test/badge.svg)](https://github.com/dbelyaev/action-checkstyle/actions?query=workflow%3ATest)
[![reviewdog](https://github.com/dbelyaev/action-checkstyle/workflows/reviewdog/badge.svg)](https://github.com/dbelyaev/action-checkstyle/actions?query=workflow%3Areviewdog)
[![depup](https://github.com/dbelyaev/action-checkstyle/workflows/depup/badge.svg)](https://github.com/dbelyaev/action-checkstyle/actions?query=workflow%3Adepup)
[![release](https://github.com/dbelyaev/action-checkstyle/workflows/release/badge.svg)](https://github.com/dbelyaev/action-checkstyle/actions?query=workflow%3Arelease)
[![GitHub release (latest SemVer)](https://img.shields.io/github/v/release/dbelyaev/action-checkstyle?logo=github&sort=semver)](https://github.com/dbelyaev/action-checkstyle/releases)
[![action-bumpr supported](https://img.shields.io/badge/bumpr-supported-ff69b4?logo=github&link=https://github.com/haya14busa/action-bumpr)](https://github.com/haya14busa/action-bumpr)

This is a GitHub action to run [Checkstyle](https://github.com/checkstyle/checkstyle) check on your Java code and report status via [reviewdog](https://github.com/reviewdog/reviewdog) on pull request.

## Example

An example of how the reported checkstyle violations will look like on pull request is shown below ([link to PR](https://github.com/dbelyaev/action-checkstyle-tester/pull/1)):

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
      - uses: actions/checkout@v3
      - uses: dbelyaev/action-checkstyle@v0.7.4
        with:
          github_token: ${{ secrets.github_token }}
          reporter: github-pr-review
          level: warning
```

## Input parameters

* ### `checkstyle_config`  

  Checkstyle configuration specifies which ruleset to apply during the scan.  
  There are two built-in configurations:
  * `google_checks.xml` 
config for the [Google coding conventions](https://google.github.io/styleguide/javaguide.html)
  * `sun_checks.xml`
config for the [Sun coding conventions](https://www.oracle.com/java/technologies/javase/codeconventions-contents.html)

  It is also possible to supply your custom Checkstyle configuration file located in the same directory.

  **`Default:`**  `google_checks.xml`

* ### `checkstyle_version`

  Checkstyle version to be used during analysis.  
  For a list of available version numbers go to [Checkstyle release page](https://github.com/checkstyle/checkstyle/releases/).

    **IMPORTANT NOTE**
  This field will always try to follow Checkstyle releases as close as possible and will use the latest available by default.
  If it is not a default preference for your project, please, pin the needed version using this property.

  **`Default:`** `10.9.3`

* ### `workdir`

  Working directory relative to the root directory.

  **`Default:`** `.`

* ### `level`

  Report level for reviewdog.
  
  **`Values:`** `[info, warning, error]`
  
  You can control GitHub status check result with this feature.

  | Level     | GitHub Status |
  | --------- | ------------- |
  | `info`    | neutral       |
  | `warning` | neutral       |
  | `error`   | failure       |

  **`Default:`** `info`

* ### `reporter`

  Reporter of reviewdog command.  
  See more in reviewdog documentation: https://github.com/reviewdog/reviewdog#reporters

  **`Values:`** `[github-pr-check, github-check, github-pr-review]`

  **`Default:`** `github-pr-check`

* ### `filter_mode`

  Filtering mode for the reviewdog command.  
  See more in reviewdog documentation: https://github.com/reviewdog/reviewdog#filter-mode

  **`Values:`** `[added, diff_context, file, nofilter]`

  **`Default:`** `added`

* ### `fail_on_error`

  Exit code for reviewdog when errors are found.

  **`Values:`** `[true, false]`

  **`Default:`** `false`

* ### `reviewdog_flags`

  Additional reviewdog flags.

  **`Default:`** ``

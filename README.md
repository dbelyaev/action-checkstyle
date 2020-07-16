# Checkstyle for Java GitHub Action

[![Test](https://github.com/dbelyaev/action-checkstyle/workflows/Test/badge.svg)](https://github.com/dbelyaev/action-checkstyle/actions?query=workflow%3ATest)
[![reviewdog](https://github.com/dbelyaev/action-checkstyle/workflows/reviewdog/badge.svg)](https://github.com/dbelyaev/action-checkstyle/actions?query=workflow%3Areviewdog)
[![depup](https://github.com/dbelyaev/action-checkstyle/workflows/depup/badge.svg)](https://github.com/dbelyaev/action-checkstyle/actions?query=workflow%3Adepup)
[![release](https://github.com/dbelyaev/action-checkstyle/workflows/release/badge.svg)](https://github.com/dbelyaev/action-checkstyle/actions?query=workflow%3Arelease)
[![GitHub release (latest SemVer)](https://img.shields.io/github/v/release/dbelyaev/action-checkstyle?logo=github&sort=semver)](https://github.com/dbelyaev/action-checkstyle/releases)
[![action-bumpr supported](https://img.shields.io/badge/bumpr-supported-ff69b4?logo=github&link=https://github.com/haya14busa/action-bumpr)](https://github.com/haya14busa/action-bumpr)

This is a GitHub action to run [Checkstyle](https://github.com/checkstyle/checkstyle) check on your Java code and report status via [reviewdog](https://github.com/reviewdog/reviewdog) on pull request.

## Input

```yaml
inputs:
  github_token:
    description: 'GITHUB_TOKEN'
    default: '${{ github.token }}'
  workdir:
    description: 'Working directory relative to the root directory.'
    default: '.'
  ### Flags for reviewdog ###
  level:
    description: 'Report level for reviewdog [info,warning,error]'
    default: 'info'
  reporter:
    description: 'Reporter of reviewdog command [github-pr-check,github-pr-review].'
    default: 'github-pr-check'
  filter_mode:
    description: |
      Filtering mode for the reviewdog command [added,diff_context,file,nofilter].
      Default is added.
    default: 'added'
  fail_on_error:
    description: |
      Exit code for reviewdog when errors are found [true,false]
      Default is `false`.
    default: 'false'
  reviewdog_flags:
    description: 'Additional reviewdog flags'
    default: ''
  ### Flags for checkstyle ###
  checkstyle_config:
    description: |
      Checkstyle configuration specifies which ruleset to apply during scan.
      There are two built-in configurations in checkstyle: [google_checks.xml,sun_checks.xml].
      google_checks.xml configures Checkstyle for the Google coding conventions (https://google.github.io/styleguide/javaguide.html)
      sun_checks.xml configures Checkstyle for the Sun coding conventions (https://www.oracle.com/java/technologies/javase/codeconventions-contents.html)
    required: true
    default: 'google_checks.xml'
```

## Usage

```yaml
name: reviewdog
on: [pull_request]
jobs:
  checkstyle:
    name: runner / checkstyle
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - uses: dbelyaev/action-checkstyle@master
        with:
          github_token: ${{ secrets.github_token }}
          # Change reviewdog reporter if you need [github-pr-check,github-check,github-pr-review].
          reporter: github-pr-review
          # Change reporter level if you need [info,warning,error].
          # GitHub Status Check won't become failure with warning.
          level: ewarning
```

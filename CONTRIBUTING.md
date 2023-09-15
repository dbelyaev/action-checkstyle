# Contribution Guide

## How to Start contributing

Welcome! We are delighted that you want to contribute to our project! 💖

This project accepts contributions via GitHub pull requests.

This document outlines the process to help ensure your contribution is accepted.

There are several ways to contribute:

* Suggest [features](https://github.com/equinor/oilmod1-code-style/issues/new?assignees=&labels=type%3A+%3Abulb%3A+feature+request&template=feature-request.md&title=)
* Suggest [changes](https://github.com/equinor/oilmod1-code-style/issues/new?assignees=&labels=type%3A+%3Awrench%3A+maintenance&template=code-maintenance.md&title=)
* Report [bugs](https://github.com/equinor/oilmod1-code-style/issues/new?assignees=&labels=type%3A+%3Abug+bug&template=bug-report.md&title=)

## How to contribute your changes via PR

In general, we follow [Work and Pull Request Workflow](https://github.com/susam/gitpr).

Here's a quick guide:

1. Create your fork of the repository.
1. Clone the project to your machine.
1. To keep track of the original repository add another remote named "upstream".

    ```shell
    git remote add upstream git@github.com:equinor/oilmod1-code-style.git
    ```

1. Create a branch locally with a succinct but descriptive name, prefixed with change type.

    ```shell
    git checkout -b feature/my-new-feature
    ```

1. Make the changes in the created branch.
1. Add the changed files.

    ```shell
    git add path/to/filename
    ```

1. Commit your changes using the [conventional commits](https://www.conventionalcommits.org/en/v1.0.0/) formatting for the commit messages.

    ```shell
    git commit -m "conventional commit formatted message"
    ```

1. Before sending the pull request, make sure to rebase onto the upstream source. This ensures your code is based on the latest available code.

    ```shell
    git fetch upstream
    git rebase upstream/main
    ```

1. Push to your fork.

    ```shell
    git push origin feature/my-new-feature
    ```

1. Submit a pull request to the original repository via GitHub interface.  
    * Please provide us with some explanation of why you made the changes you made.  
    * For new features make sure to explain a standard use case to us.

That's it... thank you for your contribution!

After your pull request is merged, you can safely delete your branch.

## Code review process

The core team regularly reviews pull requests.

After feedback has been provided, we expect responses within three weeks.

If there is no activity on the pull request after three weeks, we may consider closing it.

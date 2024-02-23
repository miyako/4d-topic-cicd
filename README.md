![version](https://img.shields.io/badge/version-20%2B-E23089)
![platform](https://img.shields.io/static/v1?label=platform&message=mac-intel%20|%20mac-arm%20|%20win-64&color=blue)
[![license](https://img.shields.io/github/license/miyako/4d-topic-cicd)](LICENSE)
![downloads](https://img.shields.io/github/downloads/miyako/4d-topic-cicd/total)

# workflows

## [Test](https://github.com/miyako/4d-topic-cicd/blob/main/.github/workflows/test.yml)

* trigger: any time there is a push to the `main` branch, or manually
* runners: github hosted `macos-latest` and/or `windows-latest`
* always use the latest `tool4d`

## Build 

* trigger: any time there is a push to the `main` branch, or manually
* runners: self-hosted, `macOS`
* when triggered automatically, sign to run locally for testing
* when triggered manually, sign for distribtuion, notarise, staple

### 資料

* [セルフホステッド ランナーの概要](https://docs.github.com/ja/actions/hosting-your-own-runners/managing-self-hosted-runners/about-self-hosted-runners)
* [セルフホステッド ランナーを追加する](https://docs.github.com/ja/actions/hosting-your-own-runners/managing-self-hosted-runners/adding-self-hosted-runners)
* [セルフホストランナーアプリケーションをサービスとして設定する](https://docs.github.com/ja/actions/hosting-your-own-runners/managing-self-hosted-runners/configuring-the-self-hosted-runner-application-as-a-service?platform=mac)

* [A Tool for 4D Code Execution in CLI](https://blog.4d.com/a-tool-for-4d-code-execution-in-cli/)

* [Workflow syntax for GitHub Actions](https://docs.github.com/en/actions/using-workflows/workflow-syntax-for-github-actions#jobsjob_idif)
* [Automatic token authentication](https://docs.github.com/en/actions/security-guides/automatic-token-authentication)
* [Contexts](https://docs.github.com/en/actions/learn-github-actions/contexts)
* [Variables](https://docs.github.com/en/actions/learn-github-actions/variables)
* [Expressions](https://docs.github.com/en/actions/learn-github-actions/expressions)
* [Workflow commands for GitHub Actions](https://docs.github.com/en/actions/using-workflows/workflow-commands-for-github-actions#environment-files)

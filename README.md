# .workflows

Reusable GitHub Actions workflows called by every `tekalib` repository, and by the `brei0x`
repositories that follow the same flow. Public on purpose: a reusable workflow in a private
repository can only be called by private repositories of the same owner, so neither a public
repository nor another account could call it. Nothing here is secret; the App key stays in an
environment of each caller.

<p align="center">
  <a href="https://github.com/tekalib/.workflows/actions/workflows/ci.yml"><img src="https://github.com/tekalib/.workflows/actions/workflows/ci.yml/badge.svg?branch=main" alt="CI"></a>
  <a href="https://github.com/tekalib/.workflows/releases/latest"><img src="https://img.shields.io/github/v/release/tekalib/.workflows?sort=semver&label=release&labelColor=24292e&logo=data:image/svg%2Bxml;base64,PHN2ZyBmaWxsPSIjOTU5ZGE1IiB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHdpZHRoPSIxNiIgaGVpZ2h0PSIxNiIgdmlld0JveD0iMCAwIDE2IDE2Ij48cGF0aCBkPSJNMSA3Ljc3NVYyLjc1QzEgMS43ODQgMS43ODQgMSAyLjc1IDFoNS4wMjVjLjQ2NCAwIC45MS4xODQgMS4yMzguNTEzbDYuMjUgNi4yNWExLjc1IDEuNzUgMCAwIDEgMCAyLjQ3NGwtNS4wMjYgNS4wMjZhMS43NSAxLjc1IDAgMCAxLTIuNDc0IDBsLTYuMjUtNi4yNUExLjc1MiAxLjc1MiAwIDAgMSAxIDcuNzc1Wm0xLjUgMGMwIC4wNjYuMDI2LjEzLjA3My4xNzdsNi4yNSA2LjI1YS4yNS4yNSAwIDAgMCAuMzU0IDBsNS4wMjUtNS4wMjVhLjI1LjI1IDAgMCAwIDAtLjM1NGwtNi4yNS02LjI1YS4yNS4yNSAwIDAgMC0uMTc3LS4wNzNIMi43NWEuMjUuMjUgMCAwIDAtLjI1LjI1Wk02IDVhMSAxIDAgMSAxIDAgMiAxIDEgMCAwIDEgMC0yWiIvPjwvc3ZnPg%3D%3D" alt="Latest release"></a>
  <a href="https://github.com/tekalib/.workflows/blob/main/LICENSE"><img src="https://img.shields.io/github/license/tekalib/.workflows?labelColor=24292e&logo=data:image/svg%2Bxml;base64,PHN2ZyBmaWxsPSIjOTU5ZGE1IiB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHdpZHRoPSIxNiIgaGVpZ2h0PSIxNiIgdmlld0JveD0iMCAwIDE2IDE2Ij48cGF0aCBkPSJNOC43NS43NVYyaC45ODVjLjMwNCAwIC42MDMuMDguODY3LjIzMWwxLjI5LjczNmMuMDM4LjAyMi4wOC4wMzMuMTI0LjAzM2gyLjIzNGEuNzUuNzUgMCAwIDEgMCAxLjVoLS40MjdsMi4xMTEgNC42OTJhLjc1Ljc1IDAgMCAxLS4xNTQuODM4bC0uNTMtLjUzLjUyOS41MzEtLjAwMS4wMDItLjAwMi4wMDItLjAwNi4wMDYtLjAwNi4wMDUtLjAxLjAxLS4wNDUuMDRjLS4yMS4xNzYtLjQ0MS4zMjctLjY4Ni40NUMxNC41NTYgMTAuNzggMTMuODggMTEgMTMgMTFhNC40OTggNC40OTggMCAwIDEtMi4wMjMtLjQ1NCAzLjU0NCAzLjU0NCAwIDAgMS0uNjg2LS40NWwtLjA0NS0uMDQtLjAxNi0uMDE1LS4wMDYtLjAwNi0uMDA0LS4wMDR2LS4wMDFhLjc1Ljc1IDAgMCAxLS4xNTQtLjgzOEwxMi4xNzggNC41aC0uMTYyYy0uMzA1IDAtLjYwNC0uMDc5LS44NjgtLjIzMWwtMS4yOS0uNzM2YS4yNDUuMjQ1IDAgMCAwLS4xMjQtLjAzM0g4Ljc1VjEzaDIuNWEuNzUuNzUgMCAwIDEgMCAxLjVoLTYuNWEuNzUuNzUgMCAwIDEgMC0xLjVoMi41VjMuNWgtLjk4NGEuMjQ1LjI0NSAwIDAgMC0uMTI0LjAzM2wtMS4yODkuNzM3Yy0uMjY1LjE1LS41NjQuMjMtLjg2OS4yM2gtLjE2MmwyLjExMiA0LjY5MmEuNzUuNzUgMCAwIDEtLjE1NC44MzhsLS41My0uNTMuNTI5LjUzMS0uMDAxLjAwMi0uMDAyLjAwMi0uMDA2LjAwNi0uMDE2LjAxNS0uMDQ1LjA0Yy0uMjEuMTc2LS40NDEuMzI3LS42ODYuNDVDNC41NTYgMTAuNzggMy44OCAxMSAzIDExYTQuNDk4IDQuNDk4IDAgMCAxLTIuMDIzLS40NTQgMy41NDQgMy41NDQgMCAwIDEtLjY4Ni0uNDVsLS4wNDUtLjA0LS4wMTYtLjAxNS0uMDA2LS4wMDYtLjAwNC0uMDA0di0uMDAxYS43NS43NSAwIDAgMS0uMTU0LS44MzhMMi4xNzggNC41SDEuNzVhLjc1Ljc1IDAgMCAxIDAtMS41aDIuMjM0YS4yNDkuMjQ5IDAgMCAwIC4xMjUtLjAzM2wxLjI4OC0uNzM3Yy4yNjUtLjE1LjU2NC0uMjMuODY5LS4yM2guOTg0Vi43NWEuNzUuNzUgMCAwIDEgMS41IDBabTIuOTQ1IDguNDc3Yy4yODUuMTM1LjcxOC4yNzMgMS4zMDUuMjczczEuMDItLjEzOCAxLjMwNS0uMjczTDEzIDYuMzI3Wm0tMTAgMGMuMjg1LjEzNS43MTguMjczIDEuMzA1LjI3M3MxLjAyLS4xMzggMS4zMDUtLjI3M0wzIDYuMzI3WiIvPjwvc3ZnPg%3D%3D" alt="License"></a>
</p>

---

The rules both accounts follow, from branches and CI to how a version is computed, are written
once, in [`docs/REFERENCE.md`](docs/REFERENCE.md): the manuals of both accounts link there.

## Workflows

| File                       | Called from                                         | Does                                                       |
| -------------------------- | --------------------------------------------------- | ---------------------------------------------------------- |
| `release.yml`              | a job after the production deploy, or after CI on `main` | next version from the Conventional Commits ([rules](docs/REFERENCE.md#versioning)), tag, release whose "What's Changed" groups the commits (Breaking changes, Features, Fixes, Other) |
| `dependabot-automerge.yml` | `pull_request_target`, on Dependabot pull requests   | arms GitHub's auto-merge (squash) on a patch or minor with the App token, so it merges once the required check is green, only while the pull request holds Dependabot's single commit; on a major or an update of unknown type, requests the maintainer's review, assigns them and trims the body to one line per dependency, Dependabot's changelog kept as a comment; an update it will not merge (ecosystem not allowed, no required check) gets the same review request and assignment |
| `back-merge.yml`           | a push to `main`, in repositories with `develop`     | merges `main` into `develop` with the App token            |
| `promote.yml`              | `workflow_dispatch`, in repositories with `develop`  | fast-forwards `main` to a `develop` whose CI is green      |
| `issues.yml`               | pull requests into `develop`, issue close/reopen     | links and closes the issue named by the branch; stamps the completed date in an organization |

Every write to a branch goes through the caller's automation GitHub App (`tekalib-automation`,
`brei0x-automation`), never `GITHUB_TOKEN`: a push or a merge made with `GITHUB_TOKEN` starts no
workflow, and it may not touch `.github/workflows/`. The three jobs that mint the App token run
in the caller's `automation` environment, which only `main` may use: a workflow on any other
branch cannot read the key.

## Calling one

A caller's `.github/workflows/automerge.yml`, whole:

```yaml
name: Dependabot auto-merge

on:
  pull_request_target: # zizmor: ignore[dangerous-triggers] no code of the pull request is checked out or run
    branches: [main]

permissions:
  contents: read

jobs:
  automerge:
    if: github.event.pull_request.user.login == 'dependabot[bot]'
    uses: tekalib/.workflows/.github/workflows/dependabot-automerge.yml@<commit SHA> # vX.Y.Z
    permissions:
      contents: read
      pull-requests: read
    secrets:
      AUTOMATION_APP_KEY: ${{ secrets.AUTOMATION_APP_KEY }}
```

`pull_request_target`, not `pull_request`: the run then belongs to `main`, so the environment
lets it in, it reads Actions secrets although Dependabot opened the pull request, and its
workflow is the one on `main`, not the one of the pull request. `back-merge.yml` and
`promote.yml` take the same `secrets:` block and nothing else. The secret is passed by name
though it exists only in the environment: without that line it resolves to an empty string in
the called job. `secrets: inherit` would do the same inside `tekalib`, not from another account.

The job merges nothing itself: it arms auto-merge, and GitHub merges when the required
`CI passed` check turns green. Where the base branch requires no status check, auto-merge would
not wait for CI, so the job hands the pull request to the maintainer, as it does for an
ecosystem the caller does not allow. Only an update Dependabot
declares a patch or a minor is armed: any other type, a missing one included, is flagged like a
major, CI green or not. The job skips a pull request that holds more than Dependabot's one commit
(a pushed fix, an "Update branch" merge): a human merges that one.

Every job runs on `ubuntu-slim`: they only call `git`, `gh` and `jq`, and a 1 vCPU minute costs a
third of a standard one in a private caller.

Pin the commit SHA of a release, its tag in a comment: a tag can be moved, a SHA cannot.
Dependabot's `github-actions` ecosystem bumps both like any action, with no cooldown (callers
exclude `tekalib/.workflows*` from it), and the caller's auto-merge takes patch and minor bumps. A change that breaks a caller (an input
renamed, a secret added) is a major: `feat!:` in the pull request title.

## Requirements in the caller

- The owner's own App, private and installed on the caller, with Contents, Pull requests and
  Workflows read/write.
- An `automation` environment whose deployment branches are the name pattern `main`, never
  "protected branches only": that option ignores rulesets and then admits every branch. It
  holds the secret `AUTOMATION_APP_KEY`. No copy of the key anywhere else: not in the
  repository, organization or Dependabot secrets.
- The variable `AUTOMATION_CLIENT_ID`, the App's public Client ID: once per organization, or
  per repository on a personal account, which has no account-level variable.
- For `dependabot-automerge.yml`: auto-merge allowed, and a required status check on `main`.
- For `back-merge.yml` and `promote.yml`: the App in the bypass list of the owner's Trunk
  Merge Flow ruleset.

## Developing

`ci.yml` runs actionlint and `tests/release-test.sh`, which runs the version and notes block of
`release.yml` as is. Like `automerge.yml`, it calls the workflows of this very repository by
path, so a change runs here before any caller pins it. `release.yml` tags `main` after a green CI
only when one of the five reusable workflows changed: every caller adopts a release within a
day, and a site that adopts one redeploys production.

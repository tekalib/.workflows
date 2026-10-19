# .workflows

Reusable GitHub Actions workflows called by every `tekalib` repository, and by the `brei0x`
repositories that follow the same flow. Public on purpose: a reusable workflow in a private
repository can only be called by private repositories of the same owner. Nothing here is
secret; the App key travels from each caller as a secret.

## Workflows

| File                       | Called from                                         | Does                                                       |
| -------------------------- | --------------------------------------------------- | ---------------------------------------------------------- |
| `release.yml`              | a job after the production deploy, or after CI on `main` | next version from the Conventional Commits, tag, release whose "What's Changed" groups the commits (Breaking changes, Features, Fixes, Other) |
| `dependabot-automerge.yml` | the last job of CI, on Dependabot pull requests      | squash-merges patch and minor updates with the App token   |
| `back-merge.yml`           | a push to `main`, in repositories with `develop`     | merges `main` into `develop` with the App token            |
| `promote.yml`              | `workflow_dispatch`, in repositories with `develop`  | fast-forwards `main` to a `develop` whose CI is green      |
| `issues.yml`               | pull requests into `develop`, issue close/reopen     | links and closes the issue named by the branch             |

Every write goes through the `tekalib-automation` GitHub App, never `GITHUB_TOKEN`: a push or a
merge made with `GITHUB_TOKEN` starts no workflow, and it may not touch `.github/workflows/`.

## Calling one

```yaml
  automerge:
    needs: [verify]
    if: github.event_name == 'pull_request' && github.event.pull_request.user.login == 'dependabot[bot]'
    uses: tekalib/.workflows/.github/workflows/dependabot-automerge.yml@<commit SHA> # v1.0.1
    permissions:
      contents: read
      pull-requests: read
    secrets:
      app-key: ${{ secrets.AUTOMATION_APP_KEY }}
```

Pin the commit SHA of a release, its tag in a comment: a tag can be moved, a SHA cannot.
Dependabot's `github-actions` ecosystem bumps both like any action, with no cooldown (callers
exclude `tekalib/.workflows*` from it), and the caller's auto-merge takes patch and minor bumps. A change that breaks a caller (an input
renamed, a secret added) is a major: `feat!:` in the pull request title.

## Requirements in the caller

- The App installed on the caller's owner (`tekalib`, `brei0x`), with Contents, Pull requests
  and Workflows read/write.
- `AUTOMATION_APP_KEY` readable by Actions and by Dependabot: organization secrets for `tekalib`,
  repository secrets elsewhere.
- For `back-merge.yml` and `promote.yml`: the App in the bypass list of the organization's
  Trunk Merge Flow ruleset.

## Developing

`ci.yml` runs actionlint and `tests/release-bump-test.sh`, then calls the workflows of this very
commit by path, so a change runs here before any caller pins it. `release.yml` tags `main` after
a green CI only when one of the five reusable workflows changed: every caller adopts a release
within a day, and a site that adopts one redeploys production.

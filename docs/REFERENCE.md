# Reference

The rules every repository of the `tekalib` organization and of the `brei0x` account follows.
One owner runs both, so there is one rule book, and this is its only written copy. Each
account's private manual holds what differs there and nothing else: how the policy is applied,
its App, its secrets.

## Branches

- **`main`** is production and the default branch, always deployable.
- **`develop`** is for a repository that deploys: pull requests land there first, and it feeds
  the staging environment where one exists. Any other repository may carry one when it needs
  to, as an exception, and then follows the same flow.
- **Nobody pushes to a trunk by hand.** The writers are the merge button and the `back-merge` and
  `promote` workflows.
- **One branch per task**, `<type>/<description>`, ticket number first when there is one:
  `feat/12-oauth-google-login`. Types are the Conventional Commits types plus `hotfix` and
  `release`. The description is `a-z0-9` with single hyphens; `release/vMAJOR.MINOR.PATCH` is
  the only branch allowed a dot. GitHub enforces the prefix, the description format is on you.
- **Bot branches** (`dependabot/…`, `revert-…`) belong to their bots.

## From an issue to production

```
with develop      issue ─► branch ─► PR ─► develop ─► Promote ─► main ─► deploy ─► tag + release
without develop   issue ─► branch ─► PR ─► main ─► tag + release
```

1. **Issue, then branch.** `gh issue develop` creates the branch and its link to the issue.
2. **Pull request** into `develop`, or into `main` where there is no `develop`. Its title is a
   Conventional Commit: it becomes the squash commit, which the [version](#versioning) is
   computed from.
3. **Merge** once `CI passed` is green, or arm it earlier with `gh pr merge --auto --squash`.
4. **Promote**, where there is a `develop`. `promote.yml` checks that CI is green on the head of
   `develop`, then fast-forwards `main` to it, so both trunks are the same commit. Never open a
   pull request from `develop` into `main`: a squash would make the trunks diverge at every
   release.
5. **Release.** The push to `main` deploys production where there is one, then `release.yml`
   tags it and publishes the GitHub release.

What follows from it:

- **Closing the issue.** GitHub honors `Closes #12` only on a pull request into the default
  branch. Into `develop`, `issues.yml` reads the number from the branch name, links the pull
  request and closes the issue on merge.
- **Back-merge.** Dependabot targets `main`, because a security update must reach production at
  once. `back-merge.yml` merges every push to `main` into `develop` within seconds. A conflict
  fails the job and leaves `develop` untouched; until someone resolves it, `promote.yml` is
  rejected.
- **`workflow_run` trap.** `deploy.yml` fires on `workflow_run`, which always runs the copy on
  the default branch: a change to it merged into `develop` does nothing until it is promoted.

## CI

- **One required check, `CI passed`.** Every `ci.yml` ends with that job. It needs every other
  job and runs `if: always()`, because a job skipped after a failed need would report success.
  The merge ruleset requires that single name, so job names can change without touching a
  ruleset. A repository whose CI lacks it merges only through a bypass.
- **CI runs on pull requests and on every push to a trunk.** `promote.yml` reads the run on
  `develop`; the deploy and the release follow the run on `main`.
- **Job names** read `<Category> (<what it runs> · …)`, the category one of `Checks` (several
  fast checks in one job), `Lint`, `Tests`, `E2E tests` or `Build`: the checks list says who
  does what without opening a log.
- **Cost.** Every GitHub-hosted job bills at least one minute, so a check that takes seconds is
  a step of an existing job. A job that only reads its needs or calls `gh`, `git` and `jq` runs
  on `ubuntu-slim`, a third of the cost of `ubuntu-latest`.

## Dependencies

- **Pinning.** Every `uses:` is a commit SHA with its tag in a comment, because a tag can be
  moved and a SHA cannot. Both accounts enforce it (`sha_pinning_required`), and zizmor must
  report nothing before a workflow change merges.
- **Shared logic.** Every workflow that writes or versions is a thin caller of this repository:
  change the logic here, never in a copy.
- **Dependabot** checks daily at 10:00 Europe/Paris, targets `main` and groups minor and patch
  updates. A third-party release waits a 7-day cooldown; this repository is ours and skips it.
- **A patch or a minor merges itself.** `automerge.yml` arms GitHub's auto-merge, and GitHub
  squash-merges once `CI passed` is green, as long as the pull request still holds Dependabot's
  single commit.
- **A major waits for a human**, and so does an update whose type Dependabot does not state:
  review requested, pull request assigned, body trimmed to one line per dependency.

## Policy

Every repository gets the same settings, applied by the `policy/apply.sh` of its owner's private
manual. Never change one in the GitHub UI: the next run overwrites it.

| Area        | Setting                                                                                          |
| ----------- | ------------------------------------------------------------------------------------------------ |
| Actions     | SHA pinning, read-only `GITHUB_TOKEN`, no workflow approves a pull request                       |
| Merge       | squash only, title `PR_TITLE`, empty body, auto-merge allowed, branch deleted on merge           |
| Security    | Dependabot alerts and security updates; on public repositories, secret scanning, push protection, private vulnerability reporting and CodeQL |
| Environment | `automation`, open to `main` only                                                                |

| Ruleset                    | Targets                      | Enforces                                                               | Bypass                           |
| -------------------------- | ---------------------------- | ---------------------------------------------------------------------- | -------------------------------- |
| Conventional Branch Naming | all branches                 | creation limited to the allowed prefixes                               | none                             |
| Trunk Protection           | default branch and `develop` | no deletion, no force-push                                             | none                             |
| Trunk Merge Flow           | default branch and `develop` | pull request, squash only, threads resolved, signed, `CI passed` green | the owner's admins, its App      |

Why it is shaped this way:

- **`PR_TITLE` is load-bearing.** GitHub's default takes the commit message when the branch
  holds one commit and the pull request title otherwise, so the version would depend on how the
  branch was committed.
- **Prefixes, not patterns.** `branch_name_pattern` is silently ignored outside GitHub
  Enterprise (tested 2026-09-17), so the naming ruleset blocks creation everywhere and excludes
  the allowed prefixes.
- **Bypass on the merge flow only.** `back-merge` and `promote` push trunks through the App, and
  a back-merge commit is unsigned and has no CI run yet. Admins keep the bypass: discipline
  guards their hand pushes.
- **No required approval.** A solo maintainer cannot approve their own pull request.
- **Branches need not be up to date.** Auto-merge never updates a stale branch, and back-merges
  move `develop` all day: the strict policy would park every pull request.

## The automation App

Each owner has its own private GitHub App, `tekalib-automation` and `brei0x-automation`. Every
write a workflow makes to a trunk goes through it, never `GITHUB_TOKEN`: a push made with
`GITHUB_TOKEN` starts no workflow and may not touch `.github/workflows/`.

- **Scope.** Contents, Pull requests and Workflows read/write and nothing else, installed only
  on the repositories that call a workflow here with it. Each run mints a token for its own
  repository that expires within the hour.
- **One home for the key.** The App bypasses Trunk Merge Flow, so its key can push to `main`. It
  lives in one place per repository, the secret `AUTOMATION_APP_KEY` of the `automation`
  environment, with no copy in repository, organization or Dependabot secrets.
- **A branch cannot read it.** GitHub refuses the environment to a run whose ref is not `main`.
  Back-merge runs on a push to `main`, promote is dispatched from `main`, and the Dependabot
  auto-merge runs on `pull_request_target`, whose ref is the base branch.
- **A name pattern, not "protected branches only".** That option counts classic branch
  protection rules, not rulesets: with rulesets alone it admits every branch (GitHub community
  discussion 132387, read 2026-11-17).

What remains: whoever can merge into `main` can change a workflow there and reach the key. Lose
the key and every promotion, back-merge and Dependabot merge stops.

## Versioning

No file holds the version: the highest `vX.Y.Z` tag reachable from the commit does.
`release.yml` tags after the production deploy, or after CI on `main` where nothing deploys.

**What counts.** Every commit that no version tag contains yet, merge commits left out. When
there is none, a back-merge alone for instance, nothing is released.

**How far to move.** The strongest signal among those commits wins, and lower ranks reset to
zero. The subject decides; with squash merges and `PR_TITLE`, the subject is the pull request
title, so you never choose the number, you write the title.

| Found                                                                                  | Bump      | `1.4.2` becomes | `0.4.2` becomes |
| -------------------------------------------------------------------------------------- | --------- | --------------- | --------------- |
| a `!` right before the `:` of the subject, or a body line starting `BREAKING CHANGE:` | **major** | `2.0.0`         | `0.5.0`         |
| the type `feat`                                                                        | **minor** | `1.5.0`         | `0.5.0`         |
| anything else, a subject that is no Conventional Commit included                       | **patch** | `1.4.3`         | `0.4.3`         |

- **Types ignore case**: `Feat:` is a feature. `BREAKING CHANGE` (or `BREAKING-CHANGE`) must be
  uppercase, as the Conventional Commits specification says.
- **Only the subject sets the type.** A body line starting `feat:`, in a pull request
  description, changes nothing.
- **A squash commit is the pull request title alone**, `<title> (#n)`: the policy of both accounts
  sets an empty squash body, and the description stays on the pull request. A pull request
  therefore declares a breaking change with the `!`.
- **Every change ships.** Unlike the specification, `chore`, `docs` or `ci` still earn a patch: a
  tag identifies what is in production, and a dependency bump changes production.
- **`0.x` never jumps to `1.0.0` on its own.** A breaking change there is a minor, as SemVer
  allows during initial development. `1.0.0` declares a stable API: a person tags it.
- **Only strict `vX.Y.Z` tags count.** A pre-release such as `v1.3.0-rc.1` is ignored.
- **A new repository is tagged by hand** before its second push to `main`: `v1.0.0` in
  production, `v0.1.0` otherwise. Without any tag the first release starts from `v0.0.0`.
- **The notes group the same commits**: Breaking changes, Features, Fixes, Other changes, then a
  compare link to the previous tag.

`tests/release-test.sh` runs the very block of `release.yml` against each of these cases.

## README header

Every repository README starts the same way, in this order: an optional presentation image,
centered, the title, one paragraph saying what the project is and who it is for, then the badges,
centered, then a rule.

```markdown
<p align="center">
  <img src="docs/assets/<presentation>.webp" alt="<What the image shows>" width="100%">
</p>

# <Title>

<One paragraph: what the project is and who it is for.>

<p align="center">
  <a href="https://github.com/<owner>/<repo>/actions/workflows/deploy.yml"><img src="https://github.com/<owner>/<repo>/actions/workflows/deploy.yml/badge.svg?branch=main" alt="Deploy"></a>
  <a href="https://github.com/<owner>/<repo>/releases/latest"><img src="https://img.shields.io/github/v/release/<owner>/<repo>?sort=semver&label=release&labelColor=24292e&logo=<tag-logo>" alt="Latest release"></a>
  <a href="https://github.com/<owner>/<repo>/blob/main/LICENSE"><img src="https://img.shields.io/github/license/<owner>/<repo>?labelColor=24292e&logo=<law-logo>" alt="License"></a>
</p>

---
```

- **The presentation image** is optional: a banner or a social preview, referenced by a relative
  path so it follows the branch. Its `alt` says what it shows. It is 2:1, the ratio of GitHub's
  social preview (1280 × 640), drawn at 2x for the README, so one composition serves both.
- **Every image or video a README shows lives in `docs/assets/`**, the presentation image
  included: never at the root, in `screenshots/` or loose in `docs/`. A generated image has
  rounded corners on a transparent background, so it sits on GitHub's light and dark themes alike.
- **Each badge carries an icon about its subject.** The workflow badges are GitHub's own, with
  their Octocat. The shields.io badges take the GitHub Octicon that GitHub itself shows for the same
  thing (`tag` for Release, `law` for License), filled `#959da5`, on a `24292e` label, so they look
  like GitHub's badges. shields.io only knows Simple Icons by name, so the Octicon goes as a data
  URI; replace `<tag-logo>` and `<law-logo>` with:

  ```text
  <tag-logo>  data:image/svg%2Bxml;base64,PHN2ZyBmaWxsPSIjOTU5ZGE1IiB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHdpZHRoPSIxNiIgaGVpZ2h0PSIxNiIgdmlld0JveD0iMCAwIDE2IDE2Ij48cGF0aCBkPSJNMSA3Ljc3NVYyLjc1QzEgMS43ODQgMS43ODQgMSAyLjc1IDFoNS4wMjVjLjQ2NCAwIC45MS4xODQgMS4yMzguNTEzbDYuMjUgNi4yNWExLjc1IDEuNzUgMCAwIDEgMCAyLjQ3NGwtNS4wMjYgNS4wMjZhMS43NSAxLjc1IDAgMCAxLTIuNDc0IDBsLTYuMjUtNi4yNUExLjc1MiAxLjc1MiAwIDAgMSAxIDcuNzc1Wm0xLjUgMGMwIC4wNjYuMDI2LjEzLjA3My4xNzdsNi4yNSA2LjI1YS4yNS4yNSAwIDAgMCAuMzU0IDBsNS4wMjUtNS4wMjVhLjI1LjI1IDAgMCAwIDAtLjM1NGwtNi4yNS02LjI1YS4yNS4yNSAwIDAgMC0uMTc3LS4wNzNIMi43NWEuMjUuMjUgMCAwIDAtLjI1LjI1Wk02IDVhMSAxIDAgMSAxIDAgMiAxIDEgMCAwIDEgMC0yWiIvPjwvc3ZnPg%3D%3D
  <law-logo>  data:image/svg%2Bxml;base64,PHN2ZyBmaWxsPSIjOTU5ZGE1IiB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHdpZHRoPSIxNiIgaGVpZ2h0PSIxNiIgdmlld0JveD0iMCAwIDE2IDE2Ij48cGF0aCBkPSJNOC43NS43NVYyaC45ODVjLjMwNCAwIC42MDMuMDguODY3LjIzMWwxLjI5LjczNmMuMDM4LjAyMi4wOC4wMzMuMTI0LjAzM2gyLjIzNGEuNzUuNzUgMCAwIDEgMCAxLjVoLS40MjdsMi4xMTEgNC42OTJhLjc1Ljc1IDAgMCAxLS4xNTQuODM4bC0uNTMtLjUzLjUyOS41MzEtLjAwMS4wMDItLjAwMi4wMDItLjAwNi4wMDYtLjAwNi4wMDUtLjAxLjAxLS4wNDUuMDRjLS4yMS4xNzYtLjQ0MS4zMjctLjY4Ni40NUMxNC41NTYgMTAuNzggMTMuODggMTEgMTMgMTFhNC40OTggNC40OTggMCAwIDEtMi4wMjMtLjQ1NCAzLjU0NCAzLjU0NCAwIDAgMS0uNjg2LS40NWwtLjA0NS0uMDQtLjAxNi0uMDE1LS4wMDYtLjAwNi0uMDA0LS4wMDR2LS4wMDFhLjc1Ljc1IDAgMCAxLS4xNTQtLjgzOEwxMi4xNzggNC41aC0uMTYyYy0uMzA1IDAtLjYwNC0uMDc5LS44NjgtLjIzMWwtMS4yOS0uNzM2YS4yNDUuMjQ1IDAgMCAwLS4xMjQtLjAzM0g4Ljc1VjEzaDIuNWEuNzUuNzUgMCAwIDEgMCAxLjVoLTYuNWEuNzUuNzUgMCAwIDEgMC0xLjVoMi41VjMuNWgtLjk4NGEuMjQ1LjI0NSAwIDAgMC0uMTI0LjAzM2wtMS4yODkuNzM3Yy0uMjY1LjE1LS41NjQuMjMtLjg2OS4yM2gtLjE2MmwyLjExMiA0LjY5MmEuNzUuNzUgMCAwIDEtLjE1NC44MzhsLS41My0uNTMuNTI5LjUzMS0uMDAxLjAwMi0uMDAyLjAwMi0uMDA2LjAwNi0uMDE2LjAxNS0uMDQ1LjA0Yy0uMjEuMTc2LS40NDEuMzI3LS42ODYuNDVDNC41NTYgMTAuNzggMy44OCAxMSAzIDExYTQuNDk4IDQuNDk4IDAgMCAxLTIuMDIzLS40NTQgMy41NDQgMy41NDQgMCAwIDEtLjY4Ni0uNDVsLS4wNDUtLjA0LS4wMTYtLjAxNS0uMDA2LS4wMDYtLjAwNC0uMDA0di0uMDAxYS43NS43NSAwIDAgMS0uMTU0LS44MzhMMi4xNzggNC41SDEuNzVhLjc1Ljc1IDAgMCAxIDAtMS41aDIuMjM0YS4yNDkuMjQ5IDAgMCAwIC4xMjUtLjAzM2wxLjI4OC0uNzM3Yy4yNjUtLjE1LjU2NC0uMjMuODY5LS4yM2guOTg0Vi43NWEuNzUuNzUgMCAwIDEgMS41IDBabTIuOTQ1IDguNDc3Yy4yODUuMTM1LjcxOC4yNzMgMS4zMDUuMjczczEuMDItLjEzOCAxLjMwNS0uMjczTDEzIDYuMzI3Wm0tMTAgMGMuMjg1LjEzNS43MTguMjczIDEuMzA1LjI3M3MxLjAyLS4xMzggMS4zMDUtLjI3M0wzIDYuMzI3WiIvPjwvc3ZnPg%3D%3D
  ```

- **The title** is the project's name as people say it; the repository name when it has no
  other.
- **The badges**, only those that apply, in this order: one workflow badge, then Release, then
  License.
- **One workflow badge**, the one that says whether `main` holds: Deploy (`deploy.yml`, ships to
  an environment once CI passed) or Publish (`publish.yml`, builds and pushes a package) when the
  repository has one, CI otherwise. A CI badge beside them repeats what they already prove.
- **Release on public repositories only.** shields.io cannot read a private repository and would
  show an error, while GitHub's own workflow badges do render in a private repository's README.
- **A rule** (`---`) closes the header, after a blank line: without it the `---` stays inside the
  badges' HTML block.
- **License** links to the `LICENSE` file: `img.shields.io/github/license/<owner>/<repo>` on a public
  repository, the static `img.shields.io/badge/license-proprietary-blue` on a private one, which
  shields.io cannot read, with the same `labelColor` and `logo`. A repository without a `LICENSE`
  has no License badge.
- **No License section.** The badge and GitHub's sidebar already show the `LICENSE`; a copy in the
  README drifts from it.
- **Absolute URLs** for the badges and their links, because a README is also read outside GitHub:
  an editor preview, a package registry.
- **Then the rest**, the `**Stack**:` line first where there is one, 120 lines at most in all.
- **Profile pages are exempt** (an organization's `profile/README.md`, the `brei0x/brei0x`
  repository): they are showcases, not projects.

# Reference

The rules every repository that calls these workflows follows, in the `tekalib` organization and
the `brei0x` account alike. This is their only written copy: the manuals of both accounts link
here, and the code that applies them lives next door.

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

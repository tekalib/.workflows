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

Every repository README starts the same way, in this order: the title, one paragraph saying what
the project is and who it is for, then the badges, centered.

```markdown
# <Title>

<One paragraph: what the project is and who it is for.>

<p align="center">
  <a href="https://github.com/<owner>/<repo>/actions/workflows/ci.yml"><img src="https://github.com/<owner>/<repo>/actions/workflows/ci.yml/badge.svg?branch=main" alt="CI"></a>
  <a href="https://github.com/<owner>/<repo>/actions/workflows/deploy.yml"><img src="https://github.com/<owner>/<repo>/actions/workflows/deploy.yml/badge.svg?branch=main" alt="Deploy"></a>
  <a href="https://github.com/<owner>/<repo>/releases/latest"><img src="https://img.shields.io/github/v/release/<owner>/<repo>?sort=semver" alt="Latest release"></a>
</p>
```

- **The title** is the project's name as people say it; the repository name when it has no
  other.
- **The badges**, only those that apply, in this order: CI, then Deploy or Publish when that
  workflow exists, then Release.
- **Release on public repositories only.** shields.io cannot read a private repository and would
  show an error, while GitHub's own workflow badges do render in a private repository's README.
- **Absolute URLs**, because a README is also read outside GitHub: an editor preview, a package
  registry.
- **Then the rest**, the `**Stack**:` line first where there is one, 120 lines at most in all.
- **Profile pages are exempt** (an organization's `profile/README.md`, the `brei0x/brei0x`
  repository): they are showcases, not projects.

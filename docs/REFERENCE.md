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

# CLAUDE.md

## Identity

`.workflows`: the reusable GitHub Actions workflows of the `tekalib` organization (release,
Dependabot auto-merge, back-merge, promote, issues), pinned by commit SHA in every `tekalib`
repository and in personal repositories that follow the same flow. Public, so personal and
public repositories can call it. Stage: production.

## Commands

```bash
pipx run --spec actionlint-py==1.7.12.25 actionlint   # lint every workflow
bash tests/release-bump-test.sh                       # version logic of release.yml
bash tests/release-notes-test.sh                      # release notes block of release.yml, run as is
```

## Conventions

- Every input, secret and output of a `workflow_call` is a public interface. Renaming or adding a
  required one breaks the callers: the pull request title takes a `!`, and the release is a major.
- Writes go through the `tekalib-automation` App token, never `GITHUB_TOKEN`; the App's Client ID
  is the default `client-id` input, its key always arrives from the caller as `app-key`.
- Every `uses:` is a commit SHA with its tag in a comment, here and in every caller. zizmor must stay
  free of high findings: `pipx run zizmor --offline .github`.
- A release is cut only when a reusable workflow changes (`changes` job of `ci.yml`); a docs or
  test change ships nothing to the callers.
- `tests/release-bump-test.sh` mirrors the "Compute the next version" step: change both together.
- Organization rules, rulesets and naming live in the organization's private manual.

## Guardrails

- `main` is the single trunk; one branch per task.
- Never put a secret, a client name or a private repository name in this public repository.

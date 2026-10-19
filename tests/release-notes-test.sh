#!/usr/bin/env bash
# Runs the release-notes block of .github/workflows/release.yml, extracted between its markers,
# against a throwaway repository, and checks the notes it writes.
set -euo pipefail

root=$(cd "$(dirname "$0")/.." && pwd)
work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT

awk '/# >>> release-notes/{on=1; next} /# <<< release-notes/{on=0} on' \
  "$root/.github/workflows/release.yml" | sed -E 's/^ {10}//' > "$work/notes.sh"
[ -s "$work/notes.sh" ] || { echo 'FAIL  release-notes markers not found'; exit 1; }

repo="$work/repo"
git init -q -b main "$repo"
g() { git -C "$repo" -c user.name=test -c user.email=test@example.com -c commit.gpgsign=false "$@"; }
commit() { g commit -q --allow-empty -m "$1" ${2:+-m "$2"}; }

commit 'chore: initial commit'
g tag v1.0.0
commit 'feat(blog): add the articles section (#12)'
commit 'fix(seo): correct the canonical on the 404'
commit 'feat(routing)!: remove /parcours'
commit 'refactor(api): new client' 'BREAKING CHANGE: drops the v1 route'
commit 'build(deps): bump the actions group with 2 updates (#7)'
commit 'Plain subject without a type'
g switch -q -c side
commit 'docs: side note'
g switch -q main
g merge -q --no-ff --no-edit side

(cd "$repo" && LAST=v1.0.0 TAG=v2.0.0 NOTES="$work/notes.md" \
  GITHUB_SERVER_URL=https://github.com GITHUB_REPOSITORY=acme/site bash "$work/notes.sh")
notes=$(cat "$work/notes.md")

fail=0
expect() { # $1 label, $2 fixed string that must appear
  if grep -qF -- "$2" <<< "$notes"; then printf 'ok    %s\n' "$1"; else printf 'FAIL  %s\n' "$1"; fail=1; fi
}
reject() { # $1 label, $2 fixed string that must not appear
  if grep -qF -- "$2" <<< "$notes"; then printf 'FAIL  %s\n' "$1"; fail=1; else printf 'ok    %s\n' "$1"; fi
}

expect 'heading'                       "## What's Changed"
expect 'feat with scope -> Features'   '- **blog**: add the articles section (#12)'
expect 'fix -> Fixes'                  '- **seo**: correct the canonical on the 404'
expect '! -> Breaking changes'         '- **routing**: remove /parcours'
expect 'footer -> Breaking changes'    '- **api**: new client'
expect 'chore type -> Other changes'   '- **deps**: bump the actions group with 2 updates (#7)'
expect 'untyped subject kept'          '- Plain subject without a type'
expect 'docs from a merged branch'     '- side note'
expect 'compare link'                  '**Full Changelog**: https://github.com/acme/site/compare/v1.0.0...v2.0.0'
reject 'merge commit left out'         'Merge branch'
reject 'commit before the last tag'    'initial commit'
[ "$(grep -c '^### ' <<< "$notes")" -eq 4 ] && echo 'ok    four sections' || { echo 'FAIL  four sections'; fail=1; }
breaking=$(sed -n '/^### Breaking changes/,/^### /p' <<< "$notes")
grep -qF 'remove /parcours' <<< "$breaking" && grep -qF 'new client' <<< "$breaking" \
  && echo 'ok    both breaking changes grouped' || { echo 'FAIL  both breaking changes grouped'; fail=1; }

exit "$fail"

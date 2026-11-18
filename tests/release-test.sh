#!/usr/bin/env bash
# ==============================================================================
# release-test.sh — Checks the version and notes block of release.yml
#
# Usage: bash tests/release-test.sh
#
# Extracts the block between `# >>> release` and `# <<< release` from
# .github/workflows/release.yml, runs it as is against throwaway repositories,
# and checks the computed tag and the release notes.
#
# Requirements: bash, git
# ==============================================================================
set -euo pipefail

root=$(cd "$(dirname "$0")/.." && pwd)
work=$(mktemp -d "${TMPDIR:-/tmp}/release-test.XXXXXX")
trap 'rm -rf "$work"' EXIT

awk '/# >>> release$/{on=1; next} /# <<< release$/{on=0} on' \
  "$root/.github/workflows/release.yml" | sed -E 's/^ {10}//' > "$work/release.sh"
[ -s "$work/release.sh" ] || { echo 'FAIL  release markers not found'; exit 1; }

fail=0
repo=''
new_repo() { repo="$work/$1"; git init -q -b main "$repo"; }
g() { git -C "$repo" -c user.name=test -c user.email=test@example.com -c commit.gpgsign=false -c tag.gpgsign=false "$@"; }
commit() { g commit -q --allow-empty -m "$1" ${2:+-m "$2"}; }
release() { # prints the computed tag, nothing when there is no release
  : > "$work/output"
  (cd "$repo" && GITHUB_OUTPUT="$work/output" NOTES="$work/notes.md" GITHUB_SERVER_URL=https://github.com \
    GITHUB_REPOSITORY=acme/site bash -eo pipefail "$work/release.sh" > /dev/null)
  sed -n 's/^tag=//p' "$work/output"
}
check() { # $1 label, $2 expected tag, empty for no release
  local got; got=$(release)
  if [ "$got" = "$2" ]; then
    printf 'ok    %-50s %s\n' "$1" "${got:-no release}"
  else
    printf 'FAIL  %-50s expected %s, got %s\n' "$1" "${2:-no release}" "${got:-no release}"; fail=1
  fi
}
from() { new_repo "$1"; commit 'chore: init'; g tag "$2"; }

from a v1.4.2; commit 'fix(seo): correct the canonical'; commit 'docs: update the readme'
check 'fix + docs -> patch' v1.4.3
from b v1.4.2; commit 'fix(seo): correct the canonical'; commit 'feat(contact): add the form'; commit 'chore(deps): bump vitest'
check 'feat wins over fix -> minor' v1.5.0
from c v1.4.2; commit 'chore(deps): bump vitest'; commit 'feat!: remove /parcours'; commit 'feat(nav): add a subtitle'
check 'feat! wins over everything -> major' v2.0.0
from d v1.4.2; commit 'feat(api): new endpoint' 'BREAKING CHANGE: drops the v1 route'
check 'BREAKING CHANGE footer -> major' v2.0.0
from e v1.4.2; commit 'refactor(nav)!: rename the route'
check 'scoped ! on another type -> major' v2.0.0
from f v1.4.2; commit 'chore(deps): bump vitest'
check 'chore only -> patch (our policy)' v1.4.3
from g v1.4.2; commit 'featuring: not a conventional type'
check 'feat must be the exact type' v1.4.3
from h v1.4.2; commit 'Feat: new page'
check 'types are case-insensitive' v1.5.0
from i v1.4.2; commit 'fix: typo' 'feat: a line of the description'
check 'a body line never sets the type' v1.4.3
from j v2.9.9; commit 'feat!: rewrite'
check 'major resets minor and patch' v3.0.0
from k v2.0.9; commit 'feat: add'
check 'minor resets patch' v2.1.0
from l v0.3.0; commit 'feat!: drop the old API'
check 'breaking on 0.x -> minor' v0.4.0
from m v1.0.0
check 'nothing since the tag -> no release' ''

new_repo n; commit 'docs: first commit'
check 'no tag -> from v0.0.0' v0.0.1
new_repo o; commit 'feat: first feature'
check 'no tag + feat -> v0.1.0' v0.1.0

from p v1.2.0; commit 'fix: b'; g tag v1.3.0-rc.1; commit 'fix: c'
check 'pre-release tags are ignored' v1.2.1

# The back-merge of a released Dependabot fix, then promoted: nothing new reaches production.
from q v1.0.0; g switch -q -c develop; g switch -q main; commit 'build(deps): bump x'; g tag v1.0.1
g switch -q develop; g merge -q --no-ff --no-edit main
check 'only a back-merge since the tags -> no release' ''

# A tag reached through a merge is higher than the nearest one: the highest wins.
from r v1.0.0; g switch -q -c side; commit 'fix: hotfix'; g tag v1.1.1; g switch -q main
commit 'feat: a'; g tag v1.1.0; g merge -q --no-ff --no-edit side; commit 'fix: later'
check 'highest reachable tag, released commits skipped' v1.1.2

from notes v1.0.0
commit 'feat(blog): add the articles section (#12)'
commit 'fix(seo): correct the canonical on the 404'
commit 'feat(routing)!: remove /parcours'
commit 'refactor(api): new client' 'BREAKING CHANGE: drops the v1 route'
commit 'build(deps): bump the actions group with 2 updates (#7)'
commit 'Plain subject without a type'
g switch -q -c side; commit 'docs: side note'; g switch -q main; g merge -q --no-ff --no-edit side
check 'notes scenario -> major' v2.0.0
notes=$(cat "$work/notes.md")

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
expect 'build type -> Other changes'   '- **deps**: bump the actions group with 2 updates (#7)'
expect 'untyped subject kept'          '- Plain subject without a type'
expect 'docs from a merged branch'     '- side note'
expect 'compare link'                  '**Full Changelog**: https://github.com/acme/site/compare/v1.0.0...v2.0.0'
reject 'merge commit left out'         'Merge branch'
reject 'commit before the last tag'    'init'
if [ "$(grep -c '^### ' <<< "$notes")" -eq 4 ]; then echo 'ok    four sections'; else echo 'FAIL  four sections'; fail=1; fi
breaking=$(sed -n '/^### Breaking changes/,/^### Features/p' <<< "$notes")
if grep -qF 'remove /parcours' <<< "$breaking" && grep -qF 'new client' <<< "$breaking"; then
  echo 'ok    both breaking changes grouped'
else
  echo 'FAIL  both breaking changes grouped'; fail=1
fi

exit "$fail"

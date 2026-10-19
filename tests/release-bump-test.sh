#!/usr/bin/env bash
# Exercises the version logic of .github/workflows/release.yml against known inputs. Keep the
# bump() body identical to its "Compute the next version" step, or this proves nothing.
set -uo pipefail

bump() { # $1 = last tag (may be empty), $2 = log text
  local last="$1" log="$2" version major minor patch
  version=${last:-v0.0.0}
  IFS=. read -r major minor patch <<< "${version#v}"
  minor=${minor:-0}
  patch=${patch:-0}
  if grep -qE '^[a-z]+(\([^)]+\))?!:|^BREAKING[ -]CHANGE:' <<< "$log"; then
    major=$((major + 1)); minor=0; patch=0
  elif grep -qE '^feat(\([^)]+\))?:' <<< "$log"; then
    minor=$((minor + 1)); patch=0
  else
    patch=$((patch + 1))
  fi
  printf 'v%s.%s.%s' "$major" "$minor" "$patch"
}

fail=0
check() { # $1 expected, $2 last, $3 log, $4 label
  local got; got=$(bump "$2" "$3")
  if [ "$got" = "$1" ]; then
    printf 'ok    %-44s %s\n' "$4" "$got"
  else
    printf 'FAIL  %-44s expected %s, got %s\n' "$4" "$1" "$got"; fail=1
  fi
}

check v1.4.3 v1.4.2 'fix(seo): correct the canonical
docs: update the readme'                              'fix + docs -> patch'
check v1.5.0 v1.4.2 'fix(seo): correct the canonical
feat(contact): add the form
chore(deps): bump vitest'                             'feat wins over fix -> minor'
check v2.0.0 v1.4.2 'chore(deps): bump vitest
feat!: remove /parcours
feat(nav): add a subtitle'                            'feat! wins over everything -> major'
check v2.0.0 v1.4.2 'feat(api): new endpoint

BREAKING CHANGE: drops the v1 route'                  'BREAKING CHANGE footer -> major'
check v2.0.0 v1.4.2 'refactor(nav)!: rename the route'  'scoped ! on another type -> major'
check v1.4.3 v1.4.2 'chore(deps): bump vitest'          'chore only -> patch (our policy)'
check v1.4.3 v1.4.2 'featuring: not a conventional type' 'feat prefix must be exact'
check v1.4.3 v1.4.2 'Merge branch main into develop'     'merge commit -> patch'
check v0.0.1 ''     'docs: first commit'                 'no previous tag -> from v0.0.0'
check v0.1.0 ''     'feat: first feature'                'no previous tag + feat -> v0.1.0'
check v3.0.0 v2.9.9 'feat!: rewrite'                     'major resets minor and patch'
check v2.1.0 v2.0.9 'feat: add'                          'minor resets patch'

exit "$fail"

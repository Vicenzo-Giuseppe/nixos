#!/bin/sh
set -eu

repo="${SOFT_SERVE_MIRROR_REPO:-}"
remote="${SOFT_SERVE_MIRROR_REMOTE:-}"
key="${SOFT_SERVE_MIRROR_KEY:-}"
git_bin="${SOFT_SERVE_GIT_BIN:-git}"
ssh_bin="${SOFT_SERVE_SSH_BIN:-ssh}"
ssh_opts="${SOFT_SERVE_MIRROR_SSH_OPTS:--o IdentitiesOnly=yes -o StrictHostKeyChecking=accept-new}"
push_option="${SOFT_SERVE_MIRROR_PUSH_OPTION:-}"
tag_trigger="${SOFT_SERVE_MIRROR_TAG:-}"

if [ -z "$repo" ] || [ -z "$remote" ] || [ -z "$key" ]; then
  exit 0
fi

case "${GIT_DIR:-}" in
  */${repo}.git) ;;
  *) exit 0 ;;
esac

if [ ! -f "$key" ]; then
  echo "mirror key not found: $key" >&2
  exit 0
fi

should_mirror=0

if [ -n "$push_option" ] && [ "${GIT_PUSH_OPTION_COUNT:-0}" -gt 0 ]; then
  i=0
  while [ "$i" -lt "$GIT_PUSH_OPTION_COUNT" ]; do
    opt="$(eval "printf '%s' \"\${GIT_PUSH_OPTION_$i-}\"")"
    if [ "$opt" = "$push_option" ]; then
      should_mirror=1
      break
    fi
    i=$((i + 1))
  done
fi

if [ "$should_mirror" -eq 0 ] && [ -n "$tag_trigger" ]; then
  while read -r _ _ ref; do
    if [ "$ref" = "refs/tags/$tag_trigger" ]; then
      should_mirror=1
    fi
  done
fi

if [ -z "$push_option" ] && [ -z "$tag_trigger" ]; then
  should_mirror=1
fi

if [ "$should_mirror" -eq 0 ]; then
  exit 0
fi

export GIT_SSH_COMMAND="$ssh_bin -i $key $ssh_opts"
"$git_bin" push --mirror "$remote"

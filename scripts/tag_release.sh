#!/usr/bin/env bash
set -euo pipefail

VERSION="${1:-v1.1.0}"

if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "Not a git repository" >&2
  exit 1
fi

echo "Tagging $VERSION ..."
git tag -a "$VERSION" -m "Release $VERSION"
echo "Pushing tag $VERSION ..."
git push origin "$VERSION"
echo "Done. The GitHub Actions 'Release' workflow will create a draft release."


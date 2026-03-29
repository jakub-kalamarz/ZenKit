#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "$0")/.." && pwd)"
catalog="$repo_root/docs/ai/component-catalog.md"

if [[ ! -f "$catalog" ]]; then
  echo "Missing $catalog" >&2
  exit 1
fi

public_types="$(mktemp)"
catalog_types="$(mktemp)"
trap 'rm -f "$public_types" "$catalog_types"' EXIT

rg --no-filename -o --replace '$1' '^public (?:struct|enum|typealias) (Zen[A-Za-z0-9_]+)' "$repo_root/Sources/ZenKit/Components" \
  | sort -u > "$public_types"

rg --no-filename -o --replace '$1' '^### `(Zen[A-Za-z0-9_]+)`' "$catalog" \
  | sort -u > "$catalog_types"

missing="$(comm -23 "$public_types" "$catalog_types" || true)"
extra="$(comm -13 "$public_types" "$catalog_types" || true)"

if [[ -n "$missing" ]]; then
  echo "Missing component catalog entries:" >&2
  echo "$missing" >&2
  exit 1
fi

if [[ -n "$extra" ]]; then
  echo "Catalog entries without matching public component types:" >&2
  echo "$extra" >&2
  exit 1
fi

rg -q '\[LLM.md\]\(LLM.md\)' "$repo_root/README.md"
rg -q 'docs/ai/component-catalog.md' "$repo_root/LLM.md"
rg -q 'docs/ai/composition-recipes.md' "$repo_root/LLM.md"
rg -q 'docs/ai/selection-matrix.md' "$repo_root/LLM.md"

echo "AI docs coverage check passed."

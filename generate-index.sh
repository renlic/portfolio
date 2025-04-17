#!/bin/zsh

cd "$(dirname "$0")"
OUTPUT="index.html"

echo '<!DOCTYPE html><html><head><meta charset="utf-8"><title>Index of portfolio.calebsobo.com</title></head><body><pre>' > "$OUTPUT"
echo "📁 portfolio.calebsobo.com" >> "$OUTPUT"
echo "" >> "$OUTPUT"

# Recursive tree renderer
render_tree() {
  local DIR="$1"
  local PREFIX="$2"

  # Get sorted list of visible files/folders excluding .DS_Store and .git
  local ENTRIES=("${(@f)$(find "$DIR" -mindepth 1 -maxdepth 1 \
    ! -name ".DS_Store" \
    ! -name ".git" \
    ! -path "*/.git/*" \
    | LC_ALL=C sort)}")

  local COUNT=${#ENTRIES}
  local i=1

  for ITEM in "${ENTRIES[@]}"; do
    local NAME="${ITEM##*/}"
    local IS_LAST=$(( i == COUNT ))
    local BRANCH=$([[ $IS_LAST -eq 1 ]] && echo "└──" || echo "├──")

    if [[ -d "$ITEM" ]]; then
      echo "${PREFIX}${BRANCH} ${NAME}/" >> "$OUTPUT"
      local NEW_PREFIX=$([[ $IS_LAST -eq 1 ]] && echo "$PREFIX    " || echo "$PREFIX│   ")
      render_tree "$ITEM" "$NEW_PREFIX"
    else
      local URL_ENCODED=$(python3 -c "import urllib.parse, sys; print(urllib.parse.quote(sys.argv[1]))" "$ITEM")
      echo "${PREFIX}${BRANCH} <a href=\"$URL_ENCODED\">${NAME}</a>" >> "$OUTPUT"
    fi
    ((i++))
  done
}

render_tree "." ""

echo "</pre></body></html>" >> "$OUTPUT"
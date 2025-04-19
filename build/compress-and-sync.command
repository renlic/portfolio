#!/bin/zsh

PORTFOLIO=~/Documents/Design/Portfolio
COMPRESSED=~/Documents/Design/Portfolio-Compressed
MAX_BYTES=$((6 * 1024 * 1024))  # 6MB

echo "🔄 Syncing new images from Portfolio to Portfolio-Compressed..."

# Find all .jpg/.jpeg/.png in Portfolio and copy if missing or updated
find "$PORTFOLIO" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" \) | while read -r original; do
  rel_path="${original#$PORTFOLIO/}"
  base=$(basename "$rel_path")
  folder=$(dirname "$rel_path")
  name="${base%.*}"
  ext="${base##*.}"

  mkdir -p "$COMPRESSED/$folder"
  target="$COMPRESSED/$folder/${name}-compressed.$ext"

  if [[ ! -f "$target" || "$original" -nt "$target" ]]; then
    echo "📥 Copying: $rel_path → $target"
    cp "$original" "$COMPRESSED/$folder/tmp-$base"

    quality=100
    while (( quality >= 10 )); do
      magick "$COMPRESSED/$folder/tmp-$base" -quality $quality "$target"
      size=$(stat -f%z "$target")
      if (( size <= MAX_BYTES )); then
        echo "✅ Compressed: $name ($((size / 1024)) KB)"
        break
      fi
      (( quality -= 5 ))
    done

    rm "$COMPRESSED/$folder/tmp-$base"

    if (( quality < 10 )); then
      echo "⚠️ Warning: Could not compress $rel_path under 6MB"
    fi
  else
    echo "✅ Already exists & up-to-date: $target"
  fi
done

echo "🎉 Done syncing and compressing!"
read "REPLY?Press Enter to close..."
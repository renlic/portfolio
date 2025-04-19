#!/bin/zsh

PORTFOLIO=~/Documents/Design/Portfolio
COMPRESSED=~/Documents/Design/Portfolio-Compressed
MAX_BYTES=$((6 * 1024 * 1024))  # 6MB

echo "🔄 Syncing new or updated images to Portfolio-Compressed..."

# === 1. Copy and compress new or updated image files ===
find "$PORTFOLIO" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" \) | while read -r original; do
  rel_path="${original#$PORTFOLIO/}"
  base=$(basename "$rel_path")
  folder=$(dirname "$rel_path")
  name="${base%.*}"
  ext="${base##*.}"

  mkdir -p "$COMPRESSED/$folder"
  target="$COMPRESSED/$folder/${name}-compressed.$ext"
  target_rel="${target#$COMPRESSED/}"

  if [[ ! -f "$target" || "$original" -nt "$target" ]]; then
    echo "📥 Copying:      $rel_path"
    cp "$original" "$COMPRESSED/$folder/tmp-$base"

    quality=100
    while (( quality >= 10 )); do
      magick "$COMPRESSED/$folder/tmp-$base" -quality $quality "$target"
      size=$(stat -f%z "$target")
if (( size <= MAX_BYTES )); then
  size_kb=$((size / 1024))
  echo "✅ Compressed:   $target_rel (${size_kb} KB)"
  break
fi
      (( quality -= 5 ))
    done

    rm "$COMPRESSED/$folder/tmp-$base"

    if (( quality < 10 )); then
      echo "⚠️  Too large:     $rel_path — could not shrink under 6MB"
      rm -f "$target"
    fi
  else
    echo "✅ Up-to-date:   $target_rel"
  fi
done

# === 2. Delete compressed files with no matching original ===
echo ""
echo "🧹 Cleaning up orphaned compressed files..."

find "$COMPRESSED" -type f \( -iname "*-compressed.jpg" -o -iname "*-compressed.jpeg" -o -iname "*-compressed.png" \) | while read -r compressed; do
  rel_path="${compressed#$COMPRESSED/}"
  folder=$(dirname "$rel_path")
  name=$(basename "$rel_path")
  original_name="${name%-compressed.*}.${name##*.}"
  original_path="$PORTFOLIO/$folder/$original_name"

  if [[ ! -f "$original_path" ]]; then
    echo "🗑  Removing:     $rel_path"
    rm "$compressed"
  fi
done

echo ""
echo "🚀 Running Git sync and index generation..."

# === 3. Run the sync-and-generate.sh script ===
cd "$PORTFOLIO/build" || exit 1
./sync-and-generate.sh

echo ""
echo "✅ Full sync complete! Press Enter to close this window..."
read
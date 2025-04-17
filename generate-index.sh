#!/bin/zsh

OUTPUT="index.html"
cd "$(dirname "$0")"

echo "<!DOCTYPE html><html><head><meta charset='utf-8'><title>Portfolio Index</title><style>body{font-family:sans-serif;padding:2rem}a{display:block;margin:.5rem 0}</style></head><body><h1>📁 Portfolio Files</h1>" > "$OUTPUT"

find . -type f \( -iname "*.pdf" -o -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" \) | while read file; do
  ENCODED=$(python3 -c "import urllib.parse, sys; print(urllib.parse.quote(sys.argv[1]))" "$file")
  echo "<a href=\"$ENCODED\">$file</a>" >> "$OUTPUT"
done

echo "</body></html>" >> "$OUTPUT"


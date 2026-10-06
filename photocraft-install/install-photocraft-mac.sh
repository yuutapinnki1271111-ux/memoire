#!/bin/bash
# PhotoCraft 最新版をダウンロード・照合し、dmgを開きます。ドラッグ操作はあなたが行います。
set -e
J=$(curl -fsSL https://api.github.com/repos/storytold/photocraft/releases/latest)
URL=$(echo "$J" | grep -o '"browser_download_url": *"[^"]*macos[^"]*\.dmg"' | head -1 | sed 's/.*"\(http[^"]*\)"/\1/')
SUM=$(echo "$J" | grep -o '"browser_download_url": *"[^"]*SHA256SUMS[^"]*"' | head -1 | sed 's/.*"\(http[^"]*\)"/\1/')
[ -z "$URL" ] && { echo "dmgが見つかりません。次の一覧をClaudeに貼ってください:"; echo "$J" | grep '"name"'; exit 1; }
F="$HOME/Downloads/$(basename "$URL")"
curl -fL "$URL" -o "$F"
if [ -n "$SUM" ]; then
  want=$(curl -fsSL "$SUM" | grep "$(basename "$F")" | awk '{print $1}')
  got=$(shasum -a 256 "$F" | awk '{print $1}')
  [ "$want" = "$got" ] && echo "OK: 指紋が一致しました" || { echo "NG: 一致しません。開かずに止めました"; exit 1; }
fi
open "$F"

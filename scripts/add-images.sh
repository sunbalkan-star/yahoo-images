#!/usr/bin/env bash
# 使い方: scripts/add-images.sh [-p 商品名プレフィックス] 画像ファイル...
# 画像を images/ にコピーし、commit & push して、公開URLとHTMLタグを出力します。
set -euo pipefail

REPO_SLUG="sunbalkan-star/yahoo-images"
BRANCH="main"
PREFIX=""

while getopts "p:" opt; do
  case "$opt" in
    p) PREFIX="$OPTARG" ;;
    *) echo "usage: $0 [-p prefix] file..." >&2; exit 2 ;;
  esac
done
shift $((OPTIND - 1))
[ "$#" -ge 1 ] || { echo "画像ファイルを指定してください" >&2; exit 2; }

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

# プレフィックスは半角英数・ハイフン・アンダースコアのみに整形
PREFIX="$(printf '%s' "$PREFIX" | tr -c 'A-Za-z0-9_-' '-' | sed 's/^-*//; s/-*$//')"
STAMP="$(TZ=Asia/Tokyo date +%Y%m%d-%H%M%S)"
DIR="images"
[ -n "$PREFIX" ] && DIR="images/$PREFIX"
mkdir -p "$DIR"

git fetch -q origin "$BRANCH" && git merge -q --ff-only "origin/$BRANCH" 2>/dev/null || true

n=0
urls=()
for f in "$@"; do
  [ -f "$f" ] || { echo "見つかりません: $f" >&2; continue; }
  ext="$(printf '%s' "${f##*.}" | tr 'A-Z' 'a-z')"
  case "$ext" in
    jpg|jpeg|png|gif|webp) ;;
    *) echo "未対応の形式のためスキップ: $f (jpg/png/gif/webpのみ)" >&2; continue ;;
  esac
  n=$((n + 1))
  name="$(printf '%s-%02d.%s' "$STAMP" "$n" "$ext")"
  cp "$f" "$DIR/$name"
  urls+=("https://raw.githubusercontent.com/$REPO_SLUG/$BRANCH/$DIR/$name")
done

[ "$n" -ge 1 ] || { echo "保存できる画像がありませんでした" >&2; exit 1; }

git add "$DIR"
git commit -q -m "画像を追加: $n 枚 ($STAMP)"
git push -q origin "HEAD:$BRANCH"

echo "=== 保存完了: $n 枚 ==="
for u in "${urls[@]}"; do echo "$u"; done
echo
echo "=== ヤフオク用HTML ==="
for u in "${urls[@]}"; do echo "<img src=\"$u\" width=\"100%\">"; done

#!/usr/bin/env python3
"""大きすぎる画像をヤフオク説明文向けに自動縮小する。

使い方: optimize_image.py 入力ファイル 出力ディレクトリ
- 長辺が MAX_SIDE を超える、またはファイルサイズが MAX_BYTES を超える場合のみ処理
- 縮小後は JPEG（品質85から段階的に下げて MAX_BYTES 以下に）
- GIF（アニメ含む）は加工せずそのまま
- 条件内の画像は無加工でコピー
- 出力先のファイルパスを標準出力に1行で返す
"""
import os
import shutil
import sys

from PIL import Image, ImageOps

MAX_SIDE = int(os.environ.get("YI_MAX_SIDE", "1600"))        # 長辺の上限(px)
MAX_BYTES = int(os.environ.get("YI_MAX_BYTES", str(1024 * 1024)))  # 1MB
START_QUALITY = 85
MIN_QUALITY = 60


def main() -> None:
    src, outdir = sys.argv[1], sys.argv[2]
    os.makedirs(outdir, exist_ok=True)
    base, ext = os.path.splitext(os.path.basename(src))
    ext = ext.lower().lstrip(".")

    def passthrough() -> None:
        dst = os.path.join(outdir, f"{base}.{ext}")
        shutil.copyfile(src, dst)
        print(dst)

    if ext == "gif":
        return passthrough()

    img = Image.open(src)
    img = ImageOps.exif_transpose(img)  # スマホ写真の向きを正しく反映
    w, h = img.size
    size = os.path.getsize(src)

    if max(w, h) <= MAX_SIDE and size <= MAX_BYTES:
        return passthrough()

    if max(w, h) > MAX_SIDE:
        scale = MAX_SIDE / max(w, h)
        img = img.resize((round(w * scale), round(h * scale)), Image.LANCZOS)

    if img.mode in ("RGBA", "LA", "P"):
        img = img.convert("RGBA")
        bg = Image.new("RGB", img.size, (255, 255, 255))
        bg.paste(img, mask=img.split()[-1])
        img = bg
    else:
        img = img.convert("RGB")

    dst = os.path.join(outdir, f"{base}.jpg")
    q = START_QUALITY
    while True:
        img.save(dst, "JPEG", quality=q, optimize=True, progressive=True)
        if os.path.getsize(dst) <= MAX_BYTES or q <= MIN_QUALITY:
            break
        q -= 5
    print(dst)


if __name__ == "__main__":
    main()

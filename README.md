# yahoo-images

ヤフオク説明文に添付する画像の保存用リポジトリです（Public）。

## 使い方

1. 画像を `images/` フォルダに追加（GitHubの「Add file → Upload files」でも可）
2. ファイル名は **半角英数字・ハイフン・アンダースコアのみ** を推奨（例: `item001-01.jpg`）
3. 下記のURL形式を、ヤフオクの説明文のHTMLに貼り付けます

## 画像URL

```
https://raw.githubusercontent.com/sunbalkan-star/yahoo-images/main/images/ファイル名.jpg
```

## ヤフオク説明文でのHTML例

```html
<img src="https://raw.githubusercontent.com/sunbalkan-star/yahoo-images/main/images/item001-01.jpg" width="100%">
```

## フォルダ構成の目安

```
images/
  item001/
    01.jpg
    02.jpg
  item002/
    01.jpg
```

## 自動縮小

`scripts/add-images.sh` で保存すると、大きすぎる画像は自動で縮小されます。

- 対象: 長辺が1600pxを超える、またはファイルサイズが1MBを超える画像
- 処理: 長辺1600pxに縮小し、JPEGで1MB以下に圧縮（スマホ写真の向きも補正）
- 対象外: 条件内の画像、GIF は無加工
- 変更: 環境変数 `YI_MAX_SIDE`（px）、`YI_MAX_BYTES`（バイト）で上限を調整できます

## 注意

- このリポジトリは公開されているため、**個人情報（住所・氏名・伝票など）が写った画像は置かないでください**。
- 画像を差し替えると、同じURLでも反映が遅れる場合があります。差し替え時はファイル名を変えるのが確実です。
- 1ファイル100MB以下、リポジトリ全体は1GB以下を目安にしてください。

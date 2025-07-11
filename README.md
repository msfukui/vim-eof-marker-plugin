# Vim EOF Marker Plugin

Vimのファイルバッファの末尾に薄い灰色で "[EOF]" マークを表示するだけのプラグインです。

textprop を使用しており、Vim 8.1+ で動作します。

## インストール

### vim-plug の場合

```vim
Plug 'msfukui/vim-eof-marker-plugin'
```

他のプラグインマネージャーの場合も同様によしなに指定してください。

### 手動インストール

ファイルを以下のディレクトリに配置してください:

```
~/.vim/plugin/eof_marker.vim
~/.vim/autoload/eof_marker.vim
~/.vim/doc/eof_marker.txt
```

## 使用方法

プラグインをインストールすると、自動的にすべてのバッファでEOFマーカーが表示されます。

### コマンド

- `:EofMarkerToggle` - EOFマーカーの表示/非表示を切り替え
- `:EofMarkerShow` - EOFマーカーを表示
- `:EofMarkerHide` - EOFマーカーを非表示

## 設定

### プラグインの有効/無効

```vim
let g:eof_marker_enabled = 1  " 有効（デフォルト）
let g:eof_marker_enabled = 0  " 無効
```

### カスタムEOFテキスト

```vim
let g:eof_marker_text = '[EOF]'      " デフォルト
let g:eof_marker_text = '~ END ~'    " カスタム
```

### カラーのカスタマイズ

```vim
" 薄いグレーに設定（デフォルト）
let g:eof_marker_highlight = {'ctermfg': 244, 'guifg': '#808080'}

" さらに薄くしたい場合
let g:eof_marker_highlight = {'ctermfg': 246, 'guifg': '#949494'}

" 非常に薄いグレー
let g:eof_marker_highlight = {'ctermfg': 248, 'guifg': '#a8a8a8'}
```

**カラー番号の参考:**
- `242`: 暗いグレー
- `244`: 薄いグレー（デフォルト）
- `246`: より薄いグレー
- `248`: 非常に薄いグレー
- `250`: 最も薄いグレー

## 開発

### テストの実行

vim-themisを使用してテストを実行できます:

```bash
# vim-themisのインストール
git clone https://github.com/thinca/vim-themis.git ~/.vim/bundle/vim-themis

# テストの実行
~/.vim/bundle/vim-themis/bin/themis test/
```

### プロジェクト構造

```
vim-eof-plugin/
├── plugin/
│   └── eof_marker.vim          # メインプラグインファイル
├── autoload/
│   └── eof_marker.vim          # 自動読み込み関数
├── test/
│   ├── .themisrc               # themis設定ファイル
│   └── eof_marker.vimspec      # vim-themisテストスペック
├── doc/
│   └── eof_marker.txt          # ヘルプドキュメント
├── README.md                   # プロジェクト説明
└── LICENSE                     # ライセンス
```

## 詳細

### 作成者

このプラグインは Cline + copilot - claude-sonnet-4 を使用して作成されました。

## ライセンス

MIT License (https://opensource.org/license/mit/)

## 変更履歴

### v1.0.0
- 初回リリース
- 基本的なEOFマーカー表示機能
- カーソル制御機能
- ファイル保存時の処理

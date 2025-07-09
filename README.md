# Vim EOF Marker Plugin

Vimのファイルバッファの末尾に薄い灰色で "[EOF]" マークを表示するプラグインです。

## 特徴

- ファイルバッファの一番末尾に "[EOF]" を薄い灰色で表示
- カーソルは "[EOF]" マークに移動できない
- "[EOF]" マークはファイル内容に含まれない（表示専用）
- 通常のVim（NeoVimではない）で動作
- TDD（Test-Driven Development）で開発
- vim-themisテストフレームワークを使用

## インストール

### vim-plugを使用する場合

```vim
Plug 'msfukui/vim-eof-plugin'
```

### Vundleを使用する場合

```vim
Plugin 'msfukui/vim-eof-plugin'
```

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
" より薄いグレーに設定（デフォルト）
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

このプラグインはTDD（Test-Driven Development）で開発されています。

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

## 技術的詳細

### Virtual Text vs Sign機能

プラグインは、Vimのバージョンに応じて最適な表示方法を自動選択します:

- **Vim 8.1以降**: `textprop`機能を使用してVirtual Textで表示
- **Vim 8.0以前**: `sign`機能を使用してフォールバック表示

### TDD開発プロセス

このプラグインは以下のTDDサイクルで開発されました:

1. **Red**: 失敗するテストを書く
2. **Green**: テストをパスする最小限の実装を書く  
3. **Refactor**: コードを改善する

## ライセンス

MIT License

## 貢献

バグ報告や機能追加の提案は、GitHubのIssuesでお願いします。

## 変更履歴

### v1.0.0
- 初回リリース
- 基本的なEOFマーカー表示機能
- カーソル制御機能
- ファイル保存時の処理
- TDDによる包括的なテストカバレッジ

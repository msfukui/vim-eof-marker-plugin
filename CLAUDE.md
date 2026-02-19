# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## プロジェクト概要

Vim でファイル末尾に "[EOF]" マーカーを表示するプラグインです。マーカーは表示のみで、ファイル保存時には実際のファイル内容に影響しません。

## 主要コマンド

### テスト実行

```bash
# 全テストを実行（vim-themisが必要）
~/.vim/bundle/vim-themis/bin/themis test/

# 特定のテストファイルを実行
~/.vim/bundle/vim-themis/bin/themis test/eof_marker.vimspec
```

### vim-themis のインストール（必要な場合）

```bash
git clone https://github.com/thinca/vim-themis.git ~/.vim/bundle/vim-themis
```

## アーキテクチャ
----
### 主要コンポーネント

- **plugin/eof_marker.vim**: エントリーポイント、autoload スクリプトの読み込みとコマンド定義
- **autoload/eof_marker.vim**: Vim の text properties API を使用したメイン実装
- **test/eof_marker.vimspec**: 12 個のテストケースを含む包括的なテストスイート

### 実装の重要なポイント

1. **Text Properties**: Vim 8.1 以降の textprop 機能で非侵襲的に表示
2. **バッファ管理**: 各バッファ専用のプロパティタイプ（例：'eof_marker_1'）
3. **イベント処理**: BufReadPost、BufNewFile、BufWritePre/Post、CursorMoved の autocmd
4. **状態管理**: 内部辞書でバッファと EOF マーカーを追跡

### 重要な関数

- `eof_marker#enable()`: メインセットアップ関数 autoload/eof_marker.vim:16
- `s:add_eof_marker()`: バッファに EOF マーカーを追加 autoload/eof_marker.vim:82
- `s:remove_eof_marker()`: EOF マーカーを削除 autoload/eof_marker.vim:122
- `s:on_cursor_moved()`: カーソル移動ロジック処理 autoload/eof_marker.vim:162

### 開発方針

TDD（テスト駆動開発）の原則に従っています：

1. まず test/eof_marker.vimspec にテストを記述
2. テストを実行して失敗を確認
3. 機能を実装
4. テストを再実行して検証

### 重要な挙動

- EOF マーカーは通常のナビゲーション時にカーソルが移動するのを防ぐ
- G コマンド（最終行へ移動）では EOF 行にカーソルを置ける
- バッファ保存時は一時的に EOF マーカーを削除してファイル変更を防ぐ
- 各バッファは独立して EOF マーカーの状態を維持

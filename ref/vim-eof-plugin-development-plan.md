# Vim EOF Plugin 開発計画書

参考: この計画書は、このプラグインを最初に企画した際に、以下のプロンプトで Cline + copilot - claude-sonnet-4 を使用して自動作成されたものです。

```
以下の仕様を持つ Vim (=Not NeoVim) のプラグインを VimScript を使って新規に作成したいです。

## 仕様
- 開いているファイルバッファの一番末尾にファイル末尾であることを示す "[EOF]" の表示を常に薄い灰色で表示する
- 表示する "[EOF]" のマークにはカーソルは移動できず、あくまでマーク表示だけなので、編集対象のファイル内にも含まれない

まずは開発を進めるための手順を整理してドキュメントに起こしていただきたいです。

開発にあたっては、TDD の手法で失敗する自動テストを書き、実装を書き、テストがパスすることを確認してからリファクタリングするやり方で、少しずつフィードバックを得ながら進めていきたいです。
```

```
申し訳ないのですが、日本語でお願いできますか?
```

```
VimScript のテストフレームワークには vim-themis を使用してください。
```

## プロジェクト概要

### 目的
Vimのファイルバッファの末尾に "[EOF]" マークを薄い灰色で表示するプラグインを開発する。

### 要件
- ファイルバッファの一番末尾に "[EOF]" を薄い灰色で表示
- カーソルは "[EOF]" マークに移動できない
- "[EOF]" マークはファイル内容に含まれない（表示専用）
- 通常のVim（NeoVimではない）で動作

## 開発手法
TDD（Test-Driven Development）を採用し、vim-themisテストフレームワークを使用する：
1. **Red**: 失敗するテストを書く
2. **Green**: テストをパスする最小限の実装を書く
3. **Refactor**: コードを改善する

## プロジェクト構造

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

## 開発環境セットアップ

### vim-themisのインストール
```bash
# vim-themisのクローン
git clone https://github.com/thinca/vim-themis.git ~/.vim/bundle/vim-themis

# またはプラグインマネージャーを使用
# vim-plug例: Plug 'thinca/vim-themis'
```

### テスト実行方法
```bash
# 全テストの実行
~/.vim/bundle/vim-themis/bin/themis test/

# 特定のテストファイルの実行
~/.vim/bundle/vim-themis/bin/themis test/eof_marker.vimspec
```

## 開発フェーズ

### Phase 1: プロジェクトセットアップ
- [ ] プロジェクトディレクトリ構造の作成
- [ ] vim-themisの設定
- [ ] 基本的なプラグインファイルの骨格作成

### Phase 2: vim-themisテスト環境の構築
- [ ] `.themisrc` 設定ファイルの作成
- [ ] 基本的なテストスペックファイルの作成
- [ ] テスト実行の確認

### Phase 3: 基本機能の実装（TDDサイクル）

#### 3.1 プラグイン初期化のテスト
**Red**: 失敗するテスト
```vim
Describe eof_marker plugin initialization
  It should load the plugin
    Assert exists('g:eof_marker_loaded')
  End
End
```

**Green**: 最小限の実装
**Refactor**: コードの整理

#### 3.2 バッファ検出機能のテスト
**Red**: 失敗するテスト
```vim
Describe buffer detection
  Before each
    tabnew
    call eof_marker#setup_buffer()
  End
  
  After each
    bdelete!
  End
  
  It should detect when buffer is loaded
    Assert eof_marker#is_buffer_tracked(bufnr('%'))
  End
End
```

**Green**: BufReadPost, BufNewFile イベントの処理実装
**Refactor**: バッファ管理の抽象化

#### 3.3 EOF マーク表示機能のテスト
**Red**: 失敗するテスト
```vim
Describe EOF marker display
  Before each
    tabnew
    call append(0, ['line1', 'line2', 'line3'])
    call eof_marker#add_eof_marker()
  End
  
  After each
    bdelete!
  End
  
  It should add EOF marker at the end of buffer
    let markers = eof_marker#get_markers(bufnr('%'))
    Assert len(markers) ==# 1
    Assert markers[0].text ==# '[EOF]'
  End
End
```

**Green**: Virtual textまたはsignを使った表示機能の実装
**Refactor**: 表示ロジックの抽象化

#### 3.4 スタイリング機能のテスト
**Red**: 失敗するテスト
```vim
Describe EOF marker styling
  It should define highlight group for EOF marker
    Assert hlexists('EofMarker')
  End
  
  It should apply gray color to EOF marker
    let hl = eof_marker#get_highlight_info()
    Assert hl.ctermfg ==# 'gray' || hl.guifg =~# 'gray\|#.*'
  End
End
```

**Green**: ハイライトグループの定義と適用
**Refactor**: カラー設定の外部化

#### 3.5 カーソル制御機能のテスト
**Red**: 失敗するテスト
```vim
Describe cursor control
  Before each
    tabnew
    call append(0, ['line1', 'line2'])
    call eof_marker#add_eof_marker()
  End
  
  After each
    bdelete!
  End
  
  It should prevent cursor from moving to EOF marker
    normal! G$
    let initial_pos = getpos('.')
    " Try to move beyond last line
    normal! j
    let final_pos = getpos('.')
    Assert initial_pos ==# final_pos
  End
End
```

**Green**: カーソル移動制御の実装
**Refactor**: イベントハンドリングの最適化

#### 3.6 ファイル保存時の処理テスト
**Red**: 失敗するテスト
```vim
Describe file saving
  Before each
    let g:temp_file = tempname()
    execute 'edit' g:temp_file
    call append(0, ['line1', 'line2'])
    call eof_marker#add_eof_marker()
  End
  
  After each
    if filereadable(g:temp_file)
      call delete(g:temp_file)
    endif
    bdelete!
  End
  
  It should not include EOF marker in saved file
    write
    let content = readfile(g:temp_file)
    for line in content
      Assert line !~# '\[EOF\]'
    endfor
  End
End
```

**Green**: 保存時処理の実装
**Refactor**: 保存処理の改善

### Phase 4: 統合テストと最適化
- [ ] 複数バッファでの動作テスト
- [ ] パフォーマンステスト
- [ ] エラーハンドリングのテスト

### Phase 5: ドキュメント化とパッケージング
- [ ] ヘルプドキュメントの作成
- [ ] README.mdの作成
- [ ] ライセンスファイルの追加

## vim-themis テスト構造

### 基本的なテストファイル構造
```vim
" test/eof_marker.vimspec

let s:suite = themis#suite('eof_marker')
let s:assert = themis#helper('assert')

function! s:suite.before_each()
  " 各テスト前の共通処理
endfunction

function! s:suite.after_each()
  " 各テスト後のクリーンアップ
endfunction

function! s:suite.test_plugin_loads()
  call s:assert.exists('g:eof_marker_loaded')
endfunction

" その他のテスト関数...
```

### .themisrc 設定例
```vim
" test/.themisrc

" プラグインパスの追加
let &runtimepath = expand('<sfile>:p:h:h') . ',' . &runtimepath

" テスト用の設定
let g:eof_marker_test_mode = 1
```

## 技術的検討事項

### Virtual Text vs Sign機能

**Virtual Text使用時のテスト例:**
```vim
It should use virtual text when available
  if has('textprop')
    let props = prop_list(line('$'))
    Assert len(props) ==# 1
    Assert props[0].text ==# '[EOF]'
  endif
End
```

**Sign機能フォールバック時のテスト例:**
```vim
It should use signs when virtual text is not available
  if !has('textprop')
    let signs = sign_getplaced(bufnr('%'))
    Assert len(signs[0].signs) ==# 1
  endif
End
```

## CI/CD パイプライン

### GitHub Actionsでの自動テスト
```yaml
# .github/workflows/test.yml
name: Test
on: [push, pull_request]
jobs:
  test:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        vim_version: ['8.0', '8.1', '8.2', '9.0']
    steps:
      - uses: actions/checkout@v2
      - name: Install Vim
        run: # Vim installation steps
      - name: Install vim-themis
        run: git clone https://github.com/thinca/vim-themis.git
      - name: Run tests
        run: ./vim-themis/bin/themis test/
```

## 成功指標とテストカバレッジ

### テストカバレッジ目標
- **関数カバレッジ**: 100%
- **行カバレッジ**: 90%以上
- **ブランチカバレッジ**: 85%以上

### 品質指標
1. 全テストがパスする
2. 複数のVimバージョンで動作する
3. メモリリークがない
4. 他の主要プラグインと競合しない
## スケジュール（目安）

- **Day 1-2**: Phase 1-2（セットアップとvim-themis環境構築）
- **Day 3-5**: Phase 3.1-3.3（基本機能のTDD開発）
- **Day 6-8**: Phase 3.4-3.6（詳細機能のTDD開発）
- **Day 9-10**: Phase 4（統合テストと最適化）
- **Day 11-12**: Phase 5（ドキュメント化）

---
この開発計画書は、vim-themisを使用したTDD開発の具体的な手順を示しています。各機能ごとに「失敗するテスト → 実装 → リファクタリング」のサイクルを回すことで、品質の高いプラグインを開発できます。


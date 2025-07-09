" plugin/eof_marker.vim
" Vim EOF Marker Plugin - メインプラグインファイル

" プラグインの重複読み込み防止
if exists('g:eof_marker_loaded') || &compatible
  finish
endif
let g:eof_marker_loaded = 1

" プラグイン設定のデフォルト値
if !exists('g:eof_marker_enabled')
  let g:eof_marker_enabled = 1
endif

if !exists('g:eof_marker_text')
  let g:eof_marker_text = '[EOF]'
endif

" カラー設定のカスタマイズオプション
if !exists('g:eof_marker_highlight')
  let g:eof_marker_highlight = {'ctermfg': 244, 'guifg': '#808080'}
endif

" ハイライトグループの定義（より薄い灰色に設定）
" デフォルトは244番（薄いグレー）と#808080（ミディアムグレー）
execute 'highlight default EofMarker ctermfg=' . g:eof_marker_highlight.ctermfg . ' guifg=' . g:eof_marker_highlight.guifg

" オートコマンドグループの定義
augroup EofMarker
  autocmd!
  autocmd BufReadPost,BufNewFile * call eof_marker#setup_buffer()
  autocmd BufWritePre * call eof_marker#remove_eof_marker_before_save()
  autocmd BufWritePost * call eof_marker#restore_eof_marker_after_save()
  autocmd CursorMoved,CursorMovedI * call eof_marker#prevent_cursor_on_eof()
augroup END

" コマンドの定義
command! EofMarkerToggle call eof_marker#toggle()
command! EofMarkerShow call eof_marker#add_eof_marker()
command! EofMarkerHide call eof_marker#remove_eof_marker()

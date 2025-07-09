" autoload/eof_marker.vim
" Vim EOF Marker Plugin - 自動読み込み関数

" バッファ追跡用のスクリプトローカル変数
let s:tracked_buffers = {}
let s:eof_markers = {}

" バッファのセットアップ
function! eof_marker#setup_buffer()
  if !g:eof_marker_enabled
    return
  endif
  
  let bufnr = bufnr('%')
  let s:tracked_buffers[bufnr] = 1
  
  " EOF マーカーを追加
  call eof_marker#add_eof_marker()
endfunction

" バッファが追跡されているかチェック
function! eof_marker#is_buffer_tracked(bufnr)
  return has_key(s:tracked_buffers, a:bufnr)
endfunction

" EOF マーカーを追加
function! eof_marker#add_eof_marker()
  if !g:eof_marker_enabled
    return
  endif
  
  let bufnr = bufnr('%')
  
  " 既存のマーカーを削除
  call eof_marker#remove_eof_marker()
  
  " Virtual textが利用可能な場合はtextpropを使用
  if has('textprop')
    call eof_marker#add_eof_marker_textprop()
  else
    " フォールバック: signを使用
    call eof_marker#add_eof_marker_sign()
  endif
endfunction

" textpropを使用してEOFマーカーを追加
function! eof_marker#add_eof_marker_textprop()
  let bufnr = bufnr('%')
  let last_line = line('$')
  
  " 空行を追加してEOFマーカー用の行を作成
  call append(last_line, '')
  let eof_line = last_line + 1
  
  " プロパティタイプを定義（バッファごとに個別に管理）
  let prop_name = 'eof_marker_' . bufnr
  try
    call prop_type_add(prop_name, {
      \ 'highlight': 'EofMarker',
      \ 'priority': 100,
      \ 'bufnr': bufnr
      \ })
  catch /E969:/
    " プロパティタイプが既に存在する場合は削除して再作成
    try
      call prop_type_delete(prop_name, {'bufnr': bufnr})
    catch
    endtry
    call prop_type_add(prop_name, {
      \ 'highlight': 'EofMarker',
      \ 'priority': 100,
      \ 'bufnr': bufnr
      \ })
  endtry
  
  " 新しい行にEOF マーカーを追加
  call prop_add(eof_line, 1, {
    \ 'type': prop_name,
    \ 'text': g:eof_marker_text,
    \ 'bufnr': bufnr
    \ })
  
  " マーカー情報を保存
  let s:eof_markers[bufnr] = [{
    \ 'text': g:eof_marker_text,
    \ 'line': eof_line,
    \ 'type': 'textprop',
    \ 'prop_name': prop_name,
    \ 'eof_line': eof_line
    \ }]
endfunction

" signを使用してEOFマーカーを追加（フォールバック）
function! eof_marker#add_eof_marker_sign()
  let bufnr = bufnr('%')
  let last_line = line('$')
  
  " サインを定義
  execute 'sign define eof_marker text=' . g:eof_marker_text . ' texthl=EofMarker'
  
  " サインを配置
  execute 'sign place 999 line=' . last_line . ' name=eof_marker buffer=' . bufnr
  
  " マーカー情報を保存
  let s:eof_markers[bufnr] = [{
    \ 'text': g:eof_marker_text,
    \ 'line': last_line,
    \ 'type': 'sign'
    \ }]
endfunction

" EOF マーカーを削除
function! eof_marker#remove_eof_marker()
  let bufnr = bufnr('%')
  
  if has_key(s:eof_markers, bufnr)
    for marker in s:eof_markers[bufnr]
      if marker.type == 'textprop'
        " textpropを削除
        let prop_name = get(marker, 'prop_name', 'eof_marker_' . bufnr)
        try
          call prop_remove({'type': prop_name, 'bufnr': bufnr, 'all': 1})
          call prop_type_delete(prop_name, {'bufnr': bufnr})
        catch
          " エラーが発生した場合は無視
        endtry
        
        " EOFマーカー用に追加した空行を削除
        if has_key(marker, 'eof_line')
          let eof_line = marker.eof_line
          " 行が存在し、空行であれば削除
          if eof_line <= line('$') && getline(eof_line) == ''
            execute eof_line . 'delete'
          endif
        endif
      elseif marker.type == 'sign'
        " サインを削除
        execute 'sign unplace 999 buffer=' . bufnr
      endif
    endfor
    unlet s:eof_markers[bufnr]
  endif
endfunction

" EOF マーカーの情報を取得
function! eof_marker#get_markers(bufnr)
  if has_key(s:eof_markers, a:bufnr)
    return s:eof_markers[a:bufnr]
  endif
  return []
endfunction

" ハイライト情報を取得
function! eof_marker#get_highlight_info()
  let hl_info = {'ctermfg': '', 'guifg': ''}
  
  " ハイライトグループの情報を取得
  try
    redir => hl_output
    silent highlight EofMarker
    redir END
    
    " ctermfgとguifgを抽出（数値とカラーコードの両方に対応）
    let hl_info.ctermfg = matchstr(hl_output, 'ctermfg=\zs\S\+')
    let hl_info.guifg = matchstr(hl_output, 'guifg=\zs\S\+')
    
    " デフォルト値が設定されているかチェック
    if empty(hl_info.ctermfg) && empty(hl_info.guifg)
      let hl_info.ctermfg = '242'
      let hl_info.guifg = '#6c6c6c'
    endif
  catch
    " エラーが発生した場合はデフォルト値を設定
    let hl_info.ctermfg = '242'
    let hl_info.guifg = '#6c6c6c'
  endtry
  
  return hl_info
endfunction

" カーソルがEOFマーカー上に移動するのを防ぐ
function! eof_marker#prevent_cursor_on_eof()
  let bufnr = bufnr('%')
  
  if has_key(s:eof_markers, bufnr)
    let current_line = line('.')
    let marker = s:eof_markers[bufnr][0]
    
    " EOFマーカーの行にカーソルがある場合、前の行に戻す
    if has_key(marker, 'eof_line') && current_line == marker.eof_line
      let prev_line = marker.eof_line - 1
      if prev_line > 0
        call cursor(prev_line, col([prev_line, '$']) - 1)
      endif
    endif
  endif
endfunction

" ファイル保存前にEOFマーカーを一時的に削除
function! eof_marker#remove_eof_marker_before_save()
  call eof_marker#remove_eof_marker()
endfunction

" ファイル保存後にEOFマーカーを復元
function! eof_marker#restore_eof_marker_after_save()
  call eof_marker#add_eof_marker()
endfunction

" プラグインの有効/無効を切り替え
function! eof_marker#toggle()
  if g:eof_marker_enabled
    let g:eof_marker_enabled = 0
    call eof_marker#remove_eof_marker()
    echo "EOF Marker disabled"
  else
    let g:eof_marker_enabled = 1
    call eof_marker#add_eof_marker()
    echo "EOF Marker enabled"
  endif
endfunction

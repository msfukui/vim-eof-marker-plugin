" autoload/eof_marker.vim
" Vim EOF Marker Plugin - 自動読み込み関数

" バッファ追跡用のスクリプトローカル変数
let s:tracked_buffers = {}
let s:eof_markers = {}
let s:last_cursor_pos = {}
let s:allow_eof_move = {}

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

  " textprop を利用
  if has('textprop')
    call eof_marker#add_eof_marker_textprop()
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

" Gコマンドかどうかを判定する関数
function! eof_marker#is_g_command_movement(bufnr, content_last_line)
  " 最後に記録された位置が最後のコンテンツ行でない場合、Gコマンドと判断
  if has_key(s:last_cursor_pos, a:bufnr)
    let [last_line, last_col] = s:last_cursor_pos[a:bufnr]
    return last_line != a:content_last_line
  endif
  return 0
endfunction

" カーソル位置を記録する関数
function! s:record_cursor_position(bufnr, line, col, eof_line)
  if a:line != a:eof_line
    let s:last_cursor_pos[a:bufnr] = [a:line, a:col]
  endif
endfunction

" Gコマンド用のカーソル移動
function! s:handle_g_command_movement(content_last_line)
  call cursor(a:content_last_line, 1)
endfunction

" 通常移動用のカーソル復元
function! s:handle_normal_movement(bufnr, content_last_line)
  if has_key(s:last_cursor_pos, a:bufnr)
    let [last_line, last_col] = s:last_cursor_pos[a:bufnr]
    call cursor(last_line, last_col)
  else
    " フォールバック: 最後の行の先頭に移動
    call cursor(a:content_last_line, 1)
  endif
endfunction

" カーソルがEOFマーカー上に移動するのを防ぐ
function! eof_marker#prevent_cursor_on_eof()
  let bufnr = bufnr('%')

  if !has_key(s:eof_markers, bufnr)
    return
  endif

  let current_line = line('.')
  let current_col = col('.')
  let marker = s:eof_markers[bufnr][0]

  if !has_key(marker, 'eof_line')
    return
  endif

  let eof_line = marker.eof_line
  let content_last_line = eof_line - 1

  " 現在の位置を記録（EOFマーカー行でない場合のみ）
  call s:record_cursor_position(bufnr, current_line, current_col, eof_line)

  " EOFマーカーの行にカーソルがある場合の処理
  if current_line == eof_line
    if eof_marker#is_g_command_movement(bufnr, content_last_line)
      " Gコマンド: 最後の行の先頭に移動
      call s:handle_g_command_movement(content_last_line)
    else
      " 通常の移動（jキーなど）: 最後に記録された有効な位置に戻す
      call s:handle_normal_movement(bufnr, content_last_line)
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

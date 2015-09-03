" File: autoload/clang_format.vim
" Description: clang-format support for VIM
" Author: Christophe Juniet
" Repository: https://github.com/cjuniet/clang-format.vim
" License: http://creativecommons.org/licenses/by/4.0/

if (!exists('g:clang_format_style'))
  let g:clang_format_style = 'Google'
endif

function! clang_format#TrimWhitespaces()
  let c = getpos('.')
  let _s = @/
  %s/\s\+$//e
  let @/ = _s
  call setpos('.', c)
  nohl
endfunction

function! clang_format#Reformat(is_visual) range
  if (&ft == 'c' || &ft == 'cpp')
    if (executable("clang-format") != 1)
      echo "ClangFormat: clang-format executable not found"
      return
    end

    " Build the command line
    let cmd = "clang-format -fallback-style=none -style=" . shellescape(g:clang_format_style)
    let pos = line2byte(line('.')) + col('.') - 2
    let cmd = cmd . " -cursor=" . pos

    if (len(bufname('%')) > 0)
      let cmd = cmd . " -assume-filename=" . shellescape(bufname('%'))
    endif

    if (a:is_visual)
      let cmd = cmd . " -lines=" . a:firstline . ":". a:lastline
    endif

    " Get the reformatted lines
    let oldlines = getline(1, '$')
    let ret = system(cmd, join(oldlines, "\n"))
    let lines = split(ret, "\n")

    " Parse the new cursor position
    let yaml = remove(lines, 0)
    let newpos = matchstr(yaml, '"Cursor": \zs\d\+\ze')
    if (newpos == "")
      echo "ClangFormat: unable to format buffer with style=" . shellescape(g:clang_format_style)
      return
    endif

    " Add or replace modified lines
    let n = len(lines)
    let m = len(oldlines)
    let i = 0
    while (i < n)
      if (i >= m)
        call append(line('$'), lines[i])
      elseif (lines[i] != oldlines[i])
        call setline(i+1, lines[i])
      endif
      let i = i + 1
    endwhile

    " Remove any remaining lines
    if (i < m)
      let i = i + 1
      silent execute i . ",$d _"
    end

    " Restore cursor position
    execute "goto" (newpos+1)
  else
    " For other filetypes, just remove trailling spaces
    call clang_format#TrimWhitespaces()
  endif
endfunction

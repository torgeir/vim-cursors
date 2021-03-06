if exists("g:cursors_loaded")
  finish
endif
let g:cursors_loaded = 1

let s:previousMarks = []
let s:marks = []
let s:highlights = []
let s:highlightColor = "Search"

" sets a mark at the current cursor position
function! s:SetMark()
  let l:mark = getpos(".")
  call s:AddMark(l:mark)
  call s:HighlightMark(l:mark)
  call s:LogPos("mark", l:mark)
endfunction

" adds a getpos() mark to the list of marks
function! s:AddMark(mark)
  call add(s:marks, a:mark)
endfunction

" clears out all marks and their highlight
function! s:ClearMarks()
  let s:current = 0
  let s:marks = []
  call s:RemoveHighlights()
  call s:Log("cleared")
endfunction

" highlights all marks in the list
function! s:HighlightMarks()
  call s:RemoveHighlights()

  for l:mark in s:marks
    call s:HighlightMark(mark)
  endfor
endfunction

" highlights a single mark in a line
function! s:HighlightMark(mark)
  let l:line = a:mark[1]
  let l:col  = a:mark[2]
  call add(s:highlights, matchadd(s:highlightColor, '\%'.l:line.'l\%'.l:col.'c.'))
endfunction

" removes highlights for all marks
function! s:RemoveHighlights()
  for l:highlight in s:highlights
    call s:RemoveHighlight(l:highlight)
  endfor
  let s:highlights = []
endfunction

" removes highlight for one mark, ignores nonexisting highlights
function! s:RemoveHighlight(highlight)
  try
    call matchdelete(a:highlight)
  catch /\V\^Vim(call):E803:/
    " ignore not found
  endtry
endfunction

" kills a single mark, removing it and its highlight
function! s:KillMark()
  let l:target = getpos(".")
  let l:newMarks = []

  for l:i in range(0, len(s:marks) - 1)
    let l:mark = s:marks[l:i]
    " re-add all that is not the killed one
    if l:mark[1] != l:target[1] || l:mark[2] != l:target[2]
      call add(l:newMarks, l:mark)
    else
      call s:LogPos("kill", l:target)
    endif
  endfor

  let s:marks = l:newMarks

  call s:HighlightMarks()

endfunction

" cycle through all marks, jumping to each one
let s:current = 0
function! s:CycleMarks(next)
  if a:next
    let s:current = (s:current + 1) % len(s:marks)
  else
    let s:current = (s:current - 1) % len(s:marks)
  endif
  call s:GotoMark(s:current)
endfunction

" move the cursor to a mark
function! s:GotoMark(n)
  if a:n >= len(s:marks)
    call s:Log("no mark", a:n)
    return
  endif

  let l:mark = s:marks[a:n]
  call setpos(".", l:mark)

  call s:LogPos("goto", l:mark)
endfunction

" perform command at all marks
function! s:PerformCommand(command)

  " bail out
  if a:command ==# ""
    call s:Log("abort")
    return
  endif

  " in reverse helps for non overlapping deletes in the same line, so the marks do not move
  for l:mark in reverse(s:marks)
    call s:PerformCommandAtMark(l:mark, a:command)
  endfor

  call s:RemoveHighlights()

  " (naivly) fix marks that may have invalid positions after command has been
  for l:mark in s:marks
    call s:FixPositions(l:mark)
  endfor

  call s:HighlightMarks()

  call s:Log("performed :normal", a:command, "on", len(s:marks), "marks")
endfunction

" attempts to fix and update the position for invalid marks after commands have been run
function! s:FixPositions(mark)
  let l:lineLength = strlen(getline(a:mark[1]))
  let l:markPos = a:mark[2]

  " end of line moved in front of  cursor
  if l:markPos >= l:lineLength
    " set mark to end of line
    let a:mark[2] = l:lineLength
  endif
endfunction

" perform a command in normal mode based on what the user typed
function! s:PerformCommandAtMark(mark, command)
  call setpos(".", a:mark)
  exe "normal! " . a:command
endfunction

" log current marks and highlights
function! s:LogMarks()
  call s:Log("log", s:marks, s:highlights)
endfunction

" log a mark's position
function! s:LogPos(text, mark)
  call s:Log(a:text, a:mark[2] . "," . a:mark[1])
endfunction

" vararg debug function
function! s:Log(...)
  echo "marks: " . join(a:000, " ")
endfunction

function! s:SetMarkForNextSearch(str)
  " move to start of word
  normal eb

  call s:SetMark()

  " keep the search, so manual movement works
  let @/ = a:str

  " move to next match"
  call search(a:str, "W")
endfunction

function! s:SetMarksForSearch(str)
  " set a mark
  normal mc

  " jump to col 0 line 0
  normal gg

  " set marks for search
  while search(a:str, "W") > 0
    call s:SetMark()
  endwhile

  " jump back
  normal `c
endfunction

noremap <unique> <silent> <Plug>CursorsClearMarks :call <SID>ClearMarks()<cr>
noremap <unique> <silent> <Plug>CursorsHighlightMarks :call <SID>HighlightMarks()<cr>
noremap <unique> <silent> <Plug>CursorsKillMark :call <SID>KillMark()<cr>
noremap <unique> <silent> <Plug>CursorsLogMarks :call <SID>LogMarks()<cr>
noremap <unique> <silent> <Plug>CursorsPerformCommand :call <SID>PerformCommand(input(":normal "))<cr>
noremap <unique> <silent> <Plug>CursorsCycleMarksNext :call <SID>CycleMarks(1)<cr>
noremap <unique> <silent> <Plug>CursorsCycleMarksPrev :call <SID>CycleMarks(0)<cr>
noremap <unique> <silent> <Plug>CursorsSetMark :call <SID>SetMark()<cr>
noremap <unique> <silent> <Plug>CursorsSetMarksForSearch :silent call <SID>SetMarksForSearch("<c-r><c-w>")<cr>
noremap <unique> <silent> <Plug>CursorsSetMarkForNextSearch :silent call <SID>SetMarkForNextSearch("<c-r><c-w>")<cr>

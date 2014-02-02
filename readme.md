# A simplistic multiple cursors implementation for vim

This plugin lets you set cursors around your document, or for all occurrences of the word under the cursor i your document and perform normal mode commands on all of them at once.

E.g. use, define these mappings in your .vimrc

    nmap <c-c><c-d> <Plug>CursorsClearMarks
    nmap <c-c><c-h> <Plug>CursorsHighlightMarks
    nmap <c-c><c-k> <Plug>CursorsKillMark
    nmap <c-c><c-l> <Plug>CursorsLogMarks
    nmap <c-c><c-m> <Plug>CursorsPerformCommand
    nmap <c-c><c-n> <Plug>CursorsCycleMarksNext
    nmap <c-c><c-p> <Plug>CursorsCycleMarksPrev
    nmap <c-c><c-x> <Plug>CursorsSetMark
    nmap <c-c><c-w> <Plug>CursorsSetMarksForSearch

Todo:

- visual mode
- support moving cursors around
- handle commands overlapping cursors

licence: mit

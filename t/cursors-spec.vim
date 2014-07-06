source plugin/cursors.vim

describe "cursors"

  before
    new
    put! = ['some text', 'some more some text']
    normal gg
  end

  after
    exe "normal \<plug>CursorsClearMarks"
    close!
  end

  it "operates on one mark"
    normal j
    exe "normal \<esc>\<plug>CursorsSetMark"
    exe "normal \<esc>\<plug>CursorsPerformCommand dw"
    Expect getline("1") == "some text"
    Expect getline("2") == "more some text"
  end

  it "operates on global search for word under cursor"
    normal w
    exe "normal \<esc>\<plug>CursorsSetMarksForSearch"
    exe "normal \<esc>\<plug>CursorsPerformCommand dw"
    Expect getline("1") == "some "
    Expect getline("2") == "some more some "
  end

  it "operates on next occurence of word under cursor"
    exe "normal \<plug>CursorsSetMarkForNextSearch"
    exe "normal \<plug>CursorsSetMarkForNextSearch"
    exe "normal \<plug>CursorsSetMarkForNextSearch"
    exe "normal \<plug>CursorsPerformCommand dw"
    Expect getline("1") == "text"
    Expect getline("2") == "more text"
  end
end

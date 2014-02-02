source plugin/cursors.vim

describe "multiple cursors"

  before
    new
    put! = ['some text', 'some more text']
    normal gg
  end

  after
    close!
  end

  it "operates on one mark"
    exe "normal \<plug>CursorsSetMark"
    exe "normal \<plug>CursorsPerformCommand dw"
    Expect getline("1") == "text"
    Expect getline("2") == "some more text"
  end

  it "operates on search for word under cursor"
    exe "normal \<plug>CursorsSetMarksForSearch"
    exe "normal \<plug>CursorsPerformCommand dw"
    Expect getline("1") == "text"
    Expect getline("2") == "more text"
  end

end

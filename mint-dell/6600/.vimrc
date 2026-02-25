set wildmenu
set ruler
set number
set encoding=utf8
set incsearch
set showmode 
colorscheme murphy
syntax on
if &filetype == ""
  set filetype=html
  set guifont=Monospace\ 11
  endif

set diffexpr=MyDiff()
function MyDiff()
  let opt = ''
  if &diffopt =~ 'icase' | let opt = opt . '-i ' | endif
  if &diffopt =~ 'iwhite' | let opt = opt . '-b ' | endif
  silent execute '!C:\VIM\VIM61\diff -a ' . opt . v:fname_in . ' ' . v:fname_new . ' > ' . v:fname_out
endfunction

set printexpr=PrintFile(v:fname_in)
function PrintFile(fname)
  call system("gtklp " . a:fname)
  call delete(a:fname)
  return v:shell_error
endfunc

let g:closetag_html_style=1
source ~/.vim/scripts/closetag.vim

set omnifunc=csscomplete#CompleteCSS
set omnifunc=htmlcomplete#CompleteTags

" Execute pathogen for vim goodness.

execute pathogen#infect()

" Set color scheme.

colorscheme slate

" Set font.

set guifont=DejaVu\ LGC\ Sans\ Mono\ Bold\ 10

" Incremental search.

set incsearch

" Ignore case in searching.

set ic

" Enable all yntax highlighting.

syntax on

" Enable autoindent and all autoindent plugins.

filetype indent on
filetype indent plugin on

" 4 space tabs.

autocmd FileType perl set tabstop=4 softtabstop=4 expandtab shiftwidth=4 smarttab
autocmd FileType python set tabstop=4 softtabstop=4 expandtab shiftwidth=4 smarttab

" Show matching bracket.

autocmd FileType perl set showmatch

" Make tab, shift-tab, and backspace (visual mode) indent code.

vmap <tab> >gv
vmap <s-tab> <gv
vmap <bs> <gv

" Make tab, shift-tab, and backspace (normal mode) indent code.

"nmap I<tab><esc>
"nmap ^i<s-tab><esc>
"nmap ^i<bs><esc>

" Prevent text wrapping.

set textwidth=0
set wrapmargin=0

" Switch between split buffers.

map <C-Up> <C-W><Up><C-W>
map <C-Down> <C-W><Down><C-W>

" Save file.

map <F9> :w <cr>

" Toggle line numbers.

map <F10> :set nu! <cr>

" Previous file/next file.

map <F11> :N <cr>
map <F12> :n <cr>

" Disable current search highlighting by hitting return.
" Will be reenabled upon the next text search.

nnoremap <cr> :noh<cr><cr>

" Set up block commenting.
"   Press '-' to comment.
"   Press '_' to un-comment.
"   Select a region in visual mode or use the commands on
"      single lines while in normal (command) mode.

autocmd FileType * let b:comment = "#"
autocmd FileType vim let b:comment = "\""

nmap <expr> - AddComment()
nmap <expr> _ RemoveComment()
vmap <expr> - AddComment()
vmap <expr> _ RemoveComment()

func AddComment()
    let b:before=@/
    return InsertComment().RestorePatternMatch().":\r"
endfunc

func RemoveComment()
    let b:before=@/
    return ScrapeComment().RestorePatternMatch().":\r"
endfunc

func RestorePatternMatch()
    return ':let @/=b:before'."\r"
endfunc

func InsertComment()
    return ':s/^\(\s*\)/\1'.b:comment."\r"
endfunc

func ScrapeComment()
    return ':s/^\(\s*\)'.b:comment."/\\1/\r"
endfunc

"set autoindent
"set smartindent
"set ruler
"set linebreak
"set number
"set paste
"set laststatus=2
"set hlsearch
"
"autocmd BufNewFile,BufRead *.t set filetype=test
"autocmd BufNewFile,BufRead *.t source $VIMRUNTIME/syntax/perl.vim
"autocmd BufNewFile,BufRead *.tdy set filetype=perl
"autocmd BufNewFile,BufRead *.tdy source $VIMRUNTIME/syntax/perl.vim



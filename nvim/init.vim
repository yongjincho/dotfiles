" general
set encoding=utf-8
set number
set hidden

" highlight
syntax on
set hlsearch

" plugins (vim-plug)
call plug#begin('~/.local/share/nvim/plugged')
Plug 'jlanzarotta/bufexplorer'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'tpope/vim-fugitive'
Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'mhinz/vim-grepper', { 'on': ['Grepper', '<plug>(GrepperOperator)'] }
"Plug 'fatih/vim-go', { 'do': ':GoUpdateBinaries' }
call plug#end()

" airline
let g:airline_powerline_fonts=1
let g:airline_theme='solarized'
let g:airline_solarized_bg='dark'

" indentation
set expandtab
set softtabstop=4
set smartindent
set shiftwidth=4
filetype plugin indent on
autocmd Filetype javascript setlocal softtabstop=2 shiftwidth=2
autocmd Filetype html setlocal softtabstop=2 shiftwidth=2
autocmd Filetype vue setlocal softtabstop=2 shiftwidth=2

" shortcut to move to the next message in qiuckfix
map <F3> :cn<CR>

" cscope
if has("cscope")
    " cscope 결과를 quickfix창에서 보기
    "  c: find functions calling this symbol
    "  d: find functions called by this symbol
    "  e: find this egrep patterm
    "  i: find files #including this file
    "  s: find this C symbol
    "  t: find asssignments to
    set cscopequickfix=c-,d-,e-,i-,s-,t-
    " cscopetag
    set cscopetag
    if filereadable("cscope.out")
        cs add cscope.out
    endif
endif

" CoC
highlight CocFloating guibg=#eeeeee

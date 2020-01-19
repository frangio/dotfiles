call plug#begin('~/.local/share/nvim/plugged')
Plug 'tpope/vim-repeat'
Plug 'machakann/vim-sandwich'
Plug 'wellle/targets.vim'
Plug 'tpope/vim-unimpaired'
Plug 'romainl/vim-cool'
Plug 'junegunn/fzf.vim'
Plug 'tpope/vim-fugitive'
Plug 'editorconfig/editorconfig-vim'
Plug 'tpope/vim-obsession'
Plug 'joshdick/onedark.vim'
Plug 'dense-analysis/ale'
Plug 'haya14busa/vim-asterisk'
Plug 'frangio/tabcycle.vim'
Plug 'tpope/vim-commentary'

Plug 'pangloss/vim-javascript'
Plug 'leafgarland/typescript-vim'
Plug 'evanleck/vim-svelte'
Plug 'mustache/vim-mustache-handlebars'
Plug 'tomlion/vim-solidity'
Plug 'posva/vim-vue'
Plug 'stephpy/vim-yaml'
Plug 'chr4/nginx.vim'
Plug 'saltstack/salt-vim'
call plug#end()

set mouse=a
set wildmode=longest:full,full
set expandtab
set softtabstop=-1
set shiftwidth=2
set title
set ignorecase
set smartcase
set nojoinspaces
set cinoptions+=g0
set nostartofline
set hidden
set termguicolors

set signcolumn=yes
set completeopt-=preview
set completeopt+=noinsert,menuone

set sessionoptions-=buffers

set splitright
set scrolloff=10

inoremap <expr> <CR> (pumvisible() ? "\<C-Y>\<CR>" : "\<CR>")

command! -bang Q qa<bang>

augroup formatoptions_comments
  autocmd!
  autocmd FileType * setlocal fo-=r fo-=o
augroup end

if $TERM ==# 'linux'
    colorscheme desert
else
    colorscheme onedark
end

" targets
let g:targets_aiAI = 'aIAi'
augroup targets_braces
  autocmd!
  autocmd User targets#mappings#user call targets#mappings#extend({
        \ 'a': {'argument': [{'o': '[({[]', 'c': '[]})]', 's': ','}]}
        \ })
augroup end

" sandwich
runtime macros/sandwich/keymap/surround.vim
let g:sandwich#recipes = deepcopy(g:sandwich#default_recipes)
let g:sandwich#recipes += [
  \   {
  \     'buns': ['(', ')'],
  \     'cursor': 'head',
  \     'command': ['startinsert'],
  \     'kind': ['add', 'replace'],
  \     'action': ['add'],
  \     'input': ['f']
  \   },
  \ ]

" :grep
if executable('rg')
  set grepprg=rg\ --vimgrep\ --no-heading
  set grepformat^=%f:%l:%c:%m
endif

" fzf
nnoremap <silent> <C-P> :FZF<CR>
let g:fzf_history_dir = '~/.local/share/nvim/fzf-history'
augroup fzf
  autocmd!
  autocmd FileType fzf tnoremap <buffer> <C-Z> <Nop>
  " [TODO] respect previous user settings
  autocmd  FileType fzf set laststatus=0 noshowmode noruler
    \| autocmd BufLeave <buffer> set laststatus=2 showmode ruler
augroup end

function! s:MkNonExDir(file, buf)
    if empty(getbufvar(a:buf, '&buftype')) && a:file !~# '\v^\w+\:\/'
        let dir = fnamemodify(a:file, ':h')
        if !isdirectory(dir)
            call mkdir(dir, 'p')
        endif
    endif
endfunction

augroup BWCCreateDir
    autocmd!
    autocmd BufWritePre * :call s:MkNonExDir(expand('<afile>'), +expand('<abuf>'))
augroup END

function! s:Change(start, end, sub)
  let l:view = winsaveview()
  let l:escaped_sub = substitute(escape(a:sub, '/'), '\\$', '\\\\', '')
  execute a:start . ',' . a:end . 's//' . l:escaped_sub . '/g'
  call winrestview(l:view)
endfunction

command! -nargs=? -range=% Change call s:Change(<line1>, <line2>, <q-args>)

let g:netrw_banner = 0

let s:did_handle_swap = {}
function! s:handle_swap(abuf)
  if !has_key(s:did_handle_swap, a:abuf)
    let s:did_handle_swap[a:abuf] = v:true
    let v:swapchoice = 'o'
  endif
endfunction

augroup handle_swap
  autocmd!
  " [TODO] correctly handle multiple windows with the same buffer
  autocmd SwapExists * call s:handle_swap(expand("<afile>"))
augroup end

highlight Comment cterm=italic gui=italic
highlight Todo cterm=italic gui=italic

nnoremap <silent> <M-q> <Cmd>q<CR>
nnoremap <silent> <M-Q> <Cmd>qa<CR>
nnoremap <silent> <M-w> <Cmd>only<CR>

nnoremap <M-i> gT
nnoremap <M-o> gt
nnoremap <silent> <M-I> <Cmd>tabm -1<CR>
nnoremap <silent> <M-O> <Cmd>tabm +1<CR>

nnoremap <M-h> <C-W>h
nnoremap <M-j> <C-W>j
nnoremap <M-k> <C-W>k
nnoremap <M-l> <C-W>l

cnoremap <M-b> <S-Left>
cnoremap <M-f> <S-Right>

cnoremap <C-P> <Up>
cnoremap <C-N> <Down>

cnoremap <expr> <M-.> expand('%:h') . '/'

nnoremap - <Cmd>e %:h<CR>

" auto load session
function! s:load_session()
  let l:session_dir = stdpath('data') . '/session/'
  let l:session_file = l:session_dir . substitute(getcwd(), '/\|%\zs', '%', 'g')
  let l:session_file_escaped = fnameescape(l:session_file)
  let l:session_exists = filereadable(l:session_file)

  if @% ==# '' && !&modified && l:session_exists
    silent execute 'source' l:session_file_escaped
  endif

  if !l:session_exists && !v:this_session
    call mkdir(l:session_dir, 'p')
    silent execute 'Obsession' l:session_file_escaped
  endif
endfunction

augroup LoadSession
  autocmd!
  autocmd VimEnter * nested call s:load_session() | autocmd! LoadSession
augroup end

" ale
let g:ale_completion_enabled = 1
let g:ale_linters = { 'rust': ['rls'] }
nmap <silent> <C-]> <Cmd>call <SID>go_to_definition(v:false)<CR>
nmap <silent> <C-w><C-]> <Cmd>call <SID>go_to_definition(v:true)<CR>
nmap <silent> zv <Cmd>ALEDetail<CR>
nmap <silent> zh <Cmd>ALEHover<CR>

" disable go to definition when tags are available
augroup ALEDisableGoToDefinition
  autocmd!
  autocmd FileType help nnoremap <buffer> <C-]> <C-]>
augroup end

function! s:go_to_definition(in_tab)
  call s:truncate_tagstack()
  if a:in_tab
    ALEGoToDefinitionInTab
  else
    ALEGoToDefinition
  endif
endfunction

function! s:truncate_tagstack()
  let l:winnr = winnr()
  let l:tagstack = gettagstack(l:winnr)
  if l:tagstack.curidx <= l:tagstack.length
    unlet l:tagstack.items[l:tagstack.curidx - 1:]
  endif
  call settagstack(l:winnr, l:tagstack)
endfunction

" vim-asterisk
map *  <Plug>(asterisk-z*)
map #  <Plug>(asterisk-z#)
map g* <Plug>(asterisk-gz*)
map g# <Plug>(asterisk-gz#)

function! s:Term(mods, cmd)
  exec a:mods "vnew | term" a:cmd

  if len(a:cmd) == 0
    startinsert
  endif
endfunction

command! -nargs=? T call s:Term(<q-mods>, <q-args>)

command! -nargs=? Rg <mods> T rg <args>

augroup FugitiveMappings
  autocmd!
  autocmd FileType fugitive nnoremap <silent> <buffer> q <C-w>q
augroup end

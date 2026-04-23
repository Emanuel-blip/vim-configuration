" =============================================================================
" VIM CONFIGURATION
" Author: Yenovq Hakobyan
" Purpose: Development environment for C/C++, JS, LaTeX, and Verilog
" =============================================================================

" -----------------------------------------------------------------------------
" 1. Core Editor Settings
" -----------------------------------------------------------------------------
function! s:SetupCoreSettings()
    set expandtab                          " Use spaces instead of tabs
    set ruler                              " Show cursor position in status line
    set shortmess+=I                       " Disable the default Vim intro message
    set lazyredraw                         " Don't redraw screen during macros/scripts
    set incsearch                          " Highlight search matches as you type
    set ttyfast                            " Improve terminal scrolling/redrawing
    set list                               " Show invisible characters
    set listchars=tab:»·,trail:·,nbsp:⍽

    filetype plugin indent on    " Enable filetype-specific detection
    syntax on                    " Enable syntax highlighting
endfunction
call s:SetupCoreSettings()

" -----------------------------------------------------------------------------
" 2. Plugin Management (vim-plug)
" -----------------------------------------------------------------------------
function! s:InitializePlugins()
    call plug#begin('~/.vim/plugged')

    " LSP and Intelligence
    Plug 'neoclide/coc.nvim', {'branch': 'release'}
    Plug 'github/copilot.vim'

    " Document Preparation
    Plug 'lervag/vimtex'

    " Web Development
    Plug 'alvan/vim-closetag'

    call plug#end()
endfunction

if empty(glob('~/.vim/autoload/plug.vim'))
    echo "Warning: vim-plug not found. Please install it to load plugins."
else
    call s:InitializePlugins()
endif

" -----------------------------------------------------------------------------
" 3. External Tool Configurations
" -----------------------------------------------------------------------------
" Link Copilot to the Node.js executable
let g:copilot_node_command = '/home/yenovq/.nix-profile/bin/node'

" Prettier and CoC global settings
let g:coc_diagnostic_enable = 1
let g:coc_border_join_chars = ['─', '│', '┌', '┐', '┘', '└']


" -----------------------------------------------------------------------------
" 4. Visuals and Interface Highlighting
" -----------------------------------------------------------------------------
function! s:ApplyUIStyles()
    " Refine completion menu appearance
    highlight Pmenu ctermbg=236 ctermfg=251
    highlight PmenuSel ctermbg=240 ctermfg=255
    highlight CocFloating ctermbg=235

    " Highlight diagnostic icons for CoC
    highlight CocSuggestTypeInfo ctermfg=Cyan guifg=#1890ff
    highlight CocSymbolDefault ctermfg=Magenta guifg=#fb4934

    " Visualize bad whitespace (e.g., non-breaking spaces)
    highlight BadWhitespace ctermbg=red guibg=red
    match BadWhitespace /\%u00a0/
endfunction
call s:ApplyUIStyles()

" -----------------------------------------------------------------------------
" 5. Language and Localization (Armenian Support)
" -----------------------------------------------------------------------------
function! ToggleArmenian()
    if &keymap == "armenian-phonetic_utf-8"
        set keymap=
        echo "Keymap: English"
    else
        set keymap=armenian-phonetic_utf-8
        echo "Keymap: Armenian"
    endif
endfunction

" Mappings for language switching
nnoremap <C-L> :call ToggleArmenian()<CR>
inoremap <C-L> <C-O>:call ToggleArmenian()<CR>

" -----------------------------------------------------------------------------
" 6. Programming Language Profiles
" -----------------------------------------------------------------------------

" Profile for C and C++ (Kernel/Strict style)
function! s:InstigateCodingStyle()
    setlocal lazyredraw
    setlocal expandtab
    setlocal softtabstop=8
    setlocal tabstop=8
    setlocal shiftwidth=8
    setlocal textwidth=80
    setlocal cindent
    setlocal colorcolumn=80
endfunction

" Profile for Web Technologies (JS/HTML)
function! s:ToggleHtmlTools()
    setlocal tabstop=2
    setlocal shiftwidth=2
    setlocal textwidth=80
    setlocal colorcolumn=81
    setlocal expandtab
endfunction

" Profile for LaTeX (Scientific writing)
function! s:ConfigureVimTeX()
    let g:vimtex_quickfix_open_on_warning = 0
    let g:vimtex_quickfix_mode = 2
    let g:vimtex_compiler_method = 'latexmk'
    let g:vimtex_compiler_latexmk = {
        \ 'build_dir'  : '',
        \ 'callback'   : 1,
        \ 'continuous' : 1,
        \ 'executable' : 'latexmk',
        \ 'options'    : [
        \   '-pdfxe',
        \   '-verbose',
        \   '-file-line-error',
        \   '-synctex=1',
        \   '-interaction=nonstopmode',
        \ ],
        \ }
endfunction

" Automation: Apply profiles based on file extension
augroup FileTypeProfiles
    autocmd!
    autocmd FileType c,cpp call s:InstigateCodingStyle()
    autocmd FileType html,javascript call s:ToggleHtmlTools()
    autocmd FileType tex call s:ConfigureVimTeX()
augroup END


" -----------------------------------------------------------------------------
" 7. Typing Assistants and Smart Mappings
" -----------------------------------------------------------------------------

" Bracket Auto-closing
inoremap ( ()<Left>
inoremap [ []<Left>
inoremap { {}<Left>
inoremap " ""<Left>
inoremap ' ''<Left>

" Smart Newline within curly braces
inoremap <expr> <CR> getline('.')[col('.')-2:col('.')-1] == '{}' ? "\<CR>\<CR>\<Up>" : "\<CR>"

" Smart Jump-out: Tab through pairs or perform normal Tab
function! s:SkipPair()
    let l:char = getline('.')[col('.') - 1]
    if index([')', '}', ']', '"', "'", '>'], l:char) != -1
        return "\<Right>"
    else
        return "\<Tab>"
    endif
endfunction

inoremap <expr> <Tab> <SID>SkipPair()

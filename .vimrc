" =============================================================================
" VIM CONFIGURATION
" Author: Yenovq Hakobyan
" Purpose: Development environment for C/C++, JS and XeLaTeX
" Created: 2026-06-01
" =============================================================================

" -----------------------------------------------------------------------------
" 1. Core Editor Settings
" -----------------------------------------------------------------------------

set expandtab                        " Use spaces instead of tabs
set ruler                            " Show cursor position in status line
set lazyredraw                       " Don't redraw screen during macros/scripts
set incsearch                        " Highlight search matches as you type
set list                             " Show invisible characters
set listchars=tab:»·,trail:·,nbsp:⍽
set directory=~/.vim/tmp             " Move swp files to a centralized directory
set updatetime=300                   " Faster diagnostic updates (LSP)
set synmaxcol=300                    " Limit syntax highlighting to 300 columns
set redrawtime=1500                  " Timeout for complex syntax rendering

" Intelligent comment formatting
set comments=sl:/*,mb:\ *,elx:\ */

" Turn on syntax and filetype detection
syntax on
filetype plugin indent on

" Create swap directory if it doesn't exist
if !isdirectory(expand(&directory))
        call mkdir(expand(&directory), 'p')
endif

" -----------------------------------------------------------------------------
" 2. Plugin Management (vim-plug)
" -----------------------------------------------------------------------------

let s:plug_path = expand('~/.vim/autoload/plug.vim')
if !filereadable(s:plug_path)
    echo "Installing vim-plug..."
    silent execute '!curl -fLo ' . s:plug_path . ' --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
    autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

call plug#begin('~/.vim/plugged')
        " C++ Specific Plugins
        Plug 'bfrg/vim-cpp-modern'  " Enhanced syntax for modern C++

        " Language Server Protocol
        Plug 'yegappan/lsp'

        " AI Assistance
        Plug 'github/copilot.vim'

        " Document Preparation
        Plug 'lervag/vimtex'

        " Web Development
        Plug 'alvan/vim-closetag' " Close tags in HTML

        " Editing Utilities
        Plug 'tpope/vim-surround'
call plug#end()

" -----------------------------------------------------------------------------
" 3. External Tool Configuration
" -----------------------------------------------------------------------------

" Link Copilot to the Node.js executable
let g:copilot_node_command = '/home/yenovq/.nix-profile/bin/node'

" VimTeX must be configured at script level (read at plugin-load time)
let g:vimtex_view_method = 'zathura'
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

" -----------------------------------------------------------------------------
" 4. Visuals and Interface Highlighting
" -----------------------------------------------------------------------------

function! s:ApplyUIStyles() abort
    " -- Completion Menu (Pmenu) - Modern Deep Dark Theme --
    highlight Pmenu      guibg=#1e1e2e guifg=#cdd6f4 ctermbg=235  ctermfg=252
    highlight PmenuSel   guibg=#313244 guifg=#89b4fa gui=bold ctermbg=238  ctermfg=255  cterm=bold
    highlight PmenuSbar  guibg=#181825 ctermbg=235
    highlight PmenuThumb guibg=#585b70 ctermbg=243
    highlight PmenuKind  guibg=#1e1e2e guifg=#a6adc8 ctermbg=235  ctermfg=245
    highlight PmenuExtra guibg=#1e1e2e guifg=#7f849c ctermbg=235  ctermfg=243

    " -- Kind-specific colors (Catppuccin inspired vibrant colors) --
    highlight PmenuKindKeyword   guibg=#1e1e2e guifg=#f38ba8 ctermbg=235 ctermfg=168
    highlight PmenuKindFunction  guibg=#1e1e2e guifg=#a6e3a1 ctermbg=235 ctermfg=114
    highlight PmenuKindVariable  guibg=#1e1e2e guifg=#89b4fa ctermbg=235 ctermfg=117
    highlight PmenuKindClass     guibg=#1e1e2e guifg=#f9e2af ctermbg=235 ctermfg=179
    highlight PmenuKindModule    guibg=#1e1e2e guifg=#cba6f7 ctermbg=235 ctermfg=176
    highlight PmenuKindField     guibg=#1e1e2e guifg=#94e2d5 ctermbg=235 ctermfg=73
    highlight PmenuKindStruct    guibg=#1e1e2e guifg=#fab387 ctermbg=235 ctermfg=215
    highlight PmenuKindInterface guibg=#1e1e2e guifg=#a6e3a1 ctermbg=235 ctermfg=150
    highlight PmenuKindEnum      guibg=#1e1e2e guifg=#f9e2af ctermbg=235 ctermfg=180

    " -- LSP Diagnostic Signs --
    highlight LspDiagSignErrorText   guifg=#f38ba8 guibg=NONE gui=bold ctermfg=167 ctermbg=NONE cterm=bold
    highlight LspDiagSignWarningText guifg=#f9e2af guibg=NONE gui=NONE ctermfg=214 ctermbg=NONE cterm=NONE
    highlight LspDiagSignInfoText    guifg=#89b4fa guibg=NONE gui=NONE ctermfg=75  ctermbg=NONE cterm=NONE
    highlight LspDiagSignHintText    guifg=#94e2d5 guibg=NONE gui=NONE ctermfg=108 ctermbg=NONE cterm=NONE

    " -- LSP Diagnostic Inline --
    highlight LspDiagInlineError   gui=undercurl guisp=#f38ba8 cterm=undercurl ctermfg=167
    highlight LspDiagInlineWarning gui=undercurl guisp=#f9e2af cterm=undercurl ctermfg=214
    highlight LspDiagInlineInfo    gui=underline guisp=#89b4fa cterm=underline ctermfg=75
    highlight LspDiagInlineHint    gui=underline guisp=#94e2d5 cterm=underline ctermfg=108

    " -- LSP Popups (hover, diagnostics) --
    highlight LspPopup        guibg=#1e1e2e guifg=#cdd6f4 ctermbg=236 ctermfg=252
    highlight LspPopupBorder  guibg=#1e1e2e guifg=#cba6f7 ctermbg=236 ctermfg=99

    " -- LSP References & Inlay Hints --
    highlight LspTextRef  guibg=#313244 guifg=NONE gui=NONE ctermbg=238 ctermfg=NONE cterm=NONE
    highlight LspReadRef  guibg=#313244 guifg=NONE gui=NONE ctermbg=238 ctermfg=NONE cterm=NONE
    highlight LspWriteRef guibg=#45475a guifg=NONE gui=bold ctermbg=52  ctermfg=NONE cterm=bold
    highlight LspInlayHintsType  guifg=#7f849c guibg=NONE gui=italic ctermfg=243 ctermbg=NONE cterm=italic
    highlight LspInlayHintsParam guifg=#7f849c guibg=NONE gui=italic ctermfg=243 ctermbg=NONE cterm=italic

    " -- LSP Symbol Highlighting --
    highlight LspSymbolName  guifg=#89b4fa gui=bold ctermfg=117 cterm=bold
    highlight LspSymbolRange guibg=#313244 gui=NONE ctermbg=238 cterm=NONE
    highlight LspSigActiveParameter guifg=#fab387 gui=bold,underline ctermfg=215 cterm=bold,underline

    " -- Misc --
    highlight BadWhitespace cterm=bold gui=bold
    highlight link BadWhitespace Error
endfunction

augroup CustomUI
    autocmd!
    autocmd VimEnter,ColorScheme * call s:ApplyUIStyles()
    autocmd VimEnter,WinEnter,BufWinEnter * if hlexists('BadWhitespace') | match BadWhitespace /\%u00a0/ | endif
augroup END

" -----------------------------------------------------------------------------
" 5. Language and Localization (Armenian Support)
" -----------------------------------------------------------------------------

function! ToggleArmenian() abort
    if &keymap ==# "armenian-phonetic_utf-8"
        set keymap=
        echo "Keymap: English"
    else
        set keymap=armenian-phonetic_utf-8
        echo "Keymap: Armenian"
    endif
endfunction

nnoremap <C-L> :call ToggleArmenian()<CR>
inoremap <C-L> <C-O>:call ToggleArmenian()<CR>

" -----------------------------------------------------------------------------
" 6. Language Server Protocol (yegappan/lsp)
" -----------------------------------------------------------------------------

let s:clang_res = system("clang -print-resource-dir 2>/dev/null | tr -d '\n'")
let s:clangd_args = [
        \   '--background-index',
        \   '--clang-tidy=false',
        \   '--header-insertion=iwyu',
        \   '--completion-style=detailed',
        \   '--pch-storage=memory',
        \   '--query-driver=**'
        \ ]

if !empty(s:clang_res) && v:shell_error == 0
    call add(s:clangd_args, '-resource-dir=' . s:clang_res)
endif

let s:lspServers = [
        \ {
        \   'filetype': ['c', 'cpp', 'h', 'hpp'],
        \   'path': 'clangd',
        \   'args': s:clangd_args
        \ }
        \ ]

let s:lspOpts = {
        \ 'useBufferCompletion': v:true,
        \ 'autoComplete': v:true,
        \ 'omniComplete': v:true,
        \ 'completionMatcher': 'fuzzy',
        \ 'completionTextEdit': v:true,
        \ 'filterCompletionDuplicates': v:true,
        \
        \ 'autoHighlightDiags': v:true,
        \ 'highlightDiagInline': v:true,
        \ 'showDiagWithSign': v:true,
        \ 'showDiagWithVirtualText': v:false,
        \ 'diagVirtualTextAlign': 'above',
        \ 'showDiagInPopup': v:true,
        \ 'showDiagOnStatusLine': v:false,
        \
        \ 'diagSignErrorText': '✘',
        \ 'diagSignWarningText': '▲',
        \ 'diagSignInfoText': '●',
        \ 'diagSignHintText': '◆',
        \
        \ 'showSignature': v:true,
        \ 'showInlayHints': v:true,
        \ 'echoSignature': v:false,
        \
        \ 'autoHighlight': v:false,
        \ 'hoverInPreview': v:false,
        \
        \ 'popupBorder': v:true,
        \ 'popupBorderChars': ['─', '│', '─', '│', '╭', '╮', '╯', '╰'],
        \
        \ 'usePopupInCodeAction': v:true,
        \ 'keepFocusInReferences': v:true,
        \ 'keepFocusInDiags': v:true,
        \
        \ 'ignoreMissingServer': v:true
        \ }

augroup LspConfiguration
    autocmd!
    autocmd User LspSetup call LspOptionsSet(s:lspOpts)
    autocmd User LspSetup call LspAddServer(s:lspServers)
augroup END

" LSP key mappings (buffer-local, set in C/C++ profile below)
function! s:SetLspKeymaps() abort
    nnoremap <buffer><silent> gd <Cmd>LspGotoDefinition<CR>
    nnoremap <buffer><silent> gr <Cmd>LspShowReferences<CR>
    nnoremap <buffer><silent> K  <Cmd>LspHover<CR>
    nnoremap <buffer><silent> <leader>rn <Cmd>LspRename<CR>
    nnoremap <buffer><silent> [d <Cmd>LspDiagPrev<CR>
    nnoremap <buffer><silent> ]d <Cmd>LspDiagNext<CR>
endfunction

" -----------------------------------------------------------------------------
" 7. Programming Language Profiles
" -----------------------------------------------------------------------------

" Profile: C and C++ (Kernel/Strict style)
function! s:ConfigureCppTools() abort
    setlocal formatoptions-=ro          " No auto-inserting comment leaders
    setlocal expandtab
    setlocal softtabstop=8
    setlocal tabstop=8
    setlocal shiftwidth=8
    setlocal textwidth=80
    setlocal cindent
    setlocal colorcolumn=+1
    call s:SetLspKeymaps()
endfunction

" Profile: Web Technologies (JS/HTML)
function! s:ConfigureWebTools() abort
    setlocal expandtab
    setlocal tabstop=2
    setlocal shiftwidth=2
    setlocal textwidth=80
    setlocal colorcolumn=+1
    nnoremap <buffer> <Leader>ln <Cmd>call ToggleLiveServer()<CR>
endfunction

" Profile: LaTeX (configured via g:vimtex_* above)
function! s:ConfigureTeX() abort
    setlocal textwidth=80
    setlocal colorcolumn=+1
endfunction

augroup FileTypeProfiles
    autocmd!
    autocmd FileType c,cpp call s:ConfigureCppTools()
    autocmd FileType html,javascript call s:ConfigureWebTools()
    autocmd FileType tex call s:ConfigureTeX()
augroup END

" -----------------------------------------------------------------------------
" 8. Live Server Integration (Web Development)
" -----------------------------------------------------------------------------
"
" FIX: The --browser flag requires the ABSOLUTE PATH to the browser
"      executable. Passing just the name 'nightly' caused live-server's
"      internal `open` module (via child_process.exec) to fail silently
"      to locate the binary, falling back to the default browser.
"
"      Resolution: use '/usr/bin/nightly' (the actual symlink target).

let g:live_server_running = 0
let s:live_server_job = v:null

function! ToggleLiveServer() abort
    if g:live_server_running == 0
        let l:cmd = ['live-server', '--browser=/usr/bin/nightly']
        let s:live_server_job = job_start(l:cmd, {
        \   'stoponexit': 'term',
        \   'out_io': 'null',
        \   'err_io': 'null'
        \ })

        if job_status(s:live_server_job) ==# 'run'
            let g:live_server_running = 1
            echo "Live Server: Running"
        else
            echoerr "Live Server: Failed to start"
        endif
    else
        if s:live_server_job != v:null && job_status(s:live_server_job) ==# 'run'
            call job_stop(s:live_server_job, 'term')
        endif
        let g:live_server_running = 0
        let s:live_server_job = v:null
        echo "Live Server: Stopped"
    endif
endfunction

" -----------------------------------------------------------------------------
" 9. Typing Assistants and Smart Mappings
" -----------------------------------------------------------------------------

" Bracket and quote auto-closing
inoremap ( ()<Left>
inoremap [ []<Left>
inoremap { {}<Left>
inoremap " ""<Left>
inoremap ' ''<Left>

" Enable completion menu globally, don't insert/select automatically
set completeopt=menu,menuone,noselect

" Smart newline within curly braces: { | } → { \n | \n }, also accept completion
inoremap <expr> <CR> pumvisible() ? "\<C-Y>" : (getline('.')[col('.')-2:col('.')-1] == '{}' ? "\<CR>\<CR>\<Up>" : "\<CR>")

" Smart jump-out: Tab skips over closing pairs, otherwise inserts Tab
function! SkipPair() abort
    let l:char = getline('.')[col('.') - 1]
    if index([')', '}', ']', '"', "'", '>'], l:char) != -1
        return "\<Right>"
    else
        return "\<Tab>"
    endif
endfunction

inoremap <expr> <Tab> pumvisible() ? "\<C-N>" : SkipPair()
inoremap <expr> <S-Tab> pumvisible() ? "\<C-P>" : "\<C-H>"

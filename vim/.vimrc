" Modeline and notes {{
"   vim: set foldmarker={{,}} foldlevel=0 spell:
"
"   This is James Pickard's .vimrc (http://github.com/euoia).
"
"   Thanks to Robert Melton (http://robertmelton.com/) for ideas on how to
"   organise this file.
" }}

" To control folds:
" Use zo to open the fold under the cursor.
" Use zc to close the current fold.
" Use zR to open all folds in the file.
" Use zM to close all folds in the file.

" VimPlug plugins {{
    " Plugins are installed using https://github.com/junegunn/vim-plug
    "
    " Plugins need to load before everything else because some settings
    " require plugins to be loaded (e.g. setting the colourscheme requires
    " vim-colorschemes).
    call plug#begin('~/.vim/plugged')

    " This plugin needs to be loaded before vim-colorschemes otherwise
    " summerfruit256 comes from vim-colorschemes.
    Plug 'git@github.com:euoia/summerfruit256.vim.git'

    Plug 'Shougo/neomru.vim'
    Plug 'Shougo/unite-outline'
    Plug 'Shougo/unite.vim'
    Plug 'Shougo/vimproc.vim'
    Plug 'SirVer/ultisnips'
    Plug 'Valloric/YouCompleteMe'
    Plug 'brookhong/DBGPavim'
    Plug 'euoia/toggle_maximize.vim'
    Plug 'flazz/vim-colorschemes'
    Plug 'git@github.com:euoia/alignify.git'
    Plug 'git@github.com:euoia/copyblock.git'
    Plug 'git@github.com:euoia/js-format.git'
    Plug 'git@github.com:euoia/vim-neosnippet-snippets.git'
    Plug 'groenewege/vim-less'
    Plug 'marijnh/tern_for_vim'
    Plug 'mustache/vim-mustache-handlebars'
    Plug 'pangloss/vim-javascript'
    Plug 'rking/ag.vim'
    Plug 'scrooloose/nerdcommenter'
    Plug 'scrooloose/nerdtree'
    Plug 'scrooloose/syntastic'
    Plug 'tpope/vim-abolish'
    Plug 'tpope/vim-fugitive'
    Plug 'tpope/vim-markdown'
    Plug 'tsukkee/unite-tag'
    Plug 'vim-scripts/matchit.zip'
    Plug 'vim-scripts/mru.vim'
    Plug 'vim-scripts/sessionman.vim'
    Plug 'vim-scripts/taglist.vim'
    Plug 'kchmck/vim-coffee-script'
    Plug 'fatih/vim-go'
    call plug#end()

    " Disabling this for now. Many of the JavaScript snippets are annoying.
    " TODO go through and copy useful ones.
    " Plug 'honza/vim-snippets'
" }}

" Basics {{
	" A note on using Vim's help: to read more about any lines which say `set
	" something` type :h 'something' including the single quotes. For example,
    " :help 'nocompatible'.

    " Set the colorscheme. This may be overridden in ~/.gvimrc for GUI vims.
    colorscheme summerfruit256

    " Whether to be compatible with vi. For modern vims, generally
    " nocompatible is better because it provides more features. Compatibility
    " with vi is an option, if you require that.
    set nocompatible

    " Whether to use .vimrc configuration from vim's current directory.
    " Enabling exrc is a security risk since a rogue .vimrc can execute
    " commands inside your editor.
    set noexrc

    " Enable syntax highlighting.
    syntax on

    " Which character to use when mappings say <leader>. The comma is a common
    " choice.
    let mapleader=','

    " When searching, whether to wrap around and search from the start when
    " the end of file is reached. If this is off, only the lines after the
    " cursor are searched. Having this enabled can be a bit disorienting.
    " Use `n` for next match and `N` for previous match. Use `/ to search
    " forwards and `?` to search backwards.
    " wrapscan - wrap around when searching.
    " nowrapscan - do not wrap around when searching.
    set nowrapscan

    " Which program to use when using :grep. There are some good alternatives
    " to `grep`. For example: ack, ag.
    set grepprg=ag\ --smart-case\ --nocolor\ --nogroup\ --column

    " This option tells vim how to interpret the output of grepprg. Whereabouts
    " the filename, line number is, etc,
    set grepformat=%f:%l:%c:%m

    " When making a substitution using :s, whether to change all occurrences
    " by default. When gdefault is enabled, using the `g` flag in a
    " substitution causes it to not act on all occurrences.
    set gdefault

    " This setting tells vim that it can make assumptions about the number of
    " colours available in terminal vim. This is not relevant for GUI vims.
    " All modern terminals (modern xterm, iterm etc) support `set t_CO=256`.
    set t_Co=256

    " Tags (see: ctags, exuberant ctags) are used by some plugins to provide a
    " list of keywords, (generally function names - see exuberant ctags
    " documentation). This option tells vim where to look for a tags file. The
    " tags file is an specific type of index that maps a tag to a filename.
    " This is used for jumping to a file using the command :tag. You can type
    " :tag <function name> and jump to its definition. When the cursor is on a
    " tag you can jump to the definition using C-].
    "
    " Look up the directory hierarchy for a tags file.
    set tags=./tags,tags,../tags,../../tags,../../../tags,
        \../../../../tags,../../../../../tags

    " Which register to use for yanked text.
    " unnamed - use the operating system clipboard.
    set clipboard=unnamed

    " This is a set of single character flags that enable certain
    " vi-compatible features.
    set cpoptions=aABceFsmq
    "             |||||||||
    "             ||||||||+-- When joining lines, leave the cursor
    "             |||||||     between joined lines
    "             |||||||+-- When a new match is created (showmatch)
    "             ||||||     pause for .5
    "             ||||||+-- Set buffer options when entering the
    "             |||||     buffer
    "             |||||+-- :write command updates current file name
    "             ||||+-- Automatically add <CR> to the last line
    "             |||     when using :@r
    "             |||+-- Searching continues at the end of the match
    "             ||     at the cursor position
    "             ||+-- A backslash has no special meaning in mappings
    "             |+-- :write updates alternative file name
    "             +-- :read updates alternative file name
" }}

" General {{
    " Whether to load filetype-specific settings. Vim itself comes with some
    " sensible default settings for many file types. If this is on, when one
    " of those file types is opened, the settings will be sourced from
    " $VIMRUNTIME/ftplugin/<file type>.vim.
    filetype plugin indent on

    " Whether to automatically switch the vim current working directory to the
    " directory of the current file.
    set noautochdir

    " Comma-separated list of settings for the behaviour of backspace. In vi,
    " for example, backspace cannot remove pre-existing characters in insert
    " mode.
    set backspace=indent,eol,start

    " Whether to make backup files of every file that is edited.
    set backup

    " Where to store backup files.
    set backupdir=~/.vim/backup

    " Where to store swap files.
    set directory=~/.vim/tmp

    " Which end-of-line character to use, in order of preference.
    set fileformats=unix,mac,dos

    " Whether to unload buffers when they are not in a window.
    " hidden - do not unload buffers.
    " nohidden - unload buffers.
    set hidden

    " Which characters are considered part of a "word" for the purpose of word
    " movements. It's sometimes a good idea to change this on a per-filetype
    " basis using autocmd.
    set iskeyword+=_,@,%,#

    " When to allow the mouse to be used. A string composed of
    " single-character flags. If empty, the mouse does not work.
    set mouse=

    " Whether to use the bell for error messages.
    set noerrorbells

    " Whether to use a visual bell instead of making a noise. To enable this
    " in GUI vims this needs to be set in ~/.gvimrc.
    set novisualbell

    " A comma-separated list of single-character flags which determine when
    " movement keys can move the cursor onto the next or previous line.
    set whichwrap=b,s,h,l,<,>,~,[,] " everything wraps
    "             | | | | | | | | |
    "             | | | | | | | | +-- "]" Insert and Replace
    "             | | | | | | | +-- "[" Insert and Replace
    "             | | | | | | +-- "~" Normal
    "             | | | | | +-- <Right> Normal and Visual
    "             | | | | +-- <Left> Normal and Visual
    "             | | | +-- "l" Normal and Visual (not recommended)
    "             | | +-- "h" Normal and Visual (not recommended)
    "             | +-- <Space> Normal and Visual
    "             +-- <BS> Normal and Visual
    "

    " Whether to show a menu for command completions. If this is off,
    " completions cycle without showing the list they are cycling through.
    set wildmenu

    " Comma-separated list specifying what to do when the completion menu is
    " displayed and 'wildchar' is entered.
    set wildmode=full

    " Comma-separated list of patterns. This tells vim which files to ignore
    " when completing filenames and directory names.
    set wildignore=*.dll,*.o,*.obj,*.bak,*.exe,*.pyc,
                    \*.jpg,*.gif,*.png,DEAD,.DS_Store

    " How many commands to remember in the history.
    set history=5000

    " Whether to automatically indent the cursor after pressing return.
    set autoindent

    " Whether to use persistent undo. Persistent undo keeps the undo history
    " even after a file is closed and reopened.
    set undofile

    " Which directory to store the undo history files in.
    set undodir=~/.vim/undo
" }}

" Vim UI {{
    " Whether to highlight the current column of the cursor.
    set nocursorcolumn

    " Whether to highlight the current line.
    set cursorline

    " Whether to incrementally search as each character is entered.
    set incsearch

    " Whether to show a status line (0=never, 1=sometimes, 2=always).
    set laststatus=2

     " Whether to redraw the screen when executing macros.
     " lazyredraw - do not redraw.
     " nolazyredraw - redraw.
    set lazyredraw

    " Number of additional pixels between lines.
    set linespace=0

    " Whether to show tab characters visually.
    set nolist

    " When 'list' is on, which characters to use.
    set listchars=tab:>-,trail:-

    " Whether to highlight matching brackets.
    set showmatch

    " Tenths of a second to blink matching brackets for.
    set matchtime=0

    " Whether to highlight all matches of the current search.
    set hlsearch

    " Whether to move the cursor to the start of line after some commands (see
    " help for full list).
    set nostartofline

    " Whether to show line numbers in the gutter.
    set number

    " Width of the line number gutter.
    set numberwidth=5

    " Threshold for reporting number lines changed.
    set report=0

    " Show cursor positions (overridden by 'statusline').
    set ruler

    " Number of lines to keep for scope at top and bottom of window.
    set scrolloff=10

    " Number of lines to keep for scope at side of window.
    set sidescrolloff=10

    " Settings for shortening messages; avoid 'press a key' prompt.
    set shortmess=aOstT

    " Whether to show the command being typed.
    set showcmd

    " What to show in the status line.
    " Note: I may override this to use output from functions provided by
    " plugins. For example, the TagList plugin provides a function which gives
    " the current function name.
    "
    " Each item starts with a % character.
    set statusline=%f%m%r\ [%p%%\ %Ll]%=%<%{substitute(getcwd(),$HOME,'~','')}
    "              | | | |  | | | |   | | |
    "              | | | |  | | | |   | | +--- Vim working directory.
    "              | | | |  | | | |   | |      (use ~ for $HOME).
    "              | | | |  | | | |   | |
    "              | | | |  | | | |   | +--- Truncate the line here.
    "              | | | |  | | | |   +--- Everything after this is right
    "              | | | |  | | | |        aligned.
    "              | | | |  | | | +--- Number of lines in the file.
    "              | | | |  | | +--- A space.
    "              | | | |  | +--- A percentage symbol.
    "              | | | |  +--- Percentage through file in lines.
    "              | | | +--- A space.
    "              | | +--- Show a flag if the file is readonly.
    "              | +--- Show a flag if the file is modified and unsaved.
    "              +--- The filename relative to vim's current directory.
" }}

" Text formatting and layout {{
    " Options for the insert-mode completion menu. Some completion plugins
    " (YouCompleteMe, NeoComplete) will override this behaviour.
    set completeopt=

    " String of single-character flags controlling the behaviour of vim's
    " formatting. Vim can automatically insert comment leaders with the
    " 'r' flag.
    set formatoptions=tcqr

    " Vim's help doesn't explain this clearly, but without the 'w' flag
    " formatting comments using 'gq' will indent the block a further level
    " since it treats it as what it calls a "paragraph".
    "
    " Disabled this because it leaves whitespace at the end of each line. I
    " haven't found a good solution.
    " set formatoptions+=w

    " Whether to be case-sensitive in searches.
    set ignorecase

    " Whether to be case-sensitive only when a search contains upper-case
    " characters.
    set smartcase

    " Same as smartcase but for insert-mode completions.
    set infercase

    " Whether to show long lines wrapped onto the next screen line.
    " wrap - Show long lines wrapped.
    " nowrap - Long lines go off the edge of the screen.
    set nowrap " do not wrap line

    " Tabs and spaces {{
        " These are just defaults. In many cases it's appropriate to override
        " these for specific file types using autocmd. Vim's tab and spacing
        " options are unfortunately a bit confusing. This page is helpful:
        " http://tedlogan.com/techblog3.html

        " Whether to use spaces or tabs for indentation.
        " expandtab - use spaces.
        " noexpandtab - use tabs.
        set noexpandtab

        " Number of spaces to use for each step of autoindenting and when
        " adjusting indent using visual-mode '>' and '<'.
        set shiftwidth=4

        " Whether to round indents to the nearest multiple of 'shiftwidth'.
        set shiftround

        " How many spaces a tab counts for in the display.
        set tabstop=4

        " Number of spaces to insert when pressing <tab> or
        " delete when pressing backspace.
        set softtabstop=4
    " }}
" }}

" Folding {{
    " Whether to enable folding.
    set foldenable

    " Comma separated pair of strings which indicate the start and end of a
    " fold. It is appropriate to override this on a per-file type basis.
    set foldmarker={,}

    " When to fold. Vim provides several options, see the help.
    set foldmethod=marker

    " The threshold for folding. Zero closes all folds. Higher numbers close
    " fewer folds.
    set foldlevel=100

    " Which types of commands open folds.
    set foldopen=block,mark,percent,quickfix,tag

    " This function is used to override the default text shown for a fold.
    " It returns the text to be displayed for the fold line.
    function! SimpleFoldText()
        return getline(v:foldstart).' '
    endfunction

    " What to display on fold lines.
    set foldtext=SimpleFoldText()
" }}

" Plugin specific settings {{
    " CopyBlock {{
        " CopyBlock copies a block of text with the filename and line number.
        if has("gui_macvim")
            vnoremap <D-C> :call CopyBlock()<cr>
        endif
    " }}
    " DBGPavim {{
        " DBGPavim is a PHP debugger.
        " PHP debugging from https://github.com/brookhong/DBGPavim
        let g:dbgPavimPort = 9009
        let g:dbgPavimBreakAtEntry = 0
    " }}
    " JsFormat {{
        " JsFormat reformats JavaScript code.
        autocmd FileType javascript let b:JsFormat_config = "~/.js-beautify.json"
        autocmd FileType javascript nmap <silent> <buffer> <F1> :JsFormat<cr>
        autocmd FileType javascript vmap <silent> <buffer> <F1> :JsFormat<cr>
    " }}
    " Fugitive {{
        " Fugitive provides lots of commands for working with git
        " repositories.

        " Copy branch name to clipboard.
        command! CPB let @*=fugitive#head()

        " Commit the current file. Pre-populates the commit message with the
        " ticket name. Assumes the branch name starts with the ticket name.
        function! GetFirstPartOfBranchName()
            let branchName = fugitive#head()
            let firstHyphen = stridx(branchName, '-')
            let secondHyphen = stridx(branchName, '-', firstHyphen + 1)
            return strpart(branchName, 0, secondHyphen)
        endfunction

        " Mappings. The trailing whitespace is intentional.
        nmap <D-2> :CT "=GetFirstPartOfBranchName()<cr> 
        nmap <Leader>c :CT "=GetFirstPartOfBranchName()<cr> 
    " }}
    " Matchit {{
        " Matchit extends vim's bracket matching capability.

        "  Whether to ignore case when matching a tag.
        let b:match_ignorecase = 1
    " }}
    " MRU (Most Recently Used) {{
        " MRU adds an :MRU command to show most recently used files.
        nnoremap <F2> :silent :MRU<cr>

        " Most recently used configuration.
        let MRU_Max_Entries=1000
    " }}
    " NERDTree {{
        " NERDTree is a filesystem viewer. It appears in a side window. It has
        " bookmarking and sensible keyboard shortcuts.
        let NERDTreeShowBookmarks=1

        " List of patterns to ignore.
        let NERDTreeIgnore=['\.vim$', '\~$', '^CVS$']

        " Do not clobber my mappings for next and previous tab.
        let NERDTreeMapJumpLastChild='\J'
        let NERDTreeMapJumpFirstChild='\K'

        " When to change vim's working directory.
        " 1 - Only change when NERDTree is first opened.
        " 2 - Whenever the root changes.
        let NERDTreeChDirMode=2

        " If NERDTree is the only window left, close it.
        function! CheckNERDTree()
            if bufname("%") =~ "NERD_tree"
                if len(tabpagebuflist()) == 1
                    :bd
                endif
            endif
        endfunction

        if has("gui_macvim")
            nnoremap <silent> <D-M> :NERDTreeMirror<cr>
            nnoremap <silent> <D-N> :NERDTreeToggle<cr>
        endif

        autocmd BufEnter * call CheckNERDTree()

        let NERDTreeIgnore += ['\.pyc$']
    " }}
    " Syntastic {{
        " Syntastic provides hooks for many static syntax checkers. It
        " highlights problems in the gutter.

        " Always populate the location list. Oddly, syntastic doesn't seem to
        " be able to use the error list.
        let g:syntastic_always_populate_loc_list=1

        " TCL {{
            let g:syntastic_tcl_checkers = ['nagelfar']

            " Ignore certain errors from nagelfar.
            let g:syntastic_tcl_nagelfar_conf='-filter "*Close brace not aligned*" -filter "*Suspicious \# char*"'
        " }}
        " JavaScript {{
            let g:syntastic_javascript_checkers = ['jshint']
        " }}
        " PHP {{
            " I removed phpmd because the "avoid excessively long variable
            " names" error was bothering me.
            let g:syntastic_php_checkers = ['php', 'phpcs']
        " }}
    " }}
    " TagList {{
        " TagList provides an "outline" of your files. It can show the
        " function names of the current file in a window at the side of the
        " screen.

        " Whether to open the tag list automatically.
        let Tlist_Auto_Open=0

        " Whether the tag list should update automatically.
        let Tlist_Auto_Update=1

        " Whether to use the small version of the menu.
        let Tlist_Compact_Format = 1

        " Path to ctags.
        let Tlist_Ctags_Cmd = '/usr/local/bin/ctags'

        " Whether to use folding.
        let Tlist_Enable_Fold_Column = 0

        " Whether to auto close folds.
        let Tlist_File_Fold_Auto_Close = 0

        " Whether to just show the current buffer's tags (as opposed to all
        " open buffers).
        let Tlist_Show_One_File = 1

        " Order tags by appearance within file.
        let Tlist_Sort_Type = "order"

        " Exit vim when TList is the only remaining window.
        let Tlist_Exist_OnlyWindow = 1

         " Split to the right side of the screen
        let Tlist_Use_Right_Window = 1

         " 40 columns wide, makes reading function names easier.
        let Tlist_WinWidth = 40

        " Faster highlighting of current tag in taglist window (default was 4000).
        set updatetime=100

        " Language specifics {{
            " Just functions, classes and constants. No variables.
            let tlist_php_settings = 'php;c:class;d:constant;f:function'

            " Tags for JavaScript. Requires custom .ctags. See
			" http://stackoverflow.com/questions/1790623/how-can-i-make-vims-taglist-plugin-show-useful-information-for-javascript
            let tlist_javascript_settings = 'javascript;r:var;s:string;a:array;o:object;u:function'
        " }}

        " Use a status line that includes TagList current tag.
        " Add this to get the current tag: %{Tlist_Get_Tagname_By_Line()}
        set statusline=%f%m%r\ %{Tlist_Get_Tagname_By_Line()}\ [%p%%\ %Ll]%=%<%(%)%{substitute(getcwd(),$HOME,'~','')}

        nnoremap <silent> <F4> :TlistToggle<cr>

        autocmd BufRead * TlistUpdate
    " }}
    " toggle_maximize {{
        " toggle_maximize provides a command to toggle between having the
        " current window maximized or not.
        nnoremap <silent> <C-F> :call ToggleMaximize()<cr>
    " }}
    " UltiSnippets {{
        " UltiSnips provides snippet completions. You can define snippets with
        " placeholders that you can tab through.
        let g:UltiSnipsSnippetsDir = "~/.vim/plugged/vim-neosnippet-snippets/MyUltiSnips"
        let g:UltiSnipsExpandTrigger = "<tab>"
        let g:UltiSnipsJumpForwardTrigger="<tab>"
        let g:UltiSnipsJumpBackwardTrigger="<s-tab>"
        let g:UltiSnipsSnippetDirectories=["MyUltiSnips", "UltiSnips"]
        let g:UltiSnipsEditSplit="horizontal"
    " }}
    " Unite {{
        " Unite is a fuzzy matcher for any source. It's very configurable, but
        " the most useful feature is opening files and jumping to tags. Unite
        " replaces CtrlP.
        " Unite does not suffer from this issue with CtrlP:
        " https://github.com/kien/ctrlp.vim/issues/562

        " Which kind of matcher to use.
        call unite#filters#matcher_default#use(['matcher_fuzzy'])

        " Which kind of ranking to use.
        call unite#filters#sorter_default#use(['sorter_rank'])

        " Define a "default" profile.
        call unite#custom#profile('default', 'context', {
            \ 'buffer_name': 'default',
            \ 'input': '',
            \ 'start_insert': 1,
            \ 'update_time': 0,
            \ 'direction': 'botright',
            \ 'prompt': '» ',
            \ 'winheight': 10})

        " For file_rec/async ignore published assets.
        call unite#custom#source(
            \ 'file_rec/async',
            \ 'ignore_pattern',
            \ '/Volumes/dev/copper/assets/.*')

        " Use the ag program for searching if it available.
        if executable('ag')
            let g:unite_source_grep_command='ag'
            let g:unite_source_grep_default_opts='--nocolor --nogroup -S -C4'
            let g:unite_source_grep_recursive_opt=''
            let g:unite_source_rec_async_command =
                    \ 'ag --follow --nocolor --nogroup --hidden -g ""'
        endif

        " Where to store the on-disk cache.
        let g:unite_data_directory='~/.vim/.cache/unite'

        " Keyboard shortcuts inside Unite.
        autocmd FileType unite imap <buffer> <ESC> <Plug>(unite_exit)
        autocmd FileType unite imap <buffer> <C-j> <Plug>(unite_select_next_line)
        autocmd FileType unite imap <buffer> <C-k> <Plug>(unite_select_previous_line)
        autocmd FileType unite imap <buffer> <C-r> <Plug>(unite_narrowing_input_history)

        " Normal mode keyboard shortcuts.
        if has("gui_macvim")
            " default: resume
            nnoremap <silent> <D-p> :Unite -resume -input= -profile-name=default buffer file_rec/async file_mru<cr>

            " with shift: do not resume
            nnoremap <silent> <D-P> :Unite -profile-name=default -input= buffer file_rec/async file_mru<cr>
        endif

        nmap <Leader>p :Unite -profile-name=default buffer file_rec/async file_mru<cr>
        nmap <Leader>b :Unite buffer<cr>

        " Tags (functions) in tags file.
        nmap <Leader>T :Unite -buffer-name=tag -resume tag<cr>

        " Tags (functions) in current file.
        nmap <Leader>t :Unite outline<cr>

        " Files in current directory (recursive).
        nmap <Leader>. :UniteWithCurrentDir file_rec<cr>

        " Files in directory of current buffer (recursive).
        nmap <Leader>e :UniteWithBufferDir file_rec<cr>

        " Most recently used files.
        nmap <leader>m :Unite file_mru<cr>
    " }}
    " unite-tag {{
        " unite-tag is a Unite extension for searching tags files.
        let g:unite_source_tag_max_name_length = 30
        let g:unite_source_tag_max_fname_length = 80
        let g:unite_source_tag_show_location = 0
    " }}
    " YouCompleteMe {{
        " YouCompleteMe provides completions through a separate process which
        " runs asynchronously. It works quite well, but needs to be compiled
        " and requires python.
        let g:ycm_key_list_select_completion = ['<Enter>', '<Down>']
    " }}

    " Disabled plugins {{
        " BufExplorer {{
            " BufExplorer provides a nice way to navigate open buffers.
            " Disabled because with Unite I don't need this.
            if 0
                let g:bufExplorerSplitHorzSize=8
                let g:bufExplorerSplitBelow=1

                nnoremap <silent> <F3> :BufExplorerHorizontalSplit<cr>
            endif
        " }}
        " CtrlP {{
            " Disabled in favour of Unite.
            if 0
                let g:ctrlp_max_files = 100000
                let g:ctrlp_map = '<D-p>'
                let g:ctrlp_mru_max = 10000
                let g:ctrlp_working_path_mode="r"
                nmap <Leader>m :CtrlPMRUFiles<cr>
                nmap <D-[> :exec "CtrlP " . expand('%:p:h')<cr>
            endif
        " }}
        " FuzzyFinder {{
            " Disabled in favour of Unite.
            " FuzzyFinder is like CtrlP. It provides fuzzy matching of files.
            if 0
                nmap <leader>E :FufFile<cr>
                nmap <leader>B :FufBuffer<cr>
                nmap <leader>F :FufFileWithCurrentBufferDir<cr>
                nmap <leader>T :FufBufferTag<cr>
                nmap <leader>M :FufMruFile<cr>
                let g:fuf_maxMenuWidth = 120
                let g:fuf_file_exclude = '\v\~$|\.(o|exe|dll|bak|orig|swp)$|(^|[/\\])\.(hg|git|bzr)($|[/\\])|CVS'

                if has("gui_macvim")
                    let g:fuf_buffertag_ctagsPath = '/usr/local/bin/ctags' " Mac OS X Path
                    let g:fuf_buffertag_ctagsPath = 'coretags' " Handle core style proc definitions
                endif
            endif
        " }}
        " NeoComplete {{
            " Disabled in favour of YouCompleteMe.
            " Trying to get this working was a frustrating experience. I don't
            " want the menu showing for everything I type, it's too slow and
            " distracting.
            if 0
                let g:neocomplete#enable_at_startup = 0
                let g:neocomplete#auto_completion_start_length = 4
                inoremap <expr><Tab>  neocomplete#start_manual_complete()
            endif
        " }}
        " NeoComplCache {{
            " Disabled because it makes changing buffers slow. As demonstrated by
            " removing it with:
            if 0
                au! neocomplcache BufEnter

                let g:neocomplcache_enable_auto_select = 1

                " Disable AutoComplPop.
                let g:acp_enableAtStartup = 0

                " Use neocomplcache.
                let g:neocomplcache_enable_at_startup = 1

                " Use smartcase.
                let g:neocomplcache_enable_smart_case = 1

                " Set minimum syntax keyword length.
                let g:neocomplcache_min_syntax_length = 3
                let g:neocomplcache_lock_buffer_name_pattern = '\*ku\*'

                " Define dictionary.
                let g:neocomplcache_dictionary_filetype_lists = {
                    \ 'default' : ''}

                " Define keyword.
                if !exists('g:neocomplcache_keyword_patterns')
                    let g:neocomplcache_keyword_patterns = {}
                endif
                let g:neocomplcache_keyword_patterns['default'] = '\h\w*'

                " Plugin key-mappings.
                inoremap <expr><C-g>     neocomplcache#undo_completion()
                inoremap <expr><C-l>     neocomplcache#complete_common_string()

                " Recommended key-mappings.
                function! s:my_cr_function()
                    return pumvisible() ? neocomplcache#close_popup() : "\<CR>"
                    " For no inserting <CR> key.
                    return neocomplcache#smart_close_popup() . "\<CR>"
                endfunction

                " <CR>: close popup and save indent.
                inoremap <silent> <CR> <C-r>=<SID>my_cr_function()<CR>

                " <TAB>: completion.
                inoremap <expr><TAB>  pumvisible() ? "\<C-n>" : "\<TAB>"

                " <C-h>, <BS>: close popup and delete backword char.
                inoremap <expr><C-h> neocomplcache#smart_close_popup()."\<C-h>"
                inoremap <expr><BS> neocomplcache#smart_close_popup()."\<C-h>"
                inoremap <expr><C-y>  neocomplcache#close_popup()
                inoremap <expr><C-e>  neocomplcache#close_popup()

                " Enable heavy omni completion.
                if !exists('g:neocomplcache_omni_patterns')
                    let g:neocomplcache_omni_patterns = {}
                endif

                if !exists('g:neocomplcache_omni_functions')
                    let g:neocomplcache_omni_functions = {}
                endif

                let g:tclUseOmniFunc = 1
                let g:neocomplcache_omni_functions['tcl'] = 'tclcomplete#Complete'
                let g:neocomplcache_omni_patterns['tcl'] = '.*'
                let g:tclcomplete_min_length = 6

                let g:neocomplcache_enable_auto_close_preview=0
            endif
        " }}
        " NeoSnippet {{
            " Disabled in favour of Ultisnips.
            if 0
                " Plugin key-mappings.
                imap <C-k>     <Plug>(neosnippet_expand_or_jump)
                smap <C-k>     <Plug>(neosnippet_expand_or_jump)
                xmap <C-k>     <Plug>(neosnippet_expand_target)

                " SuperTab like snippets behavior.
                " imap <expr><TAB> neosnippet#expandable_or_jumpable() ?
                "     \ "\<Plug>(neosnippet_expand_or_jump)"
                "     \: pumvisible() ? "\<C-n>" : "\<TAB>"
                " smap <expr><TAB> neosnippet#expandable_or_jumpable() ?
                "     \ "\<Plug>(neosnippet_expand_or_jump)"
                "     \: "\<TAB>"

                " Prioritise tab-next
                imap <expr><TAB> pumvisible() ?
                    \ "\<C-n>" :
                    \ neosnippet#expandable_or_jumpable() ?  "\<Plug>(neosnippet_expand_or_jump)" : "\<TAB>"

                smap <expr><TAB> pumvisible() ?
                    \ "\<C-n>" :
                    \ neosnippet#expandable_or_jumpable() ?  "\<Plug>(neosnippet_expand_or_jump)" : "\<TAB>"


                " For snippet_complete marker.
                if has('conceal')
                    set conceallevel=2 concealcursor=i
                endif

                " Enable snipMate compatibility feature.
                let g:neosnippet#enable_snipmate_compatibility = 1

                " Tell Neosnippet about the other snippets
                let g:neosnippet#snippets_directory='~/.vim/bundle/vim-snippets/snippets,~/.vim/bundle/euoia-vim-snippets'
            endif
        " }}
        " Vim powerline {{
            " Disabled because it was not displaying correctly.
            " Powerline provides a nice status line.
            if 0
                let g:Powerline_symbols = 'unicode'

                if has("gui_macvim")
                    set guifont=Monaco:h14
                endif
            endif
        " }}
    " }}
" }}

" Mappings {{
    " Disable the arrow keys {{
        map <down> <nop>
        map <left> <nop>
        map <right> <nop>
        map <up> <nop>
    " }}

    " Next and previous tab {{
        nnoremap <silent> K :tabnext<cr>
        nnoremap <silent> J :tabprevious<cr>
    " }}

    " Next and previous location / error / file{{
        " Location list. This is used for syntastic results.
        nnoremap <silent> <Up> :lprevious<cr>
        nnoremap <silent> <Down> :lnext<cr>

        " Error list. I use this for :grep results.
        nnoremap <silent> <C-p> :cprevious<cr>
        nnoremap <silent> <C-n> :cnext<cr>
    " }}

    " Open and split relative to current directory {{
        " Disabled because I wasn't using these.
        if 0
            nnoremap <Leader>e :e <C-R>=expand("%:p:h") . "/"<CR>
            nnoremap <Leader>t :tabe <C-R>=expand("%:p:h") . "/" <CR>
            nnoremap <Leader>s :split <C-R>=expand("%:p:h") . "/" <CR>
        endif
    " }}

    " Pull the next line onto this line. The default key is J but I have that
    " mapped to :tabprevious.
    nmap <silent> X :join<cr>

    " Create a new tab.
    nmap <silent> T :tabnew<cr>

    " Disable <esc>. Using <esc> forces your hand off the home row. Using jk
    " works well and is typed rarely enough that's it is not a bother.
    " From http://learnvimscriptthehardway.stevelosh.com/chapters/10.html
    inoremap jk <esc>
    inoremap <esc> <nop>

    " Use normal mode backspace to toggle between buffers.
    nmap <BS> 
" }}

" Additional file types {{
    " tmux
    augroup filetypedetect
        au BufNewFile,BufRead .tmux.conf*,tmux.conf* setf tmux
    augroup END

    augroup filetypedetect
        au BufNewFile,BufRead *.org setf org
    augroup END
" }}

" Filetype auto commands {{
    " Coffeescript {{
        autocmd FileType coffee setlocal shiftwidth=2
        autocmd FileType coffee setlocal softtabstop=2
        autocmd FileType coffee setlocal tabstop=2
        autocmd FileType coffee setlocal expandtab
    " }}
    " Ruby {{
        " ruby standard 2 spaces, always
        autocmd BufRead,BufNewFile *.rb,*.rhtml setlocal shiftwidth=2
        autocmd BufRead,BufNewFile *.rb,*.rhtml setlocal softtabstop=2
    " }}
    " Notes {{
        " I consider .notes files special, and handle them differently, I
        " should probably put this in another file
        au BufRead,BufNewFile *.notes set foldlevel=2
        au BufRead,BufNewFile *.notes set foldmethod=indent
        au BufRead,BufNewFile *.notes set foldtext=foldtext()
        au BufRead,BufNewFile *.notes set listchars=tab:\ \
        au BufRead,BufNewFile *.notes set noexpandtab
        au BufRead,BufNewFile *.notes set shiftwidth=8
        au BufRead,BufNewFile *.notes set softtabstop=8
        au BufRead,BufNewFile *.notes set tabstop=8
        au BufRead,BufNewFile *.notes set syntax=notes
        au BufRead,BufNewFile *.notes set nocursorcolumn
        au BufRead,BufNewFile *.notes set nocursorline
        "au BufRead,BufNewFile *.notes set guifont=Consolas:h12
        au BufRead,BufNewFile *.notes set spell
    " }}
    " TCL {{
        " TCL files use real tabs
        au FileType tcl setlocal iskeyword=@,48-57,_,192-255
        au FileType tcl setlocal tabstop=4
        au FileType tcl setlocal nolist
        au FileType tcl setlocal noexpandtab

        au FileType tcl setlocal foldtext=MyFoldText()
        au FileType tcl setlocal foldexpr=MyFoldLevel(v:lnum)
        au FileType tcl setlocal foldmethod=expr

        " au FileType tcl setlocal completeopt=menuone,preview

        " Treat the colon character as a keyword for the purposes of tag names.
        au FileType tcl nnoremap <silent> <C-]> :setlocal isk+=:<CR>:let word="<C-r>=expand('<cword>')<CR>"<CR>:setlocal isk-=:<CR>:tag  <C-r>=word<CR><CR>

        " au FileType tcl setlocal omnifunc=syntaxcomplete#Complete
        " au FileType tcl setlocal omnifunc=syntaxcomplete#Complete
        " au FileType tcl setlocal omnifunc=TclOmnifunc
        " let g:omni_syntax_group_exclude_tcl = 'tclVariable,tkBindSubstGroup,tkWidgetName,tclREClassGrouptclStuff,tclBraces,tclBrackets,tclComment,tclExpand,tclNumber,tclQuotes,tclSpecial,tkColor,tkEvent,tclSemiColon,tclLContinueOk,tclLContinueError'

        " Use a different regexp for ctags.
        au FileType tcl let b:Tlist_Ctags_Cmd = "/usr/local/bin/ctags --regex-tcl='/^[ \\t]*-proc_name[ \\t]*([a-zA-Z0-9_:]+)/\\1/p,procedure/'"
    " }}
    " Jade {{
        " Jade uses a tabstop of 2 chars
        au BufRead,BufNewFile *.jade setlocal tabstop=2
        au BufRead,BufNewFile *.jade setlocal shiftwidth=2
        au BufRead,BufNewFile *.jade setlocal softtabstop=2
    " }}
    " Html {{
        autocmd FileType html setlocal noexpandtab
        autocmd FileType html setlocal softtabstop=4
        autocmd FileType html setlocal shiftwidth=4
        autocmd FileType html setlocal tabstop=4
        autocmd FileType html setlocal isk=@,48-57,_,192-255,_,@,%,$,-

    " }}
    " JavaScript {{
        " NodeJS settings {{
            " Disabled when not working on NodeJS code.
            if 0
                au FileType javascript setlocal expandtab " spaces instead of tab - nodejs style http://nodeguide.com/style.html
                au FileType javascript setlocal list " if we don't have tabs, then we want to see tabs!
                au FileType javascript setlocal softtabstop=2
                au FileType javascript setlocal shiftwidth=2
                au FileType javascript setlocal tabstop=2
            endif
        " }}

        " Show menu and previews for completions.
        au FileType javascript setlocal completeopt=preview,menu

        " NodeJS: store last stack trace in log/lasterror.txt
        autocmd FileType javascript setlocal makeprg=cat\ log/lasterror.txt
        autocmd FileType javascript setlocal errorformat=\ \ \ \ at\ %m\ (%f:%l:%c)

        " Format as paragraph regardless of trailing whitespace.
        autocmd FileType php setlocal formatoptions-=w

        " Game making {{
            autocmd FileType javascript nmap <leader>w :s/width/\=KeepCase(submatch(0), 'height')
        " }}

        " A quick way to commit the current file after fixing the style.
        autocmd FileType javascript vmap <silent> <buffer> <Leader>, :JsFormat<cr>
        autocmd FileType javascript nmap <silent> <buffer> <Leader>, :JsFormat<cr>
        autocmd FileType javascript nmap <Leader>s :silent call CommitThis("style fixes")<cr>

        " Console.log whatever word is under the cursor.
        function! JSLogWordUnderCursor()
            " We need to include the dollar symbol in <cword>.
            let l:keyword = &iskeyword
            set iskeyword+=$

            execute "normal o
                \console.log(`" . expand("<cword>") . " = ${" . expand("<cword>") . "}`);"

            " Restore keyword setting.
            let &iskeyword = l:keyword
        endfunction

        autocmd FileType javascript nmap <Leader>l :call JSLogWordUnderCursor()<cr>

        " Highlighting {{
            " Highlight ObjectKeys
            hi link jsObjectKey Identifier
            hi link jsFunctionKey Identifier
            hi link jsFunction Identifier
            hi link jsLabel Special
        " }}
    " }}
    " JSON {{
        " npm package.json defaults.
        au FileType json setlocal expandtab
        au FileType json setlocal list
        au FileType json setlocal softtabstop=2
        au FileType json setlocal shiftwidth=2
        au FileType json setlocal tabstop=2

    " }}
    " Less {{
        au FileType less setlocal noexpandtab
        au FileType less setlocal softtabstop=4
        au FileType less setlocal shiftwidth=4
        au FileType less setlocal tabstop=4
        au FileType less setlocal nolist

        " Testing auto save.
        au Filetype less inoremap <buffer> <Esc> <Esc>:w<CR>
        au BufLeave *.less :silent wa
        au FocusLost *.less :silent wa
    " }}
    " Vim {{
        autocmd FileType vim setlocal tabstop=4
        autocmd FileType vim setlocal shiftwidth=4
        autocmd FileType vim setlocal expandtab
    " }}
    " Python {{
        autocmd FileType python setlocal tabstop=2
        autocmd FileType python setlocal shiftwidth=2
        autocmd FileType python setlocal softtabstop=2

        " Spaces not tabs for Python files.
        autocmd FileType python setlocal expandtab
    " }}
    " Markdown {{
        " Spaces not tabs for Markdown files.
        autocmd FileType markdown setlocal expandtab
        autocmd FileType markdown setlocal spell
    " }}
    " PHP {{
        " The dollar is not part of identifier.
        autocmd FileType php setlocal iskeyword-=$

        " Format as paragraph regardless of trailing whitespace.
        autocmd FileType php setlocal formatoptions-=w

        " Vim was beeping at my for not matching the '>' symbol when typing
        " '=>' due to including ftplugin/html.vim matchpairs.
        autocmd FileType php setlocal matchpairs-=<:>
        autocmd FileType php setlocal foldmethod=manual
        autocmd FileType php setlocal nofoldenable
    " }}
    " C++ {{
        " Settings for the NodeJS core code base {{
            autocmd FileType cpp setlocal expandtab
            autocmd FileType cpp setlocal shiftwidth=2
            autocmd FileType cpp setlocal tabstop=2
            autocmd FileType cpp setlocal softtabstop=2
        " }}
    " }}
    " org {{
        " Treat lines starting with asterisk as a bullet list (instead of a
        " multi line comment).
        autocmd FileType org setlocal comments=s1:/*,fb:*,ex:*/,://,b:#,:%,:XCOMM,n:>,fb:-
    " }}
    " gitcommit {{
        " Treat lines starting with asterisk as a bullet list (instead of a
        " multi line comment).
        autocmd FileType org setlocal comments=s1:/*,fb:*,ex:*/,://,b:#,:%,:XCOMM,n:>,fb:-
    " }}
" }}

" Commands and functions {{
    " Copy the current filename into the clipboard.
    command! FN :let @+ = expand("%")

    " Change directory of current window to directory of current file.
    command! CD :lcd %:p:h

    " Git related {{
        " Add and commit the current file with a message.
        function! CommitThis(msg)
            write
            :!git add %
            execute "!git commit -m " . a:msg
        endfunction

        " Commit the current file with a message.
        command! -nargs=1 CT call CommitThis(<f-args>)

        " Commit with a message and push.
        command! -nargs=1 CTP execute 'call CommitThis(<f-args>)' | :!git push

        " Push.
        command! GP :!git push
    " }}

    " Replace tabs with spaces, except at the start of lines.
    command! RetabIndents call RetabIndents()
    func! RetabIndents()
        let saved_view = winsaveview()
        execute '%s@^\(\ \{'.&ts.'\}\)\+@\=repeat("\t", len(submatch(0))/'.&ts.')@e'
        call winrestview(saved_view)
    endfunc

    " Resolve and run the first sync.sh script that is encountered when
    " looking up the directory hierarchy.
    " Requires resolve.
    function! SaveSync ()
        execute "w"
        execute "!resolve sync.sh \| xargs -I{} bash -c {}"
    endfunction

    command! SS call SaveSync()

    " Search without modifying the search register.
    function! SafeSearchCommand(theCommand)
        let search = @/
        try
            execute a:theCommand
        catch /.*/
            echo "No more."
        endtry

        let @/ = search
    endfunction

    " Lookup words. Note that according to the following discussion, google's
    " I'm Feeling Lucky search does not always work unless the referrer is
    " google.com.
    function! JSLookupKeyword(kw)
        " Must escape % or it will be replaced with the file name.
        " Duck Duck Go I'm feeling ducky:
        " execute '!open "https://duckduckgo.com/?q=\!+javascript+' . a:kw . '"'

        " Google I'm feeling lucky:
        execute '!open "http://www.google.com/search?q=javascript+' . a:kw . '&btnI=Im+Feeling+Lucky"'
    endfunction

    function! ExpressLookup(kw)
        " Must escape % or it will be replaced with the file name.
        " Duck Duck Go I'm feeling ducky:
        " execute '!open "https://duckduckgo.com/?q=\!+node.js+express+' . a:kw . '"'

        " Google I'm feeling lucky:
        execute '!open "http://www.google.com/search?q=node.js+express+' . a:kw . '&btnI=Im+Feeling+Lucky"'
    endfunction

    function! Search(kw)
        " Must escape % or it will be replaced with the file name.
        " Duck Duck Go I'm feeling ducky:
        " execute '!open "https://duckduckgo.com/?q=\!+node.js+express+' . a:kw . '"'

        " Google I'm feeling lucky:
        execute '!open "http://www.google.com/search?q=' . a:kw . '&btnI=Im+Feeling+Lucky"'
    endfunction

    function! TclLookup(kw)
        execute '!open "http://www.tcl.tk/man/tcl/TclCmd/' . a:kw . '.htm"'
    endfunction

" }}

" Fixes and workarounds {{
    " http://stackoverflow.com/questions/5585129/pasting-code-into-terminal-window-into-vim-on-mac-os-x
    if &term =~ "xterm.*"
        let &t_ti = &t_ti . "\e[?2004h"
        let &t_te = "\e[?2004l" . &t_te
        function XTermPasteBegin(ret)
            set pastetoggle=<Esc>[201~
            set paste
            return a:ret
        endfunction
        map <expr> <Esc>[200~ XTermPasteBegin("i")
        imap <expr> <Esc>[200~ XTermPasteBegin("")
        cmap <Esc>[200~ <nop>
        cmap <Esc>[201~ <nop>
    endif

    " Trailing whitespace {{
        " ExtraWhitespace highlight group (don't allow ColorScheme to override it).
        au ColorScheme * highlight ExtraWhitespace ctermbg=darkgreen guibg=lightgreen
        highlight ExtraWhitespace ctermbg=darkgreen guibg=lightgreen

        " Match trailing whitespace except when in insert mode
        au InsertEnter * match ExtraWhitespace /\s\+\%#\@<!$/
        au InsertLeave * match ExtraWhitespace /\s\+$/

        " Inappropriate use of tab.
        au ColorScheme * highlight BadTab ctermbg=darkred guibg=lightblue
        highlight BadTab ctermbg=darkred guibg=lightred

        " Highlight any use of tab after a non-whitespace character.
        "
        " The \@<= means that the \S (non-whitespace) must precede \t\+ but
        " will not be included in the match.
        au FileType tcl 2match BadTab /\S\@<=\t\+/

        " Highlight any use of space before the first non-whitespace
        " character.
        au FileType tcl match BadTab /\(^\t*\)\@<=[ ]\+\s\+/

        " Never leave trailing whitespace on the current line {{
            " Disabled because it prevents UltiSnips from inserting
            " placeholders with leading whitespace. Highlighting the trailing
            " whitespace ought to be enough.
            if 0
                function! RemoveTrailingWhitespace()
                    if &ft != 'markdown'
                        let l:winview = winsaveview()
                        silent! s/\s\+$/
                        call winrestview(l:winview)
                    endif
                endfunction

                autocmd InsertLeave * call RemoveTrailingWhitespace()
            endif
        " }}
    " }}
" }}

" Settings for Lightspeed Web Store {{
    " Controlled by environment variable.
    if $LIGHTSPEED
        " Plugins {{
            " NERDTree {{
                if has("gui_macvim")
                    nnoremap <silent> <D-N> :NERDTreeToggle copper<cr>
                endif
            " }}
        " }}

        " File types {{
            " Use tabs instead of spaces.
            au FileType javascript setlocal noexpandtab

            " Don't show tabs.
            au FileType javascript setlocal nolist

            " Indent width.
            au FileType javascript setlocal softtabstop=4
            au FileType javascript setlocal shiftwidth=4
            au FileType javascript setlocal tabstop=4
        " }}

        " A simplistic way of fixing a few of the most common phpcs errors. The
        " phpcbf program can generally do a better job than this.
        function! FixPHPCSErrors() range
            let saved_view = winsaveview()
            silent! execute a:firstline . "," . a:lastline . 's/\([^[:space:]=]\)=/\1 ='
            silent! execute a:firstline . "," . a:lastline . 's/=>\(\S\)/=> \1'
            silent! execute a:firstline . "," . a:lastline . 's/=\([^>=[:space:]]\)/= \1'
            silent! execute a:firstline . "," . a:lastline . 's/\([^-[:space:]]\)>\(\S\)/\1 > \2'
            call winrestview(saved_view)
        endfunc

        if has("gui_macvim")
            " Fix selection line
            autocmd FileType php vmap <D-r> :call FixPHPCSErrors()<cr>

            " Fix current line
            autocmd FileType php nmap <D-r> :call FixPHPCSErrors()<cr>
        endif

        " Use Web-Store style logging for whatever symbol is under the cursor.
        function! LogWordUnderCursor()
            " We need to include the dollar symbol in <cword>.
            let l:keyword = &iskeyword
            set iskeyword+=$

            execute "normal o
                \Yii::log(sprintf('DEBUG " . expand("<cword>") . " = %s',
                \ print_r(" . expand("<cword>") . ", true)),
                \\r'error', 'application.'.__CLASS__.'.'.__FUNCTION__);"

            " Restore keyword setting.
            let &iskeyword = l:keyword
        endfunction

        " Function which returns the current visual selection, from:
        " http://stackoverflow.com/questions/1533565/how-to-get-visually-selected-text-in-vimscript
        function! GetVisualSelection()
            " Why is this not a built-in Vim script function?!
            let [lnum1, col1] = getpos("'<")[1:2]
            let [lnum2, col2] = getpos("'>")[1:2]
            let lines = getline(lnum1, lnum2)
            let lines[-1] = lines[-1][: col2 - (&selection == 'inclusive' ? 1 : 2)]
            let lines[0] = lines[0][col1 - 1:]
            return join(lines, "\n")
        endfunction

        " Use Web-Store style logging for whatever symbol is under the cursor.
        function! LogSelectedText()
            let selectedText = GetVisualSelection()

            execute "normal o
                \Yii::log(sprintf('DEBUG " . selectedText. " = %s',
                \print_r(" . selectedText . ", true)),
                \\r'error', 'application.'.__CLASS__.'.'.__FUNCTION__);"
        endfunction

        autocmd FileType php nmap <Leader>l :call LogWordUnderCursor()<cr>
        autocmd FileType php vmap <Leader>v :call LogSelectedText()<cr>

        " Switch to a sensible default directory.
        cd /Volumes/dev/copper
    endif " end if $LIGHTSPEED
" }}

" tmux/iterm integration {{
    " Set window title in tmux.
    " Disabled this on 2015-06-23. I prefer to set windows titles manually
    " these days.
    " autocmd BufReadPost,FileReadPost,BufNewFile * call system("tmux rename-window 'vim:".expand("%")."'")

    nnoremap <Leader>K :silent aboveleft new<cr>
    nnoremap <Leader>J :silent belowright new<cr>
    nnoremap <Leader>H :silent leftabove vnew<cr>
    nnoremap <Leader>L :silent rightbelow vnew<cr>
" }}

" golang {{
let $GOPATH="~/.go"
" }}

" TODOs {{
    " 1. Have a look at Nerd Tree customizations from Janus
    " https://github.com/carlhuda/janus/blob/master/vimrc
    " 2. Find an easy way to switch between nodejs and non-nodejs JavaScript.
" }}

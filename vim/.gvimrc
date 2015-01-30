" Modeline and Notes {{
"   vim: set foldmarker={{,}} foldlevel=0 spell:
"
"   This is James Pickard's .gvimrc (http://github.com/euoia).
" }}

" Basics {{
    " Light-background fruity theme based on
    " http://www.vim.org/scripts/script.php?script_id=2577
    colorscheme summerfruit256

    " Set the font and height.
    set guifont=Monaco:h14

    set guioptions=ce
    "              ||
    "              |+-- use simple dialogs rather than pop-ups
    "              +  use GUI tabs, not console style tabs

    " Number of screen lines for new windows.
    set lines=40

    " Whether to hide the mouse cursor while typing.
    set mousehide

    " The label for tabs.
    " This is a good default, but it is possible to do fancy stuff with emoji
    " characters. See the GuiTabLabel function below.
    set guitablabel=%N\ %f
" }}

" Small-desktop settings {{
    " These preferences are better when not working on a massive
    " external display. Ideally this would be controlled by an
    " environment variable.

    " Disabled because the majority of the time I am using a large
    " display.
    if 0
        autocmd GUIEnter * set fullscreen " Proper full screen
    endif
" }}

" MacVim specific {{
    if has("gui_macvim")
        " Whether to allow binding of the option key for keyboard shortcuts.
        set macmeta

        " Set the transparency level. If MacVim supported transparency with
        " blurring like iTerm, I might consider this. As it is, the background
        " is too distracting.
        " 0 = no transparency.
        set transparency=0

        " Mappings {{
            " These mapping use D-something. That's the command key.

            " Create splits and change windows with command key.
            "
            " In order to map Command-h one needs to remove its "Hide"
            " functionality from the application by running the following on
            " the command line:
            " defaults write org.vim.MacVim NSUserKeyEquivalents -dict "Hide MacVim" "nil"
            nnoremap <D-K> :silent aboveleft new<cr>
            nnoremap <D-J> :silent belowright new<cr>
            nnoremap <D-H> :silent leftabove vnew<cr>
            nnoremap <D-L> :silent rightbelow vnew<cr>

            " Free up Tools -> List Errors
            macmenu Tools.List\ Errors key=<nop>

            nnoremap <D-k> <C-w>k
            nnoremap <D-h> <C-w>h
            nnoremap <D-l> <C-w>l
            nnoremap <D-j> <C-w>j

            " Run make.
            " Unmap command-M (used for minimize)
            macmenu Window.Minimize key=<nop>
            nnoremap <silent> <D-m> :silent make \| copen<cr>

            " Navigate the location list
            nnoremap <silent> <D-e> :lprevious<cr>
            nnoremap <silent> <D-d> :lnext<cr>

            " JavaScript {{
                " JsBeautify https://github.com/euoia/vim-jsbeautify-simple
                " Unmap command-f
                macmenu Edit.Find.Find\.\.\. key=<nop>
                autocmd FileType javascript nmap <silent> <buffer> <D-f> :JsBeautifySimple<cr>
                autocmd FileType javascript vmap <silent> <buffer> <D-f> :JsBeautifySimple<cr>
            " }}

            " HTML config
            autocmd FileType html nmap <silent> <buffer> <D-f> :JsBeautifySimple<cr>
            autocmd FileType html vmap <silent> <buffer> <D-f> :JsBeautifySimple<cr>

            " CSS config
            autocmd FileType css nmap <silent> <buffer> <D-f> :JsBeautifySimple<cr>
            autocmd FileType css vmap <silent> <buffer> <D-f> :JsBeautifySimple<cr>

            " Switch to a specific tab with command-number {{
                " Disabled since I rarely use them.
                if 0
                    nmap <silent> <D-1> 1gt
                    nmap <silent> <D-2> 2gt
                    nmap <silent> <D-3> 3gt
                    nmap <silent> <D-4> 4gt
                    nmap <silent> <D-5> 5gt
                    nmap <silent> <D-6> 6gt
                    nmap <silent> <D-7> 7gt
                    nmap <silent> <D-8> 8gt
                    nmap <silent> <D-9> 9gt
                endif
            " }}
        " }}

        " Menu settings using macmenu {{
            " These menu settings can only be done in a startup file. Executing
            " them after vim has started has no effect. These have no effect
            " in ~/.vimrc.

            " Free up command-p for use by CtrlP, Unite.
            macmenu File.Print key=<nop>
        " }}
    endif
" }}

" Commands and functions {{
    command! -nargs=1 JL call JSLookupKeyword('<args>')
    command! -nargs=1 EL call ExpressLookup('<args>')
    command! -nargs=1 TL call TclLookup('<args>')
    command! -nargs=1 SL call Search('<args>')

    " This function returns what should be used for the tab label.
    " This function uses emoji icons to indicate certain file statuses (e.g.
    " modified).
    function! GuiTabLabel()
        let label = ''

        " Icons in the tab bar.
        let tabBuffers = tabpagebuflist()
        let wincount = 0 " Append open book if there's more than one window open.
        let has_public_file = 0 " Append earth icon if 'public' is in path.
        let has_routes_file = 0 " Append rocket ship if 'routes' is in the path.
        let has_modified_file = 0 " Add sweat brow if one of the buffers in the tab page is modified
        let has_views_file = 0 " Add document icon if 'views' is in the path.
        let has_test_file = 0 " Add traffic light icon if 'test' is in the path.
        let has_txt_file = 0 " Add document icon if filename suffix is .txt.

        let lastBuffer = -1
        for bufNumber in tabBuffers
            " Ignore NERD_tree windows.
            if bufname(bufNumber) =~ "NERD_tree"
                continue
            endif

            " Ignore Tag List windows.
            if bufname(bufNumber) =~ "__Tag_List__"
                continue
            endif

            let lastBuffer = bufNumber

            if bufname(bufNumber) =~ "public"
                let has_public_file = 1
            endif

            if bufname(bufNumber) =~ "public"
                let has_public_file = 1
            endif

            if bufname(bufNumber) =~ "routes"
                let has_routes_file = 1
            endif

            if bufname(bufNumber) =~ "views"
                let has_views_file = 1
            endif

            if bufname(bufNumber) =~ "test"
                let has_test_file = 1
            endif

            if getbufvar(bufNumber, "&modified")
                let has_modified_file = 1
            endif

            if bufname(bufNumber) =~ ".txt"
                let has_txt_file = 1
            endif

            let wincount = wincount + 1
        endfor

        " Open book (multiple pages)
        if wincount > 1
            let label .= '😡'
        endif

        " Sweat brow.
        if has_modified_file == 1
            let label .= '😓'
        endif

        " Earth icon.
        if has_public_file == 1
            let label .= '🌍'
        endif

        " Rocket ship.
        if has_routes_file == 1
            let label .= '🚀'
        endif

        " Document.
        if has_views_file == 1
            let label .= '📄'
        endif

        " Traffic light.
        if has_test_file == 1
            let label .= '🚦'
        endif

        " Document.
        if has_txt_file == 1
            let label .= '📄'
        endif

        " Append the buffer name
        if lastBuffer == -1
            return label . " <no file open>"
        else
            " Never show a NERD_tree in the tab name.
            if bufname(v:lnum) =~ "NERD_tree"
                let bufname = bufname(lastBuffer)
            else
                let bufname = bufname(tabBuffers[tabpagewinnr(v:lnum) - 1])
            endif

            return label . pathshorten(bufname)
        endif
    endfunction

    " Add an icon to indicate the current tab.
    au TabEnter * let t:current = 1
    au TabLeave * let t:current = 0

    " Use a tab label which includes the result of the GuiTabLabel() function.
    set guitablabel=%N\ %{exists('t:current')&&t:current?'🔵':''}\ %{GuiTabLabel()}
" }}

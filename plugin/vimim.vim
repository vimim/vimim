" ======================================================
"               " VimIM —— Vim 中文輸入法 "
" ------------------------------------------------------
"   VimIM -- Input Method by Vim, of Vim, for Vimmers
" ======================================================

let $VimIM = " easter egg:"" vimim<C-6><C-6> vimimrc<C-6><C-6>
let $VimIM = " $Date$"
let $VimIM = " $Revision$"
let s:url  = " http://vim.sf.net/scripts/script.php?script_id=2506"
let s:url .= " http://vimim.googlecode.com/svn/vimim/vimim.vim.html"
let s:url .= " http://code.google.com/p/vimim/source/list"
let s:url .= " http://groups.google.com/group/vimim"
let s:url .= " http://vimim.googlecode.com/svn/vimim/vimim.html"
let s:url .= " vimim@googlegroups.com"

let s:VimIM  = [" ====  introduction     ==== {{{"]
" =================================================
"    File: vimim.vim
"  Author: vimim <vimim@googlegroups.com>
" License: GNU Lesser General Public License
"  Readme: VimIM is a Vim plugin as an independent Input Method.
"  (1) input of Chinese without mode change:  OneKey == MidasTouch
"  (2) slash search of Chinese without typing Chinese
"  (3) support 4 clouds: Google/Baidu/Sogou/QQ cloud input
"  (4) support huge datafile if python interface to Vim is used
"
" "VimIM Installation"
"  (1) drop this vim script to plugin/:    plugin/vimim.vim
"  (2) [option] drop a English  datafile:  plugin/vimim.txt
"  (3) [option] drop a standard cjk file:  plugin/vimim.cjk.txt
"  (4) [option] drop a standard directory: plugin/vimim/pinyin/
"  (5) [option] drop a python2  database:  plugin/vimim.gbk.bsddb
"
" "VimIM Usage"
"  (1) play with cloud, without datafile, with python or wget/curl
"      open vim, type i, type <C-\> to open; type <C-\> to close
"  (2) flirt with OneKey: Midas touch
"      open vim, type i, type sssss <C-6>, m, type alphabetical label

" ============================================= }}}
let s:VimIM += [" ====  initialization   ==== {{{"]
" =================================================
if exists("b:loaded_vimim") || &cp || v:version<700
    finish
endif
scriptencoding utf-8
let b:loaded_vimim = 1
let s:plugin = expand("<sfile>:p:h")

function! s:vimim_backend_initialization()
    if exists("s:vimim_backend_initialization")
        return
    else
        let s:vimim_backend_initialization = 1
    endif
    sil!call s:vimim_super_reset()
    sil!call s:vimim_initialize_encoding()
    sil!call s:vimim_initialize_session()
    sil!call s:vimim_initialize_ui()
    sil!call s:vimim_initialize_i_setting()
    sil!call s:vimim_dictionary_statusline()
    sil!call s:vimim_dictionary_punctuations()
    sil!call s:vimim_dictionary_keycodes()
    sil!call s:vimim_scan_cjk_file()
    sil!call s:vimim_scan_english_datafile()
    if len(s:vimim_mycloud) > 1
        sil!call s:vimim_scan_backend_mycloud()
    else
        sil!call s:vimim_scan_backend_embedded()
        sil!call s:vimim_scan_backend_cloud()
    endif
    sil!call s:vimim_set_keycode()
endfunction

function! s:vimim_initialize_session()
    let s:pumheight = 10
    let s:pumheight_saved = &pumheight
    let s:imode_pinyin = 0
    let s:smart_single_quotes = 1
    let s:smart_double_quotes = 1
    let s:current_positions = [0,0,1,0]
    let s:start_row_before = 0
    let s:start_column_before = 1
    let s:scriptnames_output = 0
    let az_list = range(char2nr('a'), char2nr('z'))
    let AZ_list = range(char2nr('A'), char2nr('Z'))
    let s:az_list = map(az_list, "nr2char(".'v:val'.")")
    let s:AZ_list = map(AZ_list, "nr2char(".'v:val'.")")
    let s:Az_list = s:az_list + s:AZ_list
    let s:valid_keys = s:az_list
    let s:valid_key = 0
    let s:abcd = "'abcdvfgsz"
    let s:qwer = split('pqwertyuio','\zs')
    let s:chinese_punctuation = s:vimim_chinese_punctuation % 2
    let s:seamless_positions = []
    let s:shuangpin_keycode_chinese = {}
    let s:shuangpin_table = {}
    let s:quanpin_table = {}
    let s:cjk_cache = {}
    let s:cjk_cache.i = ["我"]
endfunction

function! s:vimim_initialize_ui()
    let s:ui = {}
    let s:ui.im = ''
    let s:ui.root = ''
    let s:ui.keycode = ''
    let s:ui.statusline = ''
    let s:ui.has_dot = 0
    let s:ui.frontends = []
    let s:backend = {}
    let s:backend.directory = {}
    let s:backend.datafile  = {}
    let s:backend.cloud     = {}
endfunction

function! s:vimim_one_backend_hash()
    let one_backend_hash = {}
    let one_backend_hash.root = ''
    let one_backend_hash.im = ''
    let one_backend_hash.name = ''
    let one_backend_hash.chinese = ''
    let one_backend_hash.directory = ''
    let one_backend_hash.lines = []
    let one_backend_hash.keycode = "[0-9a-z']"
    return one_backend_hash
endfunction

function! s:vimim_dictionary_keycodes()
    let s:im_keycode = {}
    let keys  = split('pinyin hangul xinhua quick wubi')
    let keys += split('sogou qq google baidu mycloud')
    for key in keys
        let s:im_keycode[key] = "[0-9a-z']"
    endfor
    let keys = split('wu nature zhengma cangjie taijima')
    for key in keys
        let s:im_keycode[key] = "[.'a-z]"
    endfor
    let s:im_keycode.yong     = "[.'a-z;/]"
    let s:im_keycode.erbi     = "[.'a-z,;/]"
    let s:im_keycode.array30  = "[.,a-z0-9;/]"
    let s:im_keycode.phonetic = "[.,a-z0-9;/]"
    let s:im_keycode.boshiamy = "[][a-z'.,]"
    let keys  = copy(keys(s:im_keycode))
    let keys += split('pinyin_sogou pinyin_quote_sogou pinyin_huge')
    let keys += split('pinyin_fcitx pinyin_canton pinyin_hongkong')
    let keys += split('wubijd wubihf wubi98 wubi2000')
    let s:all_vimim_input_methods = copy(keys)
endfunction

function! s:vimim_set_keycode()
    let keycode = ""
    let keycode_string = ""
    if empty(s:ui.root)
        let keycode = "[0-9a-z']"
        let s:imode_pinyin = 1
    else
        let keycode = s:backend[s:ui.root][s:ui.im].keycode
    endif
    if !empty(s:vimim_shuangpin) && !empty(s:shuangpin_keycode_chinese)
        let keycode = s:shuangpin_keycode_chinese.keycode
    endif
    let i = 0
    while i < 16*16
        let char = nr2char(i)
        if char =~# keycode
            let keycode_string .= char
        endif
        let i += 1
    endwhile
    let s:valid_key  = copy(keycode)
    let s:valid_keys = split(keycode_string, '\zs')
endfunction

" ============================================= }}}
let s:VimIM += [" ====  customization    ==== {{{"]
" =================================================

function! s:vimim_initialize_global()
    let G = []
    let s:vimimrc = []
    let s:vimimdefaults = []
    call add(G, "g:vimim_debug")
    call add(G, "g:vimim_chinese_input_mode")
    call add(G, "g:vimim_ctrl_space_to_toggle")
    call add(G, "g:vimim_ctrl_h_to_toggle")
    call add(G, "g:vimim_plugin_folder")
    call add(G, "g:vimim_shuangpin")
    call add(G, "g:vimim_onekey_is_tab")
    call add(G, "g:vimim_toggle_list")
    call add(G, "g:vimim_mycloud")
    call add(G, "g:vimim_cloud")
    call s:vimim_set_global_default(G, 0)
    let G = []
    call add(G, "g:vimim_chinese_punctuation")
    call add(G, "g:vimim_one_row_menu")
    call add(G, "g:vimim_menuless")
    call add(G, "g:vimim_custom_color")
    call s:vimim_set_global_default(G, 1)
    let s:im_toggle = 0
    let s:frontends = []
    let s:loops = {}
    let s:numbers = {}
    let s:quantifiers = {}
    let s:chinese_mode = 'onekey'
    if empty(s:vimim_chinese_input_mode)
        let s:vimim_chinese_input_mode = 'dynamic'
    endif
    if isdirectory(s:vimim_plugin_folder)
        let s:plugin = s:vimim_plugin_folder
    endif
    if s:plugin[-1:] != "/"
        let s:plugin .= "/"
    endif
endfunction

function! s:vimim_set_global_default(options, default)
    for variable in a:options
        let configuration = 0
        let default = a:default
        if exists(variable)
            let value = eval(variable)
            if value!=default || type(value)==1
                let configuration = 1
            endif
            let default = string(value)
        endif
        let option = ':let ' . variable .' = '. default .' '
        if configuration
            call add(s:vimimrc, '  ' . option)
        else
            call add(s:vimimdefaults, '" ' . option)
        endif
        let s_variable = substitute(variable,"g:","s:",'')
        if exists(variable)
            exe 'let '. s_variable .'='. variable
            exe 'unlet! ' . variable
        else
            exe 'let '. s_variable .'='. a:default
        endif
    endfor
endfunction

function! s:vimim_initialize_local()
    let hjkl = '/home/xma/hjkl'
    if exists('hjkl') && isdirectory(hjkl)
        :redir @v
        let g:vimim_cloud = 'google,sogou,baidu,qq'
        let g:vimim_debug = 1
        let g:vimim_onekey_is_tab = 2
        let g:vimim_plugin_folder = hjkl
        call g:vimim_default_omni_color()
    endif
endfunction

" ============================================= }}}
let s:VimIM += [" ====  easter eggs      ==== {{{"]
" =================================================

function! s:vimim_easter_chicken(keyboard)
    try
        return eval("s:vimim_egg_" . a:keyboard . "()")
    catch
        call s:debug('alert', 'egg=', a:keyboard, v:exception)
    endtry
    return []
endfunction

function! s:vimim_egg_vimimrc()
    let vimimrc = copy(s:vimimdefaults)
    let index = match(vimimrc, 'g:vimim_toggle_list')
    let custom_im_list = s:vimim_get_custom_im_list()
    if index && !empty(custom_im_list)
        let toggle = join(custom_im_list,",")
        let value = vimimrc[index][:-3]
        let vimimrc[index] = value . "'" . toggle . "'"
    endif
    let vimimrc += s:vimimrc
    return sort(vimimrc)
endfunction

function! s:vimim_egg_vimimvim()
    let filter = "strpart(" . 'v:val' . ", 0, 29)"
    return map(copy(s:VimIM), filter)
endfunction

function! s:vimim_egg_vimimclouds()
    return s:vimim_get_cloud_all('woyouyigemeng')
endfunction

function! s:vimim_egg_vimimgame()
    let mahjong = "春夏秋冬 梅兰竹菊 東南西北 中發白囍"
    return split(mahjong)
endfunction

function! s:vimim_egg_vim()
    let eggs  = ["vi    文本編輯器"]
    let eggs += ["vim   最牛文本編輯器"]
    let eggs += ["vim   精力"]
    let eggs += ["vim   生氣"]
    let eggs += ["vimim 中文輸入法"]
    return eggs
endfunction

function! s:vimim_egg_vimimhelp()
    let eggs = []
    let url = split(s:url)
    call add(eggs, '官方网址 ' . get(url,0) . ' ' )
    call add(eggs, '最新程式 ' . get(url,1) . ' ' )
    call add(eggs, '更新报告 ' . get(url,2) . ' ' )
    call add(eggs, '新闻论坛 ' . get(url,3) . ' ' )
    call add(eggs, '最新主页 ' . get(url,4) . ' ' )
    call add(eggs, '论坛邮箱 ' . get(url,5) . ' ' )
    return eggs
endfunction

function! s:vimim_egg_vimim()
    let eggs = []
    let today = s:vimim_imode_today_now('itoday')
    let option = s:vimim_chinese('datetime') . s:colon . today
    call add(eggs, option)
    let option = "os"
        if has("win32unix") | let option = "cygwin"
    elseif has("win32")     | let option = "Windows32"
    elseif has("win64")     | let option = "Windows64"
    elseif has("unix")      | let option = "unix"
    elseif has("macunix")   | let option = "macunix" | endif
    let option .= "_" . &term
    let computer = s:vimim_chinese('computer') . s:colon
    call add(eggs, computer . option)
    let revision = s:vimim_chinese('revision') . s:colon
    let option = get(split($VimIM),1)
    let option = empty(option) ? "" : "vimim.vim=" . option
    let vim = v:progname . "=" . v:version . s:space
    call add(eggs, revision . vim . option)
    let encoding = s:vimim_chinese('encoding') . s:colon
    call add(eggs, encoding . &encoding . s:space . &fileencodings)
    if has("gui_running")
        let font = len(&gfw) ? &gfw : len(&gfn) ? &gfn : &guicursor
        let option = s:vimim_chinese('font') . s:colon . font
        call add(eggs, option)
    endif
    let option = s:vimim_chinese('env') . s:colon . v:lc_time
    call add(eggs, option)
    let database = s:vimim_chinese('database') . s:colon
    if len(s:ui.frontends) > 0
        for frontend in s:ui.frontends
            let ui_root = get(frontend, 0)
            let ui_im = get(frontend, 1)
            let datafile = s:backend[ui_root][ui_im].name
            let mass = datafile=~"bsddb" ? 'mass' : ui_root
            let ciku = database . s:vimim_chinese(mass) . database
            call add(eggs, ciku . datafile)
        endfor
    else
        let ciku = database . s:vimim_chinese('unicode') . database
        call add(eggs, ciku . "UNICODE")
    endif
    if !empty(s:english_filename)
        let ciku = database . s:vimim_chinese('english') . database
        call add(eggs, ciku . s:english_filename)
    endif
    if !empty(s:cjk_filename)
        let ciku  = database
        if s:cjk_filename =~ "vimim.cjk.txt"
            let ciku .= s:vimim_chinese('4corner')
        elseif s:cjk_filename =~ "vimim.cjkv.txt"
            let ciku .= s:vimim_chinese('5strokes')
        endif
        call add(eggs, ciku . s:colon . s:cjk_filename)
    endif
    let toggle = "toggle_with_Ctrl-Bslash"
    if s:vimim_ctrl_space_to_toggle == 1
        let toggle = "toggle_with_Ctrl-Space"
    elseif s:vimim_ctrl_space_to_toggle == 3
        let toggle = "toggle_with_Ctrl-Space_for_midas_touch"
    elseif s:vimim_onekey_is_tab > 0
       let toggle = "toggle_with_Tab_for_midas_touch"
    endif
    let style = s:vimim_chinese('style') . s:colon
    call add(eggs, style . toggle)
    let input = s:vimim_chinese('input') . s:colon
    if s:vimim_onekey_is_tab == 2
        let input .= s:vimim_chinese('onekey')  . s:space
        let input .= s:vimim_chinese('english') . s:space
        let input .= s:vimim_chinese(s:ui.im)   . s:space
    else
        let input .=  s:vimim_statusline() . s:space
    endif
    if s:vimim_cloud > -1 && s:onekey < 2
        let input .= s:vimim_chinese(s:cloud_default)
        let input .= s:vimim_chinese('cloud')
    endif
    call add(eggs, input)
    if !empty(s:vimim_check_http_executable())
        let network  = s:vimim_chinese('network') . s:colon
        let title = s:http_executable=~'Python' ? '' : "HTTP executable: "
        let option = network . title . s:http_executable
        call add(eggs, option)
    endif
    let option = s:vimim_chinese('setup') . s:colon . "vimimrc "
    if empty(s:vimimrc)
        call add(eggs, option . "all defaults")
    else
        call add(eggs, option)
        for rc in sort(s:vimimrc)
            call add(eggs, s:space . s:space . s:colon . rc[2:])
        endfor
    endif
    return map(eggs, 'v:val . " "')
endfunction

function! s:vimim_get_keyboard_but_quote(keyboard)
    let keyboard = a:keyboard
    if !empty(s:ui.has_dot) || keyboard =~ '\d'
        return keyboard
    endif
    if keyboard[-2:] == "''"     " two tail  sssss''
        let head = keyboard[:-3]
        if len(head) == 1
            return head
        endif
        let keyboard = substitute(keyboard,"'","",'g')
        let keyboard = join(split(keyboard,'\zs'),"'")
        let keyboard = s:vimim_quote_by_quote(keyboard)
    elseif keyboard[-1:] == "'"
        " [cloud] magic trailing quote to control cloud
        let s:onekey = s:onekey==1 ? 2 : s:onekey
        let keyboard = s:vimim_last_quote(keyboard)
    elseif keyboard =~ "'"
        " [local] wo'you'yi'ge'meng
        let keyboard = s:vimim_quote_by_quote(keyboard)
    endif
    return keyboard
endfunction

function! s:vimim_quote_by_quote(keyboard)
    let keyboards = split(a:keyboard,"'")
    let head = get(keyboards,0)
    let tail = join(keyboards[1:],"'")
    let s:keyboard = head . "," . tail
    return head
endfunction

function! s:vimim_get_hjkl_game(keyboard)
    let keyboard = a:keyboard
    let poem = s:vimim_check_filereadable(keyboard)
    let unname_register = getreg('"')
    let results = []
    if !empty(poem)
        " [poem] flirt any entry in the hjkl directory
        let results = s:vimim_readfile(poem)
    elseif keyboard ==# "vim" || keyboard =~# "^vimim"
        " [eggs] hunt classic easter egg ... vim<C-6>
        let results = s:vimim_easter_chicken(keyboard)
    elseif keyboard[-4:] ==# "''''"
        " [clouds] all clouds for any input: fuck''''
        let results = s:vimim_get_cloud_all(keyboard[:-5])
    elseif keyboard[-2:] ==# "''"
        let results = s:vimim_egg_vimimgame()
    elseif len(unname_register) > 8
        if keyboard ==# "'''"
            " [hjkl] display buffer inside the omni window
            let results = split(unname_register, '\n')
        elseif keyboard =~# 'u\d\d\d\d\d'
            " [visual] " vimim_visual_ctrl6: highlighted multiple cjk
            let line = substitute(unname_register,'[\x00-\xff]','','g')
            if !empty(line)
                for chinese in split(line,'\zs')
                    let menu  = s:vimim_cjk_extra_text(chinese)
                    let menu .= repeat(" ", 38-len(menu))
                    call add(results, chinese . " " . menu)
                endfor
            endif
        endif
    endif
    if !empty(results)
        let s:show_me_not = 1
        if s:hjkl_m % 4
            for i in range(s:hjkl_m%4)
                let results = s:vimim_hjkl_rotation(results)
            endfor
        endif
    endif
    return results
endfunction

function! s:vimim_get_umode_chinese(char_before, keyboard)
    let results = []
    let char_before = a:char_before
    if empty(char_before)  || char_before !~ '\W'
        if a:keyboard ==# 'u'  " 214 standard unicode index
            if empty(s:cjk_filename)
                let char_before = '一'
            else
                let results = s:vimim_cjk_match('u')
            endif
        elseif a:keyboard ==# 'uu' " easter egg
            let results = split(join(s:vimim_egg_vimimgame(),""),'\zs')
        endif
    else
        let results = s:vimim_get_unicode_list(char2nr(char_before))
    endif
    return results
endfunction

function! s:vimim_hjkl_rotation(lines)
    let max = max(map(copy(a:lines), 'strlen(v:val)')) + 1
    let multibyte = 1
    if match(a:lines,'\w') < 0
        " rotation makes more sense for cjk
        let multibyte = s:multibyte
    endif
    let results = []
    for line in a:lines
        let spaces = ''
        let gap = (max-len(line))/multibyte
        if gap > 0
            for i in range(gap)
                let spaces .= s:space
            endfor
        endif
        let line .= spaces
        call add(results, line)
    endfor
    let rotations = []
    for i in range(max/multibyte)
        let column = ''
        for line in reverse(copy(results))
            let line = get(split(line,'\zs'), i)
            if empty(line)
                continue
            else
                let column .= line
            endif
        endfor
        call add(rotations, column)
    endfor
    return rotations
endfunction

function! s:vimim_chinese_rotation() range abort
    sil!call s:vimim_backend_initialization()
    :%s#\s*\r\=$##
    let lines = getline(a:firstline, a:lastline)
    if !empty(lines)
        :let lines = s:vimim_hjkl_rotation(lines)
        :%d
        for line in lines
            put=line
        endfor
    endif
endfunction

" ============================================= }}}
let s:VimIM += [" ====  /search          ==== {{{"]
" =================================================

function! g:vimim_search_next()
    let english = @/
    if english =~ '\<' && english =~ '\>'
        let english = substitute(english,'[<>\\]','','g')
    endif
    let results = []
    if len(english) > 1 && len(english) < 24
    \&& english =~ '\w' && english !~ '\W' && english !~ '_'
    \&& v:errmsg =~# english && v:errmsg =~# '^E486: '
        try
            let results = s:vimim_search_chinese_by_english(english)
        catch
            call s:debug('alert', 'slash search /', v:exception)
        endtry
    endif
    if !empty(results)
        let results = split(substitute(join(results),'\w','','g'))
        let slash = join(results[0:8], '\|')
        let @/ = slash
        if empty(search(slash,'nw'))
            let @/ = english
        endif
    endif
    echon "/" . english
    let v:errmsg = ""
endfunction

function! s:vimim_search_chinese_by_english(keyboard)
    sil!call s:vimim_backend_initialization()
    let keyboard = tolower(a:keyboard)
    let results = []
    " 1/3 first try search from cloud/mycloud
    if s:vimim_cloud =~ 'search' || s:ui.root == 'cloud'
        " /search from the default cloud
        let results = s:vimim_get_cloud(keyboard, s:cloud_default)
    elseif !empty(s:mycloud)
        " /search from mycloud
        let results = s:vimim_get_mycloud_plugin(keyboard)
    endif
    if !empty(results)
        return results
    endif
    " 2/3 search unicode or cjk /search unicode /u808f
    let ddddd = s:vimim_get_unicode_ddddd(keyboard)
    if empty(ddddd) && !empty(s:cjk_filename)
        " /search cjk /m7712x3610j3111 /muuqwxeyqpjeqqq
        let keyboards = s:vimim_cjk_slash_search_block(keyboard)
        if len(keyboards) > 0
            for keyboard in keyboards
                let chars = s:vimim_cjk_match(keyboard)
                if len(keyboards) == 1
                    let results = copy(chars)
                elseif len(chars) > 0
                    let collection = "[" . join(chars,'') . "]"
                    call add(results, collection)
                endif
            endfor
            if len(keyboards) > 1
                let results = [join(results,'')]
            endif
        endif
    else
        let results = [nr2char(ddddd)]
    endif
    if !empty(results)
        return results
    endif
    " 3/3 search datafile and english: /ma and /horse
    let oneline = s:vimim_english(keyboard)
    if empty(oneline)
        let s:search = 1
        let results = s:vimim_embedded_backend_engine(keyboard)
    else
        let results = split(oneline)
    endif
    return results
endfunction

function! s:vimim_cjk_slash_search_block(keyboard)
    " /muuqwxeyqpjeqqq  =>  shortcut   /search
    " /m7712x3610j3111  =>  standard   /search
    " /ma77xia36ji31    =>  free-style /search
    let results = []
    let keyboard = a:keyboard
    while len(keyboard) > 1
        let keyboard2 = s:vimim_onekey_cjk(keyboard)
        if empty(keyboard2)
            break
        else
            call add(results, keyboard2)
            let keyboard = strpart(keyboard,len(keyboard2))
        endif
    endwhile
    return results
endfunction

" ============================================= }}}
let s:VimIM += [" ====  chinese imode    ==== {{{"]
" =================================================

function! s:vimim_build_numbers_hash()
    if empty(s:numbers)
        let s:numbers.1 = "一壹⑴①甲"
        let s:numbers.2 = "二贰⑵②乙"
        let s:numbers.3 = "三叁⑶③丙"
        let s:numbers.4 = "四肆⑷④丁"
        let s:numbers.5 = "五伍⑸⑤戊"
        let s:numbers.6 = "六陆⑹⑥己"
        let s:numbers.7 = "七柒⑺⑦庚"
        let s:numbers.8 = "八捌⑻⑧辛"
        let s:numbers.9 = "九玖⑼⑨壬"
        let s:numbers.0 = "十拾⑽⑩癸"
    endif
endfunction

function! s:vimim_get_antonym_list()
    let antonym  = " ，。 “” ‘’ （） 【】 〖〗 《》"
    let antonym .= " 酸甜苦辣 危安 胜败 凶吉 真假 石金 "
    return split(antonym)
endfunction

function! s:vimim_get_imode_chinese(char_before, number)
    if empty(s:loops)
        let antonyms = s:vimim_get_antonym_list()   " 石 => 金
        let numbers  = s:vimim_get_numbers_list()   " 七 => 八
        let imode_list = a:number ? numbers : numbers+antonyms
        for loop in imode_list
            let loops = split(loop,'\zs')
            for i in range(len(loops))
                let j = i==len(loops)-1 ? 0 : i+1
                let s:loops[loops[i]] = loops[j]
            endfor
        endfor
    endif
    let results = []
    let key = a:char_before
    if has_key(s:loops, key)
        let start = key
        let next = ""
        while start != next
            let next = s:loops[key]
            call add(results, next)
            let key = next
        endwhile
    endif
    if empty(results) && a:number
        let results = s:vimim_egg_vimimgame()
    endif
    return results
endfunction

function! s:vimim_get_numbers_list()
    let items = []
    call s:vimim_build_numbers_hash()
    for i in range(len(s:numbers))
        call add(items, split(s:numbers[i],'\zs'))
    endfor
    let numbers = []
    for j in range(len(get(items,0)))
        let number = ""
        for line in items
            let number .= get(line,j)
        endfor
        call add(numbers, number)
    endfor
    return numbers
endfunction

let s:translators = {}
function! s:translators.translate(english) dict
    let inputs = split(a:english)
    return join(map(inputs,'get(self.dict,tolower(v:val),v:val)'), '')
endfunction

function! s:vimim_imode_today_now(keyboard)
    let results = []
    call add(results, strftime("%Y"))
    call add(results, 'year')
    call add(results, substitute(strftime("%m"),'^0','',''))
    call add(results, 'month')
    call add(results, substitute(strftime("%d"),'^0','',''))
    call add(results, 'day')
    if a:keyboard ==# 'itoday'
        call add(results, s:space)
        call add(results, strftime("%A"))
    elseif a:keyboard ==# 'inow'
        call add(results, substitute(strftime("%H"),'^0','',''))
        call add(results, 'hour')
        call add(results, substitute(strftime("%M"),'^0','',''))
        call add(results, 'minute')
        call add(results, substitute(strftime("%S"),'^0','',''))
        call add(results, 'second')
    endif
    let ecdict = {}
    let ecdict.sunday    = "星期日"
    let ecdict.monday    = "星期一"
    let ecdict.tuesday   = "星期二"
    let ecdict.wednesday = "星期三"
    let ecdict.thursday  = "星期四"
    let ecdict.friday    = "星期五"
    let ecdict.saturday  = "星期六"
    let ecdict.year      = "年"
    let ecdict.month     = "月"
    let ecdict.day       = "日"
    let ecdict.hour      = "时"
    let ecdict.minute    = "分"
    let ecdict.second    = "秒"
    let chinese = copy(s:translators)
    let chinese.dict = ecdict
    return chinese.translate(join(results))
endfunction

function! s:vimim_imode_number(keyboard)
    let keyboard = a:keyboard
    let ii = keyboard[0:1] " sample: i88 ii88 isw8ql iisw8ql
    let keyboard = ii==#'ii' ? keyboard[2:] : keyboard[1:]
    let dddl = keyboard=~#'^\d*\l\{1}$' ? keyboard[:-2] : keyboard
    let keyboards = split(dddl, '\ze')
    let number = ""
    if empty(s:quantifiers)
        call s:vimim_build_quantifier_hash()
    endif
    for char in keyboards
        if has_key(s:quantifiers, char)
            let quantifier_list = split(s:quantifiers[char], '\zs')
            let chinese = get(quantifier_list, 0)
            if ii ==# 'ii' && char =~# '[0-9sbq]'
                let chinese = get(quantifier_list, 1)
            endif
            let number .= chinese
        endif
    endfor
    if empty(number)
        return []
    endif
    let numbers = [number]
    let last_char = keyboard[-1:]
    if !empty(last_char) && has_key(s:quantifiers, last_char)
        let quantifier_list = split(s:quantifiers[last_char], '\zs')
        if keyboard =~# '^[ds]\=\d*\l\{1}$'
            if keyboard =~# '^[ds]'
                let number = strpart(number,0,len(number)-s:multibyte)
            endif
            let numbers = map(copy(quantifier_list), 'number . v:val')
        elseif keyboard =~# '^\d*$' && len(keyboards)<2 && ii != 'ii'
            let numbers = quantifier_list
        endif
    endif
    return numbers
endfunction

function! s:vimim_build_quantifier_hash()
    call s:vimim_build_numbers_hash()
    let s:quantifiers = copy(s:numbers)
    let s:quantifiers.b = "百佰步把包杯本笔部班"
    let s:quantifiers.c = "次餐场串处床"
    let s:quantifiers.d = "第度点袋道滴碟顶栋堆对朵堵顿"
    let s:quantifiers.f = "分份发封付副幅峰方服"
    let s:quantifiers.g = "个根股管"
    let s:quantifiers.h = "行盒壶户回毫"
    let s:quantifiers.j = "斤家具架间件节剂具捲卷茎记"
    let s:quantifiers.k = "克口块棵颗捆孔"
    let s:quantifiers.l = "里粒类辆列轮厘领缕"
    let s:quantifiers.m = "米名枚面门秒"
    let s:quantifiers.n = "年"
    let s:quantifiers.p = "磅盆瓶排盘盆匹片篇撇喷"
    let s:quantifiers.q = "千仟群"
    let s:quantifiers.r = "日"
    let s:quantifiers.s = "十拾时升艘扇首双所束手"
    let s:quantifiers.t = "天吨条头通堂趟台套桶筒贴"
    let s:quantifiers.w = "万位味碗窝晚微"
    let s:quantifiers.x = "席些项"
    let s:quantifiers.y = "月叶亿"
    let s:quantifiers.z = "种只张株支枝盏座阵桩尊则站幢宗兆"
endfunction

" ============================================= }}}
let s:VimIM += [" ====  punctuation      ==== {{{"]
" =================================================

function! s:vimim_dictionary_punctuations()
    let s:punctuations = {}
    let s:punctuations['{'] = "〖"  | let s:space = "　"
    let s:punctuations['}'] = "〗"  | let s:colon = "："
    let s:punctuations['<'] = "《"  | let s:left  = "【"
    let s:punctuations['>'] = "》"  | let s:right = "】"
    let s:punctuations['@'] = s:space
    let s:punctuations[':'] = s:colon
    let s:punctuations['['] = s:left
    let s:punctuations[']'] = s:right
    let s:punctuations['('] = "（"
    let s:punctuations[')'] = "）"
    let s:punctuations['#'] = "＃"
    let s:punctuations['&'] = "＆"
    let s:punctuations['%'] = "％"
    let s:punctuations['$'] = "￥"
    let s:punctuations['!'] = "！"
    let s:punctuations['~'] = "～"
    let s:punctuations['+'] = "＋"
    let s:punctuations['-'] = "－"
    let s:punctuations['='] = "＝"
    let s:punctuations[';'] = "；"
    let s:punctuations[','] = "，"
    let s:punctuations['.'] = "。"
    let s:punctuations['?'] = "？"
    let s:punctuations['*'] = "﹡"
    let s:punctuations['^'] = "……"
    let s:punctuations['_'] = "——"
    let s:evils = {}
    if s:vimim_chinese_punctuation !~ 'latex'
        let s:evils['|'] = "、"
        let s:evils["'"] = "‘’"
        let s:evils['"'] = "“”"
    endif
endfunction

function! <SID>vimim_page_bracket_map(key)
    let hjkl = a:key
    if !pumvisible()
        return hjkl
    endif
    if hjkl =~ "[][]"
        let hjkl = s:vimim_square_bracket(hjkl)
    elseif hjkl =~ "[=.]"
        if &pumheight
            let s:pageup_pagedown = 1
        else
            let hjkl = '\<PageDown>'
        endif
    elseif hjkl =~ "[-,]"
        if &pumheight
            let s:pageup_pagedown = -1
        else
            let hjkl = '\<PageUp>'
        endif
    endif
    if hjkl == a:key
        let hjkl = g:vimim()
    endif
    sil!exe 'sil!return "' . hjkl . '"'
endfunction

function! s:vimim_punctuation_mapping()
    if s:chinese_punctuation > 0
    \&& s:vimim_chinese_punctuation !~ 'latex'
        inoremap ' <C-R>=<SID>vimim_get_quote(1)<CR>
        inoremap " <C-R>=<SID>vimim_get_quote(2)<CR>
        exe 'inoremap <Bar> ' .
        \ '<C-R>=pumvisible() ? "<C-Y>" : ""<CR>' . s:evils['|']
    else
        for _ in keys(s:evils)
            sil!exe 'iunmap '. _
        endfor
    endif
    for _ in keys(s:punctuations)
        silent!exe 'inoremap <silent> <expr> '    ._.
        \ ' <SID>vimim_chinese_punctuation_map("'._.'")'
    endfor
    return ""
endfunction

function! <SID>vimim_chinese_punctuation_map(key)
    let key = a:key
    if s:chinese_punctuation > 0
        let one_before = getline(".")[col(".")-2]
        if one_before !~ '\w' || pumvisible()
            if has_key(s:punctuations, a:key)
                let key = s:punctuations[a:key]
            endif
        endif
    endif
    if pumvisible()
        if a:key == ";"  " the 2nd choice
            let key = '\<Down>\<C-Y>' . g:vimim()
        else
            let key = '\<C-Y>' . key
        endif
    endif
    sil!exe 'sil!return "' . key . '"'
endfunction

function! <SID>vimim_onekey_punctuation_map(key)
    let hjkl = a:key
    if !pumvisible()
        return hjkl
    endif
    if hjkl == "'"  " cycle through BB/GG/SS/00 clouds
        if s:keyboard[-1:] != "'"
            let s:onekey = s:onekey==1 ? 2 : 3
            call s:vimim_last_quote("action_on_omni_popup")
        endif
    elseif hjkl ==# '*'
        let s:hjkl_star += 1
    elseif hjkl == ';'
        let hjkl = '\<C-Y>\<C-R>=g:vimim_menu_to_clip()\<CR>'
    elseif hjkl =~ "[<>]"
        let hjkl = '\<C-Y>' . s:punctuations[nr2char(char2nr(hjkl)-16)]
    elseif hjkl =~ "[/?]"
        let hjkl = s:vimim_menu_search(hjkl)
    endif
    if hjkl == a:key
        let hjkl = g:vimim()
    endif
    sil!exe 'sil!return "' . hjkl . '"'
endfunction

function! <SID>vimim_get_quote(type)
    let key = ""
        if a:type == 1 | let key = "'"
    elseif a:type == 2 | let key = '"' | endif
    let quote = ""
    if !has_key(s:evils, key)
        return ""
    elseif pumvisible()
        let quote = '\<C-Y>'
    endif
    let pairs = split(s:evils[key], '\zs')
    if a:type == 1
        if s:onekey
            let s:smart_single_quotes += 1
            let quote .= get(pairs, s:smart_single_quotes % 2)
        else  " the 3rd choice
            let quote = '\<Down>\<Down>\<C-Y>' . g:vimim()
        endif
    elseif a:type == 2
        let s:smart_double_quotes += 1
        let quote .= get(pairs, s:smart_double_quotes % 2)
    endif
    sil!exe 'sil!return "' . quote . '"'
endfunction

" ============================================= }}}
let s:VimIM += [" ====  miscellaneous    ==== {{{"]
" =================================================

function! s:vimim_get_valid_im_name(im)
    let im = a:im
    if im =~ '^wubi'
        let im = 'wubi'
    elseif im =~ '^pinyin'
        let im = 'pinyin'
    elseif im !~ s:all_vimim_input_methods
        let im = 0
    endif
    return im
endfunction

function! s:vimim_set_special_property()
    if s:backend[s:ui.root][s:ui.im].name =~# "quote"
        let s:ui.has_dot = 2      " has apostrophe in datafile
    endif
    for im in split('wu erbi yong nature boshiamy phonetic array30')
        if s:ui.im == im
            let s:ui.has_dot = 1  " has dot in datafile
            let s:vimim_chinese_punctuation = -9
            break
        endif
    endfor
    let s:imode_pinyin = 0
    if s:ui.im =~ 'pinyin' || s:onekey > 1
        let s:imode_pinyin = 1
        if empty(s:quanpin_table)
            let s:quanpin_table = s:vimim_create_quanpin_table()
        endif
    endif
endfunction

function! s:vimim_wubi_auto_input_on_the_4th(keyboard)
    let keyboard = a:keyboard
    if s:chinese_mode =~ 'dynamic'
        if len(keyboard) > 4
            let start = 4*((len(keyboard)-1)/4)
            let keyboard = strpart(keyboard, start)
        endif
        let s:keyboard = keyboard
    endif
    return keyboard
endfunction

function! g:vimim_wubi_ctrl_e_ctrl_y()
    let key = ""
    if pumvisible()
        let key = '\<C-E>'
        if empty(len(get(split(s:keyboard,","),0))%4)
            let key = '\<C-Y>'
        endif
    endif
    sil!exe 'sil!return "' . key . '"'
endfunction

function! s:vimim_plugin_conflict_on()
    if !exists('s:acp_sid')
        let s:acp_sid = s:vimim_getsid('autoload/acp.vim')
        if !empty(s:acp_sid)
            AcpDisable
        endif
    endif
    if !exists('s:supertab_sid')
        let s:supertab_sid = s:vimim_getsid('plugin/supertab.vim')
    endif
    if !exists('s:word_complete')
        let s:word_complete = s:vimim_getsid('plugin/word_complete.vim')
        if !empty(s:word_complete)
            call EndWordComplete()
        endif
    endif
endfunction

function! s:vimim_plugin_conflict_off()
    if !empty(s:acp_sid)
        let ACPMappingDrivenkeys = [
            \ '-','_','~','^','.',',',':','!','#','=','%','$','@',
            \ '<','>','/','\','<Space>','<BS>','<CR>',]
        call extend(ACPMappingDrivenkeys, range(10))
        call extend(ACPMappingDrivenkeys, s:Az_list)
        for key in ACPMappingDrivenkeys
            exe printf('iu <silent> %s', key)
            exe printf('im <silent> %s %s<C-r>=<SNR>%s_feedPopup()<CR>',
            \ key, key, s:acp_sid)
        endfor
        AcpEnable
    endif
    if !empty(s:supertab_sid)
        let tab = s:supertab_sid
        if g:SuperTabMappingForward =~ '^<tab>$'
            exe printf("im <tab> <C-R>=<SNR>%s_SuperTab('p')<CR>", tab)
        endif
        if g:SuperTabMappingBackward =~ '^<s-tab>$'
            exe printf("im <s-tab> <C-R>=<SNR>%s_SuperTab('n')<CR>", tab)
        endif
    endif
endfunction

function! s:vimim_getsid(scriptname)
    " use s:getsid to get script sid, translate <SID> to <SNR>N_ style
    let l:scriptname = a:scriptname
    " get output of ":scriptnames" in scriptnames_output variable
    if empty(s:scriptnames_output)
        let saved_shellslash=&shellslash
        set shellslash
        redir => s:scriptnames_output
        silent scriptnames
        redir END
        let &shellslash = saved_shellslash
    endif
    for line in split(s:scriptnames_output, "\n")
        " only do non-blank lines
        if line =~ l:scriptname
            " get the first number in the line
            return matchstr(line, '\d\+')
        endif
    endfor
    return 0
endfunction

" ============================================= }}}
let s:VimIM += [" ====  user   interface ==== {{{"]
" =================================================

function! s:vimim_dictionary_statusline()
    let s:status = {}
    let s:status.onekey     = "点石成金 點石成金"
    let s:status.computer   = "电脑 電腦"
    let s:status.database   = "词库 詞庫"
    let s:status.directory  = "目录 目錄"
    let s:status.setup      = "设置 設置"
    let s:status.encoding   = "编码 編碼"
    let s:status.env        = "环境 環境"
    let s:status.revision   = "版本"
    let s:status.input      = "输入 輸入"
    let s:status.font       = "字体 字體"
    let s:status.static     = "静态 靜態"
    let s:status.dynamic    = "动态 動態"
    let s:status.style      = "风格 風格"
    let s:status.erbi       = "二笔 二筆"
    let s:status.wubi       = "五笔 五筆"
    let s:status.5strokes   = "五笔画 五筆畫"
    let s:status.4corner    = "四角号码 四角號碼"
    let s:status.hangul     = "韩文 韓文"
    let s:status.xinhua     = "新华 新華"
    let s:status.zhengma    = "郑码 鄭碼"
    let s:status.cangjie    = "仓颉 倉頡"
    let s:status.yong       = "永码 永碼"
    let s:status.wu         = "吴语 吳語"
    let s:status.jidian     = "极点 極點"
    let s:status.haifeng    = "海峰"
    let s:status.shuangpin  = "双拼 雙拼"
    let s:status.boshiamy   = "呒虾米 嘸蝦米"
    let s:status.newcentury = "新世纪 新世紀"
    let s:status.taijima    = "太极码 太極碼"
    let s:status.abc        = "智能双打 智能雙打"
    let s:status.ms         = "微软 微軟"
    let s:status.nature     = "自然码 自然碼"
    let s:status.mixture    = "混合"
    let s:status.purple     = "紫光"
    let s:status.plusplus   = "加加"
    let s:status.flypy      = "小鹤 小鶴"
    let s:status.quick      = "速成"
    let s:status.array30    = "行列"
    let s:status.phonetic   = "注音"
    let s:status.pinyin     = "拼音"
    let s:status.full_width = "全角"
    let s:status.half_width = "半角"
    let s:status.mycloud    = "自己的云 自己的雲"
    let s:status.cloud      = "云 雲"
    let s:status.network    = "联网 聯網"
    let s:status.sogou      = "搜狗"
    let s:status.google     = "谷歌"
    let s:status.baidu      = "百度"
    let s:status.qq         = "QQ"
    let s:status.datafile   = "文件"
    let s:status.mass       = "海量"
    let s:status.unicode    = "统一码 萬國碼"
    let s:status.datetime   = "日期"
    let s:status.english    = "英文"
    let s:status.chinese    = "中文"
endfunction

function! s:vimim_chinese(key)
    let chinese = a:key
    if has_key(s:status, chinese)
        let twins = split(s:status[chinese])
        let chinese = get(twins,0)
        if len(twins) > 1 && s:vimim_onekey_is_tab < 2
            let chinese = get(twins,1)
        endif
    endif
    return chinese
endfunction

function! g:vimim_default_omni_color()
    highlight! PmenuSbar  NONE
    highlight! PmenuThumb NONE
    highlight! Pmenu      NONE
    highlight! link PmenuSel Title
endfunction

function! s:vimim_skin(color)
    let color = 1
    let &pumheight = 10
    let menu_in_one_row = 0
    if empty(s:onekey) && s:vimim_one_row_menu
        let color = 0
        let menu_in_one_row = 1
        let &pumheight = 5
    endif
    let s:pumheight = copy(&pumheight)
    if s:show_me_not
        let color = 0
        let &pumheight = 0
    elseif s:hjkl_l
        let &pumheight = s:hjkl_l%2 ? 0 : s:pumheight
    endif
    if empty(a:color) || s:vimim_custom_color > 1
        let color = 0
    endif
    if s:vimim_custom_color
        call g:vimim_default_omni_color()
        if empty(color)
            highlight!      PmenuSel NONE
            highlight! link PmenuSel NONE
        endif
    endif
    return menu_in_one_row
endfunction

function! s:vimim_set_statusline()
    set laststatus=2
    if empty(&statusline)
        set statusline=%<%f\ %h%m%r%=%-14.(%l,%c%V%)\ %P%{IMName()}
    elseif &statusline =~ 'IMName'
        " nothing, because it is already in the statusline
    elseif &statusline =~ '\V\^%!'
        let &statusline .= '.IMName()'
    else
        let &statusline .= '%{IMName()}'
    endif
endfunction

function! IMName()
    " This function is for user-defined 'stl' 'statusline'
    if s:chinese_mode =~ 'onekey'
        if pumvisible()
            return s:vimim_statusline()
        endif
    elseif !empty(&omnifunc) && &omnifunc ==# 'VimIM'
        return s:vimim_statusline()
    endif
    return ""
endfunction

function! s:vimim_statusline()
    if empty(s:ui.root) || empty(s:ui.im)
        return ""
    endif
    if has_key(s:im_keycode, s:ui.im)
        let s:ui.statusline = s:backend[s:ui.root][s:ui.im].chinese
    endif
    let datafile = s:backend[s:ui.root][s:ui.im].name
    if s:ui.im =~ 'wubi'
        if datafile =~# 'wubi98'
            let s:ui.statusline .= '98'
        elseif datafile =~# 'wubi2000'
            let newcentury = s:vimim_chinese('newcentury')
            let s:ui.statusline = newcentury . s:ui.statusline
        elseif datafile =~# 'wubijd'
            let jidian = s:vimim_chinese('jidian')
            let s:ui.statusline = jidian . s:ui.statusline
        elseif datafile =~# 'wubihf'
            let haifeng = s:vimim_chinese('haifeng')
            let s:ui.statusline = haifeng . s:ui.statusline
        endif
        return s:vimim_get_chinese_im()
    endif
    if len(s:backend.datafile) > 0 || len(s:backend.directory) > 0
        if !empty(s:vimim_shuangpin)
            let s:ui.statusline .= s:space
            let s:ui.statusline .= s:shuangpin_keycode_chinese.chinese
        endif
    endif
    if !empty(s:mycloud)
        let __getname = s:backend.cloud.mycloud.directory
        let s:ui.statusline .= s:space . __getname
    elseif s:ui.root == 'cloud'
        let vimim_cloud = get(split(s:vimim_cloud,','), 0)
        if vimim_cloud =~ 'mixture'
            let s:ui.statusline .= s:vimim_chinese('mixture')
        elseif vimim_cloud =~ 'wubi'
            let s:ui.statusline .= s:vimim_chinese('wubi')
        elseif vimim_cloud =~ 'shuangpin'
            if vimim_cloud =~ 'abc'
                let s:ui.statusline .= s:vimim_chinese('abc')
            elseif vimim_cloud =~ 'ms'
                let s:ui.statusline .= s:vimim_chinese('ms')
            elseif vimim_cloud =~ 'plusplus'
                let s:ui.statusline .= s:vimim_chinese('plusplus')
            elseif vimim_cloud =~ 'purple'
                let s:ui.statusline .= s:vimim_chinese('purple')
            elseif vimim_cloud =~ 'flypy'
                let s:ui.statusline .= s:vimim_chinese('flypy')
            elseif vimim_cloud =~ 'nature'
                let s:ui.statusline .= s:vimim_chinese('nature')
            endif
            if vimim_cloud !~ 'abc'
                let s:ui.statusline .= s:vimim_chinese('shuangpin')
            endif
        endif
        let s:ui.statusline .= s:vimim_chinese('cloud')
    endif
    return s:vimim_get_chinese_im()
endfunction

function! s:vimim_get_chinese_im()
    if empty(s:onekey)
        let punctuation = s:vimim_chinese('half_width')
        if s:chinese_punctuation > 0
            let punctuation = s:vimim_chinese('full_width')
        endif
        let s:ui.statusline .= s:space . punctuation
    endif
    let statusline = s:left . s:ui.statusline . s:right . "VimIM"
    let input_style  = s:vimim_chinese('chinese')
    let input_style .= s:vimim_chinese(s:vimim_chinese_input_mode)
    let input_style .= statusline
    return input_style
endfunction

function! s:vimim_map_omni_page_label()
    let labels = range(10)
    let common_punctuation = "[]=-"
    if s:onekey
        let common_punctuation .= ".,"
        let labels += split(s:abcd, '\zs')
        call remove(labels, match(labels,"'"))
    endif
    for _ in split(common_punctuation, '\zs')
        exe 'inoremap<expr> '._.' <SID>vimim_page_bracket_map("'._.'")'
    endfor
    for _ in labels
        silent!exe 'inoremap <silent> <expr> '  ._.
        \  ' <SID>vimim_abcdvfgsz_1234567890_map("'._.'")'
    endfor
endfunction

function! <SID>vimim_abcdvfgsz_1234567890_map(key)
    let key = a:key
    if pumvisible()
        let n = match(s:abcd, key)
        if key =~ '\d'
            let n = key<1 ? 9 : key-1
        endif
        let down = repeat("\<Down>", n)
        let key = down . '\<C-Y>' . g:vimim()
        let s:has_pumvisible = 1
        if s:onekey && a:key =~ '\d'
            call g:vimim_stop()
        else
            call g:vimim_reset_after_insert()
        endif
    endif
    sil!exe 'sil!return "' . key . '"'
endfunction

function! s:vimim_menu_search(key)
    let slash = ""
    if pumvisible()
        let slash  = '\<C-Y>\<C-R>=g:vimim_menu_search_on()\<CR>'
        let slash .= a:key . '\<CR>'
    endif
    sil!exe 'sil!return "' . slash . '"'
endfunction

function! g:vimim_menu_search_on()
    let word = s:vimim_popup_word()
    let @/ = empty(word) ? @_ : word
    let repeat_times = len(word) / s:multibyte
    let row_start = s:start_row_before
    let row_end = line(".")
    let delete_chars = ""
    if repeat_times > 0 && row_end == row_start
        let delete_chars = repeat("\<BS>", repeat_times)
    endif
    let slash = delete_chars . "\<Esc>"
    sil!call g:vimim_stop()
    sil!exe 'sil!return "' . slash . '"'
endfunction

function! g:vimim_menu_to_clip()
    let word = s:vimim_popup_word()
    if !empty(word)
        if has("gui_running") && has("win32")
            let @+ = word
        endif
    endif
    call g:vimim_stop()
    sil!exe "sil!return '\<Esc>'"
endfunction

function! s:vimim_popup_word()
    if pumvisible()
        return ""
    endif
    let column_start = s:start_column_before
    let column_end = col(".") - 1
    let range = column_end - column_start
    let chinese = strpart(getline("."), column_start, range)
    return substitute(chinese,'\w','','g')
endfunction

function! s:vimim_square_bracket(key)
    let key = a:key
    if pumvisible()
        let _     = key=="]" ? 0          : -1
        let left  = key=="]" ? "\<Left>"  : ""
        let right = key=="]" ? "\<Right>" : ""
        let backspace = '\<C-R>=g:vimim_bracket('._.')\<CR>'
        let key = '\<C-Y>' . left . backspace . right
    endif
    sil!exe 'sil!return "' . key . '"'
endfunction

function! g:vimim_bracket(offset)
    let column_end = col(".")-1
    let column_start = s:start_column_before
    let range = column_end - column_start
    let repeat_times = range / s:multibyte
    let repeat_times += a:offset
    let row_end = line(".")
    let row_start = s:start_row_before
    let delete_char = ""
    if repeat_times > 0 && row_end == row_start
        if a:offset > 0  " omni bslash for seamless
            let left = repeat("\<Left>", repeat_times-1)
            let right = repeat("\<Right>", repeat_times-1)
            let delete_char = left . "\<BS>" . right
        else
            let delete_char = repeat("\<BS>", repeat_times)
        endif
    endif
    if repeat_times < 1
        let current_line = getline(".")
        let chinese = strpart(current_line, column_start, s:multibyte)
        let delete_char = chinese
        if empty(a:offset)
            let chinese = s:left . chinese . s:right
            let delete_char = "\<Right>\<BS>" . chinese . "\<Left>"
        endif
    endif
    return delete_char
endfunction

function! <SID>vimim_esc()
    let hjkl = '\<Esc>'
    if s:onekey
        sil!call g:vimim_stop()
    elseif pumvisible()
        let hjkl = s:vimim_onekey_esc()
        sil!call g:vimim_reset_after_insert()
    endif
    sil!exe 'sil!return "' . hjkl . '"'
endfunction

function! s:vimim_onekey_esc()
    let hjkl = '\<C-E>'
    let column_start = s:start_column_before
    let column_end = col(".") - 1
    let range = column_end - column_start
    if range > 0
        let hjkl .= repeat("\<BS>", range)
    endif
    return hjkl
endfunction

function! <SID>vimim_backspace()
    let key = '\<BS>'
    if pumvisible()
        let key = '\<C-E>\<BS>\<C-R>=g:vimim()\<CR>'
    endif
    sil!exe 'sil!return "' . key . '"'
endfunction

function! <SID>vimim_enter()
    " (1) single <Enter> after English => seamless
    " (2) otherwise, or double <Enter> => <Enter>
    let one_before = getline(".")[col(".")-2]
    let key = ""
    if pumvisible()
        let key = "\<C-E>"
        let s:smart_enter = 1
    elseif one_before =~ s:valid_key
        let s:smart_enter += 1
    else
        let s:smart_enter = 0
    endif
    if s:smart_enter == 1
        let s:seamless_positions = getpos(".")
    else
        let key = "\<CR>"
        let s:smart_enter = 0
    endif
    sil!exe 'sil!return "' . key . '"'
endfunction

function! <SID>vimim_backslash()
    " (1) [insert] disable omni window
    " (2) [omni]   insert Chinese and remove Space before
    let bslash = '\\'
    if pumvisible()
        let bslash = '\<C-Y>\<C-R>=g:vimim_bracket('.1.')\<CR>'
    endif
    sil!exe 'sil!return "' . bslash . '"'
endfunction

function! s:vimim_get_labeling(label)
    let labeling = a:label==10 ? "0" : a:label
    if s:onekey && a:label < 11
        let label2 = a:label<2 ? "_" : s:abcd[a:label-1]
        if s:onekey > 1
            " onekey label BB for cloud Baidu
            " onekey label GG for cloud Google
            " onekey label SS for cloud Sogou
            " onekey label 00 for cloud QQ
            let vimim_cloud = get(split(s:vimim_cloud,','), 0)
            let cloud = get(split(vimim_cloud,'[.]'),0)
            if label2 == cloud[0:0]  " b/g/s
                let label2 = toupper(label2)
                let labeling = label2
            elseif label2 == 'z' && cloud =~ 'qq'
                let label2 = '0'
            endif
        endif
        let labeling .= label2
        if labeling == '0'
            let labeling = '10'
        endif
    endif
    return labeling
endfunction

" ============================================= }}}
let s:VimIM += [" ====  python interface ==== {{{"]
" =================================================

function! s:vimim_get_stone_from_bsddb(stone)
:sil!python << EOF
try:
    stone = vim.eval('a:stone')
    marble = getstone(stone)
    vim.command("return '%s'" % marble)
except vim.error:
    print("vim error: %s" % vim.error)
EOF
return ""
endfunction

function! s:vimim_get_gold_from_bsddb(stone)
:sil!python << EOF
try:
    gold = getgold(vim.eval('a:stone'))
    vim.command("return '%s'" % gold)
except vim.error:
    print("vim error: %s" % vim.error)
EOF
return ""
endfunction

function! s:vimim_initialize_bsddb(datafile)
:sil!python << EOF
import vim, bsddb
encoding = vim.eval("&encoding")
datafile = vim.eval('a:datafile')
edw = bsddb.btopen(datafile,'r')
def getstone(stone):
    isenglish = vim.eval('s:english_results')
    if stone not in edw and not isenglish:
        while stone and stone not in edw: stone = stone[:-1]
    return stone
def getgold(stone):
    gold = stone
    if stone and stone in edw:
         gold = edw.get(stone)
         if encoding == 'utf-8':
               if datafile.find("gbk") > 0:
                   gold = unicode(gold,'gb18030','ignore')
                   gold = gold.encode(encoding,'ignore')
         elif datafile.find("utf8") > 0:
               gold = unicode(gold,'utf-8','ignore')
               gold = gold.encode(encoding,'ignore')
    gold = stone + ' ' + gold
    return gold
EOF
endfunction

function! s:vimim_get_from_python2(input, cloud)
:sil!python << EOF
import vim, urllib2
cloud = vim.eval('a:cloud')
input = vim.eval('a:input')
encoding = vim.eval("&encoding")
try:
    urlopen = urllib2.urlopen(input, None, 20)
    response = urlopen.read()
    res = "'" + str(response) + "'"
    if cloud == 'qq':
        if encoding != 'utf-8':
            res = unicode(res, 'utf-8').encode('utf-8')
    elif cloud == 'google':
        if encoding != 'utf-8':
            res = unicode(res, 'unicode_escape').encode("utf8")
    elif cloud == 'baidu':
        if encoding != 'utf-8':
            res = str(response)
        else:
            res = unicode(response, 'gbk').encode(encoding)
        vim.command("let g:baidu = %s" % res)
    vim.command("return %s" % res)
    urlopen.close()
except vim.error:
    print("vim error: %s" % vim.error)
EOF
return ""
endfunction

function! s:vimim_get_from_python3(input, cloud)
:sil!python3 << EOF
import vim, urllib.request
try:
    cloud = vim.eval('a:cloud')
    input = vim.eval('a:input')
    urlopen = urllib.request.urlopen(input)
    response = urlopen.read()
    if cloud != 'baidu':
        res = "'" + str(response.decode('utf-8')) + "'"
    else:
        if vim.eval("&encoding") != 'utf-8':
            res = str(response)[2:-1]
        else:
            res = response.decode('gbk')
        vim.command("let g:baidu = %s" % res)
    vim.command("return %s" % res)
    urlopen.close()
except vim.error:
    print("vim error: %s" % vim.error)
EOF
return ""
endfunction

function! g:vimim_gmail() range abort
" [dream] to send email from within the current buffer
" [usage] :call g:vimim_gmail()
" [vimrc] :let  g:gmails={'login':'','passwd':'','to':'','bcc':''}
if has('python') < 1 && has('python3') < 1
    echo 'No magic Python Interface to Vim' | return ""
endif
let firstline = a:firstline
let  lastline = a:lastline
if lastline - firstline < 1
    let firstline = 1
    let lastline = "$"
endif
let g:gmails.msg = getline(firstline, lastline)
let python = has('python3') && &relativenumber>0 ? 'python3' : 'python'
exe python . ' << EOF'
import vim
from smtplib import SMTP
from datetime import datetime
from email.mime.text import MIMEText
def vimim_gmail():
    gmails = vim.eval('g:gmails')
    vim.command('sil!unlet g:gmails.bcc')
    now = datetime.now().strftime("%A %m/%d/%Y")
    gmail_login  = gmails.get("login","")
    if len(gmail_login) < 8: return None
    gmail_passwd = gmails.get("passwd")
    gmail_to     = gmails.get("to")
    gmail_bcc    = gmails.get("bcc","")
    gmail_msg    = gmails.get("msg")
    gamil_all = [gmail_to] + gmail_bcc.split()
    msg = str("\n".join(gmail_msg))
    rfc2822 = MIMEText(msg, 'plain', 'utf-8')
    rfc2822['From'] = gmail_login
    rfc2822['To'] = gmail_to
    rfc2822['Subject'] = now
    rfc2822.set_charset('utf-8')
    try:
        gmail = SMTP('smtp.gmail.com', 587, 120)
        gmail.starttls()
        gmail.login(gmail_login, gmail_passwd[::-1])
        gmail.sendmail(gmail_login, gamil_all, rfc2822.as_string())
    finally:
        gmail.close()
vimim_gmail()
EOF
endfunction

function! s:vimim_mycloud_python_init()
:sil!python << EOF
import vim, sys, socket
BUFSIZE = 1024
def tcpslice(sendfunc, data):
    senddata = data
    while len(senddata) >= BUFSIZE:
        sendfunc(senddata[0:BUFSIZE])
        senddata = senddata[BUFSIZE:]
    if senddata[-1:] == "\n":
        sendfunc(senddata)
    else:
        sendfunc(senddata+"\n")
def tcpsend(data, host, port):
    addr = host, port
    s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    try:
        s.connect(addr)
    except Exception, inst:
        s.close()
        return None
    ret = ""
    for item in data.split("\n"):
        if item == "":
            continue
        tcpslice(s.send, item)
        cachedata = ""
        while cachedata[-1:] != "\n":
            data = s.recv(BUFSIZE)
            cachedata += data
        if cachedata == "server closed\n":
            break
        ret += cachedata
    s.close()
    return ret
def parsefunc(keyb, host="localhost", port=10007):
    src = keyb.encode("base64")
    ret = tcpsend(src, host, port)
    if type(ret).__name__ == "str":
        try:
            return ret.decode("base64")
        except Exception:
            return ""
    else:
        return ""
EOF
endfunction

function! s:vimim_mycloud_python_client(cmd, host, port)
:sil!python << EOF
try:
    HOST = vim.eval("a:host")
    PORT = int(vim.eval("a:port"))
    cmd  = vim.eval("a:cmd")
    ret = parsefunc(cmd, HOST, PORT)
    vim.command('return "%s"' % ret)
except vim.error:
    print("vim error: %s" % vim.error)
EOF
endfunction

function! s:netlog_python_init()
:sil!python << EOF
import vim, sys, socket
BUFSIZE = 1024
def udpslice(sendfunc, data, addr):
    senddata = data
    while len(senddata) >= BUFSIZE:
        sendfunc(senddata[0:BUFSIZE], addr)
        senddata = senddata[BUFSIZE:]
    if senddata[-1:] == "\n":
        sendfunc(senddata, addr)
    else:
        sendfunc(senddata+"\n", addr)
def udpsend(data, host, port):
    addr = host, port
    s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    s.settimeout(1)
    try:
        s.bind(('', 0))
    except Exception, inst:
        s.close()
        return None
    ret = ""
    for item in data.split("\n"):
        if item == "":
            continue
        udpslice(s.sendto, item, addr)
    s.close()
def log_mask(level):
    pri = g_level.get(level, -1)
    if pri < 0:
        return 0
    else:
        return 1 << pri
def log_upto(level):
    pri = g_level.get(level, -1)
    return (1 <<(pri+1) ) - 1
def checkmask(level):
    if log_mask(level) & g_mask:
        return True
    else:
        return False
g_level = {'emerg':0,    #  system is unusable
           'alert':1,    #  action must be taken immediately
           'crit':2,     #  critical conditions
           'err':3,      #  error conditions
           'warning':4,  #  warning conditions
           'notice':5,   #  normal but significant condition
           'info':6,     #  informational
           'debug':7 }   #  debug-level messages
g_mask = log_upto('info')
EOF
endfunction

function! s:debug(...)
" [server] sdebug(){ /bin/python ~/vim/vimfiles/plugin/sdebug.py ;}
" [client] :call s:debug('info', 'foo/bar is', foobar, 'and', bar)
if s:vimim_debug < 1 || has('python') < 1
    return
endif
if s:vimim_debug < 2
    call s:netlog_python_init()
    let s:vimim_debug += 1
endif
if s:vimim_debug < 2
    return
endif
:sil!python << EOF
try:
    level = vim.eval("a:1")
    if checkmask(level):
        udpsend(vim.eval("join(a:000)"),"localhost",10007)
except vim.error:
    print("vim error: %s" % vim.error)
EOF
endfunction

" ============================================= }}}
let s:VimIM += [" ====  mode: onekey     ==== {{{"]
" =================================================

function! g:vimim_onekey_dump()
    let saved_position = getpos(".")
    let keyboard = get(split(s:keyboard,","),0)
    let space = repeat(" ", virtcol(".")-len(keyboard)-1)
    for items in s:popupmenu_list
        let line = printf('%s', items.word)
        if has_key(items, "abbr")
            let line = printf('%s', items.abbr)
            if has_key(items, "menu")
                let line = printf('%s %s', items.abbr, items.menu)
            endif
        endif
        put=space.line
    endfor
    call setpos(".", saved_position)
    sil!call g:vimim_stop()
    sil!exe "sil!return '\<Esc>'"
endfunction

function! g:vimim_onekey()
    " (1)<OneKey> in insert mode => start OneKey as the MidasTouch
    " (2)<OneKey> in OneKey mode => stop  OneKey
    " (3)<OneKey> in omni window => stop  OneKey and print out menu
    " (4)<OneKey> in menuless    => toggle &number/&relativenumber
    let onekey = ''
    let s:chinese_mode = 'onekey'
    let space_before = getline(".")[col(".")-2]
    let space_before = space_before=~'\s' || empty(space_before) ? 1 : 0
    sil!call s:vimim_backend_initialization()
    if pumvisible() && len(s:popupmenu_list)
        let onekey = '\<C-R>=g:vimim_onekey_dump()\<CR>'
    elseif s:onekey
        if s:vimim_menuless && &number
            set relativenumber
            let &pumheight = 10
            let onekey = '\<C-E>\<C-R>=g:vimim()\<CR>'
        elseif s:vimim_menuless && &relativenumber
            set number
            set norelativenumber
        else
            sil!call g:vimim_stop()
        endif
    elseif s:vimim_onekey_is_tab && space_before
        let onekey = '\t'
    else
        sil!call s:vimim_super_reset()
        let s:onekey = s:ui.root=='cloud' ? 2 : 1
        sil!call s:vimim_start()
        sil!call s:vimim_onekey_mapping()
        let onekey = s:vimim_onekey_action(0)
    endif
    sil!exe 'sil!return "' . onekey . '"'
endfunction

function! s:vimim_onekey_action(space)
    let space = a:space ? " " : ""
    let current_line = getline(".")
    let one_before = current_line[col(".")-2]
    let onekey = s:vimim_onekey_evil_action()
    if !empty(onekey)
        sil!exe 'sil!return "' . onekey . '"'
    endif
    let onekey = space
    if one_before =~# s:valid_key
        let onekey = g:vimim()
    endif
    sil!exe 'sil!return "' . onekey . '"'
endfunction

function! s:vimim_onekey_evil_action()
    let current_line = getline(".")
    let one_before = current_line[col(".")-2]
    let two_before = current_line[col(".")-3]
    if two_before =~ s:valid_key || !empty(s:ui.has_dot)
        return ""
    endif
    let onekey = ""
    let punctuations = copy(s:punctuations)
    call extend(punctuations, s:evils)
    if has_key(punctuations, one_before)
        for char in keys(punctuations)
            " no transfer for punctuation after punctuation
            if two_before ==# char || two_before =~# '\u'
                return " "
            endif
        endfor
        " transfer English punctuation to Chinese punctuation
        let bs = punctuations[one_before]
            if one_before == "'" | let bs = <SID>vimim_get_quote(1)
        elseif one_before == '"' | let bs = <SID>vimim_get_quote(2)
        endif
        let onekey = "\<BS>" . bs
    endif
    sil!exe 'sil!return "' . onekey . '"'
endfunction

function! s:vimim_get_cursor()
    let current_line = getline(".")
    let current_column = col(".")-1
    let start_column = current_column
    let before = current_line[current_column-1]
    let cursor = current_line[current_column]
    let n = 0  " to trigger Word under cursor
    if before =~# '\l' && cursor =~# '\l'
        while cursor =~# '\l'
            let current_column += 1
            let cursor = current_line[current_column]
        endwhile
        let n = current_column - start_column
    endif
    let right_arrow = ""
    if n > 0 && n < 72
        let right_arrow = repeat("\<Right>",n)
    endif
    if current_line[current_column] == "'"
        let right_arrow .= '\<Delete>'
    endif
    sil!exe 'sil!return "' . right_arrow . '"'
endfunction

function! <SID>vimim_space()
    " (1) <Space> after English (valid keys) => trigger keycode menu
    " (2) <Space> after English punctuation  => get Chinese punctuation
    " (3) <Space> after popup menu           => insert Chinese
    " (4) <Space> after pattern not found    => <Space>
    let space = " "
    if pumvisible()
        let space = '\<C-Y>\<C-R>=g:vimim()\<CR>'
        let s:has_pumvisible = 1
        call g:vimim_reset_after_insert()
    elseif s:chinese_mode !~ 'dynamic'
        if s:chinese_mode =~ 'static'
            let space = s:vimim_static_action(space)
        elseif s:onekey
            let space  = s:vimim_get_cursor()
            let space .= s:vimim_onekey_action(1)
        endif
        let space .= g:vimim_reset_after_insert()
    endif
    sil!exe 'sil!return "' . space . '"'
endfunction

function! s:vimim_onekey_mapping()
    if empty(s:cjk_filename)
        for _ in s:qwer
            exe 'inoremap<expr> '._.' <SID>vimim_qwer_hitrun_map("'._.'")'
        endfor
    else
        for _ in s:qwer
            exe 'inoremap<expr> '._.' <SID>vimim_qwer_hjkl_map("'._.'")'
        endfor
    endif
    if s:vimim_chinese_punctuation !~ 'latex'
        for _ in s:AZ_list
            exe 'inoremap<expr> '._.' <SID>vimim_onekey_caps_map("'._.'")'
        endfor
    endif
    for _ in split('xhjklmn', '\zs')
        exe 'inoremap<expr> '._.' <SID>vimim_onekey_hjkl_map("'._.'")'
    endfor
    let onekey_punctuation = "/?;'<>"
    if !empty(s:cjk_filename)
        let onekey_punctuation .= "*"
    endif
    for _ in split(onekey_punctuation, '\zs')
        exe 'inoremap<expr> '._.' <SID>vimim_onekey_punctuation_map("'._.'")'
    endfor
endfunction

function! <SID>vimim_qwer_hitrun_map(key)
    let key = a:key
    if pumvisible()
        let digit = match(s:qwer, key) - 1
        if digit < 0
            let digit = 9
        endif
        let down = repeat("\<Down>", digit)
        let yes = '\<C-Y>\<C-R>=g:vimim()\<CR>'
        let key = down . yes
        let s:has_pumvisible = 1
        if s:onekey
            call g:vimim_stop()
        endif
    endif
    sil!exe 'sil!return "' . key . '"'
endfunction

function! <SID>vimim_qwer_hjkl_map(key)
    let key = a:key
    if pumvisible()
        let digit = match(s:qwer, key)
        if s:cjk_filename =~ "vimim.cjkv.txt"
            if digit < 1
                let digit = 5  " qwert/12345 for five strokes
            elseif digit > 5
                let digit -= 5 " yuiop/12345 for five strokes
            endif
        endif
        let s:hjkl_n = s:show_me_not ? digit : s:hjkl_n . digit
        let key = g:vimim()
    endif
    sil!exe 'sil!return "' . key . '"'
endfunction

function! <SID>vimim_onekey_caps_map(key)
    let key = a:key
    if pumvisible()
        let key = tolower(key) . g:vimim()
    endif
    sil!exe 'sil!return "' . key . '"'
endfunction

function! <SID>vimim_onekey_hjkl_map(key)
    let hjkl = a:key
    if !pumvisible()
        return hjkl
    endif
    if hjkl ==# 'n'
        call g:vimim_reset_after_insert()
    elseif hjkl ==# 'x'
        let hjkl = s:vimim_onekey_esc()
    elseif hjkl ==# 'm'
        let s:hjkl_m += 1
    elseif hjkl ==# 'h'
        let s:hjkl_h += 1
    elseif hjkl ==# 'j'
        let hjkl = '\<Down>'
    elseif hjkl ==# 'k'
        let hjkl = '\<Up>'
    elseif hjkl ==# 'l'
        let s:hjkl_l += 1
    endif
    if hjkl == a:key
        let hjkl = g:vimim()
    endif
    sil!exe 'sil!return "' . hjkl . '"'
endfunction

" ============================================= }}}
let s:VimIM += [" ====  mode: dynamic    ==== {{{"]
" =================================================

function! <SID>VimIMSwitch()
    sil!call s:vimim_backend_initialization()
    if len(s:ui.frontends) < 2
        return <SID>ChineseMode()
    endif
    let s:chinese_mode = s:vimim_chinese_input_mode
    let custom_im_list = s:vimim_get_custom_im_list()
    let switch = s:im_toggle % len(custom_im_list)
    let s:im_toggle += 1
    let im = get(custom_im_list, switch)
    let switch = 1
    if im =~ 'english'
        let switch = 0
        let s:frontends = get(s:ui.frontends, 0)
    else
        for frontends in s:ui.frontends
            let frontend_im = get(frontends, 1)
            if frontend_im =~ im
                let s:frontends = frontends
                break
            endif
        endfor
    endif
    return s:vimim_chinese_mode(switch)
endfunction

function! s:vimim_get_custom_im_list()
    let custom_im_list = []
    if s:vimim_toggle_list =~ ","
        let custom_im_list = split(s:vimim_toggle_list, ",")
    elseif len(s:ui.frontends) > 1
        for frontends in s:ui.frontends
            let frontend_im = get(frontends, 1)
            call add(custom_im_list, frontend_im)
        endfor
    endif
    return custom_im_list
endfunction

function! s:vimim_chinese_mode(switch)
    let action = ""
    if a:switch < 1
        sil!call g:vimim_stop()
        if mode() == 'n'
            :redraw!
        endif
    else
        let s:chinese_mode = s:vimim_chinese_input_mode
        let s:ui.root = get(s:frontends,0)
        let s:ui.im = get(s:frontends,1)
        call s:vimim_set_statusline()
        let action = s:vimim_chinesemode_action()
    endif
    sil!exe 'sil!return "' . action . '"'
endfunction

function! <SID>ChineseMode()
    sil!call s:vimim_backend_initialization()
    if empty(s:ui.frontends)
        return ""
    elseif empty(s:frontends)
        let s:frontends = get(s:ui.frontends, 0)
    endif
    let switch = !empty(&omnifunc) && &omnifunc==#'VimIM' ? 0 : 1
    return s:vimim_chinese_mode(switch)
endfunction

function! <SID>vimim_punctuation_toggle()
    let s:chinese_punctuation = (s:chinese_punctuation+1)%2
    call s:vimim_set_statusline()
    return s:vimim_punctuation_mapping()
endfunction

" ============================================= }}}
let s:VimIM += [" ====  mode: static     ==== {{{"]
" =================================================

function! s:vimim_chinesemode_action()
    sil!call s:vimim_super_reset()
    if s:vimim_chinese_punctuation > -1
        inoremap <expr> <C-^> <SID>vimim_punctuation_toggle()
        call s:vimim_punctuation_mapping()
    endif
    sil!call s:vimim_start()
    let action = ""
    if s:chinese_mode =~ 'dynamic'
        let s:seamless_positions = getpos(".")
        let vimim_cloud = get(split(s:vimim_cloud,','), 0)
        if s:ui.im =~ 'wubi\|erbi' || vimim_cloud =~ 'wubi'
            " dynamic auto trigger for wubi
            for char in s:az_list
                sil!exe 'inoremap <silent> ' . char .
                \ ' <C-R>=g:vimim_wubi_ctrl_e_ctrl_y()<CR>'
                \ . char . '<C-R>=g:vimim()<CR>'
            endfor
        else
            " dynamic alphabet trigger for all
            let not_used_valid_keys = "[0-9']"
            if s:ui.has_dot == 1
                let not_used_valid_keys = "[0-9]"
            endif
            for char in s:valid_keys
                if char !~# not_used_valid_keys
                    sil!exe 'inoremap <silent> ' . char .
                    \ ' <C-R>=pumvisible() ? "<C-E>" : ""<CR>'
                    \ . char . '<C-R>=g:vimim()<CR>'
                endif
            endfor
        endif
    elseif s:chinese_mode =~ 'static'
        let map_list = s:Az_list
        if s:vimim_chinese_punctuation =~ 'latex'
            let map_list = s:az_list
        endif
        for char in map_list
            sil!exe 'inoremap <silent> ' . char .
            \ ' <C-R>=pumvisible() ? "<C-Y>" : ""<CR>'
            \ . char . '<C-R>=g:vimim_reset_after_insert()<CR>'
        endfor
        if !pumvisible()
            let action = s:vimim_static_action(action)
        endif
    endif
    sil!exe 'sil!return "' . action . '"'
endfunction

function! s:vimim_static_action(space)
    let space = a:space
    let one_before = getline(".")[col(".")-2]
    if one_before =~# s:valid_key
        let space = g:vimim()
    endif
    sil!exe 'sil!return "' . space . '"'
endfunction

function! s:vimim_set_keyboard_list(column_start, keyboard)
    let s:start_column_before = a:column_start
    if s:keyboard !~ ','
        let s:keyboard = a:keyboard
    endif
endfunction

function! s:vimim_get_seamless(current_positions)
    if empty(s:seamless_positions) || empty(a:current_positions)
        return -1
    endif
    let seamless_bufnum = s:seamless_positions[0]
    let seamless_lnum = s:seamless_positions[1]
    let seamless_off = s:seamless_positions[3]
    let smart_enter = s:chinese_mode=~'dynamic' ? 1 : s:smart_enter
    if empty(smart_enter)
    \|| seamless_bufnum != a:current_positions[0]
    \|| seamless_lnum != a:current_positions[1]
    \|| seamless_off != a:current_positions[3]
        let s:seamless_positions = []
        return -1
    endif
    let seamless_column = s:seamless_positions[2]-1
    let start_column = a:current_positions[2]-1
    let len = start_column - seamless_column
    let start_row = a:current_positions[1]
    let current_line = getline(start_row)
    let snip = strpart(current_line, seamless_column, len)
    if empty(len(snip))
        return -1
    endif
    for char in split(snip, '\zs')
        if char !~ s:valid_key
            return -1
        endif
    endfor
    let s:start_row_before = seamless_lnum
    return seamless_column
endfunction

" ============================================= }}}
let s:VimIM += [" ====  input unicode    ==== {{{"]
" =================================================

" ------------ ----------------- -------------- -----------
" vim encoding datafile encoding s:localization performance
" ------------ ----------------- -------------- -----------
"   utf-8          utf-8                0          good
"   chinese        chinese              0          good
"   utf-8          chinese              1          bad
"   chinese        utf-8                2          bad
" ------------ ----------------- -------------- -----------
function! s:vimim_initialize_encoding()
    let s:localization = 0
    if &encoding == "utf-8"
        if len("datafile_fenc_chinese") > 20110129
            let s:localization = 1
        endif
    else
        let s:localization = 2
    endif
    let s:multibyte = &encoding=="utf-8" ? 3 : 2
endfunction

function! s:vimim_i18n_read(line)
    let line = a:line
    if s:localization == 1
        return iconv(line, "chinese", "utf-8")
    elseif s:localization == 2
        return iconv(line, "utf-8", &enc)
    endif
    return line
endfunction

function! s:vimim_get_char_before(keyboard)
    let keyboard = a:keyboard
    let counts = keyboard=='ii' ? len(keyboard)-1 : len(keyboard)
    let start = col(".") -1 - s:multibyte * counts
    let byte_before = getline(".")[col(".")- counts -1]
    let char_before = getline(".")[start : start+s:multibyte-1]
    if byte_before =~ '\s'
        let char_before = keyboard[0:0]
    elseif char_before =~ '\w'
        let char_before = keyboard
    endif
    return char_before
endfunction

function! s:vimim_get_unicode_list(ddddd)
    let results = []
    if a:ddddd
        for i in range(99)
            call add(results, nr2char(a:ddddd+i))
        endfor
    endif
    return results
endfunction

function! s:vimim_get_unicode_ddddd(keyboard)
    let keyboard = a:keyboard
    if keyboard =~# '^u' && keyboard !~ '[^pqwertyuio]'
        if len(keyboard) == 5 || len(keyboard) == 6
            let keyboard = s:vimim_qwertyuiop_1234567890(keyboard[1:])
            if len(keyboard) == 4              " uoooo  => u9999
                let keyboard = 'u' . keyboard  " uwwwwq => 22221
            endif
        else
            return 0
        endif
    elseif len(keyboard) == 4 && s:vimim_onekey_is_tab > 1
    \&& keyboard =~# '^\x\{4}$' && keyboard !~ '^\d\{4}$'
        let keyboard = 'u' . keyboard  " from 4 hex to unicode:  9f9f =>
    endif
    let ddddd = 0
    if keyboard =~# '^u\x\{4}$'        "  u808f => 32911
        let ddddd = str2nr(keyboard[1:],16)
    elseif keyboard =~# '^\d\{5}$'     "  32911 => 32911
        let ddddd = str2nr(keyboard, 10)
    endif
    let max = &encoding=="utf-8" ? 19968+20902 : 0xffff
    if ddddd < 8080 || ddddd > max
        let ddddd = 0
    endif
    return ddddd
endfunction

function! s:vimim_get_imode_umode(keyboard)
    let keyboard = a:keyboard
    let results = []
    if keyboard =~# '^u\+$'
        " [umode] magic u: 馬力uu => 39340
        let char_before = s:vimim_get_char_before(keyboard)
        let results = s:vimim_get_umode_chinese(char_before, keyboard)
    elseif keyboard =~# '^i' && s:imode_pinyin
        " [imode] magic i: (1) English number (2) Chinese number
        if keyboard ==# 'itoday' || keyboard ==# 'inow'
            let results = [s:vimim_imode_today_now(keyboard)]
        elseif keyboard ==# 'ii'  " 一ii => 一二
            let char_before = s:vimim_get_char_before(keyboard)
            let results = s:vimim_get_imode_chinese(char_before,1)
        elseif keyboard =~ '\d' && empty(s:english_results)
            let results = s:vimim_imode_number(keyboard)
        endif
    endif
    return results
endfunction

function! s:vimim_cjk_extra_text(chinese)
    let ddddd = char2nr(a:chinese)
    let unicode = ddddd . s:space . printf('u%04x',ddddd)
    if !empty(s:cjk_filename)
        let grep = "^" . a:chinese
        let line = match(s:cjk_lines, grep, 0)
        if line > -1
            let values  = split(get(s:cjk_lines, line))
            let dddd    = s:cjk_filename=~"cjkv" ? 1 : 2
            let digit   = s:space . get(values, dddd)
            let pinyin  = s:space . get(values, 3)
            let english = " " . join(values[4:-2])
            let unicode = unicode . digit . pinyin . english
        endif
    endif
    return unicode
endfunction

function! s:vimim_unicode_to_utf8(xxxx)
    " u808f => 32911 => e8828f
    let ddddd = str2nr(a:xxxx, 16)
    let utf8 = ''
    if ddddd < 128
        let utf8 .= nr2char(ddddd)
    elseif ddddd < 2048
        let utf8 .= nr2char(192+((ddddd-(ddddd%64))/64))
        let utf8 .= nr2char(128+(ddddd%64))
    else
        let utf8 .= nr2char(224+((ddddd-(ddddd%4096))/4096))
        let utf8 .= nr2char(128+(((ddddd%4096)-(ddddd%64))/64))
        let utf8 .= nr2char(128+(ddddd%64))
    endif
    return utf8
endfunction

" ============================================= }}}
let s:VimIM += [" ====  input hjkl       ==== {{{"]
" =================================================

function! s:vimim_cache()
    if !empty(s:pageup_pagedown)
        return s:vimim_pageup_pagedown()
    elseif empty(s:onekey)
        return []
    endif
    let results = []
    if len(s:hjkl_n) > 0
        if s:show_me_not
            let results = s:vimim_onekey_menu_format()
        elseif len(s:popupmenu_list) > 0
            let results = s:vimim_onekey_menu_filter()
        endif
        return results
    endif
    if s:show_me_not
        if s:hjkl_h
            let s:hjkl_h = 0
            for line in s:matched_list
                let oneline = join(reverse(split(line,'\zs')),'')
                call add(results, oneline)
            endfor
        elseif s:hjkl_l
            let s:hjkl_l = 0
            let results = reverse(copy(s:matched_list))
        endif
    endif
    return results
endfunction

function! s:vimim_pageup_pagedown()
    let matched_list = s:matched_list
    let length = len(matched_list)
    let one_page = &pumheight<6 ? 5 : 10
    if length > one_page
        let page = s:pageup_pagedown * one_page
        let partition = page ? page : length+page
        let B = matched_list[partition :]
        let A = matched_list[: partition-1]
        let matched_list = B + A
    endif
    return matched_list
endfunction

function! s:vimim_onekey_menu_format()
    " use 1234567890/qwertyuiop to control popup textwidth
    let lines = copy(s:matched_list)
    let filter = 'substitute(' .'v:val'. ",'^\\s\\+\\|\\s\\+$','','g')"
    call map(lines, filter)
    let lines = split(join(lines),'  ')
    let filter = 'substitute(' .'v:val'. ",' ','','g')"
    call map(lines, filter)
    if s:hjkl_n == 1
        return lines
    endif
    let n = s:hjkl_n * (7-s:multibyte)
    let textwidth = repeat(".", n)
    let results = []
    for line in lines
        let onelines = split(line, textwidth . '\zs')
        call add(onelines, '')
        call extend(results, onelines)
    endfor
    return results
endfunction

function! s:vimim_onekey_menu_filter()
    " use 1234567890/qwertyuiop as digital filter
    let results = s:vimim_cjk_filter_list()
    if empty(results) && !empty(len(s:hjkl_n))
        let number_before = strpart(s:hjkl_n,0,len(s:hjkl_n)-1)
        if len(number_before) > 0
            let s:hjkl_n = number_before
            let results = s:vimim_cjk_filter_list()
        endif
    endif
    return results
endfunction

function! s:vimim_cjk_filter_list()
    let i = 0
    let foods = []
    for items in s:popupmenu_list
        if !empty(s:vimim_cjk_digit_filter(items.word))
            call add(foods, i)
        endif
        let i += 1
    endfor
    if empty(foods)
        return []
    endif
    let results = []
    for i in foods
        let menu = s:popupmenu_list[i].word
        call add(results, menu)
    endfor
    return results
endfunction

function! s:vimim_cjk_digit_filter(chinese)
    " smart digital filter: 马力 7712 4002
    "   (1)   ma<C-6>       马   => filter with   7712
    "   (2) mali<C-6>       马力 => filter with 7 4002
    let chinese = substitute(a:chinese,'[\x00-\xff]','','g')
    if empty(len(s:hjkl_n)) || empty(chinese)
        return 0
    endif
    let digit_head = ""
    let digit_tail = ""
    for cjk in split(chinese,'\zs')
        let grep = "^" . cjk
        let line = match(s:cjk_lines, grep, 0)
        if line < 0
            continue
        else
            let values = split(get(s:cjk_lines, line))
            let dddd = s:cjk_filename=~"cjkv" ? 1 : 2
            let digit = get(values, dddd)
            let digit_head .= digit[:0]
            let digit_tail  = digit[1:]
        endif
    endfor
    let number = digit_head . digit_tail
    let pattern = "^" . s:hjkl_n
    if match(number, pattern) < 0
        return 0
    endif
    return a:chinese
endfunction

function! s:vimim_hjkl_partition(keyboard)
    let keyboard = a:keyboard
    if s:hjkl_m
        if s:hjkl_m % 2     " sssss => sssss''
            let keyboard .= "''"
        endif
    elseif s:hjkl_h      " redefine match: jsjsxx => ['jsjsx','jsjs']
        let items = get(s:popupmenu_list,0)          " jsjs'xx
        let words = get(items, "word")               " jsjsxx
        let tail = len(substitute(words,'\L','','g'))    " xx
        let head = keyboard[: -tail-1]  " 'jsjsxx'[:-3]='jsjs'
        let candidates = s:vimim_more_pinyin_candidates(head)
        let head = get(candidates, 0)                " jsj
        if empty(head)
            let head = keyboard[0:0]
        endif
        let tail = strpart(keyboard, len(head))      " sxx
        let keyboard = head . "'" . tail             " jsj'sxx
        let keyboard = s:vimim_quote_by_quote(keyboard)
    endif
    return keyboard
endfunction

function! s:vimim_last_quote(keyboard)
    " (1) [insert] open cloud if one trailing quote
    " (2) [omni]   switch to the next cloud: 'google,sogou,baidu,qq'
    if s:onekey > 2
        let clouds = split(s:vimim_cloud,',')
        let s:vimim_cloud = join(clouds[1:-1]+clouds[0:0],',')
    endif
    if empty(s:vimim_check_http_executable())
        let s:onekey = 1
    endif
    return a:keyboard[:-2]
endfunction

function! s:vimim_get_head(keyboard, partition)
    if a:partition < 0
        return a:keyboard
    endif
    let head = a:keyboard[0 : a:partition-1]
    if s:keyboard !~ ','
        let s:keyboard = head
        let tail = a:keyboard[a:partition : -1]
        if !empty(tail)
            let s:keyboard = head . "," . tail
        endif
    endif
    return head
endfunction

" ============================================= }}}
let s:VimIM += [" ====  input cjk        ==== {{{"]
" =================================================

function! s:vimim_scan_cjk_file()
    let s:cjk_lines = []
    let s:cjk_filename = 0
    let cjk = "http://vimim.googlecode.com/svn/trunk/plugin/vimim.cjk.txt"
    let datafile = s:vimim_check_filereadable(get(split(cjk,"/"),-1))
    if empty(datafile)
        let cjk = "vimim.cjkv.txt" " for 5 strokes
        let datafile = s:vimim_check_filereadable(cjk)
    endif
    if !empty(datafile)
        let s:cjk_lines = s:vimim_readfile(datafile)
        let s:cjk_filename = datafile
    endif
endfunction

function! s:vimim_onekey_cjk(keyboard)
    let keyboard = a:keyboard
    if empty(s:cjk_filename) || keyboard =~ "[']"
        return 0
    endif
    if keyboard =~# '^i' " 4corner_shortcut: iuuqwuqew => 77127132
        let keyboard = s:vimim_qwertyuiop_1234567890(keyboard[1:])
    endif
    let head = 0
    if s:show_me_not || len(keyboard) == 1
        let head = keyboard
    elseif keyboard =~ '\d'
        if keyboard =~ '^\d' && keyboard !~ '\D'
            let head = keyboard
            if len(keyboard) > 4
                " output is 6021 for input 6021272260021762
                let head = s:vimim_get_head(keyboard, 4)
            endif
        elseif keyboard =~# '^\l\+\d\+\>'
            let head = keyboard
        elseif keyboard =~# '^\l\+\d\+'
            " output is wo23 for input wo23you40yigemeng
            let partition = match(keyboard, '\d')
            while partition > -1
                let partition += 1
                if keyboard[partition : partition] =~# '\D'
                    break
                endif
            endwhile
            let head = s:vimim_get_head(keyboard, partition)
        endif
    elseif s:imode_pinyin
        if  keyboard =~# '^\l' && len(keyboard)%5 < 1
        \&& keyboard[0:0] !~ '[iuv]'
        \&& keyboard[1:4] !~ '[^pqwertyuio]'
            " muuqwxeyqpjeqqq => m7712x3610j3111
            let llll = keyboard[1:4]
            let dddd = s:vimim_qwertyuiop_1234567890(llll)
            if !empty(dddd)
                let ldddd = keyboard[0:0] . dddd
                let keyboard = ldddd . keyboard[5:-1]
                let head = s:vimim_get_head(keyboard, 5)
            endif
        endif
    endif
    return head
endfunction

function! s:vimim_qwertyuiop_1234567890(keyboard)
    " output is 7712 for input uuqw
    if a:keyboard =~ '\d'
        return 0
    endif
    let dddd = ""
    for char in split(a:keyboard, '\zs')
        let digit = match(s:qwer, char)
        if digit < 0
            return 0
        else
            let dddd .= digit
        endif
    endfor
    return dddd
endfunction

function! s:vimim_cjk_match(keyboard)
    let keyboard = a:keyboard
    if has_key(s:cjk_cache,keyboard)
        return s:cjk_cache[keyboard]
    endif
    if empty(keyboard) || empty(s:cjk_filename)
        return []
    endif
    let grep_frequency = '.*' . '\s\d\+$'
    let grep = ""
    if keyboard =~ '\d'
        if keyboard =~# '^\l\l\+[1-5]\>' && empty(len(s:hjkl_n))
            " cjk pinyin with tone: huan2hai2 yi1
            let grep = keyboard . '[a-z ]'
        else
            let digit = ""
            if keyboard =~ '^\d\+' && keyboard !~ '[^0-9]'
                " cjk free style digit input: 7 77 771 7712"
                let digit = keyboard
            elseif keyboard =~# '^\l\+\d\+'
                " cjk free style input/search: ma7 ma77 ma771 ma7712
                let digit = substitute(keyboard,'\a','','g')
            endif
            if !empty(digit)
                let stroke5 = '\d\d\d\d\s'     " five strokes => li12345
                let space = '\d\{' . string(4-len(digit)) . '}'
                let space = len(digit)==4 ? "" : space
                let dddd = '\s' . digit . space . '\s'
                let grep = s:cjk_filename=~"cjkv" ? dddd.stroke5 : dddd
                let alpha = substitute(keyboard,'\d','','g')
                if !empty(alpha)
                    " search le or yue from le4yue4
                    let grep .= '\(\l\+\d\)\=' . alpha
                elseif len(keyboard) == 1
                    " one-char-list by frequency y72/yue72 l72/le72
                    " search l or y from le4yue4 music happy 426
                    let grep .= grep_frequency
                endif
            endif
            if len(keyboard) < 4 && len(string(digit)) > 0
                let s:hjkl_n = digit
            endif
        endif
    else
        if keyboard =~# '^u\+$'
            let grep = ' u\( \|$\)'  " 214 standard unicode index
        elseif len(keyboard) == 1
            " cjk one-char-list by frequency y72/yue72 l72/le72
            let grep = '[ 0-9]' . keyboard . '\l*\d' . grep_frequency
        elseif keyboard =~# '^\l'
            " cjk multiple-char-list without frequency: huan2hai2
            " support all cases: /huan /hai /yet /huan2 /hai2
            let grep = '[ 0-9]' . keyboard . '[0-9]'
        endif
    endif
    let results = []
    if !empty(grep)
        let line = match(s:cjk_lines, grep)
        while line > -1
            let values = split(get(s:cjk_lines, line))
            let frequency = get(values, -1)
            if keyboard =~# '^u\+$'
                let frequency = ""
            elseif frequency =~ '\l'
                let frequency = 9999
            endif
            let chinese_frequency = get(values,0) . ' ' . frequency
            call add(results, chinese_frequency)
            let line = match(s:cjk_lines, grep, line+1)
        endwhile
    endif
    if len(results) > 0
        let results = sort(results, "s:vimim_sort_on_last")
        let filter = "strpart(" . 'v:val' . ", 0, s:multibyte)"
        call map(results, filter)
        if keyboard =~# '^uu\+$'    " cycle 214 unicode: u uu uuu
            let next = (len(keyboard)-1)*20
            let results = results[next :] + results[: next-1]
        endif
    endif
    return results
endfunction

function! s:vimim_sort_on_last(line1, line2)
    let line1 = get(split(a:line1),-1) + 1
    let line2 = get(split(a:line2),-1) + 1
    if line1 < line2
        return -1
    elseif line1 > line2
        return 1
    endif
    return 0
endfunction

function! s:vimim_chinese_transfer() range abort
    " (1) "quick and dirty" way to transfer Chinese to Chinese
    " (2) 20% of the effort to solve 80% of the problem using one2one
    sil!call s:vimim_backend_initialization()
    if !empty(s:cjk_filename)
        exe a:firstline.",".a:lastline.'s/./\=s:vimim_1to1(submatch(0))'
    endif
endfunction

function! s:vimim_1to1(char)
    if a:char =~ '[\x00-\xff]'
        return a:char
    endif
    let grep = '^' . a:char
    let line = match(s:cjk_lines, grep, 0)
    if line < 0
        return a:char
    endif
    let values = split(get(s:cjk_lines, line))
    let traditional_chinese = get(split(get(values,0),'\zs'),1)
    if empty(traditional_chinese)
        let traditional_chinese = a:char
    endif
    return traditional_chinese
endfunction

function! <SID>vimim_visual_ctrl6()
    let key = ""
    let onekey = "\<C-R>=g:vimim_onekey()\<CR>"
    let column = virtcol("'<'") - 2
    let space = "\<C-R>=repeat(' '," . column . ")\<CR>"
    let lines = split(getreg('"'), '\n')
    if len(lines) < 2
        let line = get(lines,0)
        let chinese = get(split(line,'\zs'),0)
        if len(substitute(line,'.','.','g')) > 1
            " highlight multiple chinese => show property of each
            let s:seamless_positions = getpos("'<'")
            let ddddd = char2nr(chinese)
            let uddddd = "gvc" . 'u'.ddddd . onekey
            let dddd = "gvc" . line . onekey
            let key = ddddd=~'\d\d\d\d\d' ? uddddd : dddd
        else
            " highlight one chinese => get antonym or number loop
            let results = s:vimim_get_imode_chinese(line,0)
            if empty(results)
                let line = -1
                sil!call s:vimim_backend_initialization()
                if !empty(s:cjk_filename)
                    let line = match(s:cjk_lines, "^".chinese)
                endif
                if line < 0
                    let key = "ga"
                else
                    echo get(s:cjk_lines, line)
                endif
            else
                let chinese = get(results,0)
                let key = "gvr" . chinese . "ga"
            endif
        endif
    elseif match(lines,'\d')>-1 && join(lines) !~ '[^0-9[:blank:].]'
        " highlighted digital block => count*average=summary
        let new_positions = getpos(".")
        let new_positions[1] = line("'>'")
        call setpos(".", new_positions)
        let sum = eval(join(lines,'+'))
        let ave = printf("%.2f", 1.0*sum/len(lines))
        let line = ave . "=" . string(sum)
        let line = substitute(line, '[.]0\+', '', 'g')
        let line = string(len(lines)) . '*' . line
        let key = "o^\<C-D>" . space . " " . line . "\<Esc>"
    else
        " highlighted block => display the block in omni window
        let key = "O^\<C-D>" . space . "'''" . onekey
    endif
    sil!call feedkeys(key)
endfunction

" ============================================= }}}
let s:VimIM += [" ====  input english    ==== {{{"]
" =================================================

function! s:vimim_scan_english_datafile()
    let s:english_lines = []
    let s:english_filename = 0
    let english = "http://vimim.googlecode.com/svn/trunk/plugin/vimim.txt"
    let datafile = s:vimim_check_filereadable(get(split(english,"/"),-1))
    if !empty(datafile)
        let s:english_lines = s:vimim_readfile(datafile)
        let s:english_filename = datafile
    endif
endfunction

function! s:vimim_check_filereadable(default)
    let datafile = s:plugin . a:default
    if filereadable(datafile)
        return datafile
    endif
    return 0
endfunction

function! s:vimim_english(keyboard)
    if empty(s:english_filename)
        return 0
    endif
    " [sql] select english from vimim.txt
    let grep = '^' . a:keyboard . '\s\+'
    let matched = match(s:english_lines, grep)
    if matched < 0 && len(a:keyboard) > 3
        " support english shortcut: both haag and haagendazs
        let grep = '^' . a:keyboard
        let matched = match(s:english_lines, grep)
    endif
    let oneline = ""
    if matched > -1
        let oneline = get(s:english_lines, matched)
        if a:keyboard != get(split(oneline),0)
            let oneline = a:keyboard . " " . oneline
        endif
    endif
    return oneline
endfunction

function! s:vimim_readfile(datafile)
    if !filereadable(a:datafile)
        return []
    endif
    let lines = readfile(a:datafile)
    if s:localization > 0
        let  results = []
        for line in lines
            let line = s:vimim_i18n_read(line)
            call add(results, line)
        endfor
        return results
    endif
    return lines
endfunction

" ============================================= }}}
let s:VimIM += [" ====  input pinyin     ==== {{{"]
" =================================================

function! s:vimim_get_pinyin_from_pinyin(keyboard)
    let keyboard = s:vimim_quanpin_transform(a:keyboard)
    let results = split(keyboard, "'")
    if len(results) > 1
        return results
    endif
    return []
endfunction

function! s:vimim_quanpin_transform(pinyin)
    if empty(s:quanpin_table)
        let s:quanpin_table = s:vimim_create_quanpin_table()
    endif
    let item = a:pinyin
    let pinyinstr = ""
    let index = 0
    let lenitem = len(item)
    while index < lenitem
        if item[index] !~ "[a-z]"
            let index += 1
            continue
        endif
        for i in range(6,1,-1)
            let tmp = item[index : ]
            if len(tmp) < i
                continue
            endif
            let end = index+i
            let matchstr = item[index : end-1]
            if has_key(s:quanpin_table, matchstr)
                let tempstr = item[end-1 : end]
                " special case for fanguo, which should be fan'guo
                if tempstr == "gu" || tempstr == "nu" || tempstr == "ni"
                    if has_key(s:quanpin_table, matchstr[:-2])
                        let i -= 1
                        let matchstr = matchstr[:-2]
                    endif
                endif
                " follow ibus' rule
                let tempstr2 = item[end-2 : end+1]
                let tempstr3 = item[end-1 : end+1]
                let tempstr4 = item[end-1 : end+2]
                if (tempstr == "ge" && tempstr3 != "ger")
                    \ || (tempstr == "ne" && tempstr3 != "ner")
                    \ || (tempstr4 == "gong" || tempstr3 == "gou")
                    \ || (tempstr4 == "nong" || tempstr3 == "nou")
                    \ || (tempstr == "ga" || tempstr == "na")
                    \ || tempstr2 == "ier"
                    if has_key(s:quanpin_table, matchstr[:-2])
                        let i -= 1
                        let matchstr = matchstr[:-2]
                    endif
                endif
                let pinyinstr .= "'" . s:quanpin_table[matchstr]
                let index += i
                break
            elseif i == 1
                let pinyinstr .= "'" . item[index]
                let index += 1
                break
            else
                continue
            endif
        endfor
    endwhile
    if pinyinstr[0] == "'"
        return pinyinstr[1:]
    else
        return pinyinstr
    endif
endfunction

function! s:vimim_create_quanpin_table()
    let pinyin_list = s:vimim_get_pinyin_table()
    let table = {}
    for key in pinyin_list
        if key[0] == "'"
            let table[key[1:]] = key[1:]
        else
            let table[key] = key
        endif
    endfor
    let sheng_mu = "b p m f d t l n g k h j q x zh ch sh r z c s y w"
    for shengmu in split(sheng_mu)
        let table[shengmu] = shengmu
    endfor
    return table
endfunction

function! s:vimim_more_pinyin_candidates(keyboard)
    " [purpose] if not english, make standard layout for popup menu
    " input  =>  mamahuhu
    " output =>  mamahu, mama
    if !empty(s:english_results) || s:search > 0
        return []
    endif
    let keyboards = s:vimim_get_pinyin_from_pinyin(a:keyboard)
    if empty(a:keyboard) || empty(keyboards)
        return []
    endif
    let candidates = []
    for i in reverse(range(len(keyboards)-1))
        let candidate = join(keyboards[0 : i], "")
        if !empty(candidate)
            call add(candidates, candidate)
        endif
    endfor
    if len(candidates) > 2
        let candidates = candidates[0 : len(candidates)-2]
    endif
    return candidates
endfunction

function! s:vimim_more_pinyin_datafile(keyboard, sentence)
    if s:ui.im !~ 'pinyin'
        return []   " for pinyin with valid keycodes only
    endif
    let candidates = s:vimim_more_pinyin_candidates(a:keyboard)
    if empty(candidates)
        return []
    endif
    let results = []
    let lines = s:backend[s:ui.root][s:ui.im].lines
    for candidate in candidates
        let pattern = '^' . candidate . '\>'
        let matched = match(lines, pattern, 0)
        if matched < 0
            continue
        elseif a:sentence > 0
            return [candidate]
        endif
        let oneline = get(lines, matched)
        let matched_list = s:vimim_make_pair_list(oneline)
        call extend(results, matched_list)
    endfor
    return results
endfunction

" ============================================= }}}
let s:VimIM += [" ====  input shuangpin  ==== {{{"]
" =================================================

function! s:vimim_set_shuangpin()
    if empty(s:vimim_shuangpin)
    \|| !empty(s:shuangpin_table)
    \|| s:vimim_cloud =~ 'shuangpin'
        return
    endif
    let s:imode_pinyin = 0
    let rules = s:vimim_shuangpin_generic()
    let chinese = ""
    let shuangpin = s:vimim_chinese('shuangpin')
    let keycode = "[0-9a-z']"
    if s:vimim_shuangpin == 'abc'
        let rules = s:vimim_shuangpin_abc(rules)
        let s:imode_pinyin = 1
        let chinese = s:vimim_chinese('abc')
        let shuangpin = ""
    elseif s:vimim_shuangpin == 'ms'
        let rules = s:vimim_shuangpin_ms(rules)
        let chinese = s:vimim_chinese('ms')
        let keycode = "[0-9a-z';]"
    elseif s:vimim_shuangpin == 'nature'
        let rules = s:vimim_shuangpin_nature(rules)
        let chinese = s:vimim_chinese('nature')
    elseif s:vimim_shuangpin == 'plusplus'
        let rules = s:vimim_shuangpin_plusplus(rules)
        let chinese = s:vimim_chinese('plusplus')
    elseif s:vimim_shuangpin == 'purple'
        let rules = s:vimim_shuangpin_purple(rules)
        let chinese = s:vimim_chinese('purple')
        let keycode = "[0-9a-z';]"
    elseif s:vimim_shuangpin == 'flypy'
        let rules = s:vimim_shuangpin_flypy(rules)
        let chinese = s:vimim_chinese('flypy')
    endif
    let s:shuangpin_table = s:vimim_create_shuangpin_table(rules)
    let s:shuangpin_keycode_chinese.chinese = chinese . shuangpin
    let s:shuangpin_keycode_chinese.keycode = keycode
endfunction

function! s:vimim_shuangpin_transform(keyboard)
    let keyboard = a:keyboard
    let size = strlen(keyboard)
    let ptr = 0
    let output = ""
    let bchar = ""    " work-around for sogou
    while ptr < size
        if keyboard[ptr] !~ "[a-z;]"
            " bypass all non-characters, i.e. 0-9 and A-Z are bypassed
            let output .= keyboard[ptr]
            let ptr += 1
        else
            if keyboard[ptr+1] =~ "[a-z;]"
                let sp1 = keyboard[ptr].keyboard[ptr+1]
            else
                let sp1 = keyboard[ptr]
            endif
            if has_key(s:shuangpin_table, sp1)
                " the last odd shuangpin code are output as only shengmu
                let output .= bchar . s:shuangpin_table[sp1]
            else
                " invalid shuangpin code are preserved
                let output .= sp1
            endif
            let ptr += strlen(sp1)
        endif
    endwhile
    if output[0] == "'"
        return output[1:]
    else
        return output
    endif
endfunction

"-----------------------------------
function! s:vimim_get_pinyin_table()
"-----------------------------------
" List of all valid pinyin.  Note: Don't change this function!
return [
\"'a", "'ai", "'an", "'ang", "'ao", 'ba', 'bai', 'ban', 'bang', 'bao',
\'bei', 'ben', 'beng', 'bi', 'bian', 'biao', 'bie', 'bin', 'bing', 'bo',
\'bu', 'ca', 'cai', 'can', 'cang', 'cao', 'ce', 'cen', 'ceng', 'cha',
\'chai', 'chan', 'chang', 'chao', 'che', 'chen', 'cheng', 'chi', 'chong',
\'chou', 'chu', 'chua', 'chuai', 'chuan', 'chuang', 'chui', 'chun', 'chuo',
\'ci', 'cong', 'cou', 'cu', 'cuan', 'cui', 'cun', 'cuo', 'da', 'dai',
\'dan', 'dang', 'dao', 'de', 'dei', 'deng', 'di', 'dia', 'dian', 'diao',
\'die', 'ding', 'diu', 'dong', 'dou', 'du', 'duan', 'dui', 'dun', 'duo',
\"'e", "'ei", "'en", "'er", 'fa', 'fan', 'fang', 'fe', 'fei', 'fen',
\'feng', 'fiao', 'fo', 'fou', 'fu', 'ga', 'gai', 'gan', 'gang', 'gao',
\'ge', 'gei', 'gen', 'geng', 'gong', 'gou', 'gu', 'gua', 'guai', 'guan',
\'guang', 'gui', 'gun', 'guo', 'ha', 'hai', 'han', 'hang', 'hao', 'he',
\'hei', 'hen', 'heng', 'hong', 'hou', 'hu', 'hua', 'huai', 'huan', 'huang',
\'hui', 'hun', 'huo', "'i", 'ji', 'jia', 'jian', 'jiang', 'jiao', 'jie',
\'jin', 'jing', 'jiong', 'jiu', 'ju', 'juan', 'jue', 'jun', 'ka', 'kai',
\'kan', 'kang', 'kao', 'ke', 'ken', 'keng', 'kong', 'kou', 'ku', 'kua',
\'kuai', 'kuan', 'kuang', 'kui', 'kun', 'kuo', 'la', 'lai', 'lan', 'lang',
\'lao', 'le', 'lei', 'leng', 'li', 'lia', 'lian', 'liang', 'liao', 'lie',
\'lin', 'ling', 'liu', 'long', 'lou', 'lu', 'luan', 'lue', 'lun', 'luo',
\'lv', 'ma', 'mai', 'man', 'mang', 'mao', 'me', 'mei', 'men', 'meng', 'mi',
\'mian', 'miao', 'mie', 'min', 'ming', 'miu', 'mo', 'mou', 'mu', 'na',
\'nai', 'nan', 'nang', 'nao', 'ne', 'nei', 'nen', 'neng', "'ng", 'ni',
\'nian', 'niang', 'niao', 'nie', 'nin', 'ning', 'niu', 'nong', 'nou', 'nu',
\'nuan', 'nue', 'nuo', 'nv', "'o", "'ou", 'pa', 'pai', 'pan', 'pang',
\'pao', 'pei', 'pen', 'peng', 'pi', 'pian', 'piao', 'pie', 'pin', 'ping',
\'po', 'pou', 'pu', 'qi', 'qia', 'qian', 'qiang', 'qiao', 'qie', 'qin',
\'qing', 'qiong', 'qiu', 'qu', 'quan', 'que', 'qun', 'ran', 'rang', 'rao',
\'re', 'ren', 'reng', 'ri', 'rong', 'rou', 'ru', 'ruan', 'rui', 'run',
\'ruo', 'sa', 'sai', 'san', 'sang', 'sao', 'se', 'sen', 'seng', 'sha',
\'shai', 'shan', 'shang', 'shao', 'she', 'shei', 'shen', 'sheng', 'shi',
\'shou', 'shu', 'shua', 'shuai', 'shuan', 'shuang', 'shui', 'shun', 'shuo',
\'si', 'song', 'sou', 'su', 'suan', 'sui', 'sun', 'suo', 'ta', 'tai',
\'tan', 'tang', 'tao', 'te', 'teng', 'ti', 'tian', 'tiao', 'tie', 'ting',
\'tong', 'tou', 'tu', 'tuan', 'tui', 'tun', 'tuo', "'u", "'v", 'wa', 'wai',
\'wan', 'wang', 'wei', 'wen', 'weng', 'wo', 'wu', 'xi', 'xia', 'xian',
\'xiang', 'xiao', 'xie', 'xin', 'xing', 'xiong', 'xiu', 'xu', 'xuan',
\'xue', 'xun', 'ya', 'yan', 'yang', 'yao', 'ye', 'yi', 'yin', 'ying', 'yo',
\'yong', 'you', 'yu', 'yuan', 'yue', 'yun', 'za', 'zai', 'zan', 'zang',
\'zao', 'ze', 'zei', 'zen', 'zeng', 'zha', 'zhai', 'zhan', 'zhang', 'zhao',
\'zhe', 'zhen', 'zheng', 'zhi', 'zhong', 'zhou', 'zhu', 'zhua', 'zhuai',
\'zhuan', 'zhuang', 'zhui', 'zhun', 'zhuo', 'zi', 'zong', 'zou', 'zu',
\'zuan', 'zui', 'zun', 'zuo']
endfunction

function! s:vimim_create_shuangpin_table(rule)
    let pinyin_list = s:vimim_get_pinyin_table()
    let rules = a:rule
    let sptable = {}
    " generate table for shengmu-yunmu pairs match
    for key in pinyin_list
        if key !~ "['a-z]*"
            continue
        endif
        if key[1] == "h"
            let shengmu = key[:1]
            let yunmu = key[2:]
        else
            let shengmu = key[0]
            let yunmu = key[1:]
        endif
        if has_key(rules[0], shengmu)
            let shuangpin_shengmu = rules[0][shengmu]
        else
            continue
        endif
        if has_key(rules[1], yunmu)
            let shuangpin_yunmu = rules[1][yunmu]
        else
            continue
        endif
        let sp1 = shuangpin_shengmu.shuangpin_yunmu
        if !has_key(sptable, sp1)
            if key[0] == "'"
                let key = key[1:]
            end
            let sptable[sp1] = key
        endif
    endfor
    " the jxqy+v special case handling
    if s:vimim_shuangpin == 'abc'
    \|| s:vimim_shuangpin == 'purple'
    \|| s:vimim_shuangpin == 'nature'
    \|| s:vimim_shuangpin == 'flypy'
        let jxqy = {"jv" : "ju", "qv" : "qu", "xv" : "xu", "yv" : "yu"}
        call extend(sptable, jxqy)
    elseif s:vimim_shuangpin == 'ms'
        let jxqy = {"jv" : "jue", "qv" : "que", "xv" : "xue", "yv" : "yue"}
        call extend(sptable, jxqy)
    endif
    " the flypy shuangpin special case handling
    if s:vimim_shuangpin == 'flypy'
        let flypy = {"aa" : "a", "oo" : "o", "ee" : "e",
                    \"an" : "an", "ao" : "ao", "ai" : "ai", "ah": "ang",
                    \"os" : "ong","ou" : "ou",
                    \"en" : "en", "er" : "er", "ei" : "ei", "eg": "eng" }
        call extend(sptable, flypy)
    endif
    " the nature shuangpin special case handling
    if s:vimim_shuangpin == 'nature'
        let nature = {"aa" : "a", "oo" : "o", "ee" : "e" }
        call extend(sptable, nature)
    endif
    " generate table for shengmu-only match
    for [key, value] in items(rules[0])
        if key[0] == "'"
            let sptable[value] = ""
        else
            let sptable[value] = key
        end
    endfor
    return sptable
endfunction

function! s:vimim_shuangpin_generic()
    " generate the default value of shuangpin table
    let shengmu_list = {}
    for shengmu in ["b", "p", "m", "f", "d", "t", "l", "n", "g",
                \"k", "h", "j", "q", "x", "r", "z", "c", "s", "y", "w"]
        let shengmu_list[shengmu] = shengmu
    endfor
    let shengmu_list["'"] = "o"
    let yunmu_list = {}
    for yunmu in ["a", "o", "e", "i", "u", "v"]
        let yunmu_list[yunmu] = yunmu
    endfor
    let s:shuangpin_rule = [shengmu_list, yunmu_list]
    return s:shuangpin_rule
endfunction

function! s:vimim_shuangpin_abc(rule)
    " goal: vtpc => shuang pin => double pinyin
    call extend(a:rule[0],{ "zh" : "a", "ch" : "e", "sh" : "v" })
    call extend(a:rule[1],{
        \"an" : "j", "ao" : "k", "ai" : "l", "ang": "h",
        \"ong": "s", "ou" : "b",
        \"en" : "f", "er" : "r", "ei" : "q", "eng": "g", "ng" : "g",
        \"ia" : "d", "iu" : "r", "ie" : "x", "in" : "c", "ing": "y",
        \"iao": "z", "ian": "w", "iang": "t", "iong" : "s",
        \"un" : "n", "ua" : "d", "uo" : "o", "ue" : "m", "ui" : "m",
        \"uai": "c", "uan": "p", "uang": "t" } )
    return a:rule
endfunction

function! s:vimim_shuangpin_ms(rule)
    " goal: vi=>zhi ii=>chi ui=>shi keng=>keneng
    call extend(a:rule[0],{ "zh" : "v", "ch" : "i", "sh" : "u" })
    call extend(a:rule[1],{
        \"an" : "j", "ao" : "k", "ai" : "l", "ang": "h",
        \"ong": "s", "ou" : "b",
        \"en" : "f", "er" : "r", "ei" : "z", "eng": "g", "ng" : "g",
        \"ia" : "w", "iu" : "q", "ie" : "x", "in" : "n", "ing": ";",
        \"iao": "c", "ian": "m", "iang" : "d", "iong" : "s",
        \"un" : "p", "ua" : "w", "uo" : "o", "ue" : "t", "ui" : "v",
        \"uai": "y", "uan": "r", "uang" : "d" ,
        \"v" : "y"} )
    return a:rule
endfunction

function! s:vimim_shuangpin_nature(rule)
    " goal: 'woui' => wo shi => i am
    call extend(a:rule[0],{ "zh" : "v", "ch" : "i", "sh" : "u" })
    call extend(a:rule[1],{
        \"an" : "j", "ao" : "k", "ai" : "l", "ang": "h",
        \"ong": "s", "ou" : "b",
        \"en" : "f", "er" : "r", "ei" : "z", "eng": "g", "ng" : "g",
        \"ia" : "w", "iu" : "q", "ie" : "x", "in" : "n", "ing": "y",
        \"iao": "c", "ian": "m", "iang" : "d", "iong" : "s",
        \"un" : "p", "ua" : "w", "uo" : "o", "ue" : "t", "ui" : "v",
        \"uai": "y", "uan": "r", "uang" : "d" } )
    return a:rule
endfunction

function! s:vimim_shuangpin_plusplus(rule)
    call extend(a:rule[0],{ "zh" : "v", "ch" : "u", "sh" : "i" })
    call extend(a:rule[1],{
        \"an" : "f", "ao" : "d", "ai" : "s", "ang": "g",
        \"ong": "y", "ou" : "p",
        \"en" : "r", "er" : "q", "ei" : "w", "eng": "t", "ng" : "t",
        \"ia" : "b", "iu" : "n", "ie" : "m", "in" : "l", "ing": "q",
        \"iao": "k", "ian": "j", "iang" : "h", "iong" : "y",
        \"un" : "z", "ua" : "b", "uo" : "o", "ue" : "x", "ui" : "v",
        \"uai": "x", "uan": "c", "uang" : "h" } )
    return a:rule
endfunction

function! s:vimim_shuangpin_purple(rule)
    call extend(a:rule[0],{ "zh" : "u", "ch" : "a", "sh" : "i" })
    call extend(a:rule[1],{
        \"an" : "r", "ao" : "q", "ai" : "p", "ang": "s",
        \"ong": "h", "ou" : "z",
        \"en" : "w", "er" : "j", "ei" : "k", "eng": "t", "ng" : "t",
        \"ia" : "x", "iu" : "j", "ie" : "d", "in" : "y", "ing": ";",
        \"iao": "b", "ian": "f", "iang" : "g", "iong" : "h",
        \"un" : "m", "ua" : "x", "uo" : "o", "ue" : "n", "ui" : "n",
        \"uai": "y", "uan": "l", "uang" : "g"} )
    return a:rule
endfunction

function! s:vimim_shuangpin_flypy(rule)
    call extend(a:rule[0],{ "zh" : "v", "ch" : "i", "sh" : "u" })
    call extend(a:rule[1],{
        \"an" : "j", "ao" : "c", "ai" : "d", "ang": "h",
        \"ong": "s", "ou" : "z",
        \"en" : "f", "er" : "r", "ei" : "w", "eng": "g", "ng" : "g",
        \"ia" : "x", "iu" : "q", "ie" : "p", "in" : "b", "ing": "k",
        \"iao": "n", "ian": "m", "iang" : "l", "iong" : "s",
        \"un" : "y", "ua" : "x", "uo" : "o", "ue" : "t", "ui" : "v",
        \"uai": "k", "uan": "r", "uang" : "l" } )
    return a:rule
endfunction

" ============================================= }}}
let s:VimIM += [" ====  backend file     ==== {{{"]
" =================================================

function! s:vimim_scan_backend_embedded()
    let im = "pinyin"
    " (1/3) scan directory database
    let dir = s:plugin . im
    if isdirectory(dir)
        let dir .= "/"
        if filereadable(dir . im)
            return s:vimim_set_directory(im, dir)
        endif
    endif
    " (2/3) scan bsddb database as edw: enterprise data warehouse
    if has("python")  " bsddb is from Python 2 only
        let bsddb = "vimim.gbk.bsddb"   " wc=46,694,400
        let datafile = s:vimim_check_filereadable(bsddb)
        if !empty(datafile)
            call s:vimim_initialize_bsddb(datafile)
            return s:vimim_set_datafile(im, datafile)
        endif
    endif
    " (3/3) scan all supported data files
    for im in s:all_vimim_input_methods
        let datafile = s:plugin . "vimim." . im . ".txt"
        if !filereadable(datafile)
            let im2 = im . "." . &encoding
            let datafile = s:plugin . "vimim." . im2 . ".txt"
        endif
        if filereadable(datafile)
            call s:vimim_set_datafile(im, datafile)
        endif
    endfor
endfunction

function! s:vimim_set_datafile(im, datafile)
    let datafile = a:datafile
    let im = s:vimim_get_valid_im_name(a:im)
    if empty(im) || isdirectory(datafile)
        return
    endif
    let s:ui.root = "datafile"
    let s:ui.im = im
    let frontends = [s:ui.root, s:ui.im]
    call insert(s:ui.frontends, frontends)
    let s:backend.datafile[im] = s:vimim_one_backend_hash()
    let s:backend.datafile[im].root = "datafile"
    let s:backend.datafile[im].im = im
    let s:backend.datafile[im].name = datafile
    let s:backend.datafile[im].keycode = s:im_keycode[im]
    let s:backend.datafile[im].chinese = s:vimim_chinese(im)
    if datafile =~ ".txt" && empty(s:backend.datafile[im].lines)
        let s:backend.datafile[im].lines = s:vimim_readfile(datafile)
    endif
endfunction

function! s:vimim_sentence_datafile(keyboard)
    let keyboard = a:keyboard
    let lines = s:backend[s:ui.root][s:ui.im].lines
    if empty(lines) || !empty(s:english_results)
        return ""
    endif
    let pattern = '^' . keyboard . '\s'
    let matched = match(lines, pattern)
    if matched > -1
        return keyboard
    endif
    let candidates = s:vimim_more_pinyin_datafile(keyboard,1)
    if !empty(candidates)
        return get(candidates,0)
    endif
    let max = len(keyboard)
    while max > 1
        let max -= 1
        let head = strpart(keyboard, 0, max)
        let pattern = '^' . head . '\s'
        let matched = match(lines, pattern)
        if matched < 0
            continue
        else
            break
        endif
    endwhile
    if matched < 0
        return ""
    endif
    return keyboard[0 : max-1]
endfunction

function! s:vimim_get_from_datafile(keyboard)
    let lines = s:backend[s:ui.root][s:ui.im].lines
    let pattern = '^' . a:keyboard . '\s'
    let matched = match(lines, pattern)
    if matched < 0
        return []
    endif
    let oneline = get(lines, matched)
    let results = split(oneline)[1:]
    if s:search || len(results) > 10
        return results
    endif
    let more = len('http://code.google.com/p/vimim/issues/detail?id=121')/10
    if s:ui.im =~ 'pinyin'
        let extras = s:vimim_more_pinyin_datafile(a:keyboard,0)
        if len(extras) > 0
            let results = s:vimim_make_pair_list(oneline)
            call extend(results, extras)
        endif
    elseif len(results) < more
        let results = []
        let s:show_extra_menu = 1
        for i in range(more)
            let matched += i
            let oneline = get(lines, matched)
            let extras = s:vimim_make_pair_list(oneline)
            call extend(results, extras)
        endfor
    endif
    return results
endfunction

function! s:vimim_get_from_database(keyboard)
    if empty(a:keyboard)
        return []
    endif
    let oneline = s:vimim_get_gold_from_bsddb(a:keyboard)
    if empty(oneline) " || get(split(oneline),1) =~ '\w'
        return []
    endif
    let results = s:vimim_make_pair_list(oneline)
    if s:search < 1 && len(results) > 0 && len(results) < 20
        let candidates = s:vimim_more_pinyin_candidates(a:keyboard)
        if len(candidates) > 1
            for candidate in candidates
                let oneline = s:vimim_get_gold_from_bsddb(candidate)
                if empty(oneline) || match(oneline,' ') < 0
                    continue
                endif
                let matched_list = s:vimim_make_pair_list(oneline)
                if !empty(matched_list)
                    call extend(results, matched_list)
                endif
                if len(results) > 20*2
                    break
                endif
            endfor
        endif
    endif
    return results
endfunction

function! s:vimim_make_pair_list(oneline)
    if empty(a:oneline) || match(a:oneline,' ') < 0
        return []
    endif
    let oneline_list = split(a:oneline)
    let menu = remove(oneline_list, 0)
    let results = []
    for chinese in oneline_list
        call add(results, menu .' '. chinese)
    endfor
    return results
endfunction

" ============================================= }}}
let s:VimIM += [" ====  backend dir      ==== {{{"]
" =================================================

function! s:vimim_set_directory(im, dir)
    let im = s:vimim_get_valid_im_name(a:im)
    if empty(im) || empty(a:dir) || !isdirectory(a:dir)
        return
    endif
    let s:ui.root = "directory"
    let s:ui.im = im
    let frontends = [s:ui.root, s:ui.im]
    call insert(s:ui.frontends, frontends)
    if empty(s:backend.directory)
        let s:backend.directory[im] = s:vimim_one_backend_hash()
        let s:backend.directory[im].root = "directory"
        let s:backend.directory[im].name = a:dir
        let s:backend.directory[im].im = im
        let s:backend.directory[im].keycode = s:im_keycode[im]
        let s:backend.directory[im].chinese = s:vimim_chinese(im)
    endif
endfunction

function! s:vimim_more_pinyin_directory(keyboard, dir)
    if s:search > 0
        return []
    endif
    let candidates = s:vimim_more_pinyin_candidates(a:keyboard)
    if empty(candidates)
        return []
    endif
    let results = []
    for candidate in candidates
        let matches = []
        let filename = a:dir . candidate
        if filereadable(filename)
            let matches = s:vimim_readfile(filename)
        endif
        if !empty(matches)
            call map(matches, 'candidate ." ". v:val')
            call extend(results, matches)
        endif
    endfor
    return results
endfunction

function! s:vimim_sentence_directory(keyboard)
    let directory = s:backend.directory[s:ui.im].name
    if empty(directory)
        return ""
    endif
    let filename = directory . a:keyboard
    if filereadable(filename)
        return a:keyboard
    elseif !empty(s:english_results)
        return ""
    endif
    let candidates = s:vimim_more_pinyin_datafile(a:keyboard,1)
    if !empty(candidates)
        return get(candidates,0)
    endif
    let max = len(a:keyboard)
    while max > 1
        let max -= 1
        let head = strpart(a:keyboard, 0, max)
        let filename = directory . head
        " workaround: filereadable("/filename.") returns true
        if filereadable(filename)
            if head[-1:-1] != "."
                break
            endif
        else
            continue
        endif
    endwhile
    if filereadable(filename)
        return a:keyboard[0 : max-1]
    endif
    return ""
endfunction

" ============================================= }}}
let s:VimIM += [" ====  backend cloud    ==== {{{"]
" =================================================

function! s:vimim_initialize_cloud()
    let cloud_default = 'baidu,sogou,qq,google'
    let cloud_defaults = split(cloud_default,',')
    let s:cloud_default = get(cloud_defaults,0)
    let s:cloud_defaults = copy(cloud_defaults)
    let s:cloud_keys = {}
    let s:cloud_cache = {}
    for cloud in cloud_defaults
        let s:cloud_keys[cloud] = 0
        let s:cloud_cache[cloud] = {}
    endfor
    if empty(s:vimim_cloud)
        let s:vimim_cloud = cloud_default
    else
        let clouds = split(s:vimim_cloud,',')
        for cloud in clouds
            let cloud = get(split(cloud,'[.]'),0)
            call remove(cloud_defaults, match(cloud_defaults,cloud))
        endfor
        let clouds += cloud_defaults
        let s:vimim_cloud = join(clouds,',')
        let default = get(split(get(clouds,0),'[.]'),0)
        if match(cloud_default, default) > -1
            let s:cloud_default = default
        endif
    endif
    let s:mycloud = 0
    let s:http_executable = 0
endfunction

function! s:vimim_set_cloud(im)
    let im = a:im
    let cloud = s:vimim_set_cloud_if_http_executable(im)
    if empty(cloud)
        let s:backend.cloud = {}
        return
    endif
    let s:mycloud = 0
    let s:ui.im = im
    let s:ui.root = 'cloud'
    let frontends = [s:ui.root, s:ui.im]
    call add(s:ui.frontends, frontends)
    let clouds = split(s:vimim_cloud,',')
    for cloud in clouds
        let cloud = get(split(cloud,'[.]'),0)
        if cloud == im
            continue
        endif
        call s:vimim_set_cloud_if_http_executable(cloud)
        let frontends = [s:ui.root, cloud]
        call add(s:ui.frontends, frontends)
    endfor
endfunction

function! s:vimim_scan_backend_cloud()
    if empty(s:backend.datafile) && empty(s:backend.directory)
        call s:vimim_set_cloud(s:cloud_default)
    endif
endfunction

function! s:vimim_set_cloud_if_http_executable(im)
    if empty(s:http_executable)
        if empty(s:vimim_check_http_executable())
            return 0
        endif
    endif
    let im = a:im
    if empty(im)
        let im = s:cloud_default
    endif
    let s:backend.cloud[im] = s:vimim_one_backend_hash()
    let s:backend.cloud[im].root = 'cloud'
    let s:backend.cloud[im].im = im
    let s:backend.cloud[im].keycode = s:im_keycode[im]
    let s:backend.cloud[im].chinese = s:vimim_chinese(im)
    let s:backend.cloud[im].name = s:vimim_chinese(im)
    return 1
endfunction

function! s:vimim_check_http_executable()
    let http_executable = 0
    if s:vimim_cloud < 0 && len(s:vimim_mycloud) < 2
        return 0
    elseif len(s:http_executable) > 2
        return s:http_executable
    endif
    " step 1 of 4: try to find libvimim for mycloud
    let libvimim = s:vimim_get_libvimim()
    if !empty(libvimim) && filereadable(libvimim)
        " in win32, strip the .dll suffix
        if has("win32") && libvimim[-4:] ==? ".dll"
            let libvimim = libvimim[:-5]
        endif
        let ret = libcall(libvimim, "do_geturl", "__isvalid")
        if ret ==# "True"
            let http_executable = libvimim
        endif
    endif
    " step 2 of 4: try to use dynamic python:
    if empty(http_executable)
        if has('python')  " +python/dyn
            let http_executable = 'Python2 Interface to Vim'
        endif
        if has('python3') && &relativenumber " +python3/dyn
            let http_executable = 'Python3 Interface to Vim'
        endif
    endif
    " step 3 of 4: try to find wget
    if empty(http_executable)
        let wget = 'wget'
        let wget_exe = s:plugin . 'wget.exe'
        if filereadable(wget_exe)
            let wget = wget_exe
        endif
        if executable(wget)
            let wget_option = " -qO - --timeout 20 -t 10 "
            let http_executable = wget . wget_option
        endif
    endif
    " step 4 of 4: try to find curl if wget not available
    if empty(http_executable) && executable('curl')
        let http_executable = "curl -s "
    endif
    let s:http_executable = copy(http_executable)
    return http_executable
endfunction

function! s:vimim_get_cloud(keyboard, cloud)
    let keyboard = a:keyboard
    let cloud = a:cloud
    if keyboard!~s:valid_key || empty(cloud) || match(s:vimim_cloud,cloud)<0
        return []
    endif
    let results = []
    if has_key(s:cloud_cache[cloud], keyboard)
        return s:cloud_cache[cloud][keyboard]
    endif
    let get_cloud = "s:vimim_get_cloud_" . cloud . "(keyboard)"
    try
        let results = eval(get_cloud)
    catch
        call s:debug('alert', 'get_cloud='.cloud.'=', v:exception)
    endtry
    if !empty(results) && empty(s:english_results)
        let s:cloud_cache[cloud][keyboard] = results
        if s:keyboard !~ ','
            let s:keyboard = keyboard
        endif
    endif
    return results
endfunction

function! s:vimim_get_from_http(input, cloud)
    let input = a:input
    if empty(input)
        return ""
    endif
    if empty(s:http_executable)
        if empty(s:vimim_check_http_executable())
            return ""
        endif
    endif
    let output = ""
    try
        if s:http_executable =~ 'Python3'
            let output = s:vimim_get_from_python3(input, a:cloud)
        elseif s:http_executable =~ 'Python2'
            let output = s:vimim_get_from_python2(input, a:cloud)
        elseif s:http_executable =~ 'libvimim'
            let output = libcall(s:http_executable, "do_geturl", input)
        else
            let output = system(s:http_executable . '"'.input.'"')
        endif
    catch
        call s:debug('alert', "http_cloud", output ." ". v:exception)
    endtry
    return output
endfunction

function! s:vimim_get_cloud_sogou(keyboard)
    " http://web.pinyin.sogou.com/api/py?key=32&query=mxj
    if empty(s:cloud_keys.sogou)
        let key_sogou = "http://web.pinyin.sogou.com/web_ime/patch.php"
        let output = s:vimim_get_from_http(key_sogou, 'sogou')
        if empty(output) || output =~ '502 bad gateway'
            return []
        endif
        let s:cloud_keys.sogou = get(split(output,'"'),1)
    endif
    let input  = 'http://web.pinyin.sogou.com/api/py'
    let input .= '?key=' . s:cloud_keys.sogou
    let input .= '&query=' . a:keyboard
    let output = s:vimim_get_from_http(input, 'sogou')
    if empty(output) || output =~ '502 bad gateway'
        return []
    endif
    let first  = match(output, '"', 0)
    let second = match(output, '"', 0, 2)
    if first > 0 && second > 0
        let output = strpart(output, first+1, second-first-1)
        let output = s:vimim_url_xx_to_chinese(output)
    endif
    if s:localization > 0
        " support gb and big5 in addition to utf8
        let output = s:vimim_i18n_read(output)
    endif
    let matched_list = []
    for item in split(output, '\t+')
        let item_list = split(item, s:colon)
        if len(item_list) > 1
            let chinese = get(item_list,0)
            let english = strpart(a:keyboard, 0, get(item_list,1))
            let new_item = english . " " . chinese
            call add(matched_list, new_item)
        endif
    endfor
    return matched_list
endfunction

function! s:vimim_get_cloud_qq(keyboard)
    " http://ime.qq.com/fcgi-bin/getword?key=32&q=mxj
    let url = 'http://ime.qq.com/fcgi-bin/'
    if empty(s:cloud_keys.qq)
        let key_qq = url . 'getkey'
        let output = s:vimim_get_from_http(key_qq, 'qq')
        if empty(output) || output =~ '502 bad gateway'
            return []
        endif
        let s:cloud_keys.qq = get(split(output,'"'),3)
    endif
    if len(s:cloud_keys.qq) != 32
        return []
    endif
    let input  = url
    let clouds = split(s:vimim_cloud,',')
    let vimim_cloud = get(clouds, match(clouds,'qq'))
    if vimim_cloud =~ 'wubi'
        let input .= 'gwb'
    else
        let input .= 'getword'
    endif
    let input .= '?key=' . s:cloud_keys.qq
    if vimim_cloud =~ 'fanti'
        let input .= '&jf=1'
    endif
    let md = 0
    if vimim_cloud =~ 'mixture'
        let md = 3
    endif
    if vimim_cloud =~ 'shuangpin'
        let md = 2
        let st = 0
            if vimim_cloud =~ 'abc'      | let st = 1
        elseif vimim_cloud =~ 'ms'       | let st = 2
        elseif vimim_cloud =~ 'plusplus' | let st = 3
        elseif vimim_cloud =~ 'purple'   | let st = 4
        elseif vimim_cloud =~ 'flypy'    | let st = 5
        elseif vimim_cloud =~ 'nature'   | let st = 6 | endif
        if st > 0
            let input .= '&st=' . st
        endif
    endif
    if md > 0
        let input .= '&md=' . md
    endif
    if vimim_cloud =~ 'fuzzy'
        let input .= '&mh=1'
    endif
    let input .= '&q=' . a:keyboard
    let output = s:vimim_get_from_http(input, 'qq')
    if empty(output) || output =~ '502 bad gateway'
        return []
    endif
    if s:localization > 0
        " qq => {"q":"fuck","rs":["\xe5\xa6\x87"],
        let output = s:vimim_i18n_read(output)
    endif
    let key = 'rs'
    let matched_list = []
    let output_hash = eval(output)
    if type(output_hash) == type({}) && has_key(output_hash, key)
        let matched_list = output_hash[key]
    endif
    if vimim_cloud !~ 'wubi' && vimim_cloud !~ 'shuangpin'
        let matched_list = s:vimim_cloud_pinyin(a:keyboard, matched_list)
    endif
    return matched_list
endfunction

function! s:vimim_get_cloud_google(keyboard)
    " http://google.com/transliterate?tl_app=3&tlqt=1&num=20&text=mxj
    " http://translate.google.com/?sl=en&tl=zh-CN#en|zh-CN|fuck'
    let input  = 'http://www.google.com/transliterate/chinese'
    let input .= '?langpair=en|zh'
    let input .= '&num=20'
    let input .= '&tl_app=3'
    let input .= '&tlqt=1'
    let input .= '&text=' . a:keyboard
    let output = join(split(s:vimim_get_from_http(input,'google')))
    let matched_list = []
    if s:localization > 0
        " google => '[{"ew":"fuck","hws":["\u5987\u4EA7\u79D1",]},]'
        if s:http_executable =~ 'Python2'
            let output = s:vimim_i18n_read(output)
        else
            let unicodes = split(get(split(output),8),",")
            for item in unicodes
                let utf8 = ""
                for xxxx in split(item,"\u")
                    let utf8 .= s:vimim_unicode_to_utf8(xxxx)
                endfor
                let output = s:vimim_i18n_read(utf8)
                call add(matched_list, output)
            endfor
            return matched_list
        endif
    endif
    let key = 'hws'
    let output_hash = get(eval(output),0)
    if type(output_hash) == type({}) && has_key(output_hash, key)
        let matched_list = output_hash[key]
    endif
    return s:vimim_cloud_pinyin(a:keyboard, matched_list)
endfunction

function! s:vimim_cloud_pinyin(keyboard, matched_list)
    let keyboards = s:vimim_get_pinyin_from_pinyin(a:keyboard)
    let matched_list = []
    for chinese in a:matched_list
        let len_chinese = len(split(chinese,'\zs'))
        let english = join(keyboards[len_chinese :], "")
        let yin_yang = chinese
        if !empty(english)
            let yin_yang .= english
        endif
        call add(matched_list, yin_yang)
    endfor
    return matched_list
endfunction

function! s:vimim_get_cloud_baidu(keyboard)
    " http://olime.baidu.com/py?rn=0&pn=20&py=mxj
    let input  = 'http://olime.baidu.com/py'
    let input .= '?rn=0'
    let input .= '&pn=20'
    let input .= '&py=' . a:keyboard
    let output = s:vimim_get_from_http(input, 'baidu')
    let output_list = []
    if exists("g:baidu") && type(g:baidu) == type([])
        let output_list = get(g:baidu,0)
    endif
    if empty(output_list)
        if empty(output) || output =~ '502 bad gateway'
            return []
        elseif empty(s:localization)
            " ['[[["\xc3\xb0\xcf\xd5\xbc\xd2",3]
            let output = iconv(output, "gbk", "utf-8")
        endif
        let output_list = get(eval(output),0)
    endif
    if type(output_list) != type([])
        return []
    endif
    let matched_list = []
    for item_list in output_list
        let chinese = get(item_list,0)
        if chinese =~# '\w'
            continue
        endif
        let english = strpart(a:keyboard, get(item_list,1))
        let yin_yang = chinese . english
        call add(matched_list, yin_yang)
    endfor
    return matched_list
endfunction

function! s:vimim_get_cloud_all(keyboard)
    let results = []
    for cloud in s:cloud_defaults
        let start = localtime()
        let outputs = s:vimim_get_cloud(a:keyboard, cloud)
        call add(results, s:space)
        let title  = a:keyboard . s:space
        let title .= s:vimim_chinese(cloud)
        let title .= s:vimim_chinese('cloud')
        let title .= s:vimim_chinese('input')
        let duration = localtime() - start
        if duration > 0
            let title .= s:space . string(duration)
        endif
        call add(results, title)
        if len(outputs) > 1+1+1+1
            let outputs = &number ? outputs : outputs[0:9]
            let filter = "substitute(" . 'v:val' . ",'[a-z ]','','g')"
            call add(results, join(map(outputs,filter)))
        endif
    endfor
    call add(results, s:space)
    call s:debug('info', 'cloud_results=', results)
    return results
endfunction

" ============================================= }}}
let s:VimIM += [" ====  backend mycloud  ==== {{{"]
" =================================================

function! s:vimim_scan_backend_mycloud()
    let s:mycloud_arg  = 0
    let s:mycloud_func = 0
    let s:mycloud_host = 0
    let s:mycloud_mode = 0
    let s:mycloud_port = 0
    let im = 'mycloud'
    let s:backend.cloud[im] = s:vimim_one_backend_hash()
    let mycloud = s:vimim_check_mycloud_availability()
    if empty(mycloud)
        let s:mycloud = 0
        let s:backend.cloud = {}
    else
        let root = 'cloud'
        let s:backend.cloud[im].root = root
        let s:backend.cloud[im].im = im
        let s:backend.cloud[im].name    = s:vimim_chinese(im)
        let s:backend.cloud[im].chinese = s:vimim_chinese(im)
        let s:ui.im = im
        let s:ui.root = root
        let s:ui.frontends = [[s:ui.root, s:ui.im]]
        let s:vimim_shuangpin = 0
        let s:vimim_cloud = -1
        let s:mycloud = mycloud
    endif
endfunction

function! s:vimim_check_mycloud_availability()
    let cloud = 0
    if empty(s:vimim_mycloud)
        let cloud = s:vimim_check_mycloud_plugin_libcall()
    else
        let cloud = s:vimim_check_mycloud_plugin_url()
    endif
    if empty(cloud)
        return 0
    endif
    let ret = s:vimim_access_mycloud(cloud, "__getkeychars")
    let keycode = split(ret, "\t")[0]
    if empty(keycode)
        return 0
    endif
    let ret = s:vimim_access_mycloud(cloud, "__getname")
    let directory = split(ret, "\t")[0]
    let s:backend.cloud.mycloud.directory = directory
    let s:backend.cloud.mycloud.keycode = keycode
    return cloud
endfunction

function! s:vimim_access_mycloud(cloud, cmd)
    " use the same function to access mycloud by libcall() or system()
    let ret = ""
    if s:mycloud_mode == "libcall"
        let arg = s:mycloud_arg
        if empty(arg)
            let ret = libcall(a:cloud, s:mycloud_func, a:cmd)
        else
            let ret = libcall(a:cloud, s:mycloud_func, arg." ".a:cmd)
        endif
    elseif s:mycloud_mode == "python"
        let host = s:mycloud_host
        let port = s:mycloud_port
        let ret = s:vimim_mycloud_python_client(a:cmd, host, port)
    elseif s:mycloud_mode == "system"
        let ret = system(a:cloud." ".shellescape(a:cmd))
    elseif s:mycloud_mode == "www"
        let input = s:vimim_rot13(a:cmd)
        let http = s:http_executable
        if http =~ 'libvimim'
            let ret = libcall(http, "do_geturl", a:cloud.input)
        elseif len(http) > 0
            let ret = system(http . shellescape(a:cloud.input))
        endif
        if len(ret) > 0
            let output = s:vimim_rot13(ret)
            let ret = s:vimim_url_xx_to_chinese(output)
        endif
    endif
    return ret
endfunction

function! s:vimim_rot13(keyboard)
    let a = "12345abcdefghijklmABCDEFGHIJKLM"
    let z = "98760nopqrstuvwxyzNOPQRSTUVWXYZ"
    return tr(a:keyboard, a.z, z.a)
endfunction

function! s:vimim_get_libvimim()
    let cloud = ""
    if has("win32") || has("win32unix")
        let cloud = "libvimim.dll"
    elseif has("unix")
        let cloud = "libvimim.so"
    else
        return ""
    endif
    let cloud = s:plugin . cloud
    if filereadable(cloud)
        return cloud
    endif
    return ""
endfunction

function! s:vimim_check_mycloud_plugin_libcall()
    " we do plug-n-play for libcall(), not for system()
    let cloud = s:vimim_get_libvimim()
    if !empty(cloud)
        let s:mycloud_mode = "libcall"
        let s:mycloud_arg = ""
        let s:mycloud_func = 'do_getlocal'
        if filereadable(cloud)
            if has("win32")
                " we don't need to strip ".dll" for "win32unix".
                let cloud = cloud[:-5]
            endif
            try
                let ret = s:vimim_access_mycloud(cloud, "__isvalid")
                if split(ret, "\t")[0] == "True"
                    return cloud
                endif
            catch
                call s:debug('alert', 'libcall_mycloud2=',v:exception)
            endtry
        endif
    endif
    " libcall check failed, we now check system()
    if has("gui_win32")
        return 0
    endif
    " on linux, we do plug-n-play
    let cloud = s:plugin . "mycloud/mycloud"
    if !executable(cloud)
        if !executable("python")
            return 0
        endif
        let cloud = "python " . cloud
    endif
    " in POSIX system, we can use system() for mycloud
    let s:mycloud_mode = "system"
    let ret = s:vimim_access_mycloud(cloud, "__isvalid")
    if split(ret, "\t")[0] == "True"
        return cloud
    endif
    return 0
endfunction

function! s:vimim_check_mycloud_plugin_url()
    " we do set-and-play on all systems
    let part = split(s:vimim_mycloud, ':')
    let lenpart = len(part)
    if lenpart <= 1
        call s:debug('info', "invalid_cloud_plugin_url")
    elseif part[0] ==# 'app'
        if !has("gui_win32")
            " strip the first root if contains ":"
            if lenpart == 3
                if part[1][0] == '/'
                    let cloud = part[1][1:] . ':' .  part[2]
                else
                    let cloud = part[1] . ':' . part[2]
                endif
            elseif lenpart == 2
                let cloud = part[1]
            endif
            " in POSIX system, we can use system() for mycloud
            if executable(split(cloud, " ")[0])
                let s:mycloud_mode = "system"
                let ret = s:vimim_access_mycloud(cloud, "__isvalid")
                if split(ret, "\t")[0] == "True"
                    return cloud
                endif
            endif
        endif
    elseif part[0] ==# 'py'
        if has("python")
            " python 2 support code here
            if lenpart > 2
                let s:mycloud_host = part[1]
                let s:mycloud_port = part[2]
            elseif lenpart > 1
                let s:mycloud_host = part[1]
                let s:mycloud_port = 10007
            else
                let s:mycloud_host = "localhost"
                let s:mycloud_port = 10007
            endif
            try
                call s:vimim_mycloud_python_init()
                let s:mycloud_mode = "python"
                let cloud = part[1]
                let ret = s:vimim_access_mycloud(cloud, "__isvalid")
                if split(ret, "\t")[0] == "True"
                    return "python"
                endif
            catch
                call s:debug('alert', 'python_mycloud=', v:exception)
            endtry
        endif
    elseif part[0] ==# "dll"
        if len(part[1]) == 1
            let base = 1
        else
            let base = 0
        endif
        " provide function name
        if lenpart >= base+4
            let s:mycloud_func = part[base+3]
        else
            let s:mycloud_func = 'do_getlocal'
        endif
        " provide argument
        if lenpart >= base+3
            let s:mycloud_arg = part[base+2]
        else
            let s:mycloud_arg = ""
        endif
        " provide the dll
        if base == 1
            let cloud = part[1] . ':' . part[2]
        else
            let cloud = part[1]
        endif
        if filereadable(cloud)
            let s:mycloud_mode = "libcall"
            " strip off the .dll suffix, only required for win32
            if has("win32") && cloud[-4:] ==? ".dll"
                let cloud = cloud[:-5]
            endif
            try
                let ret = s:vimim_access_mycloud(cloud, "__isvalid")
                if split(ret, "\t")[0] == "True"
                    return cloud
                endif
            catch
                call s:debug('alert', 'libcall_mycloud=', v:exception)
            endtry
        endif
    elseif part[0] ==# "http" || part[0] ==# "https"
        if empty(s:vimim_check_http_executable())
            return 0
        endif
        if !empty(s:http_executable)
            let s:mycloud_mode = "www"
            let ret = s:vimim_access_mycloud(s:vimim_mycloud,"__isvalid")
            if split(ret, "\t")[0] == "True"
                return s:vimim_mycloud
            endif
        endif
    else
        call s:debug('alert', "invalid_cloud_plugin_url")
    endif
    return 0
endfunction

function! s:vimim_get_mycloud_plugin(keyboard)
    let output = 0
    try
        let output = s:vimim_access_mycloud(s:mycloud, a:keyboard)
    catch
        call s:debug('alert', 'mycloud=', v:exception)
    endtry
    if empty(output)
        return []
    endif
    let results = []
    for item in split(output, '\n')
        let item_list = split(item, '\t')
        let chinese = get(item_list,0)
        if s:localization > 0
            let chinese = s:vimim_i18n_read(chinese)
        endif
        if empty(chinese) || get(item_list,1,-1)<0
            " bypass the debug line which have -1
            continue
        endif
        let extra_text = get(item_list,2)
        let english = a:keyboard[get(item_list,1):]
        let new_item = extra_text . " " . chinese . english
        call add(results, new_item)
    endfor
    return results
endfunction

function! s:vimim_url_xx_to_chinese(xx)
    " %E9%A6%AC => \xE9\xA6\xAC => 馬 u99AC
    let output = a:xx
    if s:http_executable =~ 'libvimim'
        let output = libcall(s:http_executable, "do_unquote", a:xx)
    else
        let pat = '%\(\x\x\)'
        let sub = '\=eval(''"\x''.submatch(1).''"'')'
        let output = substitute(a:xx, pat, sub, 'g')
    endif
    return output
endfunction

" ============================================= }}}
let s:VimIM += [" ====  core workflow    ==== {{{"]
" =================================================

function! s:vimim_initialize_i_setting()
    let s:cpo         = &cpo
    let s:omnifunc    = &omnifunc
    let s:completeopt = &completeopt
    let s:laststatus  = &laststatus
    let s:statusline  = &statusline
    let s:titlestring = &titlestring
    let s:lazyredraw  = &lazyredraw
    let s:showmatch   = &showmatch
    let s:smartcase   = &smartcase
    let s:ruler       = &ruler
endfunction

function! s:vimim_set_vim()
    set imdisable
    set iminsert=0
    set completeopt=menuone
    set omnifunc=VimIM
    set nolazyredraw
    set noshowmatch
    set noruler
    set title
    highlight  default CursorIM guifg=NONE guibg=green gui=NONE
    highlight! link Cursor CursorIM
endfunction

function! s:vimim_restore_vim()
    let &cpo         = s:cpo
    let &omnifunc    = s:omnifunc
    let &completeopt = s:completeopt
    let &laststatus  = s:laststatus
    let &statusline  = s:statusline
    let &titlestring = s:titlestring
    let &lazyredraw  = s:lazyredraw
    let &showmatch   = s:showmatch
    let &smartcase   = s:smartcase
    let &pumheight   = s:pumheight_saved
    let &ruler       = s:ruler
    highlight! link Cursor NONE
endfunction

function! s:vimim_start()
    sil!call s:vimim_set_vim()
    sil!call s:vimim_set_shuangpin()
    sil!call s:vimim_set_keycode()
    sil!call s:vimim_set_special_property()
    sil!call s:vimim_plugin_conflict_on()
    sil!call s:vimim_map_omni_page_label()
    inoremap <expr> <BS>     <SID>vimim_backspace()
    inoremap <expr> <CR>     <SID>vimim_enter()
    inoremap <expr> <Bslash> <SID>vimim_backslash()
    inoremap <expr> <Esc>    <SID>vimim_esc()
    inoremap <expr> <Space>  <SID>vimim_space()
endfunction

function! g:vimim_stop()
    sil!call s:vimim_restore_vim()
    sil!call s:vimim_super_reset()
    sil!call s:vimim_imap_off()
    sil!call s:vimim_plugin_conflict_off()
    sil!call s:vimim_imap_for_chinesemode()
    sil!call s:vimim_imap_for_onekey()
endfunction

function! s:vimim_super_reset()
    sil!call s:vimim_reset_before_anything()
    sil!call s:vimim_reset_before_omni()
    sil!call g:vimim_reset_after_insert()
endfunction

function! s:vimim_reset_before_anything()
    let s:keyboard = ""
    let s:onekey = 0
    let s:has_pumvisible = 0
    let s:show_extra_menu = 0
    let s:pattern_not_found = 0
    let s:popupmenu_list = []
endfunction

function! s:vimim_reset_before_omni()
    let s:search = 0
    let s:smart_enter = 0
    let s:show_me_not = 0
    let s:english_results = []
endfunction

function! g:vimim_reset_after_insert()
    let s:hjkl_n = ""     " reset
    let s:hjkl_h = 0      " ctrl-h for jsjsxx
    let s:hjkl_l = 0      " toggle label
    let s:hjkl_m = 0      " toggle cjjp/cjjp''
    let s:hjkl_star = 0   " toggle simplified/traditional
    let s:matched_list = []
    let s:pageup_pagedown = 0
    if s:pattern_not_found
        let s:pattern_not_found = 0
        return " "
    endif
    return ""
endfunction

function! g:vimim()
    let key = ""
    if empty(s:pageup_pagedown)
        let s:keyboard = ""
    endif
    let one_before = getline(".")[col(".")-2]
    if one_before =~# s:valid_key
        let key = '\<C-X>\<C-O>\<C-R>=g:vimim_menu_select()\<CR>'
    else
        let s:has_pumvisible = 0
    endif
    sil!exe 'sil!return "' . key . '"'
endfunction

function! g:vimim_menu_select()
    let key = pumvisible() ? '\<C-P>\<Down>' : ""
    sil!exe 'sil!return "' . key . '"'
endfunction

function! s:vimim_imap_off()
    let keys = range(0,9) + s:valid_keys
    if s:chinese_mode !~ 'dynamic'
    \&& s:vimim_chinese_punctuation !~ 'latex'
        let keys += s:AZ_list
    endif
    let keys += keys(s:evils) + keys(s:punctuations)
    let keys += ['<Esc>','<CR>','<BS>','<Space>','<Bar>','<Bslash>']
    for _ in keys
        if len(maparg(_, 'i'))
            sil!exe 'iunmap '. _
        endif
    endfor
endfunction

" ============================================= }}}
let s:VimIM += [" ====  core engine      ==== {{{"]
" =================================================

function! VimIM(start, keyboard)
if a:start
    let current_positions = getpos(".")
    let start_row = current_positions[1]
    let start_column = current_positions[2]-1
    let current_line = getline(start_row)
    let one_before = current_line[start_column-1]
    let seamless_column = s:vimim_get_seamless(current_positions)
    if seamless_column >= 0
        let len = current_positions[2]-1 - seamless_column
        let keyboard = strpart(current_line, seamless_column, len)
        call s:vimim_set_keyboard_list(seamless_column, keyboard)
        return seamless_column
    endif
    let last_seen_nonsense_column  = copy(start_column)
    let last_seen_backslash_column = copy(start_column)
    let nonsense = s:vimim_onekey_is_tab>1 ? "[a-f0-9']" : "[0-9']"
    let all_digit = 1
    while start_column > 0
        if one_before =~# s:valid_key
            let start_column -= 1
            if one_before !~# nonsense && s:ui.has_dot < 1
                let last_seen_nonsense_column = start_column
                if all_digit > 0
                    let all_digit = 0
                endif
            endif
        elseif one_before == '\' " do nothing if leading backslash found
            let s:pattern_not_found = 1
            return last_seen_backslash_column
        else
            break
        endif
        let one_before = current_line[start_column-1]
    endwhile
    if all_digit < 1 && current_line[start_column]=~'\d'
        let start_column = last_seen_nonsense_column
    endif
    let s:start_row_before = start_row
    let s:current_positions = current_positions
    let len = current_positions[2]-1 - start_column
    let keyboard = strpart(current_line, start_column, len)
    call s:vimim_set_keyboard_list(start_column, keyboard)
    return start_column
else
    " [cache] less is more
    let results = s:vimim_cache()
    if empty(results)
        sil!call s:vimim_reset_before_omni()
    else
        return s:vimim_popupmenu_list(results)
    endif
    " [initialization] early start, half done
    let keyboard = a:keyboard
    " [validation] user keyboard input validation
    if empty(str2nr(keyboard))
        " input is alphabet only, not good for 23554022100080204420
    else
        let keyboard = get(split(s:keyboard,","),0)
    endif
    if empty(keyboard) || keyboard !~ s:valid_key
        return []
    elseif empty(s:hjkl_m) && empty(s:hjkl_h)
        " [english] English cannot be ignored!
        let oneline = s:vimim_english(keyboard)
        let s:english_results = s:vimim_make_pair_list(oneline)
    endif
    if s:onekey      " flirt with hjkl
        let results = s:vimim_get_hjkl_game(keyboard)
        if !empty(results)
            return s:vimim_popupmenu_list(results)
        endif
    endif
    " [mycloud] get chunmeng from mycloud local or www
    if !empty(s:mycloud)
        let results = s:vimim_get_mycloud_plugin(keyboard)
        if !empty(results)
            let s:show_extra_menu = 1
            return s:vimim_popupmenu_list(results)
        endif
    elseif s:onekey  " play with nothing but onekey
        let ddddd = s:vimim_get_unicode_ddddd(keyboard)
        if ddddd
            let results = s:vimim_get_unicode_list(ddddd)
        else
            let results = s:vimim_get_imode_umode(keyboard)
        endif
        if empty(results)
            " [character]  sssss'' => s's's's's
            let keyboard = s:vimim_hjkl_partition(keyboard)
            " [quote] quote_by_quote: wo'you'yi'ge'meng
            let keyboard = s:vimim_get_keyboard_but_quote(keyboard)
            " [cjk] The cjk database works like swiss-army knife.
            let keyboard2 = s:vimim_onekey_cjk(keyboard)
            let results = s:vimim_cjk_match(keyboard2)
        endif
        if !empty(results)
            return s:vimim_popupmenu_list(results)
        endif
    endif
    " [shuangpin] support 6 major shuangpin
    if !empty(s:vimim_shuangpin) && empty(s:has_pumvisible)
        let keyboard = s:vimim_shuangpin_transform(keyboard)
        let s:keyboard = keyboard
    endif
    " [cloud] to make dream come true for multiple clouds
    let vimim_cloud = get(split(s:vimim_cloud,','), 0)
    if s:onekey > 1 || s:ui.root == 'cloud'
        let cloud = get(split(vimim_cloud,'[.]'),0)
        if !empty(s:frontends) && get(s:frontends,0) =~ 'cloud'
            let cloud = get(s:frontends,1)
        endif
        let results = s:vimim_get_cloud(keyboard, cloud)
    endif
    if empty(results)
        " [wubi] support auto insert on the 4th
        if s:ui.im =~ 'wubi\|erbi' || vimim_cloud =~ 'wubi'
            let keyboard = s:vimim_wubi_auto_input_on_the_4th(keyboard)
        endif
        " [backend] plug-n-play embedded backend engine
        let results = s:vimim_embedded_backend_engine(keyboard)
    endif
    if !empty(results) && get(results,0) !~ 'None\|0'
        return s:vimim_popupmenu_list(results)
    endif
    if s:onekey  " [the last resort] try both cjk and cloud
        let keyboard = s:vimim_get_keyboard_but_quote(keyboard."''")
        let results = s:vimim_cjk_match(keyboard)        " forced sssss''
        if empty(results) && empty(s:english_results)    " forced cloud
            let results = s:vimim_get_cloud(keyboard, s:cloud_default)
        endif
    endif
    if empty(results)
        let s:pattern_not_found = 1
    else
        return s:vimim_popupmenu_list(results)
    endif
return []
endif
endfunction

function! s:vimim_popupmenu_list(matched_list)
    let matched_list = a:matched_list
    let pairs = split(get(matched_list,0))
    if len(pairs) == 2 && get(pairs,0) == get(pairs,1)
        let matched_list = [] " s:english_results ["color color"]
    endif
    let lines = s:english_results + matched_list
    if empty(lines) || type(lines) != type([])
        return []
    else
        let s:matched_list = lines
        let keyboard = join(split(s:keyboard,","),"")
        if len(keyboard) == 1 && !has_key(s:cjk_cache,keyboard)
            let s:cjk_cache[keyboard] = lines
        endif
    endif
    " [skin] no color is the best color along with one row menu
    let color = len(lines)<2 ? 0 : 1
    let menu_in_one_row = s:vimim_skin(color)
    let label = 1
    let one_list = []
    let popupmenu_list = []
    for chinese in lines
        let complete_items = {}
        if s:hjkl_star && s:hjkl_star%2 && !empty(s:cjk_filename)
            let simplified_traditional = ""
            for char in split(chinese, '\zs')
                let simplified_traditional .= s:vimim_1to1(char)
            endfor
            let chinese = simplified_traditional
        endif
        if empty(s:show_me_not)
            if keyboard ==# chinese
                continue
            endif
            let menu = ""
            let pairs = split(chinese)
            if len(pairs) > 1
                let chinese = get(pairs,1)
                if s:show_extra_menu && empty(menu_in_one_row)
                    let menu = get(pairs,0)
                endif
            endif
            if empty(s:mycloud)
                let tail = get(split(s:keyboard,","),1)
                if !empty(tail)
                    let chinese .= tail
                endif
                if s:hjkl_h && s:hjkl_h%2 && empty(s:english_results)
                    if len(chinese) == s:multibyte
                        let menu = s:vimim_cjk_extra_text(chinese)
                    endif
                endif
            endif
            let labeling = ""
            if color
                let labeling = printf('%2s ', s:vimim_get_labeling(label))
            endif
            if len(one_list) < 20
                call add(one_list, label . "." . chinese)
            endif
            let label += 1
            let complete_items["abbr"] = labeling . chinese
            let complete_items["menu"] = menu
        endif
        let complete_items["dup"] = 1
        let complete_items["word"] = empty(chinese) ? s:space : chinese
        call add(popupmenu_list, complete_items)
    endfor
    if s:onekey
        let &titlestring = ""
        let s:popupmenu_list = popupmenu_list
        set completeopt=menuone
        if empty(s:show_me_not) && s:vimim_menuless && &number
            set completeopt=menu
            let &pumheight = 1
            let &titlestring = join(one_list)
        endif
    elseif menu_in_one_row
        return s:vimim_one_row(one_list[0:4], popupmenu_list[0:4])
    endif
    return popupmenu_list
endfunction

function! s:vimim_one_row(one_list, popupmenu_list)
    let popupmenu_list = a:popupmenu_list
    let column = virtcol(".")
    if column > &columns
        let column = virtcol(".") % &columns
    endif
    let spaces = &columns - column
    let minimum = &columns/2.5
    let row1 = join(a:one_list)
    let row2 = join(a:one_list[1:])
    if spaces < len(row1) + 4
        if  len(row2) > spaces || len(row2) > minimum
            return popupmenu_list
        endif
        let popupmenu_list[0].abbr = get(a:one_list,0)
        let popupmenu_list[1].abbr = row2
    else
        let popupmenu_list[0].abbr = row1
        let popupmenu_list[1].abbr = s:space
    endif
    let &pumheight = 2
    return popupmenu_list
endfunction

function! s:vimim_embedded_backend_engine(keyboard)
    let keyboard = a:keyboard
    if empty(s:ui.im) || empty(s:ui.root) || empty(keyboard)
    \|| keyboard !~# s:valid_key
    \|| s:ui.root =~ 'cloud'
    \|| s:show_me_not
        return []
    elseif s:ui.has_dot == 2 && keyboard !~ "[']"
        let keyboard = s:vimim_quanpin_transform(keyboard)
    endif
    let results = []
    let head = 0
    if s:ui.root =~# "directory"
        let dir = s:backend[s:ui.root][s:ui.im].name
        let head = s:vimim_sentence_directory(keyboard)
        let results = s:vimim_readfile(dir . head)
        if keyboard==#head && len(results)>0 && len(results)<20
            let extras = s:vimim_more_pinyin_directory(keyboard, dir)
            if len(extras) > 0 && len(results) > 0
                call map(results, 'keyboard ." ". v:val')
                call extend(results, extras)
            endif
        endif
    elseif s:ui.root =~# "datafile"
        let datafile = s:backend[s:ui.root][s:ui.im].name
        if datafile =~ "bsddb"
            let head = s:vimim_get_stone_from_bsddb(keyboard)
            let results = s:vimim_get_from_database(head)
        else
            let head = s:vimim_sentence_datafile(keyboard)
            let results = s:vimim_get_from_datafile(head)
        endif
    endif
    if s:keyboard !~ ','
        if empty(head)
            let s:keyboard = keyboard
        elseif len(head) < len(keyboard)
            let tail = strpart(keyboard,len(head))
            let s:keyboard = head . "," . tail
        endif
    endif
    return results
endfunction

" ============================================= }}}
let s:VimIM += [" ====  core driver      ==== {{{"]
" =================================================

function! s:vimim_imap_for_onekey()
    noremap<silent> n :sil!call g:vimim_search_next()<CR>n
    if s:vimim_onekey_is_tab < 1
            imap<silent> <C-^> <Plug>VimimOneKey
        xnoremap<silent> <C-^> y:call <SID>vimim_visual_ctrl6()<CR>
    else
            imap<silent> <Tab> <Plug>VimimOneKey
        xnoremap<silent> <Tab> y:call <SID>vimim_visual_ctrl6()<CR>
    endif
    :com! -range=% VimIM <line1>,<line2>call s:vimim_chinese_transfer()
    :com! -range=% ViMiM <line1>,<line2>call s:vimim_chinese_rotation()
endfunction

function! s:vimim_imap_for_chinesemode()
    if s:vimim_onekey_is_tab < 2
         noremap<silent>  <C-Bslash>  :call <SID>ChineseMode()<CR>
            imap<silent>  <C-Bslash>  <Plug>VimIM
        inoremap<silent><expr> <C-X><C-Bslash> <SID>VimIMSwitch()
        if s:vimim_ctrl_h_to_toggle == 1
            imap <C-H> <C-Bslash>
        elseif s:vimim_ctrl_h_to_toggle == 2
            inoremap<silent><expr> <C-H> <SID>VimIMSwitch()
        endif
    endif
endfunction

function! s:vimim_imap_for_ctrl_space()
    if s:vimim_ctrl_space_to_toggle == 1
        if has("gui_running")
             map <C-Space> <C-Bslash>
            imap <C-Space> <C-Bslash>
        elseif has("win32unix")
             map <C-@> <C-Bslash>
            imap <C-@> <C-Bslash>
        endif
    elseif s:vimim_ctrl_space_to_toggle == 3
        if has("gui_running")
            imap <C-Space> <C-^>
        elseif has("win32unix")
            imap   <C-@>   <C-^>
        endif
    elseif s:vimim_ctrl_space_to_toggle == 2
        if has("gui_running")
            inoremap<silent><expr> <C-Space> <SID>VimIMSwitch()
        elseif has("win32unix")
            inoremap<silent><expr> <C-@> <SID>VimIMSwitch()
        endif
    endif
endfunction

function! s:vimim_initialize_plugin()
    if !hasmapto("VimIM") && s:vimim_onekey_is_tab < 2
        inoremap<unique><expr> <Plug>VimIM  <SID>ChineseMode()
    endif
    if !hasmapto("VimimOneKey")
        inoremap<unique><expr> <Plug>VimimOneKey g:vimim_onekey()
    endif
endfunction

sil!call s:vimim_initialize_local()
sil!call s:vimim_initialize_global()
sil!call s:vimim_initialize_cloud()
sil!call s:vimim_initialize_plugin()
sil!call s:vimim_imap_for_onekey()
sil!call s:vimim_imap_for_chinesemode()
sil!call s:vimim_imap_for_ctrl_space()
" ======================================= }}}

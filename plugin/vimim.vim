" ===========================================================
"                   VimIM —— Vim 中文輸入法
" ===========================================================
let s:egg = ' vimim easter egg:' " vim i vimim ctrl+6 ctrl+6
let s:egg = ' $Date$'
let s:egg = ' $Revision$'
let s:url = ' http://vimim.googlecode.com/svn/vimim/vimim.vim.html'
let s:url = ' http://code.google.com/p/vimim/source/list'
let s:url = ' http://vim.sf.net/scripts/script.php?script_id=2506'

let s:VimIM  = [" ====  introduction     ==== {{{"]
" =================================================
"    File: vimim.vim
"  Author: vimim <vimim@googlegroups.com>
" License: GNU Lesser General Public License
"  Readme: VimIM is a Vim plugin as an Input Method for Vim i_CTRL-^
"    (1) do Chinese input without mode change: Midas touch
"    (2) do Chinese search without typing Chinese: slash search
"    (3) support Google/Baidu/Sogou/QQ cloud input
"    (4) support bsd database with python interface to Vim
"  Plug and Play:
"    (1) drop the vimim.vim to the plugin folder: plugin/vimim.vim
"    (2) [option] drop supported datafiles, like: plugin/vimim.txt
"  Usage:
"    (1) (vim normal mode)  gi      (for windowless chinese input)
"    (2) (vim normal mode)  n       (for windowless slash search)
"    (3) (vim insert mode)  ctrl+6  (for onekey omni popup)
"    (4) (vim insert mode)  ctrl+\  (for dynamic chinese mode)

" ============================================= }}}
let s:VimIM += [" ====  initialization   ==== {{{"]
" =================================================

function! s:vimim_bare_bones_vimrc()
    set cpoptions=Bce$ go=cirMehf shm=aoOstTAI noloadplugins hlsearch
    set gcr=a:blinkon0 mouse=nicr shellslash noswapfile viminfo=
    set fencs=ucs-bom,utf8,chinese,gb18030 gfn=Courier_New:h12:w7
    set enc=utf8 gfw=YaHei_Consolas_Hybrid,NSimSun-18030
    let unix = '/usr/local/bin:/usr/bin:/bin:.'
    let windows = '/bin/;/Python27;/Python31;/Windows/system32;.'
    let $PATH = has("unix") ? unix : windows
endfunction

if exists("g:vimim_profile") || v:version < 700
    finish
elseif &compatible
    call s:vimim_bare_bones_vimrc()
endif
scriptencoding utf-8
let g:vimim_profile = reltime()
let s:plugin = expand("<sfile>:p:h")

function! s:vimim_initialize_debug()
    " gvim -u /home/xma/vim/vimfiles/plugin/vimim.vim
    " gvim -u /home/vimim/svn/vimim/trunk/plugin/vimim.vim
    let hjkl = simplify(s:plugin . '/../../../hjkl/')
    if empty(&cp) && exists('hjkl') && isdirectory(hjkl)
        let g:vimim_plugin = hjkl
        let g:vimim_map = 'tab,ctrl6,ctrl_bslash,search,gi'
    endif
endfunction

function! s:vimim_debug(...)
    " [.vimrc] :redir @+>>
    " [client] :sil!call s:vimim_debug(s:vimim_egg_vimim())
    sil!echo "\n::::::::::::::::::::::::"
    if len(a:000) > 1
        sil!echo join(a:000, " :: ")
    elseif type(a:1) == type({})
        for key in keys(a:1)
            sil!echo key . '::' . a:1[key]
        endfor
    elseif type(a:1) == type([])
        for line in a:1
            sil!echo line
        endfor
    else
        sil!echo string(a:1)
    endif
    sil!echo "::::::::::::::::::::::::\n"
endfunction

function! s:vimim_initialize_global()
    highlight  default lCursorIM guifg=NONE guibg=green gui=NONE
    highlight! link lCursor lCursorIM
    let s:space = '　'
    let s:colon = '：'
    let s:logo = "VimIM　中文輸入法"
    let s:today = s:vimim_imode_today_now('itoday')
    let s:multibyte    = &encoding =~ "utf-8" ? 3 : 2
    let s:localization = &encoding =~ "utf-8" ? 0 : 2
    let s:seamless_positions = []
    let s:current_positions = [0,0,1,0]
    let s:quanpin_table = {}
    let s:shuangpin_table = {}
    let s:http_exe = ""
    let s:mycloud_initialization = 0
    let s:shuangpin = 'abc ms plusplus purple flypy nature'
    let s:abcd = split("'abcdvfgxz", '\zs')
    let s:qwer = split("pqwertyuio", '\zs')
    let s:az_list = map(range(97,122),"nr2char(".'v:val'.")")
    let s:valid_keys = s:az_list
    let s:valid_keyboard = "[0-9a-z']"
    let s:shengmu_list = split('b p m f d t l n g k h j q x r z c s y w')
    let s:starts = { 'row' : 0, 'column' : 1 }
    let s:pumheights = { 'current' : &pumheight, 'saved' : &pumheight }
    let s:smart_quotes = { 'single' : 1, 'double' : 1 }
    let s:backend = { 'cloud' : {}, 'datafile' : {}, 'directory' : {} }
    let s:ui = { 'root' : '', 'im' : '', 'frontends' : [] }
    let s:ui = { 'root' : '', 'im' : '', 'quote' : 0, 'frontends' : [] }
    let s:rc = { "g:vimim_mode" : 'dynamic' }
    let s:rc["g:vimim_shuangpin"] = 0
    let s:rc["g:vimim_map"] = 'ctrl6,ctrl_bslash,search,gi'
    let s:rc["g:vimim_toggle"] = 0
    let s:rc["g:vimim_cloud"] = 'google,sogou,baidu,qq'
    let s:rc["g:vimim_mycloud"] = 0
    let s:rc["g:vimim_plugin"] = s:plugin
    let s:rc["g:vimim_punctuation"] = 2
    call s:vimim_set_global_default()
    if isdirectory(g:vimim_plugin)
        let s:plugin = g:vimim_plugin
    endif
    if s:plugin[-1:] != "/"
        let s:plugin .= "/"
    endif
    let s:english = { 'lines' : [], 'line' : "" }
    let s:english.filename = s:vimim_filereadable("vimim.txt")
    let s:cjk = { 'lines' : [] }
    let s:cjk.filename = s:vimim_filereadable("vimim.cjk.txt")
endfunction

function! s:vimim_dictionary_keycodes()
    let s:keycodes = {}
    let cloud = ' google sogou baidu qq mycloud '
    for key in split( cloud . ' pinyin ')
        let s:keycodes[key] = "['a-z0-9]"
    endfor
    for key in split('array30 phonetic')
        let s:keycodes[key] = "[.,a-z0-9;/]"
    endfor
    for key in split('zhengma taijima wubi cangjie hangul xinhua quick')
        let s:keycodes[key] = "['a-z]"
    endfor
    let s:keycodes.wu       = "['a-z]"      " s:ui.quote=1
    let s:keycodes.nature   = "['a-z]"      " s:ui.quote=1
    let s:keycodes.yong     = "['a-z.;/]"   " s:ui.quote=1
    let s:keycodes.erbi     = "['a-z.;/,]"  " s:ui.quote=1
    let s:keycodes.boshiamy = "['a-z.],[]"  " s:ui.quote=1
    let ime  = ' pinyin_sogou pinyin_quote_sogou pinyin_huge'
    let ime .= ' pinyin_fcitx pinyin_canton pinyin_hongkong'
    let ime .= ' wubi98 wubi2000 wubijd wubihf'
    let s:all_vimim_input_methods = keys(s:keycodes) + split(ime)
endfunction

function! s:vimim_set_keycode()
    let datafile_has_quote = 'erbi wu nature yong boshiamy'
    let s:ui.quote = 1
    if match(split(datafile_has_quote), s:ui.im) < 0
        let s:ui.quote = 0
    endif
    let keycode = "[0-9a-z']"
    if !empty(s:ui.root) && empty(g:vimim_shuangpin)
        let keycode = s:backend[s:ui.root][s:ui.im].keycode
    elseif g:vimim_shuangpin == 'ms' || g:vimim_shuangpin == 'purple'
        let keycode = "[0-9a-z';]"
    endif
    let i = 0
    let keycode_string = ""
    while i < 16*16
        let char = nr2char(i)
        if char =~# keycode
            let keycode_string .= char
        endif
        let i += 1
    endwhile
    let s:valid_keyboard  = copy(keycode)
    let s:valid_keys = split(keycode_string, '\zs')
    let vimim_cloud = get(split(g:vimim_cloud,','), 0)
    let s:wubi = vimim_cloud =~ 'wubi' || s:ui.im =~ 'wubi\|erbi' ? 1 : 0
endfunction

function! s:vimim_set_global_default()
    let s:vimimrc = []
    let s:vimimdefaults = []
    for variable in keys(s:rc)
        if exists(variable)
            let value = string(eval(variable))
            let vimimrc = ':let ' . variable .' = '. value .' '
            call add(s:vimimrc, '    ' . vimimrc)
        else
            let value = string(s:rc[variable])
            let vimimrc = ':let ' . variable .' = '. value .' '
            call add(s:vimimdefaults, '  " ' . vimimrc)
        endif
        exe 'let '. variable .'='. value
    endfor
endfunction

" ============================================= }}}
let s:VimIM += [" ====  easter eggs      ==== {{{"]
" =================================================

function! s:vimim_easter_chicken(keyboard)
    try
        return eval("s:vimim_egg_" . a:keyboard . "()")
    catch
        sil!call s:vimim_debug('egg', a:keyboard, v:exception)
    endtry
    return []
endfunction

function! s:vimim_egg_vimimhelp()
    let eggs  = split(s:url)
    let eggs += [''] + s:vimim_egg_vim()
    let eggs += [''] + s:vimim_egg_vimimgame()
    let eggs += [''] + s:vimim_egg_vimim()
    let eggs += [''] + s:vimim_egg_vimimvim()
    return map(eggs, 'v:val . " "')
endfunction

function! s:vimim_egg_vim()
    return ["Vim　　文本編輯器", s:logo]
endfunction

function! s:vimim_egg_vimimgame()
    let mahjong = "春夏秋冬 梅兰竹菊 中發白囍 東南西北"
    return split(mahjong)
endfunction

function! s:vimim_egg_vimimvim()
    let filter = "strpart(" . 'v:val' . ", 0, 29)"
    return map(copy(s:VimIM), filter)
endfunction

function! s:vimim_egg_vimimrc()
    let vimim = s:vimimdefaults + s:vimimrc
    if g:vimim_toggle > -1    " update g:vimim_toggle if not closed
        let filter = "get(" . 'v:val' . ",1)"
        let g:vimim_toggle = join(map(copy(s:ui.frontends),filter),",")
        let toggle = match(vimim, 'g:vimim_toggle')
        let left = vimim[toggle][0 : 1 + match(vimim[toggle], '=')]
        let vimim[toggle] = left . string(g:vimim_toggle)
    endif
    return sort(vimim)
endfunction

function! s:vimim_egg_vimim()
    let eggs = []
    call add(eggs, s:chinese('date', s:colon) . s:today)
    let os = "win32unix win32 win64 macunix unix x11"
    for computer in split(os)
        if has(computer) | let os = computer | break | endif
    endfor
    let time = reltimestr(g:vimim_profile) . ' seconds'
    call add(eggs, s:chinese('computer', s:colon) . os . time)
    let revision = get(split(s:egg),1)
    let revision = empty(revision) ?  ""  : "vimim.vim=" . revision
    let revision = v:progname ."=". v:version  . s:space . revision
    call add(eggs, s:chinese('revision', s:colon) . revision)
    let encoding = s:chinese('encoding', s:colon) . &encoding
    call add(eggs, encoding . s:space . &fileencodings)
    call add(eggs, s:chinese('env', s:colon) . v:lc_time)
    let db = s:chinese('database', s:colon)
    if len(s:cjk.filename)
        call add(eggs, db.s:chinese('cjk',s:colon).s:cjk.filename)
    endif
    if len(s:english.filename)
        call add(eggs, db.s:chinese('english').db.s:english.filename)
    endif
    let cloud = db . s:chinese('cloud', 'cloud') . db
    for [root, im] in s:ui.frontends
        let backend = s:backend[root][im]
        if root == "cloud"
            let cloud .= backend.name . s:chinese('cloud') . s:space
        else
            call add(eggs, db . backend.chinese . db . backend.name)
        endif
    endfor
    call add(eggs, cloud)
    let exe = s:http_exe =~ 'Python' ? '' : "HTTP executable: "
    sil!call add(eggs, s:chinese('network', s:colon) . exe . s:http_exe)
    sil!call add(eggs, s:chinese('option',  s:colon) . "vimimrc")
    sil!return map(eggs + s:vimim_egg_vimimrc(), 'v:val . " " ')
endfunction

" ============================================= }}}
let s:VimIM += [" ====  hjkl mahjong     ==== {{{"]
" =================================================

function! s:vimim_cache()
    let results = []
    if !empty(s:pageup_pagedown)
        let length = len(s:match_list)
        if length > &pumheight
            let page = s:pageup_pagedown * &pumheight
            let partition = page ? page : length+page
            let B = s:match_list[partition :]
            let A = s:match_list[: partition-1]
            let results = B + A
        endif
    elseif s:mode.onekey && s:touch_me_not
        if s:hjkl_h
            let s:hjkl_h = 0
            for line in s:match_list
                let oneline = join(reverse(split(line,'\zs')),'')
                call add(results, oneline)
            endfor
        elseif s:hjkl_l
            let s:hjkl_l = 0
            let results = reverse(copy(s:match_list))
        endif
    endif
    return results
endfunction

function! s:vimim_get_hjkl_game(keyboard)
    let keyboard = a:keyboard
    let results = []
    let poem = s:vimim_filereadable(keyboard)
    if keyboard =~# '^i' && keyboard =~ '\d' && empty(g:vimim_shuangpin)
        return s:vimim_imode_number(keyboard)
    elseif keyboard ==# 'itoday' || keyboard ==# 'inow'
        return [s:vimim_imode_today_now(keyboard)]
    elseif keyboard == "''''''"
        return split(join(s:vimim_egg_vimimgame(),""),'\zs')
    elseif s:vimim_get_unicode_ddddd(keyboard)
        return s:vimim_unicode_list(s:vimim_get_unicode_ddddd(keyboard))
    elseif keyboard == "''"
        let char_before = s:vimim_char_before()
        if empty(char_before)
            let char_before = '一'
            if s:vimim_cjk()    " 214 standard unicode index
                return s:vimim_cjk_match('u')
            endif
        endif
        return s:vimim_unicode_list(char2nr(char_before))
    elseif !empty(poem)
        " [hjkl] flirt any non-dot file in the hjkl directory
        let results = s:vimim_readfile(poem)
    elseif keyboard ==# "vim" || keyboard =~# "^vimim"
        " [hidden] hunt classic easter egg ... vim<C-6>
        let results = s:vimim_easter_chicken(keyboard)
    elseif keyboard =~# '^\l\+' . "'" . '\{4}$'
        " [clouds] all clouds for any input: fuck''''
        let results = s:vimim_get_all_clouds(keyboard[:-5])
    elseif len(getreg('"')) > 3     "  vimim_visual
        if keyboard == "''''"       ": display buffer inside omni
            let results = split(getreg('"'), '\n')
        elseif keyboard =~ "'''''"  ": display one-line-cjk property
            let line = substitute(getreg('"'),'[\x00-\xff]','','g')
            if len(line)
                for chinese in split(line, '\zs')
                    let menu  = s:vimim_cjk_property(chinese)
                    let menu .= repeat(" ", 38-len(menu))
                    call add(results, chinese . " " . menu)
                endfor
            endif
        endif
    endif
    if !empty(results)
        let s:touch_me_not = 1
        if s:hjkl_m % 4
            for i in range(s:hjkl_m % 4)
                let results = s:vimim_hjkl_rotation(results)
            endfor
        endif
        let results = [s:space] + results + [s:space]
    endif
    return results
endfunction

function! s:vimim_hjkl_rotation(lines)
    let max = max(map(copy(a:lines), 'strlen(v:val)')) + 1
    let multibyte = match(a:lines,'\w') < 0 ? s:multibyte : 1
    let results = []
    for line in a:lines
        let spaces = ''   " rotation makes more sense for cjk
        if (max-len(line)) / multibyte
            for i in range((max-len(line))/multibyte)
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
            if !empty(line)
                let column .= line
            endif
        endfor
        call add(rotations, column)
    endfor
    return rotations
endfunction

function! s:vimim_chinese_rotation() range abort
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
let s:VimIM += [" ====  user interface   ==== {{{"]
" =================================================

function! s:vimim_set_color()
    if g:vimim_mode =~ 'nocolor'
    elseif has("win32") || has("win32unix")
        highlight! PmenuSbar  NONE
        highlight! PmenuThumb NONE
        highlight! Pmenu      NONE
        highlight! link PmenuSel NonText
    endif
endfunction

function! s:vimim_dictionary_statusline()
    let s:title = {}
    let s:title.cjk        = "标准字库,標準字庫"
    let s:title.boshiamy   = "呒虾米,嘸蝦米"
    let s:title.wubi2000   = "新世纪,新世紀"
    let s:title.taijima    = "太极码,太極碼"
    let s:title.nature     = "自然码,自然碼"
    let one  = " computer database option flypy network cloud env "
    let one .= " encoding ms static dynamic erbi wubi hangul xinhua"
    let one .= " zhengma cangjie yong wu wubijd shuangpin"
    let two  = " 电脑,電腦 词库,詞庫 选项,選項 小鹤,小鶴 联网,聯網 云,雲 "
    let two .= " 环境,環境 编码,編碼 微软,微軟 静态,靜態 动态,動態"
    let two .= " 二笔,二筆 五笔,五筆 韩文,韓文 新华,新華 郑码,鄭碼"
    let two .= " 仓颉,倉頡 永码,永碼 吴语,吳語 极点,極點 双拼,雙拼"
    call extend(s:title, s:vimim_key_value_hash(one, two))
    let one  = " pin fullwidth halfwidth english chinese purple plusplus"
    let one .= " quick wubihf mycloud wubi98 hit pinyin phonetic array30"
    let one .= " abc revision date google baidu sogou qq "
    let two  = " 拼 全角 半角 英文 中文 紫光 加加 速成 海峰 自己的 98"
    let two .= " 打 拼音 注音 行列 智能 版本 日期 谷歌 百度 搜狗 ＱＱ"
    call extend(s:title, s:vimim_key_value_hash(one, two))
endfunction

function! s:vimim_dictionary_punctuations()
    let one = "  , .  +  -  ~  ^    _    "
    let two = " ， 。 ＋ － ～ …… —— "
    let mini_punctuations = s:vimim_key_value_hash(one, two)
    let one = "# & % $ ! = ; ? * { } ( ) < > [ ] : @"
    let two = "＃ ＆ ％ ￥ ！ ＝ ； ？ ﹡ 〖 〗 （ ） 《 》 【 】 ： 　"
    let most_punctuations = s:vimim_key_value_hash(one, two)
    let s:key_evils = { '\' : "、", "'" : "‘’", '"' : "“”" }
    let s:all_evils = {}   " all punctuations for onekey_evils
    call extend(s:all_evils, mini_punctuations)
    call extend(s:all_evils, most_punctuations)
    let s:punctuations = {}
    if g:vimim_punctuation > 0   " :let g:vimim_punctuation = 1
        call extend(s:punctuations, mini_punctuations)
    endif
    if g:vimim_punctuation > 1   " :let g:vimim_punctuation = 2
        call extend(s:punctuations, most_punctuations)
    endif
endfunction

function! s:chinese(...)
    let chinese = ""
    for english in a:000
        let cjk = english
        if has_key(s:title, english)
            let twins = split(s:title[english], ",")
            let cjk = get(twins, 0)
            if len(twins) > 1 && empty(s:english.filename)
                let cjk = get(twins,1)
            endif
        endif
        let chinese .= cjk
    endfor
    return chinese
endfunction

function! s:vimim_set_statusline()
    let &laststatus = s:mode.onekey ? s:laststatus : 2
    if empty(&statusline)
        set statusline=%<%f\ %h%m%r%=%-14.(%l,%c%V%)\ %P%{IMName()}
    elseif &statusline =~ 'IMName'   " nothing, as it is already there
    elseif &statusline =~ '\V\^%!'
        let &statusline .= '.IMName()'
    else
        let &statusline .= '%{IMName()}'
    endif
endfunction

function! IMName()
    if s:mode.onekey && pumvisible() || &omnifunc == 'VimIM'
        return s:space . s:vimim_statusline()
    endif  " This function is for user-defined 'stl' 'statusline'
    return ""
endfunction

function! s:vimim_get_title()
    if empty(s:ui.root) || empty(s:ui.im)
        return ""
    endif
    let title = s:space
    let backend = s:backend[s:ui.root][s:ui.im]
    if has_key(s:keycodes, s:ui.im)
        let im = backend.chinese
        if s:mode.windowless && len(s:cjk.filename)
            let im = len(s:english.line) ? '*' : ''
            let im = len(s:hjkl_n) ? s:hjkl_n : im
        endif
        let title .= im
    endif
    if s:ui.im =~ 'wubi'
        for wubi in split('wubi98 wubi2000 wubijd wubihf')
            if get(split(backend.name, '/'),-1) =~ wubi
                let title .= s:chinese(wubi)
            endif
        endfor
    elseif s:ui.im == 'mycloud'
        let title .= s:chinese('cloud', s:space)
        let title .= s:backend.cloud.mycloud.directory
    elseif s:ui.root == 'cloud'
        let title = s:chinese(s:space, s:cloud, 'cloud')
        let clouds = split(g:vimim_cloud,',')
        let vimim_cloud = get(clouds, match(clouds, s:cloud))
        if vimim_cloud =~ 'wubi'          " g:vimim_cloud='qq.wubi'
            let title .= s:chinese(s:space, 'wubi')
        elseif vimim_cloud =~ 'shuangpin' " qq.shuangpin.ms => ms
            let shuangpin = get(split(vimim_cloud,"[.]"),-1)
            if match(split(s:shuangpin),shuangpin) > -1
                let title .= s:chinese(s:space, shuangpin, 'shuangpin')
            endif
        endif
    endif
    if !empty(g:vimim_shuangpin)
        let title = s:chinese(s:space, g:vimim_shuangpin, 'shuangpin')
    endif
    if g:vimim_shuangpin =~ 'abc' || g:vimim_cloud =~ 'abc'
        let title = substitute(title,s:chinese('pin'),s:chinese('hit'),'')
    endif
    return title . s:space
endfunction

function! s:vimim_statusline()
    let punctuation = 'halfwidth'
    if g:vimim_punctuation > 0 && s:toggle_punctuation > 0
        let punctuation = 'fullwidth'
    endif
    let mode = g:vimim_mode =~ 'static' ? 'static' : 'dynamic'
    let line = s:chinese('chinese', mode) . s:vimim_get_title()
    return line . s:chinese(punctuation, s:space, "VimIM")
endfunction

function! g:vimim_slash()
    let range = col(".") - 1 - s:starts.column
    let chinese = strpart(getline("."), s:starts.column, range)
    let word = substitute(chinese,'\w','','g')
    let @/ = empty(word) ? @_ : word
    let slash = ""
    let repeat_times = len(word) / s:multibyte
    if repeat_times && line(".") == s:starts.row
        let slash = repeat("\<Left>\<Delete>", repeat_times)
    endif
    sil!exe 'sil!return "' . slash . g:vimim_esc() . '"'
endfunction

function! g:vimim_bracket(offset)
    let cursor = ""
    let range = col(".") - 1 - s:starts.column
    let repeat_times = range / s:multibyte + a:offset
    if repeat_times && line(".") == s:starts.row
        let cursor = repeat("\<Left>\<Delete>", repeat_times)
    elseif repeat_times < 1
        let cursor = strpart(getline("."), s:starts.column, s:multibyte)
    endif
    return cursor
endfunction

function! s:vimim_get_label(label)
    let labeling = a:label == 10 ? "0" : a:label
    if s:mode.onekey && a:label < 11
        let label2 = a:label < 2 ? "_" : get(s:abcd,a:label-1)
        let labeling = empty(labeling) ? '10' : labeling . label2
        if len(s:cjk.filename) && empty(s:hjkl_l%2)
            let labeling = " " . label2
        endif
    endif
    return labeling
endfunction

" ============================================= }}}
let s:VimIM += [" ====  lmap imap nmap   ==== {{{"]
" =================================================

function! s:vimim_all_maps()
    if s:mode.dynamic || s:mode.static
        sil!call s:vimim_punctuations_maps()
    elseif s:mode.onekey
        let hjkl = split("h j k l m n / ? s")
        let onekey_list = s:vimim_cjk() ?  hjkl + s:qwer : hjkl
        for _ in onekey_list
            if s:mode.onekey
                 sil!exe 'lnoremap<expr> '._.' g:vimim_hjkl("'._.'")'
            elseif s:mode.windowless
                 sil!exe 'lnoremap<expr> '._.' '._.'
            endif
        endfor
    endif
    if s:mode.dynamic || s:mode.windowless && s:ui.im !~ 'pinyin'
        let nonsense = s:ui.quote ? "[0-9]" : "[0-9']"
        for char in s:valid_keys
            if char !~ nonsense || s:ui.im =~ 'phonetic'
                sil!exe 'lnoremap <silent> ' . char . ' <C-R>=' .
                \ 'g:wubi()<CR>' . char . '<C-R>=g:vimim()<CR>'
            endif
        endfor
    endif
    let common_labels = s:ui.im =~ 'phonetic' ? [] : range(10)
    let punctuations = split("] [ = -")
    if s:mode.onekey
        let punctuations += split(". ,")
        let common_labels += s:abcd[1:]
    endif
    for _ in punctuations
        if _ !~ s:valid_keyboard && empty(s:mode.windowless)
            sil!exe 'lnoremap <expr> '._.' g:vimim_page("'._.'")'
        endif
    endfor
    for _ in common_labels
        sil!exe 'lnoremap <expr> '._.' g:vimim_label("'._.'")'
    endfor
endfunction

function! g:vimim_label(key)
    let key = a:key
    if pumvisible()
        let n = match(s:abcd, key)
        if key =~ '\d'
            let n = key < 1 ? 9 : key - 1
        endif
        let yes = repeat("\<Down>", n). '\<C-Y>'
        let key = '\<C-R>=g:vimim()\<CR>'
        let s:has_pumvisible = 1
        if s:mode.onekey && s:hit_and_run
            let key = yes . s:vimim_stop()
        elseif s:mode.onekey && s:vimim_cjk() && a:key =~ '\d'
            let s:hjkl_n .= a:key  " 1234567890 as filter
        else
            let key = yes . key
            sil!call s:vimim_reset_after_insert()
        endif
    elseif s:mode.windowless && key =~ '\d'
        if s:pattern_not_found
            let s:pattern_not_found = 0
        else
            let key = s:vimim_windowless(key)
        endif
    endif
    sil!exe 'sil!return "' . key . '"'
endfunction

function! g:vimim_page(key)
    let key = a:key
    if pumvisible()
        if key =~ '[][]'
            let left  = key == "]" ? "\<Left>"  : ""
            let right = key == "]" ? "\<Right>" : ""
            let _ = key == "]" ? 0 : -1
            let backspace  = '\<C-R>=g:vimim_bracket('._.')\<CR>'
            let key = '\<C-Y>' . left . backspace . right
        elseif key =~ '[=.]'
            let s:pageup_pagedown = &pumheight ? 1 : 0
            let key = &pumheight ? g:vimim() : '\<PageDown>'
        elseif key =~ '[-,]'
            let key = &pumheight ? g:vimim() : '\<PageUp>'
            let s:pageup_pagedown = &pumheight ? -1 : 0
        endif
    elseif empty(s:mode.onekey) && key =~ "[][=-]"
        let key = g:vimim_punctuations(key)
    endif
    sil!exe 'sil!return "' . key . '"'
endfunction

function! g:wubi()
    let key = pumvisible() || s:mode.windowless ? '\<C-E>' : ""
    if s:wubi && empty(len(get(split(s:keyboard),0))%4)
        let key = pumvisible() ? '\<C-Y>' : s:mode.windowless ? "" : key
    endif
    let key = s:smart_enter ? '' : key
    sil!exe 'sil!return "' . key . '"'
endfunction

function! g:vimim_hjkl(key)
    let key = a:key
    if pumvisible()
            if key ==# 'n' | call s:vimim_reset_after_insert()
        elseif key ==# 'm' | let s:hjkl_m += 1
        elseif key ==# 'h' | let s:hjkl_h += 1   " h
        elseif key ==# 'j' | let key = '\<Down>' " j
        elseif key ==# 'k' | let key = '\<Up>'   " k
        elseif key ==# 'l' | let s:hjkl_l += 1   " l
        elseif key ==# 's' | let s:hjkl__ += 1   " s/t transfer
        elseif key =~ "[/?]"
            let key = '\<C-Y>\<C-R>=g:vimim_slash()\<CR>' . key . '\<CR>'
        elseif match(s:qwer, key) > -1
            let s:hjkl_n .= match(s:qwer, key)
        endif
        let key = key == a:key ? '\<C-R>=g:vimim()\<CR>' : key
    endif
    sil!exe 'sil!return "' . key . '"'
endfunction

function! s:vimim_punctuations_maps()
    if g:vimim_punctuation < 0
        return
    endif
    for _ in keys(s:all_evils)
        if _ !~ s:valid_keyboard
            exe 'lnoremap <expr> '._.' g:vimim_punctuations("'._.'")'
        endif
    endfor
    if empty(s:ui.quote)
        lnoremap ' <C-R>=g:vimim_single_quote()<CR>
    endif
    lnoremap " <C-R>=g:vimim_double_quote()<CR>
    lnoremap <Bslash> <C-R>=g:vimim_bslash()<CR>
endfunction

function! g:vimim_punctuations(key)
    let key = a:key
    if s:toggle_punctuation > 0
        if pumvisible() || s:vimim_byte_before() !~ '\w'
            if has_key(s:punctuations, a:key)
                let key = s:punctuations[a:key]
            endif
        endif
    endif
    if pumvisible()        " the 2nd choice
        let key = a:key == ";" ? '\<C-N>\<C-Y>' : '\<C-Y>' . key
    endif
    sil!exe 'sil!return "' . key . '"'
endfunction

function! g:vimim_single_quote()
    let key = "'"
    if pumvisible()       " the 3rd choice
        let key = '\<C-N>\<C-N>\<C-Y>'
    elseif g:vimim_punctuation < 3 && (s:mode.dynamic||s:mode.static)
        return key
    elseif s:toggle_punctuation > 0
        let pairs = split(s:key_evils[key], '\zs')
        let s:smart_quotes.single += 1
        let key = get(pairs, s:smart_quotes.single % 2)
    endif
    sil!exe 'sil!return "' . key . '"'
endfunction

function! g:vimim_double_quote()
    let key = '"'
    if g:vimim_punctuation < 3 && (s:mode.dynamic||s:mode.static)
        return key
    elseif s:toggle_punctuation > 0
        let pairs = split(s:key_evils[key], '\zs')
        let s:smart_quotes.double += 1
        let yes = pumvisible() ? '\<C-Y>' : ""
        let key = yes . get(pairs, s:smart_quotes.double % 2)
    endif
    sil!exe 'sil!return "' . key . '"'
endfunction

function! g:vimim_bslash()
    let key = '\'
    if g:vimim_punctuation < 3 && (s:mode.dynamic||s:mode.static)
        return key
    elseif s:toggle_punctuation > 0
        let yes = pumvisible() ? '\<C-Y>' : ""
        let key = yes . s:key_evils[key]
    endif
    sil!exe 'sil!return "' . key . '"'
endfunction

" ============================================= }}}
let s:VimIM += [" ====  mode: windowless ==== {{{"]
" =================================================

function! g:vimim_gi()
    let s:mode = {'onekey':0,'windowless':1,'dynamic':0,'static':0}
    call s:vimim_title()
    sil!exe 'sil!return "' . s:vimim_start() . '"'
endfunction

function! g:vimim_tab()
    " (1) Tab in insert mode => Tab is Tab if Tab
    " (2) Tab in insert mode => start windowless
    " (3) Tab in lmap   mode => start print out fine menu
    let tab = "\t"
    if empty(s:vimim_byte_before())
    elseif pumvisible() || s:lmap
        let tab = s:vimim_screenshot()
    else
        let tab = g:vimim_gi() . s:vimim_onekey_action()
    endif
    sil!exe 'sil!return "' . tab . '"'
endfunction

function! s:vimim_windowless(key)
    let key = a:key         " workaround to detect if active completion
    if s:pattern_not_found  " gi \bslash space space
        " make space smart  " gi ma space enter space
    elseif s:smart_enter    " gi ma space enter 77 ma space
        let s:smart_enter = 0
        let s:seamless_positions = []       " gi 5stroke space 8
    elseif !empty(s:vimim_char_before()) || s:keyboard =~ " "
        let key = empty(len(a:key)) ? '\<C-N>' : '\<C-E>\<C-X>\<C-O>'
        let cursor = empty(len(a:key)) ? 1 : a:key < 1 ? 9 : a:key-1
        if s:vimim_cjk()
            let s:hjkl_n .= a:key   " 1234567890 for windowless filter
        else
            if a:key =~ '[02-9]'    "  234567890 for windowless choice
                let key = repeat('\<C-N>', cursor)
            endif
        endif
        call s:vimim_set_titlestring(cursor)
    else
        let s:hjkl_n = ""
    endif
    sil!exe 'sil!return "' . key . '"'
endfunction

function! s:vimim_title()
    let titlestring = s:logo . s:vimim_get_title()
    if s:mode.windowless && empty(s:touch_me_not)
        let titlestring .= s:today
    endif
    if &term == 'screen'
        echo titlestring
    else  " if terminal can set window titles: all GUI versions
        let &titlestring = titlestring
        :redraw
    endif
endfunction

function! s:vimim_set_titlestring(cursor)
    let west = s:all_evils['[']
    let east = s:all_evils[']']
    let titlestring = substitute(&titlestring,west.'\|'.east,' ','g')
    if titlestring !~ '\s\+' . "'" . '\+\s\+'
        let titlestring = substitute(titlestring,"'",'','g')
    endif
    let words = split(titlestring)[1:]
    let cursor = s:cursor_at_windowless + a:cursor
    let hightlight = get(words, cursor)
    if !empty(hightlight) && len(words) > 1
        let west  = join(words[1 : cursor-1]) . west
        let east .= join(words[cursor+1 :])
        let s:cursor_at_windowless = cursor
        let keyboard = get(words,0)=='0' ? "" : get(words,0)
        let title = keyboard .'  '. west . hightlight . east
        let &titlestring = "VimIM" . s:vimim_get_title() .' '. title
    endif
endfunction

function! g:vimim_pagedown()
    let key = ' '
    if pumvisible()
        let s:pageup_pagedown = &pumheight ? 1 : 0
        let key = &pumheight ? g:vimim() : '\<PageDown>'
    endif
    sil!exe 'sil!return "' . key . '"'
endfunction

function! g:vimim_space()
    " (1) Space after English (valid keys) => trigger keycode menu
    " (2) Space after English punctuation  => get Chinese punctuation
    " (3) Space after popup menu           => insert Chinese
    " (4) Space after pattern not found    => Space
    let space = " "
    let s:has_pumvisible = 0
    if pumvisible()
        let s:has_pumvisible = 1
        let space = '\<C-R>=g:vimim()\<CR>'
        if s:mode.onekey && s:hit_and_run
             let space = s:vimim_stop()
        endif
        let cursor = s:mode.static ? '\<C-P>\<C-N>' : ''
        let space = cursor . '\<C-Y>' . space
    elseif s:pattern_not_found
    elseif s:mode.dynamic
    elseif s:mode.static
        if s:vimim_byte_before() =~# s:valid_keyboard
            let space = g:vimim()
        endif
    elseif s:seamless_positions == getpos(".")
        let s:smart_enter = 0  " Space is Space after Enter
    else
        let space = s:vimim_onekey_action()
    endif
    call s:vimim_reset_after_insert()
    sil!exe 'sil!return "' . space . '"'
endfunction

function! g:vimim_enter()
    let key = ""
    if pumvisible()
        let key = "\<C-E>"
        let s:smart_enter = 1 " single Enter after English => seamless
    elseif s:mode.windowless || s:vimim_byte_before() =~ s:valid_keyboard
        let s:smart_enter = 1
        if s:seamless_positions == getpos(".")
            let s:smart_enter += 1
        endif
    else
        let s:smart_enter = 0
    endif
    if s:smart_enter == 1
        let s:seamless_positions = getpos(".")
    else
        let key = "\<CR>"     " Enter is Enter after Enter
        let s:smart_enter = 0
    endif
    call s:vimim_title()
    sil!exe 'sil!return "' . key . '"'
endfunction

function! g:vimim_esc()
    let esc = '\<Esc>'
    if s:mode.onekey || s:mode.windowless
        :y
        if has("gui_running") && has("win32")
            sil!let @+ = @0[:-2]  " copy to clipboard and window title
        endif
        let esc = s:vimim_stop() . esc
        let &titlestring = s:space . @0[:-2]
    elseif pumvisible() && g:vimim_mode =~ 'esc'
        let esc = g:vimim_correction() " use <Esc> as one key correction
    endif
    sil!exe 'sil!return "' . esc . '"'
endfunction

function! g:vimim_correction()
    let key = '\<C-U>'  " :help i_CTRL-U  Delete all entered characters
    if pumvisible()
        let range = col(".") - 1 - s:starts.column
        if range
            let key = '\<C-E>' . repeat("\<Left>\<Delete>", range)
        endif
    elseif s:mode.windowless
        let s:smart_enter = "windowless_correction"
        let key = '\<C-E>\<C-R>=g:vimim()\<CR>\<Left>\<Delete>'
        call s:vimim_title()
    endif
    sil!call s:vimim_reset_after_insert()
    sil!exe 'sil!return "' . key . '"'
endfunction

function! g:vimim_backspace()
    let key = '\<Left>\<Delete>' " avoid special meaning of <BS> in omni
    if pumvisible()
        let key .= '\<C-R>=g:vimim()\<CR>'
    endif
    sil!exe 'sil!return "' . key . '"'
endfunction

function! g:vimim_windowless_or_halfwidth()
    let key = ""
    if s:mode.dynamic || s:mode.static
        let s:toggle_punctuation = (s:toggle_punctuation + 1) % 2
        sil!call s:vimim_set_statusline()
        sil!call s:vimim_punctuations_maps()
    elseif s:mode.windowless || s:mode.onekey
        let s:hit_and_run = 0
        let key = '\<C-E>'
        if s:mode.windowless
            let s:mode = {'onekey':1,'windowless':0,'dynamic':0,'static':0}
        elseif s:mode.onekey
            let s:mode = {'onekey':0,'windowless':1,'dynamic':0,'static':0}
            let key .= '\<C-R>=g:vimim()\<CR>'
        endif
    endif
    sil!call s:vimim_all_maps()
    sil!call s:vimim_title()
    sil!exe 'sil!return "' . key . '"'
endfunction

function! s:vimim_screenshot()
    let keyboard = get(split(s:keyboard),0)
    let space = repeat(" ", virtcol(".")-len(keyboard)-1)
    if s:keyboard =~ '^vim'
        let space = ""  " no need to format if it is egg
    elseif !empty(s:keyboard)
        call setline(".", keyboard)
    endif
    let saved_position = getpos(".")
    for items in s:popup_list
        let line = printf('%s', items.word)
        if has_key(items, "abbr")
            let line = printf('%s', items.abbr)
            if has_key(items, "menu")
                let line = printf('%s  %s', items.abbr, items.menu)
            endif
        endif
        put=space.line
    endfor
    call setpos(".", saved_position)
    sil!exe 'sil!return "' . g:vimim_esc() . '"'
endfunction

" ============================================= }}}
let s:VimIM += [" ====  mode: onekey     ==== {{{"]
" =================================================

function! g:vimim_onekey()
    " (1) OneKey in insert mode => start omni popup mode
    " (2) OneKey in lmap   mode => close omni popup mode
    " (3) OneKey in omni window => start print out menu
    let onekey = ''
    if pumvisible()
        let onekey = s:vimim_screenshot()
    elseif empty(s:lmap)
        let onekey = s:vimim_start() . s:vimim_onekey_action()
    else
        let onekey = s:vimim_stop()
    endif
    sil!exe 'sil!return "' . onekey . '"'
endfunction

function! s:vimim_onekey_action()
    let onekey = s:vimim_onekey_evils()
    if empty(onekey)
        if s:vimim_byte_before() =~# s:valid_keyboard
            let onekey = g:vimim()
        elseif s:mode.windowless
            let onekey = s:vimim_windowless("")
        endif
    endif
    sil!exe 'sil!return "' . onekey . '"'
endfunction

function! s:vimim_onekey_evils()
    let onekey = ""  " punctuations can be made not so evil ..
    let one_before = s:vimim_byte_before()
    let two_before = getline(".")[col(".")-3]
    let onekey_evils = copy(s:all_evils)
    call extend(onekey_evils, s:key_evils)
    if getline(".")[col(".")-3 : col(".")-2] == ".."  " before_before
        " [game] dot dot => quotes => popup menu
        let three_before  = getline(".")[col(".")-4]
        if col(".") < 5 || empty(three_before) || three_before =~ '\s'
            let onekey = "''''''"   "  <=    .. plays mahjong
        elseif three_before =~ "[0-9a-z]"
            let onekey = "'''"      "  <=  xx.. plays hjkl_m
        else
            let onekey = "''"       "  <=  香.. plays same cjk
        endif
        let onekey = "\<BS>\<BS>" . onekey . '\<C-R>=g:vimim()\<CR>'
    elseif one_before == "'" && two_before =~ "[a-z']" " forced cloud
    elseif one_before =~ "[0-9a-z]"                    " nothing
    elseif two_before =~ "[0-9a-z]"
        let onekey = " "  " ma,space => ma, space
    elseif has_key(onekey_evils, one_before)
        for char in keys(onekey_evils)
            if two_before ==# char || two_before =~# '\u'
                return " " " no transfer if punctuation punctuation
            endif
        endfor
        let bs = onekey_evils[one_before] " make Chinese punctuation
        let bs = one_before == "'" ? g:vimim_single_quote() : bs
        let bs = one_before == '"' ? g:vimim_double_quote() : bs
        let onekey = "\<Left>\<Delete>" . bs
    endif
    sil!exe 'sil!return "' . onekey . '"'
endfunction

function! s:vimim_get_head_without_quote(keyboard)
    let keyboard = a:keyboard
    if keyboard =~ '\d' || s:ui.root == 'cloud'
        return keyboard
    endif
    if s:hjkl_m && s:hjkl_m % 2 || keyboard =~ '^\l\l\+'."'''".'$'
        " [shoupin] hjkl_m || sssss..  =>  sssss'''  =>  s's's's's
        let keyboard = substitute(keyboard, "'", "", 'g')
        let keyboard = join(split(keyboard,'\zs'), "'")
    endif
    if keyboard =~ "'" && keyboard[-1:] != "'"
        " [quote_by_quote] wo'you'yi'ge'meng
        let keyboards = split(keyboard,"'")
        let keyboard = get(keyboards,0)
        let tail = join(keyboards[1:],"'")
        let tail = len(tail) == 1 ? "'" . tail : tail
        let s:keyboard = keyboard . " " . tail
    endif
    return keyboard
endfunction

" ============================================= }}}
let s:VimIM += [" ====  mode: chinese    ==== {{{"]
" =================================================

function! g:vimim_chinese()
    let key = ""
    if empty(s:ui.frontends)
        return ""
    endif
    if g:vimim_mode =~ 'static'
        let s:mode = {'onekey':0,'windowless':0,'dynamic':0,'static':1}
    else
        let s:mode = {'onekey':0,'windowless':0,'dynamic':1,'static':0}
    endif
    let s:chinese_mode_switch = s:chinese_mode_switch ? 0 : 1
    return s:vimim_open_close(s:chinese_mode_switch)
endfunction

function! s:vimim_open_close(switch)
    let lmap = ""
    if a:switch
        let lmap = s:vimim_start()
        call s:vimim_title()
        call s:vimim_set_statusline()
    else
        let lmap = s:vimim_stop()
    endif
    sil!exe 'sil!return "' . lmap . '"'
endfunction

function! g:vimim_im_switch()
    let s:toggle_im += 1
    let switch = s:toggle_im % len(s:ui.frontends)
    let s:ui.root = get(get(s:ui.frontends, switch), 0)
    let s:ui.im   = get(get(s:ui.frontends, switch), 1)
    if s:ui.root == 'cloud' && s:ui.im != 'mycloud'
        let s:cloud = s:ui.im
    endif
    sil!return s:vimim_open_close(1)
endfunction

function! s:vimim_set_im_toggle_list()
    let toggle_list = []
    if g:vimim_toggle < 0
        let toggle_list = [get(s:ui.frontends,0)]
    elseif empty(g:vimim_toggle)
        let toggle_list = s:ui.frontends
    else
        for toggle in split(g:vimim_toggle, ",")
            for [root, im] in s:ui.frontends
                if toggle == im
                    call add(toggle_list, [root, im])
                endif
            endfor
        endfor
    endif
    if s:backend[s:ui.root][s:ui.im].name =~ "bsddb"
        let toggle_list = toggle_list[:2]  " one bsddb two clouds
    endif
    let s:ui.frontends = copy(toggle_list)
    let s:ui.root = get(get(s:ui.frontends,0), 0)
    let s:ui.im   = get(get(s:ui.frontends,0), 1)
endfunction

function! s:vimim_set_keyboard_list(column_start, keyboard)
    let s:starts.column = a:column_start
    if s:keyboard !~ '\S\s\S'
        let s:keyboard = a:keyboard
    endif
endfunction

function! s:vimim_get_seamless(current_positions)
    if empty(s:seamless_positions)
    \|| s:seamless_positions[0] != a:current_positions[0]
    \|| s:seamless_positions[1] != a:current_positions[1]
    \|| s:seamless_positions[3] != a:current_positions[3]
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
        if char !~ s:valid_keyboard
            return -1
        endif
    endfor
    let s:starts.row = s:seamless_positions[1]
    return seamless_column
endfunction

" ============================================= }}}
let s:VimIM += [" ====  input: visual    ==== {{{"]
" =================================================

function! g:vimim_visual()
    let key = ""
    let lines = split(getreg('"'), '\n')
    let line = get(lines,0)
    let space = "\<C-R>=repeat(' '," .string(virtcol("'<'")-2). ")\<CR>"
    if len(lines) == 1 && len(line) == s:multibyte
        " highlight one chinese => get antonym or number loop
        let results = s:vimim_imode_visual(line)
        if !empty(results)
            let key = "gvr" . get(results,0) . "ga"
        endif
        if s:vimim_cjk()
            let line = match(s:cjk.lines, "^".line)
            let &titlestring = s:space . get(s:cjk.lines,line)
        endif
    elseif match(lines,'\d') > -1 && join(lines) !~ '[^0-9[:blank:].]'
        call setpos(".", getpos("'>'"))  " vertical digit block =>
        let sum = eval(join(lines,'+'))  " count*average=summary
        let ave = printf("%.2f", 1.0*sum/len(lines))
        let line = substitute(ave."=".string(sum), '[.]0\+', '', 'g')
        let line = string(len(lines)) . '*' . line
        let key = "o^\<C-D>" . space . " " . line . "\<Esc>"
    else
        sil!call s:vimim_start()
        let visual = "\<C-^>" . "\<C-R>=g:vimim()\<CR>"
        if len(lines) < 2  " highlight multiple cjk => show property
            let s:seamless_positions = getpos("'<'")
            let chinese = get(split(line,'\zs'),0)
            let ddddd = char2nr(chinese) =~ '\d\d\d\d\d' ? "'''''" : line
            let key = "gvc" . ddddd . visual
        else               " highlighted block => play block with hjkl
            let key = "O^\<C-D>" . space . "''''" . visual
        endif
    endif
    return feedkeys(key,"n")
endfunction

function! s:vimim_imode_visual(char_before)
    let antonym = "，。 “” ‘’ （） 【】 〖〗 《》 金石 胜败 真假"
    if empty(s:loops)
        let items = []
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
        for loop in numbers + split(antonym)
            let loops = split(loop, '\zs')
            for i in range(len(loops))
                let j = i==len(loops)-1 ? 0 : i+1
                let s:loops[loops[i]] = loops[j]
            endfor
        endfor
    endif
    let results = []
    let char_before = a:char_before
    if has_key(s:loops, char_before)
        let start = char_before
        let next = ""
        while start != next
            let next = s:loops[char_before]
            call add(results, next)
            let char_before = next
        endwhile
    endif
    return results
endfunction

" ============================================= }}}
let s:VimIM += [" ====  input: number    ==== {{{"]
" =================================================

function! s:vimim_dictionary_numbers()
    let s:numbers = {}
    let s:numbers.1 = "一壹⑴①甲"
    let s:numbers.2 = "二贰⑵②乙"
    let s:numbers.3 = "三叁⑶③丙"
    let s:numbers.4 = "四肆⑷④丁"
    let s:numbers.5 = "五伍⑸⑤戊"
    let s:numbers.6 = "六陆⑹⑥己"
    let s:numbers.7 = "七柒⑺⑦庚"
    let s:numbers.8 = "八捌⑻⑧辛"
    let s:numbers.9 = "九玖⑼⑨壬"
    let s:numbers.0 = "〇零⑽⑩癸"
    let s:quantifiers = copy(s:numbers)
    let s:quantifiers.2 .= "两俩"
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
    let s:quantifiers.r = "日人"
    let s:quantifiers.s = "十拾时升艘扇首双所束手"
    let s:quantifiers.t = "天吨条头通堂趟台套桶筒贴"
    let s:quantifiers.w = "万位味碗窝晚微"
    let s:quantifiers.x = "席些项"
    let s:quantifiers.y = "月元叶亿"
    let s:quantifiers.z = "种只张株支总枝盏座阵桩尊则站幢宗兆"
    let s:loops = {}
endfunction

let s:translators = {}
function! s:translators.translate(english) dict
    let inputs = split(a:english)
    return join(map(inputs,'get(self.dict,tolower(v:val),v:val)'), '')
endfunction

function! s:vimim_imode_today_now(keyboard)
    let one  = " year sunday monday tuesday wednesday thursday"
    let one .= " friday saturday month day hour minute second"
    let two  = join(split("年 日 一 二 三 四 五 六"), " 星期")
    let two .= " 月 日 时 分 秒"
    let chinese = copy(s:translators)
    let chinese.dict = s:vimim_key_value_hash(one, two)
    let time  = strftime("%Y") . ' year  '
    let time .= strftime("%m") . ' month '
    let time .= strftime("%d") . ' day   '
    if a:keyboard ==# 'itoday'
        let time .= s:space .' '. strftime("%A")
    elseif a:keyboard ==# 'inow'
        let time .= strftime("%H") . ' hour   '
        let time .= strftime("%M") . ' minute '
        let time .= strftime("%S") . ' second '
    endif
    let filter = "substitute(" . 'v:val' . ",'^0','','')"
    return chinese.translate(join(map(split(time), filter)))
endfunction

function! s:vimim_imode_number(keyboard)
    let keyboard = a:keyboard
    let ii = keyboard[0:1] " sample: i88 ii88 isw8ql iisw8ql
    let keyboard = ii==#'ii' ? keyboard[2:] : keyboard[1:]
    let dddl = keyboard=~#'^\d*\l\{1}$' ? keyboard[:-2] : keyboard
    let number = ""
    let keyboards = split(dddl, '\ze')
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

" ============================================= }}}
let s:VimIM += [" ====  input: unicode   ==== {{{"]
" =================================================

function! s:vimim_i18n_read(line)
    let line = a:line
    if s:localization == 1
        return iconv(line, "chinese", "utf-8")
    elseif s:localization == 2
        return iconv(line, "utf-8", &enc)
    endif
    return line
endfunction

function! s:vimim_unicode_list(ddddd)
    let results = []
    if a:ddddd
        for i in range(99)
            call add(results, nr2char(a:ddddd+i))
        endfor
    endif
    return results
endfunction

function! s:vimim_get_unicode_ddddd(keyboard)
    let ddddd = 0
    if a:keyboard =~# '^u\x\{4}$'        "  u9f9f => 40863
        let ddddd = str2nr(a:keyboard[1:],16)
    elseif a:keyboard =~# '^\d\{5}$'     "  39532 => 39532
        let ddddd = str2nr(a:keyboard, 10)
    endif
    let max = &encoding=="utf-8" ? 19968+20902 : 0xffff
    if ddddd < 8080 || ddddd > max
        let ddddd = 0
    endif
    return ddddd
endfunction

function! s:vimim_unicode_to_utf8(xxxx)
    let utf8 = ''       " u808f => 32911 => e8828f
    let ddddd = str2nr(a:xxxx, 16)
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

function! s:vimim_url_xx_to_chinese(xx)
    let output = a:xx   " %E9%A6%AC => \xE9\xA6\xAC => 馬 u99AC
    if s:http_exe =~ 'libvimim'
        let output = libcall(s:http_exe, "do_unquote", output)
    else
        let pat = '%\(\x\x\)'
        let sub = '\=eval(''"\x''.submatch(1).''"'')'
        let output = substitute(output, pat, sub, 'g')
    endif
    return output
endfunction

function! s:vimim_char_before()
    if !empty(s:vimim_byte_before())
        let start = col(".") - 1 - s:multibyte
        let char_before = getline(".")[start : start+s:multibyte-1]
        if char_before !~ '[^\x00-\xff]'
        elseif match(values(s:all_evils),char_before) > -1
        else
            return char_before
        endif
    endif
    return ""
endfunction

function! s:vimim_byte_before()
    let one_before = getline(".")[col(".")-2]
    return  one_before =~ '\s' ? "" : one_before
endfunction

function! s:vimim_key_value_hash(single, double)
    let hash = {}
    let singles = split(a:single)
    let doubles = split(a:double)
    for i in range(len(singles))
        let hash[get(singles,i)] = get(doubles,i)
    endfor
    return hash
endfunction

function! s:vimim_rot13(keyboard)
    let a = "12345abcdefghijklmABCDEFGHIJKLM"
    let z = "98760nopqrstuvwxyzNOPQRSTUVWXYZ"
    return tr(a:keyboard, a.z, z.a)
endfunction

" ============================================= }}}
let s:VimIM += [" ====  input: cjk       ==== {{{"]
" =================================================

function! s:vimim_cjk()
    if empty(s:cjk.filename)
        return 0
    elseif empty(s:cjk.lines)
        let s:cjk.lines = s:vimim_readfile(s:cjk.filename)
        if len(s:cjk.lines) != 20902
            return 0
        endif
    endif
    return 1
endfunction

function! s:vimim_cjk_in_4corner(chinese, info)
    let digit_head = ""  " gi ma   马   =>   7712  <=>  mali 7 4
    let digit_tail = ""  " gi mali 马力 => 7 4002  <=>  mali74
    let chinese = substitute(a:chinese,'[\x00-\xff]','','g')
    for cjk in split(chinese, '\zs')
        let line = match(s:cjk.lines, "^" . cjk)
        if line > -1
            let values = split(get(s:cjk.lines, line))
            let digit_head .= get(values,1)[:0]
            let digit_tail  = get(values,1)[1:]
        endif
    endfor
    let digit = digit_head . digit_tail
    let pattern = "^" . s:hjkl_n
    if empty(a:info) && match(digit, pattern) < 0
        return 0
    endif
    return digit
endfunction

function! s:vimim_cjk_property(chinese)
    let ddddd = char2nr(a:chinese)
    let xxxx  = printf('u%04x', ddddd)
    let unicode = ddddd . s:space . xxxx
    if s:vimim_cjk()
        let unicode = repeat(s:space,3) . xxxx . s:space . ddddd
        let line = match(s:cjk.lines, "^" . a:chinese)
        if line > -1
            let values  = split(get(s:cjk.lines, line))
            let digit   = get(values, 1) . s:space
            let frequency = get(values, -1) !~ '\D' ? 1 : 0
            let pinyin  = join(frequency ? values[2:-2] : values[2:])
            let unicode = digit . xxxx . s:space . pinyin
        endif
    endif
    return unicode
endfunction

function! s:vimim_get_cjk_head(keyboard)
    let keyboard = a:keyboard
    let head = ""
    if empty(s:cjk.filename) || keyboard =~ "'"
        return ""
    elseif keyboard =~# '^i' && empty (s:english.line)
        let keyboard = s:vimim_qwertyuiop_1234567890(keyboard[1:])
    endif
    if s:touch_me_not || len(keyboard) == 1
        let head = keyboard
    elseif keyboard =~ '\d'
        if keyboard =~ '^\d' && keyboard !~ '\D'
            let head = keyboard
            if len(keyboard) > 4  " output is 7712 for input 77124002
                let head = s:vimim_get_head(keyboard, 4)
            endif
            let s:hjkl_n = empty(len(s:hjkl_n)) ? head : s:hjkl_n
        elseif keyboard =~# '^\l\+\d\+\>'
            let partition = match(keyboard,'\d')  " ma7 ma77 ma771
            let head = keyboard[0 : partition-1]  " mali in mali74
            let tail = keyboard[partition :]      "   74 in mali74
            if empty(s:vimim_get_pinyin(head)) && tail =~ '[1-4]'
                return keyboard  " pinyin with tone: ma1/ma2/ma3/ma4
            endif
            let s:hjkl_n = empty(len(s:hjkl_n)) ? tail : s:hjkl_n
        elseif keyboard =~# '^\l\+\d\+'  " wo23 for input wo23you40
            let partition = match(keyboard, '\(\l\+\d\+\)\@<=\D')
            let head = s:vimim_get_head(keyboard, partition)
        endif
    elseif empty(s:english.line) " muuqwxeyqpjeqqq => m7712x3610j3111
        if keyboard =~# '^\l' && len(keyboard)%5 < 1
            let llll = keyboard[1:4]        " awwwr/a2224 arrow color
            let dddd = s:vimim_qwertyuiop_1234567890(llll)
            if !empty(dddd)
                let keyboard = keyboard[0:0] . dddd . keyboard[5:-1]
                let head = s:vimim_get_head(keyboard, 5)
            endif
        else    " get single character from cjk
            let head = keyboard
        endif
    endif
    return head
endfunction

function! s:vimim_qwertyuiop_1234567890(keyboard)
    if a:keyboard =~ '\d'
        return ""   " 4corner shortcut: iuuqwuqew => 77127132
    endif
    let dddd = ""   " output is 7712 for input uuqw
    for char in split(a:keyboard, '\zs')
        let digit = match(s:qwer, char)
        if digit < 0
            return ""
        else
            let dddd .= digit
        endif
    endfor
    return dddd
endfunction

function! s:vimim_get_head(keyboard, partition)
    if a:partition < 0
        return a:keyboard
    endif
    let head = a:keyboard[0 : a:partition-1]
    if s:keyboard !~ '\S\s\S'
        let s:keyboard = head
        let tail = a:keyboard[a:partition : -1]
        if !empty(tail)
            let s:keyboard = head . " " . tail
        endif
    endif
    return head
endfunction

function! s:vimim_cjk_match(keyboard)
    let keyboard = a:keyboard
    if empty(keyboard) || empty(s:vimim_cjk())
        return []
    endif
    let grep_frequency = '.*' . '\s\d\+$'
    let grep = ""
    if keyboard =~ '\d'
        if keyboard =~# '^\l\l\+[1-4]\>' && empty(len(s:hjkl_n))
            let grep = keyboard . '[a-z ]'  " cjk pinyin: huan2hai2 yi1
        else
            let digit = ""
            if keyboard =~ '^\d\+' && keyboard !~ '[^0-9]'
                let digit = keyboard  " free style digit: 7 77 771 7712
            elseif keyboard =~# '^\l\+\d\+'
                " cjk free style input/search: ma7 ma77 ma771 ma7712
                let digit = substitute(keyboard,'\a','','g')
            endif
            if !empty(digit)
                let space = '\d\{' . string(4-len(digit)) . '}'
                let space = len(digit)==4 ? "" : space
                let grep = '\s\+' . digit . space . '\s'
                let alpha = substitute(keyboard,'\d','','g')
                if len(alpha)
                    let grep .= '\(\l\+\d\)\=' . alpha " le|yue: le4yue4
                elseif len(keyboard) == 1
                    let grep .= grep_frequency   " grep l|y: happy music
                endif
            endif
        endif
    elseif s:ui.im != 'mycloud'
        if len(keyboard) == 1   " one cjk by frequency y72/yue72 l72/le72
            let grep = '[ 0-9]' . keyboard . '\l*\d' . grep_frequency
            if keyboard == 'u'  "  214 standard unicode index
                let grep = ' u\( \|$\)'
            endif
        elseif keyboard =~# '^\l\+'
            " cjk multiple-char-list: /huan /hai /yet /huan2 /hai2
            let grep = '[ 0-9]' . keyboard . '[0-9]'
        endif
    endif
    let results = []
    if !empty(grep)
        let line = match(s:cjk.lines, grep)
        while line > -1
            let fields = split(get(s:cjk.lines, line))
            let frequency = get(fields,-1)=~'\l' ? 9999 : get(fields,-1)
            call add(results, get(fields,0) . ' ' . frequency)
            let line = match(s:cjk.lines, grep, line+1)
        endwhile
    endif
    if len(results)
        if keyboard != 'u'
            let results = sort(results, "s:vimim_sort_on_last")
        endif
        let filter = "strpart(" . 'v:val' . ", 0, s:multibyte)"
        call map(results, filter)
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
    if s:vimim_cjk() " quick and dirty way to transfer between Chinese
        exe a:firstline.",".a:lastline.'s/./\=s:vimim_1to1(submatch(0))'
    endif
endfunction

function! s:vimim_1to1(char)
    if a:char =~ '[\x00-\xff]'
        return a:char
    endif
    let grep = '^' . a:char
    let line = match(s:cjk.lines, grep, 0)
    if line < 0
        return a:char
    endif
    let values = split(get(s:cjk.lines, line))
    let traditional_chinese = get(split(get(values,0),'\zs'),1)
    return empty(traditional_chinese) ? a:char : traditional_chinese
endfunction

" ============================================= }}}
let s:VimIM += [" ====  input: english   ==== {{{"]
" =================================================

function! s:vimim_get_english(keyboard)
    if empty(s:english.filename)
        return ""     " english: obama/now/version/ice/o2
    elseif empty(s:english.lines)
        let s:english.lines = s:vimim_readfile(s:english.filename)
    endif             " [sql] select english from vimim.txt
    let grep = '^' . a:keyboard . '\s\+'
    let cursor = match(s:english.lines, grep)
    let keyboards = s:vimim_get_pinyin(a:keyboard)
    if cursor < 0 && len(a:keyboard) > 3 && len(keyboards)
        let grep = '^' . get(split(a:keyboard,'\d'),0) " mxj7 => mxj
        let cursor = match(s:english.lines, grep)
    endif
    let oneline = ""  " [pinyin]  cong  => cong
    if cursor > -1    " [english] congr => congratulation
        let oneline = get(s:english.lines, cursor)
        if a:keyboard != get(split(oneline),0)
            let pairs = split(oneline)   " haag haagendazs
            let oneline = join(pairs[1:] + pairs[:0])
            let oneline = a:keyboard . " " . oneline
        endif
    endif
    return oneline
endfunction

function! s:vimim_filereadable(file)
    let full_path_datafile = s:plugin . a:file
    if filereadable(full_path_datafile)
        return full_path_datafile
    endif
    return ""
endfunction

function! s:vimim_readfile(datafile)
    let lines = []
    if filereadable(a:datafile)
        if s:localization
            for line in readfile(a:datafile)
                call add(lines, s:vimim_i18n_read(line))
            endfor
        else
            return readfile(a:datafile)
        endif
    endif
    return lines
endfunction

" ============================================= }}}
let s:VimIM += [" ====  input: pinyin    ==== {{{"]
" =================================================

function! s:vimim_get_all_valid_pinyin_list()
return split(" 'a 'ai 'an 'ang 'ao ba bai ban bang bao bei ben beng bi
\ bian biao bie bin bing bo bu ca cai can cang cao ce cen ceng cha chai
\ chan chang chao che chen cheng chi chong chou chu chua chuai chuan
\ chuang chui chun chuo ci cong cou cu cuan cui cun cuo da dai dan dang
\ dao de dei deng di dia dian diao die ding diu dong dou du duan dui dun
\ duo 'e 'ei 'en 'er fa fan fang fe fei fen feng fiao fo fou fu ga gai
\ gan gang gao ge gei gen geng gong gou gu gua guai guan guang gui gun
\ guo ha hai han hang hao he hei hen heng hong hou hu hua huai huan huang
\ hui hun huo 'i ji jia jian jiang jiao jie jin jing jiong jiu ju juan
\ jue jun ka kai kan kang kao ke ken keng kong kou ku kua kuai kuan kuang
\ kui kun kuo la lai lan lang lao le lei leng li lia lian liang liao lie
\ lin ling liu long lou lu luan lue lun luo lv ma mai man mang mao me mei
\ men meng mi mian miao mie min ming miu mo mou mu na nai nan nang nao ne
\ nei nen neng 'ng ni nian niang niao nie nin ning niu nong nou nu nuan
\ nue nuo nv 'o 'ou pa pai pan pang pao pei pen peng pi pian piao pie pin
\ ping po pou pu qi qia qian qiang qiao qie qin qing qiong qiu qu quan
\ que qun ran rang rao re ren reng ri rong rou ru ruan rui run ruo sa sai
\ san sang sao se sen seng sha shai shan shang shao she shei shen sheng
\ shi shou shu shua shuai shuan shuang shui shun shuo si song sou su suan
\ sui sun suo ta tai tan tang tao te teng ti tian tiao tie ting tong tou
\ tu tuan tui tun tuo 'u 'v wa wai wan wang wei wen weng wo wu xi xia
\ xian xiang xiao xie xin xing xiong xiu xu xuan xue xun ya yan yang yao
\ ye yi yin ying yo yong you yu yuan yue yun za zai zan zang zao ze zei
\ zen zeng zha zhai zhan zhang zhao zhe zhen zheng zhi zhong zhou zhu
\ zhua zhuai zhuan zhuang zhui zhun zhuo zi zong zou zu zuan zui zun zuo")
endfunction

function! s:vimim_quanpin_transform(pinyin)
    if empty(s:quanpin_table)
        for key in s:vimim_get_all_valid_pinyin_list()
            if key[0] == "'"
                let s:quanpin_table[key[1:]] = key[1:]
            else
                let s:quanpin_table[key] = key
            endif
        endfor
        for shengmu in s:shengmu_list + split("zh ch sh")
            let s:quanpin_table[shengmu] = shengmu
        endfor
    endif
    let item = a:pinyin
    let lenitem = len(item)
    let pinyinstr = ""
    let index = 0   " follow ibus rule, plus special case for fan'guo
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
                let tempstr  = item[end-1 : end]
                let tempstr2 = item[end-2 : end+1]
                let tempstr3 = item[end-1 : end+1]
                let tempstr4 = item[end-1 : end+2]
                if (tempstr == "ge" && tempstr3 != "ger")
                \ || (tempstr == "ne" && tempstr3 != "ner")
                \ || (tempstr4 == "gong" || tempstr3 == "gou")
                \ || (tempstr4 == "nong" || tempstr3 == "nou")
                \ || (tempstr  == "ga"   || tempstr == "na")
                \ ||  tempstr2 == "ier"  || tempstr == "ni"
                \ ||  tempstr == "gu"    || tempstr == "nu"
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
    return pinyinstr[0] == "'" ? pinyinstr[1:] : pinyinstr
endfunction

function! s:vimim_more_pinyin_datafile(keyboard, sentence)
    let candidates = s:vimim_more_pinyin_candidates(a:keyboard)
    if empty(candidates) || s:ui.im !~ 'pinyin'
        return []
    endif
    let results = []
    let backend = s:backend[s:ui.root][s:ui.im]
    for candidate in candidates
        let pattern = '^' . candidate . '\>'
        let cursor = match(backend.lines, pattern, 0)
        if cursor < 0
            continue
        elseif a:sentence
            return [candidate]
        endif
        let oneline = get(backend.lines, cursor)
        call extend(results, s:vimim_make_pairs(oneline))
    endfor
    return results
endfunction

function! s:vimim_get_pinyin(keyboard)
    let keyboard = s:vimim_quanpin_transform(a:keyboard)
    let results = split(keyboard, "'")
    if len(results) > 1
        return results
    endif
    return []
endfunction

function! s:vimim_more_pinyin_candidates(keyboard)
    if !empty(g:vimim_shuangpin) || len(s:english.line)
        return []
    endif
    let candidates = []  " make layout:  mamahuhu => mamahu, mama
    let keyboards = s:vimim_get_pinyin(a:keyboard)
    if len(keyboards)
        for i in reverse(range(len(keyboards)-1))
            let candidate = join(keyboards[0 : i], "")
            if !empty(candidate)
                call add(candidates, candidate)
            endif
        endfor
        if len(candidates) > 2
            let candidates = candidates[0 : len(candidates)-2]
        endif
    endif
    return candidates
endfunction

function! s:vimim_cloud_pinyin(keyboard, match_list)
    let match_list = []
    let keyboards = s:vimim_get_pinyin(a:keyboard)
    for chinese in a:match_list
        let len_chinese = len(split(chinese,'\zs'))
        let english = join(keyboards[len_chinese :], "")
        let pair = empty(english) ? chinese : chinese.english
        call add(match_list, pair)
    endfor
    return match_list
endfunction

" ============================================= }}}
let s:VimIM += [" ====  input: shuangpin ==== {{{"]
" =================================================

function! s:vimim_shuangpin_generic()
    let shengmu_list = {}   " generate shuangpin table default value
    for shengmu in s:shengmu_list
        let shengmu_list[shengmu] = shengmu
    endfor
    let shengmu_list["'"] = "o"
    let yunmu_list = {}
    for yunmu in split("a o e i u v")
        let yunmu_list[yunmu] = yunmu
    endfor
    return [shengmu_list, yunmu_list]
endfunction

function! s:vimim_shuangpin_rules(shuangpin, rules)
    let rules = a:rules
    let key  = ' ou ei ang en iong ua er ng ia ie ing un uo in ue '
    let key .= ' uan iu uai ong eng iang ui ai an ao iao ian uang '
    let v = ''  " various value to almost the same key set
    if a:shuangpin == 'ms'         " test: viui => zhishi
        let v = 'b z h f s w r g w x ; p o n t r q y s g d v l j k c m d y'
        call extend(rules[0], { "zh" : "v", "ch" : "i", "sh" : "u" })
        let key .= 'v'  " microsoft shuangpin has one additional key
    elseif a:shuangpin == 'abc'    " test: vtpc => shuang pin
        let v = 'b q h f s d r g d x y n o c m p r c s g t m l j k z w t'
        call extend(rules[0], { "zh" : "a", "ch" : "e", "sh" : "v" })
    elseif a:shuangpin == 'nature' " test: woui => wo shi => i am
        let v = 'b z h f s w r g w x y p o n t r q y s g d v l j k c m d'
        call extend(rules[0], { "zh" : "v", "ch" : "i", "sh" : "u" })
    elseif a:shuangpin == 'plusplus'
        let v = 'p w g r y b q t b m q z o l x c n x y t h v s f d k j h'
        call extend(rules[0], { "zh" : "v", "ch" : "u", "sh" : "i" })
    elseif a:shuangpin == 'purple'
        let v = 'z k s w h x j t x d ; m o y n l j y h t g n p r q b f g'
        call extend(rules[0], { "zh" : "u", "ch" : "a", "sh" : "i" })
    elseif a:shuangpin == 'flypy'
        let v = 'z w h f s x r g x p k y o b t r q k s g l v d j c n m l'
        call extend(rules[0], { "zh" : "v", "ch" : "i", "sh" : "u" })
    endif
    call extend(rules[1], s:vimim_key_value_hash(key, v))
    return rules
endfunction

function! s:vimim_create_shuangpin_table(rules)
    let pinyin_list = s:vimim_get_all_valid_pinyin_list()
    let sptable = {}  " generate table for shengmu-yunmu pairs match
    for key in pinyin_list
        if key !~ "['a-z]*"
            continue
        endif
        let shengmu = key[0]
        let yunmu = key[1:]
        if key[1] == "h"
            let shengmu = key[:1]
            let yunmu = key[2:]
        endif
        if has_key(a:rules[0], shengmu)
            let shuangpin_shengmu = a:rules[0][shengmu]
        else
            continue
        endif
        if has_key(a:rules[1], yunmu)
            let shuangpin_yunmu = a:rules[1][yunmu]
        else
            continue
        endif
        let sp1 = shuangpin_shengmu.shuangpin_yunmu
        if !has_key(sptable, sp1)
            let sptable[sp1] = key[0] == "'" ? key[1:] : key
        endif
    endfor
    if match(split("abc purple nature flypy"), g:vimim_shuangpin) > -1
        let jxqy = {"jv" : "ju", "qv" : "qu", "xv" : "xu", "yv" : "yu"}
        call extend(sptable, jxqy)
    elseif g:vimim_shuangpin == 'ms' " jxqy+v special case handling
        let jxqy = {"jv" : "jue", "qv" : "que", "xv" : "xue", "yv" : "yue"}
        call extend(sptable, jxqy)
    endif
    if g:vimim_shuangpin == 'flypy'  " flypy special case handling
        let key   = 'ou eg  er an ao ai aa en oo os  ah  ee ei'
        let value = 'ou eng er an ao ai a  en o  ong ang e  ei'
        call extend(sptable, s:vimim_key_value_hash(key, value))
    endif
    if g:vimim_shuangpin == 'nature' " nature special case handling
        let nature = {"aa" : "a", "oo" : "o", "ee" : "e" }
        call extend(sptable, nature)
    endif
    for [key, value] in items(a:rules[0])
        let sptable[value] = key  " table for shengmu-only match
        if key[0] == "'"
            let sptable[value] = ""
        endif
    endfor
    return sptable
endfunction

function! s:vimim_shuangpin_transform(keyboard)
    let size = strlen(a:keyboard)
    let ptr = 0
    let output = ""
    let bchar = ""    " workaround for sogou
    while ptr < size
        if a:keyboard[ptr] !~ "[a-z;]"   "  bypass all non-characters
            let output .= a:keyboard[ptr]
            let ptr += 1
        else
            let sp1 = a:keyboard[ptr]
            if a:keyboard[ptr+1] =~ "[a-z;]"
                let sp1 .= a:keyboard[ptr+1]
            endif
            if has_key(s:shuangpin_table, sp1)
                let output .= bchar . s:shuangpin_table[sp1]
            else    " the last odd shuangpin code as only shengmu
                let output .= sp1 " invalid shuangpin code are preserved
            endif
            let ptr += strlen(sp1)
        endif
    endwhile
    return output[0] == "'" ? output[1:] : output
endfunction

" ============================================= }}}
let s:VimIM += [" ====  python2 python3  ==== {{{"]
" =================================================

function! g:vimim_gmail() range abort
" [dream] one click to send email from within the current vim buffer
" [usage] :call g:vimim_gmail()
" [vimrc] :let  g:gmails={'login':'x','passwd':'x','to':'x','bcc':'x'}
if empty(has('python')) && empty(has('python3'))
    echo 'No magic Python Interface to Vim' | return ""
endif
let firstline = a:firstline
let  lastline = a:lastline
if lastline - firstline < 1
    let firstline = 1
    let lastline = "$"
endif
let g:gmails.msg = getline(firstline, lastline)
let python = has('python3') && &relativenumber ? 'python3' : 'python'
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

function! s:vimim_initialize_bsddb(datafile)
:sil!python << EOF
import vim
encoding = vim.eval("&encoding")
datafile = vim.eval('a:datafile')
try:
    import bsddb3 as bsddb
except ImportError:
    import bsddb as bsddb
edw = bsddb.btopen(datafile,'r')
def getstone(stone):
    if stone not in edw:
        while stone and stone not in edw: stone = stone[:-1]
    return stone
def getgold(stone):
    gold = stone
    if stone and stone in edw:
         gold = edw.get(stone)
         if encoding == 'utf-8':
               if datafile.find("gbk"):
                   gold = unicode(gold,'gb18030','ignore')
                   gold = gold.encode(encoding,'ignore')
    gold = stone + ' ' + gold
    return gold
EOF
endfunction

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

function! s:vimim_get_from_python2(input, cloud)
:sil!python << EOF
import vim, urllib2, socket
cloud = vim.eval('a:cloud')
input = vim.eval('a:input')
encoding = vim.eval("&encoding")
try:
    socket.setdefaulttimeout(20)
    urlopen = urllib2.urlopen(input, None)
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

function! s:vimim_mycloud_python_client(cmd)
:sil!python << EOF
try:
    cmd  = vim.eval("a:cmd")
    HOST = vim.eval("s:mycloud_host")
    PORT = int(vim.eval("s:mycloud_port"))
    ret = parsefunc(cmd, HOST, PORT)
    vim.command('return "%s"' % ret)
except vim.error:
    print("vim error: %s" % vim.error)
EOF
endfunction

" ============================================= }}}
let s:VimIM += [" ====  backend: file    ==== {{{"]
" =================================================

function! s:vimim_set_datafile(im, datafile)
    let im = a:im
    if isdirectory(a:datafile)
        return
    elseif im =~ '^wubi'   | let im = 'wubi'
    elseif im =~ '^pinyin' | let im = 'pinyin' | endif
    let s:ui.root = 'datafile'
    let s:ui.im = im
    call insert(s:ui.frontends, [s:ui.root, s:ui.im])
    let s:backend.datafile[im] = {}
    let s:backend.datafile[im].root = s:ui.root
    let s:backend.datafile[im].im = s:ui.im
    let s:backend.datafile[im].name = a:datafile
    let s:backend.datafile[im].keycode = s:keycodes[im]
    let s:backend.datafile[im].chinese = s:chinese(im)
    let s:backend.datafile[im].lines = []
endfunction

function! s:vimim_sentence_datafile(keyboard)
    let backend = s:backend[s:ui.root][s:ui.im]
    let fuzzy = s:ui.im =~ 'pinyin' ? ' ' : ""
    let pattern = '^\V' . a:keyboard . fuzzy
    let cursor = match(backend.lines, pattern)
    if cursor > -1
        return a:keyboard
    endif
    let candidates = s:vimim_more_pinyin_datafile(a:keyboard,1)
    if !empty(candidates)
        return get(candidates,0)
    endif
    let max = len(a:keyboard)
    while max > 1
        let max -= 1
        let pattern = '^\V' . strpart(a:keyboard,0,max) . ' '
        let cursor = match(backend.lines, pattern)
        if cursor > -1
            break
        endif
    endwhile
    return cursor < 0 ? "" : a:keyboard[: max-1]
endfunction

function! s:vimim_get_from_datafile(keyboard)
    let fuzzy = s:ui.im =~ 'pinyin' ? ' ' : ""
    let pattern = '^\V' . a:keyboard . fuzzy
    let backend = s:backend[s:ui.root][s:ui.im]
    let cursor = match(backend.lines, pattern)
    if cursor < 0
        return []
    endif
    let oneline = get(backend.lines, cursor)
    let results = split(oneline)[1:]
    if len(s:english.line) || len(results) > 10
        return results
    endif
    if s:ui.im =~ 'pinyin'
        let extras = s:vimim_more_pinyin_datafile(a:keyboard,0)
        if len(extras)
            let results = s:vimim_make_pairs(oneline)
            call extend(results, extras)
        endif
    else  " http://code.google.com/p/vimim/issues/detail?id=121
        let results = []
        let s:show_extra_menu = 1
        for i in range(10)
            let cursor += i     " get more if less
            let oneline = get(backend.lines, cursor)
            let extras = s:vimim_make_pairs(oneline)
            call extend(results, extras)
        endfor
    endif
    return results
endfunction

function! s:vimim_get_from_database(keyboard)
    let oneline = s:vimim_get_gold_from_bsddb(a:keyboard)
    if empty(oneline) " || get(split(oneline),1) =~ '\w'
        return []
    endif
    let results = s:vimim_make_pairs(oneline)
    if empty(s:english.line) && len(results) && len(results) < 20
        let candidates = s:vimim_more_pinyin_candidates(a:keyboard)
        if len(candidates) < 2
            return results
        endif
        for candidate in candidates
            let oneline = s:vimim_get_gold_from_bsddb(candidate)
            if empty(oneline) || match(oneline,' ') < 0
                continue
            endif
            let match_list = s:vimim_make_pairs(oneline)
            if !empty(match_list)
                call extend(results, match_list)
            endif
            if len(results) > 20 * 2
                break
            endif
        endfor
    endif
    return results
endfunction

function! s:vimim_make_pairs(oneline)
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
let s:VimIM += [" ====  backend: dir     ==== {{{"]
" =================================================

function! s:vimim_set_directory(dir)
    let im = "pinyin"
    let s:ui.root = 'directory'
    let s:ui.im = im
    call insert(s:ui.frontends, [s:ui.root, s:ui.im])
    let s:backend.directory[im] = {}
    let s:backend.directory[im].root = s:ui.root
    let s:backend.directory[im].im = im
    let s:backend.directory[im].name = a:dir
    let s:backend.directory[im].keycode = s:keycodes[im]
    let s:backend.directory[im].chinese = s:chinese(im)
endfunction

function! s:vimim_sentence_directory(keyboard, directory)
    let filename = a:directory . a:keyboard
    if filereadable(filename)
        return a:keyboard
    endif
    let max = len(a:keyboard)
    while max > 1
        let max -= 1
        let head = strpart(a:keyboard, 0, max)
        let filename = a:directory . head
        " workaround: filereadable("/filename.") returns true
        if filereadable(filename) && head[-1:-1] != "."
            break
        endif
    endwhile
    return filereadable(filename) ? a:keyboard[: max-1] : ""
endfunction

function! s:vimim_more_directory(keyboard, dir)
    let candidates = s:vimim_more_pinyin_candidates(a:keyboard)
    if empty(candidates) || len(s:english.line)
        return []
    endif
    let results = []
    for candidate in candidates
        let lines = s:vimim_readfile(a:dir . candidate)
        if !empty(lines)
            call map(lines, 'candidate ." ". v:val')
            call extend(results, lines)
        endif
    endfor
    return results
endfunction

function! s:vimim_set_backend_embedded()
    let im = "pinyin"
    " (1/3) scan directory database, only for pinyin
    let dir = s:plugin . im
    if isdirectory(dir)
        let dir .= "/"
        if filereadable(dir . im)
            return s:vimim_set_directory(dir)
        endif
    endif
    " (2/3) scan bsddb database as edw: enterprise data warehouse
    if has("python") " bsddb is from Python 2 only with 46,694,400 Bytes
        let datafile = s:vimim_filereadable("vimim.gbk.bsddb")
        if !empty(datafile)
            return s:vimim_set_datafile(im, datafile)
        endif
    endif
    " (3/3) scan all supported data files, in order
    for im in s:all_vimim_input_methods
        let datafile = s:vimim_filereadable("vimim." . im . ".txt")
        if empty(datafile)
            let filename = "vimim." . im . "." . &encoding . ".txt"
            let datafile = s:vimim_filereadable(filename)
        endif
        if !empty(datafile)
            call s:vimim_set_datafile(im, datafile)
        endif
    endfor
endfunction

" ============================================= }}}
let s:VimIM += [" ====  backend: clouds  ==== {{{"]
" =================================================

function! s:vimim_set_background_clouds()
    let cloud_defaults = split(s:rc["g:vimim_cloud"],',')
    let s:cloud = get(cloud_defaults,0)
    if g:vimim_cloud < 0
        return
    endif
    let clouds = split(g:vimim_cloud,',')
    for cloud in clouds
        let cloud = get(split(cloud,'[.]'),0)
        call remove(cloud_defaults, match(cloud_defaults,cloud))
    endfor
    let clouds += cloud_defaults
    let g:vimim_cloud = join(clouds,',')
    let default = get(split(get(clouds,0),'[.]'),0)
    if match(s:rc["g:vimim_cloud"], default) > -1
        let s:cloud = default
    endif
    if !empty(s:vimim_check_http_executable())
        let s:ui.root = 'cloud'
        for cloud in reverse(split(g:vimim_cloud,','))
            let im = get(split(cloud,'[.]'),0)
            let s:ui.im = im
            call insert(s:ui.frontends, [s:ui.root, s:ui.im])
            let s:backend.cloud[im] = {}
            let s:backend.cloud[im].root = s:ui.root
            let s:backend.cloud[im].im = 0  " used for cloud key
            let s:backend.cloud[im].keycode = s:keycodes[im]
            let s:backend.cloud[im].name    = s:chinese(im)
            let s:backend.cloud[im].chinese = s:chinese(im)
        endfor
    endif
endfunction

function! s:vimim_check_http_executable()
    if g:vimim_cloud < 0 && len(g:vimim_mycloud) < 3
        return 0
    elseif len(s:http_exe) > 3
        return s:http_exe
    endif
    " step 1 of 4: try to find libvimim for mycloud
    let lib = has("win32") || has("win32unix") ? "dll" : "so"
    let libvimim = s:plugin . "libvimim." . lib
    if filereadable(libvimim)
        if has("win32") && libvimim[-4:] ==? ".dll"
            let libvimim = libvimim[:-5]
        endif
        if libcall(libvimim, "do_geturl", "__isvalid") ==# "True"
            let s:http_exe = libvimim
        endif
    endif
    " step 2 of 4: try to use dynamic python:
    if empty(s:http_exe)
        if has('python3') && &relativenumber  " +python3/dyn
            let s:http_exe = 'Python3 Interface to Vim'
        elseif has('python')                  " +python/dyn
            let s:http_exe = 'Python2 Interface to Vim'
        endif
    endif
    " step 3 of 4: try to find wget
    if empty(s:http_exe) || has("macunix")
        let wget_exe = s:plugin . 'wget.exe'
        let wget = filereadable(wget_exe) ? wget_exe : 'wget'
        if executable(wget)
            let wget_option = " -qO - --timeout 20 -t 10 "
            let s:http_exe = wget . wget_option
        endif
    endif
    " step 4 of 4: try to find curl if wget not available
    if empty(s:http_exe) && executable('curl')
        let s:http_exe = "curl -s "
    endif
    return s:http_exe
endfunction

function! s:vimim_get_cloud(keyboard, cloud)
    let keyboard = a:keyboard  " remove evil leading/trailing quote
    let keyboard = keyboard[:0]  == "'" ? keyboard[1:]  : keyboard
    let keyboard = keyboard[-1:] == "'" ? keyboard[:-2] : keyboard
    if keyboard !~ s:valid_keyboard || empty(a:cloud)
        return []
    endif
    let cloud = "s:vimim_get_cloud_" . a:cloud . "(keyboard)"
    let results = []
    try
        let results = eval(cloud)
    catch
        sil!call s:vimim_debug(a:cloud, v:exception)
    endtry
    if !empty(results) && s:keyboard !~ '\S\s\S'
        let s:keyboard = keyboard
    endif
    return results
endfunction

function! s:vimim_get_from_http(input, cloud)
    if empty(a:input) || empty(s:vimim_check_http_executable())
        return ""
    endif
    try
        if s:http_exe =~ 'Python3'
            return s:vimim_get_from_python3(a:input, a:cloud)
        elseif s:http_exe =~ 'Python2'
            return s:vimim_get_from_python2(a:input, a:cloud)
        elseif s:http_exe =~ 'libvimim'
            return libcall(s:http_exe, "do_geturl", a:input)
        elseif len(s:http_exe)
            return system(s:http_exe . shellescape(a:input))
        endif
    catch
        sil!call s:vimim_debug("s:http_exe exception", v:exception)
    endtry
    return ""
endfunction

function! s:vimim_get_cloud_sogou(keyboard)
    " http://web.pinyin.sogou.com/api/py?key=32&query=mxj
    if empty(s:backend.cloud.sogou.im)  " as cloud key
        let key_sogou = "http://web.pinyin.sogou.com/web_ime/patch.php"
        let output = s:vimim_get_from_http(key_sogou, 'sogou')
        let s:backend.cloud.sogou.im = get(split(output, '"'), 1)
    endif
    let input  = 'http://web.pinyin.sogou.com/api/py'
    let input .= '?key=' . s:backend.cloud.sogou.im
    let input .= '&query=' . a:keyboard
    let output = s:vimim_get_from_http(input, 'sogou')
    if empty(output) || output =~ '502 bad gateway'
        return []
    endif
    let first  = match(output, '"', 0)
    let second = match(output, '"', 0, 2)
    if first && second
        let output = strpart(output, first+1, second-first-1)
        let output = s:vimim_url_xx_to_chinese(output)
    endif
    if s:localization  " support gb and big5 in addition to utf8
        let output = s:vimim_i18n_read(output)
    endif
    let match_list = []
    for item in split(output, '\t+')
        let item_list = split(item, s:colon)
        if len(item_list) > 1
            let english = strpart(a:keyboard, 0, get(item_list,1))
            let english_chinese = english . " " . get(item_list,0)
            call add(match_list, english_chinese)
        endif
    endfor
    return match_list
endfunction

function! s:vimim_get_cloud_qq(keyboard)
    " http://ime.qq.com/fcgi-bin/getword?key=32&q=mxj
    let input = 'http://ime.qq.com/fcgi-bin/'
    if empty(s:backend.cloud.qq.im)  " as cloud key
        let output = s:vimim_get_from_http(input . 'getkey', 'qq')
        let s:backend.cloud.qq.im = get(split(output, '"'), 3)
    endif
    let clouds = split(g:vimim_cloud,',')      " qq.shuangpin.abc,google
    let vimim_cloud = get(clouds, match(clouds,'qq')) " qq.shuangpin.abc
    if vimim_cloud =~ 'wubi'
        let input .= 'gwb'
    else
        let input .= 'getword'
    endif
    let input .= '?key=' . s:backend.cloud.qq.im
    if vimim_cloud =~ 'fanti'
        let input .= '&jf=1'
    endif
    let md = vimim_cloud =~ 'mixture' ? 3 : 0
    if vimim_cloud =~ 'shuangpin'
        let md = 2  " qq.shuangpin.ms => ms
        let shuangpin = get(split(vimim_cloud,"[.]"), -1)
        let st = match(split(s:shuangpin),shuangpin) + 1
        if st
            let input .= '&st=' . st
        endif
    endif
    if md
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
    if s:localization  " qq => {'q':'fuck','rs':['\xe5\xa6\x87'],
        let output = s:vimim_i18n_read(output)
    endif
    let match_list = []
    let output_hash = eval(output)
    if type(output_hash) == type({}) && has_key(output_hash, 'rs')
        let match_list = output_hash['rs']  " as key
    endif
    if vimim_cloud !~ 'wubi' && vimim_cloud !~ 'shuangpin'
        let match_list = s:vimim_cloud_pinyin(a:keyboard, match_list)
    endif
    return match_list
endfunction

function! s:vimim_get_cloud_google(keyboard)
    " http://google.com/transliterate?tl_app=3&tlqt=1&num=20&text=mxj
    " http://translate.google.com/?sl=en&tl=zh-CN#en|zh-CN|fuck'
    let input  = 'http://www.google.com/transliterate/chinese'
    let input .= '?langpair=en|zh' . '&num=20' . '&tl_app=3'
    let input .= '&tlqt=1' . '&text=' . a:keyboard
    let output = join(split(s:vimim_get_from_http(input,'google')))
    let match_list = []
    if s:localization  " [{'ew':'fuck','hws':['\u5987\u4EA7\u79D1',]},]
        if s:http_exe =~ 'Python2'
            let output = s:vimim_i18n_read(output)
        else
            let unicodes = split(get(split(output),8),",")
            for item in unicodes
                let utf8 = ""
                for xxxx in split(item, "\u")
                    let utf8 .= s:vimim_unicode_to_utf8(xxxx)
                endfor
                let output = s:vimim_i18n_read(utf8)
                call add(match_list, output)
            endfor
            return match_list
        endif
    endif
    let output_hash = get(eval(output),0)
    if type(output_hash) == type({}) && has_key(output_hash, 'hws')
        let match_list = output_hash['hws']  " as key
    endif
    return s:vimim_cloud_pinyin(a:keyboard, match_list)
endfunction

function! s:vimim_get_cloud_baidu(keyboard)
    " http://olime.baidu.com/py?rn=0&pn=20&py=mxj
    let url = 'http://olime.baidu.com/py'
    let input = '?rn=0' . '&pn=20' . '&py=' . a:keyboard
    let output = s:vimim_get_from_http(url . input, 'baidu')
    let output_list = []
    if exists("g:baidu") && type(g:baidu) == type([])
        let output_list = get(g:baidu,0)
    endif
    if empty(output_list)
        if empty(output) || output =~ '502 bad gateway'
            return []
        elseif empty(s:localization)   " ['[[['\xc3\xb0\xcf\xd5',3]
            let output = iconv(output, "gbk", "utf-8")
        endif
        let output_list = get(eval(output),0)
    endif
    if type(output_list) != type([])
        return []
    endif
    let match_list = []
    for item_list in output_list
        let chinese = get(item_list,0)
        if chinese !~ '\w'
            let english = strpart(a:keyboard, get(item_list,1))
            call add(match_list, chinese . english)
        endif
    endfor
    return match_list
endfunction

function! s:vimim_get_all_clouds(keyboard)
    let results = []
    for cloud in split(s:rc["g:vimim_cloud"], ',')
        let start = reltime()
        let outputs = s:vimim_get_cloud(a:keyboard, cloud)
        if len(results) > 1
            call add(results, s:space)
        endif
        let title = s:chinese(s:space, cloud, 'cloud', s:space)
        call add(results, a:keyboard . title . reltimestr(reltime(start)))
        if len(outputs) > 1+1+1+1
            let outputs = &number ? outputs : outputs[0:9]
            let filter = "substitute(" . 'v:val' . ",'[a-z ]','','g')"
            call add(results, join(map(outputs,filter)))
        endif
    endfor
    return results
endfunction

" ============================================= }}}
let s:VimIM += [" ====  backend: mycloud ==== {{{"]
" =================================================

function! s:vimim_set_backend_mycloud()
    let s:mycloud_arg  = ""
    let s:mycloud_mode = ""
    let s:mycloud_func = "do_getlocal"
    let s:mycloud_host = "localhost"
    let s:mycloud_port = 10007
    if !empty(g:vimim_mycloud) && g:vimim_mycloud != -1
        let s:ui.root = 'cloud'
        let s:ui.im = 'mycloud'
        call insert(s:ui.frontends, [s:ui.root, s:ui.im])
        let s:backend.cloud.mycloud = {}
        let s:backend.cloud.mycloud.root = s:ui.root
        let s:backend.cloud.mycloud.name    = s:chinese(s:ui.im)
        let s:backend.cloud.mycloud.chinese = s:chinese(s:ui.im)
        let s:backend.cloud.mycloud.keycode = s:valid_keyboard
        let s:backend.cloud.mycloud.directory = s:ui.im
        let s:backend.cloud.mycloud.im = s:ui.im
    endif
endfunction

function! s:vimim_get_mycloud(keyboard)
    if s:mycloud_initialization < 0
        return []
    elseif s:mycloud_initialization < 1
        let s:mycloud_initialization = 1
        let mycloud = s:vimim_mycloud_set_and_play()
        if empty(mycloud)
            let s:mycloud_initialization = -1 " fail to start mycloud
            return []
        endif " set mycloud client with real data from mycloud server
        let s:backend.cloud.mycloud.im = mycloud
        let ret = s:vimim_access_mycloud("__getkeychars")
        let s:backend.cloud.mycloud.keycode = split(ret,"\t")[0]
        let ret = s:vimim_access_mycloud("__getname")
        let s:backend.cloud.mycloud.directory = split(ret,"\t")[0]
        call s:vimim_set_keycode()
    endif
    let output = s:vimim_access_mycloud(a:keyboard)
    if empty(output)
        return []
    endif
    let results = []
    for item in split(output, '\n')
        let item_list = split(item, '\t')
        let chinese = get(item_list,0)
        if s:localization
            let chinese = s:vimim_i18n_read(chinese)
        endif
        if empty(chinese) || get(item_list,1,-1) < 0
            continue  " bypass the breakpoint line which have -1
        endif
        let extra_text = get(item_list,2)
        let english = a:keyboard[get(item_list,1):]
        let new_item = extra_text . " " . chinese . english
        call add(results, new_item)
    endfor
    return results
endfunction

function! s:vimim_access_mycloud(cmd)
    let ret = ""
    let mycloud = s:backend.cloud.mycloud.im
    if s:mycloud_mode == "libcall"
        let cmd = empty(s:mycloud_arg) ? "" : s:mycloud_arg . " "
        let ret = libcall(mycloud, s:mycloud_func, cmd . a:cmd )
    elseif s:mycloud_mode == "python"
        let ret = s:vimim_mycloud_python_client(a:cmd)
    elseif s:mycloud_mode == "system"
        let ret = system(mycloud . " " . shellescape(a:cmd))
    elseif s:mycloud_mode == "www"
        let input = g:vimim_mycloud . s:vimim_rot13(a:cmd)
        if s:http_exe =~ 'libvimim'
            let ret = libcall(s:http_exe, "do_geturl", input)
        elseif len(s:http_exe)
            let ret = system(s:http_exe . shellescape(input))
        endif
        if len(ret)
            let output = s:vimim_rot13(ret)
            let ret = s:vimim_url_xx_to_chinese(output)
        endif
    endif
    return ret
endfunction

function! s:vimim_access_mycloud_isvalid(cloud)
    let ret = s:vimim_access_mycloud("__isvalid")
    if split(ret, "\t")[0] == "True"
        return 1
    endif
    return 0
endfunction

function! s:vimim_mycloud_set_and_play()
    let part = split(g:vimim_mycloud, ':')
    let lenpart = len(part)
    if lenpart <= 1
        sil!call s:vimim_debug('info', "invalid_cloud_plugin_url")
    elseif part[0] ==# 'py' && has("python")
        if lenpart > 2
            let s:mycloud_host = part[1]
            let s:mycloud_port = part[2]
        elseif lenpart > 1
            let s:mycloud_host = part[1]
        endif
        try
            call s:vimim_mycloud_python_init()
            let s:mycloud_mode = "python"
            if s:vimim_access_mycloud_isvalid(part[1])
                return "python"
            endif
        catch
            sil!call s:vimim_debug('python_mycloud=', v:exception)
        endtry
    elseif part[0] ==# 'app' && !has("gui_win32")
        if lenpart == 3
            let cloud = part[1] . ':' . part[2]
            if part[1][0] == '/'
                let cloud = part[1][1:] . ':' . part[2]
            endif
        elseif lenpart == 2
            let cloud = part[1]
        endif
        if executable(split(cloud, " ")[0])
            let s:mycloud_mode = "system"
            if s:vimim_access_mycloud_isvalid(cloud)
                return cloud
            endif
        endif
    elseif part[0] ==# "dll"
        let base = len(part[1]) == 1 ? 1 : 0
        if lenpart >= base+4
            let s:mycloud_func = part[base+3]
        endif
        let s:mycloud_arg = lenpart >= base+3 ? part[base+2] : ""
        let cloud = base == 1 ? part[1] . ':' . part[2] : part[1]
        if filereadable(cloud)
            let s:mycloud_mode = "libcall"
            if has("win32") && cloud[-4:] ==? ".dll"
                let cloud = cloud[:-5]  " strip off the .dll suffix
            endif
            if s:vimim_access_mycloud_isvalid(cloud)
                return cloud
            endif
        endif
    elseif part[0] ==# "http" || part[0] ==# "https"
        if !empty(s:vimim_check_http_executable())
            let s:mycloud_mode = "www"
            if s:vimim_access_mycloud_isvalid(g:vimim_mycloud)
                return g:vimim_mycloud
            endif
        endif
    else
        sil!call s:vimim_debug('alert', "invalid_cloud_plugin_url")
    endif
    return 0
endfunction

" ============================================= }}}
let s:VimIM += [" ====  /search          ==== {{{"]
" =================================================

function! g:vimim_search()
    let results = []
    let english = @/
    if len(english) > 1 && len(english) < 20 && english !~ "[^0-9a-z']"
    \&& v:errmsg =~# english && v:errmsg =~# '^E486: '
        try
            let results = s:vimim_search_chinese_by_english(english)
        catch
            sil!call s:vimim_debug('slash search /', v:exception)
        endtry
    endif
    if !empty(results)
        let results = split(substitute(join(results),'\w','','g'))
        call sort(results, "s:vimim_sort_on_length")
        let slash = join(results[0:9], '\|')
        let @/ = empty(search(slash,'nw')) ? english : slash
    endif
    echon "/" . english
    let v:errmsg = ""
endfunction

function! s:vimim_sort_on_length(i1, i2)
    return len(a:i2) - len(a:i1)
endfunc

function! s:vimim_search_chinese_by_english(keyboard)
    let keyboard = tolower(a:keyboard)
    let results = []
    " 1/3 first try search from mycloud or cloud if available
    if s:ui.im == 'mycloud'
        let results = s:vimim_get_mycloud(keyboard)
    elseif s:ui.root == 'cloud' || keyboard[-1:] == "'"
        let results = s:vimim_get_cloud(keyboard, s:cloud)
    endif
    if len(results) | return results | endif
    " 2/3 search unicode or cjk /search unicode /u808f
    let ddddd = s:vimim_get_unicode_ddddd(keyboard)
    if !empty(ddddd)
        let results = [nr2char(ddddd)]
    elseif s:vimim_cjk()
        while len(keyboard) > 1
            let head = s:vimim_get_cjk_head(keyboard)
            if empty(head)  " /muuqwxeyqpjeqqq
                break       " /m7712x3610j3111
            else            " /ma77xia36ji31
                let chinese = join(s:vimim_cjk_match(head), '')
                if !empty(chinese)
                    call add(results, "[" . chinese . "]")
                endif
                let keyboard = strpart(keyboard, len(head))
            endif
        endwhile
        let results = len(results) > 1 ? [join(results,'')] : results
    endif
    if len(results) | return results | endif
    " 3/3 search datafile and english: /ma and /horse
    let keyboard = tolower(a:keyboard)
    let s:english.line = s:vimim_get_english(keyboard)
    if empty(s:english.line)
        let results = s:vimim_embedded_backend_engine(keyboard)
    else
        let results = split(s:english.line)
    endif
    return results
endfunction

" ============================================= }}}
let s:VimIM += [" ====  core workflow    ==== {{{"]
" =================================================

function! s:vimim_start()
    sil!call s:vimim_set_vimrc()
    sil!call s:vimim_set_color()
    sil!call s:vimim_set_keycode()
    sil!call s:vimim_all_maps()
    if s:ui.im =~ 'array'
        lnoremap <silent> <expr> <CR>    g:vimim_space()
        lnoremap <silent> <expr> <Space> g:vimim_pagedown()
    else
        lnoremap <silent> <expr> <CR>    g:vimim_enter()
        lnoremap <silent> <expr> <Space> g:vimim_space()
    endif
    lnoremap <silent> <expr> <BS>    g:vimim_backspace()
    lnoremap <silent> <expr> <Esc>   g:vimim_esc()
    lnoremap <silent> <expr> <C-U>   g:vimim_correction()
    lnoremap <silent> <expr> <C-L>   g:vimim_windowless_or_halfwidth()
    if len(s:ui.frontends) > 1 && g:vimim_toggle > -1
        lnoremap <silent> <expr> <C-H> g:vimim_im_switch()
    endif
    let lmap = ""
    if empty(s:lmap) && mode() == 'i'
        let s:lmap = 32911
        let lmap = "\<C-^>"
    endif
    sil!exe 'sil!return "' . lmap . '"'
endfunction

function! s:vimim_stop()
    lmapclear
    sil!call s:vimim_restore_vimrc()
    sil!call s:vimim_super_reset()
    sil!exe 'sil!return "' . "\<C-^>" . '"'
endfunction

function! s:vimim_set_vimrc()
    set title noshowmatch shellslash imdisable
    set completeopt=menuone
    set complete=.
    set nolazyredraw
    set omnifunc=VimIM
endfunction

function! s:vimim_save_vimrc()
    let s:cpo         = &cpo
    let s:laststatus  = &laststatus
    let s:statusline  = &statusline
    let s:titlestring = &titlestring
    let s:completeopt = &completeopt
    let s:complete    = &complete
    let s:lazyredraw  = &lazyredraw
    let s:omnifunc    = &omnifunc
endfunction

function! s:vimim_restore_vimrc()
    let &cpo         = s:cpo
    let &laststatus  = s:laststatus
    let &statusline  = s:statusline
    let &titlestring = s:titlestring
    let &completeopt = s:completeopt
    let &complete    = s:complete
    let &lazyredraw  = s:lazyredraw
    let &omnifunc    = s:omnifunc
    let &pumheight   = s:pumheights.saved
endfunction

function! s:vimim_set_pumheight()
    let &completeopt = s:mode.windowless ? 'menu' : 'menuone'
    let &pumheight = s:pumheights.saved
    if empty(&pumheight)
        let &pumheight = 5
        if s:mode.onekey || len(s:valid_keys) > 28
            let &pumheight = 10
        endif
    endif
    let &pumheight = s:mode.windowless ? 1 : &pumheight
    let s:pumheights.current = copy(&pumheight)
    if s:touch_me_not
        let &pumheight = 0
    elseif s:hjkl_l
        let &pumheight = s:hjkl_l % 2 ? 0 : s:pumheights.current
    endif
endfunction

function! s:vimim_super_reset()
    sil!call s:vimim_reset_before_anything()
    sil!call s:vimim_reset_before_omni()
    sil!call s:vimim_reset_after_insert()
endfunction

function! s:vimim_reset_before_anything()
    let s:lmap = 0
    let s:mode = {'onekey':1,'windowless':0,'dynamic':0,'static':0}
    let s:hit_and_run = empty(s:cjk.filename) ? 1 : 0
    let s:toggle_im = 0
    let s:smart_enter = 0
    let s:has_pumvisible = 0
    let s:toggle_punctuation = 1
    let s:chinese_mode_switch = 0
    let s:keyboard = ""
    let s:popup_list = []
endfunction

function! s:vimim_reset_before_omni()
    let s:english.line = ""
    let s:touch_me_not = 0
    let s:show_extra_menu = 0
    let s:cursor_at_windowless = 0
endfunction

function! s:vimim_reset_after_insert()
    let s:hjkl_n = ""   "  reset for nothing
    let s:hjkl_h = 0    "  toggle cjk property
    let s:hjkl_l = 0    "  toggle label length
    let s:hjkl_m = 0    "  toggle cjjp/c'j'j'p
    let s:hjkl__ = 0    "  toggle simplified/traditional
    let s:match_list = []
    let s:pageup_pagedown = 0
    let s:pattern_not_found = 0
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
    let last_seen_bslash_column = copy(start_column)
    let last_seen_nonsense_column = copy(start_column)
    let all_digit = 1
    while start_column
        if one_before =~# s:valid_keyboard
            let start_column -= 1
            if one_before !~# "[0-9']" || s:ui.im =~ 'phonetic'
                let last_seen_nonsense_column = start_column
                let all_digit = all_digit ? 0 : all_digit
            endif
        elseif one_before == '\' " do nothing if leading bslash found
            let s:pattern_not_found = 1
            return last_seen_bslash_column
        else
            break
        endif
        let one_before = current_line[start_column-1]
    endwhile
    if all_digit < 1 && current_line[start_column] =~ '\d'
        let start_column = last_seen_nonsense_column
    endif
    let s:starts.row = start_row
    let s:current_positions = current_positions
    let len = current_positions[2]-1 - start_column
    let keyboard = strpart(current_line, start_column, len)
    call s:vimim_set_keyboard_list(start_column, keyboard)
    return start_column
else
    " [windowless] gi mamahuhuhu space ctrl+u
    if s:smart_enter =~ "windowless_correction"
        return [s:space]
    endif
    let results = s:vimim_cache() " [hjkl] less is more
    if empty(results)
        sil!call s:vimim_reset_before_omni()
    else
        return s:vimim_popupmenu_list(results)
    endif
    let keyboard = a:keyboard
    if !empty(str2nr(keyboard)) " for digit input: 23554022100080204420
        let keyboard = get(split(s:keyboard),0)
    endif
    if empty(keyboard) || keyboard !~ s:valid_keyboard
        return []
    else   " [english] first check if it is english or not
        let s:english.line = s:vimim_get_english(keyboard)
    endif
    if s:mode.onekey || s:mode.windowless
        let results = s:vimim_get_hjkl_game(keyboard)
        if empty(results) && s:vimim_cjk()
            let head = s:vimim_get_head_without_quote(keyboard)
            let head = s:vimim_get_cjk_head(head)
            let results = !empty(head) ? s:vimim_cjk_match(head) : []
        endif
        if len(results)
            return s:vimim_popupmenu_list(results)
        elseif len(s:hjkl_n) && s:keyboard !~ "'"
            let keyboard = get(split(keyboard,'\d'),0)  " mali74
        elseif get(split(s:keyboard),1) =~ "'"  " ssss.. for cloud
            let keyboard = s:vimim_get_head_without_quote(keyboard)
        endif
    endif
    " [mycloud] get chunmeng from local or www
    if s:ui.im == 'mycloud'
        let results = s:vimim_get_mycloud(keyboard)
        if len(results)
            let s:show_extra_menu = 1
            return s:vimim_popupmenu_list(results)
        else  " auto switch to the next s:ui.im after mycloud failure
            sil!call remove(s:ui.frontends,match(s:ui.frontends,s:ui.im))
            sil!call g:vimim_im_switch()
        endif
    endif
    " [shuangpin] support 6 major shuangpin rules
    if !empty(g:vimim_shuangpin) && g:vimim_cloud !~ 'shuangpin'
        if empty(s:shuangpin_table)
            let rules = s:vimim_shuangpin_generic()
            let rules = s:vimim_shuangpin_rules(g:vimim_shuangpin, rules)
            let s:shuangpin_table = s:vimim_create_shuangpin_table(rules)
        endif
        if empty(s:has_pumvisible)
            let keyboard = s:vimim_shuangpin_transform(keyboard)
            let s:keyboard = keyboard
        endif
    endif
    " [cloud] to make dream come true for multiple clouds
    if s:ui.root == 'cloud' || keyboard[-1:] == "'" && empty(s:ui.quote)
        let results = s:vimim_get_cloud(keyboard, s:cloud)
    endif
    if empty(results)
        if s:wubi && len(keyboard) > 4
            let keyboard = strpart(keyboard, 4*((len(keyboard)-1)/4))
            let s:keyboard = keyboard  " wubi auto insert on the 4th
        endif
        " [backend] plug-n-play embedded file/directory engine
        let results = s:vimim_embedded_backend_engine(keyboard)
    endif
    if len(s:english.line)
        let s:keyboard = s:keyboard !~ "'" ? keyboard : s:keyboard
        let results = s:vimim_make_pairs(s:english.line) + results
    endif
    " [the_last_resort] either force shoupin or force cloud
    if empty(results) && s:mode.onekey
        if len(keyboard) > 1
            let shoupin = s:vimim_get_head_without_quote(keyboard."'''")
            let results = s:vimim_cjk_match(shoupin)
            if empty(results)
                let results = s:vimim_get_cloud(keyboard, s:cloud)
            endif
        else
            let i = keyboard == 'i' ? "我" : s:space " for onekey continuity
            let results = split(repeat(i,5),'\zs')
        endif
    elseif empty(results) && s:mode.static
        let s:pattern_not_found = 1
    endif
    return s:vimim_popupmenu_list(results)
endif
endfunction

function! s:vimim_popupmenu_list(lines)
    let s:match_list = a:lines
    let keyboards = split(s:keyboard)  " mmmm => ['m',"m'm'm"]
    let tail = len(keyboards) < 2 ? "" : get(keyboards,1)
    let keyboard = get(keyboards, 0)
    if empty(a:lines) || type(a:lines) != type([])
        return []
    elseif s:vimim_cjk() && len(s:hjkl_n)
        let results = []  " use 1234567890 as filter for windowless
        for chinese in a:lines
            if s:vimim_cjk_in_4corner(chinese,0)
                call add(results, chinese)
            endif
        endfor
        if empty(results)
            let s:hjkl_n = ""  " make digits recyclable
        else
            let s:match_list = results
        endif
    endif
    call s:vimim_set_pumheight()
    let label = 1
    let one_list = []
    let s:popup_list = []
    for chinese in s:match_list
        let complete_items = {}
        if s:vimim_cjk() && s:hjkl__ && s:hjkl__%2
            let simplified_traditional = ""
            for char in split(chinese, '\zs')
                let simplified_traditional .= s:vimim_1to1(char)
            endfor
            let chinese = simplified_traditional
        endif
        let label2 = s:mode.windowless ? label : s:vimim_get_label(label)
        if empty(s:touch_me_not)
            let menu = ""
            let pairs = split(chinese)
            let pair_left = get(pairs,0)
            if len(pairs) > 1 && pair_left !~ '[^\x00-\xff]'
                let chinese = get(pairs,1)
                let menu = s:show_extra_menu ? pair_left : menu
            endif
            if s:hjkl_h && s:hjkl_h % 2
                let char = get(split(chinese,'\zs'),0)
                let menu = s:vimim_cjk_property(char)
            endif
            let labeling = printf('%02s ', label2)
            if s:ui.im !~ 'phonetic'
                let english = s:english.line =~ chinese ? '*' : ' '
                let label2 = english . label2
                let labeling = printf('%3s ', label2)
            endif
            let chinese .= empty(tail) ? '' : tail
            let complete_items["abbr"] = labeling . chinese
            let complete_items["menu"] = menu
        endif
        let titleline = label . "."
        if s:mode.windowless
            let titleline = label2
            if s:vimim_cjk() " display sexy english and dynamic 4corner
                let star = substitute(titleline,'[0-9a-z_ ]','','g')
                let digit = s:vimim_cjk_in_4corner(chinese,1)
                let titleline = star . digit[len(s:hjkl_n) : 3] " ma7 712
            elseif label < 11      " 234567890 for windowless selection
                let titleline = label2[:-2]
            endif
        endif
        call add(one_list, titleline . chinese)
        let label += 1
        let complete_items["dup"] = 1
        let complete_items["word"] = empty(chinese) ? s:space : chinese
        call add(s:popup_list, complete_items)
    endfor
    call s:vimim_title()
    if s:mode.windowless && empty(s:touch_me_not)
        let vimim = "VimIM" . s:space .'  '. join(keyboards,"").'  '
        let &titlestring = vimim . join(one_list)
        call s:vimim_set_titlestring(1)
        Debug s:match_list[:3]
    elseif s:touch_me_not
        let &titlestring = s:logo . s:space . s:today
    endif
    return s:popup_list
endfunction

function! s:vimim_embedded_backend_engine(keyboard)
    let keyboard = a:keyboard
    if empty(s:ui.im) || empty(s:ui.root)
        return []
    endif
    let head = 0
    let results = []
    let backend = s:backend[s:ui.root][s:ui.im]
    if backend.name =~ "quote" && keyboard !~ "[']" " has apostrophe
        let keyboard = s:vimim_quanpin_transform(keyboard)
    endif
    if s:ui.root =~# "directory"
        let head = s:vimim_sentence_directory(keyboard, backend.name)
        let results = s:vimim_readfile(backend.name . head)
        if keyboard ==# head && len(results) && len(results) < 20
            let extras = s:vimim_more_directory(keyboard, backend.name)
            if len(extras) && len(results)
                call map(results, 'keyboard ." ". v:val')
                call extend(results, extras)
            endif
        endif
    elseif s:ui.root =~# "datafile"
        if backend.name =~ "bsddb"
            if empty(backend.lines)
                let backend.lines = ["4MB_in_memory_46MB_on_disk"]
                sil!call s:vimim_initialize_bsddb(backend.name)
            endif
            let head = s:vimim_get_stone_from_bsddb(keyboard)
            if !empty(head)
                let results = s:vimim_get_from_database(head)
            endif
        else
            if empty(backend.lines)
                let backend.lines = s:vimim_readfile(backend.name)
            endif
            let head = s:vimim_sentence_datafile(keyboard)
            let results = s:vimim_get_from_datafile(head)
        endif
    endif
    if s:keyboard !~ '\S\s\S'
        if empty(head)
            let s:keyboard = keyboard
        elseif len(head) < len(keyboard)
            let tail = strpart(keyboard,len(head))
            let s:keyboard = head . " " . tail
        endif
    endif
    return results
endfunction

function! g:vimim()
    let key = ""
    let s:keyboard = empty(s:pageup_pagedown) ? "" : s:keyboard
    if s:vimim_byte_before() =~# s:valid_keyboard
        let key = '\<C-X>\<C-O>\<C-R>=g:vimim_omni()\<CR>'
    else
        let s:has_pumvisible = 0
    endif
    sil!exe 'sil!return "' . key . '"'
endfunction

function! g:vimim_omni()
    let cursor = s:mode.static ? '\<C-N>\<C-P>' : '\<C-P>\<Down>'
    let key = pumvisible() ? cursor : ""
    let s:smart_enter = 0  " windowless: gi ma enter li space 4
    sil!exe 'sil!return "' . key . '"'
endfunction

" ============================================= }}}
let s:VimIM += [" ====  core driver      ==== {{{"]
" =================================================

function! s:vimim_plug_and_play()
    if g:vimim_map =~ 'ctrl_bslash'
        nnoremap<silent><C-Bslash> :call g:vimim_chinese()<CR>
        inoremap<unique><C-Bslash> <C-R>=g:vimim_chinese()<CR>
    endif
    if g:vimim_map =~ 'ctrl6'
        inoremap<silent><C-^> <C-R>=g:vimim_onekey()<CR>
        xnoremap<silent><C-^> y:call g:vimim_visual()<CR>
    endif
    if g:vimim_map =~ 'tab'
        inoremap<silent><Tab> <C-R>=g:vimim_tab()<CR>
        xnoremap<silent><Tab> y:call g:vimim_visual()<CR>
    endif
    if g:vimim_map =~ 'gi'
        nnoremap<silent> gi a<C-R>=g:vimim_gi()<CR>
    endif
    if g:vimim_map =~ 'search'
        nnoremap<silent> n :call g:vimim_search()<CR>n
    endif
    :com! -range=% ViMiM <line1>,<line2>call s:vimim_chinese_rotation()
    :com! -range=% VimIM <line1>,<line2>call s:vimim_chinese_transfer()
    :com! -nargs=* Debug :sil!call s:vimim_debug(<args>)
endfunction

sil!call s:vimim_initialize_debug()
sil!call s:vimim_initialize_global()
sil!call s:vimim_dictionary_statusline()
sil!call s:vimim_dictionary_punctuations()
sil!call s:vimim_dictionary_numbers()
sil!call s:vimim_dictionary_keycodes()
sil!call s:vimim_save_vimrc()
sil!call s:vimim_super_reset()
sil!call s:vimim_set_background_clouds()
sil!call s:vimim_set_backend_embedded()
sil!call s:vimim_set_backend_mycloud()
sil!call s:vimim_set_im_toggle_list()
sil!call s:vimim_plug_and_play()
:let g:vimim_profile = reltime(g:vimim_profile)
" ============================================= }}}
:redir @p
Debug s:vimim_egg_vimim()

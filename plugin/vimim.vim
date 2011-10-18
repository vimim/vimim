" ===========================================================
"                   VimIM —— Vim 中文輸入法
" ===========================================================
let s:egg  = ' vimim easter egg:' " vim i vimim ctrl+6 ctrl+6
let s:egg  = ' $Date$'
let s:egg  = ' $Revision$'
let s:url  = ' http://vim.sf.net/scripts/script.php?script_id=2506'
let s:url .= ' http://vimim.googlecode.com/svn/vimim/vimim.vim.html'

let s:VimIM  = [" ====  introduction     ==== {{{"]
" =================================================
"    File: vimim.vim
"  Author: vimim <vimim@googlegroups.com>
" License: GNU Lesser General Public License
"  Readme: VimIM is a Vim plugin as an independent Input Method.
"    (1) do Chinese input without mode change: Midas touch
"    (2) do Chinese search without typing Chinese: slash search
"    (3) support Google/Baidu/Sogou/QQ cloud input
"    (4) support bsd database with python interface to Vim
"  Installation: plug and play
"    (1) drop the vimim.vim to the plugin folder: plugin/vimim.vim
"    (2) [option] drop supported datafiles, like: plugin/vimim.txt
"  Usage: vim i vimimhelp ctrl+6 ctrl+6
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

if exists("b:vimim") || v:version < 700
    finish
elseif &compatible
    call s:vimim_bare_bones_vimrc()
    " gvim -u /home/xma/vim/vimfiles/plugin/vimim.vim
    " gvim -u /home/vimim/svn/vimim/trunk/plugin/vimim.vim
endif
scriptencoding utf-8
let b:vimim = 39340
let s:plugin = expand("<sfile>:p:h")

function! s:vimim_initialize_debug()
    let hjkl = simplify(s:plugin . '/../../../hjkl/')
    if empty(&cp) && exists('hjkl') && isdirectory(hjkl)
        let g:vimim_plugin = hjkl
        let g:vimim_map = 'tab,search,gi'
    endif
endfunction

function! s:vimim_initialize_global()
    let s:space = '　'
    let s:colon = '：'
    let s:logo = "VimIM　中文輸入法"
    let s:today = s:vimim_imode_today_now('itoday')
    let s:multibyte    = &encoding =~ "utf-8" ? 3 : 2
    let s:localization = &encoding =~ "utf-8" ? 0 : 2
    let s:chinese_mode = 'onekey'
    let s:toggle_im = 0
    let s:toggle_punctuation = 1
    let s:cursor_at_menuless = 0
    let s:seamless_positions = []
    let s:current_positions = [0,0,1,0]
    let s:shuangpin_table = {}
    let s:quanpin_table = {}
    let s:abcd = split("'abcdvfgxz", '\zs')
    let s:qwer = split("pqwertyuio", '\zs')
    let s:az_list = map(range(97,122),"nr2char(".'v:val'.")")
    let s:valid_keys = s:az_list
    let s:valid_keyboard = "[0-9a-z']"
    let s:shengmu_list = split('b p m f d t l n g k h j q x r z c s y w')
    let s:starts = { 'row' : 0, 'column' : 1 }
    let s:pumheights = { 'current' : 10, 'saved' : &pumheight }
    let s:smart_quotes = { 'single' : 1, 'double' : 1 }
    let s:backend = { 'cloud' : {}, 'datafile' : {}, 'directory' : {} }
    let s:ui = { 'root' : '', 'im' : '', 'has_dot' : 0, 'frontends' : [] }
    let s:rc = { "g:vimim_chinese_input_mode" : 'dynamic' }
    let s:rc["g:vimim_map"] = 'ctrl_6,ctrl_bslash,search,gi'
    let s:rc["g:vimim_punctuation"] = 1
    let s:rc["g:vimim_toggle_list"] = 0
    let s:rc["g:vimim_shuangpin"] = 'abc ms plusplus purple flypy nature'
    let s:rc["g:vimim_plugin"] = s:plugin
    let s:rc["g:vimim_cloud"] = 'google,sogou,baidu,qq'
    let s:rc["g:vimim_mycloud"] = 0
    call s:vimim_set_global_default()
    if isdirectory(s:vimim_plugin)
        let s:plugin = s:vimim_plugin
    endif
    if s:plugin[-1:] != "/"
        let s:plugin .= "/"
    endif
    let s:english = { 'lines' : [], 'line' : "" }
    let s:english.filename = s:vimim_filereadable("vimim.txt")
    let s:cjk = { 'lines' : [] }
    let s:cjk.filename = s:vimim_filereadable("vimim.cjk.txt")
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

function! s:vimim_dictionary_keycodes()
    let s:im_keycode = {}
    let key26  = ' google sogou baidu qq '
    let key26 .= ' wu nature zhengma taijima wubi cangjie '
    for key in split(key26)
        let s:im_keycode[key] = "[a-z']"
    endfor
    for key in split('pinyin hangul xinhua quick mycloud')
        let s:im_keycode[key] = "[0-9a-z']"
    endfor
    let s:im_keycode.yong     = "[.'a-z;/]"
    let s:im_keycode.erbi     = "[.'a-z,;/]"
    let s:im_keycode.array30  = "[.,a-z0-9;/]"
    let s:im_keycode.phonetic = "[.,a-z0-9;/]"
    let s:im_keycode.boshiamy = "[][a-z'.,]"
    let keys  = copy(keys(s:im_keycode))
    let keys += split('pinyin_sogou pinyin_quote_sogou pinyin_huge')
    let keys += split('pinyin_fcitx pinyin_canton pinyin_hongkong')
    let keys += split('wubi98 wubi2000 wubijd wubihf')
    let s:all_vimim_input_methods = copy(keys)
endfunction

function! s:vimim_set_keycode()
    let dot_im = 'wu erbi yong nature boshiamy phonetic array30'
    for im in split(dot_im)
        if s:ui.im == im
            let s:ui.has_dot = 1  " has english dot in datafile
            let s:vimim_punctuation = 0
            break
        endif
    endfor
    if s:backend[s:ui.root][s:ui.im].name =~# "quote"
        let s:ui.has_dot = 2      " has apostrophe in datafile
    endif
    let keycode = "[0-9a-z']"
    if !empty(s:ui.root)
        let keycode = s:backend[s:ui.root][s:ui.im].keycode
    endif
    if len(s:vimim_shuangpin)
        let keycode = "[0-9a-z']"
        if s:vimim_shuangpin == 'ms' || s:vimim_shuangpin == 'purple'
            let keycode = "[0-9a-z';]"
        endif
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
endfunction

function! s:vimim_set_global_default()
    let s:vimimrc = []
    let s:vimimdefaults = []
    for variable in keys(s:rc)
        let s_variable = substitute(copy(variable), "g:", "s:", '')
        if exists(variable)
            let value = string(eval(variable))
            let vimimrc = ':let ' . variable .' = '. value .' '
            call add(s:vimimrc, '  ' . vimimrc)
            exe   'let  ' . s_variable .'='. value
            exe 'unlet! ' .   variable
        else
            let default = string(s:rc[variable])
            let vimimrc = ':let ' . variable .' = '. default .' '
            call add(s:vimimdefaults, '" ' . vimimrc)
            if variable == "g:vimim_shuangpin"
                exe 'let '. s_variable . " = '' "
            else
                exe 'let '. s_variable .'='. default
            endif
        endif
    endfor
endfunction

function! s:vimim_get_valid_im_name(im)
    let im = a:im
        if im =~ '^wubi'   | let im = 'wubi'
    elseif im =~ '^pinyin' | let im = 'pinyin'
    elseif match(s:all_vimim_input_methods, im) < 0
        let im = 0
    endif
    return im
endfunction

function! g:vimim_wubi()
    let key = ""
    if pumvisible()
        let key = '\<C-E>'
        if empty(len(get(split(s:keyboard),0))%4)
            let key = '\<C-Y>'
        endif
    endif
    sil!exe 'sil!return "' . key . '"'
endfunction

function! s:vimim_set_plugin_conflict()
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

function! s:vimim_restore_plugin_conflict()
    if !empty(s:acp_sid)
        let ACPMappingDrivenkeys = [
            \ '-','_','~','^','.',',',':','!','#','=','%','$','@',
            \ '<','>','/','\','<Space>','<BS>','<CR>',]
        let AZ_list = map(range(65,90), "nr2char(".'v:val'.")")
        call extend(ACPMappingDrivenkeys, range(10))
        call extend(ACPMappingDrivenkeys, s:az_list + AZ_list)
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
            exe printf("im <tab> <C-R>=<SNR>%s_SuperTab('p')<CR>",tab)
        endif
        if g:SuperTabMappingBackward =~ '^<s-tab>$'
            exe printf("im <s-tab> <C-R>=<SNR>%s_SuperTab('n')<CR>",tab)
        endif
    endif
endfunction

function! s:vimim_getsid(scriptname)
    " use s:getsid to get script sid, translate <SID> to <SNR>N_
    redir => scriptnames_output
    silent scriptnames
    redir END
    for line in split(scriptnames_output, "\n")
        if line =~ a:scriptname           " only do non-blank lines
            return matchstr(line, '\d\+') " get the first number
        endif
    endfor
    return 0
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

function! s:vimim_egg_vim()
    let logo = "Vim　　文本編輯器"
    return [logo, s:logo]
endfunction

function! s:vimim_egg_vimimgame()
    let mahjong = "春夏秋冬 梅兰竹菊 中發白囍 東南西北"
    return split(mahjong)
endfunction

function! s:vimim_egg_vimimclouds()
    return s:vimim_get_cloud_all('woyouyigemeng')
endfunction

function! s:vimim_egg_vimimvim()
    let filter = "strpart(" . 'v:val' . ", 0, 29)"
    return map(copy(s:VimIM), filter)
endfunction

function! s:vimim_egg_vimimrc()
    let vimimrc = copy(s:vimimdefaults)
    let index = match(vimimrc, 'g:vimim_toggle_list')
    let custom_im_toggle_list = s:vimim_get_custom_im_list()
    if index && !empty(custom_im_toggle_list)
        let toggle = join(custom_im_toggle_list,",")
        let value = vimimrc[index][:-3]
        let vimimrc[index] = value . "'" . toggle . "'"
    endif
    let vimimrc += s:vimimrc
    return sort(vimimrc)
endfunction

function! s:vimim_egg_vimim()
    let eggs = []
    call add(eggs, s:vimim_chinese('date') . s:colon . s:today)
    let os = "win32unix win32 win64 macunix unix x11"
    for computer in split(os)
        if has(computer)
            let os = computer | break
        endif
    endfor
    let computer = s:vimim_chinese('computer') . s:colon
    call add(eggs, computer . os . s:space . &term)
    let revision = get(split(s:egg),1)
    let revision = empty(revision) ?  ""  : "vimim.vim=" . revision
    let revision = v:progname ."=". v:version  . s:space . revision
    call add(eggs, s:vimim_chinese('revision') . s:colon . revision)
    let encoding = s:vimim_chinese('encoding') . s:colon
    call add(eggs, encoding . &encoding . s:space . &fileencodings)
    call add(eggs, s:vimim_chinese('env') . s:colon . v:lc_time)
    let database = s:vimim_chinese('database') . s:colon
    if len(s:cjk.filename)
        let ciku = database . s:vimim_chinese('cjk') . s:colon
        call add(eggs, ciku . s:cjk.filename)
    endif
    if len(s:english.filename)
        let ciku = database . s:vimim_chinese('english') . database
        call add(eggs, ciku . s:english.filename)
    endif
    if len(s:ui.frontends)
        for [root, im] in s:ui.frontends
            let mass = s:backend[root][im].name=~"bsddb" ? 'mass' : root
            let ciku = database . s:vimim_chinese(mass) . database
            call add(eggs, ciku . s:backend[root][im].name)
        endfor
        let input = s:vimim_chinese('input') . s:colon
        if s:vimim_map =~ 'ctrl_bslash'
            let input .=  s:vimim_statusline() . s:space
        elseif s:vimim_map =~ 'gi'
            let input .= s:vimim_chinese('onekey')     . s:space
            let input .= s:vimim_chinese('windowless') . s:space
        endif
        call add(eggs, input)
    endif
    if !empty(s:vimim_check_http_executable())
        let exe = s:http_exe =~ 'Python' ? '' : "HTTP executable: "
        let network  = s:vimim_chinese('network') . s:colon
        call add(eggs, network . exe . s:http_exe)
    endif
    call add(eggs, s:vimim_chinese('option') . s:colon . "vimimhelp")
    if !empty(s:vimimrc)
        for rc in sort(s:vimimrc)
            call add(eggs, s:space . s:space . s:colon . rc[2:])
        endfor
    endif
    return map(eggs, 'v:val . " " ')
endfunction

function! s:vimim_get_hjkl_game(keyboard)
    let keyboard = a:keyboard
    let results = []
    let poem = s:vimim_filereadable(keyboard)
    if s:vimim_get_unicode_ddddd(keyboard)
        return s:vimim_unicode_list(s:vimim_get_unicode_ddddd(keyboard))
    elseif keyboard ==# 'itoday' || keyboard ==# 'inow'
        return [s:vimim_imode_today_now(keyboard)]
    elseif keyboard == "'''''"
        return split(join(s:vimim_egg_vimimgame(),""),'\zs')
    elseif keyboard == "''"
        let char_before = s:vimim_char_before()
        if empty(char_before)
            if s:vimim_cjk()    " 214 standard unicode index
                return s:vimim_cjk_match('u')
            else
                let char_before = '一'
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
        let results = s:vimim_get_cloud_all(keyboard[:-5])
    elseif len(getreg('"')) > 3  " vimim_visual_ctrl6
        if keyboard ==# "''''"   " unname_register
            " [hjkl] display buffer inside the omni window
            let results = split(getreg('"'), '\n')
        elseif keyboard =~# 'u\d\d\d\d\d'
            " [cjk]  display highlighted multiple cjk
            let line = substitute(getreg('"'),'[\x00-\xff]','','g')
            if len(line)
                for chinese in split(line,'\zs')
                    let menu  = s:vimim_cjk_extra_text(chinese)
                    let menu .= repeat(" ", 38-len(menu))
                    call add(results, chinese . " " . menu)
                endfor
            endif
        endif
    endif
    if !empty(results)
        let s:touch_me_not = 1
        if s:hjkl_m % 4
            for i in range(s:hjkl_m%4)
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
        if (max-len(line))/multibyte
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
    highlight  default CursorIM guifg=NONE guibg=green gui=NONE
    highlight! link Cursor CursorIM
    if has("win32") || has("win32unix")
        highlight! PmenuSbar  NONE
        highlight! PmenuThumb NONE
        highlight! Pmenu      NONE
        highlight! link PmenuSel NonText
    endif
endfunction

function! s:vimim_dictionary_statusline()
    let s:title = {}
    let s:title.windowless = "无菜单窗,無菜單窗"
    let s:title.onekey     = "点石成金,點石成金"
    let s:title.cjk        = "标准字库,標準字庫"
    let s:title.abc        = "智能双打,智能雙打"
    let s:title.mycloud    = "自己的云,自己的雲"
    let s:title.boshiamy   = "呒虾米,嘸蝦米"
    let s:title.wubi2000   = "新世纪,新世紀"
    let s:title.taijima    = "太极码,太極碼"
    let s:title.nature     = "自然码,自然碼"
    let single  = " computer directory datafile database option  env "
    let single .= " encoding input     static   dynamic  erbi    wubi"
    let single .= " hangul   xinhua    zhengma  cangjie  yong    wu  "
    let single .= " wubijd   shuangpin cloud    flypy    network ms  "
    let double  = " 电脑,電腦 目录,目錄 文件,文本 词库,詞庫 选项,選項"
    let double .= " 环境,環境 编码,編碼 输入,輸入 静态,靜態 动态,動態"
    let double .= " 二笔,二筆 五笔,五筆 韩文,韓文 新华,新華 郑码,鄭碼"
    let double .= " 仓颉,倉頡 永码,永碼 吴语,吳語 极点,極點 双拼,雙拼"
    let double .= " 云,雲     小鹤,小鶴 联网,聯網 微软,微軟 "
    call extend(s:title, s:vimim_key_value_hash(single, double))
    let single  = " pinyin fullwidth halfwidth english chinese purple"
    let single .= " plusplus quick wubihf wubi98 phonetic array30"
    let single .= " revision mass date google baidu sogou qq "
    let double  = " 拼音 全角 半角 英文 中文 紫光 加加 速成 海峰 98"
    let double .= " 注音 行列 版本 海量 日期 谷歌 百度 搜狗 ＱＱ"
    call extend(s:title, s:vimim_key_value_hash(single, double))
endfunction

function! s:vimim_chinese(key)
    let chinese = a:key
    if has_key(s:title, chinese)
        let twins = split(s:title[chinese], ",")
        let chinese = get(twins, 0)
        if len(twins) > 1 && s:vimim_map =~ 'ctrl_bslash'
            let chinese = get(twins,1)
        endif
    endif
    return chinese
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
    elseif &omnifunc ==# 'VimIM'
        return s:space . s:vimim_statusline()
    endif
    return ""
endfunction

function! s:vimim_get_title()
    let statusline = s:space
    if empty(s:ui.root) || empty(s:ui.im)
        return ""
    elseif has_key(s:im_keycode, s:ui.im)
        let im = s:backend[s:ui.root][s:ui.im].chinese
        if s:windowless && len(s:cjk.filename)
            let im = len(s:english.line) ? '*'      : ''
            let im = len(s:hjkl_n)       ? s:hjkl_n : im
        endif
        let statusline .= im
    endif
    let datafile = s:backend[s:ui.root][s:ui.im].name
    if s:ui.im =~ 'wubi'
        for wubi in split('wubi98 wubi2000 wubijd wubihf')
            if get(split(datafile,'/'),-1) =~ wubi
                let statusline .= s:vimim_chinese(wubi)
            endif
        endfor
    elseif s:ui.im == 'mycloud'
        let statusline .= s:space . s:backend.cloud.mycloud.directory
    elseif s:ui.root == 'cloud'
        let cloud  = s:vimim_chinese(s:cloud_default)
        let cloud .= s:vimim_chinese('cloud')
        let statusline = s:space . cloud
        let clouds = split(s:vimim_cloud,',')
        let vimim_cloud = get(clouds, match(clouds, s:cloud_default))
        if vimim_cloud =~ 'wubi'          " g:vimim_cloud='qq.wubi'
            let statusline .= s:space . s:vimim_chinese('wubi')
        elseif vimim_cloud =~ 'shuangpin' " qq.shuangpin.ms => ms
            let shuangpin = get(split(vimim_cloud,"[.]"),-1)
            if match(split(s:rc["g:vimim_shuangpin"]),shuangpin) > -1
                let statusline .= s:space . s:vimim_chinese(shuangpin)
            endif
            if vimim_cloud !~ 'abc'
                let statusline .= s:space . s:vimim_chinese('shuangpin')
            endif
        endif
    endif
    if len(s:vimim_shuangpin)
        let shuangpin = s:vimim_chinese(s:vimim_shuangpin)
        if s:vimim_shuangpin !~ 'abc'
            let shuangpin .= s:vimim_chinese('shuangpin')
        endif
        let statusline = s:space . shuangpin
    endif
    return statusline . s:space
endfunction

function! s:vimim_statusline()
    let input_mode  = get(split(s:vimim_chinese_input_mode,','),0)
    let punctuation = s:toggle_punctuation ? 'fullwidth' : 'halfwidth'
    let punctuation = s:vimim_chinese(punctuation)
    let statusline  = s:vimim_chinese('chinese')
    let statusline .= s:vimim_chinese(input_mode)
    let statusline .= s:vimim_get_title() . punctuation
    let statusline .= s:space . "VimIM"
    return statusline
endfunction

function! g:vimim_slash()
    let range = col(".") - 1 - s:starts.column
    let chinese = strpart(getline("."), s:starts.column, range)
    let word = substitute(chinese,'\w','','g')
    let @/ = empty(word) ? @_ : word
    let repeat_times = len(word) / s:multibyte
    let delete_chars = ""
    if repeat_times && line(".") == s:starts.row
        let delete_chars = repeat("\<Left>\<Delete>", repeat_times)
    endif
    let slash = delete_chars . "\<Esc>"
    sil!call s:vimim_stop()
    sil!exe 'sil!return "' . slash . '"'
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

function! s:vimim_get_labeling(label)
    let labeling = a:label == 10 ? "0" : a:label
    if s:onekey && a:label < 11
        let label2 = a:label < 2 ? "_" : get(s:abcd,a:label-1)
        let labeling = empty(labeling) ? '10' : labeling . label2
        if len(s:cjk.filename) && empty(s:hjkl_l%2)
            let labeling = " " . label2
        endif
    endif
    return labeling
endfunction

" ============================================= }}}
let s:VimIM += [" ====  punctuations     ==== {{{"]
" =================================================

function! s:vimim_dictionary_punctuations()
    let s:evils = {}            " exception if passed around
    let s:all_evils = {}        " onekey uses all punctuations
    let s:punctuations = {}     " chinese mode uses minimum by default
    if s:vimim_punctuation < 1  " close all evil punctuations
        return
    endif
    let single = "  , .  +  -  ~  ^    _    "
    let double = " ， 。 ＋ － ～ …… —— "
    let mini_punctuations = s:vimim_key_value_hash(single, double)
    let single = "# & % $ ! = ; ? * { } ( ) < > [ ] : @"
    let double = "＃ ＆ ％ ￥ ！ ＝ ； ？ ﹡ 〖 〗 （ ） 《 》 【 】 ： 　"
    let most_punctuations = s:vimim_key_value_hash(single, double)
    call extend(s:punctuations, mini_punctuations)
    if s:vimim_punctuation > 1    " :let g:vimim_punctuation = 2
        call extend(s:punctuations, most_punctuations)
    endif
    let evils = { '\' : "、", "'" : "‘’", '"' : "“”" }
    if s:vimim_punctuation > 2    " :let g:vimim_punctuation = 3
        let s:evils = copy(evils)
    endif
    call extend(s:all_evils, mini_punctuations)
    call extend(s:all_evils, most_punctuations)
    call extend(s:all_evils, evils)
endfunction

function! s:vimim_punctuations_maps()
    for _ in keys(s:punctuations) + [";", "'"]
        silent!exe 'inoremap <silent> <expr> '    ._.
        \ ' <SID>vimim_punctuation_map("'._.'")'
    endfor
    if !empty(s:evils)
        inoremap    '     <C-R>=<SID>vimim_get_single_quote()<CR>
        inoremap    "     <C-R>=<SID>vimim_get_double_quote()<CR>
        inoremap <Bslash> <C-R>=pumvisible() ? "\<lt>C-Y>、" : "、"<CR>
    endif
endfunction

function! <SID>vimim_punctuation_map(key)
    let key = a:key
    if s:toggle_punctuation
        if pumvisible() || s:vimim_byte_before() !~ '\w'
            if has_key(s:punctuations, a:key)
                let key = s:punctuations[a:key]
            endif
        endif
    endif
    if pumvisible()
        let key = '\<C-Y>' . key
        if a:key == ";"      " the 2nd choice
            let key = '\<Down>\<C-Y>\<C-R>=g:vimim()\<CR>'
        elseif a:key == "'"  " the 3rd choice
            let key = '\<Down>\<Down>\<C-Y>\<C-R>=g:vimim()\<CR>'
        endif
    endif
    sil!exe 'sil!return "' . key . '"'
endfunction

function! <SID>vimim_get_single_quote()
    let key = ""
    if pumvisible()  " the 3rd choice plus
        let key = '\<Down>\<Down>\<C-Y>\<C-R>=g:vimim()\<CR>'
    else
        let pairs = split(s:all_evils["'"], '\zs')
        let s:smart_quotes.single += 1
        let key .= get(pairs, s:smart_quotes.single % 2)
    endif
    sil!exe 'sil!return "' . key . '"'
endfunction

function! <SID>vimim_get_double_quote()
    let key = ""
    if pumvisible()
        let key = '\<C-Y>'
    endif
    let pairs = split(s:all_evils['"'], '\zs')
    let s:smart_quotes.double += 1
    let key .= get(pairs, s:smart_quotes.double % 2)
    sil!exe 'sil!return "' . key . '"'
endfunction

" ============================================= }}}
let s:VimIM += [" ====  hjkl             ==== {{{"]
" =================================================

function! s:vimim_cache()
    let results = []
    if !empty(s:pageup_pagedown)
        let length = len(s:match_list)
        let one_page = &pumheight < 6 ? 5 : 10
        if length > one_page
            let page = s:pageup_pagedown * one_page
            let partition = page ? page : length+page
            let B = s:match_list[partition :]
            let A = s:match_list[: partition-1]
            let results = B + A
        endif
    elseif s:onekey && s:touch_me_not
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

function! s:vimim_onekey_digit_filter(results)
    " only use 1234567890 as filter for windowless
    " also use qwertyuiop as filter for omni popup
    let results = []
    for chinese in a:results
        if s:vimim_digit_for_cjk(chinese,0)
            call add(results, chinese)
        endif
    endfor
    if empty(results)
        let s:hjkl_n = ""   " make it recyclable
        return a:results
    endif
    return results
endfunction

function! s:vimim_common_maps()
    let labels = range(10)
    let punctuation = " ] [ = - "
    if s:onekey
        let punctuation .= " . , "
        let labels += s:abcd
        call remove(labels, match(labels,"'"))
    endif
    for _ in labels
        exe 'inoremap<expr> '._.' <SID>vimim_label_map("'._.'")'
    endfor
    for _ in split(punctuation)
        exe 'inoremap<expr> '._.' <SID>vimim_page_map("'._.'")'
    endfor
endfunction

function! <SID>vimim_label_map(key)
    let key = a:key  " abcdvfgxz 1234567890
    if pumvisible()
        let n = match(s:abcd, key)
        if key =~ '\d'
            let n = key < 1 ? 9 : key - 1
        endif
        let key = '\<C-R>=g:vimim()\<CR>'
        let down = repeat("\<Down>", n)
        let s:has_pumvisible = 1
        if s:onekey && a:key =~ '\d'
            if len(s:cjk.filename)
                let s:hjkl_n .= a:key
            else
                let key = down . '\<C-Y>'
                sil!call s:vimim_stop()
            endif
        else
            let key = down . '\<C-Y>' . key
            sil!call s:vimim_reset_after_insert()
        endif
    elseif s:windowless && key =~ '\d'
        if s:pattern_not_found
            let s:pattern_not_found = 0
        else
            let key = s:vimim_menuless_map(key)
        endif
    endif
    sil!exe 'sil!return "' . key . '"'
endfunction

function! <SID>vimim_page_map(key)
    let key = a:key
    if pumvisible()
        if key =~ "[][]"
            let left  = key == "]" ? "\<Left>"  : ""
            let right = key == "]" ? "\<Right>" : ""
            let _ = key == "]" ? 0 : -1
            let bs  = '\<C-R>=g:vimim_bracket('._.')\<CR>'
            let key = '\<C-Y>' . left . bs . right
        elseif key =~ "[=.]"
            let key = '\<PageDown>'
            if &pumheight
                let s:pageup_pagedown = 1
                let key = g:vimim()
            endif
        elseif key =~ "[-,]"
            let key = '\<PageUp>'
            if &pumheight
                let s:pageup_pagedown = -1
                let key = g:vimim()
            endif
        endif
    elseif empty(s:onekey) && s:toggle_punctuation && key =~ "[][=-]"
        let key = <SID>vimim_punctuation_map(key)
    endif
    sil!exe 'sil!return "' . key . '"'
endfunction

" ============================================= }}}
let s:VimIM += [" ====  mode: windowless ==== {{{"]
" =================================================

function! g:vimim_title()
    let titlestring = s:logo . s:vimim_get_title()
    if s:windowless && empty(s:touch_me_not)
        let titlestring .= s:today
    endif
    if &term == 'screen'     " best efforts for gun screen
        echo titlestring
    else                     " if terminal can set window titles
        let &titlestring = titlestring        " all GUI versions
        :redraw
    endif
    return ""
endfunction

function! s:vimim_menuless_map(key)
    let key = a:key    " workaround to detect if completion is active
    let digit = key == " " ? '' : key
    if s:pattern_not_found  " gi \backslash space space
        " make space smart  " gi ma space enter space
    elseif s:smart_enter    " gi ma space enter 77 ma space
        let s:smart_enter = 0
        let s:seamless_positions = []       " gi wubihua space 8
    elseif !empty(s:vimim_char_before()) || s:keyboard =~ " "
        let key = empty(len(digit)) ? '\<C-N>' : '\<C-E>\<C-X>\<C-O>'
        let cursor = empty(len(digit)) ? 1 : digit < 1 ? 9 : digit-1
        if len(s:cjk.filename)
            let s:hjkl_n .= digit   " 1234567890 for windowless filter
        else
            if a:key =~ '[02-9]'    "  234567890 for windowless selection
                let key = repeat('\<C-N>', cursor)
            endif
        endif
        call s:vimim_set_titlestring(cursor)
    else
        let s:hjkl_n = ""
    endif
    sil!exe 'sil!return "' . key . '"'
endfunction

function! s:vimim_set_titlestring(cursor)
    let titlestring = substitute(&titlestring, s:colon, ' ', 'g')
    if titlestring !~ '\s\+' . "'" . '\+\s\+'
        let titlestring = substitute(titlestring,"'",'','g')
    endif
    let words = split(titlestring)[1:]
    let cursor = s:cursor_at_menuless + a:cursor
    let hightlight = get(words, cursor)
    if !empty(hightlight) && len(words) > 1
        let left = join(words[1 : cursor-1]) . s:colon
        let right = s:colon . join(words[cursor+1 :])
        let s:cursor_at_menuless = cursor
        let keyboard = get(words,0)=='0' ? "" : get(words,0)
        let title = keyboard .'  '. left . hightlight . right
        let &titlestring = "VimIM" . s:vimim_get_title() .' '. title
    endif
endfunction

function! <SID>vimim_space()
    " (1) <Space> after English (valid keys) => trigger keycode menu
    " (2) <Space> after English punctuation  => get Chinese punctuation
    " (3) <Space> after popup menu           => insert Chinese
    " (4) <Space> after pattern not found    => Space
    let space = " "
    if pumvisible()
        let space = '\<C-Y>\<C-R>=g:vimim()\<CR>'
        let s:has_pumvisible = 1
    elseif s:pattern_not_found
        let s:pattern_not_found = 0
        return space
    elseif s:chinese_mode =~ 'dynamic'
        return space
    elseif s:chinese_mode =~ 'static'
        let space = s:vimim_static_action(space)
    elseif s:onekey
        let space = s:vimim_onekey_action(1)
    endif
    call s:vimim_reset_after_insert()
    sil!exe 'sil!return "' . space . '"'
endfunction

function! <SID>vimim_enter()
    " (1) single <Enter> after English => seamless
    " (2) otherwise, or double <Enter> => <Enter>
    let key = ""
    if pumvisible()
        let key = "\<C-E>"
        let s:smart_enter = 1
    elseif s:windowless || s:vimim_byte_before() =~# s:valid_keyboard
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
        let key = "\<CR>"
        let s:smart_enter = 0
    endif
    let key .= '\<C-R>=g:vimim_title()\<CR>'
    sil!exe 'sil!return "' . key . '"'
endfunction

function! <SID>vimim_backspace()
    " <BS> has special meaning in all 3 states of popupmenu-completion
    let key = '\<Left>\<Delete>'
    if pumvisible()
        let key .= '\<C-R>=g:vimim()\<CR>'
    endif
    if s:windowless
        if s:smart_enter
            let s:smart_enter = "menuless_correction"
            let key  = '\<C-E>\<C-R>=g:vimim()\<CR>' . key
        else
            let key .= '\<C-R>=g:vimim_title()\<CR>'
        endif
    endif
    sil!exe 'sil!return "' . key . '"'
endfunction

function! <SID>vimim_esc()
    let key = '\<Esc>'
    if s:onekey
        :y
        if has("gui_running") && has("win32")
            sil!let @+ = @0[:-2] " copy to clipboard and display
        endif
        if &columns > 60
            let echo = join(split(@0[:-2],'\zs')[:&columns/2/2],"")
            let key .= ":echo " . string(echo) . "\<CR>"
        endif
        sil!call s:vimim_stop()
    elseif pumvisible()
        let key = '\<C-E>'   " use <Esc> as one key correction
        let range = col(".") - 1 - s:starts.column
        if range
            let key .= repeat("\<Left>\<Delete>", range)
            sil!call s:vimim_reset_after_insert()
        endif
    endif
    sil!exe 'sil!return "' . key . '"'
endfunction

" ============================================= }}}
let s:VimIM += [" ====  mode: onekey     ==== {{{"]
" =================================================

function! <SID>vimim_onekey(tab)
    " (1) <OneKey> in insert mode     => start MidasTouch popup
    " (2) <OneKey> in windowless mode => start MidasTouch popup
    " (3) <OneKey> in omni window     => start windowless if input
    " (4) <OneKey> in omni window     => start print if hjkl
    let onekey = ""
    let s:chinese_mode = 'onekey'
    let one_cursor = getline(".")[col(".")-1]
    if s:onekey
        if pumvisible()
            if empty(&pumheight)
                let onekey = '\<C-R>=g:vimim_screenshot()\<CR>'
            else
                let s:windowless = empty(a:tab) ? 1 : a:tab
                let onekey = '\<C-Y>'
            endif
        elseif s:windowless
            let s:windowless = 0
            if s:vimim_byte_before() =~# s:valid_keyboard
                let onekey = g:vimim()
            endif
        else
            let s:windowless = empty(a:tab) ? 1 : a:tab
        endif
        call g:vimim_title()
    elseif a:tab == 1 && ( empty(s:vimim_byte_before())
                             \|| s:vimim_byte_before() =~ '\s' )
        let onekey = '\t'
    else
        call s:vimim_super_reset()
        let one_cursor = one_cursor =~ '\w' ? 1 : s:multibyte
        let s:onekey = 1
        let s:windowless = a:tab
        sil!call s:vimim_start()
        if s:windowless < 2
            let onekey = s:vimim_onekey_action(0)
        elseif col("$")-col(".") && col("$")-col(".") < one_cursor + 1
            let onekey = '\<Right>' " gi at the end of the cursor line
        endif
    endif
    sil!call s:vimim_onekey_hjkl_maps()
    if empty(onekey) || onekey =~ 'Right'
        let onekey .= '\<C-R>=g:vimim_title()\<CR>'
    endif
    sil!exe 'sil!return "' . onekey . '"'
endfunction

function! s:vimim_onekey_action(space)
    let space = a:space ? " " : ""
    if s:seamless_positions == getpos(".")
        let s:smart_enter = 0
        return space  "  space is space after enter
    elseif empty(s:ui.has_dot)
        let onekey = s:vimim_onekey_evils()
        if !empty(onekey)
            sil!exe 'sil!return "' . onekey . '"'
        endif
    endif
    let onekey = space
    if s:vimim_byte_before() =~# s:valid_keyboard
        let onekey = g:vimim()
    elseif s:windowless
        let onekey = s:vimim_menuless_map(space)
    endif
    sil!exe 'sil!return "' . onekey . '"'
endfunction

function! s:vimim_onekey_evils()
    let onekey = ""
    let one_before = s:vimim_byte_before()
    let two_before = getline(".")[col(".")-3]
    if getline(".")[col(".")-3 : col(".")-2] == ".."  " before_before
        " [game] dot dot => quotes => popup menu
        let three_before  = getline(".")[col(".")-4]
        if col(".") < 5 || empty(three_before) || three_before =~ '\s'
            let onekey = "'''''"    "  <=    .. plays mahjong
        elseif three_before =~ "[0-9a-z]"
            let onekey = "'''"      "  <=  xx.. plays hjkl_m
        else
            let onekey = "''"       "  <=  香.. plays same cjk
        endif
        return  "\<BS>\<BS>" . onekey . '\<C-R>=g:vimim()\<CR>'
    endif
    " [..] punctuations can be made not so evil ..
    if one_before =~ "[0-9a-z]" || two_before =~ '\s'
        return ""
    elseif one_before == "'" && two_before =~ s:valid_keyboard
        return ""
    elseif two_before =~ "[0-9a-z]"
        return " "
    elseif has_key(s:all_evils, one_before)
        for char in keys(s:all_evils)
            if two_before ==# char || two_before =~# '\u'
                return " " " no transfer if punctuation punctuation
            endif
        endfor
        " transfer English punctuation to Chinese punctuation
        let bs = s:all_evils[one_before]
        let bs = one_before == "'" ? <SID>vimim_get_single_quote() : bs
        let bs = one_before == '"' ? <SID>vimim_get_double_quote() : bs
        let onekey = "\<Left>\<Delete>" . bs
    endif
    sil!exe 'sil!return "' . onekey . '"'
endfunction

function! g:vimim_screenshot()
    let saved_position = getpos(".")
    let keyboard = get(split(s:keyboard),0)
    let space = repeat(" ", virtcol(".")-len(keyboard)-1)
    if s:vimim_byte_before() =~ "'" || s:keyboard =~ '^vimim'
        let space = ""  " no need to format if cloud
    endif
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
    sil!call s:vimim_stop()
    sil!exe "sil!return '\<Esc>'"
endfunction

function! s:vimim_onekey_hjkl_maps()
    let onekey_list = split("h j k l m n / ? ;")
    if len(s:cjk.filename)
        let onekey_list += s:qwer + ['s']
    endif
    for _ in onekey_list
        exe 'inoremap<expr> '._.' <SID>vimim_onekey_hjkl_map("'._.'")'
    endfor
endfunction

function! <SID>vimim_onekey_hjkl_map(key)
    let key = a:key
    if pumvisible()
            if key ==# 'n' | call s:vimim_reset_after_insert()
        elseif key ==# 'm' | let s:hjkl_m += 1
        elseif key ==# 'h' | let s:hjkl_h += 1   " h
        elseif key ==# 'j' | let key = '\<Down>' " j
        elseif key ==# 'k' | let key = '\<Up>'   " k
        elseif key ==# 'l' | let s:hjkl_l += 1   " l
        elseif key ==# 's' | let s:hjkl__ += 1   " s/t transfer
        elseif key ==# ';'                       " dump omni popup
            let s:popup_list = s:popup_list[:&pumheight-1]
            let key = '\<C-R>=g:vimim_screenshot()\<CR>'
        elseif key =~ "[/?]"
            let key = '\<C-Y>\<C-R>=g:vimim_slash()\<CR>' . key . '\<CR>'
        elseif match(s:qwer, key) > -1
            let s:hjkl_n .= match(s:qwer, key)
        endif
        if key == a:key
            let key = '\<C-R>=g:vimim()\<CR>'
        endif
    endif
    sil!exe 'sil!return "' . key . '"'
endfunction

function! s:vimim_cjk_engine(keyboard)
    let keyboard = a:keyboard
    let results = []
    if keyboard =~# '^i' && keyboard =~ '\d' && empty(s:vimim_shuangpin)
        let results = s:vimim_imode_number(keyboard)
    else
        let keyboard = s:vimim_get_head_without_quote(keyboard)
        let head = s:vimim_get_cjk_head(keyboard)
        if empty(head)
            "  zero tolerance for zero
        elseif empty(s:hjkl_n)
            let results = s:vimim_cjk_match(head)  " swiss-army knife
        endif
    endif
    return results
endfunction

function! s:vimim_get_head_without_quote(keyboard)
    let keyboard = a:keyboard
    if s:ui.has_dot || keyboard =~ '\d' || s:ui.root == 'cloud'
        return keyboard
    endif
    if s:hjkl_m && s:hjkl_m % 2 || keyboard =~ '^\l\l\+'."'''".'$'
        " [shoupin] hjkl_m or 3 tail quotes to control shoupin
        "    hjkl_m || sssss..  =>  sssss'''  =>  s's's's's
        let keyboard = substitute(keyboard, "'", "", 'g')
        let keyboard = join(split(keyboard,'\zs'), "'")
    endif
    if keyboard =~ "'" && keyboard[-1:] != "'"
        " [quote] quote_by_quote: wo'you'yi'ge'meng
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

function! <SID>vimim_rotation()
    if len(s:ui.frontends) < 2 && empty(s:onekey)
        return <SID>ChineseMode()
    endif
    let custom_frontends = []
    for im in s:vimim_get_custom_im_list()
        if im =~ 'english'
            call add(custom_frontends, []) | continue
        endif
        for frontends in s:ui.frontends
            if match(frontends, im) > -1
                call add(custom_frontends, frontends)
            endif
        endfor
    endfor
    if s:windowless
        let custom_frontends = custom_frontends[0:1]
    endif
    let s:toggle_im += 1
    let switch = s:toggle_im % len(custom_frontends)
    let frontends = get(custom_frontends, switch)
    if empty(frontends)
        return s:vimim_chinese_mode(0)
    else
        let s:ui.root = get(frontends,0)
        let s:ui.im   = get(frontends,1)
    endif
    if s:ui.root == 'cloud' && s:ui.im != 'mycloud'
        if s:windowless
            let s:ui.im = s:cloud_default
        else
            let s:cloud_default = s:ui.im
        endif
    endif
    if s:onekey || s:windowless
        return g:vimim_title()
    else
        return s:vimim_chinese_mode(1)
    endif
endfunction

function! <SID>ChineseMode()
    if s:onekey
        sil!call s:vimim_stop()
        if pumvisible()
            return ""
        endif
    endif
    if empty(s:ui.frontends)
        return ""
    else
        let s:toggle_im = 1
        let frontends = get(s:ui.frontends, 0)
        let s:ui.root = get(frontends, 0)
        let s:ui.im   = get(frontends, 1)
    endif
    let switch = &omnifunc ==# 'VimIM' ? 0 : 1
    return s:vimim_chinese_mode(switch)
endfunction

function! s:vimim_chinese_mode(switch)
    if a:switch
        sil!call s:vimim_chinesemode_start()
    else
        sil!call s:vimim_chinesemode_stop()
    endif
    return ""
endfunction

function! s:vimim_chinesemode_start()
    let s:chinese_mode = 'dynamic'
    if s:vimim_chinese_input_mode =~ 'static'
        let s:chinese_mode = 'static'
    endif
    sil!call s:vimim_set_statusline()
    sil!call s:vimim_set_plugin_conflict()
    sil!call s:vimim_super_reset()
    if s:vimim_punctuation
        inoremap<expr><C-^> <SID>vimim_punctuation_toggle()
        call s:vimim_punctuations_maps()
    endif
    sil!call s:vimim_start()
    let &titlestring = s:logo . s:vimim_get_title()
    if s:chinese_mode =~ 'dynamic'
        let s:seamless_positions = getpos(".")
        let vimim_cloud = get(split(s:vimim_cloud,','), 0)
        if s:ui.im =~ 'wubi\|erbi' || vimim_cloud =~ 'wubi'
            for char in s:az_list
                sil!exe 'inoremap ' . char . ' <C-R>=g:vimim_wubi()<CR>'
                \ . char . '<C-R>=g:vimim()<CR>'
            endfor
        else    " dynamic alphabet trigger for all but wubi
            let not_used_keys = s:ui.has_dot == 1 ? "[0-9]" : "[0-9']"
            for char in s:valid_keys
                if char !~# not_used_keys
                    sil!exe 'inoremap <silent> ' . char .
                    \ ' <C-R>=pumvisible() ? "<C-E>" : ""<CR>'
                    \ . char . '<C-R>=g:vimim()<CR>'
                endif
            endfor
        endif
    elseif s:chinese_mode =~ 'static'
        for char in s:az_list  " avoid mapping caps
            sil!exe 'inoremap <silent> ' . char .
            \ ' <C-R>=pumvisible() ? "<C-Y>" : ""<CR>' . char
        endfor
        if !pumvisible()
            return s:vimim_static_action("")
        endif
    endif
    return ""
endfunction

function! s:vimim_chinesemode_stop()
    sil!call s:vimim_stop()
    sil!call s:vimim_restore_plugin_conflict()
    imap<silent><C-^> <Plug>VimimOneKey
    if mode() == 'n'
        :redraw!
    endif
endfunction

function! s:vimim_get_custom_im_list()
    let custom_im_toggle_list = []
    if s:vimim_toggle_list =~ ","
        let custom_im_toggle_list = split(s:vimim_toggle_list, ",")
    elseif len(s:ui.frontends)
        for frontends in s:ui.frontends
            call add(custom_im_toggle_list, get(frontends,1))
        endfor
    endif
    return custom_im_toggle_list
endfunction

function! <SID>vimim_punctuation_toggle()
    let s:toggle_punctuation = (s:toggle_punctuation + 1) % 2
    call s:vimim_set_statusline()
    call s:vimim_punctuations_maps()
    return ""
endfunction

function! s:vimim_static_action(space)
    let space = a:space
    if s:vimim_byte_before() =~# s:valid_keyboard
        let space = g:vimim()
    endif
    sil!exe 'sil!return "' . space . '"'
endfunction

function! s:vimim_set_keyboard_list(column_start, keyboard)
    let s:starts.column = a:column_start
    if s:keyboard !~ '\S\s\S'
        let s:keyboard = a:keyboard
    endif
endfunction

function! s:vimim_get_seamless(current_positions)
    if empty(s:seamless_positions)
        return -1
    endif
    let seamless_bufnum = s:seamless_positions[0]
    let seamless_lnum = s:seamless_positions[1]
    let seamless_off = s:seamless_positions[3]
    if seamless_bufnum != a:current_positions[0]
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
        if char !~ s:valid_keyboard
            return -1
        endif
    endfor
    let s:starts.row = seamless_lnum
    return seamless_column
endfunction

" ============================================= }}}
let s:VimIM += [" ====  imode            ==== {{{"]
" =================================================

function! s:vimim_dictionary_numbers()
    let s:loops = {}
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
    let s:quantifiers.y = "月叶亿"
    let s:quantifiers.z = "种只张株支总枝盏座阵桩尊则站幢宗兆"
endfunction

function! s:vimim_imode_loop()
    if !empty(s:loops)
        return
    endif
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
    let antonym = "，。 “” ‘’ （） 【】 〖〗 《》 胜败 真假 石金"
    let imode_list = numbers + split(antonym)
    for loop in imode_list
        let loops = split(loop,'\zs')
        for i in range(len(loops))
            let j = i==len(loops)-1 ? 0 : i+1
            let s:loops[loops[i]] = loops[j]
        endfor
    endfor
endfunction

function! s:vimim_imode_chinese(char_before)
    call s:vimim_imode_loop()
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

let s:translators = {}
function! s:translators.translate(english) dict
    let inputs = split(a:english)
    return join(map(inputs,'get(self.dict,tolower(v:val),v:val)'), '')
endfunction

function! s:vimim_imode_today_now(keyboard)
    let single  = " year sunday monday tuesday wednesday thursday"
    let single .= " friday saturday month day hour minute second"
    let double  = join(split("年 日 一 二 三 四 五 六"), " 星期")
    let double .= " 月 日 时 分 秒"
    let chinese = copy(s:translators)
    let chinese.dict = s:vimim_key_value_hash(single, double)
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

function! s:vimim_url_xx_to_chinese(xx)
    " %E9%A6%AC => \xE9\xA6\xAC => 馬 u99AC
    let output = a:xx
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
    let char_before = ""
    if s:vimim_byte_before() !~ '\s'
        let start = col(".") - 1 - s:multibyte
        let char_before = getline(".")[start : start+s:multibyte-1]
        if char_before !~ '[^\x00-\xff]'
            let char_before = ""
        elseif match(values(s:all_evils),char_before) > -1
            let char_before = ""
        endif
    endif
    return char_before
endfunction

function! s:vimim_byte_before()
    return getline(".")[col(".")-2]
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
    endif
    return 1
endfunction

function! s:vimim_digit_for_cjk(chinese, info)
    " (1) gi ma   马   => filter with   7712  <=>  mali 7 4
    " (2) gi mali 马力 => filter with 7 4002  <=>  mali74
    let chinese = substitute(a:chinese,'[\x00-\xff]','','g')
    let digit_head = ""
    let digit_tail = ""
    for cjk in split(chinese, '\zs')
        let grep = "^" . cjk
        let line = match(s:cjk.lines, grep)
        if line < 0
            continue
        else
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

function! s:vimim_cjk_extra_text(chinese)
    let ddddd = char2nr(a:chinese)
    let xxxx  = printf('u%04x', ddddd)
    let unicode = ddddd . s:space . xxxx
    if s:vimim_cjk()
        let unicode = repeat(s:space,3) . xxxx . s:space . ddddd
        let line = match(s:cjk.lines, "^" . a:chinese)
        if line > -1
            let values  = split(get(s:cjk.lines, line))
            let digit   = get(values, 1)
            let frequency = get(values, -1) !~ '\D' ? 1 : 0
            let pinyin  = join(frequency ? values[2:-2] : values[2:])
            let unicode = digit . s:space . xxxx . s:space . pinyin
        endif
    endif
    return unicode
endfunction

function! s:vimim_get_cjk_head(keyboard)
    let keyboard = a:keyboard
    if empty(s:cjk.filename) || keyboard =~ "'"
        return ""
    endif
    if keyboard =~# '^i' " 4corner_shortcut: iuuqwuqew => 77127132
        let keyboard = s:vimim_qwertyuiop_1234567890(keyboard[1:])
    endif
    let head = 0
    if s:touch_me_not || len(keyboard) == 1
        let head = keyboard
    elseif keyboard =~ '\d'
        if keyboard =~ '^\d' && keyboard !~ '\D'
            let head = keyboard
            if len(keyboard) > 4
                " output is 6021 for input 6021272260021762
                let head = s:vimim_get_head(keyboard, 4)
            endif
        elseif keyboard =~# '^\l\+\d\+\>'
            let head = keyboard        "  ma7 ma77 ma771 ma7712
            let digit = match(keyboard,'\d')
            let alpha = keyboard[0 : digit-1]
            let digit = keyboard[digit :]
            let keyboards = s:vimim_get_pinyin_from_pinyin(alpha)
            if len(keyboards)
                let s:hjkl_n = digit   " 74 in mali74
                return alpha
            endif
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
    elseif empty(s:english.line) " muuqwxeyqpjeqqq => m7712x3610j3111
        if keyboard =~# '^\l' && len(keyboard)%5 < 1
            let llll = keyboard[1:4]  " awwwr arrow color
            let dddd = s:vimim_qwertyuiop_1234567890(llll)
            if !empty(dddd)
                let ldddd = keyboard[0:0] . dddd
                let keyboard = ldddd . keyboard[5:-1]
                let head = s:vimim_get_head(keyboard, 5)
            endif
        else  " get single character from cjk
            let head = keyboard
        endif
    endif
    return head
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

function! s:vimim_qwertyuiop_1234567890(keyboard)
    if a:keyboard =~ '\d'
        return ""
    endif
    let dddd = ""   " output is 7712 for input uuqw
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
    if empty(keyboard) || empty(s:vimim_cjk())
        return []
    endif
    let grep_frequency = '.*' . '\s\d\+$'
    let grep = ""
    if keyboard =~ '\d'
        if keyboard =~# '^\l\l\+[1-4]\>' && empty(len(s:hjkl_n))
            " cjk pinyin with tone: huan2hai2 yi1
            let grep = keyboard . '[a-z ]'
        else
            let digit = ""
            if keyboard =~ '^\d\+' && keyboard !~ '[^0-9]'
                let digit = keyboard   " free style digit: 7 77 771 7712
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
        if len(keyboard) == 1
            " cjk single-char-list by frequency y72/yue72 l72/le72
            let grep = '[ 0-9]' . keyboard . '\l*\d' . grep_frequency
            if keyboard == 'u'  "  214 standard unicode index
                let grep = ' u\( \|$\)'
            endif
        elseif keyboard =~# '^\l\+'
            " cjk multiple-char-list without frequency: huan2hai2
            " support all cases: /huan /hai /yet /huan2 /hai2
            let grep = '[ 0-9]' . keyboard . '[0-9]'
        endif
    endif
    let results = []
    if !empty(grep)
        let line = match(s:cjk.lines, grep)
        while line > -1
            let values = split(get(s:cjk.lines, line))
            let frequency = get(values, -1)
            if frequency =~ '\l'
                let frequency = 9999
            endif
            let chinese_frequency = get(values,0) . ' ' . frequency
            call add(results, chinese_frequency)
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
    " (1) "quick and dirty" way to transfer Chinese to Chinese
    " (2) 20% of the effort to solve 80% of the problem using one2one
    if s:vimim_cjk()
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

function! <SID>vimim_visual_ctrl6()
    let column = virtcol("'<'") - 2
    let space = "\<C-R>=repeat(' '," . column . ")\<CR>"
    let lines = split(getreg('"'), '\n')
    let line = get(lines,0)
    let key = ""
    if len(lines) == 1 && len(line) == s:multibyte
        " highlight one chinese => get antonym or number loop
        let results = s:vimim_imode_chinese(line)
        if !empty(results)
            let key = "gvr" . get(results,0) . "ga"
        endif
        if s:vimim_cjk()
            let line = match(s:cjk.lines, "^".line)
            let &titlestring = s:space . get(s:cjk.lines,line)
        endif
        return feedkeys(key)
    endif
    let s:onekey = 1
    let onekey = "\<C-R>=g:vimim()\<CR>"
    sil!call s:vimim_start()
    sil!call s:vimim_onekey_hjkl_maps()
    if len(lines) < 2
        " highlight multiple chinese => show property of each
        let chinese = get(split(line,'\zs'),0)
        let s:seamless_positions = getpos("'<'")
        let ddddd = char2nr(chinese)
        let key = ddddd =~ '\d\d\d\d\d' ? 'u'.ddddd : line
        let key = "gvc" . key . onekey
    elseif match(lines,'\d') > -1 && join(lines) !~ '[^0-9[:blank:].]'
        " highlight digit block => count*average=summary
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
        let key = "O^\<C-D>" . space . "''''" . onekey
    endif
    sil!call feedkeys(key)
endfunction

" ============================================= }}}
let s:VimIM += [" ====  input: english   ==== {{{"]
" =================================================

function! s:vimim_get_english(keyboard)
    let keyboard = a:keyboard
    if empty(s:english.filename)
        return ""  " english: obama/now/version/ice/o2
    elseif empty(s:english.lines)
        let s:english.lines = s:vimim_readfile(s:english.filename)
    endif
    " [sql] select english from vimim.txt
    let grep = '^' . keyboard . '\s\+'
    let cursor = match(s:english.lines, grep)
    " [pinyin]  cong  => cong
    " [english] congr => congratulation  haag => haagendazs
    let keyboards = s:vimim_get_pinyin_from_pinyin(keyboard)
    if cursor < 0 && len(keyboard) > 3 && len(keyboards)
        let grep = '^' . get(split(keyboard,'\d'),0) " mxj7 => mxj
        let cursor = match(s:english.lines, grep)
    endif
    let oneline = ""
    if cursor > -1
        let oneline = get(s:english.lines, cursor)
        if keyboard != get(split(oneline),0) " no surprise if windowless
            let pairs = split(oneline)       " haag haagendazs
            let oneline = join(pairs[1:] + pairs[:0])
            let oneline = keyboard . " " . oneline
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
    if !filereadable(a:datafile)
        return []
    endif
    let lines = []
    if s:localization
        for line in readfile(a:datafile)
            call add(lines, s:vimim_i18n_read(line))
        endfor
    else
        return readfile(a:datafile)
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
                    \ || (tempstr  == "ga"   || tempstr == "na")
                    \ ||  tempstr2 == "ier"
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
    endif
    return pinyinstr
endfunction

function! s:vimim_create_quanpin_table()
    let pinyin_list = s:vimim_get_all_valid_pinyin_list()
    let table = {}
    for key in pinyin_list
        if key[0] == "'"
            let table[key[1:]] = key[1:]
        else
            let table[key] = key
        endif
    endfor
    for shengmu in s:shengmu_list + split("zh ch sh")
        let table[shengmu] = shengmu
    endfor
    return table
endfunction

function! s:vimim_more_pinyin_datafile(keyboard, sentence)
    let candidates = s:vimim_more_pinyin_candidates(a:keyboard)
    if empty(candidates) || s:ui.im !~ 'pinyin'
        return []
    endif
    let results = []
    let lines = s:backend[s:ui.root][s:ui.im].lines
    for candidate in candidates
        let pattern = '^' . candidate . '\>'
        let cursor = match(lines, pattern, 0)
        if cursor < 0
            continue
        elseif a:sentence
            return [candidate]
        endif
        let oneline = get(lines, cursor)
        call extend(results, s:vimim_make_pairs(oneline))
    endfor
    return results
endfunction

function! s:vimim_get_pinyin_from_pinyin(keyboard)
    let keyboard = s:vimim_quanpin_transform(a:keyboard)
    let results = split(keyboard, "'")
    if len(results) > 1
        return results
    endif
    return []
endfunction

function! s:vimim_more_pinyin_candidates(keyboard)
    if empty(s:vimim_shuangpin) && empty(s:english.line)
        " [purpose] make standard layout for popup menu
        " input  =>  mamahuhu
        " output =>  mamahu, mama
    else
        return []
    endif
    let keyboards = s:vimim_get_pinyin_from_pinyin(a:keyboard)
    if empty(keyboards)
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

function! s:vimim_cloud_pinyin(keyboard, match_list)
    let match_list = []
    let keyboards = s:vimim_get_pinyin_from_pinyin(a:keyboard)
    for chinese in a:match_list
        let len_chinese = len(split(chinese,'\zs'))
        let english = join(keyboards[len_chinese :], "")
        let yin_yang = chinese
        if !empty(english)
            let yin_yang .= english
        endif
        call add(match_list, yin_yang)
    endfor
    return match_list
endfunction

" ============================================= }}}
let s:VimIM += [" ====  input: shuangpin ==== {{{"]
" =================================================

function! s:vimim_set_shuangpin()
    if s:vimim_cloud =~ 'shuangpin' || s:ui.im == 'mycloud'
    \|| empty(s:vimim_shuangpin) || !empty(s:shuangpin_table)
        return
    endif
    let rules = s:vimim_shuangpin_generic()
    let rules = s:vimim_get_shuangpin_rules(s:vimim_shuangpin, rules)
    let s:shuangpin_table = s:vimim_create_shuangpin_table(rules)
endfunction

function! s:vimim_shuangpin_transform(keyboard)
    let keyboard = a:keyboard
    let size = strlen(keyboard)
    let ptr = 0
    let output = ""
    let bchar = ""    " workaround for sogou
    while ptr < size
        if keyboard[ptr] !~ "[a-z;]"
            " bypass all non-characters, i.e. 0-9 and A-Z are bypassed
            let output .= keyboard[ptr]
            let ptr += 1
        else
            let sp1 = keyboard[ptr]
            if keyboard[ptr+1] =~ "[a-z;]"
                let sp1 .= keyboard[ptr+1]
            endif
            if has_key(s:shuangpin_table, sp1)
                " the last odd shuangpin code are output as only shengmu
                let output .= bchar . s:shuangpin_table[sp1]
            else
                let output .= sp1 " invalid shuangpin code are preserved
            endif
            let ptr += strlen(sp1)
        endif
    endwhile
    if output[0] == "'"
        return output[1:]
    endif
    return output
endfunction

function! s:vimim_create_shuangpin_table(rule)
    let pinyin_list = s:vimim_get_all_valid_pinyin_list()
    let rules = a:rule
    let sptable = {}
    " generate table for shengmu-yunmu pairs match
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
            endif
            let sptable[sp1] = key
        endif
    endfor
    " the jxqy+v special case handling
    if match(split("abc purple nature flypy"), s:vimim_shuangpin) > -1
        let jxqy = {"jv" : "ju", "qv" : "qu", "xv" : "xu", "yv" : "yu"}
        call extend(sptable, jxqy)
    elseif s:vimim_shuangpin == 'ms'
        let jxqy = {"jv" : "jue", "qv" : "que", "xv" : "xue", "yv" : "yue"}
        call extend(sptable, jxqy)
    endif
    if s:vimim_shuangpin == 'flypy'  " flypy special case handling
        let key   = 'ou eg  er an ao ai aa en oo os  ah  ee ei'
        let value = 'ou eng er an ao ai a  en o  ong ang e  ei'
        call extend(sptable, s:vimim_key_value_hash(key, value))
    endif
    " the nature shuangpin special case handling
    if s:vimim_shuangpin == 'nature'
        let nature = {"aa" : "a", "oo" : "o", "ee" : "e" }
        call extend(sptable, nature)
    endif
    " generate table for shengmu-only match
    for [key, value] in items(rules[0])
        let sptable[value] = key
        if key[0] == "'"
            let sptable[value] = ""
        endif
    endfor
    return sptable
endfunction

function! s:vimim_shuangpin_generic()
    " generate the default value of shuangpin table
    let shengmu_list = {}
    for shengmu in s:shengmu_list
        let shengmu_list[shengmu] = shengmu
    endfor
    let shengmu_list["'"] = "o"
    let yunmu_list = {}
    for yunmu in split("a o e i u v")
        let yunmu_list[yunmu] = yunmu
    endfor
    let shuangpin_rule = [shengmu_list, yunmu_list]
    return shuangpin_rule
endfunction

function! s:vimim_get_shuangpin_rules(shuangpin, rules)
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

" ============================================= }}}
let s:VimIM += [" ====  python           ==== {{{"]
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
import vim, bsddb
encoding = vim.eval("&encoding")
datafile = vim.eval('a:datafile')
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
    let datafile = a:datafile
    let im = s:vimim_get_valid_im_name(a:im)
    if empty(im) || isdirectory(datafile)
        return
    endif
    let s:ui.root = "datafile"
    let s:ui.im = im
    call insert(s:ui.frontends, [s:ui.root, s:ui.im])
    let s:backend.datafile[im] = {}
    let s:backend.datafile[im].root = s:ui.root
    let s:backend.datafile[im].im = im
    let s:backend.datafile[im].name = datafile
    let s:backend.datafile[im].keycode = s:im_keycode[im]
    let s:backend.datafile[im].chinese = s:vimim_chinese(im)
    let s:backend.datafile[im].lines = []
endfunction

function! s:vimim_sentence_datafile(keyboard)
    let keyboard = a:keyboard
    let lines = s:backend[s:ui.root][s:ui.im].lines
    let fuzzy = s:ui.im =~ 'pinyin' ? '\s' : ""
    let pattern = '^' . keyboard . fuzzy
    let cursor = match(lines, pattern)
    if cursor > -1
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
        let cursor = match(lines, pattern)
        if cursor < 0
            continue
        else
            break
        endif
    endwhile
    if cursor < 0
        return ""
    endif
    return keyboard[0 : max-1]
endfunction

function! s:vimim_get_from_datafile(keyboard)
    let lines = s:backend[s:ui.root][s:ui.im].lines
    let fuzzy = s:ui.im =~ 'pinyin' ? '\s' : ""
    let pattern = '^' . a:keyboard . fuzzy
    let cursor = match(lines, pattern)
    if cursor < 0
        return []
    endif
    let oneline = get(lines, cursor)
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
            let oneline = get(lines, cursor)
            let extras = s:vimim_make_pairs(oneline)
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
    let results = s:vimim_make_pairs(oneline)
    if empty(s:english.line) && len(results) && len(results) < 20
        let candidates = s:vimim_more_pinyin_candidates(a:keyboard)
        if len(candidates) > 1
            for candidate in candidates
                let oneline = s:vimim_get_gold_from_bsddb(candidate)
                if empty(oneline) || match(oneline,' ') < 0
                    continue
                endif
                let match_list = s:vimim_make_pairs(oneline)
                if !empty(match_list)
                    call extend(results, match_list)
                endif
                if len(results) > 20*2
                    break
                endif
            endfor
        endif
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

function! s:vimim_set_directory(im, dir)
    let im = s:vimim_get_valid_im_name(a:im)
    if empty(im) || empty(a:dir) || !isdirectory(a:dir)
        return
    endif
    let s:ui.root = "directory"
    let s:ui.im = im
    call insert(s:ui.frontends, [s:ui.root, s:ui.im])
    let s:backend.directory[im] = {}
    let s:backend.directory[im].root = s:ui.root
    let s:backend.directory[im].im = im
    let s:backend.directory[im].name = a:dir
    let s:backend.directory[im].keycode = s:im_keycode[im]
    let s:backend.directory[im].chinese = s:vimim_chinese(im)
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

function! s:vimim_more_pinyin_directory(keyboard, dir)
    let candidates = s:vimim_more_pinyin_candidates(a:keyboard)
    if empty(candidates) || len(s:english.line)
        return []
    endif
    let results = []
    for candidate in candidates
        let filename = a:dir . candidate
        let lines = s:vimim_readfile(filename)
        if !empty(lines)
            call map(lines, 'candidate ." ". v:val')
            call extend(results, lines)
        endif
    endfor
    return results
endfunction

" ============================================= }}}
let s:VimIM += [" ====  backend: clouds  ==== {{{"]
" =================================================

function! s:vimim_set_background_clouds()
    let s:http_exe = ""
    let cloud_defaults = split(s:rc["g:vimim_cloud"],',')
    let s:cloud_default = get(cloud_defaults,0)
    let clouds = split(s:vimim_cloud,',')
    for cloud in clouds
        let cloud = get(split(cloud,'[.]'),0)
        call remove(cloud_defaults, match(cloud_defaults,cloud))
    endfor
    let clouds += cloud_defaults
    let s:vimim_cloud = join(clouds,',')
    let default = get(split(get(clouds,0),'[.]'),0)
    if match(s:rc["g:vimim_cloud"], default) > -1
        let s:cloud_default = default
    endif
    if empty(s:vimim_check_http_executable())
        return 0
    endif
    let s:ui.root = 'cloud'
    for cloud in reverse(split(s:vimim_cloud,','))
        let im = get(split(cloud,'[.]'),0)
        let s:ui.im = im
        call insert(s:ui.frontends, [s:ui.root, s:ui.im])
        let s:backend.cloud[im] = {}
        let s:backend.cloud[im].root = s:ui.root
        let s:backend.cloud[im].im = 0  " used for cloud key
        let s:backend.cloud[im].keycode = s:im_keycode[im]
        let s:backend.cloud[im].name    = s:vimim_chinese(im)
        let s:backend.cloud[im].chinese = s:vimim_chinese(im)
    endfor
endfunction

function! s:vimim_check_http_executable()
    if s:vimim_cloud < 0 && len(s:vimim_mycloud) < 3
        return 0
    elseif len(s:http_exe) > 3
        return s:http_exe
    endif
    " step 1 of 4: try to find libvimim for mycloud
    let libvimim = s:vimim_get_libvimim()
    if libcall(libvimim, "do_geturl", "__isvalid") ==# "True"
        let s:http_exe = libvimim
    endif
    " step 2 of 4: try to use dynamic python:
    if empty(s:http_exe)
        if has('python')                     " +python/dyn
            let s:http_exe = 'Python2 Interface to Vim'
        endif
        if has('python3') && &relativenumber " +python3/dyn
            let s:http_exe = 'Python3 Interface to Vim'
        endif
    endif
    " step 3 of 4: try to find wget
    if empty(s:http_exe) || has("macunix")
        let wget = 'wget'
        let wget_exe = s:plugin . 'wget.exe'
        if filereadable(wget_exe) && executable(wget_exe)
            let wget = wget_exe
        endif
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

function! s:vimim_get_cloud(keyboard)
    let keyboard = a:keyboard  " remove evil leading/trailing quote
    let keyboard = keyboard[:0]  == "'" ? keyboard[1:]  : keyboard
    let keyboard = keyboard[-1:] == "'" ? keyboard[:-2] : keyboard
    if keyboard !~ s:valid_keyboard || empty(s:cloud_default)
        return []
    endif
    let cloud = "s:vimim_get_cloud_" . s:cloud_default . "(keyboard)"
    let results = []
    try
        let results = eval(cloud)
    catch
        sil!call s:vimim_debug(s:cloud_default, v:exception)
    endtry
    if !empty(results) && s:keyboard !~ '\S\s\S'
        let s:keyboard = keyboard
    endif
    return results
endfunction

function! s:vimim_get_from_http(input, cloud)
    if empty(a:input)
        return ""
    elseif empty(s:vimim_check_http_executable())
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
    if empty(s:backend.cloud.sogou.im)  " cloud key
        let key_sogou = "http://web.pinyin.sogou.com/web_ime/patch.php"
        let output = s:vimim_get_from_http(key_sogou, 'sogou')
        if empty(output) || output =~ '502 bad gateway'
            return []
        endif
        let s:backend.cloud.sogou.im = get(split(output,'"'),1)
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
            let chinese = get(item_list,0)
            let english = strpart(a:keyboard, 0, get(item_list,1))
            let new_item = english . " " . chinese
            call add(match_list, new_item)
        endif
    endfor
    return match_list
endfunction

function! s:vimim_get_cloud_qq(keyboard)
    " http://ime.qq.com/fcgi-bin/getword?key=32&q=mxj
    let url = 'http://ime.qq.com/fcgi-bin/'
    if empty(s:backend.cloud.qq.im)  " cloud key
        let key_qq = url . 'getkey'
        let output = s:vimim_get_from_http(key_qq, 'qq')
        let key_qq = get(split(output,'"'),3)
        if len(key_qq) != 32
            return []
        endif
        let s:backend.cloud.qq.im = key_qq
    endif
    let input  = url
    let clouds = split(s:vimim_cloud,',')    "  qq.shuangpin.abc,google
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
        let shuangpin = get(split(vimim_cloud,"[.]"),-1)
        let st = match(split(s:rc["g:vimim_shuangpin"]),shuangpin)+1
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
    if s:localization
        " qq => {"q":"fuck","rs":["\xe5\xa6\x87"],
        let output = s:vimim_i18n_read(output)
    endif
    let key = 'rs'
    let match_list = []
    let output_hash = eval(output)
    if type(output_hash) == type({}) && has_key(output_hash, key)
        let match_list = output_hash[key]
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
    let input .= '?langpair=en|zh'
    let input .= '&num=20'
    let input .= '&tl_app=3'
    let input .= '&tlqt=1'
    let input .= '&text=' . a:keyboard
    let output = join(split(s:vimim_get_from_http(input,'google')))
    let match_list = []
    if s:localization
        " google => '[{"ew":"fuck","hws":["\u5987\u4EA7\u79D1",]},]'
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
    let key = 'hws'
    let output_hash = get(eval(output),0)
    if type(output_hash) == type({}) && has_key(output_hash, key)
        let match_list = output_hash[key]
    endif
    return s:vimim_cloud_pinyin(a:keyboard, match_list)
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
    let match_list = []
    for item_list in output_list
        let chinese = get(item_list,0)
        if chinese =~# '\w'
            continue
        endif
        let english = strpart(a:keyboard, get(item_list,1))
        let yin_yang = chinese . english
        call add(match_list, yin_yang)
    endfor
    return match_list
endfunction

function! s:vimim_get_cloud_all(keyboard)
    let results = []
    for cloud in split(s:rc["g:vimim_cloud"], ',')
        let start = localtime()
        let s:cloud_default = cloud
        let outputs = s:vimim_get_cloud(a:keyboard)
        if len(results) > 1
            call add(results, s:space)
        endif
        let title  = a:keyboard . s:space
        let title .= s:vimim_chinese(cloud)
        let title .= s:vimim_chinese('cloud')
        let title .= s:vimim_chinese('input')
        let duration = localtime() - start
        if duration
            let title .= s:space . string(duration)
        endif
        call add(results, title)
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
    let s:mycloud_arg  = 0
    let s:mycloud_func = 0
    let s:mycloud_mode = 0
    let s:mycloud_host = "localhost"
    let s:mycloud_port = 10007
    let mycloud = 0
    if empty(s:vimim_mycloud)
        let mycloud = s:vimim_check_mycloud_plugin_libcall()
    else
        let mycloud = s:vimim_check_mycloud_plugin_url()
    endif
    if !empty(mycloud)
        let s:ui.root = 'cloud'
        let s:ui.im = 'mycloud'
        call insert(s:ui.frontends, [s:ui.root, s:ui.im])
        let s:backend.cloud.mycloud = {}
        let s:backend.cloud.mycloud.root = s:ui.root
        let s:backend.cloud.mycloud.im = mycloud
        let s:backend.cloud.mycloud.name    = s:vimim_chinese(s:ui.im)
        let s:backend.cloud.mycloud.chinese = s:vimim_chinese(s:ui.im)
        let ret = s:vimim_access_mycloud(mycloud, "__getkeychars")
        let s:backend.cloud.mycloud.keycode = split(ret,"\t")[0]
        let ret = s:vimim_access_mycloud(mycloud, "__getname")
        let s:backend.cloud.mycloud.directory = split(ret,"\t")[0]
    endif
endfunction

function! s:vimim_access_mycloud(cloud, cmd)
    " same function to access mycloud by libcall() or system()
    let ret = ""
    if s:mycloud_mode == "libcall"
        let cmd = empty(s:mycloud_arg) ? a:cmd : s:mycloud_arg." ".a:cmd
        let ret = libcall(a:cloud, s:mycloud_func, cmd)
    elseif s:mycloud_mode == "python"
        let ret = s:vimim_mycloud_python_client(a:cmd)
    elseif s:mycloud_mode == "system"
        let ret = system(a:cloud." ".shellescape(a:cmd))
    elseif s:mycloud_mode == "www"
        let input = a:cloud . s:vimim_rot13(a:cmd)
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
    let ret = s:vimim_access_mycloud(a:cloud, "__isvalid")
    if split(ret, "\t")[0] == "True"
        return 1
    endif
    return 0
endfunction

function! s:vimim_get_libvimim()
    let libvimim = ""
    if has("win32") || has("win32unix")
        let libvimim = "libvimim.dll"
    elseif has("unix")
        let libvimim = "libvimim.so"
    endif
    let libvimim = s:plugin . libvimim
    if filereadable(libvimim)
        if has("win32") && libvimim[-4:] ==? ".dll"
            let libvimim = libvimim[:-5]
        endif
        return libvimim
    endif
    return ""
endfunction

function! s:vimim_check_mycloud_plugin_libcall()
    " we do plug-n-play for libcall(), not for system()
    let cloud = s:vimim_get_libvimim()
    if !empty(cloud)
        let s:mycloud_arg = ""
        let s:mycloud_mode = "libcall"
        let s:mycloud_func = 'do_getlocal'
        if s:vimim_access_mycloud_isvalid(cloud)
            return cloud
        endif
    endif
    " libcall check failed, we now check system()
    if has("gui_win32")
        return 0
    endif
    " on linux, we do plug-n-play
    let cloud = s:plugin . 'mycloud/mycloud'
    if !executable(cloud)
        if !executable("python")
            return 0
        endif
        let cloud = "python " . cloud
    endif
    " in POSIX system, we can use system() for mycloud
    let s:mycloud_mode = "system"
    if s:vimim_access_mycloud_isvalid(cloud)
        return cloud
    endif
    return 0
endfunction

function! s:vimim_check_mycloud_plugin_url()
    " we do set-and-play on all systems
    let part = split(s:vimim_mycloud, ':')
    let lenpart = len(part)
    if lenpart <= 1
        sil!call s:vimim_debug('info', "invalid_cloud_plugin_url")
    elseif part[0] ==# 'app'
        if !has("gui_win32")
            " strip the first root if contains ":"
            if lenpart == 3
                let cloud = part[1] . ':' . part[2]
                if part[1][0] == '/'
                    let cloud = part[1][1:] . ':' . part[2]
                endif
            elseif lenpart == 2
                let cloud = part[1]
            endif
            " in POSIX system, we can use system() for mycloud
            if executable(split(cloud, " ")[0])
                let s:mycloud_mode = "system"
                if s:vimim_access_mycloud_isvalid(cloud)
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
        endif
    elseif part[0] ==# "dll"
        let base = 0
        if len(part[1]) == 1
            let base = 1
        endif
        " provide function name
        let s:mycloud_func = 'do_getlocal'
        if lenpart >= base+4
            let s:mycloud_func = part[base+3]
        endif
        let s:mycloud_arg = ""  " provide argument
        if lenpart >= base+3
            let s:mycloud_arg = part[base+2]
        endif
        " provide the dll
        let cloud = part[1]
        if base == 1
            let cloud .= ':' . part[2]
        endif
        if filereadable(cloud)
            let s:mycloud_mode = "libcall"
            " strip off the .dll suffix, only required for win32
            if has("win32") && cloud[-4:] ==? ".dll"
                let cloud = cloud[:-5]
            endif
            if s:vimim_access_mycloud_isvalid(cloud)
                return cloud
            endif
        endif
    elseif part[0] ==# "http" || part[0] ==# "https"
        if !empty(s:vimim_check_http_executable()) && !empty(s:http_exe)
            let s:mycloud_mode = "www"
            if s:vimim_access_mycloud_isvalid(s:vimim_mycloud)
                return s:vimim_mycloud
            endif
        endif
    else
        sil!call s:vimim_debug('alert', "invalid_cloud_plugin_url")
    endif
    return 0
endfunction

function! s:vimim_get_mycloud(keyboard)
    let output = 0
    let mycloud = s:backend.cloud.mycloud.im
    try
        let output = s:vimim_access_mycloud(mycloud, a:keyboard)
    catch
        sil!call s:vimim_debug('alert', 'mycloud', v:exception)
    endtry
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

" ============================================= }}}
let s:VimIM += [" ====  /search          ==== {{{"]
" =================================================

function! g:vimim_search_next()
    let results = []
    let english = @/
    if english =~ '\<' && english =~ '\>'
        let english = substitute(english,'[<>\\]','','g')
    endif
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
        let @/ = slash
        if empty(search(slash,'nw'))
            let @/ = english
        endif
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
    " 1/3 first try search from cloud/mycloud
    if s:ui.im == 'mycloud'     " /search from mycloud
        let results = s:vimim_get_mycloud(keyboard)
    elseif s:ui.root == 'cloud' || keyboard[-1:] == "'"
        let results = s:vimim_get_cloud(keyboard)
    endif
    if len(results)
        return results
    endif
    " 2/3 search unicode or cjk /search unicode /u808f
    let ddddd = s:vimim_get_unicode_ddddd(keyboard)
    if empty(ddddd) && s:vimim_cjk()
        " /muuqwxeyqpjeqqq /m7712x3610j3111 /ma77xia36ji31
        while len(keyboard) > 1
            let head = s:vimim_get_cjk_head(keyboard)
            if empty(head)
                break
            else
                let chars = s:vimim_cjk_match(head)
                let collection = "[" . join(chars,'') . "]"
                call add(results, collection)
                let keyboard = strpart(keyboard,len(head))
            endif
        endwhile
        if len(results) > 1
            let results = [join(results,'')]
        endif
    else
        let results = [nr2char(ddddd)]
    endif
    if len(results)
        return results
    endif
    " 3/3 search datafile and english: /ma and /horse
    let s:english.line = s:vimim_get_english(keyboard)
    if empty(s:english.line) && keyboard =~ s:valid_keyboard
        let results = s:vimim_embedded_backend_engine(keyboard)
    else
        let results = split(s:english.line)
    endif
    return results
endfunction

" ============================================= }}}
let s:VimIM += [" ====  core workflow    ==== {{{"]
" =================================================

function! s:vimim_set_vimrc()
    set title imdisable noshowmatch
    set shellslash
    set nolazyredraw
    set whichwrap=<,>
    set complete=.
    set completeopt=menuone
    set omnifunc=VimIM
endfunction

function! s:vimim_save_vimrc()
    let s:cpo         = &cpo
    let s:omnifunc    = &omnifunc
    let s:complete    = &complete
    let s:completeopt = &completeopt
    let s:whichwrap   = &whichwrap
    let s:laststatus  = &laststatus
    let s:statusline  = &statusline
    let s:titlestring = &titlestring
    let s:shellslash  = &shellslash
    let s:lazyredraw  = &lazyredraw
endfunction

function! s:vimim_restore_vimrc()
    let &cpo         = s:cpo
    let &omnifunc    = s:omnifunc
    let &complete    = s:complete
    let &completeopt = s:completeopt
    let &whichwrap   = s:whichwrap
    let &laststatus  = s:laststatus
    let &statusline  = s:statusline
    let &titlestring = s:titlestring
    let &shellslash  = s:shellslash
    let &lazyredraw  = s:lazyredraw
    let &pumheight   = s:pumheights.saved
endfunction

function! s:vimim_start()
    sil!call s:vimim_set_vimrc()
    sil!call s:vimim_set_color()
    sil!call s:vimim_set_shuangpin()
    sil!call s:vimim_set_keycode()
    sil!call s:vimim_common_maps()
    inoremap <silent> <expr> <Esc>   <SID>vimim_esc()
    inoremap <silent> <expr> <Space> <SID>vimim_space()
    inoremap <silent> <expr> <BS>    <SID>vimim_backspace()
    inoremap <silent> <expr> <CR>    <SID>vimim_enter()
    inoremap <silent> <expr> <C-H>   <SID>vimim_rotation()
endfunction

function! s:vimim_stop()
    sil!call s:vimim_restore_vimrc()
    sil!call s:vimim_super_reset()
    sil!call s:vimim_imap_off()
endfunction

function! s:vimim_super_reset()
    sil!call s:vimim_reset_before_anything()
    sil!call s:vimim_reset_before_omni()
    sil!call s:vimim_reset_after_insert()
endfunction

function! s:vimim_reset_before_anything()
    let s:keyboard = ""
    let s:onekey = 0
    let s:windowless = 0
    let s:smart_enter = 0
    let s:has_pumvisible = 0
    let s:show_extra_menu = 0
    let s:pattern_not_found = 0
    let s:popup_list = []
endfunction

function! s:vimim_reset_before_omni()
    let s:english.line = ""
    let s:touch_me_not = 0
endfunction

function! s:vimim_reset_after_insert()
    let s:hjkl_n = ""   "   reset for nothing
    let s:hjkl_h = 0    "  ctrl-h for jsjsxx
    let s:hjkl_l = 0    "  toggle label length
    let s:hjkl_m = 0    "  toggle cjjp/c'j'j'p
    let s:hjkl__ = 0    "  toggle simplified/traditional
    let s:match_list = []
    let s:pageup_pagedown = 0
endfunction

function! s:vimim_imap_off()
    let keys  = range(10)
    let keys += split('<Esc> <Space> <BS> <CR> <C-H>')
    let keys += keys(s:evils)
    let keys += keys(s:punctuations)
    let keys += s:valid_keys
    for _ in keys
        if len(maparg(_, 'i'))
            sil!exe 'iunmap '. _
        endif
    endfor
    highlight! link Cursor NONE
endfunction

function! s:vimim_set_backend_embedded()
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
    if has("python") " bsddb is from Python 2 only in 46,694,400 Bytes
        let datafile = s:vimim_filereadable("vimim.gbk.bsddb")
        if !empty(datafile)
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
    let all_digit = 1
    while start_column
        if one_before =~# s:valid_keyboard
            let start_column -= 1
            if one_before !~# "[0-9']" && empty(s:ui.has_dot)
                let last_seen_nonsense_column = start_column
                if all_digit
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
    " [windowless] gi mamahuhuhu space enter basckspace
    if s:smart_enter =~ "menuless_correction"
        return [s:space]
    endif
    " [hjkl] less is more
    let results = s:vimim_cache()
    if empty(results)
        sil!call s:vimim_reset_before_omni()
    else
        return s:vimim_popupmenu_list(results)
    endif
    let keyboard = a:keyboard
    if empty(str2nr(keyboard))
        " input is alphabet only, bad for 23554022100080204420
    else
        let keyboard = get(split(s:keyboard),0)
    endif
    if empty(keyboard) || keyboard !~ s:valid_keyboard
        return []
    else   " [english] first check if it is english or not
        let s:english.line = s:vimim_get_english(keyboard)
    endif
    if s:onekey  " [game] made life less boring
        let results = s:vimim_get_hjkl_game(keyboard)
        if len(results)
            return s:vimim_popupmenu_list(results)
        endif
    endif
   " [cjk] why not make cjk to both static and dynamic mode?
    if len(s:cjk.filename) || s:ui.im =~ 'pinyin'
        let results = s:vimim_cjk_engine(keyboard)
        if len(results)
            return s:vimim_popupmenu_list(results)
        elseif len(s:hjkl_n) && s:keyboard !~ "'"
            let keyboard = get(split(keyboard,'\d'),0)  " mali74
        elseif get(split(s:keyboard),1) =~ "'"  " ssss.. for cloud
            let keyboard = s:vimim_get_head_without_quote(keyboard)
        endif
    endif
    if s:ui.im == 'mycloud'  " [mycloud] get chunmeng from local or www
        let results = s:vimim_get_mycloud(keyboard)
        if len(results)
            let s:show_extra_menu = 1
            return s:vimim_popupmenu_list(results)
        endif
    endif
    " [shuangpin] support 6 major shuangpin rules
    if len(s:vimim_shuangpin) && empty(s:has_pumvisible)
        let keyboard = s:vimim_shuangpin_transform(keyboard)
        let s:keyboard = keyboard
    endif
    " [cloud] to make dream come true for multiple clouds
    if s:ui.root == 'cloud' || keyboard[-1:] == "'"
        let results = s:vimim_get_cloud(keyboard)
    endif
    if empty(results)
        " [wubi] support auto insert on the 4th
        if s:ui.im =~ 'wubi\|erbi' || s:vimim_cloud =~ 'wubi'
            if s:chinese_mode =~ 'dynamic' && len(keyboard) > 4
                let start = 4*((len(keyboard)-1)/4)
                let keyboard = strpart(keyboard, start)
                let s:keyboard = keyboard
            endif
        endif
        " [backend] plug-n-play embedded backend engine
        let results = s:vimim_embedded_backend_engine(keyboard)
    endif
    " [english] English cannot be ignored!
    if len(s:english.line)
        if s:keyboard !~ "'"  " english color
            let s:keyboard = keyboard
        endif
        let results = s:vimim_make_pairs(s:english.line) + results
    endif
    " [the_last_resort] either force shoupin or force cloud
    if s:onekey && empty(results)
        if len(keyboard) > 1
            let shoupin = s:vimim_get_head_without_quote(keyboard."'''")
            let results = s:vimim_cjk_match(shoupin)
            if empty(results)
                let results = s:vimim_get_cloud(keyboard)
            endif
        else    " for onekey continuity: abcdefghijklmnopqrstuvwxyz..
            let i = keyboard == 'i' ? "我" : s:space
            let results = split(repeat(i,5),'\zs')
        endif
        if empty(results)
            let s:pattern_not_found = 1
        endif
    endif
    return s:vimim_popupmenu_list(results)
endif
endfunction

function! s:vimim_popupmenu_list(lines)
    let s:match_list = a:lines
    if empty(a:lines) || type(a:lines) != type([])
        return []
    elseif s:vimim_cjk() && len(s:hjkl_n)
        let s:match_list = s:vimim_onekey_digit_filter(a:lines)
    endif
    let keyboards = split(s:keyboard)   " mmmm => ['m',"m'm'm"]
    let tail = len(keyboards) < 2 ? "" : get(keyboards,1)
    " [popup] it is art to set up popup menu height
    let &pumheight = empty(s:onekey) ? 5 : 10
    let s:pumheights.current = copy(&pumheight)
    if s:touch_me_not
        let &pumheight = 0
    elseif s:hjkl_l
        let &pumheight = s:hjkl_l % 2 ? 0 : s:pumheights.current
    endif
    let label = 1
    let one_list = []
    let popup_list = []
    for chinese in s:match_list
        let complete_items = {}
        if s:vimim_cjk() && s:hjkl__ && s:hjkl__%2
            let simplified_traditional = ""
            for char in split(chinese, '\zs')
                let simplified_traditional .= s:vimim_1to1(char)
            endfor
            let chinese = simplified_traditional
        endif
        let label2 = s:vimim_get_labeling(label)
        if empty(s:touch_me_not)
            let menu = ""
            let pairs = split(chinese)
            let pair_left = get(pairs,0)
            if len(pairs) > 1 && pair_left !~ '[^\x00-\xff]'
                let chinese = get(pairs,1)
                if s:show_extra_menu
                    let menu = pair_left
                endif
            endif
            if s:hjkl_h && s:hjkl_h%2
                let chars = split(chinese,'\zs')
                if empty(tail) || len(chars) == 1
                    let char = get(chars,0)
                    let menu = s:vimim_cjk_extra_text(char)
                endif
            endif
            let english = '*'  " sexy english flag
            if match(split(s:english.line), chinese) < 0
                let english = ' '
            endif
            let label2 = english . label2
            let labeling = printf('%2s ',label2)
            let chinese .= empty(tail) ? '' : tail
            let complete_items["abbr"] = labeling . chinese
            let complete_items["menu"] = menu
        endif
        let onerow_label = label . "."
        if s:windowless
            let onerow_label = label2
            if s:vimim_cjk()     " display english flag plus 4corner
                let star = substitute(onerow_label,'\w','','g')
                let digit = s:vimim_digit_for_cjk(chinese,1)
                let onerow_label = star . digit[:3]
            elseif label < 11    " 234567890 for windowless selection
                let onerow_label = label2[:-2]
            endif
        endif
        call add(one_list, onerow_label . chinese)
        let label += 1
        let complete_items["dup"] = 1
        let complete_items["word"] = empty(chinese) ? s:space : chinese
        call add(popup_list, complete_items)
    endfor
    if s:onekey
        call g:vimim_title()
        set completeopt=menuone   " for hjkl_n refresh
        let s:popup_list = popup_list
        if s:windowless && empty(s:touch_me_not)
            set completeopt=menu  " for direct insert
            let s:cursor_at_menuless = 0
            let vimim = "VimIM" .s:space.'  '.join(keyboards,"").'  '
            let &titlestring = vimim . join(one_list)
            let &pumheight = 1
            call s:vimim_set_titlestring(1)
            Debug s:match_list[:4]
        elseif s:touch_me_not
            let &titlestring = s:logo . s:today
        endif
    endif
    return popup_list
endfunction

function! s:vimim_embedded_backend_engine(keyboard)
    let keyboard = a:keyboard
    if empty(s:ui.im) || empty(s:ui.root)
        return []
    elseif s:ui.has_dot == 2 && keyboard !~ "[']"
        let keyboard = s:vimim_quanpin_transform(keyboard)
    endif
    let results = []
    let head = 0
    let backend = s:backend[s:ui.root][s:ui.im]
    if s:ui.root =~# "directory"
        let dir = backend.name
        let head = s:vimim_sentence_directory(keyboard, dir)
        let results = s:vimim_readfile(dir . head)
        if keyboard ==# head && len(results) && len(results) < 20
            let extras = s:vimim_more_pinyin_directory(keyboard, dir)
            if len(extras) && len(results)
                call map(results, 'keyboard ." ". v:val')
                call extend(results, extras)
            endif
        endif
    elseif s:ui.root =~# "datafile"
        let datafile = backend.name
        if datafile =~ "bsddb"
            if !exists("s:bsddb_4MB_in_memory_50MB_on_disk")
                let s:bsddb_4MB_in_memory_50MB_on_disk = 1
                sil!call s:vimim_initialize_bsddb(datafile)
            endif
            let head = s:vimim_get_stone_from_bsddb(keyboard)
            let results = s:vimim_get_from_database(head)
        else
            if empty(backend.lines)
                let backend.lines = s:vimim_readfile(datafile)
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
    if empty(s:pageup_pagedown)
        let s:keyboard = ""
    endif
    if s:vimim_byte_before() =~# s:valid_keyboard
        let key = '\<C-X>\<C-O>\<C-R>=g:vimim_omni()\<CR>'
    else
        let s:has_pumvisible = 0
    endif
    sil!exe 'sil!return "' . key . '"'
endfunction

function! g:vimim_omni()
    let key = pumvisible() ? '\<C-P>\<Down>' : ""
    let s:smart_enter = 0  " s:windowless: gi ma enter li space 3
    sil!exe 'sil!return "' . key . '"'
endfunction

" ============================================= }}}
let s:VimIM += [" ====  core driver      ==== {{{"]
" =================================================

function! s:vimim_egg_vimimhelp()
    let eggs = s:vimim_egg_vim() + ['']
    call add(eggs, "官址："    . get(split(s:url),0))
    call add(eggs, '热键：　gi　 (vim normal mode) 无菜单窗输入')
    call add(eggs, '热键：　n 　 (vim normal mode) 无菜单窗搜索')
    call add(eggs, '热键：ctrl+6 (vim insert mode) 点石成金')
    call add(eggs, '热键：ctrl+\ (vim insert mode) 中文动态')
    call add(eggs, "程式："    . get(split(s:url),1))
    return map(eggs + [''] + s:vimim_egg_vimimrc(), 'v:val .  " "')
endfunction

function! s:vimim_plug_and_play()
    if s:vimim_map =~ 'ctrl_6'
            inoremap<unique><expr><Plug>VimimOneKey <SID>vimim_onekey(0)
            imap<silent><C-^>     <Plug>VimimOneKey
        xnoremap<silent><C-^> y:call <SID>vimim_visual_ctrl6()<CR>
    endif
    if s:vimim_map =~ 'ctrl_bslash'
           inoremap<unique><expr> <Plug>VimIM <SID>ChineseMode()
           imap<silent><C-Bslash> <Plug>VimIM
        noremap<silent><C-Bslash> :call  <SID>ChineseMode()<CR>
    endif
    if s:vimim_map =~ 'search'
        noremap<silent> n :call g:vimim_search_next()<CR>n
    endif
    if s:vimim_map =~ 'gi'
        inoremap<unique><expr><Plug>VimimOneAct <SID>vimim_onekey(2)
        nmap  gi             i<Plug>VimimOneAct
    endif
    if s:vimim_map =~ 'tab'
            inoremap<unique><expr><Plug>VimimOneTab <SID>vimim_onekey(1)
            imap<silent><Tab>     <Plug>VimimOneTab
        xnoremap<silent><Tab> y:call <SID>vimim_visual_ctrl6()<CR>
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
sil!call s:vimim_plug_and_play()
" ============================================= }}}
:redir @p
Debug s:vimim_egg_vimim()

" ==================================================
"              " VimIM —— Vim 中文輸入法 "
" --------------------------------------------------
"  VimIM -- Input Method by Vim, of Vim, for Vimmers
" ==================================================
let $VimIM = "$Date$"
let $VimIM = "$Revision$"
" -------------------------------------------------------------------

" ------------------
" For the impatient:
" ------------------
" (1) throw this script into your vim plugin directory
" (2) open your vim and enter Insert mode
" (3) play with various eggs:
"     -  VimIM 經典:  type:   vim<C-6><C-6>
"     -  VimIM 環境:  type:   vimim<C-6><C-6>
"     -  VimIM 程式:  type:   vimimvim<C-6><C-6>
"     -  VimIM 幫助:  type:   vimimhelp<C-6><C-6>
"     -  VimIM 測試:  type:   vimimdebug<C-6><C-6>
"     -  VimIM 內碼:  type:   vimimunicode<C-6><C-6>
"     -  VimIM 設置:  type:   vimimdefaults<C-6><C-6>
" -----------------------------------------------------------------
let egg  = ["http://code.google.com/p/vimim/issues/entry         "]
let egg += ["http://vim.sf.net/scripts/script.php?script_id=2506 "]
let egg += ["http://vimim-data.googlecode.com                    "]
let egg += ["http://pim-cloud.appspot.com                        "]
let egg += ["http://groups.google.com/group/vimim                "]
let egg += ["http://vimim.googlecode.com/svn/vimim/vimim.html    "]
let egg += ["http://vimim.googlecode.com/svn/vimim/vimim.vim.html"]
" -----------------------------------------------------------------

let VimIM = " ====  Vim Input Method ==== {{{"
" ===========================================
"       File: vimim.vim
"     Author: vimim <vimim@googlegroups.com>
"    License: GNU Lesser General Public License
"   Official: http://vim.sf.net/scripts/script.php?script_id=2506
" -----------------------------------------------------------
"    Readme: VimIM is a Vim plugin designed as an independent IM
"            (Input Method) to support the input of multi-byte.
"            VimIM aims to complete the Vim as the greatest editor.
" -----------------------------------------------------------
"  Features: * "Plug & Play": as a client to "myCloud" and "Cloud"
"            * "Plug & Play": as a client to VimIM backend engine
"            * support internal code input: "UNICODE", "GBK", "Big5"
"            * support "pinyin" including 6 "shuangpin"
"            * support "4Corner" standalone or as a filter to "pinyin"
"            * Support "wubi", "boshiamy", "Cang Jie", "Erbi", etc
"            * Support "Chinese search" using search key '/' or '?'
"            * Support popup menu navigation using "hjkl"
"            * It is independent of the Operating System.
"            * It is independent of Vim mbyte-XIM/mbyte-IME API.
" -----------------------------------------------------------

let s:vimims = [VimIM]
" ======================================= }}}
let VimIM = " ====  Introduction     ==== {{{"
" ===========================================
call add(s:vimims, VimIM)

" -------------------
" "VimIM Design Goal"
" -------------------
" # Chinese can be input using Vim regardless of encoding
" # Chinese can be input using Vim without local datafile
" # No negative impact to Vim when VimIM is not used
" # No compromise for high speed and low memory usage
" # Most VimIM options are activated based on input methods
" # All  VimIM options can be explicitly disabled at will

" --------------------
" "VimIM Front End UI"
" --------------------
" # VimIM "OneKey": can input Chinese without mode change.
"   - use OneKey to insert multi-byte candidates
"   - use OneKey to search multi-byte using '/' or '?'
"   The default key is <C-6> (Vim Insert Mode)
" # VimIM "Chinese Input Mode":
"   - [dynamic_mode] show omni popup menu as one types
"   - [static_mode]  <Space>=>Chinese  <Enter>=>English
"   - [onekey_mode] plays well with hjkl
"   The default key is <Ctrl-Bslash> (Vim Insert Mode)

" -----------------------
" "VimIM Back End Engine"
" -----------------------
" # (1) [external] myCloud: http://pim-cloud.appspot.com
" # (2) [external] Cloud:   http://web.pinyin.sogou.com
" # (3) [embedded] VimIM:   http://vimim.googlecode.com
" #     (3.1) internal direct input for Unicode/GBK/Big5
" #     (3.2) a database:  $VIM/vimfiles/plugin/cedict.db
" #     (3.3) a datafile:  $VIM/vimfiles/plugin/vimim.pinyin.txt
" #     (3.4) a directory: $VIM/vimfiles/plugin/vimim/pinyin/

" --------------------
" "VimIM Installation"
" --------------------
" # (1) drop this file to plugin/: plugin/vimim.vim
" # (2) [option] drop a datafile:  plugin/vimim.pinyin.txt
" # (3) [option] drop a directory: plugin/vimim/pinyin/

" ======================================= }}}
let VimIM = " ====  Initialization   ==== {{{"
" ===========================================
call add(s:vimims, VimIM)
if exists("b:loaded_vimim") || &cp || v:version<700
    finish
endif
scriptencoding utf-8
let b:loaded_vimim = 1
let s:vimimhelp = egg
let s:path = expand("<sfile>:p:h")."/"

" -------------------------------------
function! s:vimim_initialization_once()
" -------------------------------------
    if empty(s:initialization_loaded)
        let s:initialization_loaded = 1
    else
        return
    endif
    " -----------------------------------------
    call s:vimim_initialize_i_setting()
    call s:vimim_initialize_session()
    call s:vimim_initialize_encoding()
    call s:vimim_dictionary_chinese()
    call s:vimim_build_im_keycode()
    " -----------------------------------------
    call s:vimim_get_datafile_in_vimrc()
    call s:vimim_scan_plugin_datafile()
    call s:vimim_scan_plugin_data_directory()
    " -----------------------------------------
    call s:vimim_initialize_erbi()
    call s:vimim_initialize_pinyin()
    call s:vimim_initialize_shuangpin()
    " -----------------------------------------
    call s:vimim_initialize_sqlite()
    call s:vimim_initialize_cloud()
    call s:vimim_initialize_mycloud_plugin()
    " -----------------------------------------
    call s:vimim_initialize_keycode()
    call s:vimim_initialize_punctuation()
    call s:vimim_initialize_quantifiers()
    call s:vimim_finalize_session()
    " -----------------------------------------
endfunction

" ------------------------------------
function! s:vimim_initialize_session()
" ------------------------------------
    sil!call s:vimim_start_omni()
    sil!call s:vimim_super_reset()
    " --------------------------------
    let s:sqlite = 0
    let s:sqlite_executable = 0
    " --------------------------------
    let s:datafile = 0
    let s:lines = []
    " --------------------------------
    let s:im = {}
    let s:input_method = 0
    " --------------------------------
    let s:data_directory_4corner = 0
    let s:data_directory_pinyin = 0
    let s:data_directory_wubi = 0
    " --------------------------------
    let s:only_4corner_or_12345 = 0
    let s:pinyin_and_4corner = 0
    let s:digit_cache = {}
    " --------------------------------
    let s:www_libcall = 0
    let s:www_executable = 0
    let s:vimim_cloud_plugin = 0
    let s:vimim_sogou_key = 0
    let s:has_dot_in_datafile = 0
    " --------------------------------
    let s:smart_single_quotes = 1
    let s:smart_double_quotes = 1
    " --------------------------------
    let s:seamless_positions = []
    let s:current_positions = [0,0,1,0]
    " --------------------------------
    let s:start_row_before = 0
    let s:start_column_before = 1
    let s:scriptnames_output = 0
    " --------------------------------
    let s:quanpin_table = {}
    let s:shuangpin_table = {}
    " --------------------------------
    let s:keyboard_count = 0
    let s:abcdefg = "'abcdefg"
    let s:show_me_not_pattern = "^ii\\|^oo"
    " --------------------------------
    let A = char2nr('A')
    let Z = char2nr('Z')
    let a = char2nr('a')
    let z = char2nr('z')
    let az_nr_list = range(a,z)
    let Az_nr_list = extend(range(A,Z), range(a,z))
    let s:Az_list = map(Az_nr_list,"nr2char(".'v:val'.")")
    let s:az_list = map(az_nr_list,"nr2char(".'v:val'.")")
    " --------------------------------
    let s:debugs = []
    let s:debug_count = 0
    " --------------------------------
endfunction

" ----------------------------------
function! s:vimim_finalize_session()
" ----------------------------------
    if s:vimim_custom_skin > 0
        call s:vimim_initialize_skin()
    endif
    " ------------------------------
    if empty(s:vimim_cloud_sogou)
        let s:vimim_cloud_sogou = 888
    endif
    " --------------------------------
    if s:datafile =~# "chinese"
        let s:vimim_datafile_is_not_utf8 = 1
    endif
    " ------------------------------
    if s:datafile =~# "quote"
        let s:vimim_datafile_has_apostrophe = 1
    endif
    " ------------------------------
    if get(s:im['boshiamy'],0) > 0
        let s:vimim_chinese_punctuation = -1
        let s:vimim_punctuation_navigation = -1
        let s:im['pinyin'][0] = 0
    endif
    " ------------------------------
    if get(s:im['phonetic'],0) > 0
    \|| get(s:im['array30'],0) > 0
        let s:vimim_static_input_style = 1
    endif
    " ------------------------------
    if s:shuangpin_flag > 0
        let s:input_method = 'pinyin'
    endif
    if s:input_method =~ 'pinyin'
        let s:im['pinyin'][0] = 1
    endif
    " ------------------------------
    if s:input_method =~# '^\d\w\+'
    \&& empty(get(s:im['pinyin'],0))
        let s:only_4corner_or_12345 = 1
    endif
    if !empty(s:only_4corner_or_12345)
        let s:input_method = '4corner'
        let s:vimim_static_input_style = 1
        let s:im['4corner'][0] = 1
        let s:im['pinyin'][0] = 0
    endif
    " ------------------------------
    if s:pinyin_and_4corner > 0
        let s:abcdefg = "'asdfgvb"
    endif
    " ------------------------------
endfunction

" ------------------------------------
function! s:vimim_get_chinese(english)
" ------------------------------------
    let key = a:english
    let chinese = a:english
    if has_key(s:chinese, key)
        let chinese = get(s:chinese[key], 0)
        if v:lc_time !~ 'gb2312' && len(s:chinese[key]) > 1
            let chinese = get(s:chinese[key], 1)
        endif
    endif
    return chinese
endfunction

" ------------------------------------
function! s:vimim_dictionary_chinese()
" ------------------------------------
    let s:space = "　"
    let H = {}
    let H['vim1'] = ['文本编辑器','文本編輯器']
    let H['vim2'] = ['最牛']
    let H['vim3'] = ['精力']
    let H['vim4'] = ['生气','生氣']
    let H['vim5'] = ['中文输入法','中文輸入法']
    let H['nonstop'] = ['连续','連續']
    let H['input'] = ['输入','輸入']
    let H['directory'] = ['目录','目錄']
    let H['ciku'] = ['词库','詞庫']
    let H['font'] = ['字体','字體']
    let H['environment'] = ['环境','環境']
    let H['myversion'] = ['版本','版本']
    let H['encoding'] = ['编码','編碼']
    let H['computer'] = ['电脑','電腦']
    let H['classic'] = ['经典','經典']
    let H['static'] = ['静态','靜態']
    let H['dynamic'] = ['动态','動態']
    let H['internal'] = ['内码','內碼']
    let H['onekey'] = ['点石成金','點石成金']
    let H['style'] = ['风格','風格']
    let H['scheme'] = ['方案','方案']
    let H['cloud'] = ['云输入','雲輸入']
    let H['mycloud'] = ['自己的云','自己的雲']
    let H['wubi'] = ['五笔','五筆']
    let H['4corner'] = ['四角号码','四角號碼']
    let H['12345'] = ['五笔划','五筆劃']
    let H['ctc'] = ['中文电码','中文電碼']
    let H['cns11643'] = ['交换码','交換碼']
    let H['english'] = ['英文']
    let H['hangul'] = ['韩文','韓文']
    let H['xinhua'] = ['新华','新華']
    let H['pinyin'] = ['拼音']
    let H['cangjie'] = ['仓颉','倉頡']
    let H['boshiamy'] = ['呒虾米','嘸蝦米']
    let H['zhengma'] = ['郑码','鄭碼']
    let H['yong'] = ['永码','永碼']
    let H['nature'] = ['自然']
    let H['quick'] = ['速成']
    let H['yong'] = ['永码','永碼']
    let H['wu'] = ['吴语','吳語']
    let H['phonetic'] = ['注音']
    let H['array30'] = ['行列']
    let H['erbi'] = ['二笔','二筆']
    let H['sogou'] = ['搜狗']
    let H['cloud_no'] = ['晴天无云','晴天無雲']
    let H['all'] = ['全']
    let H['cloud_atwill'] = ['想云就云','想雲就雲']
    let H['shezhi'] = ['设置','設置']
    let H['test'] = ['测试','測試']
    let H['jidian'] = ['极点','極點']
    let H['newcentury'] = ['新世纪','新世紀']
    let H['shuangpin'] = ['双拼','雙拼']
    let H['abc'] = ['智能双打','智能雙打']
    let H['microsoft'] = ['微软','微軟']
    let H['nature'] = ['自然']
    let H['plusplus'] = ['拼音加加']
    let H['purple'] = ['紫光']
    let H['flypy'] = ['小鹤','小鶴']
    let H['bracket_l'] = ['《','【']
    let H['bracket_r'] = ['》','】']
    let s:chinese = copy(H)
endfunction

" ----------------------------------
function! s:vimim_build_im_keycode()
" ----------------------------------
    let key_keycode = []
    call add(key_keycode, ['cloud', "[0-9a-z'.]"])
    call add(key_keycode, ['mycloud', "[0-9a-z'.]"])
    call add(key_keycode, ['wubi', "[0-9a-z'.]"])
    call add(key_keycode, ['4corner', "[0-9a-z'.]"])
    call add(key_keycode, ['12345', "[0-9a-z'.]"])
    call add(key_keycode, ['ctc', "[0-9a-z'.]"])
    call add(key_keycode, ['cns11643', "[0-9a-z'.]"])
    call add(key_keycode, ['english', "[0-9a-z'.]"])
    call add(key_keycode, ['hangul', "[0-9a-z'.]"])
    call add(key_keycode, ['xinhua', "[0-9a-z'.]"])
    call add(key_keycode, ['pinyin', "[0-9a-z'.]"])
    call add(key_keycode, ['cangjie', "[a-z'.]"])
    call add(key_keycode, ['zhengma', "[a-z'.]"])
    call add(key_keycode, ['quick', "[0-9a-z'.]"])
    " ----------------------------- has_dot_in_datafile
    call add(key_keycode, ['erbi', "[a-z'.,;/]"])
    call add(key_keycode, ['wu', "[a-z'.]"])
    call add(key_keycode, ['yong', "[a-z'.;/]"])
    call add(key_keycode, ['nature', "[a-z'.]"])
    call add(key_keycode, ['boshiamy', "[][a-z'.,]"])
    " ----------------------------- static
    call add(key_keycode, ['phonetic', "[0-9a-z.,;/]"])
    call add(key_keycode, ['array30', "[0-9a-z.,;/]"])
    " ------------------------------------
    let loaded = 0
    for pairs in key_keycode
        let key = get(pairs, 0)
        let keycode = get(pairs, 1)
        let im = s:vimim_get_chinese(key)
        let s:im[key]=[loaded, im, keycode]
    endfor
    " ------------------------------------
endfunction

" -------------------------------------------------------
function! s:vimim_expand_character_class(character_class)
" -------------------------------------------------------
    let character_string = ""
    let i = 0
    while i < 256
        let char = nr2char(i)
        if char =~# a:character_class
            let character_string .= char
        endif
        let i += 1
    endwhile
    return character_string
endfunction

" ------------------------------------
function! s:vimim_initialize_keycode()
" ------------------------------------
    let keycode = s:vimim_get_keycode()
    if empty(keycode)
        let keycode = "[0-9a-z'.]"
    endif
    " --------------------------------
    if s:shuangpin_flag > 0
        let keycode = s:im['shuangpin'][2]
    endif
    " --------------------------------
    let s:valid_key = copy(keycode)
    let keycode = s:vimim_expand_character_class(keycode)
    let s:valid_keys = split(keycode, '\zs')
    " --------------------------------
    if get(s:im['erbi'],0) > 0
    \|| get(s:im['wu'],0) > 0
    \|| get(s:im['yong'],0) > 0
    \|| get(s:im['nature'],0) > 0
    \|| get(s:im['boshiamy'],0) > 0
    \|| get(s:im['phonetic'],0) > 0
    \|| get(s:im['array30'],0) > 0
        let msg = "How to handle real valid keycode for dot?"
        let s:has_dot_in_datafile = 1
    endif
    " --------------------------------
    return
endfunction

" -----------------------------
function! s:vimim_get_keycode()
" -----------------------------
    if empty(s:input_method)
        return 0
    endif
    let keycode = get(s:im[s:input_method],2)
    if s:vimim_wildcard_search > 0
    \&& empty(get(s:im['wubi'],0))
    \&& len(keycode) > 1
        let wildcard = '[*]'
        let key_valid = strpart(keycode, 1, len(keycode)-2)
        let key_wildcard = strpart(wildcard, 1, len(wildcard)-2)
        let keycode = '[' . key_valid . key_wildcard . ']'
    endif
    return keycode
endfunction

" ======================================= }}}
let VimIM = " ====  Customization    ==== {{{"
" ===========================================
call add(s:vimims, VimIM)

" -----------------------------------
function! s:vimim_initialize_global()
" -----------------------------------
    let s:global_defaults = []
    let s:global_customized = []
    " -------------------------------
    let G = []
    call add(G, "g:vimim_backslash_close_pinyin")
    call add(G, "g:vimim_ctrl_space_to_toggle")
    call add(G, "g:vimim_custom_skin")
    call add(G, "g:vimim_data_directory")
    call add(G, "g:vimim_sqlite_cedict")
    call add(G, "g:vimim_datafile")
    call add(G, "g:vimim_datafile_has_apostrophe")
    call add(G, "g:vimim_datafile_is_not_utf8")
    call add(G, "g:vimim_english_punctuation")
    call add(G, "g:vimim_imode_universal")
    call add(G, "g:vimim_imode_pinyin")
    call add(G, "g:vimim_latex_suite")
    call add(G, "g:vimim_reverse_pageup_pagedown")
    call add(G, "g:vimim_fancy_input_style")
    call add(G, "g:vimim_shuangpin_abc")
    call add(G, "g:vimim_shuangpin_microsoft")
    call add(G, "g:vimim_shuangpin_nature")
    call add(G, "g:vimim_shuangpin_plusplus")
    call add(G, "g:vimim_shuangpin_purple")
    call add(G, "g:vimim_shuangpin_flypy")
    call add(G, "g:vimim_static_input_style")
    call add(G, "g:vimim_tab_as_onekey")
    call add(G, "g:vimim_wildcard_search")
    call add(G, "g:vimim_wget_dll")
    call add(G, "g:vimim_mycloud_url")
    call add(G, "g:vimim_cloud_sogou")
    call add(G, "g:vimim_super_internal_input")
    call add(G, "g:vimim_debug")
    call add(G, "g:vimimdebug")
    " -----------------------------------
    call s:vimim_set_global_default(G, 0)
    " -----------------------------------
    let G = []
    call add(G, "g:vimim_auto_copy_clipboard")
    call add(G, "g:vimim_chinese_punctuation")
    call add(G, "g:vimim_custom_laststatus")
    call add(G, "g:vimim_custom_menu_label")
    call add(G, "g:vimim_internal_code_input")
    call add(G, "g:vimim_onekey_double_ctrl6")
    call add(G, "g:vimim_punctuation_navigation")
    " -----------------------------------
    call s:vimim_set_global_default(G, 1)
    " -----------------------------------
endfunction

" ----------------------------------------------------
function! s:vimim_set_global_default(options, default)
" ----------------------------------------------------
    for variable in a:options
        call add(s:global_defaults, variable .'='. a:default)
        let s_variable = substitute(variable,"g:","s:",'')
        if exists(variable)
            call add(s:global_customized, variable .'='. eval(variable))
            exe 'let '. s_variable .'='. variable
            exe 'unlet! ' . variable
        else
            exe 'let '. s_variable . '=' . a:default
        endif
    endfor
endfunction

" ======================================= }}}
let VimIM = " ====  Easter_Egg       ==== {{{"
" ===========================================
call add(s:vimims, VimIM)

" ------------------------------
function! s:vimim_egg_vimimegg()
" ------------------------------
    let eggs = []
    call add(eggs, "經典　vim")
    call add(eggs, "環境　vimim")
    call add(eggs, "程式　vimimvim")
    call add(eggs, "幫助　vimimhelp")
    call add(eggs, "測試　vimimdebug")
    call add(eggs, "內碼　vimimunicode")
    call add(eggs, "設置　vimimdefaults")
    return map(eggs,  '"VimIM 彩蛋：" . v:val . s:space')
endfunction

" -------------------------
function! s:vimim_egg_vim()
" -------------------------
    let vim1 = s:vimim_get_chinese('vim1')
    let vim2 = s:vimim_get_chinese('vim2') . vim1
    let vim3 = s:vimim_get_chinese('vim3')
    let vim4 = s:vimim_get_chinese('vim4')
    let vim5 = s:vimim_get_chinese('vim5')
    " ------------------------------------
    let eggs  = ["vi　  " . vim1 ]
    let eggs += ["vim   " . vim2 ]
    let eggs += ["vim   " . vim3 ]
    let eggs += ["vim   " . vim4 ]
    let eggs += ["vimim " . vim5 ]
    return eggs
endfunction

" ------------------------------
function! s:vimim_egg_vimimvim()
" ------------------------------
    let eggs = copy(s:vimims)
    let egg = "strpart(" . 'v:val' . ", 0, 28)"
    return map(eggs, egg)
endfunction

" -----------------------------------
function! s:vimim_egg_vimimdefaults()
" -----------------------------------
    let eggs = copy(s:global_defaults)
    let egg = '"VimIM  " . v:val . s:space'
    return map(eggs, egg)
endfunction

" -------------------------------
function! s:vimim_egg_vimimhelp()
" -------------------------------
    let eggs = []
    " -------------------------------------------
    call add(eggs, "错误报告：" . s:vimimhelp[0])
    call add(eggs, "官方网址：" . s:vimimhelp[1])
    call add(eggs, "民间词库：" . s:vimimhelp[2])
    call add(eggs, "自己的云：" . s:vimimhelp[3])
    call add(eggs, "新闻论坛：" . s:vimimhelp[4])
    call add(eggs, "最新主页：" . s:vimimhelp[5])
    call add(eggs, "最新程式：" . s:vimimhelp[6])
    " -------------------------------------------
    return map(eggs, '"VimIM " . v:val . s:space')
endfunction

" ---------------------------
function! s:vimim_egg_vimim()
" ---------------------------
    let eggs = []
    if has("win32unix")
        let option = "cygwin"
    elseif has("win32")
        let option = "Windows32"
    elseif has("win64")
        let option = "Windows64"
    elseif has("unix")
        let option = "unix"
    elseif has("macunix")
        let option = "macunix"
    endif
    " ----------------------------------
    let input = s:vimim_get_chinese('input')
    let myversion = s:vimim_get_chinese('myversion')
    let myversion = "\t " . myversion . "："
    let font = s:vimim_get_chinese('font') . "："
    let environment = s:vimim_get_chinese('environment') . "："
    let encoding = s:vimim_get_chinese('encoding') . "："
    " ----------------------------------
    let option .= "_" . &term
    let computer = s:vimim_get_chinese('computer')
    let option = "computer " . computer . "：" . option
    call add(eggs, option)
    " ----------------------------------
    let option = v:progname . s:space
    let option = "Vim" . myversion  . option . v:version
    call add(eggs, option)
    " ----------------------------------
    let option = get(split($VimIM), 1)
    if empty(option)
        let msg = "not a SVN check out, revision number not available"
    else
        let option = "VimIM" . myversion . "vimim.vim" . s:space . option
        call add(eggs, option)
    endif
    " ----------------------------------
    let option = "encoding " . encoding . &encoding
    call add(eggs, option)
    " ----------------------------------
    let option = "fencs\t "  . encoding . &fileencodings
    call add(eggs, option)
    " ----------------------------------
    let option = "fonts\t "  . font . &guifontwide
    call add(eggs, option)
    " ----------------------------------
    let option = "lc_time\t " . environment . v:lc_time
    call add(eggs, option)
    " ----------------------------------
    let toggle = 'i_CTRL-Bslash'
    if s:vimim_ctrl_space_to_toggle == 1
        let toggle = "i_CTRL-Space"
    elseif s:vimim_tab_as_onekey == 1
        let toggle = "Tab_as_OneKey"
    elseif s:vimim_tab_as_onekey == 2
        let toggle = "OneKey n_CTRL-6"
    endif
    let toggle .=  s:space
    let style = s:vimim_get_chinese('style')
    let option = "mode\t " . style . "：" . toggle
    call add(eggs, option)
    " ----------------------------------
    let im = s:vimim_statusline()
    if !empty(im)
        let option = "im\t " . input . "：" . im
        call add(eggs, option)
    endif
    " ----------------------------------
    let option = s:shuangpin_flag
    if empty(option)
        let msg = "no shuangpin is used"
    else
        let scheme = s:vimim_get_chinese('scheme')
        let option = "scheme\t " . scheme . '：' . get(s:im['shuangpin'],1)
        call add(eggs, option)
    endif
    " ----------------------------------
    let option = s:vimim_get_ciku_in_Chinese()
    if empty(option)
        let msg = "no ciku found"
    else
        let ciku = s:vimim_get_chinese('ciku')
        let option = "database " . ciku . "：" . option
        call add(eggs, option)
    endif
    " ----------------------------------
    let cloud = s:vimim_cloud_sogou
    let sogou = s:vimim_get_chinese('sogou')
    let option = "cloud\t " . sogou ."："
    let CLOUD = "start_to_use_cloud_after_" .  cloud . "_characters"
    if cloud == -777
        let CLOUD = s:vimim_get_chinese('mycloud')
    elseif cloud == -1
        let CLOUD = s:vimim_get_chinese('cloud_atwill')
    elseif cloud < -1
        let CLOUD = s:vimim_get_chinese('cloud_no')
    elseif cloud == 888
        let CLOUD = s:vimim_get_chinese('cloud_atwill')
    elseif cloud == 1
        let CLOUD = s:vimim_get_chinese('all')
        let CLOUD .= s:vimim_get_chinese('cloud')
    endif
    let option .= CLOUD
    call add(eggs, option)
    " ----------------------------------
    if empty(s:global_customized)
        let msg = "no global variable is set"
    else
        for item in s:global_customized
            let shezhi = s:vimim_get_chinese('shezhi')
            let option = "VimIM\t " . shezhi . "：" . item
            call add(eggs, option)
        endfor
    endif
    " ----------------------------------
    let option = s:vimimdebug
    if option > 0
        let option = "g:vimimdebug=" . option
        let test = s:vimim_get_chinese('test')
        let option = "debug\t " . test . "：" . option
        call add(eggs, option)
    endif
    " ----------------------------------
    return map(eggs, 'v:val . s:space')
endfunction

" -------------------------------------
function! s:vimim_get_ciku_in_Chinese()
" -------------------------------------
    let database = s:datafile
    if empty(database)
        let msg = "no primary datafile, try directory"
        let database = s:path2
        if empty(database)
            let msg = "no primary datafile nor directory"
        else
            let ciku = s:vimim_get_chinese('ciku')
            let directory  = s:vimim_get_chinese('directory')
            let directory .= ciku . s:space  . database . "/"
            return  directory
        endif
    else
        return database
    endif
    return 0
endfunction

" --------------------------------------------
function! s:vimim_get_input_style_in_Chinese()
" -------------------------------------------
    let style = s:vimim_static_input_style
    let dynamic = s:vimim_get_chinese('dynamic')
    let static = s:vimim_get_chinese('static')
    let nonstop = s:vimim_get_chinese('nonstop')
    let chinese = s:vimim_get_chinese('classic')
    if style < 1
        let chinese .= dynamic
    elseif style == 1
        let chinese .= static
    elseif style == 2
        let chinese = "OneKey" . nonstop
    endif
    return chinese
endfunction

" ----------------------------------------
function! s:vimim_easter_chicken(keyboard)
" ----------------------------------------
    if empty(s:chinese_input_mode)
        let msg = "easter eggs hidden in OneKey only"
    else
        return
    endif
    " ------------------------------------
    let egg = a:keyboard
    if egg =~# s:valid_key
        let msg = "hunt easter egg ... vim<C-6>"
    else
        return []
    endif
    " ------------------------------------
    try
        return eval("<SID>vimim_egg_".egg."()")
    catch
        if s:vimimdebug > 0
            call s:debugs('egg::exception=', v:exception)
        endif
        return []
    endtry
endfunction

" ======================================= }}}
let VimIM = " ====  OneKey           ==== {{{"
" ===========================================
call add(s:vimims, VimIM)

" ---------------------
function! <SID>TabKey()
" ---------------------
    let tab = "\t"
    if pumvisible() && s:vimim_onekey_double_ctrl6
        let tab  = "\<C-E>\<C-X>\<C-U>\<C-E>"
        let tab .= "\<C-R>=g:vimim_pumvisible_p_paste()\<CR>"
    endif
    sil!exe 'sil!return "' . tab . '"'
endfunction

" ---------------------
function! <SID>OneKey()
" ---------------------
" VimIM <OneKey> double play
"  (1) <OneKey> => start OneKey as "hit and run"
"  (2) <OneKey> => stop  OneKey and print out menu
" ------------------------------------------------
    let s:chinese_input_mode = 0
    return s:vimim_start_both_onekey(0)
endfunction

" -----------------------------
function! s:vimim_onekey_mode()
" -----------------------------
    let onekey = ""
    if empty(s:chinese_mode_switch%2)
        let onekey = s:vimim_start_both_onekey(1)
    else
        call s:vimim_stop()
    endif
    return onekey
endfunction

" ---------------------------------------
function! s:vimim_start_both_onekey(mode)
" ---------------------------------------
    sil!call s:vimim_start_onekey(a:mode)
    let onekey = s:vimim_onekey_action("")
    if pumvisible() && s:vimim_onekey_double_ctrl6
        let onekey  = <SID>TabKey()
    endif
    sil!exe 'sil!return "' . onekey . '"'
endfunction

" ----------------------------------
function! s:vimim_start_onekey(mode)
" ----------------------------------
    sil!call s:vimim_start()
    sil!call s:vimim_navigation_label_on()
    sil!call s:vimim_1234567890_filter_on()
    sil!call s:vimim_abcdefg_label_on()
    sil!call s:vimim_punctuation_navigation_on()
    sil!call s:vimim_helper_mapping_on()
    if a:mode > 0
        sil!call s:vimim_start_onekey_mode()
    endif
    " ----------------------------------------------------------
    " default <OneKey> triple play
    "   (1) after English (valid keys)   => trigger omni popup
    "   (2) after omni popup window      => <Space> or nothing
    "   (3) after Chinese (invalid keys) => <Tab> or nothing
    " ----------------------------------------------------------
    inoremap <Space> <C-R>=<SID>vimim_space_onekey()<CR>
                    \<C-R>=g:vimim_reset_after_insert()<CR>
    " ----------------------------------------------------------
endfunction

" -----------------------------------
function! s:vimim_start_onekey_mode()
" -----------------------------------
    set noruler
    let s:chinese_input_mode = 'onekey'
endfunction

" ----------------------------------
function! s:vimim_stop_onekey_mode()
" ----------------------------------
    if s:chinese_input_mode =~ 'onekey'
        set ruler
        if s:vimim_auto_copy_clipboard>0 && has("gui_running")
            let @+ = getline(".")
        endif
    endif
endfunction

" ---------------------------------
function! <SID>vimim_space_onekey()
" ---------------------------------
    let onekey = " "
    sil!return s:vimim_onekey_action(onekey)
endfunction

" -------------------------------------
function! s:vimim_onekey_action(onekey)
" -------------------------------------
" <Space> multiple play in OneKey Mode:
"   (1) after English (valid keys) => trigger keycode menu
"   (2) after omni popup menu      => insert Chinese
"   (3) after English punctuation  => Chinese punctuation
"   (4) after Chinese              => trigger unicode menu
" -------------------------------------------------------
    let onekey = ''
    if pumvisible()
        if s:pattern_not_found > 0
            let s:pattern_not_found = 0
            let onekey = " "
        elseif a:onekey == " " || s:vimim_static_input_style < 2
            let onekey = s:vimim_ctrl_y_ctrl_x_ctrl_u()
        else
            let onekey = "\<C-E>"
        endif
        sil!exe 'sil!return "' . onekey . '"'
    endif
    if s:insert_without_popup > 0
        let s:insert_without_popup = 0
        let onekey = ""
    endif
    " ---------------------------------------------------
    let byte_before = getline(".")[col(".")-2]
    let char_before_before = getline(".")[col(".")-3]
    " ---------------------------------------------------
    if char_before_before !~# "[0-9a-z]"
    \&& has_key(s:punctuations, byte_before)
    \&& get(s:im['boshiamy'],0) < 1
        let onekey = ""
        for char in keys(s:punctuations_all)
            if char_before_before ==# char
                let onekey = a:onekey
                break
            else
                continue
            endif
        endfor
        if empty(onekey)
            let msg = "transform punctuation from english to chinese"
            let replacement = s:punctuations[byte_before]
            if s:vimim_static_input_style > 2
                let msg = " play smart quote in onekey static mode "
                if byte_before ==# "'"
                    let replacement = <SID>vimim_get_single_quote()
                elseif byte_before ==# '"'
                    let replacement = <SID>vimim_get_double_quote()
                endif
            endif
            let onekey = "\<BS>" . replacement
            sil!exe 'sil!return "' . onekey . '"'
        endif
    endif
    " -------------------------------------------------
    let onekey = a:onekey
    if byte_before !~# s:valid_key
        if empty(byte_before) || byte_before =~ '\s'
            if s:vimim_tab_as_onekey == 1
                let onekey = "\t"
            endif
        elseif empty(a:onekey) && empty(s:chinese_input_mode)
            return <SID>vimim_get_unicode_menu()
        endif
    endif
    " ---------------------------------------------------
    if byte_before ==# "'" && get(s:im['boshiamy'],0)<1
        let s:pattern_not_found = 0
    endif
    " ---------------------------------------------------
    if s:seamless_positions != getpos(".")
    \&& s:pattern_not_found < 1
        let onekey = '\<C-R>=g:vimim_ctrl_x_ctrl_u()\<CR>'
    else
        let onekey = ""
    endif
    " ---------------------------------------------------
    if empty(byte_before) || byte_before =~ '\s'
        if s:vimim_tab_as_onekey == 1
            let onekey = "\t"
        endif
    elseif byte_before !~# s:valid_key
        let onekey = a:onekey
    endif
    " ---------------------------------------------------
    let s:smart_enter = 0
    let s:pattern_not_found = 0
    sil!exe 'sil!return "' . onekey . '"'
endfunction

" -----------------------------------------------
function! s:vimim_get_internal_code_char_before()
" -----------------------------------------------
    let xxxx = 0
    let byte_before = getline(".")[col(".")-2]
    if empty(byte_before) || byte_before =~# s:valid_key
        return 0
    endif
    let msg = "[unicode] OneKey to trigger Chinese with omni menu"
    let start = s:multibyte + 1
    let char_before = getline(".")[col(".")-start : col(".")-2]
    let ddddd = char2nr(char_before)
    if ddddd > 127
        let xxxx = s:vimim_decimal2hex(ddddd)
        let xxxx = 'u' . xxxx
    endif
    return xxxx
endfunction

" ------------------------------------
function! s:vimim_decimal2hex(decimal)
" ------------------------------------
    let n = a:decimal
    let hex = ""
    while n
        let hex = '0123456789abcdef'[n%16].hex
        let n = n/16
    endwhile
    return hex
endfunction

" ======================================= }}}
let VimIM = " ====  Chinese_Mode     ==== {{{"
" ===========================================
call add(s:vimims, VimIM)

" -------------------------------------------
" s:chinese_input_mode=0         => (default) OneKey: hit-and-run
" s:chinese_input_mode='dynamic' => (default) classic dynamic mode
" s:chinese_input_mode='static'  => let g:vimim_static_input_style = 1
" s:chinese_input_mode='onekey'  => let g:vimim_static_input_style = 2
" -------------------------------------------

" --------------------------
function! <SID>ChineseMode()
" --------------------------
    let s:chinese_mode_switch += 1
    " ----------------------------------
    if s:vimim_static_input_style == 2
        return s:vimim_onekey_mode()
    endif
    " ----------------------------------
    let space = ""
    if s:chinese_mode_switch > 2
        call s:vimim_stop_chinese_mode()
        let space = "\<C-O>:redraw\<CR>"
    endif
    if empty(s:chinese_mode_switch%2)
        call s:vimim_start_chinese_mode()
        if s:vimim_static_input_style > 0
            if pumvisible()
                let msg = "<C-\> does nothing over omni menu"
            else
                let space = s:vimim_static_action("")
            endif
        endif
    endif
    sil!exe 'sil!return "' . space . '"'
endfunction

" ------------------------------------
function! s:vimim_start_chinese_mode()
" ------------------------------------
    sil!call s:vimim_start()
    " ------------------------------------------
    if s:vimim_static_input_style < 1
        let s:chinese_input_mode = 'dynamic'
        call <SID>vimim_set_seamless()
        call s:vimim_dynamic_alphabet_trigger()
        " ---------------------------------------------------
        inoremap <Space> <C-R>=<SID>vimim_space_dynamic()<CR>
                      \<C-R>=g:vimim_reset_after_insert()<CR>
        " ---------------------------------------------------
    elseif s:vimim_static_input_style == 1
        let s:chinese_input_mode = 'static'
        sil!call s:vimim_static_alphabet_auto_select()
        " ------------------------------------------------------
        inoremap  <Space> <C-R>=<SID>vimim_space_static()<CR>
                         \<C-R>=g:vimim_reset_after_insert()<CR>
        " ------------------------------------------------------
    endif
    " ----------------------------------
    sil!call s:vimim_helper_mapping_on()
    " ----------------------------------
    inoremap <expr> <C-^> <SID>vimim_toggle_punctuation()
    " ---------------------------------------------------
    return <SID>vimim_toggle_punctuation()
endfunction

" -----------------------------------
function! s:vimim_stop_chinese_mode()
" -----------------------------------
    if s:vimim_auto_copy_clipboard>0 && has("gui_running")
        sil!exe ':%y +'
    endif
    sil!call s:vimim_stop()
endfunction

" ----------------------------------
function! <SID>vimim_space_dynamic()
" ----------------------------------
    let space = ' '
    if pumvisible()
        let space = s:vimim_ctrl_y_ctrl_x_ctrl_u()
    endif
    sil!exe 'sil!return "' . space . '"'
endfunction

" ---------------------------------
function! <SID>vimim_space_static()
" ---------------------------------
    let space = " "
    sil!return s:vimim_static_action(space)
endfunction

" ------------------------------------
function! s:vimim_static_action(space)
" ------------------------------------
    let space = a:space
    if pumvisible()
        let space = s:vimim_ctrl_y_ctrl_x_ctrl_u()
    else
        let byte_before = getline(".")[col(".")-2]
        if byte_before =~# s:valid_key
            if s:pattern_not_found < 1
                let space = '\<C-R>=g:vimim_ctrl_x_ctrl_u()\<CR>'
            else
                let s:pattern_not_found = 0
            endif
        endif
    endif
    sil!exe 'sil!return "' . space . '"'
endfunction

" ---------------------------------------------
function! s:vimim_static_alphabet_auto_select()
" ---------------------------------------------
    if s:chinese_input_mode !~ 'static'
        return
    endif
    " always do alphabet auto selection for static mode
    for char in s:Az_list
        sil!exe 'inoremap <silent> ' . char . '
        \ <C-R>=g:vimim_pumvisible_ctrl_y()<CR>'. char .
        \'<C-R>=g:reset_after_auto_insert()<CR>'
    endfor
endfunction

" ------------------------------------------
function! s:vimim_dynamic_alphabet_trigger()
" ------------------------------------------
    if s:chinese_input_mode !~ 'dynamic'
        return
    endif
    let not_used_valid_keys = "[0-9.']"
    if s:has_dot_in_datafile > 0
        let not_used_valid_keys = "[0-9]"
    endif
    " --------------------------------------
    for char in s:valid_keys
        if char !~# not_used_valid_keys
            sil!exe 'inoremap <silent> ' . char . '
            \ <C-R>=g:vimim_pumvisible_ctrl_e_ctrl_y()<CR>'. char .
            \'<C-R>=g:vimim_ctrl_x_ctrl_u()<CR>'
        endif
    endfor
endfunction

" ======================================= }}}
let VimIM = " ====  Skin             ==== {{{"
" ===========================================
call add(s:vimims, VimIM)

" ---------------------------------
function! s:vimim_initialize_skin()
" ---------------------------------
    highlight! link PmenuSel   Title
    highlight! link StatusLine Title
    highlight!      Pmenu      NONE
    highlight!      PmenuSbar  NONE
    highlight!      PmenuThumb NONE
endfunction

" -----------------------------------
function! s:vimim_i_chinese_mode_on()
" -----------------------------------
    if empty(s:chinese_input_mode)
        return
    endif
    if s:vimim_custom_laststatus > 0
        set laststatus=2
    endif
    let b:keymap_name = s:vimim_statusline()
endfunction

" --------------------------------------
function! s:vimim_i_cursor_color(switch)
" --------------------------------------
    if empty(s:chinese_input_mode)
        return
    endif
    highlight! lCursor guifg=bg guibg=Green
    if empty(a:switch)
        highlight! Cursor guifg=bg guibg=fg
    else
        highlight! Cursor guifg=bg guibg=Green
    endif
endfunction

" ----------------
function! IMName()
" ----------------
" This function is for user-defined 'stl' 'statusline'
    call s:vimim_initialization_once()
    if empty(s:chinese_input_mode)
        if pumvisible()
            return s:vimim_statusline()
        else
            return ""
        endif
    else
        return s:vimim_statusline()
    endif
    return ""
endfunction

" ----------------------------
function! s:vimim_statusline()
" ----------------------------
    let im = ''
    let bracket_l = s:vimim_get_chinese('bracket_l')
    let bracket_r = s:vimim_get_chinese('bracket_r')
    let plus = '＋'
    let plus = bracket_r . plus . bracket_l
    " ------------------------------------
    let key  = s:input_method
    if has_key(s:im, key)
        let im = get(s:im[key],1)
    endif
    " ------------------------------------
    if key =~# 'wubi'
        if s:datafile =~# 'wubi98'
            let im .= '98'
        elseif s:datafile =~# 'wubi2000'
            let newcentury = s:vimim_get_chinese('newcentury')
            let im = newcentury . im
        elseif s:datafile =~# 'wubijd'
            let jidian = s:vimim_get_chinese('jidian')
            let im = jidian . im
        endif
    endif
    " ------------------------------------
    let pinyin = get(s:im['pinyin'],1)
    if s:shuangpin_flag > 0
        let pinyin = get(s:im['shuangpin'],0)
        let im = pinyin
    endif
    " ------------------------------------
    if s:pinyin_and_4corner > 0
        let im_digit = get(s:im['4corner'],1)
        if s:datafile =~ '12345'
            let im_digit = get(s:im['12345'],1)
            let s:im['12345'][0] = 1
        endif
        let im = pinyin . plus . im_digit
    endif
    " ------------------------------------
    if !empty(s:vimim_cloud_plugin)
        let im = get(s:im['mycloud'],0)
    endif
    " ------------------------------------
    if empty(im)
        if s:vimim_cloud_sogou > 0
            if s:vimim_cloud_sogou == 1
                let all = s:vimim_get_chinese('all')
                let cloud = get(s:im['cloud'],1)
                let im = all . cloud
            endif
        else
            let im = s:vimim_get_chinese('internal')
            let im .= s:vimim_get_chinese('input')
        endif
    endif
    " ----------------------------------
    let im  = bracket_l . im . bracket_r
    " ----------------------------------
    let input_style = s:vimim_get_input_style_in_Chinese()
    let im = im . s:space . input_style
    " ----------------------------------
    return im
endfunction

" ======================================= }}}
let VimIM = " ====  User_Interface   ==== {{{"
" ===========================================
call add(s:vimims, VimIM)

" -----------------------------------
function! s:vimim_12345678_label_on()
" -----------------------------------
    if s:vimim_custom_menu_label < 1
        return
    endif
    " -------------------------------
    let labels = range(8)
    if &pumheight > 0
        let labels = range(1, &pumheight)
    endif
    " -------------------------------
    for _ in labels
        sil!exe'inoremap <silent>  '._.'
        \  <C-R>=<SID>vimim_12345678_label("'._.'")<CR>'
        \.'<C-R>=g:vimim_reset_after_insert()<CR>'
    endfor
endfunction

" ------------------------------------
function! <SID>vimim_12345678_label(n)
" ------------------------------------
    let label = a:n
    let n = a:n
    if a:n !~ '\d'
        let n = char2nr(n) - char2nr('a') + 2
    endif
    if pumvisible()
        if n < 1
            let n = 10
        endif
        let mycount = repeat("\<Down>", n-1)
        let yes = s:vimim_ctrl_y_ctrl_x_ctrl_u()
        let label = mycount . yes
    endif
    sil!exe 'sil!return "' . label . '"'
endfunction

" ----------------------------------
function! s:vimim_abcdefg_label_on()
" ----------------------------------
    if s:vimim_custom_menu_label < 1
        return
    endif
    let labels = split(s:abcdefg, '\zs')
    for _ in labels
        sil!exe'inoremap <silent>  '._.'
        \  <C-R>=<SID>vimim_abcdefg_label("'._.'")<CR>'
        \.'<C-R>=g:vimim_reset_after_insert()<CR>'
    endfor
endfunction

" -----------------------------------
function! <SID>vimim_abcdefg_label(n)
" -----------------------------------
    let label = a:n
    if pumvisible()
        let n = match(s:abcdefg, label)
        let mycount = repeat("\<Down>", n)
        let yes = s:vimim_ctrl_y_ctrl_x_ctrl_u()
        let label = mycount . yes
    endif
    sil!exe 'sil!return "' . label . '"'
endfunction

" -------------------------------------
function! s:vimim_navigation_label_on()
" -------------------------------------
    let hjkl = 'hjklmnzxc'
    let hjkl_list = split(hjkl, '\zs')
    " ---------------------------------
    if empty(s:pinyin_and_4corner)
        call extend(hjkl_list, ['p'])
    endif
    " ---------------------------------
    for _ in hjkl_list
        sil!exe 'inoremap <silent> <expr> '._.'
        \ <SID>vimim_hjkl("'._.'")'
    endfor
    " ---------------------------------
endfunction

" ----------------------------
function! <SID>vimim_hjkl(key)
" ----------------------------
    let hjkl = a:key
    if pumvisible()
        if a:key == 'h'
            let s:pumvisible_hjkl_h = 1
            let hjkl  = s:vimim_ctrl_e_ctrl_x_ctrl_u()
        elseif a:key == 'j'
            let hjkl  = '\<Down>'
        elseif a:key == 'k'
            let hjkl  = '\<Up>'
        elseif a:key == 'l'
            let hjkl  = g:vimim_pumvisible_y_yes()
        elseif a:key == 'n'
            let hjkl  = '\<Down>\<Down>\<Down>'
        elseif a:key == 'z'
            call s:reset_matched_list()
            let hjkl  = s:vimim_ctrl_e_ctrl_x_ctrl_u()
        elseif a:key == 'x'
            let hjkl  = '\<C-E>'
        elseif a:key == 'm'
            let hjkl  = '\<C-Y>'
            let hjkl .= '\<C-R>=g:vimim_one_key_correction()\<CR>'
        elseif a:key == 'c'
            let hjkl  = '\<C-R>=g:vimim_pumvisible_y_yes()\<CR>'
            let hjkl .= '\<C-R>=g:vimim_pumvisible_putclip()\<CR>'
        elseif a:key == 'p'
            let hjkl  = <SID>TabKey()
        endif
    endif
    sil!exe 'sil!return "' . hjkl . '"'
endfunction

" --------------------------------------
function! s:vimim_1234567890_filter_on()
" --------------------------------------
    if s:vimim_custom_menu_label < 1
    \|| empty(s:pinyin_and_4corner)
    \|| !empty(s:vimim_cloud_plugin)
        return
    endif
    let label = 'pqwertyuio'
    let labels = split(label, '\zs')
    if s:pinyin_and_4corner > 1
        let labels = range(10)
    endif
    for _ in labels
        sil!exe'inoremap <silent>  '._.'
        \  <C-R>=<SID>vimim_label_1234567890_filter("'._.'")<CR>'
    endfor
endfunction

" ---------------------------------------------
function! <SID>vimim_label_1234567890_filter(n)
" ---------------------------------------------
    let label = a:n
    if pumvisible()
        if s:pinyin_and_4corner > 1
            let msg = "use 1234567890 as pinyin filter"
        else
            let label_alpha = 'pqwertyuio'
            let label = match(label_alpha, a:n)
        endif
        let s:menu_4corner_as_filter = label
        let label = s:vimim_ctrl_e_ctrl_x_ctrl_u()
    endif
    sil!exe 'sil!return "' . label . '"'
endfunction

" --------------------------------------
function! s:vimim_ctrl_e_ctrl_x_ctrl_u()
" --------------------------------------
    return '\<C-E>\<C-X>\<C-U>\<C-P>\<Down>'
endfunction

" ------------------------------------
function! g:vimim_one_key_correction()
" ------------------------------------
    let key = '\<Esc>'
    call s:reset_matched_list()
    if empty(s:chinese_input_mode)
    \|| s:chinese_input_mode=~ 'onekey'
        call s:vimim_stop()
    else
        let byte_before = getline(".")[col(".")-2]
        if byte_before =~# s:valid_key
            let s:one_key_correction = 1
            let key = '\<C-X>\<C-U>\<BS>'
        endif
    endif
    sil!exe 'sil!return "' . key . '"'
endfunction

" ------------------------------------
function! g:vimim_pumvisible_p_paste()
" ------------------------------------
    if empty(s:popupmenu_matched_list)
        return "\<Esc>"
    endif
    let pastes = []
    let title = s:keyboard_leading_zero . " =>"
    let words = [title]
    if title =~ s:show_me_not_pattern
        let words = []
    endif
    for item in s:popupmenu_matched_list
        let pairs = split(item)
        let yin = get(pairs, 0)
        let yang = get(pairs, 1)
        if yang =~ "#"
            continue
        endif
        call add(words, item)
        if yin =~ s:show_me_not_pattern
            call add(pastes, yang)
        endif
    endfor
    if len(pastes) == len(words)
        let words = copy(pastes)
    endif
    let cursor_positions = getpos(".")
    let cursor_positions[2] = 1
    if s:vimim_debug < 9
        put=words
    else
        call setline(line("."), words)
    endif
    call setpos(".", cursor_positions)
    sil!call s:vimim_stop()
    if s:vimim_auto_copy_clipboard>0 && has("gui_running")
        let string_words = ''
        for line in words
            let string_words .= line
            let string_words .= "\n"
        endfor
        let @+ = string_words
    endif
    call s:reset_matched_list()
    return "\<Esc>"
endfunction

" ----------------------------------
function! g:vimim_pumvisible_y_yes()
" ----------------------------------
    let key = ''
    if pumvisible()
        let key = s:vimim_ctrl_y_ctrl_x_ctrl_u()
    else
        let key = ' '
    endif
    sil!exe 'sil!return "' . key . '"'
endfunction

" ------------------------------------
function! g:vimim_pumvisible_putclip()
" ------------------------------------
    let chinese = s:vimim_popup_word()
    sil!call s:vimim_stop()
    if len(chinese) > 0
        if s:vimim_auto_copy_clipboard>0 && has("gui_running")
            let @+ = chinese
        endif
    endif
    call s:reset_matched_list()
    return "\<Esc>"
endfunction

" ----------------------------
function! s:vimim_popup_word()
" ----------------------------
    if pumvisible()
        return ""
    endif
    let column_start = s:start_column_before
    let column_end = col('.') - 1
    let range = column_end - column_start
    let current_line = getline(".")
    let word = strpart(current_line, column_start, range)
    return word
endfunction

" --------------------------------------
function! s:vimim_ctrl_y_ctrl_x_ctrl_u()
" --------------------------------------
    return '\<C-Y>\<C-R>=g:vimim_ctrl_x_ctrl_u()\<CR>'
endfunction

" -------------------------------
function! g:vimim_ctrl_x_ctrl_u()
" -------------------------------
    let key = ''
    call s:reset_popupmenu_matched_list()
    let byte_before = getline(".")[col(".")-2]
    if byte_before =~# s:valid_key
        let key = '\<C-X>\<C-U>'
        if s:chinese_input_mode =~ 'dynamic'
            call g:reset_after_auto_insert()
        endif
        if empty(s:vimim_fancy_input_style)
            let key .= '\<C-R>=g:vimim_menu_select()\<CR>'
        endif
    else
        call g:reset_after_auto_insert()
    endif
    sil!exe 'sil!return "' . key . '"'
endfunction

" -----------------------------
function! g:vimim_menu_select()
" -----------------------------
    let select_not_insert = ''
    if pumvisible()
        let select_not_insert = '\<C-P>\<Down>'
        if s:insert_without_popup > 0
            let select_not_insert = '\<C-Y>'
            if s:insert_without_popup > 1
                let select_not_insert .= '\<Esc>'
            endif
            let s:insert_without_popup = 0
        endif
    endif
    sil!exe 'sil!return "' . select_not_insert . '"'
endfunction

" --------------------------------
function! g:vimim_search_forward()
" --------------------------------
    return s:vimim_search("/")
endfunction

" ---------------------------------
function! g:vimim_search_backward()
" ---------------------------------
    return s:vimim_search("?")
endfunction

" ---------------------------
function! s:vimim_search(key)
" ---------------------------
    let slash = ""
    if pumvisible()
        let slash  = '\<C-R>=g:vimim_pumvisible_y_yes()\<CR>'
        let slash .= '\<C-R>=g:vimim_slash_search()\<CR>'
        let slash .= a:key . '\<CR>'
    endif
    sil!exe 'sil!return "' . slash . '"'
endfunction

" ------------------------------
function! g:vimim_slash_search()
" ------------------------------
    let msg = "search from popup menu"
    let word = s:vimim_popup_word()
    if empty(word)
        let @/ = @_
    else
        let @/ = word
    endif
    let repeat_times = len(word)/s:multibyte
    let row_start = s:start_row_before
    let row_end = line('.')
    let delete_chars = ""
    if repeat_times > 0 && row_end == row_start
        let delete_chars = repeat("\<BS>", repeat_times)
    endif
    let slash = delete_chars . "\<Esc>"
    sil!call s:vimim_stop()
    sil!exe 'sil!return "' . slash . '"'
endfunction

" ------------------------------
function! g:vimim_left_bracket()
" ------------------------------
    return s:vimim_square_bracket("[")
endfunction

" -------------------------------
function! g:vimim_right_bracket()
" -------------------------------
    return s:vimim_square_bracket("]")
endfunction

" -----------------------------------
function! s:vimim_square_bracket(key)
" -----------------------------------
    let bracket = a:key
    if pumvisible()
        let i = -1
        let left = ""
        let right = ""
        if bracket == "]"
            let i = 0
            let left = "\<Left>"
            let right = "\<Right>"
        endif
        let backspace = '\<C-R>=g:vimim_bracket_backspace('.i.')\<CR>'
        let yes = '\<C-R>=g:vimim_pumvisible_y_yes()\<CR>'
        let bracket = yes . left . backspace . right
    endif
    sil!exe 'sil!return "' . bracket . '"'
endfunction

" -----------------------------------------
function! g:vimim_bracket_backspace(offset)
" -----------------------------------------
    let column_end = col('.')-1
    let column_start = s:start_column_before
    let range = column_end - column_start
    let repeat_times = range/s:multibyte
    let repeat_times += a:offset
    let row_end = line('.')
    let row_start = s:start_row_before
    let delete_char = ""
    if repeat_times > 0 && row_end == row_start
        let delete_char = repeat("\<BS>", repeat_times)
    endif
    if repeat_times < 1
        let current_line = getline(".")
        let chinese = strpart(current_line, column_start, s:multibyte)
        let delete_char = chinese
        if empty(a:offset)
            let delete_char = "\<Right>\<BS>【".chinese."】\<Left>"
        endif
    endif
    return delete_char
endfunction

" --------------------------------
function! <SID>vimim_smart_enter()
" --------------------------------
    let key = ''
    let enter = "\<CR>"
    let byte_before = getline(".")[col(".")-2]
    " -----------------------------------------------
    " <Enter> double play in Chinese Mode:
    "   (1) after English (valid keys)    => Seamless
    "   (2) after Chinese or double Enter => Enter
    " -----------------------------------------------
    if byte_before =~# "[*']"
        let s:smart_enter = 0
    elseif byte_before =~# s:valid_key
        let s:smart_enter += 1
    endif
    " -----------------------------------------------
    " <Enter> multiple play in OneKey Mode:
    " (1) after English (valid keys)    => Seamless
    " (2) after English punctuation     => <Space>
    " (3) after Chinese or double Enter => <Enter>
    " (4) after empty line              => <Enter> with invisible <Space>
    " -----------------------------------------------
    if empty(s:chinese_input_mode)
        if has_key(s:punctuations, byte_before)
            let s:smart_enter += 1
            let key = ' '
        endif
        if byte_before =~ '\s'
            let key = enter
        endif
    endif
    " -----------------------------------------------
    if s:smart_enter == 1
        let msg = "do seamless for the first time <Enter>"
        let s:pattern_not_found = 0
        let s:seamless_positions = getpos(".")
        let s:keyboard_leading_zero = ''
        let s:keyboard_head = 0
    else
        if s:smart_enter == 2
            let key = " "
        else
            let key = enter
        endif
        let s:smart_enter = 0
    endif
    " -----------------------------------------------
    if empty(s:chinese_input_mode)
        if empty(byte_before)
            let key = s:space . enter
        endif
    endif
    " -----------------------------------------------
    sil!exe 'sil!return "' . key . '"'
endfunction

" -------------------------------------
function! <SID>vimim_get_unicode_menu()
" -------------------------------------
    let trigger = '\<C-R>=g:vimim_ctrl_x_ctrl_u()\<CR>'
    let xxxx = s:vimim_get_internal_code_char_before()
    if !empty(xxxx)
        let trigger = xxxx . trigger
        sil!exe 'sil!return "' . trigger . '"'
    endif
endfunction

" ------------------------------------------
function! g:vimim_pumvisible_ctrl_e_ctrl_y()
" ------------------------------------------
    let key = ""
    if pumvisible()
        let key = "\<C-E>"
        " ----------------------------------
        if get(s:im['wubi'],0) > 0
        \&& empty(len(s:keyboard_leading_zero)%4)
            let key = "\<C-Y>"
        endif
        " ----------------------------------
    endif
    sil!exe 'sil!return "' . key . '"'
endfunction

" -----------------------------------
function! g:vimim_pumvisible_ctrl_y()
" -----------------------------------
    let key = ""
    if pumvisible()
        let key = "\<C-Y>"
    endif
    sil!exe 'sil!return "' . key . '"'
endfunction

" -----------------------------------
function! g:vimim_pumvisible_ctrl_e()
" -----------------------------------
    let key = ""
    if pumvisible()
        let key = "\<C-E>"
    endif
    sil!exe 'sil!return "' . key . '"'
endfunction

" --------------------------------------
function! g:vimim_pumvisible_ctrl_e_on()
" --------------------------------------
    let s:pumvisible_ctrl_e = 1
    return g:vimim_pumvisible_ctrl_e()
endfunction

" -------------------------------------
function! <SID>vimim_ctrl_x_ctrl_u_bs()
" -------------------------------------
    call s:reset_matched_list()
    let s:pattern_not_found = 0
    let key = '\<BS>'
    " ---------------------------------
    if s:pumvisible_ctrl_e > 0
    \&& s:chinese_input_mode =~ 'dynamic'
        let s:pumvisible_ctrl_e = 0
        let key .= '\<C-R>=g:vimim_ctrl_x_ctrl_u()\<CR>'
        sil!exe 'sil!return "' . key . '"'
    endif
    " ---------------------------------
    if empty(s:chinese_input_mode)
        call s:vimim_stop()
    endif
    " ---------------------------------
    sil!exe 'sil!return "' . key . '"'
endfunction

" ======================================= }}}
let VimIM = " ====  Omni_Popup_Menu  ==== {{{"
" ===========================================
call add(s:vimims, VimIM)

" ---------------------------------------
function! s:vimim_pair_list(matched_list)
" ---------------------------------------
    let s:matched_list = copy(a:matched_list)
    let matched_list = a:matched_list
    if empty(matched_list)
        return []
    endif
    " -----------------------------------
    let pair_matched_list = []
    let maximum_list = 288
    if len(matched_list) > maximum_list
        let matched_list = matched_list[0 : maximum_list]
    endif
    " ----------------------
    for line in matched_list
    " ----------------------
        if len(line) < 2
            continue
        endif
        if s:localization > 0
            let line = s:vimim_i18n_read(line)
        endif
        let oneline_list = split(line, '\s\+')
        let menu = remove(oneline_list, 0)
        for chinese in oneline_list
            call add(pair_matched_list, menu .' '. chinese)
        endfor
    endfor
    return pair_matched_list
endfunction

" --------------------------------------------
function! s:vimim_popupmenu_list(matched_list)
" --------------------------------------------
    let matched_list = a:matched_list
    if empty(matched_list)
    \|| type(matched_list) != type([])
        return []
    endif
    " ----------------------------------------
    let s:popupmenu_matched_list = copy(matched_list)
    " ----------------------------------------
    if s:menu_4corner_as_filter > -1
        let matched_list = s:vimim_menu_4corner_filter(a:matched_list)
        if empty(matched_list)
            return []
        endif
    endif
    " ----------------------------------------
    let menu = 0
    let label = 1
    let popupmenu_list = []
    let keyboard = s:keyboard_leading_zero
    " ----------------------
    for pair in matched_list
    " ----------------------
        let complete_items = {}
        let pairs = split(pair)
        if len(pairs) < 2
            continue
        endif
        let menu = get(pairs, 0)
        if s:unicode_menu_display_flag > 0
            let complete_items["menu"] = menu
        endif
        let chinese = get(pairs, 1)
        if chinese =~ "#"
            continue
        endif
        " -------------------------------------------------
        if s:vimim_custom_skin < 2
            let extra_text = menu
            if s:pinyin_and_4corner > 0
            \&& empty(match(extra_text, '^\d\{4}$'))
                let unicode = printf('u%04x', char2nr(chinese))
                let extra_text = menu . s:space . unicode
            endif
            if extra_text =~ s:show_me_not_pattern
                let msg = "ignore key starting with ii/oo for beauty "
                let extra_text = ''
            endif
            let complete_items["menu"] = extra_text
        endif
        " -------------------------------------------------
        if empty(s:vimim_cloud_plugin)
            let tail = ''
            if keyboard =~ '[.]' && s:has_dot_in_datafile < 1
                let dot = match(keyboard, '[.]')
                let tail = strpart(keyboard, dot+1)
            elseif keyboard !~? '^vim' && keyboard !~ "[']"
                let tail = strpart(keyboard, len(menu))
            endif
            if tail =~ '\w'
                let chinese .=  tail
                let s:keyboard_head = strpart(keyboard, 0, len(menu))
            endif
        else
            let menu = get(split(menu,"_"),0)
        endif
        " -------------------------------------------------
        let labeling = label
        if s:vimim_custom_menu_label > 0
            if label < &pumheight+1
            \&& (empty(s:chinese_input_mode)
            \|| s:chinese_input_mode=~ 'onekey')
                " -----------------------------------------
                let label2 = s:abcdefg[label-1 : label-1]
                if label < 2
                    let label2 = "_"
                endif
                " -----------------------------------------
                if s:pinyin_and_4corner > 0
                \&& empty(s:vimim_cloud_plugin)
                    let labeling = label2
                else
                    let labeling .= label2
                endif
                " -----------------------------------------
            endif
            let abbr = printf('%2s',labeling)."\t".chinese
            let complete_items["abbr"] = abbr
        endif
        " -------------------------------------------------
        let complete_items["word"] = chinese
        let complete_items["dup"] = 1
        let label += 1
        call add(popupmenu_list, complete_items)
        " -------------------------------------------------
    endfor
    let s:popupmenu_list = copy(popupmenu_list)
    return popupmenu_list
endfunction

" ======================================= }}}
let VimIM = " ====  Seamless         ==== {{{"
" ===========================================
call add(s:vimims, VimIM)

" -----------------------------------------------
function! s:vimim_get_seamless(current_positions)
" -----------------------------------------------
    if empty(s:seamless_positions)
    \|| empty(a:current_positions)
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
    let snips = split(snip, '\zs')
    for char in snips
        if char !~# s:valid_key
            return -1
        endif
    endfor
    let s:start_row_before = seamless_lnum
    let s:smart_enter = 0
    return seamless_column
endfunction

" ---------------------------------
function! <SID>vimim_set_seamless()
" ---------------------------------
    let s:seamless_positions = getpos(".")
    let s:keyboard_leading_zero = ''
    let s:keyboard_head = 0
    return ""
endfunction

" ======================================= }}}
let VimIM = " ====  Punctuations     ==== {{{"
" ===========================================
call add(s:vimims, VimIM)

" ----------------------------------------
function! s:vimim_initialize_punctuation()
" ----------------------------------------
    let s:punctuations = {}
    let s:punctuations['@']=s:space
    let s:punctuations['#']='＃'
    let s:punctuations['&']='＆'
    let s:punctuations['%']='％'
    let s:punctuations['$']='￥'
    let s:punctuations['!']='！'
    let s:punctuations['~']='～'
    let s:punctuations['+']='＋'
    let s:punctuations[':']='：'
    let s:punctuations['(']='（'
    let s:punctuations[')']='）'
    let s:punctuations['{']='〖'
    let s:punctuations['}']='〗'
    let s:punctuations['[']='【'
    let s:punctuations[']']='】'
    let s:punctuations['^']='……'
    let s:punctuations['_']='——'
    let s:punctuations['<']='《'
    let s:punctuations['>']='》'
    let s:punctuations['-']='－'
    let s:punctuations['=']='＝'
    let s:punctuations[';']='；'
    let s:punctuations[',']='，'
    let s:punctuations['.']='。'
    let s:punctuations['?']='？'
    if empty(s:vimim_wildcard_search)
        let s:punctuations['*']='﹡'
    endif
    if empty(s:vimim_backslash_close_pinyin)
        let s:punctuations['\']='、'
    endif
    if empty(s:vimim_latex_suite)
        let s:punctuations["'"]='‘’'
        let s:punctuations['"']='“”'
    endif
    let s:punctuations_all = copy(s:punctuations)
    for char in s:valid_keys
        if has_key(s:punctuations, char)
            " -----------------------------
            if !empty(s:vimim_cloud_plugin)
            \|| s:has_dot_in_datafile > 0
                unlet s:punctuations[char]
            elseif char !~# "[*.']"
                unlet s:punctuations[char]
            endif
            " -----------------------------
        endif
    endfor
endfunction

" ---------------------------------------
function! <SID>vimim_toggle_punctuation()
" ---------------------------------------
    if s:vimim_chinese_punctuation > -1
        let s:chinese_punctuation = (s:chinese_punctuation+1)%2
        sil!call s:vimim_punctuation_on()
    endif
    return ''
endfunction

" ----------------------------------
function! s:vimim_get_single_quote()
" ----------------------------------
    let pair = "‘’"
    let pairs = split(pair,'\zs')
    let s:smart_single_quotes += 1
    return get(pairs, s:smart_single_quotes % 2)
endfunction

" ----------------------------------
function! s:vimim_get_double_quote()
" ----------------------------------
    let pair = "“”"
    let pairs = split(pair,'\zs')
    let s:smart_double_quotes += 1
    return get(pairs, s:smart_double_quotes % 2)
endfunction

" -----------------------------------
function! <SID>vimim_punctuation_on()
" -----------------------------------
    if s:chinese_input_mode =~ 'dynamic'
    \|| s:chinese_input_mode =~ 'static'
        unlet s:punctuations['\']
        unlet s:punctuations['"']
        unlet s:punctuations["'"]
    endif
    " ----------------------------
    if s:chinese_punctuation > 0
        if empty(s:vimim_latex_suite)
            if get(s:im['erbi'],0)>0 || get(s:im['pinyin'],0)>0
                let msg = "apostrophe is over-loaded for cloud at will"
            else
                inoremap ' <C-R>=<SID>vimim_get_single_quote()<CR>
            endif
            if index(s:valid_keys, '"') < 0
                inoremap " <C-R>=<SID>vimim_get_double_quote()<CR>
            endif
        endif
        if empty(s:vimim_backslash_close_pinyin)
            if index(s:valid_keys, '\') < 0
                inoremap <Bslash> 、
            endif
        endif
    else
        iunmap '
        iunmap "
        iunmap <Bslash>
    endif
    " --------------------------------------
    for _ in keys(s:punctuations)
        sil!exe 'inoremap <silent> '._.'
        \    <C-R>=<SID>vimim_punctuation_mapping("'._.'")<CR>'
        \ . '<C-R>=g:reset_after_auto_insert()<CR>'
    endfor
    " --------------------------------------
    call s:vimim_punctuation_navigation_on()
    " --------------------------------------
endfunction

" -------------------------------------------
function! <SID>vimim_punctuation_mapping(key)
" -------------------------------------------
    let value = s:vimim_get_chinese_punctuation(a:key)
    if pumvisible()
        let value = "\<C-Y>" . value
    endif
    sil!exe 'sil!return "' . value . '"'
endfunction

" -------------------------------------------
function! s:vimim_punctuation_navigation_on()
" -------------------------------------------
    if s:vimim_chinese_punctuation < 0
        return
    endif
    " ---------------------------------------
    let default = "=-[]"
    let semicolon = ";"
    let period = "."
    let comma = ","
    let slash = "/"
    let question_mark = "?"
    " ---------------------------------------
    let punctuation = default . semicolon . period . comma . slash
    if s:vimim_punctuation_navigation < 1
        let punctuation = default . semicolon
    endif
    if s:chinese_input_mode =~ 'dynamic'
    \|| s:chinese_input_mode =~ 'static'
        let punctuation = default
    endif
    " ---------------------------------------
    let hjkl_list = split(punctuation,'\zs')
    if empty(s:chinese_input_mode)
        call add(hjkl_list, question_mark)
    endif
    " ---------------------------------------
    let msg = "we should never map valid keycode"
    for char in s:valid_keys
        let i = index(hjkl_list, char)
        if i > -1 && char != period
            unlet hjkl_list[i]
        endif
    endfor
    " ---------------------------------------
    for _ in hjkl_list
        sil!exe 'inoremap <silent> <expr> '._.'
        \ <SID>vimim_punctuations_navigation("'._.'")'
    endfor
endfunction

" -----------------------------------------------
function! <SID>vimim_punctuations_navigation(key)
" -----------------------------------------------
    let hjkl = a:key
    if pumvisible()
        if a:key == ";"
            let hjkl  = '\<Down>\<C-Y>'
            let hjkl .= '\<C-R>=g:vimim_reset_after_insert()\<CR>'
        elseif a:key == "["
            let hjkl  = '\<C-R>=g:vimim_left_bracket()\<CR>'
        elseif a:key == "]"
            let hjkl  = '\<C-R>=g:vimim_right_bracket()\<CR>'
        elseif a:key == "/"
            let hjkl  = '\<C-R>=g:vimim_search_forward()\<CR>'
        elseif a:key == "?"
            let hjkl  = '\<C-R>=g:vimim_search_backward()\<CR>'
        elseif a:key =~ "[-,=.]"
            let hjkl = s:vimim_pageup_pagedown(a:key)
        endif
    else
        if s:chinese_input_mode =~ 'dynamic'
        \|| s:chinese_input_mode =~ 'static'
            let hjkl = s:vimim_get_chinese_punctuation(hjkl)
        endif
    endif
    sil!exe 'sil!return "' . hjkl . '"'
endfunction

" ------------------------------------
function! s:vimim_pageup_pagedown(key)
" ------------------------------------
    let key = a:key
    if key == ',' || key == '-'
        if s:vimim_reverse_pageup_pagedown > 0
            let key = '\<PageDown>'
        else
            let key = '\<PageUp>'
        endif
    elseif key == '.' || key == '='
        if s:vimim_reverse_pageup_pagedown > 0
            let key = '\<PageUp>'
        else
            let key = '\<PageDown>'
        endif
    endif
    return key
endfunction

" ------------------------------------------------------------
function! s:vimim_get_chinese_punctuation(english_punctuation)
" ------------------------------------------------------------
    let value = a:english_punctuation
    if s:chinese_punctuation > 0
    \&& has_key(s:punctuations, value)
        let byte_before = getline(".")[col(".")-2]
        let filter = '\w'     |" english_punctuation_after_english
        if empty(s:vimim_english_punctuation)
            let filter = '\d' |" english_punctuation_after_digit
        endif
        if byte_before !~ filter
            let value = s:punctuations[value]
        endif
    endif
    return value
endfunction

" ======================================= }}}
let VimIM = " ====  Chinese_Number   ==== {{{"
" ===========================================
call add(s:vimims, VimIM)

" ----------------------------------------
function! s:vimim_initialize_quantifiers()
" ----------------------------------------
    let s:quantifiers = {}
    if s:vimim_imode_universal < 1
    \&& s:vimim_imode_pinyin < 1
        return
    endif
    let q = {}
    let q['1'] = '一壹①⒈⑴甲'
    let q['2'] = '二贰②⒉⑵乙'
    let q['3'] = '三叁③⒊⑶丙'
    let q['4'] = '四肆④⒋⑷丁'
    let q['5'] = '五伍⑤⒌⑸戊'
    let q['6'] = '六陆⑥⒍⑹己'
    let q['7'] = '七柒⑦⒎⑺庚'
    let q['8'] = '八捌⑧⒏⑻辛'
    let q['9'] = '九玖⑨⒐⑼壬'
    let q['0'] = '〇零⑩⒑⑽癸十拾'
    let q['a'] = '秒'
    let q['b'] = '百佰步把包杯本笔部班'
    let q['c'] = '厘次餐场串处床'
    let q['d'] = '第度点袋道滴碟顶栋堆对朵堵顿'
    let q['e'] = '亿'
    let q['f'] = '分份发封付副幅峰方服'
    let q['g'] = '个根股管'
    let q['h'] = '时毫行盒壶户回'
    let q['i'] = '毫'
    let q['j'] = '斤家具架间件节剂具捲卷茎记'
    let q['k'] = '克口块棵颗捆孔'
    let q['l'] = '里粒类辆列轮厘升领缕'
    let q['m'] = '米名枚面门秒'
    let q['n'] = '年'
    let q['o'] = '度'
    let q['p'] = '磅盆瓶排盘盆匹片篇撇喷'
    let q['q'] = '千仟群'
    let q['r'] = '日'
    let q['s'] = '十拾时升艘扇首双所束手'
    let q['t'] = '吨条头通堂台套桶筒贴趟'
    let q['u'] = '微'
    let q['w'] = '万位味碗窝'
    let q['x'] = '升席些项'
    let q['y'] = '月亿叶'
    let q['z'] = '兆只张株支枝指盏座阵桩尊则种站幢宗'
    let s:quantifiers = q
endfunction

" ----------------------------------------------
function! s:vimim_imode_number(keyboard, prefix)
" ----------------------------------------------
    if s:chinese_input_mode =~ 'dynamic'
        return []
    endif
    let keyboard = a:keyboard
    " ------------------------------------------
    if a:prefix ==# "'" && get(s:im['boshiamy'],0)<1
        let keyboard = substitute(keyboard,"'",'i','g')
    endif
    " ------------------------------------------
    if strpart(keyboard,0,2) ==# 'ii'
        let keyboard = 'I' . strpart(keyboard,2)
    endif
    let ii_keyboard = keyboard
    let keyboard = strpart(keyboard,1)
    " ------------------------------------------
    if keyboard !~ '^\d\+' && keyboard !~# '^[ds]'
    \&& len(substitute(keyboard,'\d','','')) > 1
        return []
    endif
    " ------------------------------------------
    let digit_alpha = keyboard
    if keyboard =~# '^\d*\l\{1}$'
        let digit_alpha = keyboard[:-2]
    endif
    let keyboards = split(digit_alpha, '\ze')
    let i = ii_keyboard[:0]
    let number = s:vimim_get_chinese_number(keyboards, i)
    if empty(number)
        return []
    endif
    let numbers = [number]
    let last_char = keyboard[-1:]
    if !empty(last_char) && has_key(s:quantifiers, last_char)
        let quantifier = s:quantifiers[last_char]
        let quantifiers = split(quantifier, '\zs')
        if keyboard =~# '^[ds]\=\d*\l\{1}$'
            if keyboard =~# '^[ds]'
                let number = strpart(number,0,len(number)-s:multibyte)
            endif
            let numbers = map(copy(quantifiers), 'number . v:val')
        elseif keyboard =~# '^\d*$' && len(keyboards)<2 && i ==# 'i'
            let numbers = quantifiers
        endif
    endif
    if len(numbers) == 1
        let s:insert_without_popup = 1
    endif
    if len(numbers) > 0
        call map(numbers, 'a:keyboard ." ". v:val')
    endif
    return numbers
endfunction

" ------------------------------------------------
function! s:vimim_get_chinese_number(keyboards, i)
" ------------------------------------------------
    if empty(a:keyboards) && a:i !~? 'i'
        return 0
    endif
    let chinese_number = ''
    for char in a:keyboards
        if has_key(s:quantifiers, char)
            let quantifier = s:quantifiers[char]
            let quantifiers = split(quantifier,'\zs')
            if a:i ==# 'i'
                let chinese_number .= get(quantifiers,0)
            elseif a:i ==# 'I'
                let chinese_number .= get(quantifiers,1)
            endif
        else
            let chinese_number .= char
        endif
    endfor
    return chinese_number
endfunction

" ======================================= }}}
let VimIM = " ====  Input_4Corner    ==== {{{"
" ===========================================
call add(s:vimims, VimIM)

" ------------------------------------------
function! s:vimim_break_every_four(keyboard)
" ------------------------------------------
    if s:chinese_input_mode =~ 'dynamic'
    \|| len(a:keyboard)%4 != 0
        return []
    endif
    " -------------------------------
    " sijiaohaoma == 6021272260021762
    " -------------------------------
    let keyboards = split(a:keyboard, '\(.\{4}\)\zs')
    return keyboards
endfunction

" ------------------------------------------
function! <SID>vimim_visual_ctrl_6(keyboard)
" ------------------------------------------
    if len(a:keyboard) > 1
        call s:vimim_visual_ctrl_6_directory(a:keyboard)
    endif
endfunction

" -------------------------------------------------
function! s:vimim_visual_ctrl_6_directory(keyboard)
" -------------------------------------------------
" [input]     马力
" [output]    9a6c 529b   --  unicode
"             马   力
"             7712 4002   --  4corner
"             马   力
"             ma3  li4    --  pinyin
"             马   力
"             ml 马力     --  cjjp
" -------------------------------------------------
    let keyboard = a:keyboard
    let results = []
    if keyboard !~ '\p'
        let results = s:vimim_reverse_lookup(keyboard)
    endif
    call s:vimim_visual_ctrl_6_output(results)
endfunction

" ---------------------------------------------
function! s:vimim_visual_ctrl_6_output(results)
" ---------------------------------------------
    let results = a:results
    if empty(results)
        return
    endif
    let line = line(".")
    call setline(line, results)
    let new_positions = getpos(".")
    let new_positions[1] = line + len(results) - 1
    let new_positions[2] = len(get(split(get(results,-1)),0))+1
    call setpos(".", new_positions)
endfunction

" ---------------------------------------
function! s:vimim_reverse_lookup(chinese)
" ---------------------------------------
    let chinese = substitute(a:chinese,'\s\+\|\w\|\n','','g')
    let chinese_characters = split(chinese,'\zs')
    let items = []
    " -----------------------------------
    let results = []
    " -----------------------------------
    let cache = {}
    let characters = split(chinese, '\zs')
    for char in characters
        let unicode = printf('u%04x',char2nr(char))
        let cache[char] = unicode
    endfor
    let items = s:vimim_reverse_one_entry(cache, chinese)
    call add(results, get(items,0))
    call add(results, get(items,1))
    let results_unicode = copy(results)
    " ------------------------------------
    let results = []          |" 马力 => u9a6c u529b
    let results_pinyin = []   |" 马力 => ma3 li2
    let results_4corner = []  |" 马力 => 7712 4002
    let result_cjjp = ""      |" 马力 => ml
    " ------------------------------------
    let unihan = s:vimim_get_data_directory('unihan')
    if !empty(unihan)
        let im = '4corner'
        let cache = s:vimim_get_unihan_reverse_cache(chinese, im)
        let items = s:vimim_reverse_one_entry(cache, chinese)
        call add(results, get(items,0))
        call add(results, get(items,1))
        let results_4corner = copy(results)
        " --------------------------------------
        let results = []
        " --------------------------------------
        let im = 'pinyin'
        let cache = s:vimim_get_unihan_reverse_cache(chinese, im)
        let items = s:vimim_reverse_one_entry(cache, chinese)
        let pinyin_head = get(items,0)
        if !empty(pinyin_head)
            call add(results, pinyin_head)
            call add(results, get(items,1))
            for pinyin in split(pinyin_head)
                let result_cjjp .= pinyin[0:0]
            endfor
            let result_cjjp .= " ".chinese
        endif
        let results_pinyin = copy(results)
    endif
    " ------------------------------------------------
    let results = []
    if len(results_4corner) > 0
        call extend(results, results_4corner)
    endif
    if len(results_unicode) > 0
        call extend(results, results_unicode)
    endif
    if len(results_pinyin) > 0
        call extend(results, results_pinyin)
        if result_cjjp =~ '\a'
            call add(results, result_cjjp)
        endif
    endif
    return results
endfunction

" -------------------------------------------------
function! s:vimim_reverse_one_entry(cache, chinese)
" -------------------------------------------------
    if empty(a:cache) || empty(a:chinese)
        return []
    endif
    let characters = split(a:chinese, '\zs')
    let results = []
    let headers = []  "|  ma3 li4
    let bodies = []   "|  马  力
    for char_chinese in characters
        if has_key(a:cache, char_chinese)
            let head = a:cache[char_chinese]
            call add(headers, head)
            let spaces = ''
            let number_of_space = len(head)-2
            if  number_of_space > 0
                let space = ' '
                for i in range(number_of_space)
                    let spaces .= space
                endfor
            endif
            call add(bodies, char_chinese . spaces)
        endif
    endfor
    call add(results, join(headers))
    call add(results, join(bodies))
    return results
endfunction

" -----------------------------------------------------
function! s:vimim_get_unihan_reverse_cache(chinese, im)
" -----------------------------------------------------
" [input]  '馬力','4corner' || '馬力','pinyin'
" [output] {'馬': '7132', '力': '4002'}
" ----------------------------------------------
    let cache = {}
    let chinese = a:chinese
    let characters = split(chinese, '\zs')
    let im = 'unihan'  " # u808f => 8022 cao4
    for char in characters
        let key = printf('u%x',char2nr(char))
        let results = s:vimim_get_data_from_directory(key, im)
        if empty(results)
            continue
        else
            let value = char
            if a:im =~ '4corner'
                let value = get(split(get(results,0)),1)
                if value =~ '\l'
                    let value = '....'  |" 4corner not available
                endif
            elseif a:im =~ 'pinyin'
                let value = get(split(get(results,1)),1)
                if value !~ '^\l\+\d$'
                    let value = get(split(get(results,0)),1)
                endif
            endif
            let cache[char] = value
        endif
    endfor
    return cache
endfunction

" -------------------------------------------------
function! s:vimim_menu_4corner_filter(matched_list)
" -------------------------------------------------
    let matched_list = a:matched_list
    let menu_cache = s:vimim_chinese_menu_hash(matched_list)
    if empty(menu_cache) |" {'马':'ma', '妈啊':'ma'}
        return matched_list
    endif
    " ---------------------------------------------
    let digit = s:menu_4corner_as_filter  |" {'马':7}
    let digit_list = s:vimim_get_data_from_directory(digit, '4corner')
    let digit_cache = s:vimim_chinese_menu_hash(digit_list)
    let results = []
    if empty(digit_cache)
        let msg = " no 4corner for all list in the menu"
    else
        let results = s:vimim_double_filter(menu_cache, digit_cache, 0)
    endif
    return results
endfunction

" --------------------------------------------
function! s:vimim_chinese_menu_hash(menu_list)
" --------------------------------------------
    let menu_list = a:menu_list
    if empty(menu_list)
        return {}
    endif
    " ----------------------------------------
    let digit = get(split(get(menu_list,0)),0)
    if digit =~ '\d'
        if has_key(s:digit_cache, digit)
            return s:digit_cache[digit]
        endif
    endif
    " ----------------------------------------
    let chinese_to_keyboard_hash = {}
    for line in menu_list
        let words = split(line)  |" shishi 事实    7 马
        let menu = get(words,0)  |" shishi         7
        for word in words
            if word != menu
                let chinese_to_keyboard_hash[word] = menu
            endif
        endfor
    endfor
    " ----------------------------------------
    if digit =~ '\d'
        let s:digit_cache[digit] = chinese_to_keyboard_hash
    endif
    " ----------------------------------------
    return chinese_to_keyboard_hash
endfunction

" ----------------------------------------------------------------------
function! s:vimim_double_filter(chinese2pinyin, chinese2digit, position)
" ----------------------------------------------------------------------
    if empty(a:chinese2pinyin) || empty(a:chinese2digit)
        return []
    endif
    let values = []
    for key in keys(a:chinese2pinyin)
        if len(key) < s:multibyte
            continue
        endif
        " --------------------------------------
        let char_first = key[: s:multibyte-1]
        let char_last = key[-s:multibyte :]
        let char = char_first
        if a:position < 0
            let char = char_last
        endif
        " --------------------------------------
        let menu_vary = ""
        let menu_fix  = ""
        if has_key(a:chinese2digit, char)
            let menu_vary = a:chinese2pinyin[key]
            let menu_fix  = a:chinese2digit[char]
        endif
        " --------------------------------------
        if !empty(menu_fix) && !empty(menu_vary)
            let menu =  menu_vary
            if a:position < 0
                let menu = menu_fix . s:space . menu_vary
            endif
            call add(values, menu . " " . key)
        endif
    endfor
    return sort(values)
endfunction

" ======================================= }}}
let VimIM = " ====  Input_Pinyin     ==== {{{"
" ===========================================
call add(s:vimims, VimIM)

" -----------------------------------
function! s:vimim_initialize_pinyin()
" -----------------------------------
    if empty(get(s:im['pinyin'],0))
        if len(s:data_directory_pinyin) > 1
            let s:im['pinyin'][0] = 1
        else
            return
        endif
    endif
    if empty(s:vimim_imode_pinyin)
    \&& empty(s:vimim_imode_universal)
    \&& s:shuangpin_flag < 1
        let s:vimim_imode_pinyin = 1
    endif
endfunction

" ------------------------------------
function! s:vimim_apostrophe(keyboard)
" ------------------------------------
    let keyboard = a:keyboard
    if keyboard =~ "[']"
    \&& keyboard[0:0] != "'"
    \&& keyboard[-1:-1] != "'"
        let msg = "valid apostrophe is typed"
    else
        let zero_or_one = "'\\="
        let keyboard = join(split(keyboard,'\ze'), zero_or_one)
    endif
    return keyboard
endfunction

" ------------------------------------------------
function! s:vimim_get_pinyin_from_pinyin(keyboard)
" ------------------------------------------------
    if s:shuangpin_flag > 0
        return []
    else
        let msg = "pinyin breakdown: pinyin=>pin'yin "
    endif
    let keyboard2 = s:vimim_quanpin_transform(a:keyboard)
    if s:vimimdebug > 0
        call s:debugs('pinyin_in', a:keyboard)
        call s:debugs('pinyin_out', keyboard2)
    endif
    let results = split(keyboard2,"'")
    if len(results) > 1
        return results
    endif
    return []
endfunction

" -------------------------------------------
function! s:vimim_quanpin_transform(keyboard)
" -------------------------------------------
    let qptable = s:quanpin_table
    let item = a:keyboard
    let pinyinstr = ""     |" output string
    let index = 0
    let lenitem = len(item)
    while index < lenitem
        if item[index] !~ "[a-z]"
            let index += 1
            continue
        endif
        for i in range(6,1,-1)
            " NOTE: remove the space after index will cause syntax error
            let tmp = item[index : ]
            if len(tmp) < i
                continue
            endif
            let end = index+i
            let matchstr = item[index : end-1]
            if has_key(qptable, matchstr)
                let tempstr = item[end-1 : end]
                " special case for fanguo, which should be fan'guo
                if tempstr == "gu" || tempstr == "nu" || tempstr == "ni"
                    if has_key(qptable, matchstr[:-2])
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
                    if has_key(qptable, matchstr[:-2])
                        let i -= 1
                        let matchstr = matchstr[:-2]
                    endif
                endif
                let pinyinstr .= "'" . qptable[matchstr]
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

" --------------------------------------
function! s:vimim_create_quanpin_table()
" --------------------------------------
    let pinyin_list = s:vimim_get_pinyin_table()
    let table = {}
    for key in pinyin_list
        if key[0] == "'"
            let table[key[1:]] = key[1:]
        else
            let table[key] = key
        endif
    endfor
    for shengmu in ["b", "p", "m", "f", "d", "t", "l", "n", "g", "k", "h",
        \"j", "q", "x", "zh", "ch", "sh", "r", "z", "c", "s", "y", "w"]
        let table[shengmu] = shengmu
    endfor
    return table
endfunction

" ======================================= }}}
let VimIM = " ====  Input_Shuangpin  ==== {{{"
" ===========================================
call add(s:vimims, VimIM)

" --------------------------------------
function! s:vimim_dictionary_shuangpin()
" --------------------------------------
    let s:shuangpin_flag = 1
    let key = 'shuangpin'
    let loaded = s:vimim_get_chinese(key)
    let im = loaded
    let keycode = "[0-9a-z'.]"
    if s:vimim_shuangpin_abc > 0
        let im = s:vimim_get_chinese('abc')
    elseif s:vimim_shuangpin_microsoft > 0
        let microsoft = s:vimim_get_chinese('microsoft')
        let im = microsoft . im
        let keycode = "[0-9a-z'.;]"
    elseif s:vimim_shuangpin_nature > 0
        let nature = s:vimim_get_chinese('nature')
        let im = nature . im
    elseif s:vimim_shuangpin_plusplus > 0
        let plusplus = s:vimim_get_chinese('plusplus')
        let im = plusplus . im
    elseif s:vimim_shuangpin_purple > 0
        let purple = s:vimim_get_chinese('purple')
        let im = purple . im
        let keycode = "[0-9a-z'.;]"
    elseif s:vimim_shuangpin_flypy > 0
        let flypy = s:vimim_get_chinese('flypy')
        let im = flypy . im
    else
        let s:shuangpin_flag = 0
    endif
    let s:im[key] = [loaded, im, keycode]
endfunction

" --------------------------------------
function! s:vimim_initialize_shuangpin()
" --------------------------------------
    call s:vimim_dictionary_shuangpin()
    " ----------------------------------
    if empty(s:shuangpin_flag)
        let s:quanpin_table = s:vimim_create_quanpin_table()
        return
    endif
    " ----------------------------------
    let s:vimim_imode_pinyin = -1
    let rules = s:vimim_shuangpin_generic()
    " ----------------------------------
    if s:vimim_shuangpin_abc > 0
        let rules = s:vimim_shuangpin_abc(rules)
        let s:vimim_imode_pinyin = 1
    elseif s:vimim_shuangpin_microsoft > 0
        let rules = s:vimim_shuangpin_microsoft(rules)
    elseif s:vimim_shuangpin_nature > 0
        let rules = s:vimim_shuangpin_nature(rules)
    elseif s:vimim_shuangpin_plusplus > 0
        let rules = s:vimim_shuangpin_plusplus(rules)
    elseif s:vimim_shuangpin_purple > 0
        let rules = s:vimim_shuangpin_purple(rules)
    elseif s:vimim_shuangpin_flypy > 0
        let rules = s:vimim_shuangpin_flypy(rules)
    endif
    let s:shuangpin_table = s:vimim_create_shuangpin_table(rules)
endfunction

" ---------------------------------------------------
function! s:vimim_get_pinyin_from_shuangpin(keyboard)
" ---------------------------------------------------
    let keyboard = a:keyboard
    if empty(s:shuangpin_flag)
        return keyboard
    endif
    if empty(s:keyboard_shuangpin)
        let msg = "it is here to resume shuangpin"
    else
        return keyboard
    endif
    let keyboard2 = s:vimim_shuangpin_transform(keyboard)
    if s:vimimdebug > 0
        call s:debugs('shuangpin_in', keyboard)
        call s:debugs('shuangpin_out', keyboard2)
    endif
    if keyboard2 ==# keyboard
        let msg = "no point to do transform"
    else
        let s:keyboard_shuangpin = keyboard
        let s:keyboard_leading_zero = keyboard2
        let keyboard = keyboard2
    endif
    return keyboard
endfunction

" ---------------------------------------------
function! s:vimim_shuangpin_transform(keyboard)
" ---------------------------------------------
    let keyboard = a:keyboard
    let size = strlen(keyboard)
    let ptr = 0
    let output = ""
    let bchar = "" " work-around for sogou
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
" List of all valid pinyin
" NOTE: Don't change this function or remove the spaces after commas.
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

" --------------------------------------------
function! s:vimim_create_shuangpin_table(rule)
" --------------------------------------------
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
    if (s:vimim_shuangpin_abc>0) || (s:vimim_shuangpin_purple>0)
        \ || (s:vimim_shuangpin_nature>0) || (s:vimim_shuangpin_flypy>0)
        let jxqy = {"jv" : "ju", "qv" : "qu", "xv" : "xu", "yv" : "yu"}
        call extend(sptable, jxqy)
    elseif s:vimim_shuangpin_microsoft > 0
        let jxqy = {"jv" : "jue", "qv" : "que", "xv" : "xue", "yv" : "yue"}
        call extend(sptable, jxqy)
    endif
    " the flypy shuangpin special case handling
    if s:vimim_shuangpin_flypy>0
        let flypy = {"aa" : "a", "oo" : "o", "ee" : "e",
                    \"an" : "an", "ao" : "ao", "ai" : "ai", "ah": "ang",
                    \"os" : "ong","ou" : "ou",
                    \"en" : "en", "er" : "er", "ei" : "ei", "eg": "eng" }
        call extend(sptable, flypy)
    endif
    " the nature shuangpin special case handling
    if s:vimim_shuangpin_nature>0
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
    " finished init sptable, will use in s:vimim_shuangpin_transform
    return sptable
endfunction

" -----------------------------------
function! s:vimim_shuangpin_generic()
" -----------------------------------
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

" -----------------------------------
function! s:vimim_shuangpin_abc(rule)
" -----------------------------------
" vtpc => shuang pin => double pinyin
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

" -----------------------------------------
function! s:vimim_shuangpin_microsoft(rule)
" -----------------------------------------
" vi=>zhi ii=>chi ui=>shi keng=>keneng
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

" --------------------------------------
function! s:vimim_shuangpin_nature(rule)
" --------------------------------------
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

" ----------------------------------------
function! s:vimim_shuangpin_plusplus(rule)
" ----------------------------------------
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

" --------------------------------------
function! s:vimim_shuangpin_purple(rule)
" --------------------------------------
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

" -------------------------------------
function! s:vimim_shuangpin_flypy(rule)
" -------------------------------------
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

" ======================================= }}}
let VimIM = " ====  Input_Wubi       ==== {{{"
" ===========================================
call add(s:vimims, VimIM)

" ------------------------------
function! s:vimim_wubi(keyboard)
" ------------------------------
    let keyboard = a:keyboard
    let results = []
    " ----------------------------
    if s:vimim_wildcard_search > 0
    \&& len(keyboard) > 2
    \&& s:chinese_input_mode !~ 'dynamic'
        let results = s:vimim_wubi_z_as_wildcard(keyboard)
        if len(results) > 0
            return results
        endif
    endif
    " ----------------------------
    " support wubi non-stop typing
    " ----------------------------
    if s:chinese_input_mode =~ 'dynamic'
        if len(keyboard) > 4
            let start = 4*((len(keyboard)-1)/4)
            let keyboard = strpart(keyboard, start)
        endif
        let s:keyboard_leading_zero = keyboard
    endif
    " ----------------------------
    if len(s:path2) > 4
        let results = s:vimim_get_data_from_directory(keyboard, 'wubi')
    else
        let results = s:vimim_fixed_match(s:lines, keyboard, 3)
    " ----------------------------
    if s:chinese_input_mode =~ 'dynamic' && empty(results)
        let s:keyboard_leading_zero = ''
    endif
    return results
endfunction

" --------------------------------------------
function! s:vimim_wubi_z_as_wildcard(keyboard)
" --------------------------------------------
    let keyboard = a:keyboard
    if match(keyboard, 'z') < 1
        return []
    endif
    let lines = copy(s:lines)
    if a:keyboard[:1] != 'zz'
        let keyboard = substitute(a:keyboard,'z','.','g')
    endif
    let pattern = '^' . keyboard . '\>'
    call filter(lines, 'v:val =~ pattern')
    return lines
endfunction

" ======================================= }}}
let VimIM = " ====  Input_Misc       ==== {{{"
" ===========================================
call add(s:vimims, VimIM)

" ---------------------------------
function! s:vimim_initialize_erbi()
" ---------------------------------
    if empty(get(s:im['erbi'],0))
        return
    endif
    let s:im['wubi'][0] = 1
    let s:vimim_punctuation_navigation = -1
    let s:vimim_wildcard_search = -1
endfunction

" ------------------------------------------------
function! s:vimim_first_punctuation_erbi(keyboard)
" ------------------------------------------------
    let keyboard = a:keyboard
    if empty(get(s:im['erbi'],0))
        return 0
    endif
    " [erbi] the first .,/;' is punctuation
    let chinese_punctuatoin = 0
    if len(keyboard) == 1
    \&& keyboard =~ "[.,/;]"
    \&& has_key(s:punctuations_all, keyboard)
        let chinese_punctuatoin = s:punctuations_all[keyboard]
    endif
    return chinese_punctuatoin
endfunction

" ======================================= }}}
let VimIM = " ====  Backend_Unicode  ==== {{{"
" ===========================================
call add(s:vimims, VimIM)

" -------------------------------------
function! s:vimim_initialize_encoding()
" -------------------------------------
    call s:vimim_set_encoding()
    let s:localization = s:vimim_localization()
    let s:multibyte = 2
    let s:max_ddddd = 64928
    if &encoding == "utf-8"
        let s:multibyte = 3
        let s:max_ddddd = 40869
    endif
    if s:localization > 0
        let warning = 'performance hit if &encoding & datafile differs!'
    endif
endfunction

" ------------------------------
function! s:vimim_set_encoding()
" ------------------------------
    let s:encoding = "utf8"
    if  &encoding == "chinese"
    \|| &encoding == "cp936"
    \|| &encoding == "gb2312"
    \|| &encoding == "gbk"
    \|| &encoding == "euc-cn"
        let s:encoding = "chinese"
    elseif  &encoding == "taiwan"
    \|| &encoding == "cp950"
    \|| &encoding == "big5"
    \|| &encoding == "euc-tw"
        let s:encoding = "taiwan"
    endif
endfunction

" ------------------------------
function! s:vimim_localization()
" ------------------------------
    let localization = 0
    let datafile_fenc_chinese = 0
    if empty(s:vimim_datafile_is_not_utf8)
        let msg = 'current datafile is chinese encoding'
    else
        let datafile_fenc_chinese = 1
    endif
    " ------------ ----------------- --------------
    " vim encoding datafile encoding s:localization
    " ------------ ----------------- --------------
    "   utf-8          utf-8                0
    "   utf-8          chinese              1
    "   chinese        utf-8                2
    "   chinese        chinese              8
    " ------------ ----------------- --------------
    if &encoding == "utf-8"
        if datafile_fenc_chinese > 0
            let localization = 1
        endif
    elseif empty(datafile_fenc_chinese)
        let localization = 2
    endif
    return localization
endfunction

" -------------------------------------
function! s:vimim_i18n_read_list(lines)
" -------------------------------------
    if empty(a:lines)
        return []
    endif
    let results = []
    if empty(s:localization)
        return a:lines
    else
        for line in a:lines
            let line = s:vimim_i18n_read(line)
            call add(results, line)
        endfor
    endif
    return results
endfunction

" -------------------------------
function! s:vimim_i18n_read(line)
" -------------------------------
    let line = a:line
    if s:localization == 1
        let line = iconv(line, "chinese", "utf-8")
    elseif s:localization == 2
        let line = iconv(line, "utf-8", &enc)
    endif
    return line
endfunction

" --------------------------------
function! s:vimim_i18n_iconv(line)
" --------------------------------
    let line = a:line
    if s:localization == 1
        let line = iconv(line, "utf-8", &enc)
    elseif s:localization == 2
        let line = iconv(line, &enc, "utf-8")
    endif
    return line
endfunction

" ------------------
function! CJK16(...)
" ------------------
" This function outputs unicode block by block as:
" ----------------------------------------------------
"      0  1  2  3  4  5  6  7  8  9  A  B  C  D  E  F
" 4E00 #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #
" ----------------------------------------------------
    if &encoding != "utf-8"
        $put='Your Vim encoding has to be set as utf-8.'
        $put='[usage]'
        $put='(in .vimrc):      :set encoding=utf-8'
        $put='(in Vim Command): :call CJK16()<CR>'
        $put='(in Vim Command): :call CJK16(0x8000,16)<CR>'
    else
        let a = 0x4E00| let n = 112-24| let block = 0x00F0
        if (a:0>=1)| let a = a:1| let n = 1| endif
        if (a:0==2)| let n = a:2| endif
        let z = a + n*block - 128
        while a <= z
            if empty(a%(16*16))
                $put='----------------------------------------------------'
                $put='     0  1  2  3  4  5  6  7  8  9  A  B  C  D  E  F '
                $put='----------------------------------------------------'
            endif
            let c = printf('%04X ',a)
            for j in range(16)|let c.=nr2char(a).' '|let a+=1|endfor
            $put=c
        endwhile
    endif
endfunction

" -------------
function! CJK()
" -------------
" This function outputs unicode as:
" ---------------------------------
"   decimal  hex    CJK
"   39340    99ac    馬
" ---------------------------------
    if &encoding != "utf-8"
        $put='Your Vim encoding has to be set as utf-8.'
        $put='[usage]    :call CJK()<CR>'
    else
        let unicode_start = 19968  "| 一
        let unicode_end   = 40869  "| 龥
        for i in range(unicode_start, unicode_end)
            $put=printf('%d %x ',i,i).nr2char(i)
        endfor
    endif
    return ''
endfunction

" ----------------------------------
function! s:vimim_egg_vimimunicode()
" ----------------------------------
    if s:encoding != "utf8"
        return []
    endif
    let msg = " Unicode 中文部首起始碼位表【康熙字典】"
    let u  = "一丨丶丿乙亅二亠人儿入八冂冖冫几凵刀力勹匕匚匸十"
    let u .= "卜卩厂厶又口囗土士夂夊夕大女子宀寸小尢尸屮山巛工"
    let u .= "己巾干幺广廴廾弋弓彐彡彳心戈戶手支攴文斗斤方无日"
    let u .= "曰月木欠止歹殳毋比毛氏气水火爪父爻爿片牙牛犬玄玉"
    let u .= "瓜瓦甘生用田疋疒癶白皮皿目矛矢石示禸禾穴立竹米糸"
    let u .= "缶网羊羽老而耒耳聿肉臣自至臼舌舛舟艮色艸虍虫血行"
    let u .= "衣襾見角言谷豆豕豸貝赤走足身車辛辰辵邑酉釆里金長"
    let u .= "門阜隶隹雨靑非面革韋韭音頁風飛食首香馬骨高髟鬥鬯"
    let u .= "鬲鬼魚鳥鹵鹿麥麻黃黍黑黹黽鼎鼓鼠鼻齊齒龍龜龠"
    let unicodes = split(u, '\zs')
    let eggs = []
    for char in unicodes
        let ddddd = char2nr(char)
        let xxxx = s:vimim_decimal2hex(ddddd)
        let display = "U+" .  xxxx . " " . char
        call add(eggs, display)
    endfor
    return eggs
endfunction

" ======================================= }}}
let VimIM = " ====  Backend==GBK     ==== {{{"
" ===========================================
call add(s:vimims, VimIM)

" -------------
function! GBK()
" -------------
" This function outputs GBK as:
" ----------------------------- gb=6763
"   decimal  hex    GBK
"   49901    c2ed    馬
" ----------------------------- gbk=883+21003=21886
    if  s:encoding ==# "chinese"
        let start = str2nr('8140',16) "| 33088 丂
        for i in range(125)
            for j in range(start, start+190)
                if j <= 64928 && j != start+63
                    $put=printf('%d %x ',j,j).nr2char(j)
                endif
            endfor
            let start += 16*16
        endfor
    else
        $put='Your Vim encoding has to be set as chinese.'
        $put='[usage]    :call GBK()<CR>'
    endif
    return ''
endfunction

" ---------------------------------------
function! s:vimim_internal_code(keyboard)
" ---------------------------------------
    let keyboard = a:keyboard
    if s:chinese_input_mode =~ 'dynamic'
    \|| strlen(keyboard) != 5
        return []
    else
        let msg = " support <C-6> to trigger multibyte "
    endif
    let numbers = []
    " -------------------------
    if keyboard =~# '^u\x\{4}$'
    " -------------------------
        let msg = "do hex internal-code popup menu, eg, u808f"
        let pumheight = 16*16
        let xxxx = keyboard[1:]
        let ddddd = str2nr(xxxx, 16)
        if ddddd > 0xffff
            return []
        else
            let numbers = []
            for i in range(pumheight)
                let digit = str2nr(ddddd+i)
                call add(numbers, digit)
            endfor
        endif
    " ----------------------------
    elseif keyboard =~# '^\d\{5}$'
    " ----------------------------
        let last_char = keyboard[-1:-1]
        if last_char ==# '0'
            let msg = " do decimal internal-code popup menu: 22220"
            let dddd = keyboard[:-2]
            for i in range(10)
                let digit = str2nr(dddd.i)
                call add(numbers, digit)
            endfor
        else
            let msg = "do direct decimal internal-code insert: 22221"
            let ddddd = str2nr(keyboard, 10)
            let numbers = [ddddd]
        endif
    endif
    return s:vimim_internal_codes(numbers)
endfunction

" ---------------------------------------
function! s:vimim_internal_codes(numbers)
" ---------------------------------------
    if empty(a:numbers)
        return []
    endif
    let internal_codes = []
    for digit in a:numbers
        let hex = printf('%04x', digit)
        let menu = s:space . hex . s:space . digit
        let internal_code = menu.' '.nr2char(digit)
        call add(internal_codes, internal_code)
    endfor
    return internal_codes
endfunction

" -----------------------------------------
function! s:vimim_without_backend(keyboard)
" -----------------------------------------
    let keyboard = a:keyboard
    if  keyboard =~ '\l' && len(keyboard) == 1
        let msg = "make abcdefghijklmnopqrst alive"
    else
        return []
    endif
    let numbers = []
    let gbk = {}
    let a = char2nr('a')
    " ---------------------------------------
    let start = 19968
    if  s:encoding ==# "chinese"
        let start = 0xb0a1
        let az  = " b0a1 b0c5 b2c1 b4ee b6ea b7a2 b8c1 baa1 bbf7 "
        let az .= " bbf7 bfa6 c0ac c2e8 c4c3 c5b6 c5be c6da c8bb "
        let az .= " c8f6 cbfa cdda cdda cdda cef4 d1b9 d4d1"
        let gb_code_orders = split(az)
        for xxxx in s:az_list
            let gbk[nr2char(xxxx)] = "0x" . get(gb_code_orders, xxxx-a)
        endfor
    elseif  s:encoding ==# "taiwan"
        let start = 42048
    endif
    " ----------------------------------------------------------
    " [purpose] to input Chinese without datafile nor internet
    "  (1) every abcdefghijklmnopqrstuvwxy shows different menu
    "  (2) every char displays 16*16*3=768 glyph in omni menu
    "  (3) the total number of glyphs is 16*16*3*26=19968
    " ----------------------------------------------------------
    let label = char2nr(keyboard) - a
    let block = 16*16*3
    let start += label*block
    if  s:encoding ==# "chinese" && has_key(gbk, keyboard)
        let start = gbk[keyboard]
    endif
    let end = start + block
    for i in range(start, end)
        call add(numbers, str2nr(i,10))
    endfor
    " ------------------------------------
    return s:vimim_internal_codes(numbers)
    " ------------------------------------
endfunction

" ======================================= }}}
let VimIM = " ====  Backend==BIG5    ==== {{{"
" ===========================================
call add(s:vimims, VimIM)

" --------------
function! BIG5()
" --------------
" This function outputs BIG5 as:
" -----------------------------
"   decimal  hex    BIG5
"   45224    b0a8    馬
" ----------------------------- big5=408+5401+7652=13461
    if  s:encoding ==# "taiwan"
        let start = str2nr('A440',16) "| 42048  一
        for i in range(86)
            for j in range(start, start+(4*16)-2)
                $put=printf('%d %x ',j,j).nr2char(j)
            endfor
            let start2 = start + 6*16+1
            for j in range(start2, start2+93)
                $put=printf('%d %x ',j,j).nr2char(j)
            endfor
            let start += 16*16
        endfor
    else
        $put='Your Vim encoding has to be set as taiwan.'
        $put='[usage]    :call BIG5()<CR>'
    endif
    return ''
endfunction

" ======================================= }}}
let VimIM = " ====  Backend==FILE    ==== {{{"
" ===========================================
call add(s:vimims, VimIM)

" --------------------------------------
function! s:vimim_scan_plugin_datafile()
" --------------------------------------
    if empty(s:path2)
    \|| empty(s:datafile)
    \|| empty(s:sqlite)
        let msg = " no datafile nor directory specifiled in vimrc "
    else
        return
    endif
    " -----------------------------------
    let sqlite = "cedict.db"
    let datafile = s:path . sqlite
    if filereadable(datafile)
        let s:path2 = 0
        let s:sqlite = datafile
        let s:vimim_embedded_backend = "sqlite"
        return
    endif
    " -----------------------------------
    let input_methods = []
    call add(input_methods, "pinyin")
    call add(input_methods, "pinyin_quote_sogou")
    call add(input_methods, "pinyin_huge")
    call add(input_methods, "pinyin_fcitx")
    call add(input_methods, "pinyin_canton")
    call add(input_methods, "pinyin_hongkong")
    call add(input_methods, "4corner")
    call add(input_methods, "12345")
    call add(input_methods, "wubi")
    call add(input_methods, "wubi98")
    call add(input_methods, "wubi2000")
    call add(input_methods, "wubijd")
    call add(input_methods, 'cangjie')
    call add(input_methods, 'zhengma')
    call add(input_methods, 'quick')
    call add(input_methods, 'xinhua')
    call add(input_methods, 'erbi')
    call add(input_methods, 'boshiamy')
    call add(input_methods, 'phonetic')
    call add(input_methods, 'array30')
    call add(input_methods, "wu")
    call add(input_methods, "yong")
    call add(input_methods, "nature")
    call add(input_methods, "hangul")
    call add(input_methods, "cns11643")
    call add(input_methods, "ctc")
    call add(input_methods, "english")
    " ------------------------------------
    for im in input_methods
        let file = "vimim." . im . ".txt"
        let datafile = s:path . file
        if filereadable(datafile)
            break
        else
            continue
        endif
    endfor
    " ----------------------------------------
    if filereadable(datafile)
        let msg = "datafile is used first over directory database"
        let s:path2 = 0
        let s:vimim_embedded_backend = "datafile"
    else
        return
    endif
    " ----------------------------------------
    let msg = " [setter] for im-loaded-flag "
    if im =~# '^wubi'
        let im = 'wubi'
    elseif im =~# '^pinyin'
        let im = 'pinyin'
    elseif im =~# '^\d'
        let im = '4corner'
    endif
    let s:im[im][0] = 1
    " ----------------------------------------
    let s:datafile = datafile
    let s:input_method = im
endfunction

" ------------------------------------------------
function! s:vimim_wildcard_search(keyboard, lines)
" ------------------------------------------------
    if s:chinese_input_mode =~ 'dynamic'
    \|| empty(a:lines)
        return []
    endif
    let results = []
    let wildcard_pattern = "[*]"
    let wildcard = match(a:keyboard, wildcard_pattern)
    if wildcard > 0
        let star = substitute(a:keyboard,'[*]','.*','g')
        let wildcard = '^' . star . '\>'
        let results = filter(a:lines, 'v:val =~ wildcard')
    endif
    return results
endfunction

" ---------------------------------------------------
function! s:vimim_fixed_match(lines, keyboard, fixed)
" ---------------------------------------------------
    if empty(a:lines) || empty(a:keyboard)
        return []
    endif
    let pattern = '^' . a:keyboard
    let matched = match(a:lines, pattern)
    let match_end = matched + a:fixed
    let results = []
    if  matched >= 0
        let results = a:lines[matched : match_end]
    endif
    return results
endfunction

" ----------------------------------------------------
function! s:vimim_pinyin(lines, keyboard, match_start)
" ----------------------------------------------------
    let match_start = a:match_start
    if empty(a:lines) || match_start < 0
        return []
    endif
    let keyboard = a:keyboard
    " ----------------------------------------
    let pattern = '\M^\(' . keyboard
    if len(keyboard) < 2
        let pattern .= '\>'
    else
        let pinyin_tone = '\d\='
        let pattern .= pinyin_tone . '\>'
    endif
    let pattern .=  '\)\@!'
    " ----------------------------------------
    let matched = match(a:lines, pattern, match_start)-1
    let match_end = match_start
    if matched > 0 && matched > match_start
        let match_end = matched
    endif
    " ----------------------------------------
    " always do popup as one-to-many translation
    let menu_maximum = 20
    let range = match_end - match_start
    if range > menu_maximum || range < 1
        let match_end = match_start + menu_maximum
    endif
    " --------------------------------------------
    let results = a:lines[match_start : match_end]
    " --------------------------------------------
    if len(results) < 10 && get(s:im['pinyin'],0) > 0
       let extras = s:vimim_pinyin_more_match(a:lines, keyboard, results)
       if len(extras) > 0
           call extend(results, extras)
       endif
    endif
    return results
endfunction

" -----------------------------------------------------------
function! s:vimim_pinyin_more_match(lines, keyboard, results)
" -----------------------------------------------------------
    let filter = "vim\\|#\\|　"
    if match(a:results, filter) > -1
        return []
    endif
    " -----------------------------------------
    " [purpose] make standard popup menu layout
    " in  => chao'ji'jian'pin
    " out => chaojijian, chaoji, chao
    " -----------------------------------------
    let keyboards = s:vimim_get_pinyin_from_pinyin(a:keyboard)
    if empty(keyboards)
        return []
    endif
    let candidates = []
    for i in reverse(range(len(keyboards)-1))
        let candidate = join(keyboards[0 : i], "")
        call add(candidates, candidate)
    endfor
    let matched_list = []
    for keyboard in candidates
        let results = s:vimim_fixed_match(a:lines, keyboard, 1)
        call extend(matched_list, results)
    endfor
    return matched_list
endfunction

" ------------------------------------------------------
function! s:vimim_sentence_datafile(lines, keyboard, im)
" ------------------------------------------------------
    if empty(a:lines)
        return []
    endif
    let keyboard = a:keyboard
    let blocks = s:vimim_static_break_every_four(keyboard, a:im)
    if empty(blocks)
        let msg = "continue when no fancy 4-char-block"
    else
        return blocks
    endif
    let match_start = -1
    let head = s:vimim_get_matched_sentence_head(keyboard)
    let max = s:vimim_get_hjkl_h_pinyin(head) + 1
    " word matching algorithm for Chinese segmentation
    " ------------------------------------------------
    while max > 1
        let max -= 1
        let head = strpart(keyboard, 0, max)
        let pattern = '^' . head . '\>'
        let match_start = match(a:lines, pattern)
        if  match_start < 0
            let msg = "continue until match is found"
        else
            break
        endif
    endwhile
    " ------------------------------------------------
    if match_start > 0
        let blocks = s:vimim_break_string_at(a:keyboard, max)
    endif
    return blocks
endfunction

" -------------------------------
function! s:vimim_load_datafile()
" -------------------------------
    if len(s:path2) > 1
        return
    endif
    if empty(s:lines)
    \&& !empty(s:datafile)
    \&& filereadable(s:datafile)
        let s:lines = readfile(s:datafile)
    endif
endfunction

" ======================================= }}}
let VimIM = " ====  Backend==DIR     ==== {{{"
" ===========================================
call add(s:vimims, VimIM)

" --------------------------------------------
function! s:vimim_scan_plugin_data_directory()
" --------------------------------------------
    if empty(s:path2)
    \|| s:vimim_embedded_backend =~ "datafile"
    \|| s:vimim_embedded_backend =~ "sqlite"
        return
    endif
    " ----------------------------------------
    let input_methods = []
    call add(input_methods, "wubi")
    call add(input_methods, "unihan")
    call add(input_methods, "4corner")
    call add(input_methods, "pinyin")
    " ----------------------------------------
    let directoires = []
    for im in input_methods
        let dir = s:vimim_get_data_directory(im)
        if empty(dir)
            continue
        else
            call add(directoires, im)
        endif
    endfor
    " ----------------------------------------
    if empty(directoires)
        return
    else
        let s:vimim_embedded_backend = "directory"
    endif
    " ------------------------------------
    for directory in directoires
        let dir = s:vimim_get_data_directory(directory)
        if empty(dir)
            continue
        elseif directory =~# '^pinyin'
            let s:data_directory_pinyin = dir
            let s:input_method = 'pinyin'
            let s:im['pinyin'][0] = 1
        elseif directory =~# '^\d'
            let s:data_directory_4corner = dir
        elseif directory =~# '^wubi'
            let s:data_directory_wubi = dir
        endif
    endfor
    " ------------------------------------
    if len(s:data_directory_4corner) > 1
        if len(s:data_directory_pinyin) > 1
            let s:pinyin_and_4corner = 1
            let s:im['4corner'][0] = 1
        else
            let s:only_4corner_or_12345 = 1
        endif
    endif
    " ------------------------------------
endfunction

" ---------------------------------------
function! s:vimim_get_datafile_in_vimrc()
" ---------------------------------------
    let datafile = s:vimim_sqlite_cedict
    if !empty(datafile) && filereadable(datafile)
        let s:sqlite = copy(datafile)
        let s:vimim_embedded_backend = "sqlite"
        return
    endif
    " -----------------------------------
    let dir = s:vimim_data_directory
    if !empty(dir) && isdirectory(dir)
        let s:path2 = copy(dir)
        return
    endif
    " -----------------------------------
    let datafile = s:vimim_datafile
    if !empty(datafile) && filereadable(datafile)
        let s:datafile = copy(datafile)
        let s:vimim_embedded_backend = "datafile"
    endif
endfunction

" --------------------------------------
function! s:vimim_get_data_directory(im)
" --------------------------------------
    let im = a:im
    if empty(im) || empty(s:path2)
        return 0
    endif
    let dir = s:path2 ."/". im
    if isdirectory(dir)
        return dir
    else
        return 0
    endif
endfunction

" --------------------------------------
function! s:vimim_set_data_directory(im)
" --------------------------------------
    let im = a:im
    let dir = s:vimim_get_data_directory(im)
    if empty(dir)
        return 0
    else
        let s:im[im][0] = 1
        let s:input_method = im
        return dir
    endif
endfunction

" -----------------------------------------------------
function! s:vimim_get_data_from_directory(keyboard, im)
" -----------------------------------------------------
    let dir = s:vimim_get_data_directory(a:im)
    if empty(dir)
        return []
    endif
    let results = []
    let filename = dir . '/' . a:keyboard
    if filereadable(filename)
        let lines = readfile(filename)
        for line in lines
            for chinese in split(line)
                if s:localization > 0
                    let chinese = s:vimim_i18n_read(chinese)
                endif
                let menu = a:keyboard . " " . chinese
                call add(results, menu)
            endfor
        endfor
    endif
    return results
endfunction

" ----------------------------------------------
function! s:vimim_break_string_at(keyboard, max)
" ----------------------------------------------
    let keyboard = a:keyboard
    let max = a:max
    if empty(keyboard) || empty(max)
        return []
    endif
    let matched_part = strpart(keyboard, 0, max)
    let trailing_part = strpart(keyboard, max)
    let blocks = [matched_part, trailing_part]
    return blocks
endfunction

" -----------------------------------------------------
function! s:vimim_static_break_every_four(keyboard, im)
" -----------------------------------------------------
    let keyboard = a:keyboard
    if len(keyboard) < 4
        return []
    endif
    let blocks = []
    " ----------------------------------------
    if a:im =~ '4corner'
        if keyboard =~ '\d\d\d\d'
            let blocks = s:vimim_break_every_four(keyboard)
        elseif keyboard =~ '\d\+$'
            let blocks = [keyboard]
        endif
    endif
    " ----------------------------------------
    if a:im =~ 'wubi'
        let blocks = s:vimim_break_every_four(keyboard)
    endif
    " ----------------------------------------
    return blocks
endfunction

" ------------------------------------------------
function! s:vimim_sentence_directory(keyboard, im)
" ------------------------------------------------
    let keyboard = a:keyboard
    let im = a:im
    let dir = s:vimim_get_data_directory(im)
    let filename = dir . '/' . keyboard
    let head = keyboard
    if filereadable(filename)
        if s:pumvisible_hjkl_h > 0
            let s:keyboard_head = keyboard
        else
            return [keyboard]
        endif
    endif
    " ----------------------------------------
    let blocks = s:vimim_static_break_every_four(keyboard, im)
    if empty(blocks)
        let msg = "continue when no fancy 4-char-block"
    else
        return blocks
    endif
    " -------------------------------------------
    let pinyin_4corner = '\d\+\l\='
    let digit = match(keyboard, pinyin_4corner)
    if digit > 0
        return [keyboard]
    endif
    " -------------------------------------------
    let head = s:vimim_get_matched_sentence_head(head)
    let max = s:vimim_get_hjkl_h_pinyin(head)
    while max > 1
        let max -= 1
        let head = strpart(keyboard, 0, max)
        let filename = dir . '/' . head
        if filereadable(filename)
            break
        else
            continue
        endif
    endwhile
    " -------------------------------------------
    if max > 0 && filereadable(filename)
        let blocks = s:vimim_break_string_at(keyboard, max)
    endif
    return blocks
endfunction

" -------------------------------------------
function! s:vimim_get_hjkl_h_pinyin(keyboard)
" -------------------------------------------
    let keyboard = a:keyboard
    let max = len(keyboard)
    if get(s:im['pinyin'],0) < 1
        return max
    endif
    " -------------------------
    let msg = " yeyeqifangcao "
    " -------------------------
    let pinyins = s:vimim_get_pinyin_from_pinyin(keyboard)
    if len(pinyins) > 1
        let last = pinyins[-1:-1]
        let max = len(keyboard)-len(last)-1
    endif
    return max
endfunction

" ---------------------------------------------------
function! s:vimim_get_matched_sentence_head(keyboard)
" ---------------------------------------------------
    let keyboard = a:keyboard
    let head = s:keyboard_head
    if empty(head)
        let msg = 'h was not typed on omni popup menu'
    else
        if s:pumvisible_hjkl_h > 0
            let s:pumvisible_hjkl_h = 0
            let length = len(head)-1
            let keyboard = strpart(head, 0, length)
        endif
    endif
    return keyboard
endfunction

" ---------------------------------------------
function! s:vimim_pinyin_with_4corner(keyboard)
" ---------------------------------------------
    let keyboard = a:keyboard
    if empty(s:pinyin_and_4corner)
        return []
    endif
    " --------------------------------------------------------
    let blocks = []
    let pinyin_4corner = '\d\+\l\='
    let digit = match(keyboard, pinyin_4corner)
    if digit > 0
        let blocks = s:vimim_break_string_at(keyboard, digit)
    else
        return []
    endif
    " --------------------------------------------------------
    let pinyin = get(blocks,0)  |" ma im=pinyin
    let number = get(blocks,1)  |" 77 im=4corner
    " --------------------------------------------------------
    let cache_list = s:vimim_get_data_from_directory(pinyin, 'pinyin')
    let pinyin_cache = s:vimim_chinese_menu_hash(cache_list)
    " --------------------------------------------------------
    let cache_list = s:vimim_get_data_from_directory(number, '4corner')
    let digit_cache = s:vimim_chinese_menu_hash(cache_list)
    " --------------------------------------------------------
    " free style pinyin+4corner: ma7  mali4  mxj3
    return s:vimim_double_filter(pinyin_cache, digit_cache, -1)
endfunction

" ------------------------
function! g:vimim_mkdir1()
" ------------------------
" within one line, new item is appeneded
" (1) existed order:  key  value_1 value_2
" (2) new items:      key  value_2 value_3
" (3) new order:      key  value_1 value_2 value_3
    call s:vimim_mkdir('append')
endfunction

" ------------------------
function! g:vimim_mkdir2()
" ------------------------
" within one line, new item is inserted first
" (1) existed order:  key  value_1 value_2
" (2) new items:      key  value_2 value_3
" (3) new order:      key  value_2 value_3 value_1
    call s:vimim_mkdir('prepend')
endfunction

" ------------------------
function! g:vimim_mkdir3()
" ------------------------
" replace the existed content with new items
" (1) existed order:  key  value_1 value_2
" (2) new items:      key  value_2 value_3
" (3) new order:      key  value_2 value_3
    call s:vimim_mkdir('replace')
endfunction

" -----------------------------
function! s:vimim_mkdir(option)
" -----------------------------
" Goal: creating directory xxx and adding files, based on vimim.xxx.txt
" Sample file A: $VIM/vimfiles/plugin/vimim/4corner/7132
" Sample file B: $VIM/vimfiles/plugin/vimim/pinyin/jjjj
" Sample file C: $VIM/vimfiles/plugin/vimim/unihan/u808f
" ----------------------------- vim
" Example: one   input: vimim.pinyin.txt  (the master file)
"          many output: pinyin/ma3        (one sample slave file)
" (1) $cd $VIM/vimfiles/plugin/vimim/
" (2) $vi vimim.pinyin.txt
"         :call g:vimim_mkdir1()
" ----------------------------- bash
" vimimmkdir1() { vi -E -n "+call g:vimim_mkdir1()" +x vimim.$1.txt; }
" vimimmkdir2() { vi -E -n "+call g:vimim_mkdir2()" +x vimim.$1.txt; }
" vimimmkdir3() { vi -E -n "+call g:vimim_mkdir3()" +x vimim.$1.txt; }
" -----------------------------
    let root = expand("%:p:h")
    let dir = root . "/" . expand("%:e:e:r")
    if !exists(dir) && !isdirectory(dir)
        call mkdir(dir, "p")
    endif
    let lines = readfile(bufname("%"))
    let option = a:option
    for line in lines
        let entries = split(line)
        let key = get(entries, 0)
        if match(key, "'") > -1
            let key = substitute(key,"'",'','g')
        endif
        let key_as_filename = dir . "/" . key
        let chinese_list = entries[1:]
        " ----------------------------------------
        " u99ac 7132
        " u99ac ma3
        " u99ac 馬 horse; surname; KangXi radical 187
        " ----------------------------------------
        let first_list = []
        let second_list = []
        if filereadable(key_as_filename)
            let contents = split(join(readfile(key_as_filename)))
            if option =~ 'append'
                let first_list = contents
                let second_list = chinese_list
            elseif option =~ 'prepend'
                let first_list = chinese_list
                let second_list = contents
            elseif option =~ 'replace'
                let first_list = chinese_list
                let option = 'append'
            endif
            call extend(first_list, second_list)
            let chinese_list = copy(first_list)
        endif
        let results = s:vimim_remove_duplication(chinese_list)
        if !empty(results)
            call writefile(results, key_as_filename)
        endif
    endfor
endfunction

" -------------------------------------------
function! s:vimim_remove_duplication(chinese)
" -------------------------------------------
    let chinese = a:chinese
    if empty(chinese)
        return []
    endif
    let cache = {}
    let results = []
    for line in chinese
        let characters = split(line)
        for char in characters
            " allow :: ## added to the source datafile
            let char = substitute(char,':\+\|#\+','','g')
            if has_key(cache, char) || empty(char)
                continue
            else
                let cache[char] = char
                call add(results, char)
            endif
        endfor
    endfor
    return results
endfunction

" ======================================= }}}
let VimIM = " ====  Backend==SQLite  ==== {{{"
" ===========================================
call add(s:vimims, VimIM)

" -----------------------------------
function! s:vimim_initialize_sqlite()
" -----------------------------------
    if empty(s:sqlite)
        return
    else
        let msg = " starting to flirt with SQLite "
    endif
    let sqlite_executable = "sqlite3"
    if executable(sqlite_executable)
        let s:sqlite_executable = sqlite_executable
        let s:input_method = 'pinyin'
    endif
endfunction

" -----------------------------------------------
function! s:vimim_sentence_match_sqlite(keyboard)
" -----------------------------------------------
    let keyboard = a:keyboard
    let results = []
    let sql = s:vimim_get_cedict_sqlite_query(keyboard)
    let results = s:vimim_get_data_from_cedict_sqlite(keyboard, sql)
    if empty(results)
        let msg = 'nothing found from sqlite, but why not try more'
    else
        return results
    endif
    let key = keyboard
    let max = len(keyboard)
    " ----------------------------------------
    while max > 1
        let max -= 1
        let key = strpart(keyboard, 0, max)
        let sql = s:vimim_get_cedict_sqlite_query(key)
        let results = s:vimim_get_data_from_cedict_sqlite(key, sql)
        if empty(results)
            continue
        else
            break
        endif
    endwhile
    " ----------------------------------------
    return results
endfunction

" -------------------------------------------------
function! s:vimim_get_cedict_sqlite_query(keyboard)
" -------------------------------------------------
    let keyboard = a:keyboard
    if empty(keyboard)
        return 0
    endif
    " -------------------------------------------------
    " sqlite3 /usr/local/share/cjklib/cedict.db "select random()"
    " sqlite> select * from cedict where Translation like '%dream%';
    " sqlite> select * from cedict where Reading like 'ma_ ma_';
    " -------------------------------------------------
    let table = 'CEDICT'
    let column1 = 'HeadwordTraditional'
    let column2 = 'HeadwordSimplified'
    let column3 = 'Reading'
    let column4 = 'Translation'
    " ------------------
    let select = column2
    let column = column3
    " ------------------
    let magic_head = keyboard[:0]
    if  magic_head ==# "u"
        let msg = ' u switch to English mode: udream => dream '
        let keyboard = strpart(keyboard, 1)
        let keyboard = "'%" . keyboard . "%'"
        let column = column4
    else
        let msg = ' pinyin is the default: meng'
        let pinyins = s:vimim_get_pinyin_from_pinyin(keyboard)
        if len(pinyins) > 1
            let pinyins = map(pinyins, 'v:val."_"')
            let keyboard = join(pinyins)
        else
            let keyboard = keyboard."_"
        endif
        let keyboard = "'" . keyboard . "'"
    endif
    " ----------------------------------------
    let query  = " SELECT " . select
    let query .= " FROM   " . table
    let query .= " WHERE  " . column . ' like ' . keyboard
    " ----------------------------------------
    let sqlite  = s:sqlite_executable . ' '
    let sqlite .= s:sqlite . ' '
    let sqlite .= ' " '
    let sqlite .= query
    let sqlite .= ' " '
    " ----------------------------------------
    return sqlite
endfunction

" -------------------------------------------------------------
function! s:vimim_get_data_from_cedict_sqlite(keyboard, sqlite)
" -------------------------------------------------------------
    let sql_return = system(a:sqlite)
    if empty(sql_return)
        return []
    endif
    let results = []
    for chinese in split(sql_return,'\n')
        let menu = a:keyboard . " " . chinese
        call add(results, menu)
    endfor
    return results
endfunction

" ======================================= }}}
let VimIM = " ====  Backend=>Cloud   ==== {{{"
" ===========================================
call add(s:vimims, VimIM)

" ----------------------------------
function! s:vimim_initialize_cloud()
" ----------------------------------
    " s:vimim_cloud_sogou=0  : default, auto open when no datafile
    " s:vimim_cloud_sogou=-1 : cloud is open when cloud at will
    " s:vimim_cloud_sogou=-2 : cloud is shut down without condition
    " ------------------------------
    if s:vimim_cloud_sogou < -1
        return
    endif
    " step 1: try to find libvimim
    " ----------------------------
    let cloud = s:path . "libvimim.so"
    if has("win32") || has("win32unix")
        let cloud = s:vimim_wget_dll
        if empty(cloud)
            let cloud = s:path . "libvimim.dll"
        endif
    endif
    if filereadable(cloud)
        " in win32, strip the .dll suffix
        if has("win32") && cloud[-4:] ==? ".dll"
            let cloud = cloud[:-5]
        endif
        let ret = libcall(cloud, "do_geturl", "__isvalid")
        if ret ==# "True"
            let s:www_executable = cloud
            let s:www_libcall = 1
            call s:vimim_do_cloud_if_no_backend()
            return
        endif
    endif
    " step 2: try to find wget
    " ------------------------
    if empty(s:www_executable)
        let wget = 0
        if executable(s:path .  "wget.exe")
            let wget = s:path . "wget.exe"
        elseif executable('wget')
            let wget = "wget"
        endif
        if empty(wget)
            let msg = "wget is not available"
        else
            let wget_option = " -qO - --timeout 20 -t 10 "
            let s:www_executable = wget . wget_option
        endif
    endif
    " step 3: try to find curl if no wget
    " -----------------------------------
    if empty(s:www_executable)
        if executable('curl')
            let s:www_executable = "curl -s "
        endif
    endif
    if empty(s:www_executable)
        let s:vimim_cloud_sogou = 0
    else
        call s:vimim_do_cloud_if_no_backend()
    endif
endfunction

" ----------------------------------------
function! s:vimim_do_cloud_if_no_backend()
" ----------------------------------------
    if empty(s:vimim_embedded_backend)
        if empty(s:vimim_cloud_sogou)
            let s:vimim_cloud_sogou = 1
        endif
    endif
endfunction

" ------------------------------------
function! s:vimim_magic_tail(keyboard)
" ------------------------------------
    let keyboard = a:keyboard
    if s:chinese_input_mode =~ 'dynamic'
    \|| s:has_dot_in_datafile > 0
    \|| keyboard =~ '\d\d\d\d'
        return []
    endif
    let magic_tail = keyboard[-1:]
    let last_but_one =  keyboard[-2:-2]
    if magic_tail =~ "[.']" && last_but_one =~ "[0-9a-z]"
        let msg = " play with magic trailing char "
    else
        return []
    endif
    let keyboards = []
    " ----------------------------------------------------
    " <dot> double play in OneKey:
    "   (1) magic trailing dot => forced-non-cloud
    "   (2) as word partition  => match dot by dot
    " ----------------------------------------------------
    if  magic_tail ==# "."
        let msg = " trailing dot => forced-non-cloud"
        let s:no_internet_connection = 2
        call add(keyboards, -1)
    elseif  magic_tail ==# "'"
        let msg = " trailing apostrophe => forced-cloud "
        let s:no_internet_connection = -1
        call add(keyboards, 1)
    endif
    " ----------------------------------------------------
    " <apostrophe> double play in OneKey:
    "   (1) magic trailing apostrophe => cloud at will
    "   (2) magic leading  apostrophe => universal imode
    " ----------------------------------------------------
    let keyboard = keyboard[:-2]
    call insert(keyboards, keyboard)
    return keyboards
endfunction

" -------------------------------------------------
function! s:vimim_to_cloud_or_not(keyboard, clouds)
" -------------------------------------------------
    let do_cloud = get(a:clouds, 1)
    if do_cloud > 0
        return 1
    endif
    if s:no_internet_connection > 1
        let msg = "oops, there is no internet connection."
        return 0
    elseif s:no_internet_connection < 0
        return 1
    endif
    if s:vimim_cloud_sogou < 1
        return 0
    endif
    let keyboard = a:keyboard
    if empty(s:chinese_input_mode) && keyboard =~ '[.]'
        return 0
    endif
    if keyboard =~# "[^a-z']"
        let msg = "cloud limits to valid cloud keycodes only"
        return 0
    endif
    let msg = "auto cloud if number of zi > threshold"
    let pinyins = s:vimim_get_pinyin_from_pinyin(keyboard)
    let cloud_length = len(pinyins)
    if cloud_length < s:vimim_cloud_sogou
        return 0
    endif
    return 1
endfunction

" -------------------------------------
function! s:vimim_get_cloud_sogou_key()
" -------------------------------------
    if empty(s:www_executable)
        return 0
    endif
    let cloud = 'http://web.pinyin.sogou.com/web_ime/patch.php'
    let output = 0
    " --------------------------------------------------------------
    " http://web.pinyin.sogou.com/web_ime/get_ajax/woyouyigemeng.key
    " --------------------------------------------------------------
    try
        if s:www_libcall
            let input = cloud
            let output = libcall(s:www_executable, "do_geturl", input)
        else
            let input = cloud
            let output = system(s:www_executable . input)
        endif
    catch
        let msg = "it looks like sogou has trouble with its cloud?"
        if s:vimimdebug > 0
            call s:debugs('sogou::exception=', v:exception)
        endif
        let output = 0
    endtry
    if empty(output)
        return 0
    endif
    return get(split(output, '"'), 1)
endfunction

" ------------------------------------------------
function! s:vimim_get_cloud_sogou(keyboard, force)
" ------------------------------------------------
    let keyboard = a:keyboard
    if empty(s:www_executable) || empty(keyboard)
        return []
    endif
    if s:vimim_cloud_sogou < 1 && a:force < 1
        return []
    endif
    " only use sogou when we get a valid key
    if empty(s:vimim_sogou_key)
        let s:vimim_sogou_key = s:vimim_get_cloud_sogou_key()
    endif
    let cloud = 'http://web.pinyin.sogou.com/api/py?key='
    let cloud = cloud . s:vimim_sogou_key .'&query='
    " support apostrophe as delimiter to remove ambiguity
    " (1) examples: piao => pi'ao (cloth)  xian => xi'an (city)
    " (2) add double quotes between keyboard
    " (3) test: xi'anmeimeidepi'aosuifengpiaoyang
    let output = 0
    " --------------------------------------------------------------
    " http://web.pinyin.sogou.com/web_ime/get_ajax/woyouyigemeng.key
    " --------------------------------------------------------------
    try
        if s:www_libcall
            let input = cloud . keyboard
            let output = libcall(s:www_executable, "do_geturl", input)
        else
            let input = '"' . cloud . keyboard . '"'
            let output = system(s:www_executable . input)
        endif
    catch
        let msg = "it looks like sogou has trouble with its cloud?"
        if s:vimimdebug > 0
            call s:debugs('sogou::exception=', v:exception)
        endif
        let output = 0
    endtry
    call s:debugs('sogou::outputquery=', output)
    if empty(output)
        return []
    endif
    " --------------------------------------------------------
    let first = match(output, '"', 0)
    let second = match(output, '"', 0, 2)
    if first > 0 && second > 0
        let output = strpart(output, first+1, second-first-1)
        let output = s:vimim_url_xx_to_chinese(output)
    endif
    if empty(output)
        return []
    endif
    " now, let's support Cloud for gb and big5
    " ----------------------------------------
    if empty(s:localization)
        let msg = "both vim and datafile are UTF-8 encoding"
    else
        let output = s:vimim_i18n_read(output)
    endif
    " output => '我有一個夢：13    +
    let menu = []
    for item in split(output, '\t+')
        let item_list = split(item, '：')
        if len(item_list) > 1
            let chinese = get(item_list,0)
            let english = strpart(keyboard, 0, get(item_list,1))
            let new_item = english . " " . chinese
            call add(menu, new_item)
        endif
    endfor
    " output => ['woyouyigemeng 我有一個夢']
    return menu
endfunction

" ======================================= }}}
let VimIM = " ====  Backend=>myCloud ==== {{{"
" ===========================================
call add(s:vimims, VimIM)

" ------------------------------------------
function! s:vimim_access_mycloud(cloud, cmd)
" ------------------------------------------
"  use the same function to access mycloud by libcall() or system()
    if s:vimimdebug > 0
        call s:debugs("cloud", a:cloud)
        call s:debugs("cmd", a:cmd)
    endif
    if s:cloud_plugin_mode == "libcall"
        let arg = s:cloud_plugin_arg
        if empty(arg)
            return libcall(a:cloud, s:cloud_plugin_func, a:cmd)
        else
            return libcall(a:cloud, s:cloud_plugin_func, arg." ".a:cmd)
        endif
    elseif s:cloud_plugin_mode == "system"
        return system(a:cloud." ".shellescape(a:cmd))
    elseif s:cloud_plugin_mode == "www"
        let input = s:vimim_rot13(a:cmd)
        if s:www_libcall
            let ret = libcall(s:www_executable, "do_geturl", a:cloud.input)
        else
            let ret = system(s:www_executable . shellescape(a:cloud.input))
        endif
        let output = s:vimim_rot13(ret)
        let ret = s:vimim_url_xx_to_chinese(output)
        return ret
    endif
    return ""
endfunction

" --------------------------------------
function! s:vimim_check_mycloud_plugin()
" --------------------------------------
    if empty(s:vimim_mycloud_url)
        " we do plug-n-play for libcall(), not for system()
        if has("win32") || has("win32unix")
            let cloud = s:path . "libvimim.dll"
        elseif has("unix")
            let cloud = s:path . "libvimim.so"
        else
            return 0
        endif
        let s:cloud_plugin_mode = "libcall"
        let s:cloud_plugin_arg = ""
        let s:cloud_plugin_func = 'do_getlocal'
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
                if s:vimimdebug > 0
                    call s:debugs('libcall_mycloud2::error=',v:exception)
                endif
            endtry
        endif
        " libcall check failed, we now check system()
        " -------------------------------------------
        if has("gui_win32")
            return 0
        endif
        let mes = "on linux, we do plug-n-play"
        " -------------------------------------
        let cloud = s:path . "mycloud/mycloud"
        if !executable(cloud)
            if !executable("python")
                return 0
            endif
            let cloud = "python " . cloud
        endif
        " in POSIX system, we can use system() for mycloud
        let s:cloud_plugin_mode = "system"
        let ret = s:vimim_access_mycloud(cloud, "__isvalid")
        if split(ret, "\t")[0] == "True"
            return cloud
        endif
    else
        " we do set-and-play on all systems
        " ---------------------------------
        let part = split(s:vimim_mycloud_url, ':')
        let lenpart = len(part)
        if lenpart <= 1
            call s:debugs("invalid_cloud_plugin_url","")
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
                    let s:cloud_plugin_mode = "system"
                    let ret = s:vimim_access_mycloud(cloud, "__isvalid")
                    if split(ret, "\t")[0] == "True"
                        return cloud
                    endif
                endif
            endif
        elseif part[0] ==# "dll"
            if len(part[1]) == 1
                let base = 1
            else
                let base = 0
            endif
            " provide function name
            if lenpart >= base+4
                let s:cloud_plugin_func = part[base+3]
            else
                let s:cloud_plugin_func = 'do_getlocal'
            endif
            " provide argument
            if lenpart >= base+3
                let s:cloud_plugin_arg = part[base+2]
            else
                let s:cloud_plugin_arg = ''
            endif
            " provide the dll
            if base == 1
                let cloud = part[1] . ':' . part[2]
            else
                let cloud = part[1]
            endif
            if filereadable(cloud)
                let s:cloud_plugin_mode = "libcall"
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
                    if s:vimimdebug > 0
                        let key = 'libcall_mycloud1::error='
                        call s:debugs(key, v:exception)
                    endif
                endtry
            endif
        elseif part[0] ==# "http" || part[0] ==# "https"
            let cloud = s:vimim_mycloud_url
            if !empty(s:www_executable)
                let s:cloud_plugin_mode = "www"
                let ret = s:vimim_access_mycloud(cloud, "__isvalid")
                if split(ret, "\t")[0] == "True"
                    return cloud
                endif
            endif
        else
            call s:debugs("invalid_cloud_plugin_url","")
        endif
    endif
    return 0
endfunction

" -------------------------------------------
function! s:vimim_initialize_mycloud_plugin()
" -------------------------------------------
    if !empty(s:vimim_embedded_backend)
        return
    endif
" -------------------
" mycloud sample url:
" --------------------------------------------------------------
" :let g:vimim_mycloud_url = "http://pim-cloud.appspot.com/qp/"
" :let g:vimim_mycloud_url = "http://pim-cloud.appspot.com/ms/"
" :let g:vimim_mycloud_url = "http://pim-cloud.appspot.com/abc/"
" :let g:vimim_mycloud_url = "dll:/data/libvimim.so:192.168.0.1"
" :let g:vimim_mycloud_url = "dll:/home/im/plugin/libmyplugin.so:arg:func"
" :let g:vimim_mycloud_url = "dll:".$HOME."/plugin/libvimim.so"
" :let g:vimim_mycloud_url = "dll:".$HOME."/plugin/cygvimim.dll"
" :let g:vimim_mycloud_url = "app:".$VIM."/src/mycloud/mycloud"
" :let g:vimim_mycloud_url = "app:python d:/mycloud/mycloud.py"
" --------------------------------------------------------------
    let cloud = s:vimim_check_mycloud_plugin()
    " this variable should not be used after initialization
    unlet s:vimim_mycloud_url
    if empty(cloud)
        let s:vimim_cloud_plugin = 0
        return
    endif
    let ret = s:vimim_access_mycloud(cloud, "__getname")
    let loaded = split(ret, "\t")[0]
    let ret = s:vimim_access_mycloud(cloud, "__getkeychars")
    let keycode = split(ret, "\t")[0]
    if empty(keycode)
        let s:vimim_cloud_plugin = 0
    else
        let s:vimim_cloud_plugin = cloud
        let s:vimim_cloud_sogou = -777
        let s:shuangpin_flag = 0
        let s:im['mycloud'][0] = loaded
        let s:im['mycloud'][2] = keycode
        let s:input_method = 'mycloud'
    endif
endfunction

" --------------------------------------------
function! s:vimim_get_mycloud_plugin(keyboard)
" --------------------------------------------
    if empty(s:vimim_cloud_plugin)
        return []
    endif
    let cloud = s:vimim_cloud_plugin
    let input = a:keyboard
    let output = 0
    " ---------------------------------------
    try
        let output = s:vimim_access_mycloud(cloud, input)
    catch
        let output = 0
        if s:vimimdebug > 0
            call s:debugs('mycloud::error=',v:exception)
        endif
    endtry
    if empty(output)
        return []
    endif
    return s:vimim_process_mycloud_output(a:keyboard, output)
endfunction

" --------------------------------------------------------
function! s:vimim_process_mycloud_output(keyboard, output)
" --------------------------------------------------------
    let output = a:output
    if empty(output) || empty(a:keyboard)
        return []
    endif
    " ----------------------
    " 春夢      8       4420
    " ----------------------
    let menu = []
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
        call add(menu, new_item)
    endfor
    return menu
endfunction

" -------------------------------------
function! s:vimim_url_xx_to_chinese(xx)
" -------------------------------------
    if s:www_libcall
        let output = libcall(s:www_executable, "do_unquote", a:xx)
    else
        let input = a:xx
        let output = substitute(input, '%\(\x\x\)',
                    \ '\=eval(''"\x''.submatch(1).''"'')','g')
    endif
    return output
endfunction

" -------------------------------
function! s:vimim_rot13(keyboard)
" -------------------------------
    let rot13 = a:keyboard
    let a = "12345abcdefghijklmABCDEFGHIJKLM"
    let z = "98760nopqrstuvwxyzNOPQRSTUVWXYZ"
    let rot13 = tr(rot13, a.z, z.a)
    return rot13
endfunction

" ======================================= }}}
let VimIM = " ====  Debug_Framework  ==== {{{"
" ===========================================
call add(s:vimims, VimIM)

" ----------------------------------
function! s:vimim_initialize_debug()
" ----------------------------------
    let s:path2 = 0
    let s:localization = 0
    let s:chinese_mode_switch = 1
    let s:initialization_loaded = 0
    let s:vimim_embedded_backend = 0
    let s:vimim_static_input_style = 0
    let dir = "/vimim"
    if isdirectory(dir)
        let s:path2 = dir
    endif
    " ------------------------------
    let dir = s:path . "vimim"
    if isdirectory(dir)
        let s:path2 = dir
        return
    elseif filereadable(dir)
        return
    endif
    " ------------------------------
    let sqlite = s:path . "sqlite"
    if empty(s:path2)
        return
    elseif filereadable(sqlite)
        let s:vimim_sqlite_cedict = '/usr/local/share/cjklib/cedict.db'
        let s:path2 = 0
    else
        let s:vimim_embedded_backend = "directory"
    endif
    " ------------------------------
    let s:vimim_debug = 9
    let s:vimim_tab_as_onekey = 2
    let s:vimim_static_input_style = 2
    let s:vimim_cloud_sogou = -1
    let s:vimim_imode_pinyin = 1
    let s:vimim_custom_skin = 1
    let s:vimim_custom_laststatus = 0
    let s:vimim_reverse_pageup_pagedown = 1
    " ------------------------------
endfunction

" --------------------------------
function! s:vimim_egg_vimimdebug()
" --------------------------------
    let eggs = []
    for item in s:debugs
        let egg = "> "
        let egg .= item
        let egg .= s:space
        call add(eggs, egg)
    endfor
    if empty(eggs)
        let eggs = s:vimim_egg_vimimdefaults()
    endif
    return eggs
endfunction

" ----------------------------
function! s:debugs(key, value)
" ----------------------------
    let item = '['
    let item .= s:debug_count
    let item .= ']'
    let item .= a:key
    let item .= '='
    let item .= a:value
    call add(s:debugs, item)
endfunction

" -----------------------------
function! s:debug_list(results)
" -----------------------------
    let string_in = string(a:results)
    let length = 5
    let delimiter = ":"
    let string_out = join(split(string_in)[0 : length], delimiter)
    return string_out
endfunction

" -----------------------------
function! s:vimim_debug_reset()
" -----------------------------
    if s:vimimdebug > 0
        let max = 512
        if s:debug_count > max
            let begin = len(s:debugs) - max
            if begin < 0
                let begin = 0
            endif
            let end = len(s:debugs) - 1
            let s:debugs = s:debugs[begin : end]
        endif
    endif
endfunction

" ======================================= }}}
let VimIM = " ====  Plugin_Conflict  ==== {{{"
" ===========================================
call add(s:vimims, VimIM)

" -----------------------------------
function!  s:vimim_getsid(scriptname)
" -----------------------------------
" frederick.zou fixes these conflicting plugins:
" supertab      http://www.vim.org/scripts/script.php?script_id=1643
" autocomplpop  http://www.vim.org/scripts/script.php?script_id=1879
" word_complete http://www.vim.org/scripts/script.php?script_id=73
" -----------------------------------
    " use s:getsid to get script sid, translate <SID> to <SNR>N_ style
    let l:scriptname = a:scriptname
    " get the output of ":scriptnames" in the scriptnames_output variable
    if empty(s:scriptnames_output)
        let saved_shellslash=&shellslash
        set shellslash
        redir => s:scriptnames_output
        silent scriptnames
        redir END
        let &shellslash=saved_shellslash
    endif
    for line in split(s:scriptnames_output, "\n")
        " only do non-blank lines
        if line =~ l:scriptname
            " get the first number in the line.
            let nr = matchstr(line, '\d\+')
            return nr
        endif
    endfor
    return 0
endfunction

" -----------------------------------
function! s:vimim_plugins_fix_start()
" -----------------------------------
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

" ----------------------------------
function! s:vimim_plugins_fix_stop()
" ----------------------------------
    if !empty(s:acp_sid)
        let ACPMappingDrivenkeys = [
            \ '-','_','~','^','.',',',':','!','#','=','%','$','@',
            \ '<','>','/','\','<Space>','<C-H>','<BS>','<Enter>',]
        call extend(ACPMappingDrivenkeys, range(10))
        call extend(ACPMappingDrivenkeys, s:Az_list)
        for key in ACPMappingDrivenkeys
            exe printf('iu <silent> %s', key)
            exe printf('im <silent> %s
            \ %s<C-r>=<SNR>%s_feedPopup()<CR>', key, key, s:acp_sid)
        endfor
        AcpEnable
    endif
    " -------------------------------------------------------------
    if !empty(s:supertab_sid)
        let tab = s:supertab_sid
        if g:SuperTabMappingForward =~ '^<tab>$'
            exe printf("im <tab> <C-R>=<SNR>%s_SuperTab('p')<CR>", tab)
        endif
        if g:SuperTabMappingBackward =~ '^<s-tab>$'
            exe printf("im <s-tab> <C-R>=<SNR>%s_SuperTab('n')<CR>", tab)
            " inoremap <silent> <Tab>   <C-N>
            " inoremap <silent> <S-Tab> <C-P>
        endif
    endif
    " -------------------------------------------------------------
    if !empty(s:word_complete)
    "   call DoWordComplete()
    endif
endfunction

" ======================================= }}}
let VimIM = " ====  Core_Workflow    ==== {{{"
" ===========================================
call add(s:vimims, VimIM)

" --------------------------------------
function! s:vimim_initialize_i_setting()
" --------------------------------------
    let s:saved_cpo=&cpo
    let s:saved_iminsert=&iminsert
    let s:completefunc=&completefunc
    let s:completeopt=&completeopt
    let s:saved_lazyredraw=&lazyredraw
    let s:saved_hlsearch=&hlsearch
    let s:saved_pumheight=&pumheight
    let s:saved_laststatus=&laststatus
endfunction

" ------------------------------
function! s:vimim_i_setting_on()
" ------------------------------
    set completefunc=VimIM
    set completeopt=menuone
    set nolazyredraw
    if empty(&pumheight)
        let &pumheight=8
    endif
    set hlsearch
    set iminsert=1
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

" -------------------------------
function! s:vimim_i_setting_off()
" -------------------------------
    let &cpo=s:saved_cpo
    let &iminsert=s:saved_iminsert
    let &completefunc=s:completefunc
    let &completeopt=s:completeopt
    let &lazyredraw=s:saved_lazyredraw
    let &hlsearch=s:saved_hlsearch
    let &pumheight=s:saved_pumheight
    let &laststatus=s:saved_laststatus
endfunction

" ----------------------------
function! s:vimim_start_omni()
" ----------------------------
    let s:unicode_menu_display_flag = 0
    let s:insert_without_popup = 0
endfunction

" -----------------------------
function! s:vimim_super_reset()
" -----------------------------
    sil!call s:reset_before_anything()
    sil!call g:reset_after_auto_insert()
    sil!call s:vimim_reset_before_stop()
endfunction

" -----------------------
function! s:vimim_start()
" -----------------------
    sil!call s:vimim_initialization_once()
    sil!call s:vimim_plugins_fix_start()
    sil!call s:vimim_i_setting_on()
    sil!call s:vimim_i_cursor_color(1)
    sil!call s:vimim_super_reset()
    sil!call s:vimim_12345678_label_on()
    sil!call s:vimim_load_datafile()
    sil!call s:vimim_i_chinese_mode_on()
endfunction

" ----------------------
function! s:vimim_stop()
" ----------------------
    sil!call s:vimim_stop_onekey_mode()
    sil!call s:vimim_i_setting_off()
    sil!call s:vimim_i_cursor_color(0)
    sil!call s:vimim_super_reset()
    sil!call s:vimim_debug_reset()
    sil!call s:vimim_i_map_off()
    sil!call s:vimim_initialize_mapping()
    sil!call s:vimim_plugins_fix_stop()
endfunction

" -----------------------------------
function! s:vimim_reset_before_stop()
" -----------------------------------
    let s:smart_enter = 0
    let s:pumvisible_ctrl_e = 0
endfunction

" ---------------------------------
function! s:reset_before_anything()
" ---------------------------------
    call s:reset_matched_list()
    let s:no_internet_connection = 0
    let s:pattern_not_found = 0
    let s:keyboard_count += 1
    let s:chinese_punctuation = (s:vimim_chinese_punctuation+1)%2
endfunction

" ----------------------------------------
function! s:reset_popupmenu_matched_list()
" ----------------------------------------
    let s:menu_4corner_as_filter = -1
    let s:popupmenu_matched_list = []
    let s:popupmenu_list = []
endfunction

" ------------------------------
function! s:reset_matched_list()
" ------------------------------
    call s:reset_popupmenu_matched_list()
    let s:matched_list = []
endfunction

" -----------------------------------
function! g:reset_after_auto_insert()
" -----------------------------------
    let s:keyboard_leading_zero = ''
    let s:pumvisible_hjkl_h = 0
    let s:keyboard_head = 0
    let s:keyboard_shuangpin = 0
    let s:one_key_correction = 0
    return ''
endfunction

" ------------------------------------
function! g:vimim_reset_after_insert()
" ------------------------------------
    if pumvisible()
        return ''
    endif
    call s:reset_matched_list()
    call g:reset_after_auto_insert()
    if empty(s:chinese_input_mode)
        call s:vimim_stop()
    endif
    return ''
endfunction

" ---------------------------
function! s:vimim_i_map_off()
" ---------------------------
    let unmap_list = range(0,9)
    call extend(unmap_list, s:valid_keys)
    call extend(unmap_list, keys(s:punctuations))
    call extend(unmap_list, ['<Esc>','<CR>','<BS>','<Space>'])
    " -----------------------
    for _ in unmap_list
        sil!exe 'iunmap '. _
    endfor
    " -----------------------
    iunmap <Bslash>
    iunmap '
    iunmap "
endfunction

" -----------------------------------
function! s:vimim_helper_mapping_on()
" -----------------------------------
    if s:vimim_static_input_style == 1
        inoremap <Esc> <C-R>=g:vimim_pumvisible_ctrl_e()<CR>
                      \<C-R>=g:vimim_one_key_correction()<CR>
    endif
    " ----------------------------------------------------------
    inoremap <CR>  <C-R>=g:vimim_pumvisible_ctrl_e()<CR>
                  \<C-R>=<SID>vimim_smart_enter()<CR>
    " ----------------------------------------------------------
    inoremap <BS>  <C-R>=g:vimim_pumvisible_ctrl_e_on()<CR>
                  \<C-R>=<SID>vimim_ctrl_x_ctrl_u_bs()<CR>
    " ----------------------------------------------------------
endfunction

" ======================================= }}}
let VimIM = " ====  Core_Engine      ==== {{{"
" ===========================================
call add(s:vimims, VimIM)

" ------------------------------
function! VimIM(start, keyboard)
" ------------------------------
if a:start

    call s:vimim_start_omni()
    let current_positions = getpos(".")
    let start_column = current_positions[2]-1
    let start_column_save = start_column
    let start_row = current_positions[1]
    let current_line = getline(start_row)
    let byte_before = current_line[start_column-1]
    let char_before_before = current_line[start_column-2]

    " take care of seamless english/chinese input
    " -------------------------------------------
    let seamless_column = s:vimim_get_seamless(current_positions)
    if seamless_column < 0
        let msg = "no need to set seamless"
    else
        let s:start_column_before = seamless_column
        return seamless_column
    endif

    let last_seen_nonsense_column = start_column
    let last_seen_backslash_column = start_column
    let all_digit = 1

    let nonsense_pattern = "[0-9.']"
    if get(s:im['pinyin'],0) > 0
        let nonsense_pattern = "[0-9.]"
    elseif get(s:im['phonetic'],0) > 0
    \|| get(s:im['array30'],0) > 0
        let nonsense_pattern = "[.]"
    endif

    while start_column > 0
        if  byte_before =~# s:valid_key
            let start_column -= 1
            if byte_before !~# nonsense_pattern
                let last_seen_nonsense_column = start_column
            endif
            if byte_before =~# '\l'
            \&& all_digit > 0
            \&& get(s:im['phonetic'],0) < 1
            \&& get(s:im['array30'],0) < 1
                let all_digit = 0
            endif
        elseif byte_before=='\' && s:vimim_backslash_close_pinyin>0
            " do nothing for pinyin with leading backslash
            return last_seen_backslash_column
        else
            break
        endif
        let byte_before = current_line[start_column-1]
    endwhile

    if all_digit < 1
        let start_column = last_seen_nonsense_column
        let char_1st = current_line[start_column]
        let char_2nd = current_line[start_column+1]
        if char_1st ==# "'"
            if s:vimim_imode_universal > 0
            \&& char_2nd =~# "[0-9ds']"
                let msg = "sharing apostrophe as much as possible"
            else
                let start_column += 1
            endif
        endif
    endif

    let s:start_row_before = start_row
    let s:current_positions = current_positions
    let len = current_positions[2]-1 - start_column
    let s:keyboard_leading_zero = strpart(current_line,start_column,len)
    let s:start_column_before = start_column
    return start_column

else

    if s:vimimdebug > 0
        let s:debug_count += 1
        call s:debugs('keyboard', s:keyboard_leading_zero)
        if s:vimimdebug > 2
            call s:debugs('keyboard_a', a:keyboard)
        endif
    endif

    if s:one_key_correction > 0
        let d = 'delete in omni popup menu'
        let BS = 'delete in Chinese Mode'
        let s:one_key_correction = 0
        return [" "]
    endif

    let keyboard = a:keyboard
    if empty(s:keyboard_leading_zero)
        let s:keyboard_leading_zero = keyboard
    endif
    if empty(str2nr(keyboard))
        let msg = "the input is alphabet only"
    else
        let keyboard = s:keyboard_leading_zero
    endif

    " ignore all-zeroes keyboard inputs
    " ---------------------------------
    if empty(s:keyboard_leading_zero)
        return
    endif

    " ignore non-sense keyboard inputs
    " --------------------------------
    if keyboard !~# s:valid_key
        return
    endif

    " ignore multiple non-sense dots
    " ------------------------------
    if keyboard =~# '^[\.\.\+]'
    \&& get(s:im['boshiamy'],0) < 1
        let s:pattern_not_found += 1
        return
    endif

    " [erbi] special meaning of the first punctuation
    " -----------------------------------------------
    if s:im['erbi'][0] > 0
        let punctuation = s:vimim_first_punctuation_erbi(keyboard)
        if !empty(punctuation)
            return [punctuation]
        endif
    endif

    " ignore non-sense one char input
    " -------------------------------
    if s:vimim_static_input_style < 2
    \&& get(s:im['boshiamy'],0) < 1
    \&& len(keyboard) == 1
    \&& keyboard !~# '\w'
        return
    endif

    " [eggs] hunt classic easter egg ... vim<C-6>
    " -------------------------------------------
    if keyboard ==# "vim" || keyboard =~# "^vimim"
        let results = s:vimim_easter_chicken(keyboard)
        if len(results) > 0
            return s:vimim_popupmenu_list(results)
        endif
    endif

    " use cached list for digit filter
    " --------------------------------
    if s:menu_4corner_as_filter > -1
        let results = s:popupmenu_matched_list
        if empty(results)
            let msg = "built it if no popup matched list"
        else
            let results = s:vimim_popupmenu_list(results)
            if empty(results)
                return s:popupmenu_list
            else
                return results
            endif
        endif
    endif

    " [mycloud] get chunmeng from mycloud local or www
    " ------------------------------------------------
    if empty(s:vimim_cloud_plugin)
        let msg = "keep local mycloud code for the future."
    else
        let results = s:vimim_get_mycloud_plugin(keyboard)
        if empty(len(results))
            " return empty list if the result is empty
            return []
        else
            return s:vimim_popupmenu_list(results)
        endif
    endif

    " [wubi] support wubi non-stop input
    " ----------------------------------
    if get(s:im['wubi'],0) > 0
        let results = s:vimim_wubi(keyboard)
        if len(results) > 0
            let results = s:vimim_pair_list(results)
            return s:vimim_popupmenu_list(results)
        endif
    endif

    " support direct internal code (unicode/gb/big5) input
    " ----------------------------------------------------
    if s:vimim_internal_code_input > 0
        let msg = " usage: u808f<C-6> 32911<C-6>  32910<C-6> "
        let results = s:vimim_internal_code(keyboard)
        if len(results) > 0
            let s:unicode_menu_display_flag = 1
            return s:vimim_popupmenu_list(results)
        endif
    endif

    " try super-internal-code if no backend nor cloud
    " -----------------------------------------------
    if s:vimim_super_internal_input > 0
        let msg = " usage: a<C-6> b<C-6> ... z<C-6> "
        let results = s:vimim_without_backend(keyboard)
        if len(results) > 0
            let s:unicode_menu_display_flag = 1
            return s:vimim_popupmenu_list(results)
        endif
    endif

    " [imode] magic 'i': English number => Chinese number
    " ---------------------------------------------------
    if s:vimim_imode_pinyin > 0
    \&& keyboard =~# '^i'
    \&& s:vimim_embedded_backend !~ "sqlite"
        let msg = "usage: i88<C-6> ii88<C-6> i1g<C-6> isw8ql "
        let chinese_numbers = s:vimim_imode_number(keyboard, 'i')
        if len(chinese_numbers) > 0
            return s:vimim_popupmenu_list(chinese_numbers)
        endif
    endif

    " [imode] magic leading apostrophe: universal imode
    " -------------------------------------------------
    if s:vimim_imode_universal > 0
    \&& keyboard =~# "^'"
    \&& (empty(s:chinese_input_mode) || s:chinese_input_mode=~ 'onekey')
        let msg = "usage: '88<C-6> ''88<C-6> '1g<C-6> 'sw8ql "
        let chinese_numbers = s:vimim_imode_number(keyboard, "'")
        if len(chinese_numbers) > 0
            return s:vimim_popupmenu_list(chinese_numbers)
        endif
    endif

    " [cloud] magic trailing apostrophe to control cloud or not cloud
    " ---------------------------------------------------------------
    let clouds = s:vimim_magic_tail(keyboard)
    if len(clouds) > 0
        let msg = "usage: woyouyigemeng'<C-6> "
        let keyboard = get(clouds, 0)
    endif

    " [shuangpin] support 6 major shuangpin with various rules
    " --------------------------------------------------------
    let keyboard = s:vimim_get_pinyin_from_shuangpin(keyboard)

    let s:keyboard_leading_zero = keyboard
    " ------------------------------------
    if s:vimim_datafile_has_apostrophe > 0
        let keyboard = s:vimim_apostrophe(keyboard)
    endif

    " [cloud] to make cloud come true for woyouyigemeng
    " -------------------------------------------------
    let cloud = s:vimim_to_cloud_or_not(keyboard, clouds)
    if cloud > 0
        let results = s:vimim_get_cloud_sogou(keyboard, cloud)
        if empty(len(results))
            if s:vimim_cloud_sogou > 2
                let s:no_internet_connection += 1
            endif
        else
            let s:no_internet_connection = 0
            return s:vimim_popupmenu_list(results)
        endif
    endif

    " [sqlite] uses standard unihan cedict database
    " ---------------------------------------------
    if len(s:sqlite_executable) > 5 && !empty(s:sqlite)
        let results2 = s:vimim_sentence_match_sqlite(keyboard)
        if empty(results2)
            let msg = "nothing found from sqlite database"
        else
            let results = s:vimim_pair_list(results2)
            return s:vimim_popupmenu_list(results)
        endif
    endif

    " [directory] directory database is natural to vim editor
    let im = s:input_method
    " ------------------------------------------------------
    if len(s:path2) > 1
        if len(s:data_directory_4corner) > 1
            let digit_input  = '^\d\d\+$'
            if keyboard =~ digit_input
                let im = "4corner"
            endif
        endif
        " --------------------------------------------------
        let keyboards = s:vimim_sentence_directory(keyboard, im)
        if empty(keyboards)
            let msg = "sell keyboard as is for directory database"
        else
            let keyboard = get(keyboards, 0)
            " -------------------------------------------------
            let results2 = s:vimim_get_data_from_directory(keyboard, im)
            if len(results2) > 0
                let results = s:vimim_pair_list(results2)
            else
                let results = s:vimim_pinyin_with_4corner(keyboard)
            endif
            if len(results) > 0
                return s:vimim_popupmenu_list(results)
            endif
            " -------------------------------------------------
        endif
    endif

    " [wildcard search] play with magic star
    " --------------------------------------
    if s:vimim_wildcard_search > 0
        let results = s:vimim_wildcard_search(keyboard, s:lines)
        if len(results) > 0
            let results = s:vimim_pair_list(results)
            return s:vimim_popupmenu_list(results)
        endif
    endif

    " [datafile] datafile is used as another backend
    " ----------------------------------------------
    let pattern = '^' . keyboard
    let match_start = match(s:lines, pattern)

    " sentence match for datafile only
    " --------------------------------
    if match_start < 0 && empty(clouds)
        let keyboards = s:vimim_sentence_datafile(s:lines, keyboard, im)
        if empty(keyboards)
            let msg = "sell the keyboard as is, without modification"
        else
            let keyboard = get(keyboards, 0)
            if s:pumvisible_hjkl_h > 0
                let s:keyboard_head = keyboard
            endif
            let pattern = "^" . keyboard
            let match_start = match(s:lines, pattern)
        endif
    endif

    if match_start < 0
        let msg = "fuzzy search could be done here, if needed"
    else
        if s:vimim_datafile_has_apostrophe > 0
            let results = s:vimim_fixed_match(s:lines, keyboard, 1)
        elseif get(s:im['pinyin'],0) > 0
            let results = s:vimim_pinyin(s:lines, keyboard, match_start)
        else
            let results = s:vimim_fixed_match(s:lines, keyboard, 4)
        endif
        if len(results) > 0
            let results = s:vimim_pair_list(results)
            return s:vimim_popupmenu_list(results)
        endif
    endif

    " [cloud] last try cloud before giving up
    " ---------------------------------------
    if s:vimim_cloud_sogou == 1
        let results = s:vimim_get_cloud_sogou(keyboard, 1)
        if len(results) > 0
            return s:vimim_popupmenu_list(results)
        endif
    endif

    " [seamless] support seamless English input
    " -----------------------------------------
    if match_start < 0
        let s:pattern_not_found += 1
        let results = []
        if empty(s:chinese_input_mode)
            let results = [keyboard ." ". keyboard]
        else
            call <SID>vimim_set_seamless()
        endif
        return s:vimim_popupmenu_list(results)
    endif

endif
endfunction

" ======================================= }}}
let VimIM = " ====  Core_Drive       ==== {{{"
" ===========================================
call add(s:vimims, VimIM)

" ------------------------------------
function! s:vimim_initialize_mapping()
" ------------------------------------
    sil!call s:vimim_chinese_mode_mapping_on()
    sil!call s:vimim_ctrl_space_mapping_on()
    sil!call s:vimim_onekey_mapping_on()
endfunction

" -----------------------------------------
function! s:vimim_chinese_mode_mapping_on()
" -----------------------------------------
    if s:vimim_tab_as_onekey == 2
        inoremap <unique> <expr> <Plug>VimimTabKey <SID>TabKey()
            imap <silent> <Tab>  <Plug>VimimTabKey
         noremap <silent> <C-^> :call <SID>ChineseMode()<CR>
        return
    endif
    " ---------------------------------------------------------
    if !hasmapto('<Plug>VimimTrigger', 'i')
        inoremap <unique> <expr>     <Plug>VimimTrigger <SID>ChineseMode()
           imap  <silent> <C-Bslash> <Plug>VimimTrigger
        noremap  <silent> <C-Bslash> :call <SID>ChineseMode()<CR>
           vmap  <silent> <C-Bslash> :call <SID>ChineseMode()<CR>gv
    endif
    " ---------------------------------------------------------
endfunction

" ---------------------------------------
function! s:vimim_ctrl_space_mapping_on()
" ---------------------------------------
    if s:vimim_ctrl_space_to_toggle == 1
        if has("gui_running")
             map <C-Space> <C-Bslash>
            imap <C-Space> <C-Bslash>
        elseif has("win32unix")
             map <C-@> <C-Bslash>
            imap <C-@> <C-Bslash>
        endif
    endif
endfunction

" -----------------------------------
function! s:vimim_onekey_mapping_on()
" -----------------------------------
    if !hasmapto('<Plug>VimimOneKey', 'i')
        inoremap <unique> <expr> <Plug>VimimOneKey <SID>OneKey()
    endif
    " -----------------------------------
    if !hasmapto('<C-^>', 'i')
        imap <silent> <C-^> <Plug>VimimOneKey
    endif
    " -----------------------------------
    if !hasmapto('<C-^>', 'v')
        xnoremap<silent><C-^> y:call <SID>vimim_visual_ctrl_6(@0)<CR>
    endif
    " -----------------------------------
    if s:vimim_tab_as_onekey == 1
        imap <silent> <Tab> <Plug>VimimOneKey
    endif
    " -----------------------------------
endfunction

" ------------------------------------
function! s:vimim_initialize_autocmd()
" ------------------------------------
    if !has("autocmd")
        return
    endif
    " all dot vimim files are our first-class citizen.
    augroup vimim_auto_chinese_mode
        autocmd InsertLeave *.vimim sil!call s:vimim_stop()
        autocmd InsertEnter *.vimim sil!call <SID>ChineseMode()
    augroup END
endfunction

sil!call s:vimim_initialize_global()
sil!call s:vimim_initialize_debug()
sil!call s:vimim_initialize_mapping()
sil!call s:vimim_initialize_autocmd()
" ======================================= }}}

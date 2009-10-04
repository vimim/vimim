" ------------------------------------------------
" vi $VIMRUNTIME/menu.vim
" ------------------------------------------------
if !has("spell")
  finish
endif

func! <SID>SpellPopup()
  if exists("s:changeitem") && s:changeitem != ''
    call <SID>SpellDel()
  endif
  if !&spell || &spelllang == ''|return|endif
  let curcol = col('.')
  let [w, a] = spellbadword()
  if col('.') > curcol
    let w = ''
    call cursor(0, curcol)
  endif
  if w != ''
    if a == 'caps'
      let s:suglist = [substitute(w, '.*', '\u&', '')]
    else
      let s:suglist = spellsuggest(w, 10)
    endif
    if len(s:suglist) <= 0
      call cursor(0, curcol)
    else
      let s:changeitem = 'change\ "' . escape(w, ' .'). '"\ to'
      let s:fromword = w
      let pri = 1
      for sug in s:suglist
        exe 'amenu 1.5.'.pri.' PopUp.'.s:changeitem.'.'.escape(sug,' .')
              \ . ' :call <SID>SpellReplace(' . pri . ')<CR>'
        let pri += 1
      endfor
      let s:additem = 'add\ "' . escape(w, ' .') . '"\ to\ word\ list'
      exe 'amenu 1.6 PopUp.' . s:additem . ' :spellgood ' . w . '<CR>'
      let s:ignoreitem = 'ignore\ "' . escape(w, ' .') . '"'
      exe 'amenu 1.7 PopUp.' . s:ignoreitem . ' :spellgood! ' . w . '<CR>'
      amenu 1.8 PopUp.-SpellSep- :
    endif
  endif
endfunc
func! <SID>SpellReplace(n)
  let l = getline('.')
  call setline('.', strpart(l, 0, col('.') - 1) . s:suglist[a:n - 1]
        \ . strpart(l, col('.') + len(s:fromword) - 1))
endfunc
func! <SID>SpellDel()
  exe "aunmenu PopUp." . s:changeitem
  exe "aunmenu PopUp." . s:additem
  exe "aunmenu PopUp." . s:ignoreitem
  aunmenu PopUp.-SpellSep-
  let s:changeitem = ''
endfun
au! MenuPopup * call <SID>SpellPopup()

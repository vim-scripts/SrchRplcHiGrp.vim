" SrchRplcHiGrp.vim  - Search and Replace based on a highlight group
"
" Version:	    0.15
" Author:	    David Fishburn <fishburn@ianywhere.com>
" Last Changed: Fri Jan 09 2004 11:21:21 PM
" Created:	    Tue Dec 02 2003 10:11:07 PM
" Description:  Search and Replace based on a syntax highlight group
" Script:	    http://www.vim.org/script.php?script_id=848
" License:      GPL (http://www.gnu.org/licenses/gpl.html)
"
" Command Help:  {{{
"     Ensure you have updated the help system:
"     :helptags $VIM/vimfiles/doc (Windows)
"     :helptags $VIM/.vim/doc     (*nix)
"
"     :h SRHiGrp
" }}}

" If syntax is not enabled, do not bother loading this plugin
if exists('g:loaded_srhg') || &cp || !exists("syntax_on")
	finish
endif
let g:loaded_srhg = 1

" Default the highlight group to 0
let s:srhg_group_id  = 0
let s:srhg_firstline = 0
let s:srhg_lastline  = 0

" Functions: "{{{  

" SRWarningMsg:
function! <SID>SRWarningMsg(msg)  "{{{  
    echohl WarningMsg
    echomsg a:msg
    echohl None
endfunction  "}}}  

" SRDispHiGrp:
function! <SID>SRDispHiGrp()  "{{{  
    if s:srhg_group_id != 0
	 	if s:srhg_group_id < 0
			let gid= -s:srhg_group_id
		else
			let gid=  s:srhg_group_id
		endif
        exec 'echohl ' . synIDattr(gid, "name")
        echomsg "SRHiGrp - Group ID: " .gid . "  Name: " . synIDattr(gid,"name")
        echohl None
    else
        echo "No highlight group has been choosen yet"
    endif
endfunction  "}}}  

" SRChooseHiGrp:
function! <SID>SRChooseHiGrp(use_top_level)  "{{{  
    if(a:use_top_level == 1)
        let cursynid = -synID(line("."),col("."),1) 
    else
        let cursynid =  synIDtrans(synID(line("."),col("."),1)) 
    endif

    if cursynid == 0
        call s:SRWarningMsg( 
                    \ 'There is no syntax group specified ' .
                    \ 'under the cursor'
                    \ )
    else
        let s:srhg_group_id = cursynid
        call s:SRDispHiGrp()
    endif
endfunction  "}}}  

" SRPositionWord:
function! <SID>SRPositionWord( prvline, prvcol)  "{{{  
    let prvline = a:prvline
    let prvcol  = a:prvcol

    " echo 'L:'. col("'<") . ' R:' . col("'>")
    " echo 'Visual Mode:'. visualmode()

    if (prvline == 0) && (prvcol == 0)
        " If the current line position is not at the beginning
        " or the end of the visual region
        if line(".") != line("'<") && line(".") != line("'>") 
            " Visually select the rows to ensure the correct
            " range is operated on.
            " This handles the case that SRHiGrp was run as:
            "   :SRHiGrp
            "   :1,5SRHiGrp
            " instead of:
            "   :'<,'>SRHiGrp

            exec 'normal! '.s:srhg_firstline."GV"
            if s:srhg_lastline > s:srhg_firstline
                exec "normal! " . 
                            \ (s:srhg_lastline - s:srhg_firstline) . 
                            \ "j"
            endif
            exec "normal! \<Esc>"
        endif
        let leftcol  = col("'<") - 1
        exe 'norm! '.s:srhg_firstline."G\<bar>".leftcol.(leftcol>0 ? 'l' : '' )
        return 1
    endif

    while 1==1
        if visualmode() == 'v'
            if line(".") == s:srhg_firstline
                let leftcol  = col("'<") - 1
            else
                let leftcol  = 1
            endif
            if line(".") == s:srhg_lastline
                let rightcol  = col("'>")
            else
                let rightcol  = col("$")
            endif
        elseif visualmode() == 'V'
            let leftcol  = 0
            let rightcol = col("$")
        elseif visualmode() == "\<C-V>"
            let leftcol  = col("'<") - 1
            let rightcol  = col("'>")
        endif

        " echo 'PrvLine:'.prvline.' prvcol:'.prvcol.
        "             \' L:'.leftcol.' R:'.rightcol.
        "             \' VL:'.leftcol.' VR:'.rightcol

        " Position cursor on leftcol
        " on each new line based on visual mode
        if col(".") < leftcol
            exe 'norm! '.line(".")."G\<bar>".leftcol.(leftcol>0 ? 'l' : '' )
        else
            normal! w
        endif

        " Add additional check to see if the cursor has
        " moved after the above, if not, exit.
        if (col(".") == prvcol) && (line(".") == prvline)
            return -1
        endif


        if col(".")  >= leftcol  && 
                    \ col(".")  <= rightcol && 
                    \ line(".") <= s:srhg_lastline
            return 1
        elseif col(".") > rightcol && line(".") < s:srhg_lastline
            let prvline = prvline + 1
            " Position the cursor on the next line and move 
            " to the start of the visual region
            exe 'norm! '.prvline."G\<bar>".leftcol.(leftcol>0 ? 'l' : '' )
            break
        elseif col(".") < leftcol && line(".") <= s:srhg_lastline
            " outside of visual area, move to next word
            continue
        else
            return -1
        endif
    endwhile

    return 1
endfunction  "}}}  

" SRHiGrp:
function! <SID>SRHiGrp(...) range   "{{{  

    let s:srhg_firstline = a:firstline
    let s:srhg_lastline  = a:lastline

    if s:srhg_group_id == 0
        call s:SRWarningMsg( 
                    \ 'You must specify a syntax group name ' .
                    \ 'by placing the cursor on a character ' .
                    \ 'that is highlighted the way you want ' .
                    \ 'and execute :SRChooseHiGrp or ' . 
                    \ ':SRChooseHiGrp!'  
                    \ )
        return
    endif

    if(a:0 > 0) 
        if( a:1 == 0 || a:1 == 1)
            let match_group = a:1
        endif
    else
        " Default to operate on syntax groups that match
        let match_group = 1
    endif

    if(a:0 > 1) 
        let match_exp = a:2
    else
        let match_exp = '\(\w\+\>\)'
        let dialog_msg = "Enter match expression (default word at cursor - " . 
                        \ match_exp .
                        \ "): "
        let l:var_val = inputdialog(dialog_msg, match_exp)
        let response = 1
        " Ok or Cancel result in an empty string
        if l:var_val == ""
            call s:SRWarningMsg( 
                        \ 'You must provide a match expression which ' .
                        \ 'includes a submatch' 
                        \ )
            return
        endif
        let match_exp = l:var_val
    endif

    if(a:0 > 2) 
        let replace_exp  = a:3
    else
        let replace_exp  = '\U\1'
        let dialog_msg = "Enter replacement expression for the submatch " .
                    \ "(ie capitalize word - \\U\\1): "
        let l:var_val = inputdialog(dialog_msg, replace_exp)
        let response = 1
        " Ok or Cancel result in an empty string
        if l:var_val == ""
            " If empty, check if they want to leave it empty
            " of skip this variable
            let response = confirm("Your value is empty!"
                        \ , "&Use blank\n&Cancel", response)
        endif
        if response == 1
            " Replace the variable with what was entered
            let replace_exp = l:var_val
        else
            " Cancel
            return 
        endif
    endif

    " let higrpid    = synIDtrans(hlID(s:srhg_group_id))
    let lastline   = line("$")
    let curcol     = 0
    let curline    = line(".")
    let fenkeep    = &fen
    let saveSearch = @/
    set nofoldenable

    if s:SRPositionWord(0,0) == -1
        call s:SRWarningMsg( 
                    \ 'Please reselect the visual area (ie gv)'
                    \ )
        return
    endif

	let gid = s:srhg_group_id
	if(gid < 0)
		let gid = -s:srhg_group_id
	endif

    while line(".") <= a:lastline
        let curcol   = col(".")
        let curline  = line(".")
        let cursynid = (s:srhg_group_id < 0) ?
                    \ -synID(line("."),col("."),1) :
                    \ synIDtrans(synID(line("."),col("."),1)) 
        let cursynid = (s:srhg_group_id < 0) ? synID(line("."),col("."),1) : synIDtrans(synID(line("."),col("."),1)) 
        " Useful debugging statement:
        " echo col(".").':'.getline(".")[col(".")-1].':'.cursynid.':'.getline(".")

        if line(".") == curline 
            if match_group == 1 && cursynid == gid
                " Perform the subtitution, but do not report an error
                " if the match fails
                exec 's/\%#'.match_exp.'/'.replace_exp.'/e'
                " Since this command can move the cursor, put the cursor
                " back to its original position
                exe 'norm! '.curline."G\<bar>".(curcol-1)."l"
            elseif match_group == 0 && cursynid != gid
                " Perform the subtitution, but do not report an error
                " if the match fails
                exec 's/\%#'.match_exp.'/'.replace_exp.'/e'
                " Since this command can move the cursor, put the cursor
                " back to its original position
                exe 'norm! '.curline."G\<bar>".(curcol-1)."l"
            endif
        endif

        let prvcol  = curcol
        let prvline = curline
        if s:SRPositionWord(prvline, prvcol) == -1
            break
        endif

    endwhile

    " cleanup
    let &fen= fenkeep
    if foldlevel(".") > 0
        norm! zO
    endif
    unlet curcol
    " unlet higrpid
    unlet lastline
    let @/ = saveSearch
    if exists("prvcol")
        unlet prvcol
    endif
endfunction  "}}}  

"}}}  

" Commands:  {{{  
command! -range -bang -nargs=* SRHiGrp       <line1>,<line2>call s:SRHiGrp(<bang>1,<args>)
command!        -bang -nargs=0 SRChooseHiGrp :call s:SRChooseHiGrp(<bang>1)
command!              -nargs=0 SRDispHiGrp   :call s:SRDispHiGrp()
"}}}  

" vim:fdm=marker:nowrap:ts=4:

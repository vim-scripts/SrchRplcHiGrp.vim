" SrchRplcHiGrp.vim  - Search and Replace based on a highlight group
"
" Version:	    7.0
" Author:	    David Fishburn <dfishburn dot vim at gmail dot com>
" Last Changed: 2015 Aug 25
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
if exists('g:loaded_srhg') || !exists("syntax_on")
	finish
endif
let g:loaded_srhg = 7

" Turn on support for line continuations when creating the script
let s:cpo_save = &cpo
set cpo&vim

" Commands:  {{{
command! -range=% -nargs=* -bang SRHiGrp       <line1>,<line2>call SrchRplcHiGrp#SRHiGrp(<bang>1,<args>)
command!          -nargs=* -bang SRChooseHiGrp :call SrchRplcHiGrp#SRChooseHiGrp(<bang>1,<args>)
command!          -nargs=*       SRDispHiGrp   :call SrchRplcHiGrp#SRDispHiGrp(<args>)
command! -range=% -nargs=? -bang SRSearch      call SrchRplcHiGrp#SRSearch(<bang>1,<line1>,<line2>,<q-args>)
"}}}

let &cpo = s:cpo_save
unlet s:cpo_save

" vim:fdm=marker:nowrap:ts=4:

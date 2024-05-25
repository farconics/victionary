" =========================================================================
" Vim plugin for looking up words in an online dictionary (ie. WordNet)
" A fork of the vim-online-thesaurus plugin
" Author:	Jose Francisco Taas, Evan Quan
" Version: 3.1.0
" Credits to both Anton Beloglazov and Nick Coleman: original idea and code
" And to Dave Pearson: RFC 2229 client for ruby
" NOTE: This is a very hackish implementation since I didn't originally
" plan on sharing the code. It could also be because I'm a piss-poor coder.
" =========================================================================
if exists("g:victionary#loaded")
	finish
endif

let s:path = expand('<sfile>:p:h')
let s:dictpath = s:path . '/dict.rb'

let g:victionary#WORD_NET = "wn"
let g:victionary#GCIDE = "gcide"

if !exists("g:victionary#format_results")
	let g:victionary#format_results = 1
endif

let s:thesaurus = "moby-thesaurus"

let s:dictionary_names = {
                          \ g:victionary#WORD_NET : "WordNet",
                          \ g:victionary#GCIDE    : "GCIDE",
                          \ s:thesaurus           : "Moby Thesaurus",
                          \}

if !exists("g:victionary#dictionary")
	let g:victionary#dictionary = g:victionary#WORD_NET
endif

function! s:GetThesaurus()
	return s:thesaurus
endfunction

function! s:Lookup(word, dictionary)
	silent keepalt belowright split victionary
	setlocal noswapfile nobuflisted nospell nowrap modifiable
	setlocal buftype=nofile bufhidden=hide
	1,$d
	echo "Fetching " . a:word . " from the " . get(s:dictionary_names, a:dictionary, a:dictionary) . " dictionary..."
	exec "silent 0r !" . s:dictpath . " -d " . a:dictionary . " " . a:word
	normal! ggiWord:

	let l:resizeTo = line('$') + 1
	let l:l = search('^\s*2[:.]', 'n')
	if l:l > 0
		let l:resizeTo = l:l
	endif
	exec 'resize ' . (l:resizeTo - 1)
	unlet! l:l l:resizeTo

	nnoremap <silent> <buffer> q :q<Return>
	if g:victionary#format_results
		setlocal nonumber norelativenumber showbreak="" nolist
		setlocal cursorline colorcolumn=""
	endif
	setlocal nomodifiable filetype=victionary
endfunction

function! s:WordPrompt(prompt, dictionary)
	call inputsave()
	let word = input(a:prompt . ': ')
	call inputrestore()
	if word == ""
		return
	end
	redraw
	call s:Lookup(word, a:dictionary)
endfunction

if !exists('g:victionary#map_defaults')
	let g:victionary#map_defaults = 1
endif

nnoremap <Plug>(victionary#define_prompt) :call <SID>WordPrompt('Define word', g:victionary#dictionary)<Return>
nnoremap <Plug>(victionary#define_under_cursor) :call <SID>Lookup('<C-r><C-w>', g:victionary#dictionary)<Return>

nnoremap <Plug>(victionary#synonym_prompt) :call <SID>WordPrompt('Get synonyms', <SID>GetThesaurus())<Return>
nnoremap <Plug>(victionary#synonym_under_cursor) :call <SID>Lookup('<C-r><C-w>', <SID>GetThesaurus())<Return>

if g:victionary#map_defaults
	nnoremap <unique> <Leader>d <Plug>(victionary#define_prompt)
	nnoremap <unique> <Leader>D <Plug>(victionary#define_under_cursor)
	nnoremap <unique> <Leader>s <Plug>(victionary#synonym_prompt)
	nnoremap <unique> <Leader>S <Plug>(victionary#synonym_under_cursor)
endif

command! -nargs=1 VictionaryDefine :call <SID>Lookup(<f-args>, g:victionary#dictionary)
command! -nargs=1 VictionarySynonym :call <SID>Lookup(<f-args>, <SID>GetThesaurus())

let g:victionary#loaded = 1

" =========================================================================
" Vim plugin for looking up words in an online dictionary (ie. WordNet)
" A fork of the vim-online-thesaurus plugin
" Author:	Jose Francisco Taas, Evan Quan
" Version: 2.0.0
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

let s:database_names = {
                      \ g:victionary#WORD_NET : "WordNet",
                      \ g:victionary#GCIDE : "GCIDE",
                      \}

if !exists("g:victionary#database")
	" let g:victionary#database =  g:victionary#WORD_NET
	let g:victionary#database =  g:victionary#GCIDE
endif

let s:thesaurus = "moby-thesaurus"

function! s:GetThesaurus()
	return s:thesaurus
endfunction

function! s:Lookup(word, database)
	silent keepalt belowright split victionary
	setlocal noswapfile nobuflisted nospell nowrap modifiable
	setlocal buftype=nofile bufhidden=hide
	1,$d
	echo "Fetching " . a:word . " from the " . s:database_names[a:database] . " dictionary..."
	exec "silent 0r !" . s:dictpath . " -d " . a:database . " " . a:word
	normal! ggiWord: 
ruby << EOF
	@buffer = VIM::Buffer.current
	resizeTo = VIM::evaluate("line('$')") + 1
	for i in 1..@buffer.count
		if @buffer[i].include? "2:"
			resizeTo = i
			break
		end
	end
	VIM.command("resize #{resizeTo - 1}")
EOF
	nnoremap <silent> <buffer> q :q<CR>
	setlocal nomodifiable filetype=victionary
endfunction

function! s:WordPrompt(prompt, database)
	call inputsave()
	let word = input(a:prompt . ': ')
	call inputrestore()
	if word == ""
		return
	end
	redraw
	call s:Lookup(word, a:database)
endfunction

if !exists('g:victionary#map_defaults')
	let g:victionary#map_defaults = 1
endif

nnoremap <Plug>(victionary#define_prompt) :call <SID>WordPrompt('Define word', g:victionary#database)<Return>
nnoremap <Plug>(victionary#define_under_cursor) :call <SID>Lookup('<C-r><C-w>', g:victionary#database)<Return>

nnoremap <Plug>(victionary#synonym_prompt) :call <SID>WordPrompt('Get synonym', <SID>GetThesaurus())<Return>
nnoremap <Plug>(victionary#synonym_under_cursor) :call <SID>Lookup('<C-r><C-w>', <SID>GetThesaurus())<Return>

if g:victionary#map_defaults
	nnoremap <unique> <Leader>d <Plug>(victionary#define_prompt)
	nnoremap <unique> <Leader>D <Plug>(victionary#define_under_cursor)
	nnoremap <unique> <Leader>s <Plug>(victionary#synonym_prompt)
	nnoremap <unique> <Leader>S <Plug>(victionary#synonym_under_cursor)
endif

command! -nargs=1 VictionaryDefine :call <SID>Lookup(<f-args>, g:victionary#database)
command! -nargs=1 VictionarySynonym :call <SID>Lookup(<f-args>, <SID>GetThesaurus())

let g:victionary#loaded = 1

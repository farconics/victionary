" =========================================================================
" Vim plugin for looking up words in an online dictionary (ie. WordNet)
" A fork of the vim-online-thesaurus plugin
" Author:	Jose Francisco Taas
" Version: 0.1.0
" Credits to both Anton Beloglazov and Nick Coleman: original idea and code
" And to Dave Pearson: RFC 2229 client for ruby
" NOTE: This is a very hackish implementation since I didn't originally
" plan on sharing the code. It could also be because I'm a piss-poor coder.
" =========================================================================
if exists("g:loaded_victionary")
	finish
endif
let g:loaded_victionary = 1

let s:path = expand('<sfile>:p:h')
let s:dictpath = s:path . '/dict.rb'

function! s:Lookup(word)
	silent keepalt belowright split victionary
	setlocal noswapfile nobuflisted nospell nowrap modifiable
	setlocal buftype=nofile bufhidden=hide
	1,$d
	echo "Fetching " . a:word . " from the WordNet dictionary..."
	exec "silent 0r !" . s:dictpath . " -d wn " . a:word
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

function! s:WordPrompt()
	call inputsave()
	let word = input('Enter word: ')
	call inputrestore()
	if word == ""
		return
	end
	redraw
	call s:Lookup(word)
endfunction

noremap <Leader>d :call <SID>WordPrompt()<CR>

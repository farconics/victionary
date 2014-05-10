if exists("b:current_syntax")
	finish
endif

syntax match vdWordHead /Word: */ contained
syntax keyword vdSynonyms syn
syntax region vdWord start=/Word:/ end=/$/ contains=CONTAINED keepend
highlight link vdSynonyms Keyword
highlight link vdWordHead Keyword
highlight vdWord term=bold cterm=bold gui=bold

let b:current_syntax = "victionary"

" ============================================================================
" File: victionary.vim
" Maintainer: https://github.com/farconics/victionary/
" Version: 0.1.0
"
" Syntax highlighting for victionary results.
"
" NOTE: Currently only works with WordNet definitions
" ============================================================================
if exists("b:current_syntax")
	finish
endif

syntax match vdWordHead /^Word: */ contained
syntax match vdSeparator /;/

syntax keyword vdAntonyms ant
syntax keyword vdSynonyms syn

syntax region vdAdjective start=/^    adj/ end=/ / contains=CONTAINED keepend
syntax region vdAdverb start=/^    adv/ end=/ / contains=CONTAINED keepend
syntax region vdDefitionNumber start=/[1-9]/ end=/:/ contains=CONTAINED keepend
syntax region vdNoun start=/^    n/ end=/ / contains=CONTAINED keepend
syntax region vdQuote start=/"/ end=/"/ contains=CONTAINED keepend
syntax region vdSynonym start=/{/ end=/}/ contains=CONTAINED keepend
syntax region vdVerb start=/^    v/ end=/ / contains=CONTAINED keepend
syntax region vdWord start=/^Word:/ end=/$/ contains=CONTAINED keepend

highlight link vdAdjective Type
highlight link vdAdverb Type
highlight link vdAntonyms Keyword
highlight link vdDefitionNumber Number
highlight link vdNoun Type
highlight link vdQuote String
highlight link vdSeparator Operator
highlight link vdSynonym Special
highlight link vdSynonyms Keyword
highlight link vdVerb Type
highlight link vdWordHead Label

highlight vdWord term=bold cterm=bold gui=bold

let b:current_syntax = "victionary"

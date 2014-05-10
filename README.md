# Victionary

An easy to use dict client for Vim.

![img](https://camo.githubusercontent.com/16abd39a97eedd2a195348d72e4d7dd34a5bf836/687474703a2f2f692e696d6775722e636f6d2f4c47697365444b2e676966)

# Installation

For easy installation, I highly suggest that you install a plugin manager (ie. Pathogen/Vundle/NeoBundle)

* [Pathogen][1]
	* `git clone https://github.com/farconics/victionary ~/.vim/bundle/victionary`

# Usage

The hotkey for triggering the plugin is:

	<Leader>d

If you'd like to change the custom mapping, add this to your .vimrc:

	let g:victionary_mapping = 0
	nnoremap <mapping> :call <SID>WordPrompt()<CR>

Looking up a word will open a horizontal split at the bottom, simply press q
to close the window.

[1]: https://github.com/tpope/vim-pathogen

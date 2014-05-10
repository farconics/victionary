# Victionary

An easy to use dict client for Vim.

![img](https://github.com/farconics/victionary/wiki/images/demo.gif)

# Requirements

* `Vim compiled w/ Ruby 1.9.2 or greater`

# Installation

For easy installation, I highly suggest that you install a plugin manager (ie. Pathogen/Vundle/NeoBundle)

* [Pathogen][1]
	* `git clone https://github.com/farconics/victionary ~/.vim/bundle/victionary`

# Configuration

The plugin works out of the box, using 'dict.org' as the host and WordNet as dictionary.
I will try to add the option to specify a host and dictionary in the future.

# Usage

The hotkey for triggering the plugin is:

	<Leader>d

If you'd like to change the custom mapping, add this to your .vimrc:

	let g:victionary_mapping = 0
	nnoremap <mapping> :call <SID>WordPrompt()<CR>

Looking up a word will open a horizontal split at the bottom, simply press q
to close the window.

[1]: https://github.com/tpope/vim-pathogen

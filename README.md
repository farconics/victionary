# Victionary

An easy to use dict client for Vim.

![img](https://github.com/farconics/victionary/wiki/images/demo.gif)

# Requirements

* `Vim compiled w/ Ruby 1.9.2 or greater`

# Installation

For easy installation, I highly suggest that you install a plugin manager (ie. Pathogen/Vundle/NeoBundle)

* Vim 8 Native Package Manager
```bash
mkdir ~/.vim/pack/plugin/start/victionary
git clone https://github.com/farconics/victionary ~/.vim/pack/plugin/start/victionary
```

* [Pathogen][1]
```bash
git clone https://github.com/farconics/victionary ~/.vim/bundle/victionary
```
* [Vim-Plug][2]

1. Add `Plug 'farconics/victionary'` to your `.vimrc` file.
2. Reload your `.vimrc`.
3. Run `:PlugInstall`

* [Vundle][3]

1. Add `Plugin 'farconics/victionary'` to your `.vimrc` file.
2. Reload your `.vimrc`.
3. Run `:BundleInstall`

* [NeoBundle][4]

1. Add `NeoBundle 'farconics/victionary'` to your `.vimrc` file.
2. Reload your `.vimrc`.
3. Run `:NeoUpdate`


# Configuration

The plugin works out of the box, using 'dict.org' as the host and WordNet as
the dictionary. I will try to add the option to specify a host.

### Changing Dictionary

You can chance which dictionary to use with `g:victionary#dictionary`. There
are currently 2 options, which you can set in your `.vimrc`:

```vim
" Use WordNet
let g:victionary#dictionary = g:victionary#WORD_NET

" Use the Collaborative International Dictionary of English
let g:victionary#dictionary = g:victionary#GCIDE
```

# Usage

### Mappings

`<Plug>(victionary#define_prompt)`
* Prompts the user for a word to define

`<Plug>(victionary#define_under_cursor)`
* Defines the word currently under the cursor

`<Plug>(victionary#synonym_prompt)`
* Prompts the user for a word to get synonyms

`<Plug>(victionary#synonym_under_cursor)`
* Get synonym the word currently under the cursor

By default, the hotkeys for triggering each mapping are:

|    Hotkey   |                 Mapping                   |
|:-----------:|:-----------------------------------------:|
| `<Leader>d` | `<Plug>(victionary#define_prompt)`        |
| `<Leader>D` | `<Plug>(victionary#define_under_cursor)`  |
| `<Leader>s` | `<Plug>(victionary#synonym_prompt)`       |
| `<Leader>S` | `<Plug>(victionary#synonym_under_cursor)` |

If you'd like to disable the default mappings, add this to your `.vimrc`:

```vim
let g:victionary#map_defaults = 0
```

If you'd like to customize the mappings, add this to your `.vimrc`:

```vim
let g:victionary#map_defaults = 0
nmap <mapping> <Plug>(victionary#define_prompt)
nmap <mapping> <Plug>(victionary#define_under_cursor)
nmap <mapping> <Plug>(victionary#synonym_prompt)
nmap <mapping> <Plug>(victionary#synonym_under_cursor)
```

### Commands

`:VictionaryDefine`
* Takes a word as a parameter to define
`:VictionarySynonym`
* Takes a word as a parameter to get synonyms


Looking up a word will open a horizontal split at the bottom, simply press q
to close the window.

# Examples

![img](https://github.com/farconics/victionary/wiki/images/demo2.gif)

[1]: https://github.com/tpope/vim-pathogen
[2]: https://github.com/junegunn/vim-plug
[3]: https://github.com/VundleVim/Vundle.vim
[4]: https://github.com/Shougo/neobundle.vim

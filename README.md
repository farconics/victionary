# Victionary

An easy to use dict client for Vim.

![img](https://github.com/farconics/victionary/wiki/images/demo.gif)

## Table of Contents

<details>
<summary>Click here to show.</summary>

1. [Requirements](#requirements)
2. [Installation](#installation)
3. [Configuration](#configuration)
    - [Changing Dictionary](#changing-dictionary)
4. [Usage](#usage)
    - [Mappings](#mappings)
    - [Commands](#commands)
    - [Variables](#variables)
5. [Examples](#examples)

</details>

## Requirements

* `Vim compiled w/ Ruby 1.9.2 or greater`

## Installation

For easy installation, I highly suggest that you install a plugin manager (ie.
Pathogen/Vundle/NeoBundle)

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


## Configuration

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

## Usage

You can read the help docs for this plugin at any time with:

```vim
:help victionary
```

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

### Variables

`g:victionary#format_results`

Type: `Number`

Default: `1`

If this variable is set to a non-zero value, then the results are formatted to
remove visual clutter. This includes disabling 'number', `relativenumber`,
`listchars`, and `colorcolumn`, while enabling `cursorline` for visual
distinction. If you like to have the results window to be unaltered, add the
following to your `.vimrc`:
```vim
let g:victionary#format_results = 0
```

`g:victionary#visible_results`

Type: `Number`

Default: `1`

This sets the maximum number of results immediately visible when a word's
definition is searched for. The results window resizes to match the number of
results set to be visible.

For example, for the definition results of the word "number", if
`g:victionary#visible_results` is set to `1`, then the results would resize to
fit only the first definition:

```
Word:number
    n 1: the property possessed by a sum or total or indefinite
         quantity of units or individuals; "he had a number of
         chores to do"; "the number of parameters is small"; "the
         figure was about a thousand" [syn: {number}, {figure}]
```

If set to `3`, the window would resize to fit the first three definitions,
which would take up more space:

```
Word:number
    n 1: the property possessed by a sum or total or indefinite
         quantity of units or individuals; "he had a number of
         chores to do"; "the number of parameters is small"; "the
         figure was about a thousand" [syn: {number}, {figure}]
    2: a concept of quantity involving zero and units; "every number
       has a unique position in the sequence"
    3: a short theatrical performance that is part of a longer
       program; "he did his act three times every evening"; "she had
       a catchy little routine"; "it was one of the best numbers he
       ever did" [syn: {act}, {routine}, {number}, {turn}, {bit}]
```

In all cases, the user can still scroll down to see more definitions, but the
window will maintain its initial size.

## Examples

![img](https://github.com/farconics/victionary/wiki/images/demo2.gif)

[1]: https://github.com/tpope/vim-pathogen
[2]: https://github.com/junegunn/vim-plug
[3]: https://github.com/VundleVim/Vundle.vim
[4]: https://github.com/Shougo/neobundle.vim

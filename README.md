# tidal.nvim

tidal.nvim is (another) Neovim plugin for livecoding with [TidalCycles](https://tidalcycles.org)

## Features

- User commands to start/stop ghci and (optionally) SuperCollider processes in Neovim's built in terminal (see [boot](#boot))

- Send commands to the tidal interpreter using built-in [keymaps](#keymaps)

- Write your own keymaps and functions using lua functions exported as part of the tidal.nvim [api](#api)

- Apply haskell syntax highlighting to .tidal files

## Installation

Install the plugin with your preferred package manager:

eg [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua

return { 'grddavies/tidal.nvim',
opts = {
    -- Your configuration here
    -- See configuration section for defaults
  }
}
```

## Configuration

```lua
{
  --- Configure TidalLaunch command
  boot = {
    tidal = {
      --- Command to launch ghci with tidal installation
      cmd = "ghci",
      args = {
        "-v0",
      },
      --- Tidal boot file path
      file = vim.api.nvim_get_runtime_file("bootfiles/BootTidal.hs", false)[1],
      enabled = true,
    },
    sclang = {
      --- Command to launch SuperCollider
      cmd = "sclang",
      args = {},
      --- SuperCollider boot file
      file = vim.api.nvim_get_runtime_file("bootfiles/BootSuperDirt.scd", false)[1],
      enabled = false,
    },
    split = "v",
  },
  --- Default keymaps
  --- Set to false to disable all default mappings
  --- @type table | nil
  mappings = {
    send_line = { mode = { "i", "n" }, key = "<S-CR>" },
    send_visual = { mode = { "x" }, key = "<S-CR>" },
    send_block = { mode = { "i", "n", "x" }, key = "<M-CR>" },
    send_node = { mode = "n", key = "<leader><CR>" },
    send_silence = { mode = "n", key = "<leader>d" },
    send_hush = { mode = "n", key = "<leader><Esc>" },
  },
  ---- Configure highlight applied to selections sent to tidal interpreter
  selection_highlight = {
    --- Can be either the name of a highlight group or a highlight definition table
    --- see ':h nvim_set_hl' for details
    highlight = "IncSearch",
    --- Duration to apply the highlight for
    timeout = 150,
  },
}
```

## Usage

### Boot

`tidal.nvim` provides a pair of `Ex` commands,
`:TidalLaunch` and `:TidalQuit`,
which start and stop TidalCycles processes.
By default, only a session of `ghci` running the `BootTidal.hs` script provided by this plugin is run.

If `boot.sclang.enabled` is `true`, then a session of `sclang` is run.
Please ensure that the command `sclang` correctly starts an instance of SuperCollider when executed in the terminal.
By default on macOS, this appears to require something like the following
shell script saved as `sclang` someplace in your path.

```sh
#!/bin/sh
cd /Applications/SuperCollider.app/Contents/MacOS
./sclang "$@"
```

### Keymaps

`tidal.nvim` provides five configurable keymaps in `.tidal` files,
which are used to send chunks of TidalCycles code from the file to the Tidal interpreter:

- `send_line` sends the current line

- `send_line` sends a contiguous block of nonempty lines

- `send_node` sends the expression under the cursor

- `send_visual` sends the current visual selection

- `send_silence` accepts a count (see :h count) sends `d<count> silence` to tidal, silencing the pattern. By default, with no count, d1 is silenced.

- `hush` sends "hush"

### API

`tidal.nvim` also exposes some useful functions to roll your own keymaps or Ex functions

```lua
-- A daft example of using the tidal.nvim api to make noise
vim.api.nvim_create_user_command("InstantGabber", function()
  local tidal = require("tidal")
  --- Send a message to tidal
  tidal.api.send("setcps (200/60/4)")
  --- Send a multiline message to tidal
  local drums = {
    "d1 $ stack [",
    's "gabba*4" # speed 0.78,',
    's "<[~ sd:2]*4!3 [sd*4 [~ sd]!3]>",',
    's "~ hh:2*4"]',
  }
  tidal.api.send_multiline(drums)
  tidal.api.send('d2 $ "amencutup*8" # irand 32 # crush 4 # speed (5/4)')
  tidal.api.send('d3 $ s "rave" + speed "[3 2 3 2] [4 3 4 2]" # end (slow 2 (tri * 0.7))')
end, { desc = "Make gabber happen fast" })
```

see [api.lua](lua/tidal/api.lua) for the full list

## Requirements

### TidalCycles

See the [tidal website for full details](https://tidalcycles.org/docs/getting-started/linux_install)

- ghc installation with tidal installed

- SuperCollider with SuperDirt

### NeoVim

To use the `send_node` mapping, which is based on [treesitter](https://github.com/nvim-treesitter/nvim-treesitter), you must have the treesitter parser for `haskell` installed.

## Contributing

Contributions to the Neovim Tidalcycles Plugin are welcome! If you have ideas, bug fixes, or enhancements, please submit them as issues or pull requests

## Acknowledgements

- [vim.tidal](https://github.com/tidalcycles/vim-tidal)

- [vscode-tidalcycles](https://github.com/tidalcycles/vscode-tidalcycles)

- [iron.nvim](https://github.com/Vigemus/iron.nvim)

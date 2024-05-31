local config = require("tidal.config")
local notify = require("tidal.util.notify")
local api = require("tidal.api")

local Tidal = {}

local keymaps = {
  send_line = { callback = api.send_line, desc = "Send current line to tidal" },
  send_visual = {
    callback = [[<Esc><Cmd>lua require("tidal").api.send_visual()<CR>gv]],
    desc = "Send current visual selection to tidal",
  },
  send_block = { callback = api.send_block, desc = "Send current block to tidal" },
  send_node = { callback = api.send_node, desc = "Send current TS node to tidal" },
  send_silence = { callback = api.send_silence, desc = "Send 'd{count} silence' to tidal" },
  send_hush = {
    callback = function()
      api.send("hush")
    end,
    desc = "Send 'hush' to tidal",
  },
}

local function setup_user_commands()
  vim.api.nvim_create_user_command("TidalLaunch", function()
    api.launch_tidal(config.options.boot)
  end, { desc = "Launch Tidal instance" })
  vim.api.nvim_create_user_command("TidalQuit", api.exit_tidal, { desc = "Quit Tidal instance" })
end

local function setup_autocmds()
  vim.api.nvim_create_augroup("Tidal", { clear = true })
  vim.api.nvim_create_autocmd({ "BufEnter", "BufWinEnter" }, {
    group = "Tidal",
    pattern = { "*.tidal" },
    callback = function()
      vim.api.nvim_buf_set_option(0, "filetype", "tidal")
      for name, mapping in pairs(config.options.mappings or {}) do
        if mapping then
          local command = keymaps[name]
          vim.keymap.set(mapping.mode, mapping.key, command.callback, { buffer = true, desc = command.desc })
        end
      end
    end,
  })
end

---Configure Tidal plugin
---@param options TidalConfig | nil
function Tidal.setup(options)
  vim.treesitter.language.register("haskell", { "tidal" })
  -- TODO: Check version support
  if vim.fn.has("nvim-0.8.0") == 0 then
    notify.error("Tidal requires nvim >= 0.8.0")
    return
  end

  config.setup(options)
  setup_autocmds()
  setup_user_commands()
end

Tidal.api = api

return Tidal

---@class Process
---@field private _running boolean process has is running
---@field cmd string command
---@field args table<string> arguments

local Process = {}
Process.__index = Process

---@class ProcessOpts
---@field on_exit fun(code: number, signal: number)?
---@field on_stdout fun(data: string)?
---@field on_stderr fun(data: string)?

--- Create a new Process instance
---@param cmd string
---@param args? table<string>
---@param opts? ProcessOpts
function Process.new(cmd, args, opts)
  local self = setmetatable({}, Process)

  self.cmd = cmd
  self.args = args or {}
  self.opts = opts or {}
  self._running = false
  return self
end

function Process:start()
  local uv = vim.uv

  self.stdin = uv.new_pipe(false)
  self.stdout = uv.new_pipe(false)
  self.stderr = uv.new_pipe(false)

  local handle, pid
  handle, pid = uv.spawn(
    self.cmd,
    {
      args = self.args,
      stdio = { self.stdin, self.stdout, self.stderr },
    },
    -- On exit callback
    function(code, signal)
      vim.schedule(function()
        self.opts.on_exit()
        -- Clean up
        uv.close(self.stdin)
        uv.close(self.stdout)
        uv.close(self.stderr)
        uv.close(handle)
        self._running = false
      end)
    end
  )

  if not handle then
    error("Failed to start process: " .. self.cmd)
    return false
  end

  self.handle = handle
  self.pid = pid
  self._running = true

  uv.read_start(
    self.stdout,
    vim.schedule_wrap(function(err, data)
      if err then
        error("stdout error: " .. err)
        return
      end
      if self.opts.on_stdout then
        vim.schedule(function()
          self.opts.on_stdout(data)
        end)
      end
    end)
  )

  uv.read_start(
    self.stderr,
    vim.schedule_wrap(function(err, data)
      if err then
        error("stderr error: " .. err)
        return
      end
      if self.opts.on_stderr then
        vim.schedule(function()
          self.opts.on_stderr(data)
        end)
      end
    end)
  )
end

function Process:stop()
  if self.handle then
    vim.uv.process_kill(self.handle, "SIGTERM")
  end
end

function Process.kill_all()
  local processes = vim.tbl_extend("keep", {}, Process.active_processes)

  -- Kill processes in reverse order
  for i = #processes, 1, -1 do
    local proc = processes[i]
    if proc and proc.handle then
      pcall(function()
        proc:stop()
      end)
    end
  end
end

-- Set up the VimLeavePre autocmd to kill all processes on exit
vim.api.nvim_create_autocmd("VimLeavePre", {
  group = vim.api.nvim_create_augroup("ProcessCleanup", { clear = true }),
  callback = function()
    Process.kill_all()
  end,
  desc = "Kill all tidal.nvim managed Processes before Neovim exits",
})

return Process

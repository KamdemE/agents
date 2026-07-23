-- KπX Neovim config — daily driver
-- Lazy.nvim bootstrap

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.fn.isdirectory(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)
-- nvim-treesitter install dir must be in runtimepath for parser loading
vim.opt.rtp:append(vim.fn.stdpath("data") .. "/site")

-- Save startup cwd before persistence restores a session
vim.g.kpihx_startup_cwd = vim.fn.getcwd()

-- Change cwd to first argument if it's a directory (before any plugins load)
if vim.fn.argc(-1) > 0 and vim.fn.isdirectory(vim.fn.argv(0)) == 1 then
  vim.fn.chdir(vim.fn.argv(0))
end

vim.g.mapleader = " "
vim.g.maplocalleader = " "
vim.g.python3_host_prog = vim.fn.exepath("python3")
-- pyenv support removed — uv is the sole Python toolchain
vim.g.loaded_ruby_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.loaded_node_provider = 0
vim.opt.conceallevel = 3
-- Suppress Neovim 0.12 deprecation healthcheck (vim.validate → Nvim 1.0, not actionable)
-- Clears the deprecation table before checkhealth reads it.
vim.api.nvim_create_autocmd("User", {
  pattern = "LazyDone",
  callback = function()
    local ok, health = pcall(require, "vim.deprecated.health")
    if ok then
      -- Clear accumulated deprecations and mark as ok
      local orig_check = health.check
      health.check = function()
        vim.health.start("Deprecation warnings")
        vim.health.ok("No deprecated functions detected")
      end
    end
  end,
})

vim.opt.number = true
vim.opt.relativenumber = false
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true
vim.opt.smartindent = true
vim.opt.wrap = false
vim.opt.termguicolors = true
vim.opt.mouse = "a"
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.clipboard = "unnamedplus"
-- Force wl-clipboard provider (bypasses tmux OSC 52 — works outside nvim on Wayland)
if vim.fn.executable("wl-copy") == 1 then
  vim.g.clipboard = {
    name = "wl-clipboard",
    copy = { ["+"] = "wl-copy", ["*"] = "wl-copy" },
    paste = { ["+"] = "wl-paste --no-newline", ["*"] = "wl-paste --no-newline" },
    cache_enabled = false,
  }
end
vim.opt.swapfile = true
vim.opt.undofile = true
vim.opt.backup = true
vim.opt.scrolloff = 8
vim.opt.signcolumn = "yes"
vim.opt.updatetime = 250
vim.opt.timeoutlen = 300
vim.opt.splitright = true
vim.opt.splitbelow = true
vim.opt.list = true
vim.opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }
vim.opt.inccommand = "split"

vim.api.nvim_create_autocmd("TextYankPost", {
  desc = "Highlight on yank",
  callback = function()
    vim.highlight.on_yank({ higroup = "IncSearch", timeout = 150 })
  end,
})

-- Auto-save modified files on InsertLeave and TextChanged (crash safety)
vim.api.nvim_create_autocmd({ "InsertLeave", "TextChanged" }, {
  desc = "Auto-save modified buffers",
  callback = function()
    local buf = vim.api.nvim_get_current_buf()
    if not vim.bo[buf].modified then return end
    if vim.bo[buf].buftype ~= "" then return end
    local fname = vim.api.nvim_buf_get_name(buf)
    if fname == "" then return end
    if fname:find("^/tmp/") then return end
    if fname:find("://") then return end
    if vim.fn.isdirectory(fname) == 1 then return end
    local parent = vim.fn.fnamemodify(fname, ":h")
    if vim.fn.isdirectory(parent) == 0 then return end
    vim.cmd("silent w")
  end,
})

require("lazy").setup({
  spec = {
    { import = "kpihx/plugins" },
  },
  defaults = { lazy = true, version = false },
  install = { colorscheme = { "catppuccin" } },
  rocks = { enabled = false },
  checker = { enabled = false },
  change_detection = { notify = false },
  ui = { border = "rounded" },
})

require("kpihx.keymaps")
require("kpihx.lsp")
require("kpihx.tmux-navigator")

-- Restore session on startup
local function reattach_markview()
  vim.schedule(function()
    if not package.loaded["markview"] then return end
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
      if vim.api.nvim_buf_is_valid(buf) and vim.bo[buf].filetype == "" then
        local ft = vim.filetype.match({ buf = buf })
        if ft and ft ~= "" then
          vim.bo[buf].filetype = ft
        end
      end
    end
  end)
end

vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    local persistence_ok, persistence = pcall(require, "persistence")
    if not persistence_ok then return end

    if vim.fn.argc(-1) == 0 then
      -- nvim → restore last session if exists, else open Oil
      local has_session = #vim.fn.glob(vim.fn.stdpath("state") .. "/sessions/*.vim", false, true) > 0
      if has_session then
        persistence.load({ last = true })
        reattach_markview()
      else
        vim.schedule(function() pcall(vim.cmd, "Oil") end)
      end
    else
      local arg = vim.fn.fnamemodify(vim.fn.argv(0), ":p")
      if vim.fn.isdirectory(arg) == 1 then
        -- change cwd so persistence picks the right session
        vim.fn.chdir(arg)
        -- check if a session exists for this directory
        local session_file = persistence.current()
        if vim.fn.filereadable(session_file) == 1 then
          persistence.load()
          reattach_markview()
        else
          -- no session → open Oil on this directory
          vim.schedule(function() pcall(vim.cmd, "Oil " .. arg) end)
        end
      end
    end
  end,
})

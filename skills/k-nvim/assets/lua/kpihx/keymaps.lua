-- KπX custom keymaps

-- Editor binary — change this one constant to switch forks (cursor, agy, etc.)
local CODE = "code"

local opt = { noremap = true, silent = true }

vim.keymap.set("n", "<leader>w", "<C-w>", opt) -- Window commands

vim.keymap.set("n", "<Esc>", "<CMD>nohlsearch<CR>", { desc = "Clear search highlight" })

vim.keymap.set("n", "j", "gj", opt)
vim.keymap.set("n", "k", "gk", opt)

vim.keymap.set("n", "<leader>q", "<CMD>q<CR>", { desc = "Close window" })
vim.keymap.set("n", "<leader>Q", "<CMD>qa<CR>", { desc = "Close all" })
vim.keymap.set("n", "<leader>wq", "<CMD>wq<CR>", { desc = "Save and close" })

vim.keymap.set("n", "<leader>pv", vim.cmd.Ex, { desc = "Explorer" })

vim.keymap.set("n", "<leader>sv", "<C-w>v", { desc = "Split vertical" })
vim.keymap.set("n", "<leader>sh", "<C-w>s", { desc = "Split horizontal" })
vim.keymap.set("n", "<leader>se", "<C-w>=", { desc = "Equal splits" })
vim.keymap.set("n", "<leader>sx", "<CMD>close<CR>", { desc = "Close split" })

vim.keymap.set("n", "<leader>tn", "<CMD>tabnew<CR>", { desc = "New tab" })
vim.keymap.set("n", "<leader>to", "<CMD>tabonly<CR>", { desc = "Close other tabs" })
vim.keymap.set("n", "<leader>tc", "<CMD>tabclose<CR>", { desc = "Close tab" })
vim.keymap.set("n", "<leader>tf", "<CMD>tabfirst<CR>", { desc = "First tab" })
vim.keymap.set("n", "<leader>tl", "<CMD>tablast<CR>", { desc = "Last tab" })

vim.keymap.set("n", "<leader>u", vim.cmd.UndotreeToggle, { desc = "Undo tree" })

vim.keymap.set("x", "<leader>p", '"_dP', { desc = "Paste without yanked deleting" })

-- Open file with system app using gtk-launch (reliable on GNOME/Wayland)
local function open_with_system(path)
  local mime = vim.fn.trim(vim.fn.system({ "file", "--mime-type", "-b", path }))
  if mime == "" then return vim.ui.open(path) end
  local handler = vim.fn.trim(vim.fn.system({ "xdg-mime", "query", "default", mime }))
  if handler == "" then return vim.ui.open(path) end
  vim.fn.jobstart({ "gtk-launch", handler, path }, { detach = true })
end

local function gx_open()
  local word = vim.fn.expand("<cWORD>")
  if word == "" then word = vim.fn.expand("<cfile>") end
  if word ~= "" then
    local path = vim.fn.fnamemodify(word, ":p")
    if vim.fn.filereadable(path) == 1 or vim.fn.isdirectory(path) == 1 then
      return open_with_system(path)
    end
    local bufdir = vim.fn.expand("%:p:h")
    if bufdir ~= "" then
      path = vim.fn.fnamemodify(bufdir .. "/" .. word, ":p")
      if vim.fn.filereadable(path) == 1 or vim.fn.isdirectory(path) == 1 then
        return open_with_system(path)
      end
    end
  end
  local cur = vim.fn.expand("%:p")
  if cur ~= "" and vim.fn.filereadable(cur) == 1 then
    return open_with_system(cur)
  end
  vim.notify("Nothing to open: place cursor on a file path", vim.log.levels.WARN)
end

vim.keymap.set("n", "gx", gx_open, { desc = "Open file/URL with system app" })
vim.keymap.set("n", "<leader>gx", gx_open, { desc = "Open file/URL with system app" })

-- gX: open current DIRECTORY with system app (same as gC but with system handler)
local function gX_open()
  local path = nil
  local ok, oil = pcall(require, "oil")
  if ok then
    local dir = oil.get_current_dir()
    if dir then path = dir end
  end
  if not path then
    local file = vim.fn.expand("%:p")
    if file ~= "" then path = vim.fn.fnamemodify(file, ":h") end
  end
  if not path or path == "" then
    vim.notify("No directory to open", vim.log.levels.WARN)
    return
  end
  open_with_system(path)
end

vim.keymap.set("n", "gX", gX_open, { desc = "Open directory with system app" })

-- gc: open current FILE in VS Code (goto position only for real files)
local function gc_open()
  local file = nil
  local from_oil = false
  -- In Oil: open the file under cursor (no goto — cursor line is meaningless)
  local ok, oil = pcall(require, "oil")
  if ok then
    local entry = oil.get_cursor_entry()
    if entry then
      local dir = oil.get_current_dir()
      if dir and entry.name then
        file = dir .. entry.name
        from_oil = true
      end
    end
  end
  -- Fallback: current buffer file (with goto)
  if not file then
    local buf = vim.fn.expand("%:p")
    if buf ~= "" and vim.fn.isdirectory(buf) == 0 then
      file = buf
    end
  end
  if not file or file == "" then
    vim.notify("No file to open (use gC for directory)", vim.log.levels.WARN)
    return
  end
  if from_oil then
    vim.fn.jobstart({ CODE, file })
  else
    local pos = vim.fn.line(".") .. ":" .. vim.fn.col(".")
    vim.fn.jobstart({ CODE, "--goto", file .. ":" .. pos })
  end
end

-- gC: open current DIRECTORY in VS Code (Oil dir first, then buffer dir)
local function gC_open()
  local path = nil
  local ok, oil = pcall(require, "oil")
  if ok then
    local dir = oil.get_current_dir()
    if dir then path = dir end
  end
  if not path then
    local file = vim.fn.expand("%:p")
    if file ~= "" then path = vim.fn.fnamemodify(file, ":h") end
  end
  if not path or path == "" then
    vim.notify("No directory to open", vim.log.levels.WARN)
    return
  end
  vim.fn.jobstart({ CODE, path })
end

vim.keymap.set("n", "gc", gc_open, { desc = "Open file in VS Code (cursor)" })
vim.keymap.set("n", "gC", gC_open, { desc = "Open directory in VS Code" })
-- Neutralize vim's default gc operator-pending/visual (comment textobject)
-- so our normal-mode gc mapping actually fires
vim.keymap.set("o", "gc", "<nop>", { desc = "Disabled — use gc in normal mode" })
vim.keymap.set("x", "gc", "<nop>", { desc = "Disabled — use gc in normal mode" })

--  Neovim trash — FreeDesktop Trash integration
-- dd/D/cc/C → ~/.local/share/Trash/{files,info}/
-- Visible in: trash-cli, GNOME trash, Ubuntu trash, trash-list, trash-empty

local M = {}

local trash_base = vim.fn.expand("$HOME") .. "/.local/share/Trash"
local trash_files = trash_base .. "/files"
local trash_info = trash_base .. "/info"

vim.fn.mkdir(trash_files, "p")
vim.fn.mkdir(trash_info, "p")

local entry_counter = 0

local function unique_name()
  entry_counter = entry_counter + 1
  return string.format(
    "nvim-dd-%s-%04x",
    os.date("%Y%m%dT%H%M%S"),
    entry_counter % 65536
  )
end

local function create_trash_entry(lines, original_path, operation)
  if not lines or #lines == 0 then return end
  if vim.bo.buftype ~= "" then return end

  local name = unique_name()
  local filepath = trash_files .. "/" .. name
  local infopath = trash_info .. "/" .. name .. ".trashinfo"

  -- Content: the deleted line(s), clean, no headers
  vim.fn.writefile(lines, filepath)

  -- .trashinfo: FreeDesktop Trash Specification
  -- Path uses .nvim-dd/ prefix to distinguish nvim trash entries
  -- and prevent accidental trash-restore collisions
  local info = {
    "[Trash Info]",
    "Path=.nvim-dd" .. (original_path or "/[No Name]"),
    "DeletionDate=" .. os.date("%Y-%m-%dT%H:%M:%S"),
  }
  vim.fn.writefile(info, infopath)
end

function M.setup()

  -- dd: delete line(s) with count support (3dd = delete 3 lines)
  vim.keymap.set("n", "dd", function()
    local count = vim.v.count > 0 and vim.v.count or 1
    local start_line = vim.fn.line(".")
    local end_line = math.min(start_line + count - 1, vim.fn.line("$"))
    local lines = vim.fn.getline(start_line, end_line)
    local filepath = vim.fn.expand("%:p")
    if filepath == "" then filepath = "[No Name]" end
    vim.cmd("normal! " .. count .. "dd")
    create_trash_entry(lines, filepath, "dd")
  end, { desc = "Delete line(s) (trashed)" })

  -- D: delete from cursor to end of line
  vim.keymap.set("n", "D", function()
    local line = vim.fn.getline(".")
    local col = vim.fn.col(".")
    local deleted = (line and col <= #line) and line:sub(col) or ""
    local filepath = vim.fn.expand("%:p")
    if filepath == "" then filepath = "[No Name]" end
    vim.cmd("normal! D")
    if deleted ~= "" then
      create_trash_entry({ deleted }, filepath, "D")
    end
  end, { desc = "Delete to end of line (trashed)" })

  -- cc: change line (delete line + enter insert mode)
  vim.keymap.set("n", "cc", function()
    local line = vim.fn.getline(".")
    local filepath = vim.fn.expand("%:p")
    if filepath == "" then filepath = "[No Name]" end
    vim.cmd("normal! cc")
    if line ~= "" then
      create_trash_entry({ line }, filepath, "cc")
    end
  end, { desc = "Change line (trashed)" })

  -- C: change to end of line (delete to end + enter insert mode)
  vim.keymap.set("n", "C", function()
    local line = vim.fn.getline(".")
    local col = vim.fn.col(".")
    local deleted = (line and col <= #line) and line:sub(col) or ""
    local filepath = vim.fn.expand("%:p")
    if filepath == "" then filepath = "[No Name]" end
    vim.cmd("normal! C")
    if deleted ~= "" then
      create_trash_entry({ deleted }, filepath, "C")
    end
  end, { desc = "Change to end of line (trashed)" })

end

return M

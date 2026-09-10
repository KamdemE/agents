--  Neovim plugins

local ignore = {
  ".git/", ".cache/", ".local/", ".npm-global/",
  "node_modules/", "__pycache__/", ".venv/", ".env/",
  "waydroid/",
  ".nvm/", ".cargo/", ".rustup/",
  "go/pkg/", ".dotnet/", ".java/",
  ".vscode/", ".idea/", ".windsurf/", ".cursor/",
  ".cursor-server/", ".vscode-server/", ".vscode-shared/",
  ".docker/", ".android/", ".zoom/",
  "target/", "build/", "dist/", ".next/",
  ".terraform/", ".pytest_cache/", ".mypy_cache/",
  ".ruff_cache/", ".mozilla/", ".var/",
  ".bun/", ".npm/", ".bw/",
  ".claude/", ".cline/", ".codeium/", ".codex/",
  ".colab/", ".continue/", ".copilot/",
  ".gemini/", ".k-ai/", ".mistralcode/",
  ".openclaw/", ".qwen/", ".roo/", ".securecoder/",
  ".vibe/", ".flow/", ".sui/",
  ".oh-my-zsh/", ".tmux/",
  ".antigravity/", ".antigravitycli/", ".antigravity-ide/",
  ".snap/", "snap/",
  ".pki/", ".gnupg/",
  ".gnome/", ".ipython/", ".jupyter/",
  ".n8n/", ".gitlab/",
}

-- Manual cwd sync: press <leader>oc to set cwd to Oil's current directory
vim.keymap.set("n", "<leader>oc", function()
  local ok, oil = pcall(require, "oil")
  if not ok then return end
  local dir = oil.get_current_dir()
  if dir then
    vim.fn.chdir(dir)
    print("cwd → " .. dir)
  end
end, { desc = "Oil cwd sync" })

-- === Diff current file with HEAD ===
local diff_current = function()
  vim.cmd("silent write")

  local file = vim.fn.expand("%:p")
  if file == "" then
    vim.notify("No file to diff", vim.log.levels.WARN)
    return
  end

  local git_dir = vim.fn.fnamemodify(file, ":h")
  local relpath = vim.fn.trim(vim.fn.system({
    "git", "-C", git_dir, "ls-files", "--full-name", file
  }))

  if relpath == "" or vim.v.shell_error ~= 0 then
    vim.notify("File not tracked by git", vim.log.levels.WARN)
    return
  end

  local ret = vim.fn.system({
    "git", "-C", git_dir, "diff", "--quiet", "HEAD", "--", relpath
  })
  if vim.v.shell_error == 0 then
    vim.notify("File unchanged since HEAD", vim.log.levels.INFO)
    return
  end

  local orig_win = vim.api.nvim_get_current_win()

  vim.cmd("vertical topleft new")
  local diff_buf = vim.api.nvim_get_current_buf()

  vim.bo[diff_buf].buftype = "nofile"
  vim.bo[diff_buf].bufhidden = "wipe"
  vim.bo[diff_buf].noswapfile = true
  vim.bo[diff_buf].modifiable = true

  vim.fn.setline(1, {})
  vim.cmd("0read !git show HEAD:" .. vim.fn.shellescape(relpath))
  vim.cmd("1delete")
  vim.bo[diff_buf].modified = false
  vim.bo[diff_buf].readonly = true

  pcall(vim.api.nvim_buf_set_name, diff_buf, "[OLD]")

  vim.cmd("diffthis")
  vim.api.nvim_set_current_win(orig_win)
  vim.cmd("diffthis")
end

local close_diff = function()
  vim.cmd("diffoff!")
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    local buf = vim.api.nvim_win_get_buf(win)
    local name = vim.api.nvim_buf_get_name(buf)
    if name:match("^%[OLD%]") then
      vim.api.nvim_win_close(win, true)
    end
  end
end

vim.keymap.set("n", "<leader>do", diff_current, { desc = "Diff current file" })
vim.keymap.set("n", "<leader>dc", close_diff, { desc = "Close diff" })

return {
  -- === Session persistence ===
  -- nvim → restore last session; nvim <dir> → restore dir-specific session
  {
    "folke/persistence.nvim",
    event = "BufReadPre",
    opts = {
      options = { "buffers", "curdir", "tabpages", "winsize", "help", "globals" },
      need = 0,
      branch = false,
      dir = vim.fn.stdpath("state") .. "/sessions/",
    },
    config = function(_, opts)
      require("persistence").setup(opts)
    end,
  },
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    config = function()
      require("catppuccin").setup({
        flavour = "mocha",
        transparent_background = true,
        integrations = {
          telescope = true,
          mason = true,
          neogit = true,
          which_key = true,
          indent_blankline = { enabled = true },
          native_lsp = { enabled = true },
          gitsigns = true,
          treesitter = true,
          lsp_trouble = true,
          lualine = true,
        },
      })
      vim.cmd.colorscheme("catppuccin")
    end,
  },

  -- === Yank/paste history ===
  {
    "gbprod/yanky.nvim",
    event = "VeryLazy",
    config = function()
      require("yanky").setup({
        highlight = { timer = 150 },
        ring = { history_length = 100 },
      })
    end,
  },

  {
    "nvim-tree/nvim-web-devicons",
    lazy = true,
    priority = 100,
  },

  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    config = function()
      require("lualine").setup({
        options = {
          theme = "auto",
          component_separators = "",
          section_separators = "",
        },
        sections = {
          lualine_b = {
            { "filename", path = 1, file_status = true },
          },
        },
      })
    end,
  },

  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    config = function()
      require("which-key").setup({})
    end,
  },

  { "lukas-reineke/indent-blankline.nvim", main = "ibl", opts = {}, event = "VeryLazy" },

  -- === Treesitter ===
  -- nvim-treesitter requires Nvim 0.12+ (since 4916d65)
  {
    "nvim-treesitter/nvim-treesitter",
    lazy = false,
    config = function()
      require("nvim-treesitter.config").setup({
        install_dir = vim.fn.stdpath("data") .. "/site",
        highlight = { enable = true },
      })
    end,
  },

  -- === File navigation ===
  {
    "nvim-telescope/telescope.nvim",
    -- No tag pin: track master for nvim-treesitter 2026 API compat
    -- (ft_to_lang/ts_configs removed upstream; 0.1.8 crashes previews).
    -- Consistent with lazy defaults (version = false).
    dependencies = { "nvim-lua/plenary.nvim" },
    keys = {
      { "<leader>ff", function() require("telescope.builtin").find_files({
        hidden = true,
        follow = true,
        find_command = {
          "fd", "--type", "f", "--hidden", "--follow",
          "--no-ignore-vcs",
          "--exclude", ".git", "--exclude", "node_modules",
          "--exclude", ".cache", "--exclude", ".local",
          "--exclude", ".npm-global", "--exclude", ".npm",
          "--exclude", ".bun", "--exclude", ".bw",
          "--exclude", ".cargo", "--exclude", ".rustup",
           "--exclude", ".nvm",
           "--exclude", ".dotnet", "--exclude", ".java",
           "--exclude", ".vscode", "--exclude", ".cursor",
           "--exclude", ".windsurf", "--exclude", ".idea",
           "--exclude", ".docker", "--exclude", ".android",
          "--exclude", ".zoom", "--exclude", ".var",
          "--exclude", ".mozilla", "--exclude", ".gnome",
          "--exclude", ".gnupg", "--exclude", ".pki",
          "--exclude", ".ssh", "--exclude", ".config",
          "--exclude", ".claude", "--exclude", ".cline",
          "--exclude", ".codex", "--exclude", ".codeium",
          "--exclude", ".colab", "--exclude", ".copilot",
          "--exclude", ".continue", "--exclude", ".gemini",
          "--exclude", ".k-ai", "--exclude", ".mistralcode",
          "--exclude", ".openclaw", "--exclude", ".qwen",
          "--exclude", ".roo", "--exclude", ".securecoder",
          "--exclude", ".vibe", "--exclude", ".flow",
          "--exclude", ".sui", "--exclude", ".oh-my-zsh",
          "--exclude", ".tmux", "--exclude", ".antigravity",
          "--exclude", ".snap",
          "--exclude", "snap", "--exclude", ".ipython",
          "--exclude", ".jupyter", "--exclude", ".n8n",
          "--exclude", ".gitlab",
          "--exclude", "target", "--exclude", "build",
          "--exclude", "dist", "--exclude", ".next",
          "--exclude", ".terraform", "--exclude", ".pytest_cache",
          "--exclude", ".mypy_cache", "--exclude", ".ruff_cache",
          "--exclude", "go/pkg", "--exclude", ".dotnet",
          "--exclude", "node_modules", "--exclude", "__pycache__",
          "--exclude", ".venv", "--exclude", ".env",
          "--exclude", ".cursor-server", "--exclude", ".vscode-server",
          "--exclude", ".vscode-shared",
        },
      }) end, desc = "Find files (incl. hidden)" },
      { "<leader>fF", function() require("telescope.builtin").find_files({
        find_command = {
          "fd", "--type", "f",
          "--no-ignore-vcs",
          "--exclude", ".git", "--exclude", "node_modules",
          "--exclude", ".cache", "--exclude", ".local",
          "--exclude", ".npm-global", "--exclude", ".npm",
          "--exclude", ".bun", "--exclude", ".bw",
          "--exclude", ".cargo", "--exclude", ".rustup",
           "--exclude", ".nvm",
           "--exclude", ".dotnet", "--exclude", ".java",
           "--exclude", ".vscode", "--exclude", ".cursor",
           "--exclude", ".windsurf", "--exclude", ".idea",
           "--exclude", ".docker", "--exclude", ".android",
          "--exclude", ".zoom", "--exclude", ".var",
          "--exclude", ".mozilla", "--exclude", ".gnome",
          "--exclude", ".gnupg", "--exclude", ".pki",
          "--exclude", ".ssh", "--exclude", ".config",
          "--exclude", ".claude", "--exclude", ".cline",
          "--exclude", ".codex", "--exclude", ".codeium",
          "--exclude", ".colab", "--exclude", ".copilot",
          "--exclude", ".continue", "--exclude", ".gemini",
          "--exclude", ".k-ai", "--exclude", ".mistralcode",
          "--exclude", ".openclaw", "--exclude", ".qwen",
          "--exclude", ".roo", "--exclude", ".securecoder",
          "--exclude", ".vibe", "--exclude", ".flow",
          "--exclude", ".sui", "--exclude", ".oh-my-zsh",
          "--exclude", ".tmux", "--exclude", ".antigravity",
          "--exclude", ".snap",
          "--exclude", "snap", "--exclude", ".ipython",
          "--exclude", ".jupyter", "--exclude", ".n8n",
          "--exclude", ".gitlab",
          "--exclude", "target", "--exclude", "build",
          "--exclude", "dist", "--exclude", ".next",
          "--exclude", ".terraform", "--exclude", ".pytest_cache",
          "--exclude", ".mypy_cache", "--exclude", ".ruff_cache",
          "--exclude", "go/pkg", "--exclude", ".dotnet",
          "--exclude", "node_modules", "--exclude", "__pycache__",
          "--exclude", ".venv", "--exclude", ".env",
          "--exclude", ".cursor-server", "--exclude", ".vscode-server",
          "--exclude", ".vscode-shared",
        },
      }) end, desc = "Find files (no hidden)" },
      { "<leader>fg", function() require("telescope.builtin").live_grep({ file_ignore_patterns = ignore }) end, desc = "Live grep" },
      { "<leader>fb", function() require("telescope.builtin").buffers() end, desc = "Buffers" },
      { "<leader>fh", function() require("telescope.builtin").help_tags() end, desc = "Help tags" },
      { "<leader>fs", function() require("telescope.builtin").lsp_document_symbols() end, desc = "Document symbols" },
      { "<leader>fd", function() require("telescope.builtin").diagnostics() end, desc = "Diagnostics" },
      { "<leader>fc", function() require("telescope.builtin").git_commits() end, desc = "Git commits" },
      { "<leader>fo", function()
        require("telescope.builtin").find_files({
          find_command = { "fd", "--type", "d", "--hidden", "--follow", "--no-ignore-vcs",
            "--exclude", ".git", "--exclude", "node_modules",
            "--exclude", ".cache", "--exclude", ".local",
            "--exclude", ".npm-global", "--exclude", ".npm",
            "--exclude", ".bun", "--exclude", ".bw",
            "--exclude", ".cargo", "--exclude", ".rustup",
            "--exclude", ".pyenv", "--exclude", ".nvm",
            "--exclude", ".dotnet", "--exclude", ".java",
            "--exclude", ".vscode", "--exclude", ".cursor",
            "--exclude", ".windsurf", "--exclude", ".idea",
            "--exclude", ".docker", "--exclude", ".android",
            "--exclude", ".zoom", "--exclude", ".var",
            "--exclude", ".mozilla", "--exclude", ".gnome",
            "--exclude", ".gnupg", "--exclude", ".pki",
            "--exclude", ".ssh", "--exclude", ".config",
            "--exclude", ".claude", "--exclude", ".cline",
            "--exclude", ".codex", "--exclude", ".codeium",
            "--exclude", ".colab", "--exclude", ".copilot",
            "--exclude", ".continue", "--exclude", ".gemini",
            "--exclude", ".k-ai", "--exclude", ".mistralcode",
            "--exclude", ".openclaw", "--exclude", ".qwen",
            "--exclude", ".roo", "--exclude", ".securecoder",
            "--exclude", ".vibe", "--exclude", ".flow",
            "--exclude", ".sui", "--exclude", ".oh-my-zsh",
            "--exclude", ".tmux", "--exclude", ".antigravity",
            "--exclude", ".snap",
            "--exclude", "snap", "--exclude", ".ipython",
            "--exclude", ".jupyter", "--exclude", ".n8n",
            "--exclude", ".gitlab",
            "--exclude", "target", "--exclude", "build",
            "--exclude", "dist", "--exclude", ".next",
            "--exclude", ".terraform", "--exclude", ".pytest_cache",
            "--exclude", ".mypy_cache", "--exclude", ".ruff_cache",
            "--exclude", "go/pkg", "--exclude", ".dotnet",
            "--exclude", "node_modules", "--exclude", "__pycache__",
            "--exclude", ".venv", "--exclude", ".env",
            "--exclude", ".cursor-server", "--exclude", ".vscode-server",
            "--exclude", ".vscode-shared",
          },
          attach_mappings = function(_, map)
            map("i", "<CR>", function(prompt_bufnr)
              local entry = require("telescope.actions.state").get_selected_entry()
              require("telescope.actions").close(prompt_bufnr)
              if entry then
                vim.fn.chdir(entry[1])
                vim.cmd("Oil " .. entry[1])
              end
            end)
            return true
          end,
        })
      end, desc = "Find directory" },
    },
    config = function()
      local actions = require("telescope.actions")
      local action_state = require("telescope.actions.state")
      require("telescope").setup({
        defaults = {
          vimgrep_arguments = {
            "rg",
            "--color=never",
            "--no-heading",
            "--with-filename",
            "--line-number",
            "--column",
            "--smart-case",
            "--glob", "!.local/share/waydroid",
          },
          mappings = {
            n = {
              ["<C-d>"] = function(prompt_bufnr)
                local entry = action_state.get_selected_entry()
                if entry then
                  pcall(vim.api.nvim_buf_delete, entry.bufnr, { force = true })
                end
              end,
            },
          },
        },
      })
    end,
  },

  -- === Search & replace ===
  {
    "nvim-pack/nvim-spectre",
    event = "VeryLazy",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      require("spectre").setup()
    end,
    keys = {
      { "<leader>sr", "<cmd>lua require('spectre').open()<cr>", desc = "Spectre search/replace", mode = "n" },
    },
  },

  {
    "stevearc/oil.nvim",
    lazy = false,
    keys = {
      { "<leader>e", function()
        -- 1. If editing a real file, open Oil on its directory
        local buf_dir = vim.fn.expand("%:p:h")
        if buf_dir ~= "" and buf_dir ~= "." and vim.fn.isdirectory(buf_dir) == 1 then
          return require("oil").open(buf_dir)
        end
        -- 2. Use current cwd (respects :cd and :tcd)
        require("oil").open(vim.fn.getcwd())
      end, desc = "File explorer" },
    },
    config = function()
      require("oil").setup({
        default_file_explorer = false,
        delete_to_trash = true,
        columns = { "icon" },
        view_options = {
          show_hidden = true,
          natural_order = true,
        },
        keymaps = {
          [".."] = "actions.parent",
          ["<C-r>"] = "actions.refresh",
          ["<C-s>"] = false,
          ["<M-s>"] = false,
          ["<C-h>"] = false,
          ["<M-h>"] = false,
          ["gx"] = function()
            local entry = require("oil").get_cursor_entry()
            if entry then
              local dir = require("oil").get_current_dir()
              if dir then
                local path = dir .. "/" .. entry.name
                local mime = vim.fn.trim(vim.fn.system({ "file", "--mime-type", "-b", path }))
                local handler = vim.fn.trim(vim.fn.system({ "xdg-mime", "query", "default", mime }))
                if handler ~= "" then
                  vim.fn.jobstart({ "gtk-launch", handler, path }, { detach = true })
                end
              end
            end
          end,
        },
      })
      local oil_group = vim.api.nvim_create_augroup("kpihx_oil_winbar", { clear = true })
      vim.api.nvim_create_user_command("O", function(opts)
        local oil = require("oil")
        local dir = oil.get_current_dir()
        if not dir then return end
        local bufnr = vim.api.nvim_get_current_buf()
        for lnum = opts.line1, opts.line2 do
          pcall(function()
            local entry = oil.get_entry_on_line(bufnr, lnum)
            if entry and entry.type == "file" then
              local path = dir .. "/" .. entry.name
              local mime = vim.fn.trim(vim.fn.system({ "file", "--mime-type", "-b", path }))
              local handler = vim.fn.trim(vim.fn.system({ "xdg-mime", "query", "default", mime }))
              if handler ~= "" then
                vim.fn.jobstart({ "gtk-launch", handler, path }, { detach = true })
              end
            end
          end)
        end
      end, { range = true, nargs = 0 })
      vim.api.nvim_create_autocmd("FileType", {
        group = oil_group,
        pattern = "oil",
        callback = function(args)
          local bufname = vim.api.nvim_buf_get_name(args.buf)
          local dir = bufname:gsub("^oil://", ""):gsub("/$", "")
          local winid = vim.fn.bufwinid(args.buf)
          if winid and winid > 0 then
            vim.wo[winid].winbar = " " .. dir
          end
        end,
      })
    end,
  },

  {
    "ThePrimeagen/harpoon",
    branch = "harpoon2",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      require("harpoon").setup({
        settings = {
          save_on_toggle = true,
          sync_on_ui_close = true,
          key = function()
            return vim.fn.expand("$HOME")
          end,
        },
      })
      -- Sync cwd when Harpoon opens a file via any method (menu or direct keys)
      require("harpoon.extensions").extensions:add_listener({
        SELECT = function(data)
          local item = data.item
          if item and item.value then
            local val = item.value:gsub("^oil://", "")
            local full = vim.fn.fnamemodify(val, ":p")
            full = full:gsub("/$", "")
            local dir = (vim.fn.isdirectory(full) == 1)
                and full
                or vim.fn.fnamemodify(val, ":p:h"):gsub("/$", "")
            pcall(vim.fn.chdir, dir)
          end
        end,
      })
    end,
    keys = {
      { "<leader>ha", function() require("harpoon"):list():add() end, desc = "Harpoon add" },
      { "<leader>hl", function() require("harpoon").ui:toggle_quick_menu(require("harpoon"):list()) end, desc = "Harpoon menu" },
      { "<leader>1", function()
        local l = require("harpoon"):list()
        local item = l:get()[1]
        if item and item.value then
          local val = item.value:gsub("^oil://", "")
          local full = vim.fn.fnamemodify(val, ":p"):gsub("/$", "")
          local dir = (vim.fn.isdirectory(full) == 1)
              and full
              or vim.fn.fnamemodify(val, ":p:h"):gsub("/$", "")
          pcall(vim.fn.chdir, dir)
        end
        l:select(1)
      end, desc = "Harpoon 1" },
      { "<leader>2", function()
        local l = require("harpoon"):list()
        local item = l:get()[2]
        if item and item.value then
          local val = item.value:gsub("^oil://", "")
          local full = vim.fn.fnamemodify(val, ":p"):gsub("/$", "")
          local dir = (vim.fn.isdirectory(full) == 1)
              and full
              or vim.fn.fnamemodify(val, ":p:h"):gsub("/$", "")
          pcall(vim.fn.chdir, dir)
        end
        l:select(2)
      end, desc = "Harpoon 2" },
      { "<leader>3", function()
        local l = require("harpoon"):list()
        local item = l:get()[3]
        if item and item.value then
          local val = item.value:gsub("^oil://", "")
          local full = vim.fn.fnamemodify(val, ":p"):gsub("/$", "")
          local dir = (vim.fn.isdirectory(full) == 1)
              and full
              or vim.fn.fnamemodify(val, ":p:h"):gsub("/$", "")
          pcall(vim.fn.chdir, dir)
        end
        l:select(3)
      end, desc = "Harpoon 3" },
      { "<leader>4", function()
        local l = require("harpoon"):list()
        local item = l:get()[4]
        if item and item.value then
          local val = item.value:gsub("^oil://", "")
          local full = vim.fn.fnamemodify(val, ":p"):gsub("/$", "")
          local dir = (vim.fn.isdirectory(full) == 1)
              and full
              or vim.fn.fnamemodify(val, ":p:h"):gsub("/$", "")
          pcall(vim.fn.chdir, dir)
        end
        l:select(4)
      end, desc = "Harpoon 4" },
    },
  },

  -- === Editing ===
  {
    "numToStr/Comment.nvim",
    event = "VeryLazy",
    config = function()
      require("Comment").setup({
        toggler = { line = "<leader>cc", block = "<leader>bc" },
        opleader = { line = "<leader>c", block = "<leader>b" },
        extra = { eol = "<leader>ca", below = "<leader>co", above = "<leader>cO", left = "<leader>cl", right = "<leader>cr" },
      })
    end,
  },

  {
    "tpope/vim-surround",
    event = "VeryLazy",
  },

  {
    "stevearc/conform.nvim",
    event = "BufWritePre",
    config = function()
      require("conform").setup({
        formatters_by_ft = {
          python = { "ruff_format" },
          javascript = { "prettierd", "prettier" },
          typescript = { "prettierd", "prettier" },
          json = { "prettierd", "prettier" },
          lua = { "stylua" },
          markdown = { "prettierd", "prettier" },
          yaml = { "prettierd", "prettier" },
          sh = { "shfmt" },
        },
        format_on_save = { timeout_ms = 500, lsp_format = "fallback" },
      })
    end,
  },

  {
    "folke/todo-comments.nvim",
    event = "VeryLazy",
    config = function()
      require("todo-comments").setup({})
      vim.keymap.set("n", "<leader>xt", "<CMD>TodoTrouble<CR>", { desc = "Todo comments" })
    end,
  },

  -- === Git ===
  {
    "NeogitOrg/neogit",
    cmd = "Neogit",
    config = function()
      require("neogit").setup({})
      vim.keymap.set("n", "<leader>gs", "<CMD>Neogit<CR>", { desc = "Git status" })
    end,
  },

  {
    "lewis6991/gitsigns.nvim",
    event = "VeryLazy",
    config = function()
      require("gitsigns").setup({
        on_attach = function(bufnr)
          local gs = require("gitsigns")
          vim.keymap.set("n", "<leader>gb", gs.blame_line, { buffer = bufnr, desc = "Git blame" })
        end,
      })
    end,
  },

  {
    "sindrets/diffview.nvim",
    cmd = "DiffviewOpen",
    config = function()
      require("diffview").setup({})

      local View = require("diffview.scene.view")

      function View.View:open()
        self.tabpage = vim.api.nvim_get_current_tabpage()
        vim.cmd("tabedit")
        self.tabpage = vim.api.nvim_get_current_tabpage()
        self:init_layout()
        self:post_open()
        DiffviewGlobal.emitter:emit("view_opened", self)
        DiffviewGlobal.emitter:emit("view_enter", self)
      end

      function View.View:close()
        self.closing:send()
        if self.tabpage and vim.api.nvim_tabpage_is_valid(self.tabpage) then
          DiffviewGlobal.emitter:emit("view_leave", self)
        end
        if vim.fn.tabpagenr("$") > 1 then
          vim.cmd("tabclose")
        end
        DiffviewGlobal.emitter:emit("view_closed", self)
      end

      vim.keymap.set("n", "<leader>do", "<CMD>DiffviewOpen<CR>", { desc = "Diffview open" })
      vim.keymap.set("n", "<leader>dh", "<CMD>DiffviewFileHistory<CR>", { desc = "Diffview file history" })
      vim.keymap.set("n", "<leader>dc", "<CMD>DiffviewClose<CR>", { desc = "Diffview close" })
    end,
  },

  -- === Diagnostics ===
  {
    "folke/trouble.nvim",
    cmd = "Trouble",
    config = function()
      require("trouble").setup({})
      vim.keymap.set("n", "<leader>xx", "<CMD>Trouble diagnostics toggle<CR>", { desc = "Diagnostics" })
      vim.keymap.set("n", "<leader>xw", "<CMD>Trouble diagnostics toggle filter.buf=0<CR>", { desc = "Buffer diagnostics" })
    end,
  },

  -- === Markdown ===
  {
    "OXY2DEV/markview.nvim",
    lazy = false,
    priority = 500,
    config = function()
      require("markview").setup({
        markdown = { enable = true },
        markdown_inline = { enable = true },
        preview = {
          filetypes = { "markdown" },
          ignore_buftypes = { "nofile", "prompt", "oil" },
        },
      })
    end,
  },

  -- === Jupyter ===
  {
    "GCBallesteros/jupytext.nvim",
    lazy = false,
    config = function()
      require("jupytext").setup({
        style = "markdown",
        output_extension = "md",
        force_ft = "markdown",
      })
    end,
  },

  {
    "benlubas/molten-nvim",
    lazy = false,
    build = ":UpdateRemotePlugins",
    init = function()
      vim.g.molten_auto_open_output = true
      vim.g.molten_virt_text_output = true
      vim.g.molten_wrap_output = true
      vim.g.molten_image_provider = "none"
      vim.g.molten_auto_image_popup = false
    end,
    config = function()
      local imb = function(e)
        vim.schedule(function()
          local kernels = vim.fn.MoltenAvailableKernels()
          local try_kernel_name = function()
            local f = io.open(e.file, "r")
            if not f then return nil end
            local content = f:read("a")
            f:close()
            local ok, decoded = pcall(vim.json.decode, content)
            if not ok then return nil end
            return decoded.metadata and decoded.metadata.kernelspec and decoded.metadata.kernelspec.name
          end
          local ok, kernel_name = pcall(try_kernel_name)
          if not ok or not kernel_name or not vim.tbl_contains(kernels, kernel_name) then
            kernel_name = nil
            local venv = os.getenv("VIRTUAL_ENV") or os.getenv("CONDA_PREFIX")
            if venv then
              kernel_name = venv:match("/.+/(.+)")
            end
          end
          if kernel_name and vim.tbl_contains(kernels, kernel_name) then
            vim.cmd(("MoltenInit %s"):format(kernel_name))
          end
          pcall(vim.cmd, "MoltenImportOutput")
        end)
      end

      vim.api.nvim_create_autocmd("BufAdd", {
        pattern = { "*.ipynb" },
        callback = imb,
      })

      vim.api.nvim_create_autocmd("BufEnter", {
        pattern = { "*.ipynb" },
        callback = function(e)
          if vim.v.vim_did_enter ~= 1 then imb(e) end
        end,
      })

      vim.api.nvim_create_autocmd("BufWritePost", {
        pattern = { "*.ipynb" },
        callback = function()
          if require("molten.status").initialized() == "Molten" then
            vim.cmd("MoltenExportOutput!")
          end
        end,
      })

      local default_notebook = [[
        {
          "cells": [{
            "cell_type": "code",
            "metadata": {},
            "source": [""]
          }],
          "metadata": {
            "kernelspec": {
              "display_name": "Python 3",
              "language": "python",
              "name": "python3"
            },
            "language_info": {
              "codemirror_mode": { "name": "ipython", "version": 3 },
              "file_extension": ".py",
              "mimetype": "text/x-python",
              "name": "python",
              "nbconvert_exporter": "python",
              "pygments_lexer": "ipython3",
              "version": "3.12.0"
            }
          },
          "nbformat": 4,
          "nbformat_minor": 5
        }
      ]]

      vim.api.nvim_create_user_command("NewNotebook", function()
        local path = vim.fn.input("Notebook path: ", vim.fn.expand("%:p:h") .. "/notebook.ipynb")
        if path ~= "" then
          local f = io.open(path, "w")
          if f then
            f:write(default_notebook)
            f:close()
            vim.cmd("edit " .. path)
          end
        end
      end, { desc = "Create a new Jupyter notebook" })

      vim.keymap.set("n", "<leader>mr", "<CMD>MoltenEvaluateLine<CR>", { desc = "Run cell" })
      vim.keymap.set("n", "<leader>ml", "<CMD>MoltenReevaluateCell<CR>", { desc = "Reevaluate cell" })
      vim.keymap.set("n", "<leader>mo", "<CMD>MoltenShowOutput<CR>", { desc = "Open output float" })
      vim.keymap.set("n", "<leader>mI", "<CMD>MoltenInit<CR>", { desc = "Init kernel" })
      vim.keymap.set("v", "<leader>mr", ":<C-u>MoltenEvaluateVisual<CR>gv", { desc = "Evaluate visual selection" })
    end,
  },

  -- === LSP & completion ===
  {
    "williamboman/mason.nvim",
    cmd = "Mason",
    build = ":MasonUpdate",
    config = function()
      require("mason").setup()
    end,
  },

  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = { "williamboman/mason.nvim" },
    config = function()
      require("mason-lspconfig").setup({
        ensure_installed = {
          "basedpyright",
          "ruff",
          "lua_ls",
          "typescript-language-server",
          "jsonls",
          "yamlls",
          "marksman",
          "bashls",
          "texlab",
        },
        automatic_installation = true,
        handlers = {
          function(_) end,
        },
      })
    end,
  },

  {
    "hrsh7th/nvim-cmp",
    event = "InsertEnter",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "L3MON4D3/LuaSnip",
      "saadparwaiz1/cmp_luasnip",
    },
    config = function()
      local cmp = require("cmp")
      local luasnip = require("luasnip")
      cmp.setup({
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },
        mapping = cmp.mapping.preset.insert({
          ["<C-b>"] = cmp.mapping.scroll_docs(-4),
          ["<C-f>"] = cmp.mapping.scroll_docs(4),
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<C-e>"] = cmp.mapping.abort(),
          ["<CR>"] = cmp.mapping.confirm({ select = true }),
        }),
        sources = cmp.config.sources({
          { name = "nvim_lsp" },
          { name = "luasnip" },
        }, {
          { name = "buffer" },
          { name = "path" },
        }),
      })
    end,
  },

  -- === Python venv auto-detection ===
  {
    "1A7432/nvim-python-venv",
    event = "VeryLazy",
    config = function()
      require('nvim-python-venv').setup({
        auto_detect = true,
        auto_activate = true,
        auto_restart_lsp = true,
        cache = {
          enabled = true,
          auto_clean = true,
        },
        managers = {
          priority = { 'uv', 'poetry', 'pipenv', 'conda', 'pyenv', 'local_venv' },
        },
        lsp = {
          servers = { 'basedpyright' },
          restart_on_venv_change = true,
        },
        ui = {
          selector = 'auto',
          notify = true,
          statusline = true,
        },
      })
    end,
  },

  -- === TypeScript tools ===
  {
    "pmizio/typescript-tools.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    ft = { "typescript", "typescriptreact", "javascript", "javascriptreact" },
    keys = {
      { "<leader>lr", "<CMD>TSToolsRenameFile<CR>", desc = "Rename file" },
      { "<leader>lR", "<CMD>TSToolsFileReferences<CR>", desc = "File references" },
      { "<leader>lg", "<CMD>TSToolsGoToSourceDefinition<CR>", desc = "Go to source definition" },
    },
    config = function()
      require("typescript-tools").setup({
        settings = {
          separate_diagnostic_server = true,
          publish_diagnostic_on = "insert_leave",
          expose_as_code_action = {},
          tsserver_max_memory = "auto",
          tsserver_format_options = {},
          tsserver_file_preferences = {},
          tsserver_locale = "en",
          complete_function_calls = false,
          include_completions_with_insert_text = true,
          code_lens = "off",
          disable_member_code_lens = true,
          jsx_close_tag = {
            enable = false,
            filetypes = { "javascriptreact", "typescriptreact" },
          },
        },
      })
    end,
  },

  -- === tmux navigation ===
  {
    "christoomey/vim-tmux-navigator",
    cmd = { "TmuxNavigateLeft", "TmuxNavigateDown", "TmuxNavigateUp", "TmuxNavigateRight" },
    keys = {
      { "<C-h>", "<CMD>TmuxNavigateLeft<CR>", desc = "Window left" },
      { "<C-j>", "<CMD>TmuxNavigateDown<CR>", desc = "Window down" },
      { "<C-k>", "<CMD>TmuxNavigateUp<CR>", desc = "Window up" },
      { "<C-l>", "<CMD>TmuxNavigateRight<CR>", desc = "Window right" },
    },
  },

  -- === Git diff ===
  -- Opens HEAD version side-by-side using native nvim diff mode
  -- Uses bufhidden=wipe for automatic cleanup on close
  {
    "nvim-lua/plenary.nvim",
    lazy = true,
  },
}

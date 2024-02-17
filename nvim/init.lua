--------------------------------------------------------------------------------
-- Genernal settings
--------------------------------------------------------------------------------
vim.o.number = true
vim.o.termguicolors = true
-- Case insensitive search
vim.o.ignorecase = true
vim.o.smartcase = true

vim.g.mapleader = " "
-- vim.keymap.set({ "n", "v" }, "<Space>", "<Nop>", { silent = true })

-- General keymapping
local nmap = function(lhs, rhs, desc)
  desc = desc or ""
  vim.keymap.set("n", lhs, rhs, { desc = desc })
end

nmap("<leader>E", function () vim.cmd("Explore") end, "File Explore")
nmap("<leader>e", vim.diagnostic.open_float, "Show float diagnostic")
nmap("[d", vim.diagnostic.goto_prev, "Prev diagnostic")
nmap("]d", vim.diagnostic.goto_next, "Next diagnostic")
nmap("<leader>q", vim.diagnostic.setloclist)

--------------------------------------------------------------------------------
-- UI
--------------------------------------------------------------------------------
local gruvbox = {
  "ellisonleao/gruvbox.nvim",
  lazy = false,
  priority = 1000,
  config = function()
    vim.o.background = "light"
    vim.cmd("colorscheme gruvbox")
  end
}
local lualine = {
  "nvim-lualine/lualine.nvim",
  opts = {
    options = {
      theme = "gruvbox_light",
      icons_enabled = false,
    },
    sections = {
      lualine_c = {
        { "filename", path = 1 },
      }
    },
  },
}
local whichkey = {
  "folke/which-key.nvim",
  event = "VeryLazy",
  init = function()
    vim.o.timeout = true
    vim.o.timeoutlen = 300
  end,
  config = true
}

--------------------------------------------------------------------------------
-- Telescope
--------------------------------------------------------------------------------
local telescope = {
  "nvim-telescope/telescope.nvim",
  tag = "0.1.5",
  dependencies = { "nvim-lua/plenary.nvim" },
  config = function()
    local builtin = require("telescope.builtin")
    nmap("<leader><space>", function()
      builtin.buffers {
        sort_mru = true,
        initial_mode = "normal",
        ignore_current_buffer = true,
        path_display = function(_, path)
          local tail = require("telescope.utils").path_tail(path)
          if tail == path then
            return path
          else
            local head = string.sub(path, 0, string.len(path) - string.len(tail) - 1)
            return string.format("%s (%s)", tail, head)
          end
        end,
      }
    end, "Find buffers")
    nmap("<leader>ff", builtin.find_files, "Find files")
    nmap("<leader>fg", builtin.live_grep, "Live grep")
    nmap("<leader>fh", builtin.help_tags, "Find help")
  end,
}
local fzf = {
  "nvim-telescope/telescope-fzf-native.nvim",
  build = "cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release && cmake --install build --prefix build",
  dependencies = { "nvim-telescope/telescope.nvim" },
  config = function()
    require("telescope").load_extension("fzf")
  end,
}

--------------------------------------------------------------------------------
-- Coding
--------------------------------------------------------------------------------
local tabstop = { "tpope/vim-sleuth" } -- Detect tabstop and shiftwidth automatically
local comment = { "echasnovski/mini.comment", version = "*", config = true }
local fugitive = { "tpope/vim-fugitive" }
local gitsigns = { "lewis6991/gitsigns.nvim", opts = { current_line_blame = true } }

--------------------------------------------------------------------------------
-- LSP & Copilot
--------------------------------------------------------------------------------
local on_attach = function (_, bufnr)
  local lmap = function (keys, func, desc)
    vim.keymap.set("n", keys, func, { buffer = bufnr, desc = desc })
  end

  lmap("K", vim.lsp.buf.hover, "Hover documentation")
  lmap("<C-k>", vim.lsp.buf.signature_help, "Signature help")

  lmap("gd", vim.lsp.buf.definition, "Goto definition")
  lmap("gr", vim.lsp.buf.references, "Goto references")
  lmap("gD", vim.lsp.buf.declaration, "Goto declaration")
  lmap("gi", vim.lsp.buf.implementation, "Goto implementation")

  lmap("<space>D", vim.lsp.buf.type_definition, "Type definition")
  lmap("<space>rn", vim.lsp.buf.rename, "Rename")
  lmap("<space>ca", vim.lsp.buf.code_action, "Code action")
  lmap("<space>f", function()
    vim.lsp.buf.format { async = true }
  end, "Format")
end

local lspconfig = {
  "neovim/nvim-lspconfig",
  dependencies = { "folke/neodev.nvim" },
}
local mason = { "williamboman/mason.nvim", config = true }
local mason_lspconfig = {
  "williamboman/mason-lspconfig.nvim",
  dependencies = {
    "neovim/nvim-lspconfig",
    "williamboman/mason.nvim",
  },
  opts = {
    ensure_installed = {
      "lua_ls",
      "pyright",
      "gopls",
    },
    handlers = {
      -- Default handler
      function(server_name)
        require("lspconfig")[server_name].setup {
          on_attach = on_attach,
        }
      end,
      -- Language specific handlers
      ["lua_ls"] = function()
        require("lspconfig").lua_ls.setup{
          settings = {
            Lua = { diagnostics = { globals = { "vim" } } }
          }
        }
      end,
      ["pyright"] = function()
        local lspcfg = require("lspconfig")
        lspcfg.pyright.setup {
          on_attach = on_attach,
          root_dir = lspcfg.util.root_pattern("pyrightconfig.json"),
          settings = {
            autoSearchPaths = true,
            diagnosticMode = "workspace",
          },
        }
      end,
    },
  },
}
local copilot = {
  "zbirenbaum/copilot.lua",
  opts = {
    suggestion = { enabled = false },
    panel = { enabled = false },
  },
}
-- Autocompletion
local cmp = {
  "hrsh7th/nvim-cmp",
  dependencies = {
    "L3MON4D3/LuaSnip",
    "hrsh7th/cmp-nvim-lsp",
    "zbirenbaum/copilot-cmp",
  },
  config = function ()
    local cmp = require("cmp")
    cmp.setup {
      snippet = {
        expand = function(args)
          require("luasnip").lsp_expand(args.body)
        end,
      },
      mapping = cmp.mapping.preset.insert({
        ["<C-b>"] = cmp.mapping.scroll_docs(-4),
        ["<C-f>"] = cmp.mapping.scroll_docs(4),
        ["<C-Space>"] = cmp.mapping.complete(),
        ["<C-e>"] = cmp.mapping.abort(),
        ["<CR>"] = cmp.mapping.confirm({ select = false }),
      }),
      sources = cmp.config.sources({
        { name = "nvim_lsp" },
        { name = "copilot" },
      })
    }
  end,
}

--------------------------------------------------------------------------------
-- Language specific settings
--------------------------------------------------------------------------------
-- Neovim Lua
local neodev = { "folke/neodev.nvim", config = true }
-- Go
vim.api.nvim_create_autocmd("FileType", {
  pattern = "go",
  callback = function()
    vim.bo.tabstop = 4
  end
})
-- Markdown
local markdown = {
  "iamcco/markdown-preview.nvim",
  cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
  build = "cd app && yarn install",
  init = function()
    vim.g.mkdp_filetypes = { "markdown" }
  end,
  ft = { "markdown" },
}

--------------------------------------------------------------------------------
-- Packages Manager
--------------------------------------------------------------------------------
-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none", "https://github.com/folke/lazy.nvim.git", "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- Load packages
require("lazy").setup {
  -- UI
  gruvbox,
  lualine,
  whichkey,
  -- Telescope
  telescope,
  fzf,
  -- Coding
  tabstop,
  comment,
  fugitive,
  gitsigns,
  -- LSP & Copilot
  lspconfig,
  mason,
  mason_lspconfig,
  copilot,
  cmp,
  -- Language
  neodev,
  markdown,
}

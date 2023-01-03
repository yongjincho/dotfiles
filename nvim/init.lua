-- Packer
local ensure_packer = function()
  local fn = vim.fn
  local install_path = fn.stdpath('data')..'/site/pack/packer/start/packer.nvim'
  if fn.empty(fn.glob(install_path)) > 0 then
    fn.system({'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', install_path})
    vim.cmd [[packadd packer.nvim]]
    return true
  end
  return false
end

local packer_bootstrap = ensure_packer()

require('packer').startup(function(use)
  use 'wbthomason/packer.nvim'

  -- General
  use 'morhetz/gruvbox' -- Colorscheme
  use 'tpope/vim-sleuth' -- Detect tabstop and shiftwidth automatically
  use 'nvim-lualine/lualine.nvim' -- Fancier statusline

  -- Editor
  use 'lukas-reineke/indent-blankline.nvim' -- Add indentation guides even on blank lines
  use 'numToStr/Comment.nvim'

  -- Languages
  use 'fatih/vim-go'

  -- Git
  use 'tpope/vim-fugitive'
  use 'tpope/vim-rhubarb'
  use 'lewis6991/gitsigns.nvim'

  -- Telescope
  use { 'nvim-telescope/telescope.nvim', tag = '0.1.0', requires = { 'nvim-lua/plenary.nvim' } }
  use { 'nvim-telescope/telescope-fzf-native.nvim', run = 'make', cond = vim.fn.executable 'make' == 1 }

  -- LSP
  use { -- LSP Configuration & Plugins
    'neovim/nvim-lspconfig',
    requires = {
      -- Automatically install LSPs to stdpath for neovim
      'williamboman/mason.nvim',
      'williamboman/mason-lspconfig.nvim',

      -- Useful status updates for LSP
      'j-hui/fidget.nvim',
    },
  }

  -- Autocompletion
  use {
    'hrsh7th/nvim-cmp', -- Autocompletion plugin
    requires = {
      'hrsh7th/cmp-nvim-lsp',
      'L3MON4D3/LuaSnip', -- Snippets plugin
      'saadparwaiz1/cmp_luasnip',
    },
  }

  -- Additional lua configuration, makes nvim stuff amazing
  use 'folke/neodev.nvim'

  if packer_bootstrap then
    require('packer').sync()
  end
end)

if packer_bootstrap then
  return
end


-- General options (`:help vim.o`)
vim.o.number = true
vim.o.termguicolors = true
-- Use gruvbox dark theme
vim.cmd [[colorscheme gruvbox]]
vim.o.bg = 'dark'
-- Case insensitive search
vim.o.ignorecase = true
vim.o.smartcase = true


-- General shorcuts
local nmap = function(lhs, rhs, opts)
  opts = opts or {}
  vim.keymap.set('n', lhs, rhs, opts)
end

vim.g.mapleader = ' '
vim.keymap.set({ 'n', 'v' }, '<Space>', '<Nop>', { silent = true })


-- lualine
require('lualine').setup {
  options = {
    icons_enabled = false,
    theme = 'gruvbox_dark',
  },
  sections = {
    lualine_c = {
      { 'filename', path = 1 },
    }
  }
}


-- indent_blankline
vim.opt.list = true
vim.opt.listchars:append "eol:↴"
require('indent_blankline').setup {
  show_end_of_line = true,
  show_trailing_blankline_indent = false,
}


-- Enable Comment.nvim
require('Comment').setup()


-- gitsigns (`:help gitsigns.txt`)
require('gitsigns').setup {
  --current_line_blame = true,
}


-- Telescope
local telescope = require('telescope.builtin')
pcall(require('telescope').load_extension, 'fzf') -- `brew install ripgrep` for live_grep
nmap('<leader><space>', function ()
  telescope.buffers{
    sort_mru = true,
    initial_mode = 'normal',
    path_display = function(_, path)
      local tail = require("telescope.utils").path_tail(path)
      if tail == path then
        return string.format(path)
      else
        local head = string.sub(path, 0, string.len(path)-string.len(tail)-1)
        return string.format("%s (%s)", tail, head)
      end
    end,
  }
end)
nmap('<leader>ff', telescope.find_files)
nmap('<leader>fg', telescope.live_grep)
nmap('<leader>fh', telescope.help_tags)


-- LSP settings.
-- Diagnostic keymaps
nmap('[d', vim.diagnostic.goto_prev)
nmap(']d', vim.diagnostic.goto_next)
nmap('<leader>e', vim.diagnostic.open_float)
nmap('<leader>q', vim.diagnostic.setloclist)

--  This function gets run when an LSP connects to a particular buffer.
local on_attach = function(_, bufnr)
  local lmap = function(keys, func, desc)
    if desc then
      desc = 'LSP: ' .. desc
    end
    vim.keymap.set('n', keys, func, { buffer = bufnr, desc = desc })
  end

  lmap('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')
  lmap('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction')

  lmap('gd', vim.lsp.buf.definition, '[G]oto [D]efinition')
  lmap('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')
  lmap('gr', telescope.lsp_references, '[G]oto [R]eferences')
  lmap('gI', vim.lsp.buf.implementation, '[G]oto [I]mplementation')
  lmap('<leader>D', vim.lsp.buf.type_definition, 'Type [D]efinition')
  lmap('<leader>ds', telescope.lsp_document_symbols, '[D]ocument [S]ymbols')
  lmap('<leader>ws', telescope.lsp_dynamic_workspace_symbols, '[W]orkspace [S]ymbols')

  -- See `:help K` for why this keymap
  lmap('K', vim.lsp.buf.hover, 'Hover Documentation')
  lmap('<C-k>', vim.lsp.buf.signature_help, 'Signature Documentation')

  -- Lesser used LSP functionality
  lmap('<leader>wa', vim.lsp.buf.add_workspace_folder, '[W]orkspace [A]dd Folder')
  lmap('<leader>wr', vim.lsp.buf.remove_workspace_folder, '[W]orkspace [R]emove Folder')
  lmap('<leader>wl', function() print(vim.inspect(vim.lsp.buf.list_workspace_folders())) end, '[W]orkspace [L]ist Folders')

  -- Create a command `:Format` local to the LSP buffer
  vim.api.nvim_buf_create_user_command(bufnr, 'Format', function() vim.lsp.buf.format() end, { desc = 'Format current buffer with LSP' })
end

-- Enable the following language servers
--  Feel free to add/remove any LSPs that you want here. They will automatically be installed.
--
--  Add any additional override configuration in the following tables. They will be passed to
--  the `settings` field of the server config. You must look up that documentation yourself.
local servers = {
  gopls = {},
  pyright = {
    autoSearchPaths = true,
    diagnosticMode = 'workspace',
  },
  tsserver = {},
  -- clangd = {},
  -- rust_analyzer = {},
  sumneko_lua = {
    Lua = {
      workspace = { checkThirdParty = false },
      telemetry = { enable = false },
    },
  },
}

-- Setup neovim lua configuration
require('neodev').setup()

-- nvim-cmp supports additional completion capabilities, so broadcast that to servers
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require('cmp_nvim_lsp').default_capabilities(capabilities)

-- Setup mason so it can manage external tooling
require('mason').setup()

-- Ensure the servers above are installed
local mason_lspconfig = require 'mason-lspconfig'

mason_lspconfig.setup {
  ensure_installed = vim.tbl_keys(servers),
}

mason_lspconfig.setup_handlers {
  function(server_name)
    require('lspconfig')[server_name].setup {
      capabilities = capabilities,
      on_attach = on_attach,
      settings = servers[server_name],
    }
  end,
}

-- Turn on lsp status information
require('fidget').setup()

-- nvim-cmp setup
local cmp = require 'cmp'
local luasnip = require 'luasnip'

cmp.setup {
  snippet = {
    expand = function(args)
      luasnip.lsp_expand(args.body)
    end,
  },
  mapping = cmp.mapping.preset.insert {
    ['<C-b>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<C-e>'] = cmp.mapping.abort,
    ['<CR>'] = cmp.mapping.confirm {
      --behavior = cmp.ConfirmBehavior.Replace,
      select = true,
    },
    ['<Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      elseif luasnip.expand_or_jumpable() then
        luasnip.expand_or_jump()
      else
        fallback()
      end
    end, { 'i', 's' }),
    ['<S-Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      elseif luasnip.jumpable(-1) then
        luasnip.jump(-1)
      else
        fallback()
      end
    end, { 'i', 's' }),
  },
  sources = {
    { name = 'nvim_lsp' },
    { name = 'luasnip' },
  },
}


-- Language specific settings
vim.api.nvim_create_autocmd('FileType', {
  pattern = "go",
  callback = function()
    vim.bo.tabstop = 4
  end
})


-- Load old vim plugins
local ensure_plug = function()
  local fn = vim.fn
  local install_path = fn.stdpath('data') .. '/site/autoload/plug.vim'
  if fn.empty(fn.glob(install_path)) > 0 then
    fn.system{'curl', '-fLo', install_path, '--create-dirs',
              'https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'}
  end
end
ensure_plug()

vim.cmd[[
call plug#begin('~/.local/share/nvim/plugged')
Plug 'jlanzarotta/bufexplorer'
call plug#end()
]]

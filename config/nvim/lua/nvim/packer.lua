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

return require('packer').startup(function(use)
    -- Packer can manage itselfpacker
    use 'wbthomason/packer.nvim'

    use {
        'nvim-telescope/telescope.nvim', tag = '0.1.5',
        -- or                            , branch = '0.1.x',
        requires = { { 'nvim-lua/plenary.nvim' } }

    }

    -- telescope code actions ui
		use("nvim-telescope/telescope-ui-select.nvim")

		-- telescope file browser
		use("nvim-telescope/telescope-file-browser.nvim")
--    use {
--        'svrana/neosolarized.nvim',
--        requires = { 'tjdevries/colorbuddy.nvim' }
--    }
    use('nvim-treesitter/nvim-treesitter', { run = ':TSUpdate' })
    use("theprimeagen/harpoon")
    use("mbbill/undotree")
    use("tpope/vim-fugitive")
    use('nvim-lualine/lualine.nvim') -- Statusline
    use('kyazdani42/nvim-web-devicons') -- File icons
    use('kyazdani42/nvim-tree.lua') -- NvimTree
    use('jose-elias-alvarez/null-ls.nvim')
    use('MunifTanjim/prettier.nvim')
    use('numToStr/Comment.nvim')
    use('windwp/nvim-autopairs')
    use('windwp/nvim-ts-autotag')
    use('xiyaowong/nvim-transparent')
    use({ "catppuccin/nvim", as = "catppuccin" })
    use('tomasiser/vim-code-dark')
    use('norcalli/nvim-colorizer.lua')
    use {
        'VonHeikemen/lsp-zero.nvim',
        branch = 'v1.x',
        requires = {
            -- LSP Support
            { 'neovim/nvim-lspconfig' },             -- Required
            { 'williamboman/mason.nvim' },           -- Optional
            { 'williamboman/mason-lspconfig.nvim' }, -- Optional

            -- Autocompletion
            { 'hrsh7th/nvim-cmp' },         -- Required
            { 'hrsh7th/cmp-nvim-lsp' },     -- Required
            { 'hrsh7th/cmp-buffer' },       -- Optional
            { 'hrsh7th/cmp-path' },         -- Optional
            { 'saadparwaiz1/cmp_luasnip' }, -- Optional
            { 'hrsh7th/cmp-nvim-lua' },     -- Optional

            -- Snippets
            { 'L3MON4D3/LuaSnip' },             -- Required
            { 'rafamadriz/friendly-snippets' }, -- Optional
        }
    }

    -- Automatically set up your configuration after cloning packer.nvim
    -- Put this at the end after all plugins
    if packer_bootstrap then
        require('packer').sync()
    end
end)

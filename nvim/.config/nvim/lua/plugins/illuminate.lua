return {
  "RRethy/vim-illuminate",
  opts = {
    -- Remove 'treesitter' from providers to stop the Neovim 0.12 internal crashes
    providers = { "lsp", "regex" },
  },
  config = function(_, opts)
    require("illuminate").configure(opts)
  end,
}

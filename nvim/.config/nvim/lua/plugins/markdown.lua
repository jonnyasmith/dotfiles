return {
  "iamcco/markdown-preview.nvim",
  cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
  ft = { "markdown" },
  -- AstroNvim will automatically run the installer post-install/update
  build = function() vim.fn["mkdp#util#install"]() end,
  init = function()
    -- Enable Mermaid and diagram rendering engines globally
    vim.g.mkdp_preview_options = {
      mermaid = {},
      seq_diagrams = {},
      flowchart_diagrams = {},
    }
  end,
}

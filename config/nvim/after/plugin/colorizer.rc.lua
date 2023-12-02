if vim.g.vscode then return end
local status, colorizer = pcall(require, "colorizer")
if (not status) then return end

colorizer.setup({
  '*';
})

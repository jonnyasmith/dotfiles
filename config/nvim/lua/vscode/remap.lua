local keymap = vim.api.nvim_set_keymap
local options = { noremap = true, silent = true }

vim.keymap.set('n', '<Space>', function() vim.fn.VSCodeNotify('whichkey.show') end, options)
vim.keymap.set('x', '<Space>', function() vim.fn.VSCodeNotify('whichkey.show') end, options)

vim.keymap.set('n', '<M+]>', function() vim.fn.VSCodeNotify('workbench.action.moveEditorToNextGroup') end, options)
vim.keymap.set('n', '<M+}>', function() vim.fn.VSCodeNotify('workbench.action.moveEditorToNextGroup') end, options)

vim.keymap.set('v', '<', '<gv', options)
vim.keymap.set('v', '>', '>gv', options)

vim.keymap.set('n', '<C-j>', '5j', options)
vim.keymap.set('n', '<C-k>', '5k', options)

vim.keymap.set("n", "<C-u>", "<C-u>zz", {desc = "Center cursor after moving up half-page"})
vim.keymap.set("n", "<C-d>", "<C-d>zz", {desc = "Center cursor after moving down half-page"})

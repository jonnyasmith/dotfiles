local keymap = vim.api.nvim_set_keymap
local options = { noremap = true, silent = true }

keymap('', '<Space>', '<Nop>', options)

vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

keymap('n', 'x', '"_x', options)
keymap('n', '<leader>n', ':nohl<CR>', options)

-- Easy save and quit
keymap('n', '<leader>w', ':w<CR>', options)
keymap('n', '<leader>q', ':q!<CR>', options)

-- Increment/decrement
keymap('n', '+', '<C-a>', options)
keymap('n', '-', '<C-x>', options)

-- Select all
keymap('n', '<C-a>', 'gg<S-v>G', options)

-- Split window
keymap('n', '<leader>-', ':split<Return><C-w>w', options)
keymap('n', '<leader>|', ':vsplit<Return><C-w>w', options)

-- Resize window
keymap('n', '<C-w><left>', '<C-w><', options)
keymap('n', '<C-w><right>', '<C-w>>', options)
keymap('n', '<C-w><up>', '<C-w>+', options)
keymap('n', '<C-w><down>', '<C-w>-', options)

keymap('n', '<leader>to', ':tabonly<CR>', options)

-- Visual
-- Stay in indent mode
keymap('v', '<', '<gv', options)
keymap('v', '>', '>gv', options)
keymap('v', 'p', '_dP', options)

-- NvimTree
keymap('n', '<leader>e', ':NvimTreeToggle<CR>', options)

vim.keymap.set('n', '<leader>fd', function()
    vim.lsp.buf.format()
end)


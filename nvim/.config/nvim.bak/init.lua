if vim.g.vscode then
    require('mscode')
    print("✔ nvim vscode loaded")
else
    require('nvim')
    print("✔ nvim loaded")
end

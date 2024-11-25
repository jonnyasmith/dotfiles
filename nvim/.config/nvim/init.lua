if vim.g.vscode then
    require('vscode')
    print("✔ nvim vscode loaded")
else
    require('nvim')
    print("✔ nvim loaded")
end

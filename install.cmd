For /R %HOME%\.dotfiles\ %%G IN (*.bash) do mklink "%HOME%\.%%~nG" "%%G"

mklink /D %HOME%\.dotfiles\vim\.vim %HOME%\.dotfiles\vim\vim.symlink
mklink /D %HOME%\.dotfiles\vim\.vimrc %HOME%\.dotfiles\vim\vimrc.symlink
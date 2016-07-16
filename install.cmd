For /R %HOME%\.dotfiles\ %%G IN (*.symlink) do echo mklink "%HOME%\.%%~nG" "%%G"
For /R %HOME%\.dotfiles\ %%G IN (*.bash) do mklink "%HOME%\.%%~nG" "%%G"

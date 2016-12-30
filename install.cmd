del /f C:\Users\Jonny\.bash_profile
del /f C:\Users\Jonny\.bashrc
del /f C:\Users\Jonny\.gitconfig
del /f C:\Users\Jonny\.vimrc
RD /S /Q C:\Users\Jonny\.vim
RD /S /Q C:\Users\Jonny\.webstorm
RD /S /Q C:\Users\Jonny\.rider
del /f C:\Users\Jonny\AppData\Roaming\Code\User\settings.json
del /f C:\Users\Jonny\AppData\Roaming\Code\User\keybindings.json
RD /S /Q C:\Users\Jonny\.vim-tmp

mklink C:\Users\Jonny\.bash_profile C:\Users\Jonny\.dotfiles\bash_current\bash_profile.bash
mklink C:\Users\Jonny\.bashrc C:\Users\Jonny\.dotfiles\bash_current\.bashrc
mklink C:\Users\Jonny\.gitconfig C:\Users\Jonny\.dotfiles\bash_current\gitconfig.bash
mklink C:\Users\Jonny\.vimrc C:\Users\Jonny\.dotfiles\vim\.vimrc
mklink /D C:\Users\Jonny\.vim C:\Users\Jonny\.dotfiles\vim\.vim
mklink /D C:\Users\Jonny\.webstorm C:\Users\Jonny\.dotfiles\.webstorm
mklink /D C:\Users\Jonny\.rider C:\Users\Jonny\.dotfiles\.rider
mklink C:\Users\Jonny\AppData\Roaming\Code\User\settings.json C:\Users\Jonny\.dotfiles\.code\settings.json
mklink C:\Users\Jonny\AppData\Roaming\Code\User\keybindings.json C:\Users\Jonny\.dotfiles\.code\keybindings.json

mkdir C:\Users\Jonny\.vim-tmp

pause

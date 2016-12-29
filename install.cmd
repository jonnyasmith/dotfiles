del C:\Users\JonnySmith\.bash_profile
del C:\Users\JonnySmith\.bashrc
del C:\Users\JonnySmith\.gitconfig
del C:\Users\JonnySmith\.vimrc
del C:\Users\JonnySmith\AppData\Roaming\Code\User\keybindings.json
del C:\Users\JonnySmith\AppData\Roaming\Code\User\settings.json

rmdir C:\Users\JonnySmith\.vim
rmdir C:\Users\JonnySmith\.webstorm
rmdir C:\Users\JonnySmith\.rider

rmdir C:\Users\JonnySmith\.vim-tmp

mklink C:\Users\JonnySmith\.bash_profile C:\Users\JonnySmith\.dotfiles\bash_current\bash_profile.bash
mklink C:\Users\JonnySmith\.bashrc C:\Users\JonnySmith\.dotfiles\bash_current\.bashrc
mklink C:\Users\JonnySmith\.gitconfig C:\Users\JonnySmith\.dotfiles\bash_current\gitconfig.bash
mklink C:\Users\JonnySmith\.vimrc C:\Users\JonnySmith\.dotfiles\vim\.vimrc
mklink C:\Users\JonnySmith\AppData\Roaming\Code\User\keybindings.json C:\Users\JonnySmith\.dotfiles\.code\keybindings.json
mklink C:\Users\JonnySmith\AppData\Roaming\Code\User\settings.json C:\Users\JonnySmith\.dotfiles\.code\settings.json

mklink /D C:\Users\JonnySmith\.vim C:\Users\JonnySmith\.dotfiles\vim\.vim
mklink /D C:\Users\JonnySmith\.webstorm C:\Users\JonnySmith\.dotfiles\.webstorm
mklink /D C:\Users\JonnySmith\.rider C:\Users\JonnySmith\.dotfiles\.rider

mkdir C:\Users\JonnySmith\.vim-tmp

pause
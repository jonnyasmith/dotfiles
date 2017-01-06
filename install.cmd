del /f %UserProfile%\.bash_profile
del /f %UserProfile%\.bashrc
del /f %UserProfile%\.gitconfig
del /f %UserProfile%\.vimrc
RD /S /Q %UserProfile%\.vim
RD /S /Q %UserProfile%\.vim-tmp

mklink %UserProfile%\.bash_profile %UserProfile%\.dotfiles\bash_current\bash_profile.bash
mklink %UserProfile%\.bashrc %UserProfile%\.dotfiles\bash_current\.bashrc
mklink C:\Users\smithjon\.gitconfig C:\Users\smithjon\.dotfiles\bash_current\gitconfig.bash
mklink %UserProfile%\.vimrc %UserProfile%\.dotfiles\vim\.vimrc
mklink /D %UserProfile%\.vim %UserProfile%\.dotfiles\vim\.vim

mkdir %UserProfile%\.vim-tmp

pause

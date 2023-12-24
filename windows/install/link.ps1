Write-Host "Running link script" -ForegroundColor Green
Write-Host "Creating symlinks"   -ForegroundColor Blue

New-Item -ItemType SymbolicLink -Path "$env:USERPROFILE\.config"            -Target "$env:USERPROFILE\.dotfiles\config"                        -Force
New-Item -ItemType SymbolicLink -Path "$env:USERPROFILE\AppData\local\nvim" -Target "$env:USERPROFILE\.dotfiles\config\nvim"                   -Force
New-Item -ItemType SymbolicLink -Path "$env:USERPROFILE\.gitconfig"         -Target "$env:USERPROFILE\.dotfiles\windows\git\gitconfig.symlink" -Force
New-Item -ItemType SymbolicLink -Path "$env:USERPROFILE\.ideavimrc"         -Target "$env:USERPROFILE\.dotfiles\windows\vim\ideavimrc.symlink" -Force

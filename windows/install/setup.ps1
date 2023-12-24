Write-Host "Running setup script" -ForegroundColor Green

Write-Host "Install packer" -ForegroundColor Blue
$packerPath = "$env:LOCALAPPDATA\nvim-data\site\pack\packer\start\packer.nvim"
if (Test-Path $packerPath) {
  Write-Host "packer.nvim repository already cloned"
} else {
  Write-Host "Cloning packer.nvim repository"
  git clone https://github.com/wbthomason/packer.nvim $packerPath
}

Write-Host "Copy fzf.exe" -ForegroundColor Blue
Copy-Item -Path "$env:USERPROFILE\.dotfiles\windows\files\fzf.exe" -Destination "C:\Windows\System32" -Force

Write-Host "Running setup script" -ForegroundColor Green

Write-Host "Install packer" -ForegroundColor Blue
git clone https://github.com/wbthomason/packer.nvim "$env:LOCALAPPDATA\nvim-data\site\pack\packer\start\packer.nvim"

# Write-Host "Install wsl" -ForegroundColor Blue
# wsl --install

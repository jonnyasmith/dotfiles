Write-Host "Install PowerShell modules" -ForegroundColor Blue
Install-Module -Name PSFzf -RequiredVersion 2.5.16 -Force
Install-Module -Name Terminal-Icons -Repository PSGallery -Force
Install-Module z -AllowClobber -Force

Write-Host "Install wsl" -ForegroundColor Blue
wsl --install

Write-Host "Install npm lts" -ForegroundColor Blue
nvm install --lts
nvm use --lts

write-host "Install npm packages" -ForegroundColor Blue
npm i @githubnext/github-copilot-cli -g
npm i prettier -g



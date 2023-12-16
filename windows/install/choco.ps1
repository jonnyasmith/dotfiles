Write-Host "Running choco script" -ForegroundColor Green

Write-Host "Installing choco" -ForegroundColor Blue
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))

$packagesToInstall = @(
    "nerd-fonts-FiraMono",
    "nerd-fonts-FiraCode",
    "mingw"
)

foreach ($package in $packagesToInstall) {
    Write-Host "Installing $package" -ForegroundColor Blue
    choco install $package -y
}

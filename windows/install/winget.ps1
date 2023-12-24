Write-Host "Running winget script" -ForegroundColor Green

$packagesToInstall = @(
    "CoreyButler.NVMforWindows",
    "Docker.DockerDesktop",
    "Git.Git",
    "JetBrains.Toolbox",
    "Microsoft.DotNet.SDK.6",
    "Microsoft.DotNet.SDK.7",
    "Microsoft.DotNet.SDK.8",
    "Microsoft.PowerToys",
    "Microsoft.VisualStudioCode",
    "Neovim.Neovim",
    "Microsoft.PowerShell",
    "AgileBits.1Password",
    "Starship.Starship"
)

foreach ($package in $packagesToInstall) {
    Write-Host "Installing $package" -ForegroundColor Blue
    winget install --id $package
}

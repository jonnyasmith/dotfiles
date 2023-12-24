Write-Host "Running winget script" -ForegroundColor Green

$packagesToInstall = @(
    "AgileBits.1Password",
    "CoreyButler.NVMforWindows",
    "Docker.DockerDesktop",
    # "Git.Git",
    "JetBrains.Toolbox",
    "Microsoft.DotNet.SDK.6",
    "RedHat.Podman-Desktop",
    "Microsoft.AzureCLI",
    "Microsoft.DotNet.SDK.7",
    "Microsoft.DotNet.SDK.8",
    "Microsoft.PowerShell",
    "Microsoft.PowerToys",
    "Microsoft.VisualStudioCode",
    "Neovim.Neovim",
    "Starship.Starship"
)

foreach ($package in $packagesToInstall) {
    Write-Host "Installing $package" -ForegroundColor Blue
    winget install --id $package
}

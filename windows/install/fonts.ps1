Write-Host "Running fonts script" -ForegroundColor Green

# Define the folder containing font files
$fontFolder =  "$env:USERPROFILE\.dotfiles\fonts"

# Get a list of font files in the folder with .ttf and .otf extensions
$fontFiles = Get-ChildItem -Path $fontFolder | Where-Object { $_.Extension -match '\.ttf$|\.otf$' }

# Loop through each font file
foreach ($fontFile in $fontFiles) {
    # Get the font name without the file extension
    $fontName = [System.IO.Path]::GetFileNameWithoutExtension($fontFile.Name)

    # Check if the font is already installed
    if (-not (Get-ChildItem -Path "C:\Windows\Fonts" | Where-Object { $_.Name -eq "$fontName.ttf" -or $_.Name -eq "$fontName.otf" })) {    
        # Install the font using the font file
        Write-Host "Installing font: $fontName" -ForegroundColor Blue
        $fontInstaller = New-Object -ComObject Shell.Application
        $fontInstaller.NameSpace(0).CopyHere($fontFile.FullName)
        
        # Wait for a few seconds to ensure the font installation is completed
        Start-Sleep -Seconds 5
    }
    else {
        Write-Host "Font '$fontName' is already installed." -ForegroundColor Blue
    }
}
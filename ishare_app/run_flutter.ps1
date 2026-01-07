# Flutter run script that filters out file_picker warnings
param(
    [string]$Device = "chrome",
    [string[]]$AdditionalArgs = @()
)

# Build the command
$cmd = "flutter run -d $Device"
if ($AdditionalArgs.Count -gt 0) {
    $cmd += " " + ($AdditionalArgs -join " ")
}

# Run flutter run and filter out file_picker warnings
Invoke-Expression $cmd 2>&1 | ForEach-Object {
    $line = $_
    # Filter out file_picker warnings
    if ($line -notmatch "file_picker.*default plugin" -and 
        $line -notmatch "Ask the maintainers of file_picker" -and
        $line -notmatch "default_package: file_picker" -and
        $line -notmatch "pluginClass or dartPluginClass") {
        Write-Output $line
    }
}

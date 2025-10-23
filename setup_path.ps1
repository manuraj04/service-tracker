$flutterPath = "C:\flutter\bin"
$pubCachePath = "$env:LOCALAPPDATA\Pub\Cache\bin"

# Get the current user's PATH
$currentUserPath = [Environment]::GetEnvironmentVariable("Path", "User")

# Check if paths are already in the PATH
$addFlutterPath = $currentUserPath -notlike "*$flutterPath*"
$addPubPath = $currentUserPath -notlike "*$pubCachePath*"

# Create new PATH value
$newPath = $currentUserPath
if ($addFlutterPath) {
    $newPath = "$newPath;$flutterPath"
}
if ($addPubPath) {
    $newPath = "$newPath;$pubCachePath"
}

# Set the new PATH
[Environment]::SetEnvironmentVariable("Path", $newPath, "User")

Write-Host "PATH has been updated. Please restart your terminal to apply changes."
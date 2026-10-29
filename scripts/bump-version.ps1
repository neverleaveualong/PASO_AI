param(
    [ValidateSet("major", "minor", "patch", "revision")]
    [string]$Part = "revision"
)

$versionFile = Join-Path $PSScriptRoot "..\VERSION"
$current = (Get-Content $versionFile -Raw).Trim()
$parts = $current.Split('.') | ForEach-Object { [int]$_ }

switch ($Part) {
    "major"    { $parts[0]++; $parts[1] = 0; $parts[2] = 0; $parts[3] = 0 }
    "minor"    { $parts[1]++; $parts[2] = 0; $parts[3] = 0 }
    "patch"    { $parts[2]++; $parts[3] = 0 }
    "revision" { $parts[3]++ }
}

$next = "$($parts[0]).$($parts[1]).$($parts[2]).$($parts[3])"
Set-Content -Path $versionFile -Value $next -NoNewline
Write-Output "Version bumped: $current -> $next"

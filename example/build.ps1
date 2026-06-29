#----------------------------------------------------------------------------------------------------------------------
#
#----------------------------------------------------------------------------------------------------------------------
#Requires -PSEdition Core

[CmdletBinding()]
param (
    [ValidateSet('windows-msvc-x64', 'windows-msvc-x64+asan', 'windows-msvc-x86', 'windows-msvc-arm64', 'windows-msvc-arm64+relwithdebinfo+asan', 'windows-msvc-arm64+debug+asan', 'windows-clang-x64', 'windows-clang-x64+asan', 'windows-clangcl-x64', 'windows-clangcl-x64+asan')]
    $Presets = @('windows-msvc-x64', 'windows-msvc-x64+asan', 'windows-msvc-x86', 'windows-msvc-arm64', 'windows-msvc-arm64+relwithdebinfo+asan', 'windows-msvc-arm64+debug+asan', 'windows-clang-x64', 'windows-clang-x64+asan', 'windows-clangcl-x64', 'windows-clangcl-x64+asan')
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$CMake = Get-Variable -Name 'CMake' -ValueOnly -Scope global -ErrorAction SilentlyContinue
if (-not $CMake) {
    $CMakeCandidates = @(
        (Get-Command 'cmake' -ErrorAction SilentlyContinue)
        if ($IsWindows) {
            (Join-Path -Path $env:ProgramFiles -ChildPath 'CMake/bin/cmake.exe')
        }
    )
    foreach ($CMakeCandidate in $CMakeCandidates) {
        $CMake = Get-Command $CMakeCandidate -ErrorAction SilentlyContinue
        if ($CMake) {
            $global:CMake = $CMake
            break
        }
    }

    if (-not $CMake) {
        Write-Error "Unable to find CMake."
    }
}

$Configurations = @(
    'Debug'
    'Release'
    'RelWithDebInfo'
)

foreach ($Preset in $Presets) {
    & $CMake --preset $Preset

    foreach ($Configuration in $Configurations) {
        & $CMake --build --preset $Preset --config $Configuration
    }
}

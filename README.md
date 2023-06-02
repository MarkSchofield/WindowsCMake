# CMake Tooling for Windows Builds

'WindowsCMake' contains CMake-scripts for Windows-specific build tasks, like unpacking NuGet files or generating Cpp/WinRT projections.

## Linting

WindowsCMake uses [`cmakelang`][cmakelang] for linting the CMake files in the codebase. The
[.cmake-format.yaml](./.cmake-format.yaml) file describes the formatting style for the codebase. To run the linting
tools:

1. Install [`cmakelang`][cmakelang] following [the installation instuctions](https://cmake-format.readthedocs.io/en/latest/installation.html).
Note: Since WindowsCMake uses a `.yaml` file for configuration, make sure to install the `cmakelang[YAML]` package.

2. Run [`./analyze.ps1`](./analyze.ps1)

The [WindowsCMake CI](.\.github\workflows\ci.yaml) GitHub Workflow enforces the linting rules during PR and CI.

## Testing

WindowsCMake uses [Pester][pester] for testing the CMake files in the codebase. The tests are written for
[PowerShell Core][powershellcore] and checked into [the `Tests` folder](./Tests). To run the tests:

1. Launch a [PowerShell Core][powershellcore] prompt.

    ```text
    pwsh
    ```

2. Make sure that you have [Pester][pester] installed. This only needs to be done once.

    ```powershell
    Install-Module Pester
    ```

3. Import the Pester module into the PowerShell Core session:

    ```powershell
    Import-Module Pester
    ```

4. Discover and run all tests:

    ```powershell
    Invoke-Pester
    ```

The [WindowsCMake CI](.\.github\workflows\ci.yaml) GitHub Workflow requires all tests to pass during PR and CI.

[cmakelang]: https://cmake-format.readthedocs.io/ "cmakelang"
[pester]: https://pester.dev/ "Pester"
[powershellcore]: https://learn.microsoft.com/en-us/powershell/ "PowerShell Core"

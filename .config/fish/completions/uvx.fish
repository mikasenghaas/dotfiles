complete -c uvx -l from -d 'Use the given package to provide the command' -r
complete -c uvx -s w -l with -d 'Run with the given packages installed' -r
complete -c uvx -l with-editable -d 'Run with the given packages installed in editable mode' -r
complete -c uvx -l with-requirements -d 'Run with the packages listed in the given files' -r
complete -c uvx -s c -l constraints -d 'Constrain versions using the given requirements files' -r
complete -c uvx -s b -l build-constraints -d 'Constrain build dependencies using the given requirements files when building source distributions' -r
complete -c uvx -l overrides -d 'Override versions using the given requirements files' -r
complete -c uvx -l env-file -d 'Load environment variables from a `.env` file' -r -F
complete -c uvx -l index -d 'The URLs to use when resolving dependencies, in addition to the default index' -r
complete -c uvx -l default-index -d 'The URL of the default package index (by default: <https://pypi.org/simple>)' -r
complete -c uvx -s i -l index-url -d '(Deprecated: use `--default-index` instead) The URL of the Python package index (by default: <https://pypi.org/simple>)' -r
complete -c uvx -l extra-index-url -d '(Deprecated: use `--index` instead) Extra URLs of package indexes to use, in addition to `--index-url`' -r
complete -c uvx -s f -l find-links -d 'Locations to search for candidate distributions, in addition to those found in the registry indexes' -r
complete -c uvx -s P -l upgrade-package -d 'Allow upgrades for a specific package, ignoring pinned versions in any existing output file. Implies `--refresh-package`' -r
complete -c uvx -l reinstall-package -d 'Reinstall a specific package, regardless of whether it\'s already installed. Implies `--refresh-package`' -r
complete -c uvx -l index-strategy -d 'The strategy to use when resolving against multiple index URLs' -r -f -a "first-index\t'Only use results from the first index that returns a match for a given package name'
unsafe-first-match\t'Search for every package name across all indexes, exhausting the versions from the first index before moving on to the next'
unsafe-best-match\t'Search for every package name across all indexes, preferring the "best" version found. If a package version is in multiple indexes, only look at the entry for the first index'"
complete -c uvx -l keyring-provider -d 'Attempt to use `keyring` for authentication for index URLs' -r -f -a "disabled\t'Do not use keyring for credential lookup'
subprocess\t'Use the `keyring` command for credential lookup'"
complete -c uvx -l resolution -d 'The strategy to use when selecting between the different compatible versions for a given package requirement' -r -f -a "highest\t'Resolve the highest compatible version of each package'
lowest\t'Resolve the lowest compatible version of each package'
lowest-direct\t'Resolve the lowest compatible version of any direct dependencies, and the highest compatible version of any transitive dependencies'"
complete -c uvx -l prerelease -d 'The strategy to use when considering pre-release versions' -r -f -a "disallow\t'Disallow all pre-release versions'
allow\t'Allow all pre-release versions'
if-necessary\t'Allow pre-release versions if all versions of a package are pre-release'
explicit\t'Allow pre-release versions for first-party packages with explicit pre-release markers in their version requirements'
if-necessary-or-explicit\t'Allow pre-release versions if all versions of a package are pre-release, or if the package has an explicit pre-release marker in its version requirements'"
complete -c uvx -l fork-strategy -d 'The strategy to use when selecting multiple versions of a given package across Python versions and platforms' -r -f -a "fewest\t'Optimize for selecting the fewest number of versions for each package. Older versions may be preferred if they are compatible with a wider range of supported Python versions or platforms'
requires-python\t'Optimize for selecting latest supported version of each package, for each supported Python version'"
complete -c uvx -s C -l config-setting -d 'Settings to pass to the PEP 517 build backend, specified as `KEY=VALUE` pairs' -r
complete -c uvx -l config-settings-package -d 'Settings to pass to the PEP 517 build backend for a specific package, specified as `PACKAGE:KEY=VALUE` pairs' -r
complete -c uvx -l no-build-isolation-package -d 'Disable isolation when building source distributions for a specific package' -r
complete -c uvx -l exclude-newer -d 'Limit candidate packages to those that were uploaded prior to the given date' -r
complete -c uvx -l exclude-newer-package -d 'Limit candidate packages for specific packages to those that were uploaded prior to the given date' -r
complete -c uvx -l link-mode -d 'The method to use when installing packages from the global cache' -r -f -a "clone\t'Clone (i.e., copy-on-write) packages from the wheel into the `site-packages` directory'
copy\t'Copy packages from the wheel into the `site-packages` directory'
hardlink\t'Hard link packages from the wheel into the `site-packages` directory'
symlink\t'Symbolically link packages from the wheel into the `site-packages` directory'"
complete -c uvx -l no-build-package -d 'Don\'t build source distributions for a specific package' -r
complete -c uvx -l no-binary-package -d 'Don\'t install pre-built wheels for a specific package' -r
complete -c uvx -l refresh-package -d 'Refresh cached data for a specific package' -r
complete -c uvx -s p -l python -d 'The Python interpreter to use to build the run environment.' -r
complete -c uvx -l python-platform -d 'The platform for which requirements should be installed' -r -f -a "windows\t'An alias for `x86_64-pc-windows-msvc`, the default target for Windows'
linux\t'An alias for `x86_64-unknown-linux-gnu`, the default target for Linux'
macos\t'An alias for `aarch64-apple-darwin`, the default target for macOS'
x86_64-pc-windows-msvc\t'A 64-bit x86 Windows target'
aarch64-pc-windows-msvc\t'An ARM64 Windows target'
i686-pc-windows-msvc\t'A 32-bit x86 Windows target'
x86_64-unknown-linux-gnu\t'An x86 Linux target. Equivalent to `x86_64-manylinux_2_28`'
aarch64-apple-darwin\t'An ARM-based macOS target, as seen on Apple Silicon devices'
x86_64-apple-darwin\t'An x86 macOS target'
aarch64-unknown-linux-gnu\t'An ARM64 Linux target. Equivalent to `aarch64-manylinux_2_28`'
aarch64-unknown-linux-musl\t'An ARM64 Linux target'
x86_64-unknown-linux-musl\t'An `x86_64` Linux target'
riscv64-unknown-linux\t'A RISCV64 Linux target'
x86_64-manylinux2014\t'An `x86_64` target for the `manylinux2014` platform. Equivalent to `x86_64-manylinux_2_17`'
x86_64-manylinux_2_17\t'An `x86_64` target for the `manylinux_2_17` platform'
x86_64-manylinux_2_28\t'An `x86_64` target for the `manylinux_2_28` platform'
x86_64-manylinux_2_31\t'An `x86_64` target for the `manylinux_2_31` platform'
x86_64-manylinux_2_32\t'An `x86_64` target for the `manylinux_2_32` platform'
x86_64-manylinux_2_33\t'An `x86_64` target for the `manylinux_2_33` platform'
x86_64-manylinux_2_34\t'An `x86_64` target for the `manylinux_2_34` platform'
x86_64-manylinux_2_35\t'An `x86_64` target for the `manylinux_2_35` platform'
x86_64-manylinux_2_36\t'An `x86_64` target for the `manylinux_2_36` platform'
x86_64-manylinux_2_37\t'An `x86_64` target for the `manylinux_2_37` platform'
x86_64-manylinux_2_38\t'An `x86_64` target for the `manylinux_2_38` platform'
x86_64-manylinux_2_39\t'An `x86_64` target for the `manylinux_2_39` platform'
x86_64-manylinux_2_40\t'An `x86_64` target for the `manylinux_2_40` platform'
aarch64-manylinux2014\t'An ARM64 target for the `manylinux2014` platform. Equivalent to `aarch64-manylinux_2_17`'
aarch64-manylinux_2_17\t'An ARM64 target for the `manylinux_2_17` platform'
aarch64-manylinux_2_28\t'An ARM64 target for the `manylinux_2_28` platform'
aarch64-manylinux_2_31\t'An ARM64 target for the `manylinux_2_31` platform'
aarch64-manylinux_2_32\t'An ARM64 target for the `manylinux_2_32` platform'
aarch64-manylinux_2_33\t'An ARM64 target for the `manylinux_2_33` platform'
aarch64-manylinux_2_34\t'An ARM64 target for the `manylinux_2_34` platform'
aarch64-manylinux_2_35\t'An ARM64 target for the `manylinux_2_35` platform'
aarch64-manylinux_2_36\t'An ARM64 target for the `manylinux_2_36` platform'
aarch64-manylinux_2_37\t'An ARM64 target for the `manylinux_2_37` platform'
aarch64-manylinux_2_38\t'An ARM64 target for the `manylinux_2_38` platform'
aarch64-manylinux_2_39\t'An ARM64 target for the `manylinux_2_39` platform'
aarch64-manylinux_2_40\t'An ARM64 target for the `manylinux_2_40` platform'
aarch64-linux-android\t'An ARM64 Android target'
x86_64-linux-android\t'An `x86_64` Android target'
wasm32-pyodide2024\t'A wasm32 target using the Pyodide 2024 platform. Meant for use with Python 3.12'
arm64-apple-ios\t'An ARM64 target for iOS device'
arm64-apple-ios-simulator\t'An ARM64 target for iOS simulator'
x86_64-apple-ios-simulator\t'An `x86_64` target for iOS simulator'"
complete -c uvx -l generate-shell-completion -r -f -a "bash\t''
elvish\t''
fish\t''
nushell\t''
powershell\t''
zsh\t''"
complete -c uvx -l cache-dir -d 'Path to the cache directory' -r -F
complete -c uvx -l python-preference -r -f -a "only-managed\t'Only use managed Python installations; never use system Python installations'
managed\t'Prefer managed Python installations over system Python installations'
system\t'Prefer system Python installations over managed Python installations'
only-system\t'Only use system Python installations; never use managed Python installations'"
complete -c uvx -l python-fetch -d 'Deprecated version of [`Self::python_downloads`]' -r -f -a "automatic\t'Automatically download managed Python installations when needed'
manual\t'Do not automatically download managed Python installations; require explicit installation'
never\t'Do not ever allow Python downloads'"
complete -c uvx -l color -d 'Control the use of color in output' -r -f -a "auto\t'Enables colored output only when the output is going to a terminal or TTY with support'
always\t'Enables colored output regardless of the detected environment'
never\t'Disables colored output'"
complete -c uvx -l allow-insecure-host -d 'Allow insecure connections to a host' -r
complete -c uvx -l preview-features -d 'Enable experimental preview features' -r
complete -c uvx -l directory -d 'Change to the given directory prior to running the command' -r -F
complete -c uvx -l project -d 'Run the command within the given project directory' -r -F
complete -c uvx -l config-file -d 'The path to a `uv.toml` file to use for configuration' -r -F
complete -c uvx -l isolated -d 'Run the tool in an isolated virtual environment, ignoring any already-installed tools'
complete -c uvx -l no-env-file -d 'Avoid reading environment variables from a `.env` file'
complete -c uvx -l no-index -d 'Ignore the registry index (e.g., PyPI), instead relying on direct URL dependencies and those provided via `--find-links`'
complete -c uvx -s U -l upgrade -d 'Allow package upgrades, ignoring pinned versions in any existing output file. Implies `--refresh`'
complete -c uvx -l no-upgrade
complete -c uvx -l reinstall -d 'Reinstall all packages, regardless of whether they\'re already installed. Implies `--refresh`'
complete -c uvx -l no-reinstall
complete -c uvx -l pre
complete -c uvx -l no-build-isolation -d 'Disable isolation when building source distributions'
complete -c uvx -l build-isolation
complete -c uvx -l compile-bytecode -d 'Compile Python files to bytecode after installation'
complete -c uvx -l no-compile-bytecode
complete -c uvx -l no-sources -d 'Ignore the `tool.uv.sources` table when resolving dependencies. Used to lock against the standards-compliant, publishable package metadata, as opposed to using any workspace, Git, URL, or local path sources'
complete -c uvx -l no-build -d 'Don\'t build source distributions'
complete -c uvx -l build
complete -c uvx -l no-binary -d 'Don\'t install pre-built wheels'
complete -c uvx -l binary
complete -c uvx -l refresh -d 'Refresh all cached data'
complete -c uvx -l no-refresh
complete -c uvx -l show-resolution -d 'Whether to show resolver and installer output from any environment modifications'
complete -c uvx -s V -l version -d 'Display the uvx version'
complete -c uvx -s n -l no-cache -d 'Avoid reading from or writing to the cache, instead using a temporary directory for the duration of the operation'
complete -c uvx -l managed-python -d 'Require use of uv-managed Python versions'
complete -c uvx -l no-managed-python -d 'Disable use of uv-managed Python versions'
complete -c uvx -l allow-python-downloads -d 'Allow automatically downloading Python when required. [env: "UV_PYTHON_DOWNLOADS=auto"]'
complete -c uvx -l no-python-downloads -d 'Disable automatic downloads of Python. [env: "UV_PYTHON_DOWNLOADS=never"]'
complete -c uvx -s q -l quiet -d 'Use quiet output'
complete -c uvx -s v -l verbose -d 'Use verbose output'
complete -c uvx -l no-color -d 'Disable colors'
complete -c uvx -l native-tls -d 'Whether to load TLS certificates from the platform\'s native certificate store'
complete -c uvx -l no-native-tls
complete -c uvx -l offline -d 'Disable network access'
complete -c uvx -l no-offline
complete -c uvx -l preview -d 'Whether to enable all experimental preview features'
complete -c uvx -l no-preview
complete -c uvx -l show-settings -d 'Show the resolved settings for the current command'
complete -c uvx -l no-progress -d 'Hide all progress outputs'
complete -c uvx -l no-installer-metadata -d 'Skip writing `uv` installer metadata files (e.g., `INSTALLER`, `REQUESTED`, and `direct_url.json`) to site-packages `.dist-info` directories'
complete -c uvx -l no-config -d 'Avoid discovering configuration files (`pyproject.toml`, `uv.toml`)'
complete -c uvx -s h -l help -d 'Display the concise help for this command'

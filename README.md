# Cursor Agent Mise plugin

A cross-platform [Mise tool plugin](https://mise.jdx.dev/tool-plugin-development.html) for installing the official
[Cursor Agent CLI](https://cursor.com/docs/cli/installation).

The plugin reads the current release from Cursor's official installer, downloads the matching immutable package from
Cursor's CDN, and keeps the installation isolated under Mise. It does not modify shell startup files or the user's
global PATH.

## Supported platforms

| Operating system | x64 | ARM64 | Archive |
| --- | --- | --- | --- |
| Linux | Yes | Yes | `tar.gz` |
| macOS | Yes | Yes | `tar.gz` |
| Windows | Yes | Yes | `zip` |

The aliases `amd64`, `x86_64`, `aarch64`, `darwin`, `macos`, `windows`, and `win32` are normalized automatically.

## Install from GitHub

You do not need to clone this repository. Install the plugin directly from GitHub, then activate Cursor Agent:

```sh
mise plugins install cursor-agent https://github.com/thehumanworks/mise-plugin-cursor-agent.git
mise use --global cursor-agent@latest
```

The explicit `cursor-agent` name is important because the repository name is `mise-plugin-cursor-agent`.

For a project configuration shared with teammates, declare the GitHub remote in `mise.toml`:

```toml
[plugins]
"vfox:cursor-agent" = "https://github.com/thehumanworks/mise-plugin-cursor-agent.git"

[tools]
cursor-agent = "latest"
```

Then install everything declared by the project:

```sh
mise install
```

You can also address the GitHub-hosted vfox plugin directly without registering a short name first:

```sh
mise use --global vfox:thehumanworks/mise-plugin-cursor-agent@latest
```

For local development from this directory:

```sh
mise plugins link --force cursor-agent .
mise use cursor-agent@latest
```

Verify the installation and start an agent:

```sh
cursor-agent --version
cursor-agent
```

On macOS and Linux, `agent` is also installed as an alias for `cursor-agent`, matching Cursor's current installer.

## Version behavior

Cursor's installer only advertises the current release, so `mise ls-remote cursor-agent` returns that release. The
version has Cursor's date-and-revision form, for example `2026.08.25-3e8eec8` (newer releases may include a build
timestamp). A specific older version can also be requested if its package is still present on Cursor's CDN:

```sh
mise install cursor-agent@2026.08.25-3e8eec8
```

Cursor does not currently publish checksums alongside these CLI archives. This plugin downloads the same HTTPS CDN
artifacts used by Cursor's official installer but cannot supply Mise with an upstream checksum.

## Development

Run the platform mapping tests and a native integration install:

```sh
mise run test
```

CI exercises Linux and macOS on x64 and ARM64, plus Windows on x64. Unit tests cover every supported OS and
architecture mapping, including Windows ARM64.

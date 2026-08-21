# cursor-agent (mise plugin)

[mise](https://mise.jdx.dev) tool plugin for the [Cursor Agent CLI](https://cursor.com).

You do **not** need to clone this repository to install it. mise fetches the plugin from Git.

## Install from mise (no clone)

This is a vfox-style [tool plugin](https://mise.jdx.dev/tool-plugin-development.html). It is **not** in the [default mise registry](https://mise.jdx.dev/registry.html), so a short name alone (`mise plugin install cursor-agent`) will not resolve. Pass the Git URL.

```bash
# mise clones the plugin for you
mise plugin install cursor-agent https://github.com/thehumanworks/mise-plugin-cursor-agent

# then install / activate the tool
mise install cursor-agent@latest
mise use --global cursor-agent@latest
```

Always pass the name `cursor-agent`. The repo is `mise-plugin-cursor-agent`; mise's URL-only name inference only strips a `mise-` prefix, so

```bash
mise plugin install https://github.com/thehumanworks/mise-plugin-cursor-agent
```

would register the plugin as `plugin-cursor-agent` and break `mise install cursor-agent`.

Pin a Git ref the same way as any other plugin:

```bash
mise plugin install cursor-agent https://github.com/thehumanworks/mise-plugin-cursor-agent#main
```

### Project `mise.toml` (shared with teammates)

Declare the plugin URL so `mise install` auto-fetches it — still no manual clone:

```toml
[plugins]
cursor-agent = "https://github.com/thehumanworks/mise-plugin-cursor-agent"

[tools]
cursor-agent = "latest"
```

Then:

```bash
mise install
```

The optional `vfox:` prefix marks this as a Lua tool plugin before clone (see [mise plugin config](https://mise.jdx.dev/configuration.html#plugins-specify-custom-plugin-repository-urls)):

```toml
[plugins]
"vfox:cursor-agent" = "https://github.com/thehumanworks/mise-plugin-cursor-agent"
```

## Versions

| Request | Meaning |
| --- | --- |
| `latest` | Rolling channel. Resolved from `https://cursor.com/install` at install time. |
| `YYYY.MM.DD-<hash>` | Pinned Cursor lab build id. |

```bash
mise ls-remote cursor-agent
mise install cursor-agent@latest
mise exec cursor-agent@latest -- cursor-agent --version
```

Older build ids can be listed via `MISE_CURSOR_AGENT_EXTRA_VERSIONS` (comma-separated).

Supports Linux and macOS (`x64` / `arm64`).

## Development

Local clone + symlink (uncommitted edits):

```bash
mise plugin link --force cursor-agent .
bash scripts/run_tests.sh
bash scripts/verify_mise.sh --link
```

`scripts/verify_mise.sh` (default, no `--link`) installs the plugin with `mise plugin install <name> <git-url>` from a temporary bare clone. That is the same path users hit when they do not clone this repo themselves.

## Registry (optional)

To make `mise install cursor-agent` work with no URL, open a PR against [jdx/mise](https://github.com/jdx/mise) `registry.toml`:

```toml
[tools.cursor-agent]
backends = ["vfox:thehumanworks/mise-plugin-cursor-agent"]
description = "Cursor Agent CLI for headless AI coding"
```

Until that lands, use the Git URL or a `[plugins]` entry.

## License

MIT. See [LICENSE](LICENSE).

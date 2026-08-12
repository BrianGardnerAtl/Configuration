# Computer Configuration

This repo contains my development environment configuration. On a new machine, a single bootstrap script handles the bulk of the setup.

## Quick Start (New Machine)

From macOS Terminal.app, before anything else is installed:

```bash
curl -o bootstrap.sh https://raw.githubusercontent.com/BrianGardnerAtl/Configuration/master/bootstrap.sh
bash bootstrap.sh
```

The script will walk you through everything and pause when it needs input.

### What the script handles

1. Installs Homebrew
2. Installs git
3. Generates an SSH key and guides you through adding it to GitHub (auth + signing)
4. Configures git with your name, email, and SSH commit signing
5. Clones this repo to `~/Development/Configuration`
6. Installs all apps and tools via `Brewfile` (see below)
7. Installs oh-my-zsh
8. Sets up symlinks for zsh, vim, agent guidance, Codex roles, and Claude Code skills
9. Installs vim plugins via Vundle

### What you still do manually after the script

- **iTerm2:** Import the color scheme — Preferences > Profiles > Colors > Color Presets > Import > `material-ocean.itermcolors`
- **Alfred:** Enter license and configure preferences
- **JetBrains Toolbox:** Open and install desired IDEs
- **Android Studio:** Open and complete the SDK setup wizard
- **Divvy:** Open and configure window layouts
- **Claude Code:** Sign in by running `claude`

---

## Installed Apps & Tools (Brewfile)

| Tool | Type |
|---|---|
| git | CLI |
| node | CLI |
| openjdk@21 | CLI |
| Google Chrome | App |
| 1Password | App |
| Alfred | App |
| iTerm2 | App |
| Ollama | App |
| JetBrains Toolbox | App |
| Android Studio | App |
| Claude Code | App |
| Divvy | App |

To install everything from the Brewfile independently:

```bash
brew bundle --file=~/Development/Configuration/Brewfile
```

---

## ZSH Setup

`zsh_config` is symlinked to `~/.zshrc` by the bootstrap script.

To set it up manually:

```bash
ln -s ~/Development/Configuration/zsh_config ~/.zshrc
```

---

## Vim Setup

The `vim/` directory is symlinked to `~/.vim` and `vim/vimrc` to `~/.vimrc`.

To set it up manually:

```bash
ln -s ~/Development/Configuration/vim ~/.vim
ln -s ~/Development/Configuration/vim/vimrc ~/.vimrc
```

Plugins are managed by [Vundle](https://github.com/VundleVim/Vundle.vim). After the symlinks are in place:

```bash
# Install Vundle if not already present
git clone https://github.com/VundleVim/Vundle.vim.git ~/Development/Configuration/vim/bundle/Vundle.vim

# Install all plugins
vim +PluginInstall +qall
```

**Leader key:** `,`

### Vim File Structure

| Path | Purpose |
|---|---|
| `vim/vimrc` | Main config, sources everything else |
| `vim/vundle.vim` | Plugin declarations |
| `vim/gvimrc` | GUI (MacVim) settings |
| `vim/config/` | Per-plugin config files |
| `vim/bundle/` | Installed plugins (git-ignored) |

---

## Agent Guidance

Shared engineering guidance lives in `agents/GLOBAL.md` and remains the source used by Claude Code. Codex uses the standalone `codex/AGENTS.md`, which includes that engineering intent plus the Codex-specific Research-Plan-Implement (RPI) orchestration workflow.

| Symlink | Source | Purpose |
|---|---|---|
| `~/.codex/AGENTS.md` | `codex/AGENTS.md` | Codex engineering and RPI guidance |
| `~/.codex/agents/rpi-researcher.toml` | `codex/agents/rpi-researcher.toml` | Read-only architecture researcher |
| `~/.codex/agents/rpi-worker.toml` | `codex/agents/rpi-worker.toml` | Focused implementation worker |
| `~/.codex/agents/rpi-reviewer.toml` | `codex/agents/rpi-reviewer.toml` | Read-only completion reviewer |
| `~/.claude/CLAUDE.md` | `claude/CLAUDE.md` | Claude Code shared engineering guidance |

The RPI lifecycle is:

1. **Research:** The orchestrator delegates read-only investigation, reconciles the request with the current architecture, and raises material discrepancies.
2. **Plan:** The orchestrator presents a detailed, versioned plan. Implementation starts only after the user unambiguously approves that plan version.
3. **Implement:** One worker implements one approved item at a time, then a separate reviewer verifies the item. Unexpected scope is left untouched, researched separately, and raised to the user before any plan revision is implemented.

Codex role files are linked individually so bootstrap preserves unrelated personal roles in `~/.codex/agents`. It does not replace the private `~/.codex/config.toml`.

To set it up manually:

```bash
mkdir -p ~/.codex/agents ~/.claude
ln -s ~/Development/Configuration/codex/AGENTS.md ~/.codex/AGENTS.md
ln -s ~/Development/Configuration/codex/agents/rpi-researcher.toml ~/.codex/agents/rpi-researcher.toml
ln -s ~/Development/Configuration/codex/agents/rpi-worker.toml ~/.codex/agents/rpi-worker.toml
ln -s ~/Development/Configuration/codex/agents/rpi-reviewer.toml ~/.codex/agents/rpi-reviewer.toml
ln -s ~/Development/Configuration/claude/CLAUDE.md ~/.claude/CLAUDE.md
```

Start a new Codex session after changing the guidance or role files.

## Claude Code

Commands and skills are also symlinked globally:

| Symlink | Source | Purpose |
|---|---|---|
| `~/.claude/commands/` | `claude/commands/` | Simple slash commands (`.md` files) |
| `~/.claude/skills/` | `claude/skills/` | Full skills (directories with `SKILL.md`) |

To set it up manually:

```bash
ln -s ~/Development/Configuration/claude/commands ~/.claude/commands
ln -s ~/Development/Configuration/claude/skills ~/.claude/skills
```

### Adding a new skill

Create a directory under `claude/skills/` with a `SKILL.md` inside:

```
claude/skills/my-skill/SKILL.md
```

Invoke it with `/my-skill [arguments]`. Use `$ARGUMENTS` in the prompt to capture what the user passes.

### Available Skills

| Skill | Description |
|---|---|
| `/emulator` | Manage Android Virtual Devices — list, create, delete, start, stop |

---

## iTerm2 Color Scheme

The `material-ocean.itermcolors` file contains the Material Ocean color theme for iTerm2. Import it via:

Preferences > Profiles > Colors > Color Presets > Import

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
8. Sets up symlinks for zsh, vim, and Claude Code skills
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

## Claude Code

Three things are symlinked globally so they travel between machines:

| Symlink | Source | Purpose |
|---|---|---|
| `~/.claude/CLAUDE.md` | `claude/CLAUDE.md` | Global AI hints (RPI process, TDD) |
| `~/.claude/commands/` | `claude/commands/` | Simple slash commands (`.md` files) |
| `~/.claude/skills/` | `claude/skills/` | Full skills (directories with `SKILL.md`) |

To set it up manually:

```bash
mkdir -p ~/.claude
ln -s ~/Development/Configuration/claude/CLAUDE.md ~/.claude/CLAUDE.md
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

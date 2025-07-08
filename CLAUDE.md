# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a personal dotfiles repository containing configuration files for terminal applications and development tools. The repository includes a custom Bash tool called `dot` that manages symbolic links between the repository and the user's home directory.

## Key Components

### Dotfile Management Tool
- **Location**: `.dot/dot` - Executable Bash script for creating symbolic links
- **Purpose**: Creates symlinks from repository files to `$HOME` directory
- **Usage**: 
  ```bash
  ./.dot/dot --all                    # Link all configurations
  ./.dot/dot --file .config/kitty     # Link specific file/directory
  ./.dot/dot --force --all            # Force overwrite existing links
  ```

### Configuration Structure
- **`.config/`**: Contains application configurations
  - **`kitty/`**: Kitty terminal emulator configuration with extensive theming support (180+ themes)
  - **`nvim/`**: Neovim configuration using LazyVim framework
  - **`Code/`**: VS Code configuration (mostly ignored via .gitignore)
  - **`JetBrains/`**: JetBrains IDE configuration (mostly ignored)

## Common Commands

### Installing/Updating Dotfiles
```bash
# Clone repository (if not already cloned)
git clone <repository-url> ~/dotfiles

# Navigate to repository
cd ~/dotfiles

# Link all configurations
./.dot/dot --all

# Link specific configuration
./.dot/dot --file .config/nvim

# Force overwrite existing configurations
./.dot/dot --force --all
```

### Testing Dotfiles Safely
```bash
# Test in temporary home directory
mkdir -p /tmp/test-home
export HOME=/tmp/test-home
~/dotfiles/.dot/dot --all

# Backup existing configs before applying
cp -r $HOME/.config $HOME/.config.backup
```

## Architecture Notes

### Dotfile Management Design
- The `dot` script is configured to work from `$HOME/dotfiles` directory
- It creates symbolic links from repository files to corresponding locations in `$HOME`
- Excludes `.git` directory and respects `.gitignore` patterns
- Supports both bulk operations (`--all`) and selective operations (`--file`)

### Configuration Philosophy
- Configurations are stored in their expected locations within the repository (e.g., `.config/kitty/` maps to `~/.config/kitty/`)
- The repository structure mirrors the target filesystem structure
- IDE cache files are excluded via `.gitignore` to keep the repository clean

### Current State vs Documentation
- The README.md references a `shell/` directory that doesn't exist in the current structure
- Actual configurations are stored directly in `.config/` directory
- The documentation appears outdated and references a different directory structure

## Important Files

- **`.dot/dot`**: Main dotfile management script
- **`.config/kitty/kitty.conf`**: Kitty terminal configuration
- **`.config/nvim/init.lua`**: Neovim entry point
- **`.gitignore`**: Excludes IDE cache files and temporary data
- **`README.md`**: Repository documentation (in Spanish, may be outdated)
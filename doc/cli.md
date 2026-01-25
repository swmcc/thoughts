# Thought CLI

A command-line tool for posting thoughts quickly from your terminal.

## Installation

### Quick Setup

1. Symlink the script to your PATH:

```bash
ln -s /path/to/thoughts/bin/thought /usr/local/bin/thought
```

2. Initialize configuration:

```bash
thought --init
```

3. Enter your API URL and token when prompted.

### Manual Configuration

Create `~/.config/thoughts/config`:

```bash
mkdir -p ~/.config/thoughts
cat > ~/.config/thoughts/config << 'EOF'
THOUGHTS_API_URL=https://your-domain.com/api/thoughts
THOUGHTS_API_TOKEN=your-api-token-here
EOF
chmod 600 ~/.config/thoughts/config
```

## Usage

### Basic Usage

```bash
# Post a simple thought
thought "Hello world"

# Post with tags
thought -t coding "Working on a new feature"
thought -t coding -t ruby "Learning Ruby today"
thought --tag=work,meeting "Team standup done"
```

### Tags

Tags are optional and can be specified multiple ways:

```bash
# Single tag
thought -t idea "What if we..."

# Multiple tags (separate flags)
thought -t coding -t ruby -t learning "TIL about blocks"

# Multiple tags (comma-separated)
thought -t coding,ruby "Working on Ruby project"
thought --tag=work,important "Deadline reminder"
```

### Piped Input

```bash
# Pipe content
echo "Quick thought" | thought

# Pipe with tags
echo "Found a bug" | thought -t bug -t urgent

# From a file
cat note.txt | thought -t note

# Command output
date | thought -t log
```

### Examples

```bash
# Simple thought
thought "Coffee break"

# With URL (will auto-unfurl)
thought "Check this out https://example.com"

# Multiple tags
thought -t til -t ruby "TIL: Ruby has a dig method for nested hashes"

# Quick note from clipboard (macOS)
pbpaste | thought -t clipboard
```

## Commands

| Command | Description |
|---------|-------------|
| `thought "content"` | Post a thought |
| `thought --init` | Set up configuration interactively |
| `thought --config` | Show current configuration |
| `thought --help` | Show help message |
| `thought --version` | Show version |

## Options

| Option | Description |
|--------|-------------|
| `-t, --tag TAG` | Add a tag (repeatable, comma-separated) |
| `-h, --help` | Show help |
| `-v, --version` | Show version |

## Configuration

Configuration is stored in `~/.config/thoughts/config`.

### Required Variables

| Variable | Description |
|----------|-------------|
| `THOUGHTS_API_URL` | Full URL to the thoughts API endpoint |
| `THOUGHTS_API_TOKEN` | Your API authentication token |

### Getting Your API Token

1. Log into the admin interface
2. Navigate to your profile/settings
3. Copy or generate an API token

### Example Config

```bash
# ~/.config/thoughts/config
THOUGHTS_API_URL=https://thoughts.example.com/api/thoughts
THOUGHTS_API_TOKEN=abc123def456
```

## Requirements

- `bash` 4.0+
- `curl`
- `jq`

### macOS

```bash
# jq is required
brew install jq
```

### Linux (Debian/Ubuntu)

```bash
sudo apt install jq curl
```

## Troubleshooting

### "No configuration found"

Run `thought --init` or create the config file manually.

### "Thought exceeds 140 characters"

Thoughts are limited to 140 characters. Shorten your message.

### "HTTP 401"

Your API token is invalid or expired. Check your configuration.

### "HTTP 422"

The thought content is invalid (empty or too long).

## Shell Aliases

Add to your `~/.bashrc` or `~/.zshrc`:

```bash
# Quick thought
alias t='thought'

# Thought with common tags
alias tw='thought -t work'
alias ti='thought -t idea'
alias tb='thought -t bookmark'
```

## Integration Ideas

### Git Hook (post-commit)

```bash
#!/bin/bash
# .git/hooks/post-commit
msg=$(git log -1 --pretty=%B)
thought -t git -t commit "${msg:0:140}"
```

### Alfred/Raycast

Create a script that calls `thought` with the input.

### Keyboard Shortcut (macOS)

Use Automator to create a Quick Action that runs:

```bash
/usr/local/bin/thought "$1"
```

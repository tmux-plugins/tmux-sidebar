# Tmux Sidebar

Instantly shows directory tree in pane sidebar. It's fast, convenient and works
great with vim.

Requirements: `tmux 1.9` or higher

### Key bindings

- `prefix + Tab` - toggle sidebar with directory tree
- `prefix + Backspace` - toggle sidebar and move cursor to it (focus it)

Key bindings toggle the sidebar!

### Installation with [Tmux Plugin Manager](https://github.com/tmux-plugins/tpm) (recommended)

Add plugin to the list of TPM plugins in `.tmux.conf`:

    set -g @tpm_plugins "          \
      tmux-plugins/tpm             \
      tmux-plugins/tmux-sidebar    \
    "

Hit `prefix + I` to fetch the plugin and source it. You should now be able to
use the plugin.

### Manual Installation

Clone the repo:

    $ git clone https://github.com/tmux-plugins/tmux-sidebar ~/clone/path

Add this line to the bottom of `.tmux.conf`:

    run-shell ~/clone/path/sidebar.tmux

Reload TMUX environment:

    # type this in terminal
    $ tmux source-file ~/.tmux.conf

You should now be able to use the plugin.

### Other goodies

- [tmux-copycat](https://github.com/tmux-plugins/tmux-copycat) - a plugin for
  regex searches in tmux and fast match selection
- [tmux-resurrect](https://github.com/tmux-plugins/tmux-resurrect) - restore
  tmux environment after a system restart

### License

[MIT](LICENSE.md)

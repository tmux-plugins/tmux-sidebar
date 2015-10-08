# Tmux Sidebar

`tmux-sidebar` does one thing: it opens a tree directory listing for the current
path. It's fast, convenient and works great with vim.

![screenshot](/screenshot.gif)

Some of the features that make the plugin more appealing than doing the same
thing manually each time:

- **fast**<br/>
  Much faster than doing each step manually.
- **smart sizing**<br/>
  Sidebar remembers its size, so the next time you open it, it will have the
  **exact same** width. This is a per-directory property, so you can have just
  the right size for multiple dirs.
- **toggling**<br/>
  The same key binding opens and closes the sidebar.
- **uninterrupted workflow**<br/>
  The main `prefix + Tab` key binding opens a sidebar but **does not** move
  cursor to it.
- **pane layout stays the same**<br/>
  No matter which pane layout you prefer, sidebar tries hard not to mess your
  pane splits. Open, then close the sidebar and everything should look the same.

Requirements: `tmux 1.9` or higher, `tree` recommended but not required

Tested and working on Linux, OSX and Cygwin.

### Key bindings

- `prefix + Tab` - toggle sidebar with a directory tree
- `prefix + Backspace` - toggle sidebar and move cursor to it (focus it)

### Installation with [Tmux Plugin Manager](https://github.com/tmux-plugins/tpm) (recommended)

Add plugin to the list of TPM plugins in `.tmux.conf`:

    set -g @plugin 'tmux-plugins/tmux-sidebar'

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

### Docs

- [customization options](docs/options.md)

### Other goodies

- [tmux-copycat](https://github.com/tmux-plugins/tmux-copycat) - a plugin for
  regex searches in tmux and fast match selection
- [tmux-resurrect](https://github.com/tmux-plugins/tmux-resurrect) - restore
  tmux environment after a system restart

### License

[MIT](LICENSE.md)

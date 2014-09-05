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

### Key bindings

- `prefix + Tab` - toggle sidebar with a directory tree
- `prefix + Backspace` - toggle sidebar and move cursor to it (focus it)

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

### Options

Customize `tmux-sidebar` by placing options in `.tmux.conf` and reloading Tmux
environment.

> How can I run some other command in the sidebar?

    set -g @sidebar-tree-command 'ls -1'

> Can I have the sidebar on the right?

    set -g @sidebar-tree-position 'right'

> I don't like the default 'prefix + Tab' key binding. Can I change it to be
'prefix + e'?

    set -g @sidebar-tree 'e'

> How can I change the default 'prefix + Backspace' to be 'prefix + w'?

    set -g @sidebar-tree-focus 'w'

> I see the tree sidebar uses 'less' as a pager. I would like to use 'more'.

    set -g @sidebar-tree-pager 'more'

> The default sidebar width is 40 columns. I want the sidebar to be wider by
default!

    set -g @sidebar-tree-width '60'

### Other goodies

- [tmux-copycat](https://github.com/tmux-plugins/tmux-copycat) - a plugin for
  regex searches in tmux and fast match selection
- [tmux-resurrect](https://github.com/tmux-plugins/tmux-resurrect) - restore
  tmux environment after a system restart

### License

[MIT](LICENSE.md)

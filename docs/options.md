## Options

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

> I see the tree sidebar uses 'less' as a pager. I would like to use 'view'.

    set -g @sidebar-tree-pager 'view -'

> The default sidebar width is 40 columns. I want the sidebar to be wider by
default!

    set -g @sidebar-tree-width '60'

> Can I colorize the ``tree`` directory listing in the sidebar?

    set -g @sidebar-tree-command 'tree -C'

### Notes

The command used to display the directory listing
(`@sidebar-tree-pager`, if set) must support color codes. If it does not,
unusual characters - the color control codes - will be visible in the sidebar.


# Changelog

### master
- move customization options to a separate docs document
- sidebar size bugfix for tmux 2.1 and above

### v0.8.0, Apr 05, 2015
- do not colorize `tree` output because a pager application might not handle it
  well
- do not suggest using `more` program in the readme
- invoke `less` pager command in a subshell so that unsetting environment
  variable via `LESS=` works in any shell
- bugfix: improve regex for fetching current directory sidebar width

### v0.7.0, Sep 05, 2014
- bugfix: invalid params for 'save_sidebar_width' script
- remove tilde characters from less
- improve less and tree commands
- add option for specifying custom command

### v0.6.0, Sep 05, 2014
- more options for customizing tree sidebar
- describe various options in the readme
- fix sidebar right resizing
- improve sidebar right handling
- big refactor for smooth window creation

### v0.5.0, Sep 04, 2014
- key bindings work from the sidebar now too

### v0.4.0, Sep 04, 2014
- change default key bindings to `Tab` and `Backspace`
- less does not wrap lines in the sidebar
- handle issue with refreshing the main pane
- by default the tree window is now 40 columns wide
- remember custom sidebar width for each directory
- bugfix for main window resize

### v0.3.0, Sep 04, 2014
- if the pane is too narrow do not show sidebar
- improve sidebar max size handling
- handle invalid pane resizing after sidebar is killed

### v0.2.0, Sep 03, 2014
- automatic sidebar opening for another sidebar type
- sidebars can't have nested sidebars
- show "custom tree" dir listing when `tree` command is not installed

### v0.1.0, Sep 03, 2014
- started the project
- init script done
- toggle script working
- fix wrong $PWD in sidebar pane
- plugin requires tmux version 1.9 or greater
- enable specifying sidebar width
- enable focusing on the sidebar when it's created

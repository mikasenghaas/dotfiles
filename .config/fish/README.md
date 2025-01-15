# Fish

[`fish`](https://fishshell.com/) is a user-friendly command line shell. It comes with many neat features out of the box.

I set up Alacritty to use Fish by default, so firing up the terminal should also open fish. To verify, type

```shell
echo $SHELL
```

This prints out your default shell.

## :electric_plug: Plugins

My fish configuration makes use of some plugins. The plugin manager is called [`fisher`](https://github.com/jorgebucaran/fisher). It is used to install, update and remove plugins interactively. Install via:

```shell
curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source && fisher install jorgebucaran/fisher
```

Install plugins using `fisher install <github-path>`.
List all currently installed plugins using `fisher list`

This is the list of all the plugins that I am using (inspired by this [plugin curation](https://gthub.com/jorgebucaran/awsm.fish))

1. [hydro](https://github.com/jorgebucaran/hydro) for a ultra-minmal prompt
2. [z](https://github.com/jethrokuan/z) for jumping directories quickly

To install all plugins run:

```
fisher install jorgebucaran/hydro
fisher install jethrokuan/z
```

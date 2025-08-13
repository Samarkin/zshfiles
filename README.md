# Z shell configuration

## Usage

### To install

1. Make sure `~/.zsh` does not exist.
2. Execute the following commands:
```
git clone https://github.com/Samarkin/zshfiles ~/.zsh
echo 'for plugin in ~/.zsh/*.plugin.zsh; source $plugin' >> ~/.zshrc
```

### To update

```
cd ~/.zsh
git pull
```

### To modify prompt color

The default prompt color might not look good on all terminals, so you can customize it with `$ZSH_PROMPT_COLOR`.
You can also use color to differentiate between modes/machines/environments.

To do that, add the following line **before** `for plugin ...`:
```shell
ZSH_PROMPT_COLOR=cyan # replace it with the color of your choice
```

### To uninstall:

```
sed -i.bak '/^for plugin in ~\/\.zsh/d' ~/.zshrc && rm -rf ~/.zsh
```

# Z shell configuration

## Usage

### macOS

1. Make sure `~/.zsh` does not exist.
2. Execute the following commands:
```
git clone https://github.com/Samarkin/zshfiles ~/.zsh
echo 'for plugin in ~/.zsh/*.plugin.zsh; source $plugin' >> ~/.zshrc
```
3. To update:
```
cd ~/.zsh
git pull
```
4. To uninstall:
```
sed -i.bak '/^for plugin in ~\/\.zsh/d' ~/.zshrc && rm -rf ~/.zsh
```

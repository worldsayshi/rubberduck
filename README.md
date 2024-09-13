
This is a plugin for running https://github.com/VictorTaelin/AI-scripts in neovim. It is a work in progress.


## Installation

1. Install AI-scripts
```bash
git clone https://github.com/VictorTaelin/AI-scripts.git ~/.local/src/AI-scripts
cd ~/.local/src/AI-scripts
git checkout c935e27 # Currently only works with this commit
npm install -g
```
2. Install this plugin, here with lazy:
```lua
{
  "worldsayshi/rubberduck",
  dependencies = { "nvim-lua/plenary.nvim" },
}
```


## Run tests

run tests:
```bash
make test
```
watch tests:
```bash
brew install entr
git ls-files | entr make test
```
or:
```bash
git ls-files | entr sh -c 'clear && make test'
```

## todos
- [ ] Bring up to speed with latest AI-scripts
- [ ] Split out the functionality that streams command output to a buffer and make a test for it


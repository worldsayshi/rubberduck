


Good test docs here:
https://github.com/nvim-lua/plenary.nvim/blob/master/TESTS_README.md

Plugin test example:
https://github.com/ellisonleao/nvim-plugin-template/blob/main/tests/plugin_name/plugin_name_spec.lua


run tests:
```bash
make test
```
watch tests:
```bash
brew install entr
git ls-files | entr make test
```

todos:
- [ ] Split out the functionality that streams command output to a buffer and make a test for it


# vim: set ft=make :

TESTS_INIT := "tests/minimal_init.lua"
TESTS_DIR := "tests/"

test:
    @nvim \
        --headless \
        --noplugin \
        -u {{TESTS_INIT}} \
        -c "PlenaryBustedDirectory {{TESTS_DIR}} { minimal_init = '{{TESTS_INIT}}' }"


test-lua-experiment:
    #!/bin/bash
    git ls-files | entr nvim --headless +RBdo +q

do-lua:
    #!/bin/bash
    nvim --headless +RBdo +q

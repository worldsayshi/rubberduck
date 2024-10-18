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
    just start-server
    nvim --headless +RBdo +q

start-server:
    #!/bin/bash
    PORT=3000
    if ! netstat -tuln | grep -q ":$PORT "; then
      echo "Starting server on port $PORT"
      deno run --allow-net simple_server.ts &
      echo $! > server.pid
    fi

kill-server:
    #!/bin/bash
    if [ -f server.pid ]; then
      echo "Killing server"
      kill $(cat server.pid)
      rm server.pid
    fi

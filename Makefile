TESTS_INIT=tests/minimal_init.lua
TESTS_DIR=tests/

.PHONY: test test-login

test:
	@nvim \
		--headless \
		--noplugin \
		-u ${TESTS_INIT} \
		-c "PlenaryBustedDirectory ${TESTS_DIR} { minimal_init = '${TESTS_INIT}' }"

test-login:
	@nvim \
		--headless \
		-c ":lua require('rubberduck').login() os.exit()"



BIN = bin
C_TEST = $(BIN)/c-test


$(BIN):
	mkdir -p $(@)

$(C_TEST): test_it.c chpl_exec.c $(BIN)
	$(CC) -o $(@) test_it.c chpl_exec.c

c-test: $(C_TEST)
	$(<)

.PHONY: c-test

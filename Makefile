
REPO_ROOT = $(CURDIR)

BIN = bin
TEST = test

CHPL = chpl

CHPLTEST = $(BIN)/chpltest
CHPL_SRCS = *.chpl

C_HDRS = *.h
C_SRCS = *.c

C_TEST = $(BIN)/c-test

default: $(CHPLTEST)

$(BIN):
	mkdir -p $(@)

$(CHPLTEST): $(CHPL_SRCS) $(C_SRCS) $(C_HDRS) $(BIN)
	$(CHPL) -o $(@) ChapelTest.chpl

$(C_TEST): $(TEST)/test_it.c $(C_SRCS) $(C_HDRS) $(BIN)
	$(CC) -o $(@) -I$(REPO_ROOT) $(TEST)/test_it.c $(C_SRCS)

c-test: $(C_TEST)
	$(<)

.PHONY: c-test default

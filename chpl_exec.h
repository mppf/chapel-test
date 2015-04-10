#include <stdlib.h>

size_t chpl_get_environ_size(void);
void chpl_get_environ(const char* env[], size_t env_size);
int chpl_run(const char* cmd, const char** out);

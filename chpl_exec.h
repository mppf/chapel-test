#ifndef _BSD_SOURCE
#define _BSD_SOURCE
#endif

#ifndef _XOPEN_SOURCE
#define _XOPEN_SOURCE 600
#endif

#ifndef _DEFAULT_SOURCE
#define _DEFAULT_SOURCE
#endif

#include <stdlib.h>

size_t chpl_get_environ_size(void);
void chpl_get_environ(const char* env[], size_t env_size);
int chpl_run(const char* cmd, const char** out);

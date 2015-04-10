
#include "chpl_exec.h"

#include <stdio.h>
#include <string.h>


int main() {
  /*
  const int size = 2 * chpl_get_environ_size();
  const char* env[size];
  chpl_get_environ(env, size);

  for (int i = 0; i < size; i++)
    printf("%s\n", env[i]);
  */

  const char* cmd = "ls -la";
  const char* output;
  int result = chpl_run(cmd, &output);
  printf("output:\n%s\n", output);
  printf("result = %i\n", result);

  return 0;
}

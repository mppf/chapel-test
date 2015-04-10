
#include "chpl_exec.h"

#include <stdio.h>
#include <string.h>


int main() {
  const int size = 2 * chpl_get_environ_size();
  const char* env[size];
  chpl_get_environ(env, size);

  for (int i = 0; i < size; i++)
    printf("%s\n", env[i]);

  /*
  char* output;
  int result = chpl_run("ls -l ~/Dropbox", &output);
  //save_cmd("ls -l ~/Dropbox");
  printf("output:\n%s\n", output);
  printf("result = %i\n", result);
  //  printf("output:\n%s\n", output);
  // printf("strlen(output) = %lu\n", strlen(output));
  */
  return 0;
}

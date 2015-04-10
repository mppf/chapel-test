
#include "chpl_exec.h"

#include <assert.h>
#include <errno.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>


extern char** environ;


size_t chpl_get_environ_size() {
  size_t var_count = 0;
  for (size_t i = 0; environ && environ[i]; i++)
    var_count++;
  return var_count;
}


/* Iterate through each environment variable, split it into key/value, and
 * assign key then value to env[] output array. The env[] output array should
 * be twice the size of chpl_get_environ_size().
 */
void chpl_get_environ(const char* env[], size_t env_size) {
  assert(2*chpl_get_environ_size() == env_size);
  for (int i = 0; environ && environ[i]; i++) {
    char* e = environ[i];
    char* token;
    token = strtok(e, "=");
    env[2*i] = token;  // env var key
    env[2*i+1] = e + strlen(token) + 1;  // env var value
  }
}


int chpl_run(const char* cmd, const char** out) {
  char buffer[1024];
  char* output = NULL;
  char* temp_output = NULL;
  size_t size = 1;  // null terminator
  size_t line_length;

  FILE* proc;

  if ((proc = popen(cmd, "r")) == NULL) {
    // ERROR
  }

  while (fgets(buffer, sizeof(buffer), proc) != NULL) {
    // Find the length of the line we just read.
    line_length = strlen(buffer);

    // Allocate room for buffer, which will be appended.
    temp_output = realloc(output, size + line_length);
    if (temp_output == NULL) {
      // ERROR: allocation
    } else {
      output = temp_output;
    }

    // Append buffer to output.
    strncpy(output + size - 1, buffer, strlen(buffer));

    // Keep track of total output length.
    size += line_length;
  }

  int result = pclose(proc);
  *out = output;
  return result;
}

/* Execute commands... */

use "chpl_exec.h";
use "chpl_exec.c";

use Assert;

/* Run `cmd` and return exit code and output. */
proc run(cmd: string) {
  extern proc chpl_run(cmd: c_string, ref stdout: c_string_copy): int;

  var temp: c_string_copy,
    output: string;

  const env = getEnviron();
  for key in env.domain {
    setEnv(key, env[key]);
  }

  const result = chpl_run(cmd: c_string, temp);
  output = toString(temp);
  return output;
}

proc getEnviron() {
  extern proc chpl_get_environ_size(): int;
  extern proc chpl_get_environ(env: [] c_string_copy, envSize: int);

  const envSize = 2 * chpl_get_environ_size();
  var D = {1..envSize},
    tempEnv: [D] c_string_copy,
    envKeys: domain(string),
    env: [envKeys] string;

  chpl_get_environ(tempEnv, envSize);

  for i in 1..envSize by 2 {
    const key: string = tempEnv[i],
      value: string = tempEnv[i+1];
    env[key] = value;
  }

  return env;
}


/* Get the value of the envirionment variable. Returns empty string if variable
   is unset.

   :arg envVar: environment variable name
   :type envVar: string

   :returns: environment variable value
   :rtype: string
*/
proc getEnv(envVar: string): string {
  extern proc getenv(envKey: c_string): c_string;

  const value = getenv(envVar);
  return value: string;
}


/* Set the environment variable `envVar` to the given value.

   :arg envVar: environment variable name
   :type envVar: string

   :arg value: environment variable value
   :type value: string
*/
proc setEnv(envVar: string, value: string) {
  extern proc setenv(envKey: c_string, envValue: c_string, overwrite: bool): int;

  const result = setenv(envVar: c_string, value: c_string, true);
  assert(result == 0, "Failed to set env var " + envVar);
}


/* Delete variable `envVar` from environment.

   :arg envVar: environment variable name
   :type envVar: string
*/
proc unsetEnv(envVar: string) {
  extern proc unsetenv(envKey: c_string): int;

  const result = unsetenv(envVar: c_string);
  assert(result == 0, "Failed to unset env var " + envVar);
}

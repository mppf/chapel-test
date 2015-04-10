/* Execute commands... */

use "chpl_exec.h";

use Assert;

/* Run `cmd` and return exit code and output. */
proc run(cmd: string) {
  extern proc setenv(envKey: c_string, envValue: c_string, overwrite: bool): int;
  extern proc chpl_run(cmd: c_string, ref stdout: c_string_copy): int;

  var temp: c_string_copy,
    output: string;

  const env = getEnviron();

  for key in env.domain {
    const setResult = setenv(key: c_string, env[key]: c_string, true);
    assert(setResult == 0, "Failed to set env var " + key);
  }

  const result = chpl_run(cmd: c_string, temp);
  output = toString(temp);
  return (result, output);
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

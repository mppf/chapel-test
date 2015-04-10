
use Exec;
use FileSystem;

config const testDir = "/Users/tvandoren/src/chapel/test/release/examples/programs";

config const printEnv = false;

proc main() {
  if printEnv {
    writeln("### Chapel Environment ###");
    const chplEnv = run("$CHPL_HOME/util/printchplenv");
    write(chplEnv);
    writeln("##########################");
    writeln();
  }

  forall test in findTests(testDir) {
    runTest(test);
  }
}


proc runTest(test) {
  writeln("testing: ", test);
}


iter findTests(testDir) {
  for filename in findfiles(testDir, recursive=true) {
    if isChapelFile(filename) {
      yield filename;
    }
  }
}


iter findTests(testDir, param tag: iterKind)
  where tag == iterKind.standalone
{
  forall filename in findfiles(testDir, recursive=true) {
    if isChapelFile(filename) {
      yield filename;
    }
  }
}

proc isChapelFile(filename) {
  return ".chpl" == filename.substring(filename.length-4..);
}

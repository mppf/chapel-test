
use Exec;
use FileSystem;
use IO;

config const testDir = "/Users/tvandoren/src/chapel/test/release/examples/programs";

config const testverbose = false;
config const printEnv = testverbose;
config const noRecurse = false;


proc main() {
  var testRunner = new TestRunner(testDir, !noRecurse);
  testRunner.runTests();
  delete testRunner;
}

class TestRunner {
  const testDir, chplHome: string,
    recurse: bool;

  proc TestRunner(testDir, recurse) {
    this.testDir = testDir;
    this.recurse = recurse;
    this.chplHome = this.getChplHome();
  }

  proc runTests() {
    setEnv("CHPL_HOME", this.chplHome);
    this.printEnvironment();

    // TODO: forall test in this.findTests() {
    for test in this.findTests() {
      this.runTest(test);
    }
  }

  proc getChplHome() {
    const output = run("chpl --print-chpl-home");
    var chplHome: string;

    for i in 1..output.length {
      if output.substring(i) == "\t" {
        chplHome = output.substring(1..i-1);
        break;
      }
    }

    if testverbose then
      writeln("CHPL_HOME: ", chplHome);

    return chplHome;
  }

  proc printEnvironment() {
    if printEnv {
      const chplEnv = run("$CHPL_HOME/util/printchplenv");
      writeln("### Chapel Environment ###");
      write(chplEnv);
      writeln("##########################");
      writeln();
    }
  }

  proc runTest(test) {
    writeln("testing: ", test);

    var t = new Test(test);
    t.runTest();
    delete t;
  }

  iter findTests() {
    for filename in findfiles(this.testDir, recursive=this.recurse) {
      if this.isChapelFile(filename) {
        yield filename;
      }
    }
  }

  iter findTests(param tag: iterKind)
    where tag == iterKind.standalone
  {
    forall filename in findfiles(this.testDir, recursive=this.recurse) {
      if this.isChapelFile(filename) {
        yield filename;
      }
    }
  }

  proc isChapelFile(filename) {
    return getTestBasename(filename) + ".chpl" == filename;
  }

  proc writeThis(w: Writer) {
    w <~> "TestRunner(";
    w <~> "testDir=";
    w <~> testDir;
    w <~> ")";
  }
}

class Test {
  const test, testDir, testBasename, testName: string;
  var diff: string,
    success: bool;

  proc Test(test) {
    this.test = test;
    (testDir, testBasename) = splitFilename(test);
    testName = getTestBasename(testBasename);

    this.validateTestFiles();
  }

  proc validateTestFiles() {
    // TODO: implement this!
  }

  proc runTest() {
    const testOutput = this.compile() + this.execute();
    if this.checkOutput(testOutput) {
      writeln("SUCCESS: " + this.test);
    } else {
      writeln("ERROR: matching output: " + this.test);
    }
    return this.result;
  }

  proc result {
    // return pass/fail as bool, then diff
    return (this.success, this.diff);
  }

  proc fullTestName {
    return this.testDir + "/" + this.testName;
  }

  proc goodFile {
    return this.fullTestName + ".good";
  }

  proc expectedOutput {
    var f = open(this.goodFile, iomode.r),
      r = f.reader();
    var o: string;
    r.readstring(o);
    r.close();
    f.close();
    return o;
  }

  proc checkOutput(testOutput) {
    const expectedOut = this.expectedOutput;
    this.success = testOutput == expectedOut;
    if !this.success {
      this.diff = this.generateDiff(expectedOut, testOutput);
    }
    return this.success;
  }

  proc actualOutputFile {
    return this.fullTestName + ".out.tmp";
  }

  proc generateDiff(expectedOutput, actualOutput) {
    var f = open(this.actualOutputFile, iomode.cw),
      w = f.writer();
    w.write(actualOutput);
    w.close();
    f.close();

    const cmd = "diff " + this.goodFile + " " + this.actualOutputFile;
    if testverbose then
      writeln("Running diff command: " + cmd);
    return run(cmd);
  }

  proc compile() {
    const cmd = "chpl -o " + this.fullTestName + " " + this.test;
    if testverbose then
      writeln("Running compiler: " + cmd);
    return run(cmd);
  }

  proc execute() {
    const cmd = this.fullTestName;
    if testverbose then
      writeln("Running binary: " + cmd);
    const output = run(cmd);

    if testverbose then
      writeln("Deleting " + this.fullTestName);
    remove(this.fullTestName);

    return output;
  }

  proc writeThis(w: Writer) {
    w <~> "Test(";
    w <~> "test=";
    w <~> test;
    w <~> ", testDir=";
    w <~> testDir;
    w <~> ", testBasename=";
    w <~> testBasename;
    w <~> ", testName=";
    w <~> testName;
    w <~> ")";
  }
}

proc getTestBasename(filename) {
  return filename.substring(..filename.length-5);
}

/* Return tuple that is dirname and basename. */
proc splitFilename(filename) {
  for i in 1..filename.length by -1 {
    if filename.substring(i) == "/" {
      return (filename.substring(1..i-1), filename.substring(i+1..));
    }
  }
  return ("", filename);
}

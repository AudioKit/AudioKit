AudioKit Test Suite
===================

The AudioKit test suite consists of one OSX Swift-based test project which can run one of the many test Swift files stored in the "Tests" folder. There are two shell scripts which are executed to build and run tests.

The build script `build_all.sh` compiles every test in the `Tests` folder.  Recommended usage is:

`./build_all.sh >& test_output.log`

which when complete, produce a log file that can be searched for the term "BUILD FAILED" to find tests that did not compile.

The run script `run.sh` may be used to run one test:

`./run.sh Tests/AKVibes.swift`

or it may be run interactively by supplying no arguments.  In the interactive mode you can choose to run all the tests built by the `build_all.sh` script or to choose from a list of available tests.

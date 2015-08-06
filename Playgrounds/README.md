AudioKit Playgrounds
====================

This folder contains one iOS Xcode project called "AudioKitPlayground", a library of available playground base-files in the "Playgrounds" folder and two shell scripts.

The `install.sh` script needs to be run just once, before you can run the playground.  It will install the prerequisite software.

The `run.sh` script needs to be run before attempting to open the AudioKitPlayground workspace, and in fact will open the workspace up for you when it is ready.  The `run.sh` is an interactive script that will prompt you whether you want to run the project with the default playground, which is empty, the current playground (presumably one that is a work-in-progress) or one of the example playgrounds.  When you have made your choice, the script begins watching the files for updates,  launches the Playground workspace in Xcode, and copies the playground file if necessary.

If you upgrade your Xcode to a new version, you will have to run install.sh again.

#!/bin/bash
#
# Use this script as a "run script" phase for your OS X target.
# You may either copy the contents of this script or reference the file from the run phase.
#

install_name_tool -change CsoundLib @executable_path/../Frameworks/CsoundLib.framework/Versions/6.0/CsoundLib "$TARGET_BUILD_DIR/$EXECUTABLE_PATH"


#!/bin/bash
#
# Process the framework to copy symbol maps to the archive, remove simulator slices and remove extra data from the framework itself
#

cd "$BUILT_PRODUCTS_DIR/$FRAMEWORKS_FOLDER_PATH"

framework=./AudioKit.framework
binary="$framework/AudioKit"

if [ "$ACTION" == "install" ]; then
	find "$framework/BCSymbolMaps" -name \*.bcsymbolmap -type f -exec mv {} "$CONFIGURATION_BUILD_DIR" \;
	lipo -remove i386 -output "$binary" "$binary"
	lipo -remove x86_64 -output "$binary" "$binary"
	rm -f "$framework/fix-framework.sh"
fi

rm -rf "$framework/BCSymbolMaps"

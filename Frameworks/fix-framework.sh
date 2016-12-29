#!/bin/bash
#
# Process the framework to copy symbol maps to the archive, remove simulator slices and remove extra data from the framework itself
#

cd "$BUILT_PRODUCTS_DIR/$FRAMEWORKS_FOLDER_PATH"

framework=./AudioKit.framework
binary="$framework/AudioKit"

if [ "$ACTION" == "install" ]; then
	find "$framework/BCSymbolMaps" -name \*.bcsymbolmap -type f -exec mv {} "$CONFIGURATION_BUILD_DIR" \;

	BINARY_INFO=`lipo -info "$binary"`;
	
	if (`echo $BINARY_INFO | grep i386`); then
	    # Binary has i386
	    lipo -remove i386 -output "$binary" "$binary"
	fi

	if (`echo $BINARY_INFO | grep x86_64`); then
	    # Binary has x86_64
	    lipo -remove x86_64 -output "$binary" "$binary"
	fi
	
	rm -f "$framework/fix-framework.sh"
fi

rm -rf "$framework/BCSymbolMaps"

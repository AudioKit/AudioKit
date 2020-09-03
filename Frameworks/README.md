# AudioKit Frameworks

Starting with AudioKit 5, the Swift Package Manager is the preferred way to integrate AudioKit within your applications.

However, we also still provide build scripts in this directory to create universal static XCFrameworks, which can be installed via CocoaPods or dragged directly in your application. We strongly urge you to migrate your project to SPM however.

## Universal XCFrameworks on Xcode 11 / Catalina

If you are running at least macOS 10.15 (Catalina), you can now build XCFramework archives containing all supported platforms in a singular archive - including the Mac Catalyst versions.

Note that these can only be built on a Mac running Catalina or later, and you need to explicitly run the `build_xcframework.sh` script after building the individual frameworks first with `build_frameworks.sh`. You will need binaries for all supported platforms to be able to generate the XCFrameworks with this script.


# Windows VST2 Plugin
This is a project for Microsoft Visual Studio 2017, which takes the platform-independent code for *AudioKitCore::Chorus* and *AudioKitCore::Flanger* and wraps them as VST2 plug-in DLLs for Windows.

## Microsoft VS2017
To build this project, you'll need Microsoft's *Visual Studio 2017* IDE, which you can download from https://www.visualstudio.com/. The free *Community Edition* is sufficient, BUT you will need to set it up for "Desktop development with C++", and also select "MFC and ATL support (x86 and x64)" to ensure that certain required headers are available.

## VST2_SDK
You will also need some source-code files from Steinberg Media GmbH's VST2 SDK. Steinberg's licensing rules forbid us from including these here, but they are easy to obtain. Check the README.md file in the `VST2_SDK` folder for details.

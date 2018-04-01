# Windows VST2 Plugin
This is a project for Microsoft Visual Studio 2017, which takes the platform-independent code for *AudioKitCore::Sampler* and wraps it as a VST2 plug-in DLL for Windows.

## Microsoft VS2017
To build this project, you'll need Microsoft's *Visual Studio 2017* IDE, which you can download from https://www.visualstudio.com/. The free *Community Edition* is sufficient, BUT you will need to set it up for "Desktop development with C++", and also select "MFC and ATL support (x86 and x64)" to ensure that certain required headers are available.

## VST2_SDK
You will also need some source-code files from Steinberg Media GmbH's VST2 SDK. Steinberg's licensing rules forbid us from including these here, but they are easy to obtain. Check the README.md file in the `VST2_SDK` folder for details.

## libsndfile
To facilitate reading standard, uncompressed audio files (e.g. WAV, AIF, formats), this project uses the *libsndfile* library, a copy of which is included here. For simplicity and compactness, we have only included the pre-compiled DLLs, stub libraries and header file, but if you wish, you can obtain the full source, documentation, etc. from the author's web site http://www.mega-nerd.com/libsndfile/.

The *libsndfile* library is subject to the terms of the Gnu Lesser General Public license (LGPL), which essentially means it can be used freely as a file-I/O library for larger software applications such as this.

## WavpackDLL
To facilitate reading *compressed* sound files, this project uses David Bryant's excellent *Wavpack* library, which we have also included here in the DLL/stub/header form. You can obtain the full source code, etc. from the main Wavpack site http://www.wavpack.com/.

*Wavpack* is subject to the terms of the MIT License.

## Demo sound files
To get started right away, we recommend that you download a small set of prepared files from [this link](http://audiokit.io/downloads/ROMPlayerInstruments.zip). That download also includes some useful utilities and a detailed README describing how to prepare your own sample files.

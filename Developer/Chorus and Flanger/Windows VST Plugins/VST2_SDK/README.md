# Obtaining the VST2 SDK
## Note: VST is licensed technology
VST (Virtual Studio Technology) is a trademark of Steinberg Media Technologies GmbH, and the associated SDKs, although freely available for download, are subject to license and so we are not allowed to simply include them here. However, the files you need are quite easy to obtain, as described below.

Steinberg's licensing conditions only apply to redistribution of the source code and use of VST technology in commercial products. It also compels us to include the following text here:

* VST Plugin Technology by Steinberg Media Technologies
* VST PlugIn Interface Technology by Steinberg Media Technologies GmbH

## Obtaining the files you need to build this project
This project uses the older VST2 SDK, which is now distributed by Steinberg as part of a package with the newer VST3 SDK. You can download the entire package from a link at https://www.steinberg.net/en/company/developers.html.

At the time this is written, the present download file is called `vstsdk367_03_03_2017_build_352.zip`. Opening this zip archive reveals three folders, `my_plugins`, `VST_SDK` and `VST3_SDK`, and two script files. For this project you only need the contents of the `VST2_SDK` folder (two folders called `pluginterfaces` and `public.sdk`), which you should copy into this folder, i.e., the one containing the README.md file you are now reading. Once these are in place, the project should build.

# Is AudioUnit Extension different from the AuV3 plugin which I use in Logic?

No, the two notions are basically the same, but the terminology can be confusing.

*Audio Units* (AU) are a basic Mac/iOS software technology for audio processing. An AU is a chunk of software with an API which follows certain rules, so when it is loaded in memory, it can connect to and work with the rest of the Mac/iOS Core Audio system. AudioKit is primarily a large collection of these "in-memory" AU's, many of which are just wrappers to legacy code.


*Plug-In* technologies are ways to allow AUs (or other dynamic-link software library units) to exist as disk files, plus ways for running programs ("host programs") to find out where they are and load them into memory, in order to connect to them. Apple's original AU plugin technologies were also called "Audio Units"; their first attempt was quickly replaced by AU version 2 ("AUv2"). Nearly all "audio unit" plugins available for the Mac today use the AUv2 standard, which requires that plugin files live in one of two special folders, so host programs can find them.

None of this works on iOS, where (a) the file system is hidden from the user, and (b) the App Store only supports apps, not dynamic-link libraries, so Apple came up with a new "AU version 3" ("AUv3") plug-in technology. In AUv3, Audio Unit code lives in a new kind of file called "Audio Unit Extension" which can be packaged into an app, as an .appex file in the app's "bundle" (a disguised version of a folder). Running the app "registers" the .appex file with the operating system, which then provides APIs to allow host programs to find it.

The AUv3 standard includes a number of technical improvements over AUv2, but the end result is (roughly) the same: a host app can get a list of installed plugins, ask the operating system to "instantiate" one by loading a copy of the code into memory, then connect to it as (roughly) an old-fashioned, in-memory Audio Unit.

On iOS, the "container" app provides a handy way to deliver the .appex via the App Store, and usually serves as a stand-alone host for a single instance. AUv3 app extensions also work on the Mac, and Apple has been telling us since 2014 that we should stop building AUv2 plugins and switch to AUv3, but there has been little progress so far, partly because AUv2 is already "good enough", but mostly because they've done an astonishingly poor job of telling developers what to do. This is why the AudioKit team is still struggling to make AUv3 plugins.

[Written by Shane Dunne]
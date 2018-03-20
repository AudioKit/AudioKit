# Developer/AKSampler 
Experimental projects to re-target the device-independent **AudioKitCore::Sampler** as an Audio Unit plug-in for use in a Mac DAW such as *Logic Pro X*.

## Mac AUv2 Plugin
Creates a simple plugin based on the older Audio Unit version 2 standard, which remains the most widely-used plugin format on the Mac platform.

**What about AUv3?** I have looked into AUv3 development on the Mac, but the process remains essentially undocumented and there are many serious hurdles.

## Windows VST2 Plugin
Creates a plugin for Windows based on the VST 2.4 standard. (VST is a trade mark of Steinberg Media Technologies GmbH.) See the README.md in the Windows VST Plugin folder for more details.

**What about VST3?** I created this project mainly as a proof-of-concept exercise to show that the new *AudioKitCore::Sampler* code could indeed be ported to platforms other than the Mac and iOS. I used the VST version 2 API because I have experience doing so, but it should not be difficult to use the newer VST3 API instead.

**What about VST for Mac/Linux?** Steinberg's VST technologies are quite well supported on both Macintosh and Linux operating systems, and in principle it should be straightforward to adapt this code to build on those platorms as well. I have not done so (yet), but I invite others to try, and would welcome their contributions to the AudioKit code base.


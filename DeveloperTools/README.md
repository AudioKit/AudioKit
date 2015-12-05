== Instructions for Creating a Soundpipe-powered AudioKit Node

* Run `lua data2yaml.lua` to make a yaml file
* Edit the yaml file to look like others
* Run `./bin/generate_node.rb path-to-folder/file.yaml`
* Add the folder to the Xcode project
* Change the XXXAudioUnit.h to a public header file
* Add <AudioKit/XXXAudioUnit.h> to the AudioKit.h file
* Add module.c to AudioKit's Soundpipe folder in Xcode
* Update the config.mk.ak with the new compiled module
* Generate a new soundpipe.h file with `make clean; make CONFIG=config.def.mk.ak` or some shell script
* Copy over the soundpipe.h file (if not part of a shell script)
* Commit the new files
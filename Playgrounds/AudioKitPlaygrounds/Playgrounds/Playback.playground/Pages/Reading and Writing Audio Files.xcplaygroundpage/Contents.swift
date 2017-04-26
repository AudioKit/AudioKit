//: ## Reading and Writing Audio Files
//:
//: AKAudioFile inherits from AVAudioFile so you can use it just like any AVAudioFile
import AudioKitPlaygrounds
import AudioKit

// Let's create an AKaudioFile :
let akAudioFile = try AKAudioFile(readFileName: "click.wav",
                                  baseDir: .resources)

// converted in an AVAudioFile
let avAudioFile = akAudioFile as AVAudioFile

// converted back into an AKAudioFile
let akAudioFile2 = try AKAudioFile(forReading: avAudioFile.url)

//: The baseDirectory parameter if an enum value from AKAudioFile.BaseDirectory :
let documentsDir = AKAudioFile.BaseDirectory.documents
let resourcesDir = AKAudioFile.BaseDirectory.resources
let tempDir = AKAudioFile.BaseDirectory.temp

//: baseDir is defaulted to be .resources, so loading an AKAudiofile
//: from this playground Resources folder can be done like this :
let drumloop = try AKAudioFile(readFileName: "drumloop.wav")

//: As AKAudioFile is an optional, it will be set to nil if a problem occurs.
//: Notice that an error message is printed in the debug area, and an error is thrown...
do {
    let nonExistentFile = try AKAudioFile(readFileName: "nonExistent.wav",
                                          baseDir: .resources)
} catch let error as NSError {
    print("There's an error: \(error)")
}

//: So it's a good idea to check that the AKAudioFile is valid before using it.
//: Let's display some info about drumloop :
print("drumloop.sampleRate: \(drumloop.sampleRate)")
print("drumloop.duration: \(drumloop.duration)")
// and so on...

//: AKAudioFile can easily be trimmed and exported and you can set a
//: callback function that will be triggered upon export has been completed.

//: Then, we can extract from 1 to 2 seconds of drumloop, as an mp4 file that will be
//: written in documents directory. If the destination file exists, it will be overwritten.
try drumloop.exportAsynchronously(name: "exported.m4a",
                                  baseDir: .documents,
                                  exportFormat: .m4a,
                                  fromSample: 44_100,
                                  toSample: 2 * 44_100) { exportedFile, error in
    print("myExportCallBack has been triggered. It means that export ended")
    if error == nil {
        print("Export succeeded")

        // If it is valid, we can play it :
        if let successfulFile = exportedFile {

            print(successfulFile.fileNamePlusExtension)
            let player = try? AKAudioPlayer(file: successfulFile)
            AudioKit.output = player
            AudioKit.start()
            player?.play()
        }

    } else {
        print(drumloop.fileNamePlusExtension)
        print("Export failed: \(error)")
    }
}

//: ## AKAudioFile for writing / recording
//: AKAudioFile is handy to create file for recording or writing to.
//:
//: If you set no parameter, an AKAudioFile is created in temp directory,
//: set to match AudioKit AKSettings (a stereo empty 32 bits float wav file at 44.1 kHz,
//: with a unique name identifier.
//:
//: The simplest way to create such a file is like this:
if let myWorkingFile = try? AKAudioFile(), let mySecondWorkingFile = try? AKAudioFile() {
    let myWorkingFileName1 = myWorkingFile.fileNamePlusExtension
    let mySecondWorkingFileName = mySecondWorkingFile.fileNamePlusExtension
}

//: But the benefits of using AKAudioFile instead of AVAudioFile, is that you can normalize,
//: reverse them or extract samples as float arrays. You can even perform audio edits very easily.
//: Have a look to AKAudioFile Part 2...

import PlaygroundSupport
PlaygroundPage.current.needsIndefiniteExecution = true

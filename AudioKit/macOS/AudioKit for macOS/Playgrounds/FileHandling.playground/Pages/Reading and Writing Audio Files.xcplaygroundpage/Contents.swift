//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## Reading and Writing Audio Files
//:
//: AKAudioFile inherits from AVAudioFile so you can use it just like any AVAudioFile
import XCPlayground
import AudioKit

// Let's create an AKaudioFile :
let akAudioFile = try? AKAudioFile(readFileName: "click.wav",
                                   baseDir: .Resources)

// converted in an AVAudioFile
let avAudioFile = akAudioFile! as AVAudioFile

// converted back into an AKAudioFile
let akAudioFile2 = try? AKAudioFile(forReading: avAudioFile.url)


//: The baseDirectory parameter if an enum value from AKAudioFile.BaseDirectory :
let documentsDir = AKAudioFile.BaseDirectory.Documents
let resourcesDir = AKAudioFile.BaseDirectory.Resources
let tempDir = AKAudioFile.BaseDirectory.Temp

//: baseDir is defaulted to be .Resources, so loading an AKAudiofile
//: from this playground Resources folder can be done like this :
let drumloop = try? AKAudioFile(readFileName: "drumloop.wav")

//: You can load a file from a sub directory like this:
let fmpia = try? AKAudioFile(readFileName: "Sounds/fmpia1.wav",
                             baseDir: .Resources)

//: As AKAudioFile is an optional, it will be set to nil if a problem occurs.
//: Notice that an error message is printed in the debug area, and an error is thrown...
do {
    let nonExistentFile = try AKAudioFile(readFileName: "nonExistent.wav",
                                          baseDir: .Resources)
} catch let error as NSError {
    print ("There's an error: \(error)")
}

//: So it's a good idea to check that the AKAudioFile is valid before using it.
//: Let's display some info about drumloop :
if drumloop != nil {
    print("drumloop!.sampleRate:  \(drumloop!.sampleRate)")
    print("drumloop!.duration:  \(drumloop!.duration)")
    // and so on...
}

//: AKAudioFile can easily be trimmed and exported. First, you must set a
//: callback function that will be triggered upon export has been completed.
func myExportCallBack() {
    print ("myExportCallBack has been triggered. It means that export ended")
    if myExport!!.succeeded {
        print ("Export succeeded")
        // we get the resulting AKAudioFile
        let exportedfile = myExport?!.exportedAudioFile!
        
        
        // If it is valid, we can play it :
        if exportedfile != nil {
            
            print (exportedfile?.fileNamePlusExtension)
            let player = try? AKAudioPlayer(file: exportedfile!)
            AudioKit.output = player
            AudioKit.start()
            player!.play()
        }
        
    } else {
        print ("Export failed")
    }
}

//: Then, we can extract from 1 to 2 seconds of drumloop, as an mp4 file that will be
//: written in documents directory. If the destination file exists, it will be overwritten.
let myExport = try? drumloop?.export(name: "exported", ext: .m4a, baseDir: .Documents,
                                     callBack: myExportCallBack,
                                     fromTime: 1, toTime: 2)



//: ## AKAudioFile for writing / recording
//: AKAudioFile is handy to create file for recording or writing to.
//: The simplest way to create such a file is like this:
let myWorkingFile = try? AKAudioFile()
let mySecondWorkingFile = try? AKAudioFile()

//: If you set no parameter, an AKAudioFile is created in temp directory,
//: set to match AudioKit AKSettings (a stereo empty 32 bits float wav file at 44.1 kHz,
//: with a unique name identifier:
if myWorkingFile != nil && mySecondWorkingFile != nil {
    let myWorkingFileName1 = myWorkingFile!.fileNamePlusExtension
    let mySecondWorkingFileName = mySecondWorkingFile!.fileNamePlusExtension
}

//: But the benefits of using AKAudioFile instead of AVAudioFile, is that you can normalize,
//: reverse them or extract samples as float arrays. You can even perform audio edits very easily.
//: Have a look to AKAudioFile Part 2...

XCPlaygroundPage.currentPage.needsIndefiniteExecution = true

//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)

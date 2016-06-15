//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## AKAudioFile
//:
//: AKAudioFile inherits from AVAudioFile so you can use it just like any AVAudioFile :
import PlaygroundSupport
import AudioKit

// Let's create an AKaudioFile :
let ak = try? AKAudioFile(forReadingFileName: "click", withExtension: "wav", fromBaseDirectory: .resources)

// converted in an AVAudioFile
let av = ak! as AVAudioFile

//converted back into an AKAudioFile
let ak2 = try? AKAudioFile(fromAVAudioFile: av)


//: The baseDirectory parameter if an enum value from AKAudioFile.BaseDirectory :
let documentsDir = AKAudioFile.BaseDirectory.documents
let resourcesDir = AKAudioFile.BaseDirectory.resources
let tempDir = AKAudioFile.BaseDirectory.temp

// So to load an AKAudiofile from this playground Resources folder :
let drumloop = try? AKAudioFile(forReadingFileName: "drumloop", withExtension: "wav", fromBaseDirectory: .resources)

//: You can load a file from a sub directory like this:
let fmpia = try? AKAudioFile(forReadingFileName: "Sounds/fmpia1", withExtension: "wav", fromBaseDirectory: .resources)

//: As AKAudioFile is an optional, it will be set to nil if a problem occurs. Notice that an error message is printed in the debug area, and an error is thrown...
do {
    let nonExistentFile = try AKAudioFile(forReadingFileName: "aFileName", withExtension: "wav", fromBaseDirectory: .resources)
} catch let error as NSError {
    print ("There's an error: \(error)")
}

//: So it's a good idea to check that the AKAudioFile is valid before using it. let's display some info about drumloop :
if drumloop != nil{
    print("drumloop!.sampleRate:  \(drumloop!.sampleRate)")
    print("drumloop!.duration:  \(drumloop!.duration)")
    // and so on...
}

//: The benefit of AKAudioFile versus AVAudioFile is that you can easily trim and export it. First, you must set a callback function that will be triggered upon export has been completed.
func myExportCallBack(){
    print ("myExportCallBack has been triggered. It means that export ended")
    if myExport!!.succeeded
    {
        print ("Export succeeded")
        // we get the resulting AKAudioFile
        let exportedfile = myExport?!.exportedAKAudioFile!
        // If it is valid, we can play it :
        if exportedfile != nil {
            let player = AKAudioPlayer(exportedfile!.url.absoluteString)
            AudioKit.output = player
            AudioKit.start()
            player.play()
        }
    } else {
        print ("Export failed")
    }
}

//: Then, we can extract from 1 to 2 seconds of drumloop, as an mp4 file that will be written in documents directory. If the destination file exists, it will be overwritten.
let myExport = try? drumloop?.export(withFileName: "drumloopExported", withExtension: .mp4, toDirectory: .documents, callBack: myExportCallBack, from: 1, to: 2)



//: ## AKAudioFile for writing / recording
//: AKAudioFile is handy to create file for recording or writing to. The simplest way to create such a file is like this:
let myWorkingFile = try? AKAudioFile()
let mySecondWorkingFile = try? AKAudioFile()

//: If you set no parameter, an AKAudioFile is created in temp directory, set to match AudioKit AKSettings (a stereo empty 32 bits float wav file at 44.1 kHz, with a unique name identifier :
if myWorkingFile != nil && mySecondWorkingFile != nil {
    print ("myWorkingFile name is \(myWorkingFile!.fileNameWithExtension)")
    print ("mySecondWorkingFile name is \(mySecondWorkingFile!.fileNameWithExtension)")
}

//: But you can create a custom AKAudioFile too :
let custom16bitsLinearSettings:[String : AnyObject] = [
    AVSampleRateKey : NSNumber(float: Float(AKSettings.sampleRate)),
    AVLinearPCMIsFloatKey: NSNumber(bool: false),
    AVFormatIDKey : NSNumber(int: Int32(kAudioFormatLinearPCM)),
    AVNumberOfChannelsKey : NSNumber(int: Int32(AKSettings.numberOfChannels)),
    AVLinearPCMIsNonInterleaved: NSNumber(bool: false),
    AVLinearPCMIsBigEndianKey: NSNumber(bool: false),
    AVLinearPCMBitDepthKey: NSNumber(int: Int32(16)) ]


let customFile = try? AKAudioFile(forWritingInBaseDirectory:.documents, withFileName: "customFile", andFileExtension: "aif", withSettings: custom16bitsLinearSettings)
if customFile != nil {
    let customFileSettings = customFile!.fileFormatSettings
    print("customFileSettings: \(customFileSettings)")
}
//: Check AKAudioFile.swift to learn more about its properties and methods...


PlaygroundPage.current.needsIndefiniteExecution = true

//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)

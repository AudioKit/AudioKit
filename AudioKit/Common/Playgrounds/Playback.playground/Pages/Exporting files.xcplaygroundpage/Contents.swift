//: ## Exporting Audio Files
//: AKAudioFiles can be easily converted to major audio formats asynchronously.
import XCPlayground
import AudioKit

//: We pick a file to convert :
let mixloop = try AKAudioFile(readFileName: "mixloop.wav")

//: Export will be done asynchronously. So we can play some music while exporting

let player = mixloop.player
AudioKit.output = player
AudioKit.start()
player!.looping = true
player!.play()

//: We need a callback that will be triggered as soon as Export has been completed.
//: the callBack must be set as an AsyncProcessCallback with a signature set to be :
// func callback(processedFile: AKAudioFile?, error: NSError?) -> Void
//: If export failed, "processedFile" will be nil. We can get the error thrown using "error" parameter. If export succeeded, no error will be set (error = nil) and we can get the exported file as an AKAudioFile.
//: Here, our callBack will print some information and replace the file being played with the exported file.
func callBack(processedFile: AKAudioFile?, error: NSError?){
    print("Export completed !")

    // First, we check if processed file is valid (different from nil)
    if let converted = processedFile {
        print("Export succeeded, converted file: \(converted.fileNamePlusExtension)")
        // We print the exported file's duration
        print("Exsported File Duration: \(converted.duration) seconds")
        // And we replace the file being played
        try? player!.replaceFile(converted)
    }
    else {
        // An error occured. So we print the Error
        print("Error: \(error!.localizedDescription)")
    }
}

//: Now we can export our mixloop into a compressed .mp4 file :
mixloop.exportAsynchronously(name: "test", baseDir: .Documents,exportFormat: .mp4, callBack: callBack)

//: We can convert our file to .WAV format, and this time, we'll set a range for our export
mixloop.exportAsynchronously(name: "test2", baseDir: .Documents,exportFormat: .wav,  fromSample: 10000, toSample: 20000, callBack: callBack)

/// Let's pick another file to convert to .aif.
let drumloop = try AKAudioFile(readFileName: "drumloop.wav")
drumloop.exportAsynchronously(name: "test3", baseDir: .Documents, exportFormat: .aif, fromSample: 20000, toSample: 40000,  callBack: callBack)

//: Each time an export has been completed and succeeded, the player will be set to play it.

//:Check the debug area. You'll notice that all file exports are done serially, in the order we set them...
XCPlaygroundPage.currentPage.needsIndefiniteExecution = true
//: Be aware that PCM format files can be converted to PCM or compressed formats. But compressed m4a or mp4 audiofiles cannot be converted to PCM files (.wav or .aif). For converting from any format compressed format to PCM, you can use AKAudioFile.extract or AKAudioFile.extractAsynchronously() methods (will convert to .CAF PCM). The resulting file can then be exported to .mp4, m4a, .wav, or .aif.


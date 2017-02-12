//: ## Exporting Audio Files
//: AKAudioFiles can be easily converted to major audio formats asynchronously.
import AudioKit

//: Pick a file to convert :
let mixloop = try AKAudioFile(readFileName: "mixloop.wav")

//: Export will be done asynchronously. So you can play some music while exporting

let player = mixloop.player
AudioKit.output = player
AudioKit.start()
player!.looping = false
player!.play()

//: You need a callback that will be triggered as soon as Export has been completed.
//: the callback must be set as an AsyncProcessCallback with a signature set to be:
//:
//: ```func callback(processedFile: AKAudioFile?, error: NSError?) -> Void```
//:
//: If export failed, "processedFile" will be nil.  The error being thrown is given in the "error" parameter. If export succeeded, no error will be set (error = nil) and the exported file is returned as an AKAudioFile.
//: The callback will print some information and replace the file being played with the exported file.
func callback(processedFile: AKAudioFile?, error: NSError?) {
    print("Export completed !")

    // Check if processed file is valid (different from nil)
    if let converted = processedFile {
        print("Export succeeded, converted file: \(converted.fileNamePlusExtension)")
        // Print the exported file's duration
        print("Exported File Duration: \(converted.duration) seconds")
        // Replace the file being played
        try? player!.replace(file: converted)
    } else {
        // An error occured. So, print the Error
        print("Error: \(error!.localizedDescription)")
    }
}

//: Next export the mixloop into a compressed .mp4 file :
mixloop.exportAsynchronously(name: "test", baseDir: .documents, exportFormat: .mp4, callback: callback)

//: Convert the file to .WAV format, and this time, set a range for the export
mixloop.exportAsynchronously(name: "test2", baseDir: .documents, exportFormat: .wav, fromSample: 10_000, toSample: 20_000, callback: callback)

/// Use another file to convert to .aif.
let drumloop = try AKAudioFile(readFileName: "drumloop.wav")
drumloop.exportAsynchronously(name: "test3", baseDir: .documents, exportFormat: .aif, fromSample: 20_000, toSample: 40_000, callback: callback)

//: Each time an export has been completed and succeeded, the player will be set to play it.

//: Check the debug area. Notice that all file exports are done serially, in the order they were set.

import PlaygroundSupport
PlaygroundPage.current.needsIndefiniteExecution = true
//: Be aware that PCM format files can be converted to PCM or compressed formats. But compressed m4a or mp4 audiofiles cannot be converted to PCM files (.wav or .aif). For converting from any format compressed format to PCM, you can use AKAudioFile.extract or AKAudioFile.extractAsynchronously() methods (will convert to .CAF PCM). The resulting file can then be exported to .mp4, m4a, .wav, or .aif.

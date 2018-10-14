//: ## Processing Audio File Asynchronously
//: Processing some audio files in background
import AudioKitPlaygrounds
import AudioKit

//: We begin by cleaning our bedroom... (any audioFiles in the Temp directory are deleted)

AKAudioFile.cleanTempDirectory()

//: We load the piano piece from resources and play it :
var piano = try AKAudioFile(readFileName: "poney.mp3")
let player = try AKAudioPlayer(file: piano)
player.looping = true

AudioKit.output = player
try AudioKit.start()
player.start()

//: While the piano is playing, we will process the file in background. AKAudioFile has a private ProcessFactory
//: that will handle any process in background
//: We define a call back that will be invoked when an async process has been completed. Notice that the process can
//: have succeeded or failed. if processedFile is different from nil, process succeeded, so you can get the processed
//: file. If processedFile is nil, process failed, but you can get the process thrown error:
func callback(processedFile: AKAudioFile?, error: NSError?) {

    // Each time our process is triggered, it will display some info about AKAudioFile Process Factory status :
    AKLog("callback Async process completed !")
    AKLog("callback -> How many async process have been scheduled: \(AKAudioFile.scheduledAsyncProcessesCount)")
    AKLog("callback -> How many uncompleted processes remain in the queue: \(AKAudioFile.queuedAsyncProcessCount)")
    AKLog("callback -> How many async process have been completed: \(AKAudioFile.completedAsyncProcessesCount)")

    // Now we handle the file (and the error if any occurred.)
    if let successfulFile = processedFile {
        // We AKLog its duration:
        AKLog("callback -> processed: \(successfulFile.duration)")
        // We replace the actual played file with the processed file
        do {
            try player.replace(file: successfulFile)
        } catch {
            AKLog("Couldn't replace file.")
        }
        AKLog("callback -> Replaced player's file !")
    } else {
        AKLog("callback -> error: \(error)")
    }
}

//: Let's process our piano asynchronously. First, we reverse the piano so it will play backward...

piano.reverseAsynchronously(completionHandler: callback)

AKLog("How many async process have been scheduled: \(AKAudioFile.scheduledAsyncProcessesCount)")
AKLog("How many uncompleted processes remain in the queue: \(AKAudioFile.queuedAsyncProcessCount)")
AKLog("How many async process have been completed: \(AKAudioFile.completedAsyncProcessesCount)")

//: Now we lower the piano level by normalizing it to a max level set at - 6 dB
piano.normalizeAsynchronously(newMaxLevel: 0, completionHandler: callback)

AKLog("How many async process have been scheduled: \(AKAudioFile.scheduledAsyncProcessesCount)")
AKLog("How many uncompleted processes remain in the queue: \(AKAudioFile.queuedAsyncProcessCount)")
AKLog("How many async process have been completed: \(AKAudioFile.completedAsyncProcessesCount)")

//: Now, extract one second from piano...

piano.extractAsynchronously(fromSample: 100_000, toSample: 144_100, completionHandler: callback)

AKLog("How many async process have been scheduled: \(AKAudioFile.scheduledAsyncProcessesCount)")
AKLog("How many uncompleted processes remain in the queue: \(AKAudioFile.queuedAsyncProcessCount)")
AKLog("How many async process have been completed: \(AKAudioFile.completedAsyncProcessesCount)")

//: You may have noticed that Async Processes are queued serially. That means that the next process will only occur
//: AFTER previous processes have been completed. First in, first out, completionHandlers will always be triggered in
//: the same order as you invoked an async process.

//: Most of the time, you 'll want to chain process. Then, you have to define a specific callback for each
//: process step. Let's experiment with the drum loop

var drumloop = try AKAudioFile(readFileName: "drumloop.wav")

//: We will first reverse the loop, and append the original loop to the reversed loop, and replace the file of our
//: player with the resulting processed file.
drumloop.reverseAsynchronously { reversedFile, error in
    if let successfullyReversedFile = reversedFile {
        AKLog("Drum Loop has been reversed")
        successfullyReversedFile.appendAsynchronously(file: drumloop) { appendedFile, error in
            if let successfullyAppendedFile = appendedFile {
                AKLog("Original drum loop has been appended to the reversed loop, so we can play the resulting file.")
                do {
                    try player.replace(file: successfullyAppendedFile)
                } catch {
                    AKLog("Could not replace file.")
                }
            } else {
                AKLog("error: \(error)")
            }
        }
    } else {
        AKLog("error: \(error)")
    }
}

//: These processes are done in background, that means that the next line will be AKLoged BEFORE the first (or any)
//: async process has ended.
AKLog("Can refresh UI or do anything while processing...")

import PlaygroundSupport
PlaygroundPage.current.needsIndefiniteExecution = true

//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## Processing Audio Files Asynchronously
//: ### Let's make more noise while processing


import XCPlayground

import Foundation
import AudioKit


//: We pick some audio to play with from the resources folder...

let piano = try? AKAudioFile(readFileName: "poney.mp3")
let guitar = try? AKAudioFile(readFileName: "guitarloop.wav")
let lead = try? AKAudioFile(readFileName: "leadloop.wav")

//: Within an AKAudioFile, there's already the player to listen to the file. Just ask for it :

let player1 = piano!.player!
player1.looping = true

//: Then, we need 3 more players. They won't play now so we don't care. We'll use the same recipe.

let player2 = piano!.player!
player2.looping = true

let player3 = piano!.player!
player3.looping = true

let player4 = piano!.player!
player4.looping = true

//: I love reverb..
let reverb = AKReverb(player4)

//: we put all of them them in a mixer.
let mixer = AKMixer(player1, player2, player3, reverb)

//: Let's have some sound now.

AudioKit.output = mixer
AudioKit.start()
player1.play()

//: Only player 1 is playing. The other players will play only when we'll have made
//: some process to feed them. As we want to process in background, we need callbacks.

//: These callbacks will be triggered when process has been completed. Then, we
//: can get the processed file and use it to feed a player, and start the player.
//: So player 2, 3 and 4 will start to play as soon as their processed file have been completed.

//: player2 will loop an extract of the piano piece.

func callback1() {
    try? player2.replaceFile(extractProcess.processedFile!)
    player2.play()
}

//: player3 will play the piano backward.
func callback2() {
    try? player3.replaceFile(reverseProcess.processedFile!)
    player3.play()
}

//: player4 will play the result of appending the guitar loop to the lead loop
func callback3() {
    try? player4.replaceFile(appendProcess.processedFile!)
    player4.play()
}

//: Now, the callbacks are ready, let's begin with the "extract" process. We must
//: provide a number of samples. Lets say we want 10 % of our (beautiful) piano piece

let tenPerCentsOfPiano = piano!.samplesCount / 10

//: Fine, we'll pick a part from the beginning (but not at the beginning),
//: so we extract from 10 % to 20 % of the piano song)

let extractProcess = piano!.extractAsynchronously(fromSample: tenPerCentsOfPiano,
                                                  toSample: tenPerCentsOfPiano * 2,
                                                  completionCallBack: callback1)
//: We want another player to play the piano backward. So we need the reversed audiofile:
let reverseProcess = piano!.reverseAsynchronously(completionCallBack: callback2)
//: Then, as a tribute to Franckenstein, we append the guitarloop to the leadloop into a single file
let appendProcess = lead!.appendAsynchronously(file: guitar!, completionCallBack: callback3)

//: Process will occur in background, so they won't block the program.
//: Notice that the print will occur before any process has ended.
//: As soon as a process has been completed, its player will play,
//: and new file will be processed and so on.

print ("Can refresh UI or do anything while processing...")

//: Okay, the result is not so musical. But you can experiment with your own files
//: (copy them in the playground resources folder so you can play with them)



XCPlaygroundPage.currentPage.needsIndefiniteExecution = true

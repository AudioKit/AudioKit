//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## AKAudioFile part 2 : Audio editing !...
//: ### Let's have some fun with our drum loop

import XCPlayground
import AudioKit

//: First we load the drumloop

let loop = try? AKAudioFile(readFileName: "drumloop.wav", baseDir: .Resources)

//: You may have noticed that the drumloop doesn't loop so well. Let's fix this...
let fixedLoop = try? loop!.extract(0, to: Int64(3.42 * 44100))

//: Now out drumloop is one bar long and perfectly loops. Let's extract the kick, the snare and hihat into sisteenth note long files :
let oneBarLength = fixedLoop!.samplesCount

let oneSixteenthLength = oneBarLength / 16

let kick = try?  fixedLoop!.extract(0, to: oneSixteenthLength)
let snare = try? fixedLoop!.extract(oneSixteenthLength * 4, to: oneSixteenthLength * 5)
let hihat = try? fixedLoop!.extract(oneSixteenthLength * 2, to: oneSixteenthLength * 3)

//: Notice that we don't provide any name or location for those files (in fact, I don't care...) If no name / location are set, files will be created in temp directory with a unique name. But you could choose name and location if you wish. Let's check this:

let kickFileName = kick!.fileNamePlusExtension
let kickFilePath = kick!.directoryPath

//: I love hihat, so we gonna normalize our Hihat sample so it will play as loud as other instruments...
let normalizedHihat = try? hihat!.normalize()

//: Why not making some new files by reversing them
let reverseKick = try? kick!.reverse()
let reverseSnare = try? snare!.reverse()
let reverseHihat = try? normalizedHihat!.reverse()

// A sixteenth note silence could be handy...
let silence = try?  AKAudioFile.silent(oneSixteenthLength)

//: Now, we put all them in an array so we can later randomly pick samples. Some are doubled so they'll have more luck to be picked.

let samplesBox: [AKAudioFile] = [kick!, snare!, kick!, snare!, kick!, snare!, normalizedHihat!, reverseKick! , reverseSnare!, reverseHihat!, silence!, silence!, silence!, silence!, silence! ]

//: Now, we'll play the original loop three times,
let threeTimesLoop =  try? fixedLoop!.append(fixedLoop!)
var sequence = try? threeTimesLoop!.append(fixedLoop!)
//: Next, we append a random sequence of 16 sixteenth of audio to build our random drum solo...

for i in 0..<16 {
    let newSampleIndex = randomInt(0..<samplesBox.count)
    let newSound = samplesBox[newSampleIndex]
    print ("picked sample #\(newSampleIndex) name: \(newSound.fileNamePlusExtension)")
    var newFile = try? sequence!.append(newSound)
    sequence = newFile!
}

//: Each time you'll run this playground, the resulting audioFile will be different. Let's listen to our edited audiofile: Original Loop 3 times, followed by the "drum solo of the day"...


let sequencePlayer = try? AKAudioPlayer(file: sequence!)
sequencePlayer!.looping = true

AudioKit.output = sequencePlayer!
AudioKit.start()
sequencePlayer!.play()


XCPlaygroundPage.currentPage.needsIndefiniteExecution = true

//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)

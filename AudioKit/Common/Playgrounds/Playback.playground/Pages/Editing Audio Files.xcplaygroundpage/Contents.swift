//: ## Editing Audio Files
//: Let's have some fun with our drum loop

import PlaygroundSupport
import AudioKit

//: First we load the drumloop

let loop = try? AKAudioFile(readFileName: "drumloop.wav", baseDir: .Resources)

//: You may have noticed that the drumloop doesn't loop so well. Let's fix this...
let fixedLoop = try? loop!.extracted(fromSample: 0, toSample: Int64(3.42 * 44100))

//: Now out drumloop is one bar long and perfectly loops. Let's extract the kick,
//: the snare and hihat into sixteenth note long files:
let oneBarLength = fixedLoop!.samplesCount

let oneSixteenthLength = oneBarLength / 16

let kick = try?  fixedLoop!.extracted(fromSample: 0, toSample: oneSixteenthLength)
let snare = try? fixedLoop!.extracted(fromSample: oneSixteenthLength * 4,
                                      toSample: oneSixteenthLength * 5)
let hihat = try? fixedLoop!.extracted(fromSample: oneSixteenthLength * 2,
                                      toSample: oneSixteenthLength * 3)

//: Notice that we don't provide any name or location for those files (in fact, we don't care...)
//: If no name / location are set, files will be created in temp directory with a unique name.
//: But you could choose name and location if you wish. Let's check this:

let kickFileName = kick!.fileNamePlusExtension
let kickFilePath = kick!.directoryPath

//: I love hihat, so normalize our Hihat sample so it will be as loud as other instruments...
let normalizedHihat = try? hihat!.normalized()

//: Why not making some new files by reversing them
let reverseKick = try? kick!.reversed()
let reverseSnare = try? snare!.reversed()
let reverseHihat = try? normalizedHihat!.reversed()

// A sixteenth note silence could be handy...
let silence = try?  AKAudioFile.silent(samples: oneSixteenthLength)

//: Now, we put all them in an array so we can later randomly pick samples.
//: Some are doubled so they'll have more luck to be picked.

let samplesBox: [AKAudioFile] = [kick!, snare!, kick!, snare!, kick!, snare!,
                                 normalizedHihat!, reverseKick!, reverseSnare!, reverseHihat!,
                                 silence!, silence!, silence!, silence!, silence!]

//: Now, we'll play the original loop three times,
let threeTimesLoop =  try? fixedLoop!.appendedBy(file: fixedLoop!)
var sequence = try? threeTimesLoop!.appendedBy(file: fixedLoop!)
//: Next, we append a random sequence of 16 sixteenth of audio to build our random drum solo...

for i in 0..<16 {
    let newSampleIndex = (0..<samplesBox.count).randomElement()
    let newSound = samplesBox[newSampleIndex]
    print("picked sample #\(newSampleIndex) name: \(newSound.fileNamePlusExtension)")
    var newFile = try? sequence!.appendedBy(file: newSound)
    sequence = newFile!
}

//: Each time you'll run this playground, the resulting audioFile will be different.
//: Let's listen to our edited audiofile: Original Loop 3 times,
//: followed by the "drum solo of the day"...


let sequencePlayer = try? AKAudioPlayer(file: sequence!)
sequencePlayer!.looping = true

AudioKit.output = sequencePlayer!
AudioKit.start()
sequencePlayer!.play()


PlaygroundPage.current.needsIndefiniteExecution = true

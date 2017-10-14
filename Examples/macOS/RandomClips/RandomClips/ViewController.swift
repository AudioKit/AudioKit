//
//  ViewController.swift
//  RandomClips
//
//  Created by David O'Neill on 9/8/17.
//  Copyright © 2017 AudioKit. All rights reserved.
//

import Cocoa
import AudioKit
import AudioKitUI

class ViewController: NSViewController {

    let drumPlayer = AKClipPlayer()
    let guitarPlayer = AKClipPlayer()
    let mixer = AKMixer()
    var drumLooper: AKAudioPlayer?
    let playButton = AKButton()
    let guitarDelay = AVAudioUnitDelay()
    let reverb = AKReverb()
    let highPass = AKHighPassFilter()

    override func viewDidLoad() {
        super.viewDidLoad()
        guard
            let drumURL = Bundle.main.url(forResource: "drumloop", withExtension: "wav"),
            let guitarURL = Bundle.main.url(forResource: "leadloop", withExtension: "wav"),
            let guitarLoopURL = Bundle.main.url(forResource: "guitarloop", withExtension: "wav"),
            let drumFile = try? AKAudioFile(forReading: drumURL),
            let guitarFile = try? AKAudioFile(forReading: guitarURL),
            let guitarLoopFile = try? AKAudioFile(forReading: guitarLoopURL),
            let drumLooper = try? AKAudioPlayer(file: drumFile, looping: true),
            let guitarLooper = try? AKAudioPlayer(file: guitarLoopFile, looping: true)

            else {
                print("missing resources!")
                return
        }
        [drumPlayer >>> highPass,
         guitarPlayer >>> guitarDelay >>> reverb,
         drumLooper,
         guitarLooper] >>> mixer

        guitarDelay.delayTime = guitarFile.duration / 8
        guitarDelay.feedback = 1
        guitarDelay.wetDryMix = 0.6
        reverb.loadFactoryPreset(.cathedral)
        reverb.dryWetMix = 0.8
        highPass.cutoffFrequency = 600

        drumPlayer.volume = 1
        guitarPlayer.volume = 0.6
        guitarLooper.volume = 0.3
        drumPlayer.volume = 0.6

        AudioKit.output = mixer
        AudioKit.start()

        playButton.title = "Play"
        playButton.frame = view.bounds
        view.addSubview(playButton)

        let drumChops = 32
        let guitarChops = 16
        let loops = 100

        func randomChopClips(audioFile: AKAudioFile, chops: Int, count: Int) -> [AKFileClip] {
            let duration = audioFile.duration / Double(chops)
            let randomOffset: () -> Double = {
                let btwn0andChop = arc4random_uniform(UInt32(chops))
                return duration * Double(btwn0andChop)
            }
            var clips = [AKFileClip(audioFile: audioFile,
                                    time: 0,
                                    offset: randomOffset(),
                                    duration: duration)]
            for _ in 0..<count {
                guard let lastClip = clips.last else { fatalError() }
                clips.append(AKFileClip(audioFile: audioFile,
                                        time: lastClip.endTime,
                                        offset: randomOffset(),
                                        duration: duration))
            }
            return clips
        }

        playButton.callback = { [drumPlayer, guitarPlayer] button in

            if drumPlayer.isPlaying {
                drumPlayer.stop()
                guitarPlayer.stop()
                guitarLooper.stop()
                drumLooper.stop()
                button.title = drumPlayer.isPlaying ? "Stop" : "Play"

            } else {
                drumPlayer.clips = randomChopClips(audioFile: drumFile,
                                                   chops: drumChops,
                                                   count: loops * drumChops)
                guitarPlayer.clips = randomChopClips(audioFile: guitarFile,
                                                     chops: guitarChops,
                                                     count: loops * guitarChops)

                drumPlayer.currentTime = 0
                guitarPlayer.currentTime = 0

                drumPlayer.prepare(withFrameCount: 44_100)
                guitarPlayer.prepare(withFrameCount: 44_100)

                drumLooper.schedule(from: 0, to: drumLooper.duration, avTime: nil)
                guitarLooper.schedule(from: 0, to: guitarLooper.duration, avTime: nil)

                let twoRendersTime = AKSettings.ioBufferDuration * 2
                let futureTime = AVAudioTime.now() + twoRendersTime

                drumLooper.play(at: futureTime)
                guitarLooper.play(at: futureTime)

                let loopDur = drumFile.duration
                drumPlayer.play(at: futureTime + loopDur)
                guitarPlayer.play(at: futureTime + loopDur * 2)

            }
            button.title = drumPlayer.isPlaying ? "Stop" : "Play"
        }
    }
}

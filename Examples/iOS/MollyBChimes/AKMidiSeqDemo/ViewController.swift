//
//  ViewController.swift
//  AKMidiSeqDemo
//
//  Created by Jeff Cooper on 1/16/16.
//  Copyright © 2016 Jeff Cooper. All rights reserved.
//
//  MollyBChimes Demo
//  the demo formerly named AKMidiDemo
//

import UIKit
import AudioKit

class ViewController: UIViewController {
    let midi = AKMIDI()

    var fmOsc1 = AKFMOscillatorBank()
    var melodicSound: AKMIDINode?
    var verb: AKReverb2?

    var bassDrumInst: BDInst?
    var bassDrum: AKMIDIInstrument?

    var snareDrumInst: SDInst?
    var snareDrum: AKMIDIInstrument?
    var snareGhostInst: SDInst?
    var snareGhost: AKMIDIInstrument?
    var snareMixer = AKMixer()
    var snareVerb: AKReverb?

    var seq = AKSequencer()
    var mixer = AKMixer()
    var pumper: AKCompressor?

    let scale1: [Int] = [0, 2, 4, 7, 9]
    let scale2: [Int] = [0, 3, 5, 7, 10]
    let seqLen = Beat(8.0)

    @IBOutlet var mollyButt: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        fmOsc1.modulatingMultiplier = 3
        fmOsc1.modulationIndex = 0.3

        melodicSound = AKMIDINode(node: fmOsc1)
        melodicSound?.enableMIDI(midi.client, name: "melodicSound midi in")
        verb = AKReverb2(melodicSound!)
        verb?.dryWetMix = 0.5
        verb?.decayTimeAt0Hz = 7
        verb?.decayTimeAtNyquist = 11
        verb?.randomizeReflections = 600
        verb?.gain = 1

        bassDrumInst = BDInst(voiceCount: 1)
        bassDrumInst?.amplitude = 1
        bassDrum = AKMIDIInstrument(instrument: bassDrumInst!)
        bassDrum?.enableMIDI(midi.client, name: "bassDrum midi in")

        snareDrumInst = SDInst(voiceCount: 1)
        snareDrumInst?.amplitude = 0.3
        snareDrum = AKMIDIInstrument(instrument: snareDrumInst!)
        snareDrum?.enableMIDI(midi.client, name: "snareDrum midi in")

        snareGhostInst = SDInst(voiceCount: 1, dur: 0.06, res: 0.3)
        snareGhostInst?.amplitude = 0.2
        snareGhost = AKMIDIInstrument(instrument: snareGhostInst!)
        snareGhost?.enableMIDI(midi.client, name: "snareGhost midi in")

        snareMixer.connect(snareDrum!)
        snareMixer.connect(snareGhost!)
        snareVerb = AKReverb(snareMixer)

        pumper = AKCompressor(mixer)

        pumper?.headRoom = 0.10
        pumper?.threshold = -15
        pumper?.masterGain = 15
        pumper?.attackTime = 0.01
        pumper?.releaseTime = 0.3

        mixer.connect(verb!)
        mixer.connect(bassDrum!)
        mixer.connect(snareDrum!)
        mixer.connect(snareGhost!)
        mixer.connect(snareVerb!)

        AudioKit.output = pumper
        AudioKit.start()

        seq.newTrack()
        seq.setLength(seqLen)
        seq.tracks[0].setMIDIOutput((melodicSound?.midiIn)!)
        genNewMelodicSequence(minor: false)

        seq.newTrack()
        seq.tracks[1].setMIDIOutput((bassDrum?.midiIn)!)
        genBDSeq()

        seq.newTrack()
        seq.tracks[2].setMIDIOutput((snareDrum?.midiIn)!)
        genSDSeq()

        seq.newTrack()
        seq.tracks[3].setMIDIOutput((snareGhost?.midiIn)!)
        genSDGhostSeq()

        seq.enableLooping()
        seq.setTempo(100)
        seq.play()
    }

    @IBAction func genSeqUI(sender: UIButton) {
        if(maybe() > 0.0) {
            genNewMelodicSequence(minor: true)
            print("minor")
        } else {
            genNewMelodicSequence(minor: false)
            print("major")
        }
        genBDSeq()
        genSDSeq()
        genSDGhostSeq()
    }

    @IBAction func genSDGhostSeqUI(sender: UIButton) {
        genSDGhostSeq(clear: false)
    }
    @IBAction func clearMeloSeqUI(sender: UIButton) {
        seq.tracks[0].clear()
    }
    @IBAction func clearBDSeqUI(sender: UIButton) {
        seq.tracks[1].clear()
    }
    @IBAction func clearSDSeqUI(sender: UIButton) {
        seq.tracks[2].clear()
    }
    @IBAction func clearSDGhostSeqUI(sender: UIButton) {
        seq.tracks[3].clear()
    }
    @IBAction func genMajorSeqUI(sender: UIButton) {
        genNewMelodicSequence(minor: false)
    }
    @IBAction func genMinorSeqUI(sender: UIButton) {
        genNewMelodicSequence(minor: true)
    }
    @IBAction func genBDSeqUI(sender: UIButton) {
        genBDSeq()
    }
    @IBAction func genBDHalfSeqUI(sender: UIButton) {
        genBDSeq(2)
    }
    @IBAction func genBDQrtrSeqUI(sender: UIButton) {
        genBDSeq(4)
    }
    @IBAction func genSDSeqUI(sender: UIButton) {
        genSDSeq()
    }
    @IBAction func genSDHalfSeqUI(sender: UIButton) {
        genSDSeq(2)
    }

    @IBAction func adjustBpm(sender: UISlider) {
        seq.setTempo(Double(sender.value))
        rotateElement(mollyButt, amount: (Float(M_PI) * sender.value/280.0) - 20.0)
    }

    func genNewMelodicSequence(stepSize: Float = 1/8, minor: Bool = false, clear: Bool = true) {
        if (clear) { seq.tracks[0].clear() }
        seq.setLength(seqLen)
        let numSteps = Int(Float(seqLen.value)/stepSize)
        //print("steps in seq: \(numSteps)")
        for i in 0 ..< numSteps {
            if (random(0, 16) > 12) {
                let step = Double(i) * stepSize
                //print("step is \(step)")
                let scale = (minor ? scale2 : scale1)
                let scaleOffset = random(0, Double(scale.count-1))
                var octaveOffset = 0
                for _ in 0 ..< 2 {
                    octaveOffset += Int(12 * ((maybe()*2.0)+(-1.0)))
                    octaveOffset = Int(maybe() * maybe() * Float(octaveOffset))
                }
                //print("octave offset is \(octaveOffset)")
                let noteToAdd = 60 + scale[Int(scaleOffset)] + octaveOffset
                seq.tracks[0].addNote(noteToAdd, velocity: 100, position: Beat(step), duration: Beat(1))
            }
        }
        seq.setLength(seqLen)
    }

    func genBDSeq(stepSize: Float = 1, clear: Bool = true) {
        if (clear) { seq.tracks[1].clear() }
        let numSteps = Int(Float(seqLen.value)/stepSize)
        for i in 0 ..< numSteps {
            let step = Double(i) * stepSize
            seq.tracks[1].addNote(60, velocity: 100, position: Beat(step), duration: Beat(1))
        }
    }

    func genSDSeq(stepSize: Float = 1, clear: Bool = true) {
        if (clear) { seq.tracks[2].clear() }
        let numSteps = Int(Float(seqLen.value)/stepSize)

        for i in 1.stride(to: numSteps, by: 2) {
            let step = (Double(i) * stepSize)
            seq.tracks[2].addNote(60, velocity: 80, position: Beat(step), duration: Beat(1))
        }
    }

    func genSDGhostSeq(stepSize: Float = 1/8, clear: Bool = true) {
        if (clear) { seq.tracks[3].clear() }
        let numSteps = Int(Float(seqLen.value)/stepSize)
        //print("steps in seq: \(numSteps)")
        for i in 0 ..< numSteps {
            if(random(0, 16) > 14.0) {
                let step = Double(i) * stepSize
                seq.tracks[3].addNote(60, velocity: Int(random(1, 66)), position: Beat(step), duration: Beat(0.1))
            }
        }
        seq.setLength(seqLen)
    }

    func rotateElement(element: UIView, amount: Float = Float(M_PI_2)) {
        element.transform = CGAffineTransformMakeRotation(CGFloat(amount))
    }

    func maybe()->Float {
        let maybeVal = random(0, 2)
        let outVal = Float((maybeVal > 1 ? 0 : 1))
        return (outVal)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}


class BDVoice: AKVoice {
    var generator: AKOperationGenerator
    var filt: AKMoogLadder?

    override init() {

        let frequency = AKOperation.lineSegment(AKOperation.trigger, start: 120, end: 40, duration: 0.03)
        let volSlide = AKOperation.lineSegment(AKOperation.trigger, start: 1, end: 0, duration: 0.3)
        let sine = AKOperation.sineWave(frequency: frequency, amplitude: volSlide)

        generator = AKOperationGenerator(operation: sine)
        filt = AKMoogLadder(generator)
        filt!.cutoffFrequency = 666
        filt!.resonance = 0.00

        super.init()
        avAudioNode = filt!.avAudioNode
        generator.start()
    }

    /// Function create an identical new node for use in creating polyphonic instruments
    override func duplicate() -> AKVoice {
        let copy = BDVoice()
        return copy
    }

    /// Tells whether the node is processing (ie. started, playing, or active)
    override var isStarted: Bool {
        return generator.isPlaying
    }

    /// Function to start, play, or activate the node, all do the same thing
    override func start() {
        generator.trigger()
    }

    /// Function to stop or bypass the node, both are equivalent
    override func stop() {

    }
}
class BDInst: AKPolyphonicInstrument {
    init(voiceCount: Int) {
        super.init(voice: BDVoice(), voiceCount: voiceCount)
    }
    override func playVoice(voice: AKVoice, note: Int, velocity: Int) {
        voice.start()
    }
    override func stopVoice(voice: AKVoice, note: Int) {

    }
}

class SDVoice: AKVoice {
    var generator: AKOperationGenerator
    var filt: AKMoogLadder?
    var len = 0.143

    init(dur: Double = 0.143, res: Double = 0.9) {
        len = dur
        let volSlide = AKOperation.lineSegment(AKOperation.trigger, start: 1, end: 0, duration: len)

        let white = AKOperation.whiteNoise(amplitude: volSlide)
        generator = AKOperationGenerator(operation: white)
        filt = AKMoogLadder(generator)
        filt!.cutoffFrequency = 1666
        resonance = res

        super.init()
        avAudioNode = filt!.avAudioNode
        generator.start()
    }

    internal var cutoff: Double = 1666 {
        didSet {
            filt?.cutoffFrequency = cutoff
        }
    }
    internal var resonance: Double = 0.3 {
        didSet {
            filt?.resonance = resonance
        }
    }

    /// Function create an identical new node for use in creating polyphonic instruments
    override func duplicate() -> AKVoice {
        let copy = SDVoice(dur: len, res:resonance)
        return copy
    }

    /// Tells whether the node is processing (ie. started, playing, or active)
    override var isStarted: Bool {
        return generator.isPlaying
    }

    /// Function to start, play, or activate the node, all do the same thing
    override func start() {
        generator.trigger()
    }

    /// Function to stop or bypass the node, both are equivalent
    override func stop() {

    }
}
class SDInst: AKPolyphonicInstrument {
    init(voiceCount: Int, dur: Double = 0.143, res: Double = 0.9) {
        super.init(voice: SDVoice(dur: dur, res:res), voiceCount: voiceCount)
    }
    override func playVoice(voice: AKVoice, note: Int, velocity: Int) {
        let tempVoice = voice as! SDVoice
        tempVoice.cutoff = (Double(velocity)/127.0 * 1600.0) + 300.0
        voice.start()
    }
    override func stopVoice(voice: AKVoice, note: Int) {

    }
}

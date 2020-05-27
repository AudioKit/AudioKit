// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit
import XCTest

class AKWaveTableTests: AKTestCase {

    var sampler: AKWaveTable?

    func testDefault() {
        afterStart = {
            self.sampler?.play()
        }
        AKTestMD5("72ff03c8f6b529625877f89f4c7325bf")
    }

    func testReversePlayback() {
        sampler?.startPoint = sampler!.size
        sampler?.endPoint.value = 0
        afterStart = {
            self.sampler?.play()
        }
        AKTestMD5("4ff8bf4506289ce8b4f5f26f6d3c77ac")
    }

    let startOffsetMD5 = "d06ca74db9d9e5ca6892a5c6b32b978c"

    func testStartOffset() {
        afterStart = {
            self.sampler?.play(from: 2_000)
        }
        AKTestMD5(startOffsetMD5)
    }

    func testStartOffsetUsingPoints() {
        sampler?.startPoint.value = 2_000
        afterStart = {
            self.sampler?.play()
        }
        AKTestMD5(startOffsetMD5)
    }

    let endOffsetMD5 = "4fead31c7eb9c03698e8b94e286aa7ac"

    func testEndOffset() {
        afterStart = {
            self.sampler?.play(from: 0, to: 300)
        }
        AKTestMD5(endOffsetMD5)
    }

    func testEndOffsetUsingSamplePoints() {
        sampler?.startPoint.value = 0
        sampler?.endPoint.value = 300
        afterStart = {
            self.sampler?.play()
        }
        AKTestMD5(endOffsetMD5)
    }

    let subsectionMD5 = "8ab03caca1d5011f73ad6e974ca6a9db"

    func testSampleSubsection() {
        afterStart = {
            self.sampler?.play(from: 300, to: 600)
        }
        AKTestMD5(subsectionMD5)
    }

    func testSampleSubsectionUsingSamplePoints() {
        sampler?.startPoint.value = 300
        sampler?.endPoint.value = 600
        afterStart = {
            self.sampler?.play()
        }
        AKTestMD5(subsectionMD5)
    }

    let subsectionResetMD5 = "aea154e169b0f37557c5d8f5a3380315"

    func testSampleSubsectionWithReset() {
        sampler?.completionHandler = {
            self.sampler?.play()
        }
        afterStart = {
            self.sampler?.play(from: 300, to: 600)
        }
        AKTestMD5(subsectionResetMD5)
    }

    func testSampleSubsectionWithResetUsingSamplePoints() {
        sampler?.completionHandler = {
            self.sampler?.startPoint.value = 0
            self.sampler?.endPoint = self.sampler!.size
            self.sampler?.play()
        }
        afterStart = {
            self.sampler?.startPoint.value = 300
            self.sampler?.endPoint.value = 600
            self.sampler?.play()
        }
        AKTestMD5(subsectionResetMD5)
    }

    func testForwardLoop() {
        sampler?.loopStartPoint.value = 100
        sampler?.loopEndPoint.value = 300
        sampler?.endPoint.value = 300
        sampler?.loopEnabled = true
        afterStart = {
            self.sampler?.play()
        }
        AKTestMD5("664e78be6d2d3a3daef538f981e20ecd")
    }

    func testReverseLoop() {
        sampler?.loopStartPoint.value = 300
        sampler?.loopEndPoint.value = 100
        sampler?.endPoint.value = 300
        sampler?.loopEnabled = true
        afterStart = {
            self.sampler?.play()
        }
        AKTestMD5("d8f001556a3efed4577101c2249b986c")
    }

    func setupSampler() {
        if let path = Bundle.main.path(forResource: "sinechirp", ofType: "wav") {
            let url = URL(fileURLWithPath: path)
            let file = try! AKAudioFile(forReading: url)
            sampler = AKWaveTable(file: file, maximumSamples: 1_024)
            output = sampler
        } else {
            XCTFail("Could not load sinechirp.wav")
        }
    }

    override func setUp() {
        super.setUp()
        setupSampler()
    }

}

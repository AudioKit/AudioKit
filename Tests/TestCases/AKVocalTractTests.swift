// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit

class AKVocalTractTests: AKTestCase {
    var vocalTract = AKVocalTract()

    override func setUp() {
        afterStart = { self.vocalTract.start() }
        vocalTract.rampDuration = 0
        vocalTract.start()
    }

    func testDefault() {
        output = vocalTract
        AKTestMD5("1e99cc28428af7353ca4f1dc1ba7cbca")
    }

    func testFrequency() {
        vocalTract.frequency.value = 444.5
        output = vocalTract
        AKTestMD5("2b396d9594b82055f08a0bc4fa920d7b")
    }

    func testNasality() {
        vocalTract.nasality.value = 0.6
        output = vocalTract
        AKTestMD5("71ecb9a92790fffae596c3f46c445f7e")
    }

    func testTenseness() {
        vocalTract.tenseness.value = 0.5
        output = vocalTract
        AKTestMD5("b68e8abc69646b53b0df69c1ba7e33aa")
    }

    func testTongueDiameter() {
        vocalTract.tongueDiameter.value = 0.4
        output = vocalTract
        AKTestMD5("35085ac510e12e74e6c4f0107bb6bfe9")
    }

    func testTonguePosition() {
        vocalTract.tonguePosition.value = 0.3
        output = vocalTract
        AKTestMD5("d959f6ad27f11640dab046ed3eca472b")
    }

    func testParametersSetAfterInit() {
        vocalTract.frequency.value = 234.5
        vocalTract.tonguePosition.value = 0.3
        vocalTract.tongueDiameter.value = 0.4
        vocalTract.tenseness.value = 0.5
        vocalTract.nasality.value = 0.6
        output = vocalTract
        AKTestMD5("0501c323ab9f99c3f6c8a43c74983eec")
    }

    func testParametersSetOnInit() {
        vocalTract = AKVocalTract(frequency: 234.5,
                                  tonguePosition: 0.3,
                                  tongueDiameter: 0.4,
                                  tenseness: 0.5,
                                  nasality: 0.6)
        output = vocalTract
        AKTestMD5("0501c323ab9f99c3f6c8a43c74983eec")
    }

}

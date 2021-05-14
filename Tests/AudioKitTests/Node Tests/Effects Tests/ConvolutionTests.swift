// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit
import AVFoundation
import XCTest

class ConvolutionTests: XCTestCase {

    func testConvolution() {
        guard let url = Bundle.module.url(forResource: "TestResources/drumloop", withExtension: "wav"),
              let file = try? AVAudioFile(forReading: url) else {
            XCTFail("Didn't generate test file")
            return
        }
        
        let engine = AudioEngine()
        let player = AudioPlayer()
        
        let dishURL = Bundle.module.url(forResource: "TestResources/dish", withExtension: "wav")!
        let convolution = Convolution(player,
                                      impulseResponseFileURL: dishURL,
                                      partitionLength: 8_192)
        

        engine.output = convolution
        
        
        
        let audio = engine.startTest(totalDuration: 2.0)
        player.file = file
        
        player.play()
        audio.append(engine.render(duration: 2.0))
        
        testMD5(audio)

    }
}



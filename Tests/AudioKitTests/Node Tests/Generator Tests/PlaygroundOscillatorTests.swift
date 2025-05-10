// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit
import AVFoundation
import Foundation
import GameplayKit
import XCTest

class PlaygroundOscillatorTests: XCTestCase {
    let engine = AudioEngine()

    override func setUp() {
        Settings.sampleRate = 44100
    }

    func testSine() {
        let data = test(waveform: .sine)

        XCTAssertEqual(
            data.visualDescription(),
            """
            Format 2 ch, 44100.0 Hz, deinterleaved, Float32
            Frame count 44100
            Frame capacity 44100

            7│                *                                            
            6│          ****** *****                                       
            5│        **            **                                     
            4│      **                **                                   
            3│     *                    *                                  
            2│   **                      **                                
            1│  *                          *                               
            0│ *                            **                            *
            1│                                *                          * 
            2│                                 **                      **  
            3│                                   *                    *    
            4│                                    **                **     
            5│                                      **            **       
            6│                                        ***** ******         
            7│                                             *               

            """
        )
    }

    func testTriangle() {
        let data = test(waveform: .triangle)
        XCTAssertEqual(
            data.visualDescription(),
            """
            Format 2 ch, 44100.0 Hz, deinterleaved, Float32
            Frame count 44100
            Frame capacity 44100

            7│                              **                             
            6│                            **  **                           
            5│                          **      **                         
            4│                        **          **                       
            3│                      **              **                     
            2│                    **                  **                   
            1│                  **                      **                 
            0│              ****                          ****             
            1│            **                                  **           
            2│          **                                      **         
            3│        **                                          **       
            4│      **                                              **     
            5│    **                                                  **   
            6│  **                                                      ** 
            7│ *                                                          *

            """
        )
    }

    func testPositiveSquare() {
        let data = test(waveform: .positiveSquare)
        XCTAssertEqual(
            data.visualDescription(),
            """
            Format 2 ch, 44100.0 Hz, deinterleaved, Float32
            Frame count 44100
            Frame capacity 44100

            7│                              *******************************
            6│                                                             
            5│                                                             
            4│                                                             
            3│                                                             
            2│                                                             
            1│                                                             
            0│ *****************************                               
            1│                                                             
            2│                                                             
            3│                                                             
            4│                                                             
            5│                                                             
            6│                                                             
            7│                                                             

            """
        )
    }
}

private extension PlaygroundOscillatorTests {
    func test(waveform: TableType) -> AVAudioPCMBuffer {
        let oscillator = PlaygroundOscillator(waveform: Table(waveform), frequency: 1)
        engine.output = oscillator
        oscillator.start()

        let data = engine.startTest(totalDuration: 1)
        data.append(engine.render(duration: 1))
        return data
    }
}

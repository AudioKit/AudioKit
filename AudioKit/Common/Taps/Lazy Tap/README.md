# Lazy Tap

Lazxy tap different from a normal tap in that you have to poll it for data, but this method allows for buffer re-use, so you can call it as quickly as you'd like.  

Here's an example of using AKLazyTap to get peak:

```
import UIKit
import AudioKit

class ViewController: UIViewController {

    let microphone = AKMicrophone()
    var tap: AKLazyTap?

    override func viewDidLoad() {
        super.viewDidLoad()


        AudioKit.output = microphone
        AKSettings.ioBufferDuration = 0.002 // This is to decrease latency for faster callbacks.

        tap = AKLazyTap(node: microphone.avAudioNode)

        guard tap != nil,
            let buffer = AVAudioPCMBuffer(pcmFormat: microphone.avAudioNode.outputFormat(forBus: 0), frameCapacity: 44100) else {
            fatalError()
        }

        // Your timer should fire equal to or faster than your buffer duration
        Timer.scheduledTimer(withTimeInterval: AKSettings.ioBufferDuration / 2, repeats: true) { _ in

            self.tap?.fillNextBuffer(buffer, timeStamp: nil)

            if buffer.frameLength == 0 { return } // This is important, since we're polling for samples, sometimes it's empty, and sometimes it will be double what it was the last call.

            let leftMono = UnsafeBufferPointer(start: buffer.floatChannelData?[0], count:Int(buffer.frameLength))
            var peak = Float(0)
            for sample in leftMono {
                peak = max(peak, fabsf(sample))
            }
            print("number of samples \(buffer.frameLength) peak \(peak)")

        }

        do {
            try AudioKit.start()         
        } catch {
            AKLog("AudioKit did not start!")
        }
    }
}
```
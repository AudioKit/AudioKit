//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## Non-Audio Tutorial
//: In the AudioKit Playgrounds, you'll learn a lot about processing audio,
//: but we won't explain most other basic programming concepts that we'll use.
//: So, here's a mini-tutorial of things that you should probably understand going forward.
//:
//: You will always see the `import` lines which bring in all of
//: AudioKit's functionality to the playground.
import AudioKitPlaygrounds
import AudioKit

//: If you intend to use some of the user interface elements provided by the optional AudioKitUI
//: framework, you will also need to import it.
import AudioKitUI

//: ALERT: This is also the line that most commonly shows an error "No such module"
//: This just means you haven't built AudioKitPlaygrounds yet, in which case pressing Cmd-B or
//: accessing the "Product" menu and choosing "Build".

//: To use a file, copy it intot playground's "Resources" folder and refer to it by name:
let file = try AKAudioFile(readFileName: "mixloop.wav")

//: You are not limited to using the sound files provided with AudioKit, in fact
//: we encourage you to drag your own sound files to the Resources folder.
//: Ideally, to keep things running quickly, loopable 10-20 second `.wav` or `.aiff`
//: files are recommended.  Many free loops are avaiable online at sites such as
//: [looperman.com](http://www.looperman.com/) or [freesound.org](http://www.freesound.org/).
//:
//: ![drag](http://audiokit.io/playgrounds/DragResource.gif "drag")
//:

//: While we will do our best to annotate the playgrounds well, you can also get
//: more information about the different code elements on the page by clicking
//: on them and looking at the Quick Help Inspector.  Or, you can also option-click
//: on any class, method, or variable name to show information about that element.
//: Try it with the lines below:
let player = AKPlayer(audioFile: file)
let effect = AKMoogLadder(player)

//: The following lines keep a playground executing even after the last line is
//: run so that the audio elements that were started have time to play and make
//: sounds for us to listen to.
import PlaygroundSupport
PlaygroundPage.current.needsIndefiniteExecution = true
//: The other ways we'll keep playgrounds running will by using `sleep` and `usleep`
//: functions and infinite while loops.

//: You can view the waveform on the timeline for any playground page by adding
//: the following lines if they don't exist.  The plot does not usually appear
//: by default because it takes significant power to draw the plots and we don't
//: want your laptop's fan to fire up and drain your battery unnecessarily
let plotView = AKOutputWaveformPlot.createView()
PlaygroundPage.current.liveView = plotView

//: Now that we are near the bottom of the screen (unless you have a majorly tall monitor!)
//: we'd like to call your attention to the playground controls on the
//: bottom left right below the navbar.
//:
//: The first button toggles the console log which can be useful to look at when
//: things go wrong. The second button is your play / stop button which is
//: useful to control playback of the audio in the playground. If you click and
//: hold on this button you will get a pop-up that will allow you choose between
//: automatically running the playground or manually pressing play.  They both
//: have their reason.  Automatic running is great for changing a parameter and
//: quickly hearing the audio results.   Manual Run is better for when you're in
//: the middle of creating an audio system and you don't want to hear results
//: until you're further along in the process.
//:
//: ![controls](http://audiokit.io/playgrounds/controls.png "controls")
//: ---
//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)

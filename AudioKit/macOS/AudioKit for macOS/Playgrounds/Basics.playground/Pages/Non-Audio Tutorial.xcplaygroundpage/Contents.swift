//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## Non-Audio Tutorial
//: ### In the AudioKit Playgrounds, you'll learn a lot about processing audio,
//: ### but we won't explain most other basic programming concepts that we'll use.
//: ### So, here's a mini-tutorial of things that you should probably understand going forward.
//:
//: You will always see the `import AudioKit` line which brings in all of
//: AudioKit's functionality to the playground.
import AudioKit

//: Another import line you will see in most playgrounds enables `XCPlayground` functions
//: for plotting, keeping the playground alive while audio plays, and more.
import XCPlayground

//: This main bundle line just helps the playground find the files (such as audio clips)
//: it will be able to play and process.
let bundle = NSBundle.mainBundle()

//: To reference a file, you use the bundle from about and the `pathForResource`
//: method that includes the name with the extension given in the `ofType` parameter.
let file = try AKAudioFile(readFileName: "PianoBassDrumLoop.wav", baseDir: .Resources)

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
let player = try AKAudioPlayer(file: file)
let effect = AKMoogLadder(player)

//: We'll often use the notation above which is `let variable = AKClass(input)`
//: but for the best code completion, this is equivalent to
//: `let variable = AKClass.init(input)` which has the added benefit of providing
//: better code completion and inline documentation.  This may not be necessary
//: as Xcode's support for Swift code completion improves.
let effect2 = AKMoogLadder.init(player)

//: Remember the `import XCPlayground` line above?  Here's one way that is used.
//: The following line keeps a playground executing even after the last line is
//: run so that the audio elements that were started have time to play and make
//: sounds for us to listen to.
XCPlaygroundPage.currentPage.needsIndefiniteExecution = true
//: The other ways we'll keep playgrounds running will by using `sleep` and `usleep`
//: functions and infinite while loops.

//: You can view the waveform on the timeline for any playground page by adding
//: the following lines if they don't exist.  The plot does not usually appear
//: by default because it takes significant power to draw the plots and we don't
//: want your laptop's fan to fire up and drain your battery unnecessarily
let plotView = AKOutputWaveformPlot.createView()
XCPlaygroundPage.currentPage.liveView = plotView

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

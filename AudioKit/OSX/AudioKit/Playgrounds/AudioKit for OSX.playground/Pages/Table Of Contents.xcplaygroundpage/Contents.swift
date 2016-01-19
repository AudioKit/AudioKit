//: # AudioKit for OSX Playgrounds
//:
//: AudioKit comes with Playgrounds built for both iOS and OS X because even though AudioKit is identical for all platforms, Xcode's playgrounds have different capabilities.  OS X Playgrounds allow you to create interactive windows with buttons and sliders that can interact with the code in the playground.  So, in iOS we have a lot of automatical loops that change values for the reader, but in OS X, we provide windows with sliders that you allow you to set the parameters you want to hear.  In addition, as of AudioKit 3.0, OS X Playgrounds do not register the custom audio units from AudioKit properly, so there is less to demonstrate in OS X.  As you can see, both playgrounds have their advantages and really you should use them both for what they're capable of.
//:
//: ## Getting Started
//:
//: Let's start off just making sure you're all set up and can make sound.
//:
//: * [Introduction](Intro)
//:
//: ## This is going to be fun...
//:
//: So wait, before we jump into the actual tutorials, let's just highlight some of the cooler sound playgrounds we have.  Don't try to understand the code if you're just started, it will all be expained starting with the next section, Basic Tutorials.
//:
//: * [Delay](Delay)
//: * [Time Stretching and Pitch Shifting](Time%20Stretching%20and%20Pitch%20Shifting)
//:
//: ## Basic Tutorials
//:
//: These tutorials help you get started with the basic concepts of AudioKit, starting with what you need to know about playgrounds in general and then moving on to sound creation and working with AudioKit nodes.
//:
//: * [Non-Audio Tutorial](Non-Audio%20Tutorial)
//: * [Connecting Nodes](Connecting%20Nodes)
//: * [Mixing Nodes](Mixing%20Nodes)
//: * [Splitting Nodes](Splitting%20Nodes)
//: * [Dry Wet Mixer](Dry%20Wet%20Mixer)
//:
//: ## Playback Nodes
//:
//: Over the course of viewing the playgrounds so far, you've come across AKAudioPlayer repeatedly.  It is a simple neough class that it doesn't require a playground of its own, but there are some playback-oriented nodes that are very useful and cool.
//:
//: * [Sampler Instrument - EXS24](Sampler%20Instrument%20-%20EXS24)
//: * [Sampler Instrument - Wav file](Sampler%20Instrument%20-%20Wav%20file)
//: * [Sequencer - Single output](Sequencer%20-%20Single%20output)
//: * [Sequencer - Multiple output](Sequencer%20-%20Multiple%20output)
//: * [Time Stretching and Pitch Shifting](Time%20Stretching%20and%20Pitch%20Shifting)
//:
//: ## Effect Processor Nodes
//:
//: Here is where we start presenting playgrounds with the purpose of demonstrating a particular type of node.  This section covers effect processors such as what you might find on a electric guitar pedal board.
//:
//: ### Delay Nodes
//:
//: Delay is a lot more powerful than simply repeating an earlier sound.  By varying parameters, you can get startlingly beautiful effects.
//:
//: * [Delay](Delay)
//:
//: ### Distortion
//:
//: Distortion is a category for nodes that do more than just filter a sound, and basically change something essential to the sound, usually making for a harsher sound, but that's a matter of taste.
//:
//: * [Decimator](Decimator)
//: * [Ring Modulation](Ring%20Modulation)
//: * [Complex Distortion](Complex%20Distortion)
//:
//: ### Dynamics Processing
//:
//: Dynamics processing is usually done at the mixing stage and involves changing the signal's output levels.
//:
//: * [Dynamics Processor](Dynamics%20Processor)
//: * [Peak Limiter](Peak%20Limiter)
//:
//: ### Filters
//:
//: * [Band Pass Filter](Band%20Pass%20Filter)
//: * [High Pass Filter](High%20Pass%20Filter)
//: * [High Shelf Filter](High%20Shelf%20Filter)
//: * [Low Pass Filter](Low%20Pass%20Filter)
//: * [Low  Shelf Filter](Low%20Shelf%20Filter)
//: * [Parametric Equalizer](Parametric%20Equalizer)
//:
//: ### Reverb
//:
//: These are the more traditional reverb efffects.
//:
//: * [Simple Reverb](Simple%20Reverb)


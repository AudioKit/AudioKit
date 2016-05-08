//: # Playgrounds Table of Contents
//:
//: AudioKit comes with many playgrounds, each of which serves to teach some core concept, demonstrate a particular generator or synthesizer, or just show off some wacky sounds that we've discovered.  Because there are so many playgrounds that are inter-related in different ways, the order of the playgrounds in Xcode is more or less alphabetical, however this index page lists all the the playgrounds grouped by category.  Playgrounds that fit into multiple categories are listed in each relevant category.
//:
//: ## Getting Started
//:
//: Let's start off just making sure you're all set up and can make sound.
//:
//: * [Introduction and Hello World](Introduction%20and%20Hello%20World)
//:
//: ## This is going to be fun...
//:
//: So wait, before we jump into the actual tutorials, let's just highlight some of the cooler sound playgrounds we have.  Don't try to understand the code if you're just started, it will all be expained starting with the next section, Basic Tutorials.
//:
//: * [Electro Drum Beat](Drum%20Synthesizers)
//: * [Filter Envelope](Filter%20Envelope)
//: * [Alien Apocalypse](Linear%20and%20Exponential%20Segment%20Operations)
//: * [Telephone](Telephone) - Dialtone, ringing, busy signal, and digits
//: * [EXS24 Sampler](Sampler%20Instrument%20-%20EXS24)
//: * [Crazy Drum Effects](Variable%20Delay)
//: * [Phase-Locked Vocoder](Phase-Locked%20Vocoder)
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
//: * [Balancing Nodes](Balancing%20Nodes)
//: * [Stereo Panning](Stereo%20Panning)
//:
//: ## Plotting
//:
//: Playgrounds are a very visually compelling interface and you create a few different ways  of seeing what is happening to your audio signal.
//:
//: * [Output Waveform Plot](Output%20Waveform%20Plot)
//: * [Rolling Output Plot](Rolling%20Output%20Plot)
//: * [Node Output Plot](Node%20Output%20Plot)
//: * [Node FFT Plot](Node%20FFT%20Plot)
//:
//: ## Audio Analysis
//:
//: * [Tracking Amplitude](Tracking%20Amplitude)
//: * [Tracking Frequency](Tracking%20Frequency)
//:
//: ## "Analog Synth X" Example Project
//:
//: AudioKit is shipped with an awesome synth example project and the following playgrounds are where we developed and tested out the effects for that synth.
//:
//: * [Fatten Effect](Fatten%20Effect)
//: * [Filter Section](Filter%20Section%20Example)
//: * [MultiDelay](MultiDelay%20Example)
//:
//: ## Designing Sound
//:
//: These playgrounds are inspired by the "Practicals" section of the book "Designing Sound", by Andy Farnell.  While this book is excellent, the examples are implemented in Pd, which is okay, I guess, but hey, this is AudioKit!
//:
//: * [Pedestrians](Pedestrians)
//: * [Telephone](Telephone) - Dialtone, ringing, busy signal, and digits
//:
//: Hopefully we'll add more practicals over time.  If you're interested in making more, submit a pull-request to git repo and we'll be sure to include them.
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
//: * [Phase-Locked Vocoder](Phase-Locked%20Vocoder)
//:
//: ## Generator Nodes
//:
//: ### Oscillators
//:
//: Oscillators are the bread and butter of audio synthesis and there's no shortage of them in AudioKit.
//:
//: * [FM Oscillator](FM%20Oscillator)
//: * [General Purpose Oscillator](General%20Purpose%20Oscillator)
//: * [Morphing Oscillator](Morphing%20Oscillator)
//: * [Sawtooth Oscillator](Sawtooth%20Oscillator)
//: * [Square Wave Oscillator](Square%20Wave%20Oscillator)
//: * [Triangular Wave Oscillator](Triangular%20Wave%20Oscillator)
//:
//: ### Noise Generators
//:
//: Two noise "colors" to start off with, but we aim to have a much larger spectrum soon.
//:
//: * [Pink Noise Generator](Pink%20Noise%20Generator)
//: * [White Noise Generator](White%20Noise%20Generator)
//:
//: ### Physical Models
//:
//: There are only a few of these to start off with, but we think they are a lot of fun and sound really good.  More on the way!
//:
//: * [Dripping Sounds](Dripping%20Sounds)
//: * [Plucked String](Plucked%20String)
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
//: * [Variable Delay](Variable%20Delay)
//:
//: ### Distortion
//:
//: Distortion is a category for nodes that do more than just filter a sound, and basically change something essential to the sound, usually making for a harsher sound, but that's a matter of taste.
//:
//: * [Bit Crush Effect](Bit%20Crush%20Effect)
//: * [Decimator](Decimator)
//: * [Ring Modulation](Ring%20Modulation)
//: * [Tanh Distortion](Tanh%20Distortion)
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
//: * [Amplitude Envelope](Amplitude%20Envelope)
//: * [Auto Wah Wah](Auto%20Wah%20Wah)
//: * [Band Pass Butterworth Filter](Band%20Pass%20Butterworth%20Filter)
//: * [Band Pass Filter](Band%20Pass%20Filter)
//: * [Band Reject Butterworth Filter](Band%20Reject%20Butterworth%20Filter)
//: * [Graphic Equalizer](Graphic%20Equalizer)
//: * [High Pass Butterworth Filter](High%20Pass%20Butterworth%20Filter)
//: * [High Pass Filter](High%20Pass%20Filter)
//: * [High Shelf Filter](High%20Shelf%20Filter)
//: * [Low Pass Butterworth Filter](Loiw%20Pass%20Butterworth%20Filter)
//: * [Low Pass Filter](Low%20Pass%20Filter)
//: * [Low  Shelf Filter](Low%20Shelf%20Filter)
//: * [Modal Resonance Filter](Modal%20Resonance%20Filter)
//: * [Moog Ladder Filter](Moog%20Ladder%20Filter)
//: * [Parametric Equalizer](Parametric%20Equalizer)
//: * [Roland TB-303 Filter](Roland%20TB-303%20Filter)
//: * [String Resonator](String%20Resonator)
//:
//: ### Reverb
//:
//: These are the more traditional reverb efffects.
//:
//: * [Simple Reverb](Simple%20Reverb)
//: * [iOS-only Reverb](iOS-only%20Reverb)
//: * [Sean Costello Reverb](Sean%20Costello%20Reverb)
//:
//: Convolution is included here because it often used for reverb effects, but it can do a lot more.
//:
//: * [Convolution](Convolution)
//:
//: Then there are "reverbs" that are more commonly used as components, not as a stand-alone effect.
//:
//: * [Comb Filter Reverb](Comb%20Filter%20Reverb)
//: * [Flat Frequency Response Reverb](Flat%20Frequency%20Response%20Reverb)
//:
//: ## Operations
//:
//: Operations are used to make the internals of a single node.
//:
//: * [Custom Generator](Custom%20Generator)
//: * [Low-Frequency Oscillating of Parameters](Low-Frequency%20Oscillating%20of%20Parameters)
//: * [Using Functions](Using%20Functions)
//: * [Using Functions Part 2](Using%20Functions%20Part%202)
//: * [Muli-tap Delay](Multi-tap%20Delay)
//:
//: Many of the types of things you can do in nodes are also possible with operations, but with great flexibility in how the parameters are changed over time.
//:
//: * [AutoPan Operation](AutoPan%20Operation)
//: * [AutoWah Operation](AutoWah%20Operation)
//: * [Bit Crush](Bit%20Crush%20Operation)
//: * [Clip](Clip%20Operation)
//: * [Drum Synthesizers](Drum%20Synthesizers)
//: * [Filter Envelope](Filter%20Envelope)
//: * [Flat Frequency Response Reverb](Flat%20Frequency%20Response%20Reverb%20Operation)
//: * [FM Oscillator](FM%20Oscillator%20Operation)
//: * [High Pass Filter](High%20Pass%20Filter%20Operation)
//: * [Linear and Exponential Segment Operations](Linear%20and%20Exponential%20Segment%20Operations)
//: * [Low Pass Filter](Low%20Pass%20Filter%20Operation)
//: * [Modal Resonance Filter](Modal%20Resonance%20Filter%20Operation)
//: * [Moog Ladder Filter](Moog%20Ladder%20Filter%20Operation)
//: * [Noise](Noise%20Operations)
//: * [Phasor](Phasor%20Operation)
//: * [Plucked String Operation](Plucked%20String%20Operation)
//: * [Sawtooth Wave Oscillator Operation](Sawtooth%20Wave%20Oscillator%20Operation)
//: * [Sean Costello Reverb ](Sean%20Costello%20Reverb%20Operation)
//: * [Variable Delay](Variable%20Delay%20Operation)
//:
//: ## Sporth
//:
//: Sporth is a simple but super-powerful stack-based audio processing language that you can run directly in AudioKit. Here are some examples.
//:
//: * [Sporth Based Generator](Sporth%20Based%20Generator)
//: * [Sporth Based Effect](Sporth%20Based%20Effect)
//:
//: ## Development
//:
//: These playgrounds are here basically for us to work on future AudioKit developments.  Proceed with caution!
//:
//: * [Parameter Ramp Time](Parameter%20Ramp%20Time)
//:
//: Hey you got all the way to the bottom of this file, why not let us know by emailing audiokit@audiokit.io.  We'd love to hear from you!
//:

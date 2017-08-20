//: # Synthesis Playgrounds
//:
//: AudioKit comes with many playgrounds, each of which serves to teach some
//: core concept, demonstrate a particular generator or synthesizer, or just
//: show off some wacky sounds that we've discovered.  Because there are so
//: many playgrounds that are inter-related in different ways, the order of the
//: playgrounds in Xcode is more or less alphabetical, however this index page
//: lists all the the playgrounds grouped by category.  Playgrounds that fit
//: into multiple categories are listed in each relevant category.
//:
//:
//: ## Designing Sound
//:
//: These playgrounds are inspired by the "Practicals" section of the book
//: "Designing Sound", by Andy Farnell.  While this book is excellent, the
//: examples are implemented in Pd, which is okay, I guess, but hey, this is AudioKit!
//:
//: * [Pedestrians](Pedestrians)
//: * [Telephone](Telephone) - Dialtone, ringing, busy signal, and digits
//:
//: Hopefully we'll add more practicals over time.  If you're interested in
//: making more, submit a pull-request to the git repository and we'll be sure to include them.
//:
//: ## Generator Nodes
//:
//: ### Oscillators
//:
//: Oscillators are the bread and butter of audio synthesis and there's no
//: shortage of them in AudioKit.
//:
//: * [Oscillator](Oscillator)
//: * [Oscillator Synth](Oscillator%20Synth)
//: * [FM Oscillator](FM%20Oscillator)
//: * [Morphing Oscillator](Morphing%20Oscillator)
//: * [Phase Distortion Oscillator](Phase%20Distortion%20Oscillator)
//: * [Pulse Width Modulation Oscillator](PWM%20Oscillator)
//: 
//: New in AudioKit 3.7 is Microtonality capability:
//:
//: * [Microtonality](Microtonality)
//:
//: Oscillators are the basis of many synths which also usually have envelopes:
//:
//: * [Amplitude Envelope](Amplitude%20Envelope)
//: * [Filter Envelope](Filter%20Envelope)
//:
//: There are also oscillator banks which are a collection of oscillators 
//: that allow you to play several notes at once (polyphony).
//:
//: * [Oscillator Bank](Oscillator%20Bank)
//: * [FM Oscillator Bank](FM%20Oscillator%20Bank)
//: * [Morphing Oscillator Bank](Morphing%20Oscillator%20Bank)
//: * [Phase Distortion Oscillator Bank](Phase%20Distortion%20Oscillator%20Bank)
//: * [Pulse Width Modulation Oscillator Bank](PWM%20Oscillator%20Bank)
//:
//: ### Noise Generators
//:
//: There are two noise "colors" to start off with, pink and white, 
//: but we aim to have a much larger spectrum soon.
//:
//: * [Noise Generators](Noise%20Generators)
//:
//: ### Physical Models
//:
//: These playgrounds highlight sound synthesis in which the intent is to
//: to model a real-life sound, instrument, or object.
//:
//: * [Drawbar Organ](Drawbar%20Organ)
//: * [Dripping Sounds](Dripping%20Sounds)
//: * [Drum Synthesizers](Drum%20Synthesizers)
//: * [Flute](Flute)
//: * [Mandolin](Mandolin)
//: * [Plucked String](Plucked%20String)
//: * [Vocal Tract](Vocal%20Tract)
//: * [Vocal Tract Operation](Vocal%20Tract%20Operation)
//:
//: ## Operations
//:
//: Many of the types of things you can do in nodes are also possible with operations,
//: but with great flexibility in how the parameters are changed over time.
//:
//: * [FM Oscillator](FM%20Oscillator%20Operation)
//: * [Segment Operations](Segment%20Operations)
//: * [Noise](Noise%20Operations)
//: * [Phasor](Phasor%20Operation)
//: * [Plucked String](Plucked%20String%20Operation)
//: * [Sawtooth Wave Oscillator](Sawtooth%20Wave%20Oscillator%20Operation)
//:
//: ### Sporth
//:
//: Sporth is a simple but super-powerful stack-based audio processing language
//: that you can run directly in AudioKit. This playground contains several examples of sound synthesis with Sporth.
//:
//: * [Sporth Based Generator](Sporth%20Based%20Generator)
//:

# Audiobus MIDI Sender
This project gives examples of how to:

* Use AKSequencer to send MIDI messages externally using AKCallbackInstrument
* Update the UI in response to AKSequencer events using AKCallbackInstrument
* Create MIDI Send ports that will be recognized by Audiobus 3
* Send MIDI data to Audiobus 3 MIDI receivers
* Allow Audiobus to control the transport for AKSequencer

#### IMPORTANT:
Minimally, to get this project to run, you will need to:

* Add AudioKit and Audiobus to the project
* Build the project, go to the Audiobus developer page, and get an API key:

1. You'll need to give a title (it doesn't matter what) to the 'aurg' port
1. Add 4 new MIDI Sender Ports, and give them the names 'MIDISend0' to 'MIDISend3', repsectively

* Paste your API key into the Audiobus.txt file



## Getting the Project Audiobus Compatible
This project uses the [SenderSynth](https://github.com/AudioKit/AudioKit/tree/master/Examples/iOS/SenderSynth) project as its starting point.  All of the steps needed to set up SenderSynth are also needed here (except, of course, making the synth).  The steps are:

* Importing AudioKit and adding Audiobus files
* Adding the bridging header for the Audiobus files
* Allowing the audio background mode and IAA
* Adding an Audiobus URL scheme
* Adding the AudioComponents info (you should still use 'aurg' as the type, even if your app is not going send audio - you can hide this port later)
* Including AudioKit's Audiobus.swift file
* Giving the app a unique display name
* Including an app icon (it won't work without it)
* Getting an API key from the Audiobus developer website


## Preparing AKSequencer for External MIDI
Normally, AKSequencer tracks are connected directly to MIDI Inputs, but if we want to send MIDI outside the app, we need to connect each track to an AKCallbackInstrument.  The callback function takes three arguments: MIDIStatus, MIDINoteNumber, and MIDIVelocity. Presumably, you'd want to send normal MIDI externally when Audiobus is not connected. Typically that setup would look like this:

```
let midi = AKMIDI()
let seq = AKSequencer()
let callbackInst = AKCallbackInstrument()
midi.openOutput()
        
let callbackTrack = seq.newTrack()
callbackTrack?.setMIDIOutput(callbackInst.midiIn)
callbackInst.callback = { status, note, velocity in
   if status == .noteOn {
       self.midi.sendNoteOnMessage(noteNumber: note, velocity: velocity)
   } else if status == .noteOff {
       self.midi.sendNoteOffMessage(noteNumber: note, velocity: velocity)
   }
}
```
For sending to Audiobus we will use this basic pattern, but send messages to Audiobus instead of CoreMIDI.
This pattern is also useful for getting the UI to respond to sequencer events (but these callbacks are called on a background thread, so make sure that UI updates are called explictly on the main thread).

## Setting up Audiobus MIDI
### Include Helper Files
Make sure to include the helper methods in the file Audiobus+MIDI.swift in your project.

### Creating Audiobus MIDISendPorts
First, call Audiobus.start() to instantiate the Audiobus controller, then add the MIDIPorts.  Adding MIDISendPorts involves two steps. First, create the port, then add it to the Audiobus controller:

```
Audiobus.start()

if let port = ABMIDISenderPort(name: "MIDISend", title: "MIDI Send") {
    Audiobus.addMIDISenderPort(port)
}
```
The 'name' is the internal port name, and the 'title' is the user-facing name.  You will need to enter the names and titles that your app uses exactly as they are in your code when you re-apply for the API key.  If they don't match, Audiobus will not let your app run.
Keep the references to the ports created in the first step, because you'll need to pass these references when sending messages to Audiobus.

### Sending NoteOn and NoteOff Messages
You can send messages by passing your ABMIDISendPort reference to the Audiobus Controller, along with the MIDI data:

```
Audiobus.sendNoteOnMessage(midiSendPort: midiSendPort, status: status, note: note, velocity: velocity)
```

These messages should also be sent from the AKCallbackInstrument connected to the AKSequencer.

### Letting Audiobus Shut Off CoreMIDI Messages
Obviously, you don't want to continue sending MIDI through AKMIDI when sending to Audiobus, or else each MIDI message would be sent twice.  Audiobus insists that you let it control when conventional MIDI messages can be sent.  They're very adamant about this. So you must send a closure to your Audiobus controller that will allow Audiobus to shut off the CoreMIDI messages.  In the example project, I have a flag ```coreMIDIIsActive``` which controls the flow of the MIDI messages in my callback:

```
fileprivate func noteOn(midiSendPort: ABMIDISenderPort, status: AKMIDIStatus, note: MIDINoteNumber, velocity: MIDIVelocity, channel: MIDIChannel = 0) {
    if coreMIDIIsActive {
        self.midi.sendNoteOnMessage(noteNumber: note, velocity: velocity, channel: channel)
    } else {
        Audiobus.sendNoteOnMessage(midiSendPort: midiSendPort, status: status, note: note, velocity: velocity)
    }
}
```

We give Audiobus complete control over this flag by sending the closure to the Audiobus controller:

```
Audiobus.setUpEnableCoreMIDIBlock { [weak self] isEnabled in
    guard let this = self else { return }  
    this.coreMIDIIsActive = isEnabled
}
```  
Some enableCoreMIDIBlock closure must be passed to the Audiobus controller, to give Audiobus control over your app's MIDI flow.

### Controlling App Transport
The Audiobus transport controls can control your app using an ```ABTrigger``` which you can add to your Audiobus controller.  Audiobus provides many different trigger types, but typically for a sequencer, ```ABTriggerTypePlayToggle``` would be appropriate.  You create the trigger and add it to the controller:

```
transportTrigger = ABTrigger(systemType: ABTriggerTypePlayToggle) { [weak self] trigger, ports in
    guard let this = self else { return }
    if this.isPlaying {
        this.stop()
    } else {
        this.play()
    }
}
Audiobus.addTrigger(transportTrigger)
```

You are responsible for updating the state of trigger.  This way you can keep the trigger informed about the state of your app when you are controlling it with internal transport controls:

```
func play() {
    isPlaying = true
    transportTrigger.state = ABTriggerStateSelected
    sequencer.play()
}
    
func stop() {
    isPlaying = false
    transportTrigger.state = ABTriggerStateNormal     
    sequencer.stop()
}
```


        
### Getting a New API Key
When this is all set up, you will need to get a new API key from the Audiobus developer site.  As in the SenderSynth example, you need to build your code and locate the plist file.  When you submit your plist file, the only port it will generate automatically is the 'aurg' (audio sender) port.  If your app doesn't send audio, it gives you the option to hide this port.
You must manually add MIDI sender ports and type in their names and titles.  These should match the names and titles you included in your code when you instantiated the ABMIDISenderPort:

```
let port = ABMIDISenderPort(name: "MIDISend", title: "MIDI Send") 
```
After you include your new API key in the Audiobus.txt file and run your app, if there are any problems, Audiobus will stop your app and print to the console fairly clear and detailed explanations of the problems.  But if the API key that you registered with does not include MIDI Sender Ports, then calls to 
```
Audiobus.addMIDISenderPort(port)
```
will crash your app with a bad thread error.





# AudioKit Filter Effects Example

![Filter Effects](http://audiokit.io/audiobus/filter-effects/filter-effects.png)

The process for creating the filter is very similar, but even so, its worth going through the process a second time to really solidify your understanding. It will be described here in slightly less detail.

The project will just create a few sliders for some standard AudioKit effects.

Create a single view application called Filter Effects


![Filter Project Start](http://audiokit.io/audiobus/filter-effects/project-start-filter.png)

Set up the effects
------------------

The AudioKit code here is a little bit longer than for the synth, mainly so we can offer quite a few effects:

```
import UIKit
import AudioKit

class ViewController: UIViewController {

    var delay: AKVariableDelay?
    var delayMixer: AKDryWetMixer?
    var reverb: AKCostelloReverb?
    var reverbMixer: AKDryWetMixer?
    var booster: AKBooster?

    override func viewDidLoad() {
        super.viewDidLoad()

        let input = AKStereoInput()

        delay = AKVariableDelay(input)
        delay?.rampDuration = 0.5 // Allows for some cool effects
        delayMixer = AKDryWetMixer(input, delay!)

        reverb = AKCostelloReverb(delayMixer!)
        reverbMixer = AKDryWetMixer(delayMixer!, reverb!)

        booster = AKBooster(reverbMixer!)

        AudioKit.output = booster
        do {
            try AudioKit.start()         
        } catch {
            AKLog("AudioKit did not start!")
        }
        Audiobus.start()

        setupUI()
    }
}
```

It's worth stating that this code will not run in the simulator because it requires an audio input device, which the simulator is not currently able to emulate.  I can't imagine that this won't ever be fixed by Apple, but for now, let's move on.

Set up the User Interface
-------------------------

While this may not be the case once the app is used within Audiobus, to run the app before we integrate Audiobus, add the following to the Info.plist: "Privacy - Microphone Usage Description" for which the string can not be blank (Xcode won't complain, but iTunes Connect will when you prepare the app for the App Store)

Add this UI Set up code to create the UI:

```
    override func viewDidLoad() {
        // All the code from before plus the next line:
        setupUI()
    }

    func setupUI() {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.alignment = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.spacing = 10

        stackView.addArrangedSubview(AKPropertySlider(
            property: "Delay Time",
            format: "%0.2f s",
            value: self.delay!.time, minimum: 0, maximum: 1,
            color: UIColor.green) { sliderValue in
                self.delay?.time = sliderValue
        })

        stackView.addArrangedSubview(AKPropertySlider(
            property: "Delay Feedback",
            format: "%0.2f",
            value: self.delay!.feedback, minimum: 0, maximum: 0.99,
            color: UIColor.green) { sliderValue in
                self.delay?.feedback = sliderValue
        })

        stackView.addArrangedSubview(AKPropertySlider(
            property: "Delay Mix",
            format: "%0.2f",
            value: self.delayMixer!.balance, minimum: 0, maximum: 1,
            color: UIColor.green) { sliderValue in
                self.delayMixer?.balance = sliderValue
        })

        stackView.addArrangedSubview(AKPropertySlider(
            property: "Reverb Feedback",
            format: "%0.2f",
            value: self.reverb!.feedback, minimum: 0, maximum: 0.99,
            color: UIColor.red) { sliderValue in
                self.reverb?.feedback = sliderValue
        })

        stackView.addArrangedSubview(AKPropertySlider(
            property: "Reverb Mix",
            format: "%0.2f",
            value: self.reverbMixer!.balance, minimum: 0, maximum: 1,
            color: UIColor.red) { sliderValue in
                self.reverbMixer?.balance = sliderValue
        })

        stackView.addArrangedSubview(AKPropertySlider(
            property: "Output Volume",
            format: "%0.2f",
            value: self.booster!.gain, minimum: 0, maximum: 2,
            color: UIColor.yellow) { sliderValue in
                self.booster?.gain = sliderValue
        })

        view.addSubview(stackView)

        stackView.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.9).isActive = true
        stackView.heightAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: 0.9).isActive = true

        stackView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        stackView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
    }

```
This should all work on your device at this point.  And now, we just need to do the configuration song and dance. :)

Install Audiobus
----------------
This is the same process as it was for the Sender Synth, except of course, for the name of the app.

Add the Audiobus Files
----------------------
This is the same as for a sender app, except you will want to name the bridging header according to the new app name: "FilterEffects-BridgingHeader.h"

Project Settings
----------------

This is also the same as the Project Settings section for the Sender Synth.  For the URLs use: io.audiokit.filtereffects and for the URL scheme use: "FilterEffects-1.0.audiobus".

Once that's done here are the steps for the filter port:

1. Open your app target screen within Xcode by selecting your project entry at the top of Xcode's Project Navigator, and selecting your app from under the "TARGETS" heading.

2. Select the "Info" tab.

3. If you don't already have an "AudioComponents" group, then under the "Custom iOS Target Properties" group, right-click and select "Add Row", then name it "AudioComponents". Set the type to "Array" in the second column.

4. Open up the "AudioComponents" group by clicking on the disclosure triangle, then right-click on "AudioComponents" and select "Add Row". Set the type of the row in the second column to "Dictionary". Now make sure the new row is selected, and open up the new group using its disclosure triangle.

5. Create five different new rows, by pressing Enter to create a new row and editing its properties:

6. "manufacturer" (of type String): This is a four letter code that you should make up for yourself.  For us at AudioKit, we use "AuKt", but you will need to have your own.

7. "type" (of type String): set this to "aurx", which means a "Remote Effect" unit.

8. "subtype" (of type String): set this to "filx", which stands for "Filter Example".

9. "name" (of type String): set this to "AudioKit: Filter"

10. "version" (of type Number): set this to an integer. "1" is a good place to start.

In the end your Info.plist should now have the following:

![AudioComponents in Filter App's Info.plist](http://audiokit.io/audiobus/filter-effects/audiocomponents-filter.png)

Register your App with Audiobus
-------------------------------
![Temporary Registration](http://audiokit.io/audiobus/filter-effects/temporary-registration-filter.png)

Again, this is similar to the Sender Synth registration.  Make sure you get a permanent registration with Audiobus when you're ready to submit to the App Store.


Conclusion (for Filter Apps)
----------------------------
Even easier the second time through right?

// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/
#if !os(tvOS)

import SwiftUI
import AVFoundation

open class PlaygroundConductor {

    let engine = AKEngine()
    public init() {}

    open func setup() {
        // override in subclass
    }

    open func start() {
        shutdown()
        setup()
        do {
            try engine.start()
        } catch {
            AKLog("AudioKit did not start! \(error)")
        }
    }

    open func shutdown() {
        do {
            engine.stop()
        } catch {
            AKLog("AudioKit did not stop! \(error)")
        }
    }
}

public struct PresetButton: View {
    var text: String
    var onTap: () -> Void

    public init(text: String, onTap: @escaping () -> Void) {
        self.text = text
        self.onTap = onTap
    }

    public var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10).foregroundColor(.gray)
            Text(text).onTapGesture {
                self.onTap()
            }
        }
    }
}

public struct ParameterSlider: View {
    var text: String
    var parameter: Binding<AUValue>
    var range: ClosedRange<AUValue>

    public init(text: String, parameter: Binding<AUValue>, range: ClosedRange<AUValue>) {
        self.text = text
        self.parameter = parameter
        self.range = range
    }

    public var body: some View {
        GeometryReader { gp in
            HStack {
                Spacer()
                Text(self.text).frame(width: gp.size.width * 0.2)
                Slider(value: self.parameter, in: self.range).frame(width: gp.size.width / 2)
                Text("\(self.parameter.wrappedValue)").frame(width: gp.size.width * 0.2)
                Spacer()
            }
        }
    }
}

#endif

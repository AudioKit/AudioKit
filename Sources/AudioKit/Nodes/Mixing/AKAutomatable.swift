// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AVFoundation
import CAudioKit

public protocol AKAutomatable: AnyObject {
    var parameterAutomation: AKParameterAutomation? { get }
}

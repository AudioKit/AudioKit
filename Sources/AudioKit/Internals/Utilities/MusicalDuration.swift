import Foundation

public enum MusicalDuration: Int, CaseIterable {
    case thirtysecond
    case thirtysecondDotted
    case sixteenth
    case sixteenthDotted
    case eighth
    case eighthDotted
    case quarter
    case quarterDotted
    case half
    case halfDotted
    case whole
    case wholeDotted

    public var multiplier: Double {
        switch self {
        case .thirtysecond:
            return 1.0 / 32.0
        case .thirtysecondDotted:
            return 1.0 / 32.0 * (3.0 / 2.0)
        case .sixteenth:
            return 1.0 / 16.0
        case .sixteenthDotted:
            return 1.0 / 16.0 * (3.0 / 2.0)
        case .eighth:
            return 0.125
        case .eighthDotted:
            return 0.125 * (3.0 / 2.0)
        case .quarter:
            return 0.25
        case .quarterDotted:
            return 0.25 * (3.0 / 2.0)
        case .half:
            return 0.5
        case .halfDotted:
            return 0.5 * (3.0 / 2.0)
        case .whole:
            return 1
        case .wholeDotted:
            return 3.0 / 2.0
        }
    }

    public var description: String {
        switch self {
        case .thirtysecond:
            return "1/32"
        case .thirtysecondDotted:
            return "1/32 D"
        case .sixteenth:
            return "1/16"
        case .sixteenthDotted:
            return "1/16 D"
        case .eighth:
            return "1/8"
        case .eighthDotted:
            return "1/8 D"
        case .quarter:
            return "1/4"
        case .quarterDotted:
            return "1/4 D"
        case .half:
            return "1/2"
        case .halfDotted:
            return "1/2 D"
        case .whole:
            return "1"
        case .wholeDotted:
            return "1 D"
        }
    }

    public var next: MusicalDuration {
        return MusicalDuration(rawValue: (rawValue + 1) % MusicalDuration.allCases.count) ?? .eighth
    }

    public var previous: MusicalDuration {
        var newValue = rawValue - 1
        while newValue < 0 {
            newValue += MusicalDuration.allCases.count
        }
        return MusicalDuration(rawValue: newValue) ?? .eighth
    }
}

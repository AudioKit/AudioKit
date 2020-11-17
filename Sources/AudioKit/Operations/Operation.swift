// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

/// A computed parameter differs from a regular parameter in that it only exists within an operation
/// (unlike float, doubles, and ints which have a value outside of an operation)
public protocol ComputedParameter: OperationParameter {}

/// An Operation is a computed parameter that can be passed to other operations in the same operation node
open class Operation: ComputedParameter {

    // MARK: - Dependency Management

    fileprivate var inputs = [OperationParameter]()

    internal var savedLocation = -1

    fileprivate var dependencies = [Operation]()

    internal var recursiveDependencies: [Operation] {
        var all = [Operation]()
        var uniq = [Operation]()
        var added = Set<String>()
        for dep in dependencies {
            all += dep.recursiveDependencies
            all.append(dep)
        }

        for elem in all {
            if !added.contains(elem.inlineSporth) {
                uniq.append(elem)
                added.insert(elem.inlineSporth)
            }
        }

        return uniq
    }

    // MARK: - String Representations

    fileprivate var valueText = ""
    internal var setupSporth = ""
    fileprivate var module = ""

    internal var inlineSporth: String {
        if valueText != "" {
            return valueText
        }
        var opString = ""
        for input in inputs {
            if type(of: input) == Operation.self {
                if let operation = input as? Operation {
                    if operation.savedLocation >= 0 {
                        opString += "\(operation.savedLocation) \"ak\" tget "
                    } else {
                        opString += operation.inlineSporth
                    }
                }
            } else {
                opString  += "\(input) "
            }
        }
        opString  += "\(module) "
        return opString
    }

    func getSetup() -> String {
        return setupSporth == "" ? "" : setupSporth + " "
    }

    /// Final sporth string when this operation is the last operation in the stack
    internal var sporth: String {
        let rd = recursiveDependencies
        var str = ""
        if rd.isNotEmpty {
            str = #""ak" ""#
            str += rd.compactMap { _ in "0" }.joined(separator: " ")
            str += #"" gen_vals "#

            var counter = 0
            for op in rd {
                op.savedLocation = counter
                str += op.getSetup()
                str += op.inlineSporth + "\(op.savedLocation) \"ak\" tset "
                counter += 1
            }
        }
        str += getSetup()
        str += inlineSporth

        return str
    }

    /// Redefining description to return the operation string
    open var description: String {
        return inlineSporth
    }

    // MARK: - Inputs

    /// Left input to any stereo operation
    public static var leftInput = Operation("(14 p) ")

    /// Right input to any stereo operation
    public static var rightInput = Operation("(15 p) ")

    /// Dummy trigger
    public static var trigger = Operation("(14 p) ")

    // MARK: - Functions

    /// An= array of 14 parameters which may be sent to operations
    public static var parameters: [Operation] =
        [Operation("(0 p) "),
         Operation("(1 p) "),
         Operation("(2 p) "),
         Operation("(3 p) "),
         Operation("(4 p) "),
         Operation("(5 p) "),
         Operation("(6 p) "),
         Operation("(7 p) "),
         Operation("(8 p) "),
         Operation("(9 p) "),
         Operation("(10 p) "),
         Operation("(11 p) "),
         Operation("(12 p) "),
         Operation("(13 p) ")]

    /// Convert the operation to a mono operation
    public func toMono() -> Operation {
        return self
    }

    /// Performs absolute value on the operation
    public func abs() -> Operation {
        return Operation(module: "abs", inputs: self)
    }

    /// Performs floor calculation on the operation
    public func floor() -> Operation {
        return Operation(module: "floor", inputs: self)
    }

    /// Returns the fractional part of the operation (as opposed to the integer part)
    public func fract() -> Operation {
        return Operation(module: "frac", inputs: self)
    }

    /// Performs natural logarithm on the operation
    public func log() -> Operation {
        return Operation(module: "log", inputs: self)
    }

    /// Performs Base 10 logarithm on the operation
    public func log10() -> Operation {
        return Operation(module: "log10", inputs: self)
    }

    /// Rounds the operation to the nearest integer
    public func round() -> Operation {
        return Operation(module: "round", inputs: self)
    }

    /// Returns a frequency for a given MIDI note number
    public func midiNoteToFrequency() -> Operation {
        return Operation(module: "mtof", inputs: self)
    }

    // MARK: - Initialization

    /// Initialize the operation as a constant value
    ///
    /// - parameter value: Constant value as an operation
    ///
    public init(_ value: Double) {
        self.valueText = "\(value)"
    }

    init(global: String) {
        self.valueText = global
    }

    /// Initialize the operation with a Sporth string
    ///
    /// - parameter operationString: Valid Sporth string (proceed with caution
    ///
    public init(_ operationString: String) {
        self.valueText = operationString
        //self.tableIndex = -1 //Operation.nextTableIndex
        //Operation.nextTableIndex += 1
        //Operation.operationArray.append(self)
    }

    /// Initialize the operation
    ///
    /// - parameter module: Sporth unit generator
    /// - parameter setup:  Any setup Sporth code that this operation may require
    /// - parameter inputs: All the parameters of the operation
    ///
    public init(module: String, setup: String = "", inputs: OperationParameter...) {
        self.module = module
        self.setupSporth = setup
        self.inputs = inputs

        for input in inputs {
            if type(of: input) == Operation.self {
                if let forcedInput = input as? Operation {
                    dependencies.append(forcedInput)
                }
            }
        }
    }
}

// MARK: - Global Functions

/// Performs absolute value on the operation
///
/// - parameter parameter: ComputedParameter to operate on
///
public func abs(_ parameter: Operation) -> Operation {
    return parameter.abs()
}

/// Performs floor calculation on the operation
///
/// - parameter operation: ComputedParameter to operate on
///
public func floor(_ operation: Operation) -> Operation {
    return operation.floor()
}

/// Returns the fractional part of the operation (as opposed to the integer part)
///
/// - parameter operation: ComputedParameter to operate on
///
public func fract(_ operation: Operation) -> Operation {
    return operation.fract()
}

/// Performs natural logarithm on the operation
///
/// - parameter operation: ComputedParameter to operate on
///
public func log(_ operation: Operation) -> Operation {
    return operation.log()
}

/// Performs Base 10 logarithm on the operation
///
/// - parmeter operation: ComputedParameter to operate on
///
public func log10(_ operation: Operation) -> Operation {
    return operation.log10()

}

/// Rounds the operation to the nearest integer
///
/// - parameter operation: ComputedParameter to operate on
///
public func round(_ operation: Operation) -> Operation {
    return operation.round()
}

// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

/// Stereo version of AKComputedParameter
open class AKStereoOperation: AKComputedParameter {

    // MARK: - Dependency Management

    fileprivate var inputs = [AKParameter]()

    fileprivate var savedLocation = -1

    fileprivate var dependencies = [AKOperation]()

    internal var recursiveDependencies: [AKOperation] {
        var all = [AKOperation]()
        var uniq = [AKOperation]()
        var added = Set<String>()
        for dep in dependencies {
            all += dep.recursiveDependencies
            all.append(dep)
        }

        for elem in all {
            if ❗️added.contains(elem.inlineSporth) {
                uniq.append(elem)
                added.insert(elem.inlineSporth)
            }
        }

        return uniq
    }

    // MARK: - String Representations

    fileprivate var valueText = ""
    fileprivate var module = ""
    internal var setupSporth = ""

    fileprivate var inlineSporth: String {
        if valueText != "" {
            return valueText
        }
        var opString = ""
        for input in inputs {
            if type(of: input) == AKOperation.self {
                if let operation = input as? AKOperation {
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
        var str = #""ak" ""#
        str += rd.compactMap { _ in "0" }.joined(separator: " ")
        str += #"" gen_vals "#

        var counter = 0
        for op in rd {
            op.savedLocation = counter
            str += op.getSetup()
            str += op.inlineSporth + "\(op.savedLocation) \"ak\" tset "
            counter += 1
        }
        str += getSetup()
        str += inlineSporth
        return str
    }

    /// Redefining description to return the operation string
    open var description: String {
        return inlineSporth
    }

    // MARK: - Functions

    /// Create a mono signal by dropping the right channel
    public func toMono() -> AKOperation {
        return AKOperation(module: "add", inputs: self)
    }

    /// Create a mono signal by dropping the right channel
    public func left() -> AKOperation {
        return AKOperation(module: "drop", inputs: self)
    }

    /// Create a mono signal by dropping the left channel
    public func right() -> AKOperation {
        return AKOperation(module: "swap drop", inputs: self)
    }

    /// An operation is requiring a parameter to be stereo, which in this case, it is, so just return self
    public func toStereo() -> AKStereoOperation {
        return self
    }

    // MARK: - Initialization

    /// Default stereo input to any operation stack
    public static var input = AKStereoOperation("((14 p) (15 p))")

    /// Initialize the stereo operation with a Sporth string
    ///
    /// - parameter operationString: Valid Sporth string (proceed with caution
    ///
    public init(_ operationString: String) {
        self.valueText = operationString
    }

    /// Initialize the stereo operation
    ///
    /// - parameter module: Sporth unit generator
    /// - parameter setup:  Any setup Sporth code that this operation may require
    /// - parameter inputs: All the parameters of the operation
    ///
    public init(module: String, setup: String = "", inputs: AKParameter...) {
        self.module = module
        self.setupSporth = setup
        self.inputs = inputs

        for input in inputs {
            if type(of: input) == AKOperation.self {
                if let forcedInput = input as? AKOperation {
                    dependencies.append(forcedInput)
                }
            }
        }
    }
}

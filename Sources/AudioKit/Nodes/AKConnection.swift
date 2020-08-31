// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AVFoundation

/// A transitory used to pass connection information.
open class AKInputConnection: NSObject {

    open var node: AKInputCrap
    open var bus: Int
    public init(node: AKInputCrap, bus: Int) {
        self.node = node
        self.bus = bus
        super.init()
    }
    open var avConnection: AVAudioConnectionPoint {
        return AVAudioConnectionPoint(node: self.node.inputNode, bus: bus)
    }
}

/// Simplify making connections from a node.
public protocol AKOutput: AnyObject {

    /// The output of this node can be connected to the inputNode of an AKInput.
    var outputNode: AVAudioNode { get }
}

extension AKOutput {

    /// Output connection points of outputNode.
    public var connectionPoints: [AVAudioConnectionPoint] {
        get { return outputNode.engine?.outputConnectionPoints(for: outputNode, outputBus: 0) ?? [] }
        set { AKManager.connect(outputNode, to: newValue, fromBus: 0, format: AKSettings.audioFormat) }
    }

    /// Disconnects all outputNode's output connections.
    public func disconnectOutput() {
        AKManager.engine.disconnectNodeOutput(outputNode)
    }

    /// Breaks connection from outputNode to an input's node if exists.
    ///   - Parameter from: The node that output will disconnect from.
    public func disconnectOutput(from: AKInputCrap) {
        connectionPoints = connectionPoints.filter({ $0.node != from.inputNode })
    }

    /// Add a connection to an input using the input's nextInput for the bus.
    @discardableResult public func connect(to node: AKInputCrap) -> AKInputCrap {
        return connect(to: node, bus: node.nextInput.bus)
    }

    /// Add a connection to input.node on input.bus.
    ///   - Parameter input: Contains node and input bus used to make a connection.
    @discardableResult public func connect(to input: AKInputConnection) -> AKInputCrap {
        return connect(to: input.node, bus: input.bus)
    }

    /// Add a connection to node on a specific bus.
    @discardableResult public func connect(to node: AKInputCrap, bus: Int) -> AKInputCrap {
        connectionPoints.append(AVAudioConnectionPoint(node: node.inputNode, bus: bus))
        return node
    }

    /// Add an output connection to each input in inputs.
    ///   - Parameter nodes: Inputs that will be connected to.
    @discardableResult public func connect(to nodes: [AKInputCrap]) -> [AKInputCrap] {
        connectionPoints += nodes.map { $0.nextInput }.map { $0.avConnection }
        return nodes
    }

    /// Add an output connection to each connectionPoint in toInputs.
    ///   - Parameter toInputs: Inputs that will be connected to.
    @discardableResult public func connect(toInputs: [AKInputConnection]) -> [AKInputCrap] {
        connectionPoints += toInputs.map { $0.avConnection }
        return toInputs.map { $0.node }
    }

    /// Add an output connectionPoint.
    ///   - Parameter connectionPoint: Input that will be connected to.
    public func connect(to connectionPoint: AVAudioConnectionPoint) {
        connectionPoints.append(connectionPoint)
    }

    /// Sets output connection, removes existing output connections.
    ///   - Parameter node: Input that output will be connected to.
    @discardableResult public func setOutput(to node: AKInputCrap) -> AKInputCrap {
        return setOutput(to: node, bus: node.nextInput.bus, format: AKSettings.audioFormat)
    }

    /// Sets output connection, removes previously existing output connections.
    ///   - Parameter node: Input that output will be connected to.
    ///   - Parameter bus: The bus on the input that the output will connect to.
    ///   - Parameter format: The format of the connection.
    @discardableResult public func setOutput(to node: AKInputCrap, bus: Int, format: AVAudioFormat?) -> AKInputCrap {
        AKManager.connect(outputNode, to: node.inputNode, fromBus: 0, toBus: bus, format: format)
        return node
    }

    /// Sets output connections to an array of inputs, removes previously existing output connections.
    ///   - Parameter nodes: Inputs that output will be connected to.
    ///   - Parameter format: The format of the connections.
    @discardableResult public func setOutput(to nodes: [AKInputCrap], format: AVAudioFormat?) -> [AKInputCrap] {
        setOutput(to: nodes.map { $0.nextInput.avConnection }, format: format)
        return nodes
    }

    /// Sets output connections to an array of inputConnectios, removes previously existing output connections.
    ///   - Parameter toInputs: Inputs that output will be connected to.
    @discardableResult public func setOutput(toInputs: [AKInputConnection]) -> [AKInputCrap] {
        return setOutput(toInputs: toInputs, format: AKSettings.audioFormat)
    }

    /// Sets output connections to an array of inputConnectios, removes previously existing output connections.
    ///   - Parameter toInputs: Inputs that output will be connected to.
    ///   - Parameter format: The format of the connections.
    ///  - returns: Array of input connections
    @discardableResult public func setOutput(toInputs: [AKInputConnection], format: AVAudioFormat?) -> [AKInputCrap] {
        setOutput(to: toInputs.map { $0.avConnection }, format: format)
        return toInputs.map { $0.node }
    }

    /// Sets output connections to a single connectionPoint, removes previously existing output connections.
    ///   - Parameter connectionPoint: Input that output will be connected to.
    public func setOutput(to connectionPoint: AVAudioConnectionPoint) {
        setOutput(to: connectionPoint, format: AKSettings.audioFormat)
    }

    /// Sets output connections to a single connectionPoint, removes previously existing output connections.
    ///   - Parameter connectionPoint: Input that output will be connected to.
    ///   - Parameter format: The format of the connections.
    public func setOutput(to connectionPoint: AVAudioConnectionPoint, format: AVAudioFormat?) {
        setOutput(to: [connectionPoint], format: format)
    }

    /// Sets output connections to an array of connectionPoints, removes previously existing output connections.
    ///   - Parameter connectionPoints: Inputs that output will be connected to.
    ///   - Parameter format: The format of the connections.
    public func setOutput(to connectionPoints: [AVAudioConnectionPoint], format: AVAudioFormat?) {
        AKManager.connect(outputNode, to: connectionPoints, fromBus: 0, format: format)
    }

}

/// Manages connections to inputNode.
public protocol AKInputCrap: AKOutput {

    /// The node that an output's node can connect to.  Default implementation will return outputNode.
    var inputNode: AVAudioNode { get }

    /// The input bus that should be used for an input connection.  Default implementation is 0.  Multi-input nodes
    /// should return an open bus.
    ///
    ///   - Return: An inputConnection object conatining self and the input bus to use for an input connection.
    var nextInput: AKInputConnection { get }

    /// Disconnects all inputs
    func disconnectInput()

    /// Disconnects input on a bus.
    func disconnectInput(bus: Int)

    /// Creates an input connection object with a bus number.
    ///   - Return: An inputConnection object conatining self and the input bus to use for an input connection.
    func input(_ bus: Int) -> AKInputConnection
}

extension AKInputCrap {
    public var inputNode: AVAudioNode {
        return outputNode
    }
    public func disconnectInput() {
        AKManager.engine.disconnectNodeInput(inputNode)
    }
    public func disconnectInput(bus: Int) {
        AKManager.engine.disconnectNodeInput(inputNode, bus: bus )
    }
    public var nextInput: AKInputConnection {

        if let mixer = inputNode as? AVAudioMixerNode {
            return input(mixer.nextAvailableInputBus)
        }
        return input(0)
    }
    public func input(_ bus: Int) -> AKInputConnection {
        return AKInputConnection(node: self, bus: bus)
    }

}

extension AVAudioNode: AKInputCrap {
    public var outputNode: AVAudioNode {
        return self
    }
}


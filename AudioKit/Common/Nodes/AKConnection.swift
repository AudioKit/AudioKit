//
//  AKConnection.swift
//  AudioKit
//
//  Created by David O'Neill on 8/12/17.
//  Copyright © 2017 AudioKit. All rights reserved.
//

/// A transitory used to pass connection information.
open class AKInputConnection: NSObject {

    open var node: AKInput
    open var bus: Int
    public init(node: AKInput, bus: Int) {
        self.node = node
        self.bus = bus
        super.init()
    }
    open var avConnection: AVAudioConnectionPoint {
        return AVAudioConnectionPoint(node: self.node.inputNode, bus: bus)
    }
}

/// Simplify making connections from a node.
@objc public protocol AKOutput: class {

    /// The output of this node can be connected to the inputNode of an AKInput.
    var outputNode: AVAudioNode { get }
}

extension AKOutput {

    /// Output connection points of outputNode.
    public var connectionPoints: [AVAudioConnectionPoint] {
        get { return outputNode.engine?.outputConnectionPoints(for: outputNode, outputBus: 0) ?? [] }
        set { AudioKit.connect(outputNode, to: newValue, fromBus: 0, format: AudioKit.format) }
    }

    /// Disconnects all outputNode's output connections.
    public func disconnectOutput() {
        AudioKit.engine.disconnectNodeOutput(outputNode)
    }

    /// Breaks connection from outputNode to an input's node if exists.
    ///   - Parameter from: The node that output will disconnect from.
    public func disconnectOutput(from: AKInput) {
        connectionPoints = connectionPoints.filter({ $0.node != from.inputNode })
    }

    /// Add a connection to an input using the input's nextInput for the bus.
    @discardableResult public func connect(to node: AKInput) -> AKInput {
        return connect(to: node, bus: node.nextInput.bus)
    }

    /// Add a connection to input.node on input.bus.
    ///   - Parameter input: Contains node and input bus used to make a connection.
    @discardableResult public func connect(to input: AKInputConnection) -> AKInput {
        return connect(to: input.node, bus: input.bus)
    }

    /// Add a connection to node on a specific bus.
    @discardableResult public func connect(to node: AKInput, bus: Int) -> AKInput {
        connectionPoints.append(AVAudioConnectionPoint(node: node.inputNode, bus: bus))
        return node
    }

    /// Add an output connection to each input in inputs.
    ///   - Parameter nodes: Inputs that will be connected to.
    @discardableResult public func connect(to nodes: [AKInput]) -> [AKInput] {
        connectionPoints += nodes.map { $0.nextInput }.map { $0.avConnection }
        return nodes
    }

    /// Add an output connection to each connectionPoint in toInputs.
    ///   - Parameter toInputs: Inputs that will be connected to.
    @discardableResult public func connect(toInputs: [AKInputConnection]) -> [AKInput] {
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
    @discardableResult public func setOutput(to node: AKInput) -> AKInput {
        return setOutput(to: node, bus: node.nextInput.bus, format: AudioKit.format)
    }

    /// Sets output connection, removes previously existing output connections.
    ///   - Parameter node: Input that output will be connected to.
    ///   - Parameter bus: The bus on the input that the output will connect to.
    ///   - Parameter format: The format of the connection.
    @discardableResult public func setOutput(to node: AKInput, bus: Int, format: AVAudioFormat?) -> AKInput {
        AudioKit.connect(outputNode, to: node.inputNode, fromBus: 0, toBus: bus, format: format)
        return node
    }

    /// Sets output connections to an array of inputs, removes previously existing output connections.
    ///   - Parameter nodes: Inputs that output will be connected to.
    ///   - Parameter format: The format of the connections.
    @discardableResult public func setOutput(to nodes: [AKInput], format: AVAudioFormat?) -> [AKInput] {
        setOutput(to: nodes.map { $0.nextInput.avConnection }, format: format)
        return nodes
    }

    /// Sets output connections to an array of inputConnectios, removes previously existing output connections.
    ///   - Parameter toInputs: Inputs that output will be connected to.
    @discardableResult public func setOutput(toInputs: [AKInputConnection]) -> [AKInput] {
        return setOutput(toInputs: toInputs, format: AudioKit.format)
    }

    /// Sets output connections to an array of inputConnectios, removes previously existing output connections.
    ///   - Parameter toInputs: Inputs that output will be connected to.
    ///   - Parameter format: The format of the connections.
    @discardableResult public func setOutput(toInputs: [AKInputConnection], format: AVAudioFormat?) -> [AKInput] {
        setOutput(to: toInputs.map { $0.avConnection }, format: format)
        return toInputs.map { $0.node }
    }

    /// Sets output connections to a single connectionPoint, removes previously existing output connections.
    ///   - Parameter connectionPoint: Input that output will be connected to.
    public func setOutput(to connectionPoint: AVAudioConnectionPoint) {
        setOutput(to: connectionPoint, format: AudioKit.format)
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
        AudioKit.connect(outputNode, to: connectionPoints, fromBus: 0, format: format)
    }

}

/// Manages connections to inputNode.
public protocol AKInput: AKOutput {

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

extension AKInput {
    public var inputNode: AVAudioNode {
        return outputNode
    }
    public func disconnectInput() {
        AudioKit.engine.disconnectNodeInput(inputNode)
    }
    public func disconnectInput(bus: Int) {
        AudioKit.engine.disconnectNodeInput(inputNode, bus: bus )
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

@objc extension AVAudioNode: AKInput {
    public var outputNode: AVAudioNode {
        return self
    }
}

// Set output connection(s)
infix operator >>>: AdditionPrecedence

@discardableResult public func >>>(left: AKOutput, right: AKInput) -> AKInput {
    return left.connect(to: right)
}
@discardableResult public func >>>(left: AKOutput, right: [AKInput]) -> [AKInput] {
    return left.connect(to: right)
}
@discardableResult public func >>>(left: [AKOutput], right: AKInput) -> AKInput {
    for node in left {
        node.connect(to: right)
    }
    return right
}
@discardableResult public func >>>(left: AKOutput, right: AKInputConnection) -> AKInput {
    return left.connect(to: right.node, bus: right.bus)
}
@discardableResult public func >>>(left: AKOutput, right: [AKInputConnection]) -> [AKInput] {
    return left.connect(toInputs: right)
}
public func >>>(left: AKOutput, right: AVAudioConnectionPoint) {
    return left.connect(to: right)
}

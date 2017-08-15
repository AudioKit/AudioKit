//
//  AKConnection.swift
//  AudioKit For iOS
//
//  Created by David O'Neill on 8/12/17.
//  Copyright © 2017 AudioKit. All rights reserved.
//

open class AKInputConnection: NSObject {
    open var node: AKInput
    open var bus: Int
    public init(node: AKInput, bus: Int) {
        self.node = node
        self.bus = bus
        super.init()
    }
    open var avConnection: AVAudioConnectionPoint{
        return AVAudioConnectionPoint(node: self.node.inputNode, bus: bus)
    }
}


public protocol AKOutput: class {
    var outputNode: AVAudioNode { get }
}

extension AKOutput{

    public var connectionPoints: [AVAudioConnectionPoint]{
        get{ return AudioKit.engine.outputConnectionPoints(for: outputNode, outputBus: 0) }
        set{ AudioKit.connect(outputNode, to: newValue, fromBus: 0, format: AudioKit.format) }
    }

    //Disconnection
    public func disconnectOutput() {
        AudioKit.engine.disconnectNodeOutput(outputNode)
    }
    public func disconnectOutput(from: AKInput) {
        connectionPoints = connectionPoints.filter({ $0.node != from.inputNode })
    }
    public func disconnectOutput(bus: Int) {
        AudioKit.engine.disconnectNodeOutput(outputNode, bus: bus)
    }



    //Add Connection
    @discardableResult public func connect(to node: AKInput) -> AKInput {
        return connect(to: node, bus: node.nextInput.bus)
    }
    @discardableResult public func connect(to input: AKInputConnection) -> AKInput {
        return connect(to: input.node, bus: input.bus)
    }
    @discardableResult public func connect(to node: AKInput, bus: Int) -> AKInput {
        connectionPoints.append(AVAudioConnectionPoint(node: node.inputNode, bus: bus))
        return node
    }

    @discardableResult public func connect(to nodes: [AKInput]) -> [AKInput] {
        connectionPoints += nodes.map{ $0.nextInput }.map{ $0.avConnection }
        return nodes
    }
    @discardableResult public func connect(toInputs: [AKInputConnection]) -> [AKInput]{
        connectionPoints += toInputs.map{ $0.avConnection }
        return toInputs.map{ $0.node }
    }
    public func connect(to connectionPoint: AVAudioConnectionPoint) {
        connectionPoints.append(connectionPoint)
    }


    //Set connection, this will remove existing connections from the output.
    @discardableResult public func setOutput(to node: AKInput) -> AKInput {
        return setOutput(to: node, bus: node.nextInput.bus, format: AudioKit.format)
    }
    @discardableResult public func setOutput(to node: AKInput, bus: Int, format: AVAudioFormat) -> AKInput {
        AudioKit.connect(outputNode, to: node.inputNode, fromBus: 0, toBus: bus, format: format)
        return node
    }
    @discardableResult public func setOutput(to nodes: [AKInput], format: AVAudioFormat) -> [AKInput] {
        setOutput(to: nodes.map{ $0.nextInput.avConnection }, format: format)
        return nodes
    }
    @discardableResult public func setOutput(toInputs: [AKInputConnection]) -> [AKInput]{
        return setOutput(toInputs: toInputs, format: AudioKit.format)
    }
    @discardableResult public func setOutput(toInputs: [AKInputConnection], format: AVAudioFormat) -> [AKInput]{
        setOutput(to: toInputs.map{ $0.avConnection }, format: format)
        return toInputs.map{ $0.node }
    }



    public func setOutput(to connectionPoint: AVAudioConnectionPoint) {
        setOutput(to: connectionPoint, format: AudioKit.format)
    }
    public func setOutput(to connectionPoint: AVAudioConnectionPoint, format: AVAudioFormat) {
        setOutput(to: [connectionPoint], format: format)
    }
    public func setOutput(to connectionPoints: [AVAudioConnectionPoint], format: AVAudioFormat) {
        AudioKit.connect(outputNode, to: connectionPoints, fromBus: 0, format: format)
    }


}


public protocol AKInput: AKOutput {
    var inputNode: AVAudioNode { get }
    var nextInput: AKInputConnection { get }
    func disconnectInput()
    func disconnectInput(bus: Int)
    func input(_ bus: Int) -> AKInputConnection
}



extension AKInput {
    public var inputNode: AVAudioNode {
        return outputNode
    }
    public func disconnectInput(){
        AudioKit.engine.disconnectNodeInput(inputNode)
    }
    public func disconnectInput(bus: Int){
        AudioKit.engine.disconnectNodeInput(inputNode, bus: bus )
    }
    public var nextInput: AKInputConnection {
        return input(0)
    }
    public func input(_ bus: Int) -> AKInputConnection {
        return AKInputConnection(node: self, bus: bus)
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
@discardableResult public func >>>(left: AKOutput, right: AKInputConnection) -> AKInput {
    return left.connect(to: right.node, bus: right.bus)
}
@discardableResult public func >>>(left: AKOutput, right: [AKInputConnection]) -> [AKInput] {
    return left.connect(toInputs: right)
}
public func >>>(left: AKOutput, right: AVAudioConnectionPoint){
    return left.connect(to: right)
}





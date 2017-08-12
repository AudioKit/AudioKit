//
//  AKConnection.swift
//  AudioKit For iOS
//
//  Created by David O'Neill on 8/12/17.
//  Copyright © 2017 AudioKit. All rights reserved.
//

public class AKInputConnection: NSObject {
    var node: AKInput
    var bus: Int
    init(node: AKInput, bus: Int) {
        self.node = node
        self.bus = bus
        super.init()
    }
    var avConnection: AVAudioConnectionPoint{
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
    public func disconnectOutput(bus: Int) {
        AudioKit.engine.disconnectNodeOutput(outputNode, bus: bus)
    }
    
    
    //Connection
    @discardableResult func connect(to node: AKInput, bus: Int, format: AVAudioFormat) -> AKInput {
        AudioKit.connect(outputNode, to: node.inputNode, fromBus: 0, toBus: bus, format: format)
        return node
    }
    @discardableResult func connect(toInputs: [AKInputConnection]) -> [AKInput]{
        AudioKit.connect(outputNode,
                         to: toInputs.map{ $0.avConnection },
                         fromBus: 0,
                         format: AudioKit.format)
        return toInputs.map{ $0.node }
    }
    
    //Convenience
    @discardableResult func connect(to node: AKInput) -> AKInput {
        return connect(to: node, bus: node.nextInput.bus)
    }
    @discardableResult func connect(to input: AKInputConnection) -> AKInput {
        return connect(to: input.node, bus: input.bus)
    }
    @discardableResult func connect(to nodes: [AKInput]) -> [AKInput] {
        return connect(toInputs: nodes.map{ $0.nextInput })
    }
    @discardableResult func connect(to node: AKInput, bus: Int) -> AKInput {
        return connect(to: node, bus: bus, format: AudioKit.format)
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
    var inputNode: AVAudioNode {
        return outputNode
    }
    func disconnectInput(){
        AudioKit.engine.disconnectNodeInput(inputNode)
    }
    func disconnectInput(bus: Int){
        AudioKit.engine.disconnectNodeInput(inputNode, bus: bus )
    }
    var nextInput: AKInputConnection {
        return input(0)
    }
    public func input(_ bus: Int) -> AKInputConnection {
        return AKInputConnection(node: self, bus: bus)
    }
}


// Set output connection(s)
infix operator >>>: AdditionPrecedence

@discardableResult func >>>(left: AKOutput, right: AKInput) -> AKInput {
    return left.connect(to: right)
}
@discardableResult func >>>(left: AKOutput, right: [AKInput]) -> [AKInput] {
    return left.connect(to: right)
}
@discardableResult func >>>(left: AKOutput, right: AKInputConnection) -> AKInput {
    return left.connect(to: right.node, bus: right.bus)
}
@discardableResult func >>>(left: AKOutput, right: [AKInputConnection]) -> [AKInput] {
    return left.connect(toInputs: right)
}


// Add output connection(s)
@discardableResult func +(left: AKOutput, right: AKInput) -> AKInput {
    left.connectionPoints.append(right.nextInput.avConnection)
    return right
}

@discardableResult func +(left: AKOutput, right: AKInputConnection) -> AKInput {
    left.connectionPoints.append(right.avConnection)
    return right.node
}
@discardableResult func +(left: AKOutput, right: [AKInput]) -> [AKInput] {
    left.connectionPoints += right.map{ $0.nextInput.avConnection }
    return right
}
@discardableResult func +(left: AKOutput, right: [AKInputConnection]) -> [AKInput] {
    left.connectionPoints += right.map{ $0.avConnection }
    return right.map{ $0.node }
}



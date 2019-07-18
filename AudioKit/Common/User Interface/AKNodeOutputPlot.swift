//
//  AKNodeOutputPlot.swift
//  AudioKitUI
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//
import AudioKit

extension Notification.Name {
    static let IAAConnected = Notification.Name(rawValue: "IAAConnected")
    static let IAADisconnected = Notification.Name(rawValue: "IAADisconnected")
}

/// Plot the output from any node in an signal processing graph
///
/// By default this plots the output of AudioKit.output
@IBDesignable
open class AKNodeOutputPlot: EZAudioPlot {

    public var isConnected = false
    public var isNotConnected: Bool { return !isConnected }

    internal func setupNode(_ input: AKNode?) {
        if isNotConnected {
            input?.avAudioUnitOrNode.installTap(
                onBus: 0,
                bufferSize: bufferSize,
                format: nil) { [weak self] (buffer, _) in

                    guard let strongSelf = self else {
                        AKLog("Unable to create strong reference to self")
                        return
                    }
                    buffer.frameLength = strongSelf.bufferSize
                    let offset = Int(buffer.frameCapacity - buffer.frameLength)
                    if let tail = buffer.floatChannelData?[0] {
                        strongSelf.updateBuffer(&tail[offset], withBufferSize: strongSelf.bufferSize)
                    }
            }
        }
        isConnected = true
    }

    // Useful to reconnect after connecting to Audiobus or IAA
    @objc func reconnect() {
        pause()
        resume()
    }

    @objc open func pause() {
        if isConnected {
            node?.avAudioUnitOrNode.removeTap(onBus: 0)
            isConnected = false
        }
    }

    @objc open func resume() {
        setupNode(node)
    }

    private func setupReconnection() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(reconnect),
                                               name: .IAAConnected,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(reconnect),
                                               name: .IAADisconnected,
                                               object: nil)
    }

    internal var bufferSize: UInt32 = 1_024

    /// The node whose output to graph
    ///
    /// Defaults to AudioKit.output
    @objc open var node: AKNode? {
        willSet {
            pause()
        }
        didSet {
            resume()
        }
    }

    deinit {
        node?.avAudioUnitOrNode.removeTap(onBus: 0)
    }

    /// Required coder-based initialization (for use with Interface Builder)
    ///
    /// - parameter coder: NSCoder
    ///
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupNode(AudioKit.output)
        setupReconnection()
    }

    /// Initialize the plot with the output from a given node and optional plot size
    ///
    /// - Parameters:
    ///   - input: AKNode from which to get the plot data
    ///   - width: Width of the view
    ///   - height: Height of the view
    ///
    @objc public init(_ input: AKNode? = AudioKit.output, frame: CGRect = CGRect.zero, bufferSize: Int = 1_024) {
        super.init(frame: frame)
        self.plotType = .buffer
        self.backgroundColor = AKColor.white
        self.shouldCenterYAxis = true
        self.bufferSize = UInt32(bufferSize)

        setupNode(input)
        self.node = input
        setupReconnection()
    }
}

//
//  AKView.swift
//  AudioKit
//
//  Created by Stéphane Peter, revision history on Github.
//  Copyright © 2017 Aurelius Prochazka. All rights reserved.
//

#if os(macOS)
    public typealias AKView = NSView
    public typealias AKColor = NSColor
#else
    public typealias AKView = UIView
    public typealias AKColor = UIColor
#endif

//
//  DisplayLink.swift
//
//  Created by aleclarson via https://gist.github.com/aleclarson/e3ac0afce979eea429eb
//

import QuartzCore

public class DisplayLink {
    
    public init (_ callback: @escaping () -> Void) {
        _callback = callback
        _link = CADisplayLink(target: _DisplayTarget(self), selector: #selector(_DisplayTarget._callback))
        _link.add(to: RunLoop.main, forMode: RunLoop.Mode.common)
    }
    
    fileprivate let _callback: () -> Void
    
    private var _link: CADisplayLink!
    
    deinit {
        _link.invalidate()
    }

    func pause() {
        _link.isPaused = true
    }
    func resume() {
        _link.isPaused = false
    }
    
    public func invalidate() {
        _link.invalidate()
    }
    
}

/// Retained by CADisplayLink.
fileprivate class _DisplayTarget {
    
    init (_ link: DisplayLink) {
        _link = link
    }
    
    weak var _link: DisplayLink!
    
    @objc func _callback () {
        _link?._callback()
    }
}

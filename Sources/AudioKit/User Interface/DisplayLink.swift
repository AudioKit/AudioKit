// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/
//
//  Based on work by aleclarson https://gist.github.com/aleclarson/e3ac0afce979eea429eb

#if !os(macOS)

import QuartzCore

public class DisplayLink {

    fileprivate let callback: () -> Void

    private var link: CADisplayLink!

    public init (_ callback: @escaping () -> Void) {
        self.callback = callback
        link = CADisplayLink(target: DisplayTarget(self), selector: #selector(DisplayTarget.callback))
        link.add(to: RunLoop.main, forMode: RunLoop.Mode.common)
    }
    

    deinit {
        link.invalidate()
    }

    func pause() {
        link.isPaused = true
    }
    func resume() {
        link.isPaused = false
    }
    
    public func invalidate() {
        link.invalidate()
    }
    
}

/// Retained by CADisplayLink.
fileprivate class DisplayTarget {
    weak var link: DisplayLink!

    init (_ link: DisplayLink) {
        self.link = link
    }

    @objc func callback() {
        link?.callback()
    }
}
#endif

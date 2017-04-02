//
//  AKScheduledAction.swift
//  AudioKit For iOS
//
//  Created by David Sweetman on 4/1/17.
//  Copyright © 2017 AudioKit. All rights reserved.
//

import Foundation

class AKScheduledAction {

    private var interval: TimeInterval
    private var block: (() -> Void)
    private var timer: Timer?

    init(interval: TimeInterval, block: @escaping () -> Void) {
        self.interval = interval
        self.block = block
        start()
    }

    func start() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(timeInterval: interval,
                                     target: self,
                                     selector: #selector(fire(timer:)),
                                     userInfo: nil,
                                     repeats: false)
    }

    func stop() {
        timer?.invalidate()
        timer = nil
    }

    private dynamic func fire(timer: Timer) {
        guard timer.isValid else { return }
        self.block()
    }

    deinit {
        stop()
    }
}

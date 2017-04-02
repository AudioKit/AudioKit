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

    dynamic func start() {
        timer?.invalidate()
        timer = nil
        timer = Timer.scheduledTimer(withTimeInterval: interval,
                                     repeats: false,
                                     block: { [weak self] (timer) in
                                        guard timer.isValid else { return }
                                        self?.block()
        })
    }

    dynamic func stop() {
        timer?.invalidate()
        timer = nil
    }

    deinit {
        stop()
    }
}

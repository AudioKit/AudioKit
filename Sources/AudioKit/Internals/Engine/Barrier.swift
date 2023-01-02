// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import Foundation
import Atomics

class Barrier {

    var waiting: ManagedAtomic<Int>

    init(count: Int) {
        self.waiting = .init(count)
    }

    func reset(count: Int) {
        self.waiting.store(count, ordering: .relaxed)
    }

    func wait() {
        while self.waiting.wrappingDecrementThenLoad(ordering: .relaxed) > 0 { }
    }

}

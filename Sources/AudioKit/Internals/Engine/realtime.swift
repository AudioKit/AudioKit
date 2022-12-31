// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import Foundation

func set_realtime(period: UInt32, computation: UInt32, constraint: UInt32) -> Bool {
    let TIME_CONSTRAINT_POLICY: UInt32 = 2
    let TIME_CONSTRAINT_POLICY_COUNT = UInt32(MemoryLayout<thread_time_constraint_policy_data_t>.size / MemoryLayout<integer_t>.size)
    let SUCCESS: Int32 = 0
    var policy: thread_time_constraint_policy = .init()
    var ret: Int32
    let thread: thread_port_t = pthread_mach_thread_np(pthread_self())

    policy.period = period
    policy.computation = computation
    policy.constraint = constraint
    policy.preemptible = 1

    ret = withUnsafeMutablePointer(to: &policy) {
        $0.withMemoryRebound(to: integer_t.self, capacity: Int(TIME_CONSTRAINT_POLICY_COUNT)) {
            thread_policy_set(thread, TIME_CONSTRAINT_POLICY, $0, TIME_CONSTRAINT_POLICY_COUNT)
        }
    }

    if ret != SUCCESS {
        print(stderr, "set_realtime() failed.\n")
        return false
    }
    return true
}

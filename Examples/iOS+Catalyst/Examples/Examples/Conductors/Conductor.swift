import AudioKit

class Conductor {

    var performance: AKPeriodicFunction?

    func setup() {
        // override in subclass
    }

    func start() {
        shutdown()
        setup()
        do {
            if let performance = performance {
                try AKManager.start(withPeriodicFunctions: performance)
            } else {
                try AKManager.start()
            }
        } catch {
            AKLog("AudioKit did not start! \(error)")
        }
    }

    func shutdown() {
        do {
            try AKManager.shutdown()
        } catch {
            AKLog("AudioKit did not stop! \(error)")
        }
    }
}


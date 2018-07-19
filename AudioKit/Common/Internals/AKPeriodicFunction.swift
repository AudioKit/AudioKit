//
//  AKPeriodicFunction.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on GitHub.
//  Copyright © 2018 AudioKit. All rights reserved.
//

/// A class to periodically perform a callback
public class AKPeriodicFunction: AKOperationGenerator {
    fileprivate var internalHandler: () -> Void = {}
    private var duration = 1.0

    let triggerFunctionUgen =
        AKCustomUgen(name: "triggerFunction", argTypes: "f") { _, stack, userData in
            let trigger = stack.popFloat()
            if trigger != 0 {
                if let function = userData as? AKPeriodicFunction {
                    DispatchQueue.main.async {
                        function.internalHandler()
                    }
                }
            }
        }

    /// Repeat this loop at a given period with a code block
    ///
    /// - parameter period: Interval between block executions
    /// - parameter handler: Code block to execute
    ///
    @objc public init(every period: Double, handler: @escaping () -> Void) {
        duration = period
        internalHandler = handler
        super.init(sporth: "\(period) dmetro (_triggerFunction fe) 0 0", customUgens: [triggerFunctionUgen] )
        triggerFunctionUgen.userData = self
    }

    /// Repeat this loop at a given frequency with a code block
    ///
    /// - parameter frequency: Period, or interval between block executions
    /// - parameter handler: Code block to execute
    ///
    public convenience init(frequency: Double, handler: @escaping () -> Void) {
        self.init(every: 1.0 / frequency, handler: handler)
    }
}

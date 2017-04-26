//
//  AKPeriodicFunction.swift
//  AudioKit
//
//  Created by Aurelius Prochazka on 4/10/17.
//  Copyright © 2017 Aurelius Prochazka. All rights reserved.
//

public class AKPeriodicFunction: AKOperationGenerator {
    fileprivate var internalHandler: () -> Void = {}
    private var duration = 1.0
    
    let triggerFunctionUgen =
        AKCustomUgen(name: "triggerFunction", argTypes: "f") { ugen, stack, userData in
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
    /// - parameter every: Period, or interval between block executions
    /// - parameter handler: Code block to execute
    ///
    public init(every dur: Double, handler: @escaping () -> Void) {
        duration = dur
        internalHandler = handler
        super.init(sporth: "\(dur) dmetro (_triggerFunction fe) 0 0", customUgens: [triggerFunctionUgen] )
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

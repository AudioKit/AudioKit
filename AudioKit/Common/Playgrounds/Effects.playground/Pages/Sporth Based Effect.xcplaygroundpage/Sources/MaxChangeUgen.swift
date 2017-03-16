import AudioKit

public let maxChangeUgen =
AKCustomUgen(name: "maxchange", argTypes: "ff") { stack, userData in
    let maxChange = stack.popFloat()
    let destValue = stack.popFloat()
    var nextValue = destValue

    if let prevValue = userData.flatMap({ $0 as? Float }) {
        let change = destValue - prevValue
        if abs(change) > maxChange {
          nextValue = prevValue + (change > 0 ? maxChange : -maxChange)
        }
    }
    userData = nextValue
    stack.push(nextValue)
}

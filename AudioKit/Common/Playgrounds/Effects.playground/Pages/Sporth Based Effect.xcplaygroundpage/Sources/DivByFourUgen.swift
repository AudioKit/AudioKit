import AudioKit

public let divByFourUgen =
AKCustomUgen(name: "divByFour", argTypes: "f") { stack in
  let f = stack.popFloat()
  stack.push(f / 4.0)
}

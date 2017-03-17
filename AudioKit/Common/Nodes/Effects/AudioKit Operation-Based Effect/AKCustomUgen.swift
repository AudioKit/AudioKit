//
//  AKCustomUgen.swift
//  AudioKit For iOS
//
//  Created by Joseph Constantakis on 3/14/17.
//  Copyright © 2017 AudioKit. All rights reserved.
//

import Foundation

open class AKCustomUgen: NSObject {
  open let name: String
  open let argTypes: String // string of f for float / s for string, e.g. "fsf"
  open var userData: Any?
  open let computeFunction: (AKCustomUgen, AKSporthStack, inout Any?) -> ()

  public var stack = AKSporthStack()

  public init(name: String, argTypes: String, userData: Any? = nil,
              computeFunction: @escaping (AKCustomUgen, AKSporthStack, inout Any?) -> ()) {
      self.name = name
      self.argTypes = argTypes
      self.computeFunction = computeFunction
      self.userData = userData
  }

  public func duplicate() -> AKCustomUgen {
     return AKCustomUgen(name: self.name, argTypes: self.argTypes, userData: self.userData, computeFunction: self.computeFunction)
  }

  open let callComputeFunction: @convention(c) (AKCustomUgen) -> ()
      = { ugen in
      ugen.computeFunction(ugen, ugen.stack, &(ugen.userData))
  }
}

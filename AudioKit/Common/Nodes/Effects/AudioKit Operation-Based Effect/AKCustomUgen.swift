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

  open let computeFunction: @convention(c) (AKSporthStack) -> ()

  public init(name: String = "", argTypes: String,
       computeFunction: @escaping @convention(c) (AKSporthStack) -> ()) {
    self.name = name
    self.argTypes = argTypes
    self.computeFunction = computeFunction
  }
}

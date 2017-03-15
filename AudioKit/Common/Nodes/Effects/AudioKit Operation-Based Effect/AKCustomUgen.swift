//
//  AKCustomUgen.swift
//  AudioKit For iOS
//
//  Created by Joseph Constantakis on 3/14/17.
//  Copyright © 2017 AudioKit. All rights reserved.
//

import Foundation

@objc open class AKCustomUgen: NSObject {
  @objc open var name: String
  @objc open var argTypes: String // something like "fff" or "sf"

  open var computeFunction: @convention(c) (SporthStack) -> ()

  public init(name: String = "", argTypes: String,
       computeFunction: @escaping @convention(c) (SporthStack) -> ()) {
    self.name = name
    self.argTypes = argTypes
    self.computeFunction = computeFunction
  }
}

//
//  AppDelegate.swift
//  LoopbackRecording
//
//  Created by David O'Neill on 5/3/18.
//  Copyright © 2018 AudioKit. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        let vc = ViewController()
        window!.rootViewController = vc
        window?.makeKeyAndVisible()
        return true
    }
}

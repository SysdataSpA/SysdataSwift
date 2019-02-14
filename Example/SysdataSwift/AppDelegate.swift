//
//  AppDelegate.swift
//  SysdataSwift
//
//  Created by guidosabatini-sysdata on 02/14/2019.
//  Copyright (c) 2019 guidosabatini-sysdata. All rights reserved.
//

import UIKit
import SysdataSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var interfaceCoordinator: MainCoordinator?
    let nav = UINavigationController()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        let coreContainer = setupCoreContainer()
        interfaceCoordinator = MainCoordinator(coordinatorContainer: coreContainer)
        
        let context = Context(coordinator: interfaceCoordinator!, core: coreContainer)
        
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = nav
        window?.makeKeyAndVisible()
        
        interfaceCoordinator!.start(context: context, rootViewController: nav)
        
        return true
    }

    func setupCoreContainer() -> Container {
        let container = BaseContainer()
        
        return container
    }

}


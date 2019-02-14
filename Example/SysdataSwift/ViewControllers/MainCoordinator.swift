//
//  MainCoordinator.swift
//  Template
//
//  Created by Francesco Ceravolo on 21/12/2018.
//  Copyright © 2018 Sysdata. All rights reserved.
//

import Foundation
import SysdataSwift

public enum MainCoordinatorEnums: CoordinatorEnums {
    public typealias ACT = Actions
    public typealias NOD = Node
    
    public enum Actions {
        case firtScreenOk(text: String)
        case updateContext
    }

    public enum Node: String {
        case first
        case second
    }
}

public class MainCoordinator: BaseCoordinator<MainCoordinatorEnums> {
    
    override public func start<PRM>(context: Context<PRM>, rootViewController: UIViewController? = nil) {
        super.start(context: context, rootViewController: rootViewController)
        navigate(toNode: .first, context: context)
    }

    public override func registerAllNodes() {
        super.registerAllNodes()
        
        // registrazione classi concrete per ogni nodo
        registerNode(key: nodes.first, view: FirstViewController.self, presenter: FirstPresenter.self)
        registerNode(key: nodes.second, view: SecondViewController.self, presenter: SecondPresenter.self)
    }
    
    override public func actionManagement<PRM>(action actionKey: MainCoordinatorEnums.Actions, context: Context<PRM>) {
        switch actionKey {
        case .firtScreenOk(let text):
            navigate(toNode: .second, context: context.make(param: text))
        case .updateContext:
            updateContext(key: .second, vc: self.navigationController!.topViewController!, context: context)
        }
    }
    
}

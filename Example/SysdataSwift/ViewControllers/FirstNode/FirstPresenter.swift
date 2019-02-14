//
//  FirstPresenter.swift
//  UITemplate
//
//  Created by Francesco Ceravolo on 20/12/2018.
//  Copyright © 2018 Sysdata. All rights reserved.
//

import UIKit
import SysdataSwift

class FirstPresenter: BasePresenter<FirstViewController, Context<Void>, MainCoordinatorEnums.Actions>, FirstPresenterProtocol {

    func load() {
        
    }
    
    func save(text: String) {
        context.coordinator.performAction(action: actions.firtScreenOk(text: text), context: context)
    }

}

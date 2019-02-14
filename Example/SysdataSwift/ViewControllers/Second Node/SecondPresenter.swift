//
//  SecondPresenter.swift
//  Template
//
//  Created by Francesco Ceravolo on 21/12/2018.
//  Copyright © 2018 Sysdata. All rights reserved.
//

import UIKit
import SysdataSwift

class SecondPresenter: BasePresenter<SecondViewController, Context<String>, MainCoordinatorEnums.Actions>, SecondPresenterProtocol {
    
    var labelName: String {
        return context.param
    }
    
    func updateContext() {
        context.coordinator.performAction(action: actions.updateContext, context: context.make(param: "111111111"))
    }
}

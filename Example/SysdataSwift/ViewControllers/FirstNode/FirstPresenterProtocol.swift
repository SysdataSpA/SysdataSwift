//
//  FirstViewControllerDelegate.swift
//  UITemplate
//
//  Created by Francesco Ceravolo on 20/12/2018.
//  Copyright © 2018 Sysdata. All rights reserved.
//

import Foundation
import SysdataSwift

protocol FirstPresenterProtocol: Presenter {    
    func load()
    func save(text: String)
}

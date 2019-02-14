//
//  SecondViewController.swift
//  Template
//
//  Created by Francesco Ceravolo on 21/12/2018.
//  Copyright © 2018 Sysdata. All rights reserved.
//

import UIKit
import SysdataSwift

class SecondViewController: BaseViewController<SecondPresenterProtocol> {

    @IBOutlet weak var label: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        refreshLabel()
    }

    @IBAction func updateContext(_ sender: Any) {
        self.presenter.updateContext()
        refreshLabel()
    }
    
    private func refreshLabel() {
        label.text = presenter.labelName
    }

}

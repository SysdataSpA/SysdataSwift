//
//  FirstViewController.swift
//  UITemplate
//
//  Created by Francesco Ceravolo on 20/12/2018.
//  Copyright © 2018 Sysdata. All rights reserved.
//

import UIKit
import SysdataSwift

class FirstViewController: BaseViewController<FirstPresenterProtocol> {

    @IBOutlet weak var textField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func okButtonTapped(_ sender: Any) {
        presenter.save(text: textField.text ?? "empty")
    }

}

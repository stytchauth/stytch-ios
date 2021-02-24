//
//  AuthedViewController.swift
//  StytchExample
//
//  Created by Ethan Furstoss on 2/20/21.
//

import Foundation
import UIKit

class AuthedViewController: UIViewController{
    
    let mainLabel: UILabel = {
        let label = UILabel(frame: CGRect(x: 100, y: 100, width: 100, height: 100))
        label.text = "Authed!"
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpView()
    }
    
    func setUpView(){
        self.view.backgroundColor = .white
        self.view.addSubview(mainLabel)
    }
    
}


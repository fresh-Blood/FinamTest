//
//  SecondViewController.swift
//  FinamTest
//
//  Created by Admin on 13.08.2021.
//

import UIKit

class SecondViewController: UIViewController {

    @IBOutlet weak var topicLabel: UILabel!
    
    var textInfo = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        topicLabel.text = textInfo
        topicLabel.sizeToFit()
        
    }
    

}

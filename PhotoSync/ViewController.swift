//
//  ViewController.swift
//  PhotoSync
//
//  Created by Aadil Majeed on 12/20/16.
//  Copyright © 2016 BML. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.navigationController?.performSegue(withIdentifier: "ShowLoginView", sender: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if let user_name = Oauth.default.user_name{
            self.title = user_name
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    

}


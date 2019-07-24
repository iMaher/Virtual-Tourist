//
//  LoginVC.swift
//  Virtual_Tourist_1.0
//
//  Created by maher malibari on 24/07/2019.
//  Copyright © 2019 maher malibari. All rights reserved.
//

import UIKit

class LoginVC: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    @IBAction func loginButtonPressed(_ sender: Any) {
        let ai = ActivityIndicator()
        guard let email = emailTextField.text ,let password = passwordTextField.text, !email.isEmpty, !password.isEmpty else {
            
            self.alert(t: "Error", m: "Wrong Email or Password")
            return
            
        }
        
        UdacityAPI.createSession(with: email, password: password) { (errorMsg) in
            ai.stopAnimating()
            if errorMsg != nil {
                self.alert(t: "Error", m: errorMsg)
                return
            }
            
            UdacityAPI.getUserData  { (errorMsg) in
                if errorMsg != nil {
                    self.alert(t: "Error", m: errorMsg)
                    return
                }
                
                UdacityAPI.Parse.getLocations { (errorMsg) in
                    if errorMsg != nil {
                        self.alert(t: "Error", m: errorMsg)
                        return
                    }
                    DispatchQueue.main.async {
                        
                        self.emailTextField.text = ""
                        self.passwordTextField.text = ""
                        
                        self.performSegue(withIdentifier: "toMap", sender: self)
                    }
                    
                }
            }
            
            
        }
        
    }
    
    func errorMessage(errorMsg: String) -> Void {
        self.loginButton.isEnabled = true
        self.alert(t: "Error", m: errorMsg)
    }
    
}    



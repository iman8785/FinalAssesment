//
//  ViewController.swift
//  Final Assessment
//
//  Created by Habib Zarrin Chang Fard on 02/10/2017.
//  Copyright © 2017 Habib Zahrrin Chang Fard. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase


class ViewController: UIViewController {
    
    var selectedUser: User?
    
    
    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var loginButton: UIButton!{
        didSet{
            loginButton.addTarget(self, action: #selector(loginUser), for: .touchUpInside)
        }
        
    }

    @IBAction func signupButton(_ sender: Any) {
        
        let mainStoryBoard = UIStoryboard(name: "Main", bundle: Bundle.main)
        guard let destination = mainStoryBoard.instantiateViewController(withIdentifier: "SignupViewController") as?
            SignupViewController else {return}
        
        destination.selectedUser = selectedUser
        navigationController?.pushViewController(destination, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Login Email
        if Auth.auth().currentUser != nil {
            guard let vc = storyboard?.instantiateViewController(withIdentifier: "tabBarController") as? UITabBarController else { return }
            
            //skip login page straight to homepage
            present(vc, animated:  true, completion:  nil)
        }
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        
        view.addGestureRecognizer(tapGesture)
        
    }
    @objc func dismissKeyboard() {
        
        view.endEditing(true)
    }
    
    // Email Login
    
    @objc func loginUser() {
        guard let email = emailTextField.text else { return }
        guard let password = passwordTextField.text else { return }
        
        Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
            
            if self.emailTextField.text == "" {
                self.createErrorAlert("Empty Email Text Field", "Plaese Input Valid Email")
                return
            }
            else if self.passwordTextField.text == "" {
                self.createErrorAlert("Empty Password Text Field", "Please Input Valid Password")
                return
            }
            if let validError = error {
                
                print(validError.localizedDescription)
                self.createErrorAlert("Error", validError.localizedDescription)
            }
            
            if let validUser = user {
                print(validUser)
                
                let ref = Database.database().reference()
                
                ref.child("Users").child(validUser.uid).observe(.value, with: { (snapshot) in
                    guard let info = snapshot.value as? [String : Any]
                        else { return }
                    print("info: \(info)")
                    print(snapshot)
                    print(snapshot.key)
                    
                    if let name = info["name"] as? String,
                        let imageURL = info["imageURL"] as? String,
                        let imageFilename = info["imageFilename"] as? String,
                        let id = info["id"] as? String,
                        let age = info["age"] as? String,
                        let gender = info["gender"] as? String,
                        let description = info["description"] as? String
                        {
                             User.currentUser = User(anID: id, aName: name, anEmail: email, anImageURL: imageURL, anFilename: imageFilename, anAge : age, aGender : gender, aDescription : description )

//                          let currentUser = User
//                            currentUser.name = name
//                            currentUser.imageURL = imageURL
//                            currentUser.filename = imageFilename
//                            currentUser.id = id
//                            currentUser.age = age
//                            currentUser.gender = gender
//                            currentUser.description = description
                            
                    }
                    
                    guard let vc = self.storyboard?.instantiateViewController(withIdentifier: "tabBarController") as? UITabBarController else { return }
                    
                    self.present(vc, animated:  true, completion:  nil)
                    
                })
                
            }
        }
        
        
    }
    
    func createErrorAlert(_ title: String, _ message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "Error", style: .default, handler: nil)
        alert.addAction(action)
        
        present(alert, animated: true, completion:  nil)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}


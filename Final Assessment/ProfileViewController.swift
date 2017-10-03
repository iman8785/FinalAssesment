//
//  ProfileViewController.swift
//  Final Assessment
//
//  Created by Habib Zarrin Chang Fard on 02/10/2017.
//  Copyright © 2017 Habib Zahrrin Chang Fard. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseStorage
import FirebaseAuth
import SDWebImage

class ProfileViewController: UIViewController {
    var selectedUser : User?
    var ref : DatabaseReference!
    var idEdit : Bool = true
    
    var users : [User] = []
    var profilePicURL : String = ""
    var userId : String = ""
    var userName : String = ""
    
    // let currentUser: User = User()
    
    @IBOutlet weak var descriptionTextField: UITextField!
    @IBOutlet weak var ageTextField: UITextField!
    @IBOutlet weak var genderTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var userNameTextField: UITextField!
    
    @IBAction func editButton(_ sender: Any) {
        
        let mainStoryBoard = UIStoryboard(name: "Main", bundle: Bundle.main)
        guard let destination = mainStoryBoard.instantiateViewController(withIdentifier: "SignupViewController") as?
            SignupViewController else {return}
        
        destination.selectedUser = selectedUser
        navigationController?.pushViewController(destination, animated: true)
    }
    
    @IBAction func signOut(_ sender: Any) {
        signOutUser()
    }
    
    func signOutUser() {
        do {
            try Auth.auth().signOut()
            dismiss(animated: true, completion: nil)
            
        } catch let error as NSError {
            print(error.localizedDescription)
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fetchHeader()
        loadImage(urlString: "http;///jj")
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadImage(urlString: String) {
        //1.url
        //2.session
        //3.task
        //4.start
        
        guard let url = URL(string: urlString) else {
            return
        }
        
        let session = URLSession.shared
        
        let task = session.dataTask(with: url) { (data, response, error) in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                return
            }
            
            if let data = data {
                DispatchQueue.main.async {
                    self.imageView.image = UIImage(data: data)
                }
            }
        }
        task.resume()
    }
    
    
    func fetchHeader() {
        //Get User Id
        
        ref = Database.database().reference()
        guard let uid = Auth.auth().currentUser?.uid else {return}
        userId = uid
        ref.child("Users").child(uid).observe(.value, with:{ (snapshot) in
            guard let info = snapshot.value as? [String:Any] else {return}
            print("info: \(info)")
            print(snapshot)
            
            //cast snapshot value to correct DataType
            
            if let name = info["name"] as? String,
                let age = info["age"] as? String,
                let gender = info["gender"] as? String,
                let email = info["email"] as? String,
                let imageURL = info["imageURL"] as? String,
                let description = info["description"] as? String,
                let filename = info["imageFilename"] as? String{
                
                
                let newUser = User(anID: snapshot.key, aName: name, anEmail: email, anImageURL: imageURL, anFilename: filename, anAge: age, aGender: gender, aDescription: description)
                
                self.users.append(newUser) //add self because we are inside a block
                
                
                
                DispatchQueue.main.async{
                    //                              self.selectedUser = newUser
                    self.users.append(newUser)
                    //                              self.userName = name
                    //                //self.users.removeAll()
                    self.userNameTextField.text = newUser.name
                    self.emailTextField.text = newUser.email
                    self.descriptionTextField.text = newUser.description
                    self.ageTextField.text = newUser.age
                    self.genderTextField.text = newUser.gender
                    self.imageView.sd_setImage(with: URL(string: newUser.imageURL))
                }
            }
        })
        
       
        
    }
}

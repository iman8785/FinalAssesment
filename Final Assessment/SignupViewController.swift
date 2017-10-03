//
//  SignupViewController.swift
//  Final Assessment
//
//  Created by Habib Zarrin Chang Fard on 02/10/2017.
//  Copyright © 2017 Habib Zahrrin Chang Fard. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage
import SDWebImage


class SignupViewController: UIViewController {
    
    var selectedUser: User?
    let picker = UIImagePickerController()
    var profilePicURL : String = ""
    var imageFilename : String = ""
    var ref : DatabaseReference!
    var userId : String = ""
    var userName : String = ""
    var imageUrl: String = ""
    
    
    @IBOutlet weak var editButton: UIButton!
        {
        didSet {
            editButton.addTarget(self, action: #selector(editBtn), for: .touchUpInside)
        }
        
    }
    @IBOutlet weak var imageView: UIImageView!
    
    
    @IBOutlet weak var userNameTextField: UITextField!
    
    @IBOutlet weak var emailTextField: UITextField!
    
    @IBAction func savePhoto(_ sender: AnyObject) {
        
        
        
    }
    @IBOutlet weak var passwordTextField: UITextField!
  
    @IBOutlet weak var confirmPasswordTextField: UITextField!
  
    @IBOutlet weak var genderTextField: UITextField!
    
    @IBOutlet weak var ageTextField: UITextField!
    
    @IBOutlet weak var descriptionTextField: UITextField!
    
    @IBAction func UploadPhotoButton(_ sender: UIBarButtonItem) {
        
        updateProfilePicEnable()
        
    }
    
    @IBOutlet weak var creatAccountButton: UIButton!{
        
        didSet{
            
            creatAccountButton.addTarget(self, action: #selector(signUp), for: .touchUpInside)
        }
        
    }
    
   @objc func signUp() {
        
        
        guard let email = emailTextField.text,
            let password = passwordTextField.text,
            let confirmPassword = confirmPasswordTextField.text,
            let userName = userNameTextField.text,
            let gender = genderTextField.text,
            let age = ageTextField.text,
            let description = descriptionTextField.text
            
            else {return}
        
        
        if password != confirmPassword {
            createErrorVC("Password Error", "Password does not match")
        } else if email == "" || password == "" || confirmPassword == "" {
            createErrorVC("Missing input fill", "Please fill up your info appropriately in the respective spaces.")
        }
        
        
        Auth.auth().createUser(withEmail: email, password: password) { (user, error) in
            if let error = error {
                print(error.localizedDescription)
                self.createErrorVC("Error", error.localizedDescription)
            }
            
            if let validUser = user {
                let ref = Database.database().reference()
                
                let post : [String:Any] = ["name": userName, "email": email ,"age": age, "imageURL": self.imageUrl,"imageFilename": "", "description" : description, "gender" : gender]
                
                ref.child("Users").child(validUser.uid).setValue(post)
                
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    func createErrorVC(_ title: String, _ message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        ref = Database.database().reference()
        
        guard let uid = Auth.auth().currentUser?.uid else {return}
        userId = uid
        
        guard let name = selectedUser?.name,
            let age = selectedUser?.age,
            let gender = selectedUser?.gender,
            let email = selectedUser?.email,
            let description = selectedUser?.description,
            let imageURL = selectedUser?.imageURL
            else {return}
        
        userNameTextField.text = name
        ageTextField.text = age
        genderTextField.text = gender
        emailTextField.text = email
        descriptionTextField.text = description
        
        imageView.sd_setImage(with: URL(string: imageURL))

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
    func updateProfilePicEnable() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        present(imagePicker, animated: true, completion: nil)
    }
    
   @objc func editBtn() {
        if editButton.titleLabel?.text == "Edit" {
            userNameTextField.isUserInteractionEnabled = true
            ageTextField.isUserInteractionEnabled = true
            genderTextField.isUserInteractionEnabled = true
            descriptionTextField.isUserInteractionEnabled = true
            
            //updateProfilePicEnable() //Enable user to change profile pic
            editButton.setTitle("Done", for: .normal)
        } else {
            userNameTextField.isUserInteractionEnabled = false
            ageTextField.isUserInteractionEnabled = false
            genderTextField.isUserInteractionEnabled = false
            descriptionTextField.isUserInteractionEnabled = false
            
            ref = Database.database().reference()
            
            
            //get the id of the specific user
            guard let name = userNameTextField.text,
                let age = ageTextField.text,
                let gender = genderTextField.text,
                let description = descriptionTextField.text
                else {return}
            
            let post : [String:Any] = ["name": name, "age":age, "imageURL": imageUrl, "description": description, "gender" : gender]
            
            //dig path to the user
            ref.child("Users").child(userId).updateChildValues(post)
            
            
            //
            
            editButton.setTitle("Edit", for: .normal)
        }
        
    
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func uploadImageToStorage(_ image: UIImage) {
        let ref = Storage.storage().reference()
        
        let timeStamp = Date().timeIntervalSince1970
        
        //compress image so that the image isn't too big
        guard let imageData = UIImageJPEGRepresentation(image, 0.2) else {return}
        
        let metaData = StorageMetadata()
        metaData.contentType = "image/jpeg"
        
        //metadata gives us the url to retrieve the data on the cloud
        
        ref.child("\(timeStamp).jpeg").putData(imageData, metadata: metaData) { (meta, error) in
            if let validError = error {
                print(validError.localizedDescription)
            }
            
            if let downloadPath = meta?.downloadURL()?.absoluteString {
                self.imageUrl = downloadPath
                self.imageView.image = image
            }
        }
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
extension SignupViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        defer {
            //no matter what happens, this will get executed
            dismiss(animated: true, completion: nil)
        }
        
        guard let image = info[UIImagePickerControllerOriginalImage] as? UIImage else {return}
        
        uploadImageToStorage(image)
        
    }
}



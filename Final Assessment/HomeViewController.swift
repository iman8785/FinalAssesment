//
//  HomeViewController.swift
//  Final Assessment
//
//  Created by Habib Zarrin Chang Fard on 03/10/2017.
//  Copyright © 2017 Habib Zahrrin Chang Fard. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseStorage
import FirebaseAuth
import SDWebImage

class HomeViewController: UIViewController {
    
    var handledata : DatabaseHandle = 0
    var users : [User] = []
    var ref : DatabaseReference!
    var userId : String = ""
    @IBOutlet weak var tableView: UITableView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        tableView.dataSource = self
        ref = Database.database().reference()
        guard let uid = Auth.auth().currentUser?.uid else {return}
        userId = uid
        ref.child("Users").observe(.childAdded, with:{ (snapshot) in
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
                
                DispatchQueue.main.async {
                    self.users.append(newUser)
                    self.tableView.reloadData()
                }
            }
        }
        
    )}
}
extension HomeViewController : UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as? CellTableViewCell else {return UITableViewCell()}
        
        
        let user = users[indexPath.row]
        cell.textLabel?.text = user.name
        
        
        return cell
    }
}



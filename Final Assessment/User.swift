//
//  User.swift
//  Final Assessment
//
//  Created by Habib Zarrin Chang Fard on 02/10/2017.
//  Copyright © 2017 Habib Zahrrin Chang Fard. All rights reserved.
//

import Foundation

class User {
    var id : String = ""
    var name : String = ""
    var email : String = ""
    var imageURL : String = ""
    var filename : String = ""
    var age : String = ""
    var gender : String = ""
    var description : String = ""
    
    static var currentUser : User?
    
    
    init(anID : String, aName : String,  anEmail : String, anImageURL : String, anFilename : String, anAge : String , aGender : String, aDescription : String  ) {
        self.id = anID
        self.name = aName
        self.email = anEmail
        self.imageURL = anImageURL
        self.filename = anFilename
        self.age = anAge
        self.gender = aGender
        self.description = aDescription
        
    }
    
    
    
}

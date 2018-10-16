//
//  Suggested.swift
//  discovery
//
//  Created by peishan lee on 14/10/18.
//  Copyright © 2018 The University of Melbourne. All rights reserved.
//

import UIKit

class Suggested {
    
    //MARK: Properties
    
    var name: String
    var intro: String
    var photo: UIImage?
    
    init?(name: String, photo: UIImage?, intro: String) {
        
        // The name must not be empty, name refers to unique username
        guard !name.isEmpty else {
            return nil
        }
        // The intro must not be empty, intro refers to customised name
        guard !intro.isEmpty else {
            return nil
        }
        
        
        // Initialize stored properties.
        self.name = name
        self.photo = photo
        self.intro = intro
        
    }
    
}

//
//  MessagesIDs.swift
//  RangeComm
//
//  Created by air on 03.11.15.
//  Copyright © 2015 Christoph Mueller. All rights reserved.
//

import Foundation

import Parse
import Bolts

class Message {
    
    var objectID: String?
    var deviceID: String?
    
    var text: String?
    
    // var location: PFGeoPoint?
    var longitude: Double?
    var latitude: Double?
    
    var rating: Int?
    
    var createdAt: String?
    var updatedAt: String?

}

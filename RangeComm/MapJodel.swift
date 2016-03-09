//
//  MapJodel.swift
//  Jodel2
//
//  Created by David Ganshorn on 2/24/16.
//  Copyright © 2016 Christoph Mueller. All rights reserved.
//

import Foundation

import MapKit

class MapText: NSObject, MKAnnotation {
   
    let title: String?
    let time: String?
    let color: String
    let username: String?
    let coordinate: CLLocationCoordinate2D
    // let icon: UIImage
    
    init(title: String, time: String, color: String, username: String, coordinate: CLLocationCoordinate2D) {
       
        self.title = title
        self.time = time
        self.color = color
        self.coordinate = coordinate
        self.username = username
        
        super.init()
    }
    
    var subtitle: String? {
        return time
    }
    
    // pinColor for disciplines: Sculpture, Plaque, Mural, Monument, other
    func pinColor() -> MKPinAnnotationColor  {
        switch color {
        case "Red":
            return .Red
        case "Purple":
            return .Purple
        case "Green":
            return .Green
        default:
            return .Green
        }
    }

    
}

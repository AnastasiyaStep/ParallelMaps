//
//  PinAnnotation.swift
//  ParallelMaps
//
//  Created by Anastasiya on 2/25/15.
//  Copyright (c) 2015 example. All rights reserved.
//

import Foundation
import MapKit
import UIKit

class PinAnnotation : NSObject, MKAnnotation {
    private var coord: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 0, longitude: 0)
    
    var coordinate : CLLocationCoordinate2D {
        get {
            return coord
        }
    }
    
    var title : String = "wewwe"
    var subtitle : String = "wewewewewwe"
    
    func setCoordinate(newCoordinate: CLLocationCoordinate2D) {
        self.coord = newCoordinate
    }
}
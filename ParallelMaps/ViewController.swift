//
//  ViewController.swift
//  ParallelMaps
//
//  Created by Anastasiya on 2/23/15.
//  Copyright (c) 2015 example. All rights reserved.
//

import UIKit
import MapKit

let MERCATOR_OFFSET: Double = 268435456
let MERCATOR_RADIUS: Double = 85445659.44705395
let MAX_GOOGLE_LEVELS : Double = 20

class ViewController: UIViewController, MKMapViewDelegate, GMSMapViewDelegate {

    @IBOutlet var mapView: MKMapView!
    @IBOutlet weak var googleMapView: GMSMapView!
    @IBOutlet weak var button: UIButton!
    
    @IBAction func zoomIn(sender: AnyObject) {
        let userLocation = mapView.userLocation
        
        mapView.centerCoordinate = userLocation.location.coordinate
        
        var location = mapView.userLocation.coordinate
        
        var viewRegion = MKCoordinateRegionMakeWithDistance(location, 90000, 90000)
        var adjustedRegion = self.mapView.regionThatFits(viewRegion)
        self.mapView.setRegion(adjustedRegion, animated: true)
        //googleMapView.center = userLocation
        
        var camera = GMSCameraPosition.cameraWithLatitude(googleMapView.myLocation.coordinate.latitude, longitude: googleMapView.myLocation.coordinate.longitude, zoom: 8.5)
        
        googleMapView.camera = GMSCameraPosition.cameraWithLatitude(googleMapView.myLocation.coordinate.latitude, longitude: googleMapView.myLocation.coordinate.longitude, zoom: 8.5)
        
        var marker = GMSMarker()
        marker.position = camera.target
        marker.snippet = "Hello World"
        marker.appearAnimation = kGMSMarkerAnimationPop
        marker.map = googleMapView
    }
    
    let locationManager = CLLocationManager()
    var mapRegion : MKCoordinateRegion!
    var googleMapRegion : NSNumber!
    
    var googleMapsCurrentZoom : Float!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        googleMapView.myLocationEnabled = true
        googleMapView.settings.compassButton = true
        googleMapView.settings.indoorPicker = true
        
        mapView.showsUserLocation = true
        
        var location = mapView.userLocation.coordinate
        
        var viewRegion = MKCoordinateRegionMakeWithDistance(location, 90000, 90000)
        var adjustedRegion = self.mapView.regionThatFits(viewRegion)
        self.mapView.setRegion(adjustedRegion, animated: true)
        
        mapView.delegate = self
        
        self.googleMapView.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    func mapView(mapView: MKMapView!, didUpdateUserLocation userLocation: MKUserLocation!) {
        
    }
    
    
    func mapView(mapView: MKMapView!, regionWillChangeAnimated animated: Bool) {
        mapRegion = self.mapView.region
        googleMapsCurrentZoom = 8.5
        //NSLog("lat = %f, long = %f", mapRegion.span.latitudeDelta, mapRegion.span.longitudeDelta)
        //NSLog("lat = %f long = %f", , mapView.userLocation.coordinate.longitude)
        
    }
    
    func mapView(mapView: MKMapView!, regionDidChangeAnimated animated: Bool) {
        var newRegion : MKCoordinateRegion
        var zoomLevel : CLLocationDegrees
        newRegion = mapView.region
        zoomLevel = mapRegion.span.latitudeDelta / newRegion.span.latitudeDelta
        
        var moveAmountLatitude = mapRegion.span.latitudeDelta - newRegion.span.latitudeDelta
        var moveAmountLongitude = mapRegion.span.longitudeDelta - newRegion.span.longitudeDelta
        
        var centerPixelX : Double = mapView.centerCoordinate.longitude
        var centerPixelY : Double = mapView.centerCoordinate.latitude
        
        var zoomNew = Float(getZoomLevel())
        
        var zFactor : NSInteger
        //if ((mapRegion.span.latitudeDelta/newRegion.span.latitudeDelta) > 1.0) {
            googleMapView.camera = GMSCameraPosition.cameraWithLatitude(mapView.region.center.latitude, longitude: mapView.region.center.longitude, zoom: zoomNew)
    }
    
    func getZoomLevel() -> Double {
        var longitudeDelta : CLLocationDegrees
        longitudeDelta = mapView.region.span.longitudeDelta
        var mapWidthInPixels : CGFloat
        mapWidthInPixels = mapView.bounds.size.width
        var zoomScale : Double = longitudeDelta * MERCATOR_RADIUS * M_PI / (180.0 * Double(mapWidthInPixels))
        var zoomer : Double = MAX_GOOGLE_LEVELS - log2(zoomScale)
        if (zoomer < 0) {
            zoomer = 0
        }
        return zoomer
    }
    
    func googleMapView(googleMapView: GMSMapView!, willMove gesture: Bool) {
        googleMapView.camera = GMSCameraPosition.cameraWithLatitude(googleMapView.myLocation.coordinate.latitude, longitude: googleMapView.myLocation.coordinate.longitude, zoom: 8.5)
    }
    
    func googleMapView(googleMapView: GMSMapView!, didChangeCameraPosition position: GMSCameraPosition!) {
        self.mapView.bounds.size = self.googleMapView.bounds.size
        NSLog("%f,%f",googleMapView.projection.visibleRegion().farLeft.latitude, googleMapView.projection.visibleRegion().farLeft.longitude);//north west
        
        /*var visibleRegion : GMSVisibleRegion
        visibleRegion = googleMapView.projection.visibleRegion()
        var bounds : GMSCoordinateBounds
        init() {
            bounds = visibleRegion
        }
        
        var northEast : CLLocationCoordinate2D
        var southWest : CLLocationCoordinate2D
        northEast = bounds.northEast
        southWest = bounds.southWest
        */
    }
    
    func googleMapView(googleMapView: GMSMapView!, idleAtCameraPosition position: GMSCameraPosition!) {
        button.setTitle("It works!", forState: UIControlState.Normal)
    }
    
    @IBAction func mapTypeSegmentPressed(sender: AnyObject) {
        let segmentedControl = sender as UISegmentedControl
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            googleMapView.mapType = kGMSTypeNormal
            mapView.mapType = MKMapType.Standard
        case 1:
            googleMapView.mapType = kGMSTypeSatellite
            mapView.mapType = MKMapType.Satellite
        case 2:
            googleMapView.mapType = kGMSTypeHybrid
            mapView.mapType = MKMapType.Hybrid
        default:
            googleMapView.mapType = googleMapView.mapType
            mapView.mapType = MKMapType.Standard
        }
    }
}


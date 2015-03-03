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
        //googleMapView.settings.myLocationButton = true
        googleMapView.settings.compassButton = true
        googleMapView.settings.indoorPicker = true
        
        mapView.showsUserLocation = true
        
        var location = mapView.userLocation.coordinate
        
        var viewRegion = MKCoordinateRegionMakeWithDistance(location, 90000, 90000)
        var adjustedRegion = self.mapView.regionThatFits(viewRegion)
        self.mapView.setRegion(adjustedRegion, animated: true)
        
        mapView.delegate = self
        
        googleMapView.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    func mapView(mapView: MKMapView!, didUpdateUserLocation userLocation: MKUserLocation!) {
        
    }
    
    
    func mapView(mapView: MKMapView!, regionWillChangeAnimated animated: Bool) {
        mapRegion = self.mapView.region
        //googleMapsCurrentZoom = self.googleMapView.camera.zoom
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
        
        NSLog("move latitude %f", moveAmountLatitude)
        //NSLog("move longitude %f", moveAmountLongitude)
        //NSLog("zoom %f", zoomLevel)
        //NSLog("google map zoom %f", googleMapView.camera.zoom)
        
        var centerPixelX : Double = mapView.centerCoordinate.longitude
        var centerPixelY : Double = mapView.centerCoordinate.latitude
        
        //var zoomLevel1 = 21 - round(log2(mapView.region.span.longitudeDelta * MERCATOR_RADIUS * M_PI / (180.0 * mapView.bounds.size.width)))
       // var zoomExponent : NSInteger = 20 - zoomLevel1
        
        var zFactor : NSInteger
        if ((mapRegion.span.latitudeDelta/newRegion.span.latitudeDelta) > 1.0) {
            //button.setTitle("MapView Zoom in", forState: UIControlState.Normal)
            googleMapView.camera = GMSCameraPosition.cameraWithLatitude(mapView.region.center.latitude, longitude: mapView.region.center.longitude, zoom: (googleMapsCurrentZoom * Float(zoomLevel)))
        }
        if ((mapRegion.span.latitudeDelta/newRegion.span.latitudeDelta) < 1.0) {
            //button.setTitle("MapView Zoom out", forState: UIControlState.Normal)
            googleMapView.camera = GMSCameraPosition.cameraWithLatitude(mapView.region.center.latitude, longitude: mapView.region.center.longitude, zoom: (googleMapsCurrentZoom * Float(zoomLevel)))
        }
        if (zoomLevel == 1.0) {
            googleMapView.camera = GMSCameraPosition.cameraWithLatitude(mapView.region.center.latitude, longitude: mapView.region.center.longitude, zoom: googleMapsCurrentZoom * Float(zoomLevel))
        }
    }
    
    func longitudeToPixelSpaceX(longitude: Double) -> Double {
        return round(MERCATOR_OFFSET + MERCATOR_RADIUS * longitude * M_PI / 180.0)
    }
    
    func latitudeToPixelSpaceY(latitude: Double) -> Double {
        return round(MERCATOR_OFFSET - MERCATOR_RADIUS * log((1.0 + sin(latitude * M_PI / 180.0)) / (1.0 - sin(latitude * M_PI / 180.0))) / 2.0)
    }
    
    func pixelSpaceXToLongitude(pixelX: Double) -> Double {
        return ((round(pixelX) - MERCATOR_OFFSET) / MERCATOR_RADIUS) * 180.0 / M_PI
    }
    
    func pixelSpaceYToLatitude(pixelY: Double) -> Double {
        return (M_PI / 2.0 - 2.0 * atan(exp((round(pixelY) - MERCATOR_OFFSET) / MERCATOR_RADIUS))) * 180.0 / M_PI
    }
    
    func coordinateSpan(mapView: MKMapView!, centerCoordinate: CLLocationCoordinate2D, zoomLevel: Int) -> MKCoordinateSpan {
        
        let centerPixelX = longitudeToPixelSpaceX(centerCoordinate.longitude)
        let centerPixelY = latitudeToPixelSpaceY(centerCoordinate.latitude)
        
        let zoomExponent = 20 - zoomLevel
        let zoomScale = pow(2.0, Double(zoomExponent))
        
        let mapSizeInPixels = mapView.bounds.size
        let scaledMapWidth = Double(mapSizeInPixels.width) * zoomScale
        let scaledMapHeight = Double(mapSizeInPixels.height) * zoomScale
        
        let topLeftPixelX = centerPixelX - (scaledMapWidth / 2)
        let topLeftPixelY = centerPixelY - (scaledMapHeight / 2)
        
        let minLng = pixelSpaceXToLongitude(topLeftPixelX) as CLLocationDegrees
        let maxLng = pixelSpaceXToLongitude(topLeftPixelX + scaledMapWidth)
        let longitudeDelta = maxLng - minLng
        
        let minLat = pixelSpaceXToLongitude(topLeftPixelY)
        let maxLat = pixelSpaceXToLongitude(topLeftPixelY + scaledMapHeight)
        let latitudeDelta = maxLat - minLat
        
        return MKCoordinateSpanMake(latitudeDelta, longitudeDelta)
    }
    
    func setCenterCoordinate(centerCoordinate: CLLocationCoordinate2D, zoomLevel:Int, animated: Bool) {
        let aZoomLevel = min(zoomLevel, 28)
        
        let span = coordinateSpan(mapView, centerCoordinate: centerCoordinate, zoomLevel: aZoomLevel)
        let region = MKCoordinateRegionMake(centerCoordinate, span)
        
        mapView.setRegion(region, animated: animated)
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
}


//
//  MapManager.swift
//  UITableViewApp
//
//  Created by Vladimir on 25.01.2023.
//

import UIKit
import MapKit

class MapManager {
    let locationManager = CLLocationManager()
    
     var placeCoordinate: CLLocationCoordinate2D?
     let regionInMeters = 1000.00
     var directionsArray: [MKDirections] = []
    
    
    
     func setupPlaceMark(place: Place, mapView: MKMapView) {
        guard let location = place.location else {return}
        
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(location) { placemarks, error in
            
            if let error = error {
                print(error)
                return
            }
            
            guard let placemarks = placemarks else {return}
            
            let placemark = placemarks.first
            
            let annotation = MKPointAnnotation()
            annotation.title = place.name
            annotation.subtitle = place.type
            
            guard let placemarkLocation = placemark?.location else {return}
            
            annotation.coordinate = placemarkLocation.coordinate
            self.placeCoordinate = placemarkLocation.coordinate
            
            mapView.showAnnotations([annotation], animated: true)
            mapView.selectAnnotation(annotation, animated: true)
            
        }
    }
    
    
     func checkLocationAuthorization(mapView: MKMapView, segueIdentifier:String) {
        switch CLLocationManager.authorizationStatus() {
        case .authorizedWhenInUse:
            mapView.showsUserLocation = true
            if segueIdentifier == "getAddress" { showUserLocation(mapView: mapView) }
            break
        case .denied:
            // Show alert controller
            break
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted:
            //alertC
            break
        case .authorizedAlways:
            break
        @unknown default:
            break
        }
    }
    
     func showUserLocation(mapView: MKMapView){
        if let location = locationManager.location?.coordinate {
            let region = MKCoordinateRegion(center: location,
                                            latitudinalMeters: regionInMeters,
                                            longitudinalMeters: regionInMeters)
            mapView.setRegion(region, animated: true)
        }
    }
    
    
     func getDirections(for mapView:MKMapView, previousLocation:(CLLocation) -> ()){
        
        guard let location = locationManager.location?.coordinate else{
            //showAlert(title: "Error",message: "Current location is not found")
            return
            
        }
        
        locationManager.startUpdatingLocation()
        previousLocation(CLLocation(latitude: location.latitude, longitude: location.longitude))
        
        guard let request = createDirectionsRequest(from: location) else {
            showAlert(title:"Error", message: "Destination is not found")
            return
        }
        let directions = MKDirections(request: request)
         
         resetMapView(with: mapView, directions: directions)
        
        directions.calculate { responce, error in
            if let error = error {
                print(error)
                return
            }
            guard let responce = responce else {
                self.showAlert(title:"Error", message: "Direction is not available")
                return
            }
            for route in responce.routes {
                mapView.addOverlay(route.polyline)
                mapView.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
                let distance = String(format: "%.1f", route.distance / 1000)
                let timeInterval = String(format: "%.0f", ((route.expectedTravelTime / 60)))
                //destinationTimeLabel.isHidden = false
                //destinationTimeLabel.text = "\(distance) км и \(timeInterval) минут"
            }
        }
    }
    
    
     func createDirectionsRequest(from coordinate: CLLocationCoordinate2D) -> MKDirections.Request? {
        guard let destinationCoordinate = placeCoordinate else {return nil}
        let startingLocation = MKPlacemark(coordinate: coordinate)
        let destination = MKPlacemark(coordinate: destinationCoordinate)
        
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: startingLocation)
        request.destination = MKMapItem(placemark: destination)
        request.transportType = .walking
        request.requestsAlternateRoutes = true
        
        return request
    }
    
    
     func startTrackingUserLocation(mapView: MKMapView,
                                           and location: CLLocation?,
                                           closure: (_ currentLocation: CLLocation) -> ()) {
        
        guard let location = location else { return }
        let center = getCenterLocation(for: mapView)
        guard center.distance(from: location) > 50 else { return }
        closure(center)
//        self.previousLocation = center
//        DispatchQueue.main.asyncAfter(deadline: .now() + 3){
//            self.showUserLocation()
//
//        }
    }
    
     func resetMapView(with mapView:MKMapView, directions: MKDirections) {
        
        mapView.removeOverlays(mapView.overlays)
        directionsArray.append(directions)
        let _ = directionsArray.map {$0.cancel()}
        directionsArray.removeAll()
        
    }
    
    
     func checkLocationServices(mapView:MKMapView, segueIdentifier: String, closure: () -> ()){
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            checkLocationAuthorization(mapView: mapView, segueIdentifier: segueIdentifier)
            closure()
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1){
                self.showAlert(title: "Location services are Disabled", message: "To enable it go: Settings > Privacy > Location Services and turn it On")
            }
        }
    }
    
    
     func getCenterLocation(for mapView:MKMapView) ->CLLocation {
        let latitude = mapView.centerCoordinate.latitude
        let longitude = mapView.centerCoordinate.longitude
        return CLLocation(latitude: latitude, longitude: longitude)
    }
    
     func showAlert(title: String, message:String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAtcion = UIAlertAction(title: "OK", style: .default)
        alert.addAction(okAtcion)
        
        let alertWindow = UIWindow(frame: UIScreen.main.bounds)
        alertWindow.rootViewController = UIViewController()
        alertWindow.windowLevel = UIWindow.Level.alert + 1
        alertWindow.makeKeyAndVisible()
        alertWindow.rootViewController?.present(alert,animated: true)
    }
}

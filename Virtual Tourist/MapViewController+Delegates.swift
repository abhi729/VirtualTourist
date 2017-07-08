//
//  MapViewController+Delegates.swift
//  Virtual Tourist
//
//  Created by Abhishek Agarwal on 02/07/17.
//  Copyright © 2017 Abhishek. All rights reserved.
//

import UIKit
import MapKit

extension MapViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        //capture the map settings after the map region has changed
        mapSettings["latitudeDelta"] = mapView.region.span.latitudeDelta as AnyObject
        mapSettings["longitudeDelta"] = mapView.region.span.longitudeDelta as AnyObject
        mapSettings["latitude"] = mapView.centerCoordinate.latitude as AnyObject
        mapSettings["longitude"] = mapView.centerCoordinate.longitude as AnyObject
        
        UserDefaults.standard.set(mapSettings, forKey: "mapSettings")
        
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: nil)
        pinView.animatesDrop = true
        return pinView
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if mapEditingInProgress {
            //delete annotation
            if let annotation = view.annotation as? PinAnnotation {
                if let pin = annotation.pin {
                    
                    let delegate = UIApplication.shared.delegate as! AppDelegate
                    delegate.stack.context.delete(pin)
                    delegate.stack.save()
                    
                    mapView.removeAnnotation(annotation)
                }
            }
        } else {
            //get images for pin location
            if let annotation = view.annotation as? PinAnnotation {
                if let _ = annotation.pin {
                    performSegue(withIdentifier: "SegueToPhotos", sender: annotation)
                }
            }
        }
    }
    
}

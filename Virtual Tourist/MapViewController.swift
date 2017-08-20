//
//  ViewController.swift
//  Virtual Tourist
//
//  Created by Abhishek Agarwal on 11/06/17.
//  Copyright © 2017 Abhishek. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class MapViewController: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var editButton: UIBarButtonItem!
    var deleteButton: UIButton!
    
    var mapEditingInProgress = false
    var deleteButtonHeight: CGFloat = 0.0
    var deleteButtonHeightConstant: CGFloat = 0.1
    
    var currentPin: PinAnnotation?
    var mapSettings =  [String:AnyObject]()
    
    @IBAction func editButtonTapped(_ sender: UIBarButtonItem) {
        mapEditingInProgress = !mapEditingInProgress
        
        if mapEditingInProgress {
            editButton.title = "Done"
            adjustVisibilityOfDeleteButton(isVisible: true)
        } else {
            editButton.title = "Edit"
            adjustVisibilityOfDeleteButton(isVisible: false)
        }
    }
    
    func adjustVisibilityOfDeleteButton(isVisible : Bool) {
        deleteButtonHeight = deleteButtonHeightConstant * view.bounds.maxY
        
        if isVisible {
            deleteButton.isHidden = false
            UIView.animate(withDuration: 0.5, animations: { () -> Void in
                self.mapView.frame.origin.y -= self.deleteButtonHeight
                self.deleteButton.frame.origin.y -=  self.deleteButtonHeight
            })
            
        } else {
            UIView.animate(withDuration: 0.5, animations: { () -> Void in
                self.mapView.frame.origin.y = 0
                self.deleteButton.frame.origin.y = self.view.bounds.maxY
            }, completion: { (complete) -> Void in
                self.deleteButton.isHidden = true
            })
        }
    }
    
    func loadPins() {
        let delegate = UIApplication.shared.delegate as! AppDelegate
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Pin")
        
        do {
            if let results = try delegate.stack.context.fetch(fetchRequest) as? [Pin] {
                for mapPin in results {
                    let pin = PinAnnotation()
                    let latitude = mapPin.latitude 
                    let longitude = mapPin.longitude 
                    pin.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                    
                    pin.pin = mapPin
                    mapView.addAnnotation(pin)
                }
            }
        } catch {
            alertUI(withTitle: "Query Error", message: "There was an error retrieving the pins from the database!")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        
        setupDeleteButton()
        
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(self.addPinToMap(_:)))
        longPressGesture.minimumPressDuration = 1
        mapView.addGestureRecognizer(longPressGesture)
        
        loadPins()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let settings = UserDefaults.standard.object(forKey: "mapSettings") as? [String: AnyObject] {
//            mapSettings = settings
            
            let latitude = settings["latitude"] as! CLLocationDegrees
            let longitude = settings["longitude"] as! CLLocationDegrees
            let mapCenter = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            
            mapView.centerCoordinate = mapCenter
            
            let latDelta = (settings["latitudeDelta"] as! CLLocationDegrees)
            let longDelta = (settings["longitudeDelta"] as! CLLocationDegrees)
            let mapSpan = MKCoordinateSpan(latitudeDelta: latDelta, longitudeDelta: longDelta)
            
            mapView.region.span = mapSpan
            
        }
    }
    
    func setupDeleteButton() {
        
        deleteButton = UIButton()
        deleteButton.isHidden = true
        deleteButtonHeight = deleteButtonHeightConstant * view.bounds.maxY
        deleteButton.frame = CGRect(x: 0, y: view.bounds.maxY, width: view.bounds.size.width, height: deleteButtonHeightConstant * view.bounds.maxY)
        deleteButton.backgroundColor = UIColor.red
        deleteButton.setTitle("Tap Pins to Delete!", for: UIControlState())
        
        view.addSubview(deleteButton)
        
    }
    
    func addPinToMap(_ longPressGesture:UILongPressGestureRecognizer) {
        if mapEditingInProgress {
            return
        }
        
        switch longPressGesture.state {
        case .began:
            currentPin = PinAnnotation()
            let touchCoord = longPressGesture.location(in: mapView)
            currentPin!.coordinate = mapView.convert(touchCoord, toCoordinateFrom: mapView)
            mapView.addAnnotation(currentPin!)
            
            break
            
        case .changed:
            if let pin = currentPin {
                let touchCoord = longPressGesture.location(in: mapView)
                pin.coordinate = mapView.convert(touchCoord, toCoordinateFrom: mapView)
            }
            
            break
            
        case .ended:
            if let pin = self.currentPin {
                let delegate = UIApplication.shared.delegate as! AppDelegate
                
                var pinDictionary = [String: AnyObject]()
                pinDictionary[Pin.Keys.latitude] = Double(pin.coordinate.latitude) as AnyObject
                pinDictionary[Pin.Keys.longitude] = Double(pin.coordinate.longitude) as AnyObject
                
                let pinEntity = Pin(dictionary: pinDictionary,context: delegate.stack.context)
                pin.pin = pinEntity
                
                delegate.stack.save()
                
                currentPin = nil
            }
            
            break
            
        default:
            break
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "SegueToPhotos" {
            let destination = segue.destination as! PhotoViewController
            let annotation = sender as! PinAnnotation
            
            if let pin = annotation.pin {
                destination.pin = pin
                mapView.deselectAnnotation(annotation, animated: true)
            }
        }
    }

}


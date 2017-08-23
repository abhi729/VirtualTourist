//
//  PhotoViewController.swift
//  Virtual Tourist
//
//  Created by Abhishek Agarwal on 08/07/17.
//  Copyright © 2017 Abhishek. All rights reserved.
//

import UIKit
import MapKit
import CoreData

extension UIViewController {
    func alertUI(withTitle title:String, message:String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
}

class PhotoViewController: UIViewController {
    
    @IBOutlet weak var photoCollectionView: UICollectionView!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var newCollectionButton: UIButton!
    @IBOutlet weak var noPhotosLabel: UILabel!
    
    var pin: Pin?
    var selectedPhotos: [IndexPath]?
    var photoUrls: [String: Date]?
    var isFetchingData = false
    
    lazy var fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult> = {
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Photo")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        
        if let latitude = self.pin?.latitude, let longitude = self.pin?.longitude {
            let predicate = NSPredicate(format: "pin = %@", argumentArray: [self.pin!])
            fetchRequest.predicate = predicate
        }
        
        let delegate = UIApplication.shared.delegate as! AppDelegate
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: delegate.stack.context, sectionNameKeyPath: nil, cacheName: nil)
        
        return fetchedResultsController
    }()
    
    func removePhotosFromPin(_ indexPath:IndexPath) {
        DispatchQueue.main.async {
            let photo = self.fetchedResultsController.object(at: indexPath) as! Photo
            let delegate = UIApplication.shared.delegate as! AppDelegate
            delegate.stack.context.delete(photo)
            delegate.stack.save()
        }
    }
    
    @IBAction func newCollectionTapped(_ sender: AnyObject) {
        if (selectedPhotos?.count ?? 0) > 0 {
            photoCollectionView.performBatchUpdates({ () -> Void in
                for indexPath in (self.selectedPhotos?.sorted(by: { $0.item > $1.item}))! {
                    self.removePhotosFromPin(indexPath)
                }
            }, completion: { (completed) -> Void in
                DispatchQueue.main.async {
                    self.photoCollectionView.deleteItems(at: self.selectedPhotos!)
                    self.selectedPhotos?.removeAll()
                    self.newCollectionButton.setTitle("New Collection", for: UIControlState())
                }
            })
            
        } else {
            newCollectionButton.isEnabled = false
            
            let delegate = UIApplication.shared.delegate as! AppDelegate
            self.isFetchingData = true
            if let photos = self.fetchedResultsController.fetchedObjects as? [Photo] {
                for photo in photos {
                    delegate.stack.context.delete(photo)
                }
                delegate.stack.save()
            }
            self.isFetchingData = false
            self.getPhotos()
        }
    }
    
    func loadfetchedResultsController() {
        fetchedResultsController.delegate = self
        
        //get results from the fetchedResultsController
        do {
            try self.fetchedResultsController.performFetch()
        } catch {
            let fetchError = error as NSError
            print("\(fetchError), \(fetchError.userInfo)")
            self.alertUI(withTitle: "Failed Query", message: "Failed to load photos")
        }
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        let width = view.frame.width / 3
        let layout = photoCollectionView.collectionViewLayout as! UICollectionViewFlowLayout
        layout.itemSize = CGSize(width: width - 1, height: width - 1)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        FlickrClient.sharedInstance().pageNumber = 1
        
        mapView.isUserInteractionEnabled = false
        photoCollectionView.backgroundColor = UIColor.white
        photoCollectionView.allowsMultipleSelection = true
        
        if let pin = self.pin {
            let latitude = pin.latitude
            let longitude = pin.longitude
            let center = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))
            
            mapView.setRegion(region, animated: true)
            
            let marker = MKPointAnnotation()
            marker.coordinate = center
            mapView.addAnnotation(marker)
        }
        
        loadfetchedResultsController()
        
        selectedPhotos = [IndexPath]()
        
        noPhotosLabel.isHidden = true
        
        let count = pin?.photos?.count
        if (count ?? 0) <= 0 {
            newCollectionButton.isEnabled = false
            getPhotos()
        }
        
    }
    
    
    
    func getPhotos() {
        FlickrClient.sharedInstance().getPhotosByLocation(forPin: pin!) { (result, error) in
            guard error == nil else {
                self.alertUI(withTitle: "Failed", message: "Unable to fetch images for this location")
                return
            }
            if let photos = result {
                if let photosDict = photos["photos"] as? [String: AnyObject], let photosDesc = photosDict["photo"] as? [[String: AnyObject]] {
                    self.photoUrls = [:]
                    let df = DateFormatter()
                    df.dateFormat = "yyyy-MM-dd HH:mm:ss"
                    for (_, photo) in photosDesc.enumerated() {
                        if let urlString = photo["url_m"] as? String, let dateTaken = photo["datetaken"] as? String {
                            self.photoUrls?[urlString] = df.date(from: dateTaken)
                        }
                    }
                    if (self.photoUrls?.keys.count ?? 0) > 0 {
                        let delegate = UIApplication.shared.delegate as! AppDelegate
                        DispatchQueue.main.async {
                            for urlString in self.photoUrls!.keys {
                                if let date = self.photoUrls![urlString] as NSDate? {
                                    let photo = Photo(context: delegate.stack.context)
                                    photo.imageUrl = urlString
                                    photo.date = date
                                    photo.pin = self.pin!
                                    photo.image = nil
                                }
                            }
                            delegate.stack.save()
                            
                            self.photoCollectionView.isHidden = false
                            self.newCollectionButton.isEnabled = true
                        }
                    } else {
                        DispatchQueue.main.async {
                            self.photoCollectionView.isHidden = true
                            self.newCollectionButton.isEnabled = true
                            self.noPhotosLabel.isHidden = false
                        }
                    }
                } else {
                    DispatchQueue.main.async {
                        self.photoCollectionView.isHidden = true
                        self.noPhotosLabel.text = "No more images!"
                        self.noPhotosLabel.isHidden = false
                    }
                }
            }
        }
    }
    
}

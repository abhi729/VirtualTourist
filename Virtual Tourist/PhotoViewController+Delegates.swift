//
//  PhotoViewController+Delegates.swift
//  Virtual Tourist
//
//  Created by Abhishek Agarwal on 08/07/17.
//  Copyright © 2017 Abhishek. All rights reserved.
//

import UIKit
import MapKit
import CoreData

extension PhotoViewController: UICollectionViewDataSource {
    
    func configure(_ cell: PhotoCollectionCell, forRowAtIndexPath indexPath: IndexPath) -> UICollectionViewCell {
        if let indexSet = selectedPhotos {
            if indexSet.contains(indexPath) {
                if cell.photoCellImageView.alpha == 1.0 {
                    DispatchQueue.main.async {
                        cell.photoCellImageView.alpha = 0.5
                    }
                }
            } else {
                DispatchQueue.main.async {
                    cell.photoCellImageView.alpha = 1.0
                }
            }
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let sectionInfo = fetchedResultsController.sections {
            return sectionInfo[section].numberOfObjects
        } else {
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "photoCell", for: indexPath) as! PhotoCollectionCell
        
        let photo = fetchedResultsController.object(at: indexPath) as! Photo
        let imageLocation = photo.imageLocation!
        
        if let url = URL(string: Photo.Keys.filePath)?.appendingPathComponent(imageLocation) {
            print(url.path)
            if FileManager.default.fileExists(atPath: url.path) {
                cell.photoCellImageView.image = UIImage(contentsOfFile: url.path)
                cell.loadingView.isHidden = true
            } else {
                let imageUrlString = photo.imageUrl!
                if let imageUrl = URL(string: imageUrlString) {
                    DispatchQueue.global(qos: .userInteractive).async {
                        if let imageData = try? Data(contentsOf: imageUrl) {
                            try? imageData.write(to: url, options: .atomic)
                            DispatchQueue.main.async {
                                cell.photoCellImageView.image = UIImage(data: imageData)
                                cell.loadingView.isHidden = true
                            }
                        }
                    }
                }
            }
        }
        
        return configure(cell, forRowAtIndexPath: indexPath)
    }
    
}

extension PhotoViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) as? PhotoCollectionCell {
            cell.isSelected = true
            selectedPhotos?.append(indexPath)
            newCollectionButton.setTitle("Remove Selected Pictures", for: UIControlState())
            _ = configure(cell, forRowAtIndexPath: indexPath)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) as? PhotoCollectionCell {
            cell.isSelected = false
            if let indexToRemove = selectedPhotos?.index(of: indexPath) {
                selectedPhotos?.remove(at: indexToRemove)
            }
            
            if selectedPhotos?.count == 0 {
                newCollectionButton.setTitle("New Collection", for: UIControlState())
            }
            
            _ = configure(cell, forRowAtIndexPath: indexPath)
        }
    }
}

extension PhotoViewController : NSFetchedResultsControllerDelegate {
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .delete:
            if isFetchingData {
                photoCollectionView.reloadData()
            }
            break
            
        case .insert:
            photoCollectionView.reloadData()
            break
            
        default:
            return
        }
    }
}

//
//  PhotoCollectionCell.swift
//  Virtual Tourist
//
//  Created by Abhishek Agarwal on 02/07/17.
//  Copyright © 2017 Abhishek. All rights reserved.
//

import UIKit

class PhotoCollectionCell: UICollectionViewCell {
    
    @IBOutlet weak var photoCellImageView: UIImageView!
    @IBOutlet weak var loadingView: UIView! {
        didSet {
            loadingView.clipsToBounds = true
            loadingView.layer.cornerRadius = 10
            let activityIndicatorView = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width:
                25, height: 25))
            activityIndicatorView.center = self.center
            loadingView.addSubview(activityIndicatorView)
            activityIndicatorView.hidesWhenStopped = true
            activityIndicatorView.activityIndicatorViewStyle = .white
            activityIndicatorView.startAnimating()
        }
    }
}

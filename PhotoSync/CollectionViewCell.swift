//
//  CollectionViewCell.swift
//  PhotoSync
//
//  Created by Aadil Majeed on 12/27/16.
//  Copyright © 2016 BML. All rights reserved.
//

import UIKit

class CollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var imageView: UIImageView!
    // MARK: - View Life Cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        imageView.backgroundColor = Utility.themeColor()
    }
    
    deinit {
        self.imageView.image = nil
    }
}

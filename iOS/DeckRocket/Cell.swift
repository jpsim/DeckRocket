//
//  Cell.swift
//  DeckRocket
//
//  Created by JP Simard on 6/13/14.
//  Copyright (c) 2014 JP Simard. All rights reserved.
//

import UIKit

class Cell: UICollectionViewCell {
    let imageView = UIImageView()
    
    init(frame: CGRect) {
        super.init(frame: frame)
        imageView.frame = CGRect(origin: CGPoint(), size: frame.size)
        imageView.contentMode = UIViewContentMode.ScaleAspectFit
        contentView.addSubview(imageView)
    }
}

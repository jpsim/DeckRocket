//
//  CollectionViewLayout.swift
//  DeckRocket
//
//  Created by JP Simard on 6/14/14.
//  Copyright (c) 2014 JP Simard. All rights reserved.
//

import UIKit

final class CollectionViewLayout: UICollectionViewFlowLayout {

    override init() {
        super.init()
        if let windowSize = UIApplication.shared.delegate?.window??.bounds.size {
            itemSize = windowSize
        }
        scrollDirection = .horizontal
        minimumInteritemSpacing = 0
        minimumLineSpacing = 0
    }

    required convenience init(coder aDecoder: NSCoder) {
        self.init()
    }
}

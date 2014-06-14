//
//  CollectionViewLayout.swift
//  DeckRocket
//
//  Created by JP Simard on 6/14/14.
//  Copyright (c) 2014 JP Simard. All rights reserved.
//

import UIKit

class CollectionViewLayout: UICollectionViewFlowLayout {
    init() {
        super.init()
        itemSize = UIApplication.sharedApplication().delegate.window!.bounds.size
        scrollDirection = UICollectionViewScrollDirection.Horizontal
        minimumInteritemSpacing = 0
        minimumLineSpacing = 0
    }
}

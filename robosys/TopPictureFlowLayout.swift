
//
//  TopPictureFlowLayout.swift
//  robosys
//
//  Created by 刘渊 on 2017/4/20.
//  Copyright © 2017年 joekoe. All rights reserved.
//

import UIKit

class TopPictureFlowLayout: UICollectionViewFlowLayout {

    override func prepareLayout() {
        
        self.scrollDirection = .Vertical
        
        self.minimumInteritemSpacing = 1
        self.minimumLineSpacing = 1
        
        
        let height : CGFloat = (self.collectionView!.frame.size.height - 1)/2
        let widht : CGFloat = (self.collectionView!.frame.size.width - 2)/3
        
        self.itemSize = CGSizeMake(widht, height)
        self.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0)
        
    }
}

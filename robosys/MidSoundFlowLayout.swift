//
//  MidSoundFlowLayout.swift
//  robosys
//
//  Created by 刘渊 on 2017/4/21.
//  Copyright © 2017年 joekoe. All rights reserved.
//

import UIKit

class MidSoundFlowLayout: UICollectionViewFlowLayout {

    override func prepareLayout() {
        
        self.scrollDirection = .Vertical
        
        self.minimumInteritemSpacing = 0
        self.minimumLineSpacing = 0

        let height : CGFloat = self.collectionView!.frame.size.height / 2
        let width : CGFloat = (self.collectionView!.frame.size.width - 12) / 3
        self.itemSize = CGSizeMake(width, height)
        self.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0)
        
    }

}

//
//  ScanRobotViewController.swift
//  robosys
//
//  Created by Cheer on 16/5/19.
//  Copyright © 2016年 joekoe. All rights reserved.
//

import UIKit
import SnapKit
class ScanRobotViewController: AppViewController,UIScrollViewDelegate
{
    
    deinit
    {
        print("\(classForCoder)--hello there")
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        (view as! ScanRobotView).scrollV.zoomScale = 0.35
        
        let tempStr = UIDevice.currentDevice().systemVersion.substringToIndex(UIDevice.currentDevice().systemVersion.startIndex.advancedBy(2)).hasSuffix(".") ? "去连接" : "下一步"
        (view as! ScanRobotView).connectBtn.setTitle(tempStr, forState: .Normal)

    }
}

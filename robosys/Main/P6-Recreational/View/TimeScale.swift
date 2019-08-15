//
//  TimeScale.swift
//  robosys
//
//  Created by Cheer on 16/7/14.
//  Copyright © 2016年 joekoe. All rights reserved.
//

import Foundation

class TimeScale: UIView
{
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var timeImg: UIImageView!

    var index:Int!
    
    override func layoutSubviews()
    {
        super.layoutSubviews()

        timeImg.frame.size.width = 45 - timeImg.frame.origin.x
        
        if index == 15
        {
            timeImg.frame.size.width = 5
        }
    }
    
}
//
//  AppAlertView.swift
//  robosys
//
//  Created by Cheer on 16/5/19.
//  Copyright © 2016年 joekoe. All rights reserved.
//

import UIKit

class AppAlertView: AppView
{
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subTitleLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var backBtn: UIButton!
    
    
    override func awakeFromNib()
    {
    
    }
    
    @IBAction func click(sender: UIButton)
    {
        dismiss()
    }
    
    deinit
    {
        print("\(classForCoder)--hello there")
    }
}
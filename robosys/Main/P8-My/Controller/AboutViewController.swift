//
//  AboutViewController.swift
//  robosys
//
//  Created by Cheer on 16/7/18.
//  Copyright © 2016年 joekoe. All rights reserved.
//

import UIKit

class AboutViewController: AppViewController
{
    @IBOutlet weak var versionBackView: UIView!
    @IBOutlet weak var versionLabel: UILabel!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.versionBackView.layer.borderColor = UIColor(red: 136/255, green: 150/255, blue: 204/255, alpha: 1).CGColor
        self.versionBackView.layer.borderWidth = 1.0
        self.versionBackView.layer.cornerRadius = 5.0
        self.versionBackView.backgroundColor = UIColor(red: 7/255, green: 17/255, blue: 35/255, alpha: 0.5)
        
        let version = NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleShortVersionString") as! NSString
        self.versionLabel.text = version as String
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        HYBProgressHUD.dismiss()
    }
}

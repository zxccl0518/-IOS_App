//
//  RegistViewController.swift
//  robosys
//
//  Created by Cheer on 16/5/18.
//  Copyright © 2016年 joekoe. All rights reserved.
//

import UIKit

class RegistViewController : AppViewController

{
    //-MARK:生命周期
    override func viewWillDisappear(animated: Bool)
    {
        super.viewWillDisappear(animated)
        
        (view as! RegistView).timer.invalidate()
        (view as! RegistView).captchaBtn.setTitle("获取验证码", forState: UIControlState.Normal)
    }
    deinit
    {
        print("\(classForCoder)--hello there")
    }
}
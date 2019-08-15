//
//  AppViewController.swift
//  robosys
//
//  Created by Cheer on 16/8/17.
//  Copyright © 2016年 joekoe. All rights reserved.
//

import UIKit

class AppViewController: UIViewController
{
    override func shouldAutorotate() -> Bool {
        return true
    }
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return .Portrait
    }
    override func preferredInterfaceOrientationForPresentation() -> UIInterfaceOrientation {
        return .Portrait
    }
    
    override func viewDidLayoutSubviews()
    {
        for v in view.subviews
        {
            if v is MainHeadView
            {
                view.bringSubviewToFront(v)
            }
            if v is LeftView
            {
                view.bringSubviewToFront(v)
            }
            if v is AppAlert
            {
                view.bringSubviewToFront(v)
                view.bringSubviewToFront((v as! AppAlert).topView)
            }
        }
    }
    

}

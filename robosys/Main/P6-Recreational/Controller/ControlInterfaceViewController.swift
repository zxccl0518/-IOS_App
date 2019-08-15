//
//  ControlInterfaceViewController.swift
//  robosys
//
//  Created by Cheer on 16/6/8.
//  Copyright © 2016年 joekoe. All rights reserved.
//


import UIKit

class ControlInterfaceViewController: AppViewController
{
    override func viewDidLoad()
    {
        super.viewDidLoad()
        UIDevice.currentDevice().setValue(UIInterfaceOrientation.LandscapeRight.rawValue, forKey: "orientation")
    }

    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return .LandscapeRight
    }
    override func preferredInterfaceOrientationForPresentation() -> UIInterfaceOrientation {
        return .LandscapeRight
    }
    
    override func viewDidDisappear(animated: Bool)
    {
        UIDevice.currentDevice().setValue(UIInterfaceOrientation.Portrait.rawValue, forKey: "orientation")
    }
    
    deinit
    {
        print("\(classForCoder)--hello there")
    }
}


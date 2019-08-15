//
//  AppNavgationController.swift
//  robosys
//
//  Created by Cheer on 16/5/18.
//  Copyright © 2016年 joekoe. All rights reserved.
//

import UIKit

class AppNavgationController: UINavigationController
{
    override func shouldAutorotate() -> Bool
    {
        return viewControllers.last!.shouldAutorotate()
    }
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask
    {
        return viewControllers.last!.supportedInterfaceOrientations()
    }
    override func preferredInterfaceOrientationForPresentation() -> UIInterfaceOrientation
    {
        return viewControllers.last!.preferredInterfaceOrientationForPresentation()
    }
}

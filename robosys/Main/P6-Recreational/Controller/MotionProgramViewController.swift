//
//  MotionProgramViewController.swift
//  robosys
//
//  Created by Cheer on 16/6/2.
//  Copyright © 2016年 joekoe. All rights reserved.
//
import UIKit

class MotionProgramViewController: AppViewController
{
    var programming : Programming?
    var programming_Last : Programming?
    var isEdit = false
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        automaticallyAdjustsScrollViewInsets = false
        
        UIDevice.currentDevice().setValue(UIInterfaceOrientation.LandscapeRight.rawValue, forKey: "orientation")
        
        (view as! MotionProgramView).programming = programming
        (view as! MotionProgramView).isEdit = isEdit
        (view as! MotionProgramView).programming_Last = programming_Last
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        UIDevice.currentDevice().setValue(UIInterfaceOrientation.LandscapeRight.rawValue, forKey: "orientation")

    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
        if (view as! MotionProgramView).timer != nil
        {
            (view as! MotionProgramView).timer.invalidate()
            (view as! MotionProgramView).timer = nil
        }
        
        if (view as! MotionProgramView).audioRecorder != nil
        {
            (view as! MotionProgramView).audioRecorder.delegate = nil
            (view as! MotionProgramView).audioRecorder = nil
        }
        
        UIDevice.currentDevice().setValue(UIInterfaceOrientation.Portrait.rawValue, forKey: "orientation")
    }
    
    override func viewWillDisappear(animated: Bool)
    {
        super.viewWillDisappear(animated)
        
        if (view as! MotionProgramView).timer != nil
        {
            (view as! MotionProgramView).timer.invalidate()
            (view as! MotionProgramView).timer = nil
        }
        
        if (view as! MotionProgramView).audioRecorder != nil
        {
            (view as! MotionProgramView).audioRecorder.delegate = nil
            (view as! MotionProgramView).audioRecorder = nil
        }
        
        UIDevice.currentDevice().setValue(UIInterfaceOrientation.Portrait.rawValue, forKey: "orientation")
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return .LandscapeRight
    }
    override func preferredInterfaceOrientationForPresentation() -> UIInterfaceOrientation {
        return .LandscapeRight
    }
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        
        let contentSize = CGSizeMake(size.width-51, (size.height-123.5)*2)
        (view as! MotionProgramView).originalWidthFloat = contentSize.width
        (view as! MotionProgramView).rightTable?.frame = CGRectMake(0, 0, contentSize.width, contentSize.height)
        (view as! MotionProgramView).backGroundScrollView.contentSize = contentSize
        (view as! MotionProgramView).leftHeightConstraint.constant = contentSize.height
        (view as! MotionProgramView).rightTable!.delegate = (view as! MotionProgramView)
        (view as! MotionProgramView).rightTable!.dataSource = (view as! MotionProgramView)
        (view as! MotionProgramView).leftTable!.delegate = (view as! MotionProgramView)
        (view as! MotionProgramView).leftTable!.dataSource = (view as! MotionProgramView)
        
    }
}







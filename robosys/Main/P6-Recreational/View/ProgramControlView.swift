//
//  ProgramControl.swift
//  robosys
//
//  Created by Cheer on 16/6/2.
//  Copyright © 2016年 joekoe. All rights reserved.
//

import UIKit

class ProgramControlView: AppView
{
    @IBOutlet weak var myProgramBtn: UIButton!
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        
        initMainHeadView("编程控制", imageName: "返回")
        
        myProgramBtn.setImage(UIImage(named: "我的程序按下"), forState: .Selected)
    }

    //动作编程
    @IBAction func motionProgram(sender: UIButton)
    {
        jump2AnyController(MotionProgramViewController(nibName: "MotionProgramView",bundle: nil))
    }
    
    //程序管理
    @IBAction func myProgram(sender: UIButton)
    {
        jump2AnyController(MyProgramViewController(nibName: "MyProgramView",bundle: nil))

    }
}

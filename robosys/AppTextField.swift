//
//  AppTextField.swift
//  robosys
//
//  Created by Cheer on 16/11/16.
//  Copyright © 2016年 joekoe. All rights reserved.
//

import UIKit

class AppTextField: UITextField
{
    lazy var rightBtn:UIButton =
    {
        var btn = UIButton(frame: CGRectMake(0,0,30,30))
        btn.setImage(UIImage(named:"清空"), forState: .Normal)
        btn.addTarget(self, action: #selector(AppTextField.click), forControlEvents: .TouchUpInside)
        return btn
    }()
    override func awakeFromNib() {
        super.awakeFromNib()
        
        rightViewMode = .WhileEditing
        rightView = rightBtn
    }
    func click()
    {
        text = ""
    }
}
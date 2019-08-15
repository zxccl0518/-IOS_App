//
//  PermissionView.swift
//  robosys
//
//  Created by Cheer on 16/10/12.
//  Copyright © 2016年 joekoe. All rights reserved.
//

import Foundation

class PermissionView : AppView
{
    override func awakeFromNib()
    {
        super.awakeFromNib()
        
        initMainHeadView("管理员权限", imageName: "返回")
    }
    
    @IBAction func transferPermission(sender: UIButton)
    {
//        connect.didUnBind(loginM.num, token: loginM.token, robotId: loginM.robotId)
    }
    
    @IBAction func normalPermission(sender: UIButton) {
//        Alert({}, title: "功能暂未开放", message: "")
    }
    @IBAction func deletePermission(sender: UIButton) {
//        Alert({}, title: "功能暂未开放", message: "")
    }
}

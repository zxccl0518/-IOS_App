//
//  HelpViewController.swift
//  robosys
//
//  Created by Cheer on 16/7/15.
//  Copyright © 2016年 joekoe. All rights reserved.
//

import UIKit

class HelpViewController: AppViewController
{
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        HYBProgressHUD.dismiss()
    }
}

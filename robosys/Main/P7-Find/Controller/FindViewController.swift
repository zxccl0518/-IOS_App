//
//  FindViewController.swift
//  robosys
//
//  Created by Cheer on 16/5/26.
//  Copyright © 2016年 joekoe. All rights reserved.
//

import UIKit

class FindViewController: AppViewController
{
    
    private lazy var findV : UIView = FindView()

    // loading
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        //        HYBProgressHUD.dismiss()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        self.view.addSubview(findV)
        
        findV.snp_makeConstraints { (make) in
//            self.view.layoutIfNeeded()
            make.edges.equalTo(self.view)
        }
        
        
    }
   
    
}




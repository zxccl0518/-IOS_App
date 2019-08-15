//
//  MyProgramHeaderView.swift
//  robosys
//
//  Created by yaorenjin on 2017/3/17.
//  Copyright © 2017年 joekoe. All rights reserved.
//

import UIKit

class MyProgramHeaderView: UIView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.backView.layer.borderColor = UIColor(red: 136/255, green: 150/255, blue: 204/255, alpha: 1).CGColor
        self.backView.layer.borderWidth = 1.0
        self.backView.layer.cornerRadius = 5.0
        self.backView.backgroundColor = UIColor(red: 7/255, green: 17/255, blue: 35/255, alpha: 0.5)
    }

    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var backView: UIView!

}

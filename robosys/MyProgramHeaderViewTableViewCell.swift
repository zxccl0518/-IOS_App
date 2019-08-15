//
//  MyProgramHeaderViewTableViewCell.swift
//  robosys
//
//  Created by yaorenjin on 2017/3/20.
//  Copyright © 2017年 joekoe. All rights reserved.
//

import UIKit

class MyProgramHeaderViewTableViewCell: UITableViewCell {

    typealias btnClickBolock = (btn:UIButton)->Void
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code\
        
        self.backgroundColor = UIColor.clearColor()
        self.contentView.backgroundColor = UIColor.clearColor()
        
        self.backView.layer.borderColor = UIColor(red: 136/255, green: 150/255, blue: 204/255, alpha: 1).CGColor
        self.backView.layer.borderWidth = 1.0
        self.backView.layer.cornerRadius = 5.0
        self.backView.backgroundColor = UIColor(red: 7/255, green: 17/255, blue: 35/255, alpha: 0.5)
        
    }
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var btn: UIButton!
    @IBOutlet weak var backView: UIView!
    var clickBolock = btnClickBolock?()
    
    
    @IBAction func btnClick(sender: AnyObject) {
        
        if (self.clickBolock != nil) {
            
            self.clickBolock!(btn: sender as! UIButton)
        }
        return
    }
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

//
//  RemindDetailsCell.swift
//  robosys
//
//  Created by Cheer on 16/7/21.
//  Copyright © 2016年 joekoe. All rights reserved.
//

import UIKit

class RemindDetailsCell: UITableViewCell
{
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var label: UILabel!
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        
        backgroundColor = .clearColor()
        selectionStyle = .None
    }
}

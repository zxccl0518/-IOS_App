//
//  ProgramAlertView.swift
//  robosys
//
//  Created by Cheer on 16/6/14.
//  Copyright © 2016年 joekoe. All rights reserved.
//

class ProgramAlertView : AppView
{
    @IBOutlet weak var ensureBtn: UIButton!
    @IBOutlet weak var cancelBtn: UIButton!
    
    internal var code = {}
    
    internal var delay = false
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        
    }
    @IBAction func clickEnsure(sender: UIButton)
    {
        code()
        
        if delay
        {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW,Int64(2 * Double(NSEC_PER_SEC))), dispatch_get_main_queue(), {
                self.dismiss()
            })
        }
        else
        {
            dismiss()
        }
    }
    
    @IBAction func clickCancel(sender: UIButton)
    {
        dismiss()
    }    
}

//
//  CompactSoundViewController.swift
//  robosys
//
//  Created by Alan on 2017/9/6.
//  Copyright © 2017年 joekoe. All rights reserved.
//

import UIKit

class CompactSoundViewController: UIViewController {
    @IBOutlet var appView: AppView!

    @IBOutlet weak var soundText: UITextView!
    @IBOutlet weak var playBtn: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        appView.initMainHeadView("合成音", imageName: "返回")
        
        setupUI()
    }
    
    func setupUI() {
        
        playBtn.addTarget(self, action: #selector(playBtnClick), forControlEvents: UIControlEvents.TouchUpInside)
    }
    
    func playBtnClick() {
        
        self.soundText.resignFirstResponder()
        
        Alert({
            
            RobotControl.shareInstance().didPlaySST(self.soundText.text)
            
            }, title: "播放中...", message: "")
    }

    
}

//
//  MusicLocationListController.swift
//  robosys
//
//  Created by Alan on 2017/10/9.
//  Copyright © 2017年 joekoe. All rights reserved.
//

import UIKit

class MusicLocationListController: AppViewController {
    @IBOutlet var appView: AppView!

    var musicPathList = String()
    private lazy var control = RobotControl.shareInstance()
    override func viewDidLoad() {
        super.viewDidLoad()

        appView.initMainHeadView("我的音乐", imageName: "返回")
        
    }

    @IBAction func popLocationList(sender: UIButton) {
        
        
        Alert({
            let vc = MusicViewController(nibName: "MusicViewController",bundle: nil)
            
            self.navigationController?.pushViewController(vc, animated: true)
            }, title: "扫描音乐目录", message: "")

    }
   
    @IBAction func popHistoryList(sender: UIButton) {
        
        Alert({
            let vc = RobotPlayHistoryController(nibName: "RobotPlayHistoryController",bundle: nil)
            vc.historyPath = self.musicPathList
            
            self.navigationController?.pushViewController(vc, animated: true)
            }, title: "扫描历史歌单...", message: "")
    }

   
}

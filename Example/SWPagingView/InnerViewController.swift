//
//  InnerViewController.swift
//  SWPagingView_Example
//
//  Created by lixiaomeng on 2018/7/29.
//  Copyright © 2018年 CocoaPods. All rights reserved.
//

import UIKit

class InnerViewController: UIViewController {

  private var label = UILabel()
  
  var indexId: Int = 0
  
  override func viewDidLoad() {
    super.viewDidLoad()
  }

  override func viewDidLayoutSubviews() {
    label.frame = self.view.bounds
    self.view.addSubview(label)
    self.label.font = UIFont.systemFont(ofSize: 30)
    self.label.textColor = UIColor.black
    self.label.contentMode = .center
    self.label.text = "第\(indexId + 1)个界面"
    self.label.textAlignment = .center
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }

}

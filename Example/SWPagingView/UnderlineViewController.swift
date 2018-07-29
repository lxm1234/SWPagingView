//
//  UnderlineViewController.swift
//  SWPagingView_Example
//
//  Created by lixiaomeng on 2018/7/29.
//  Copyright © 2018年 CocoaPods. All rights reserved.
//

import UIKit
import SWPagingView

class UnderlineViewController: UIViewController {

  private var pageTitleView: SWPageTitleView?
  private var pageContentView: SWPageContentView?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupPageView()
  }

  /// 设置pageView的title和content
  func setupPageView() {
    let titleArr: [String] = ["OC", "Swift", "C++", "Java", "Python"]
    
    let configure = SWPageTitleViewConfigure()
    configure.isNeedBounces = false
    configure.isOpenTitleTextZoom = true
    configure.isTitleGradientEffect = false
//    configure.titleTextScaling = 0.3
//    configure.bottomSeparatorColor = UIColor.clear
//    configure.spacingBetweenButtons = 0
    configure.indicatorHeight = 5
    configure.indicatorColor = UIColor.blue
    configure.indicatorAdditionalWidth = 50
    pageTitleView = SWPageTitleView(frame: CGRect(x: 0,
                                                      y: UIApplication.shared.statusBarFrame.size.height + 44,
                                                      width: self.view.frame.width,
                                                      height: 44),
                                        delegate: self,
                                        titleNames: titleArr,
                                        configure: configure)
    self.view.addSubview(pageTitleView!)
    
    var childArr: [UIViewController] = []
    for index in 0..<titleArr.count {
      let controller = InnerViewController()
      controller.indexId = index
      childArr.append(controller)
    }
    let contentViewHeight = self.view.frame.height - self.pageTitleView!.frame.maxY
    self.pageContentView = SWPageContentView(frame: CGRect.init(x: 0,
                                                                   y: self.pageTitleView!.frame.maxY,
                                                                   width: self.view.frame.size.width,
                                                                   height: contentViewHeight),
                                                parentVC: self,
                                                childVCs: childArr)
    self.pageContentView?.delegatePageContentView = self
    self.view.addSubview(pageContentView!)
  }

}

// MARK: - SWPageTitleViewDelegate, SWPageContentViewDelegate
extension UnderlineViewController: SWPageTitleViewDelegate, SWPageContentViewDelegate {

  func pageTitleView(pageTitleView: SWPageTitleView, selectedIndex: Int) {
    self.pageContentView!.setPageContentView(currentIndex: selectedIndex)
  }

  func pageContentView(pageContentView: SWPageContentView, progress: CGFloat, originalIndex: Int, targetIndex: Int) {
    self.pageTitleView?.setPageTitleView(progress: progress, originalIndex: originalIndex, targetIndex: targetIndex)
  }
}

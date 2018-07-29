//
//  SWPageContentView.swift
//  SmartWalnut
//
//  Created by lixiaomeng on 2018/6/15.
//  Copyright © 2018年 com.hetao101. All rights reserved.
//

import UIKit

@objc public protocol SWPageContentViewDelegate: NSObjectProtocol {
  /**
     *  联动 SWPageTitleView 的方法
     *
     *  @param pageContentView      SWPageContentView
     *  @param progress             SWPageContentView 内部视图滚动时的偏移量
     *  @param originalIndex        原始视图所在下标
     *  @param targetIndex          目标视图所在下标
     */
  @objc optional func pageContentView(pageContentView: SWPageContentView, progress: CGFloat, originalIndex: Int, targetIndex: Int)
  /**
     *  给 SWPageContentView 所在控制器提供的方法（根据偏移量来处理返回手势的问题）
     *
     *  @param pageContentView     SWPageContentView
     *  @param offsetX             SWPageContentView 内部视图的偏移量
     */
  //@objc optional func pageContentView(pageContentView: PageContentView, offsetX: CGFloat)
}

open class SWPageContentView: UIView {

   var parentViewController: UIViewController?
   var childViewControllers: [UIViewController]?
  public var delegatePageContentView: SWPageContentViewDelegate?

   lazy var collectionView: UICollectionView = {
    let flowLayout = UICollectionViewFlowLayout()
    flowLayout.itemSize = self.bounds.size
    flowLayout.minimumLineSpacing = 0
    flowLayout.minimumInteritemSpacing = 0
    flowLayout.scrollDirection = .horizontal
    let collectionViewX: CGFloat = 0
    let collectionViewY: CGFloat = 0
    let collectionViewW = self.frame.width
    let collectionViewH = self.frame.height
    let collectionView = UICollectionView(frame: CGRect(x: collectionViewX,
      y: collectionViewY,
      width: collectionViewW,
      height: collectionViewH), collectionViewLayout: flowLayout)
    collectionView.showsVerticalScrollIndicator = false
    collectionView.showsHorizontalScrollIndicator = false
    collectionView.isPagingEnabled = true
    collectionView.bounces = false
    collectionView.backgroundColor = UIColor.white
    collectionView.delegate = self
    collectionView.dataSource = self
    collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "cell")
    return collectionView
  }()

  /// 记录刚开始时的偏移量
   var startOffsetX: CGFloat = 0
  /// 标记按钮是否点击
   var isClickBtn: Bool = false

  public init(frame: CGRect, parentVC: UIViewController, childVCs: [UIViewController]) {
    super.init(frame: frame)
    self.parentViewController = parentVC
    self.childViewControllers = childVCs
    self.setupSubviews()
  }

  required public init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func setupSubviews() {
    // 0、处理偏移量
    let tempView = UIView.init(frame: CGRect.zero)
    self.addSubview(tempView)
    // 1、将所有的子控制器添加父控制器中
    childViewControllers!.forEach { (childVC) in
      self.parentViewController!.addChildViewController(childVC)
    }
    // 2、添加UICollectionView, 用于在Cell中存放控制器的View
    self.addSubview(self.collectionView)
  }
}

extension SWPageContentView: UICollectionViewDataSource, UICollectionViewDelegate {
  public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return self.childViewControllers?.count ?? 0
  }

  public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
    cell.contentView.subviews.forEach {
      $0.removeFromSuperview()
    }
    //设置内容
    let childVC = self.childViewControllers![indexPath.item]
    childVC.view.frame = cell.contentView.frame
    cell.contentView.addSubview(childVC.view)
    return cell
  }
}

extension SWPageContentView: UIScrollViewDelegate {
  public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
    self.isClickBtn = false
    self.startOffsetX = scrollView.contentOffset.x
  }

  public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
    let offsetX = scrollView.contentOffset.x - self.startOffsetX
    let scrollViewW = scrollView.bounds.size.width
    if abs(offsetX) / scrollViewW > 0.95 {
      var originalIndex: Int = 0
      var targetIndex: Int = 0
      if offsetX > 0{
        //左滑
        targetIndex = Int(scrollView.contentOffset.x / scrollViewW)
        originalIndex = targetIndex - 1
      } else {
        //右滑
        targetIndex = Int(scrollView.contentOffset.x / scrollViewW)
        originalIndex = targetIndex + 1
      }
      // 3、pageContentViewDelegare; 将 progress／sourceIndex／targetIndex 传递给 SWPageTitleView
      if self.delegatePageContentView != nil,
        self.delegatePageContentView!.self.responds(
          to: #selector(self.delegatePageContentView!.pageContentView(pageContentView: progress: originalIndex: targetIndex:))) {
        self.delegatePageContentView!.pageContentView!(pageContentView: self,
                                                       progress: 1,
                                                       originalIndex: originalIndex,
                                                       targetIndex: targetIndex)
      }
    }
  }
  
  public func scrollViewDidScroll(_ scrollView: UIScrollView) {
    // 1、定义获取需要的数据
    var progress: CGFloat = 0
    var originalIndex: Int = 0
    var targetIndex: Int = 0
    // 2、判断是左滑还是右滑
    let currentOffsetX = scrollView.contentOffset.x
    let scrollViewW = scrollView.bounds.size.width
    if currentOffsetX > self.startOffsetX { // 左滑
      // 1、计算 progress
      progress = currentOffsetX / scrollViewW - CGFloat(floorf(Float(currentOffsetX / scrollViewW)))
      // 2、计算 originalIndex
      originalIndex = Int(currentOffsetX / scrollViewW)
      // 3、计算 targetIndex
      targetIndex = originalIndex + 1
      if targetIndex >= self.childViewControllers!.count {
        progress = 1
        targetIndex = originalIndex
      }
      // 4、如果完全划过去
      if currentOffsetX - self.startOffsetX == scrollViewW {
        progress = 1
        targetIndex = originalIndex
      }
    } else { // 右滑
      // 1、计算 progress
      progress = 1 - (currentOffsetX / scrollViewW - CGFloat(floorf(Float(currentOffsetX / scrollViewW))))
      // 2、计算 targetIndex
      targetIndex = Int(currentOffsetX / scrollViewW)
      // 3、计算 originalIndex
      originalIndex = targetIndex + 1
      if originalIndex >= self.childViewControllers!.count {
        originalIndex = self.childViewControllers!.count - 1
      }
    }
    // 3、pageContentViewDelegare; 将 progress／sourceIndex／targetIndex 传递给 SWPageTitleView
    if self.delegatePageContentView != nil,
      self.delegatePageContentView!.self.responds(
        to: #selector(self.delegatePageContentView!.pageContentView(pageContentView: progress: originalIndex: targetIndex:))) {
      self.delegatePageContentView!.pageContentView!(pageContentView: self,
        progress: progress,
        originalIndex: originalIndex,
        targetIndex: targetIndex)
    }
  }

  public func setPageContentView(currentIndex: Int) {
    self.isClickBtn = true
    let offsetX = CGFloat(currentIndex) * self.collectionView.frame.width
    //处理内容偏移
    self.collectionView.contentOffset = CGPoint(x: offsetX, y: 0)
  }
}

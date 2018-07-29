//
//  PageTitleView.swift
//  SmartWalnut
//
//  Created by lixiaomeng on 2018/6/15.
//  Copyright © 2018年 com.hetao101. All rights reserved.
//

import UIKit

public protocol SWPageTitleViewDelegate: class {
  /**
     *  联动 pageContent 的方法
     *
     *  @param pageTitleView      SWPageTitleView
     *  @param selectedIndex      选中按钮的下标
     */
  func pageTitleView(pageTitleView: SWPageTitleView, selectedIndex: Int)
}

open class SWPageTitleView: UIView {

  /** 选中标题按钮下标，默认为 0 */
  var selectedIndex: Int = 0
  /** 重置选中标题按钮下标（用于子控制器内的点击事件改变标题的选中下标）*/
  var resetSelectedIndex: Int = 0
  /// SWPageTitleViewDelegate
  private weak var delegatePageTitleView: SWPageTitleViewDelegate?
  /// SWPageTitleView 配置信息
  private var configure: SWPageTitleViewConfigure!
  /// scrollView
  private var isScroller: Bool = false
  /// 按钮之间的间距
  private var btnSpace: CGFloat = 0

  private lazy var scrollView: UIScrollView = {
    let scrollView = UIScrollView()
    scrollView.showsVerticalScrollIndicator = false
    scrollView.showsHorizontalScrollIndicator = false
    scrollView.alwaysBounceHorizontal = true
    scrollView.bounces = self.configure.isNeedBounces
    scrollView.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height)
    return scrollView
  }()
  /// 指示器
  private lazy var indicatorView: UIView = {
    let indicatorView = UIView()
    if self.configure.indicatorStyle == .cover {
      //遮盖样式指示器的高度
      let tempIndicatorViewH = self.titleArr[0].sw_sizeWithString(font: self.configure.titleFont).height
      indicatorView.frame.size.height = min(self.frame.height, max(self.configure.indicatorHeight, tempIndicatorViewH))
      indicatorView.frame.origin.y = (self.frame.height - indicatorView.frame.height) * 0.5
      //圆角处理
      let cornerRadius = min(0.5 * indicatorView.frame.height, max(0, self.configure.indicatorCornerRadius))
      indicatorView.layer.cornerRadius = cornerRadius
      indicatorView.layer.masksToBounds = true
      // 边框宽度及边框颜色
      indicatorView.layer.borderWidth = self.configure.indicatorBorderWidth
      indicatorView.layer.borderColor = self.configure.indicatorBorderColor.cgColor
    } else {
      indicatorView.frame.size.height = min(self.frame.height, max(0, self.configure.indicatorHeight))
      indicatorView.frame.origin.y = self.frame.height - indicatorView.frame.height
    }
    //设置背景
    indicatorView.backgroundColor = self.configure.indicatorColor
    return indicatorView
  }()

  /// 底部分割线
  private lazy var bottomSeparator: UIView = {
    let view = UIView()
    let bottomSeparatorW: CGFloat = self.frame.width
    let bottomSeparatorH: CGFloat = 0.5
    let bottomSeparatorX: CGFloat = 0
    let bottomSeparatorY: CGFloat = self.frame.height - bottomSeparatorH
    view.frame = CGRect.init(x: bottomSeparatorX, y: bottomSeparatorY, width: bottomSeparatorW, height: bottomSeparatorH)
    view.backgroundColor = self.configure.bottomSeparatorColor
    return view
  }()
  /// 保存外界传递过来的标题数组
  private var titleArr: [String] = []
  /// 存储标题按钮的数组
  private var btnMArr: [UIButton] = []
  /// tempBtn
  private var tempBtn: UIButton?
  /// 记录所有按钮文字宽度
  private var allBtnTextWidth: CGFloat = 0
  /// 标记按钮下标
  private var signBtnIndex: Int = 0
  /// 开始颜色, 取值范围 0~1
  private var startR: CGFloat = 0
  private var startG: CGFloat = 0
  private var startB: CGFloat = 0
  /// 完成颜色, 取值范围 0~1
  private var endR: CGFloat = 0
  private var endG: CGFloat = 0
  private var endB: CGFloat = 0

  public init(frame: CGRect, delegate: SWPageTitleViewDelegate, titleNames: [String], configure: SWPageTitleViewConfigure) {
    super.init(frame: frame)
    self.backgroundColor = UIColor.white.withAlphaComponent(0.77)
    self.delegatePageTitleView = delegate
    self.titleArr = titleNames
    self.configure = configure
    self.setupSubviews()
  }

  required public init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func setupSubviews() {
    // 1、添加 UIScrollView
    self.addSubview(self.scrollView)
    // 2、添加标题按钮
    self.setupTitleButtons()
    // 3、添加底部分割线
    self.addSubview(self.bottomSeparator)
    // 4、添加指示器
    self.scrollView.insertSubview(self.indicatorView, at: 0)
  }

  override open func layoutSubviews() {
    super.layoutSubviews()
    let lastBtn = self.btnMArr.last
    if let tag = lastBtn?.tag, tag >= selectedIndex && selectedIndex >= 0 {
      self.btnAction(button: self.btnMArr[selectedIndex])
    }
  }

  func setupTitleButtons() {
    // 计算所有按钮的文字宽度
    self.titleArr.forEach { (title) in
      self.allBtnTextWidth += title.sw_sizeWithString(font: self.configure.titleFont).width
    }
    // 所有按钮文字宽度 ＋ 按钮之间的间隔
    var allWidth = self.configure.spacingBetweenButtons * CGFloat(self.titleArr.count) + self.allBtnTextWidth
    allWidth = CGFloat(ceilf(Float(allWidth)))
    let titleCount = self.titleArr.count
    self.isScroller = allWidth > self.frame.width
    self.btnSpace = self.isScroller ? self.configure.spacingBetweenButtons : (self.frame.width - self.allBtnTextWidth) / CGFloat(titleCount)
    var btnX:CGFloat = 20
    let btnH: CGFloat = (self.configure.indicatorStyle == .underLine) ? (self.frame.height - self.configure.indicatorHeight) : self.frame.height
    for index in 0..<titleCount {
      let btnW: CGFloat = self.titleArr[index].sw_sizeWithString(font: self.configure.titleFont).width
      let btn = UIButton(frame: CGRect(x: btnX, y: 0, width: btnW, height: btnH))
      btnX += (btnW + btnSpace)
      btn.tag = index
      btn.titleLabel?.font = self.configure.titleFont
      btn.setTitle(self.titleArr[index], for: .normal)
      btn.setTitleColor(self.configure.titleColor, for: .normal)
      btn.setTitleColor(self.configure.titleSelectedColor, for: .selected)
      btn.addTarget(self, action: #selector(btnAction(button:)), for: .touchUpInside)
      self.btnMArr.append(btn)
      self.scrollView.addSubview(btn)
      self.setupStartColor(color: self.configure.titleColor)
      self.setupEndColor(color: self.configure.titleSelectedColor)
    }
    //scrollView的contentSize宽度
    if !self.isScroller { //静止样式
      self.scrollView.contentSize = CGSize(width: self.frame.width, height: self.frame.height)
    } else { //滚动样式
      let scrollViewWidth = self.scrollView.subviews.last!.frame.maxX + 20
      self.scrollView.contentSize = CGSize(width: scrollViewWidth, height: self.frame.height)
    }
  }

  //pragma mark - - - 颜色设置的计算
  /// 开始颜色设置
  func setupStartColor(color: UIColor) {
    let components = self.getRGBComponents(color: color)
    self.startR = components[0]
    self.startG = components[1]
    self.startB = components[2]
  }
  /// 结束颜色设置
  func setupEndColor(color: UIColor) {
    let components = self.getRGBComponents(color: color)
    self.endR = components[0]
    self.endG = components[1]
    self.endB = components[2]
  }

  /**
     *  指定颜色，获取颜色的RGB值
     *
     *  @param components RGB数组
     *  @param color      颜色
     */
  func getRGBComponents(color: UIColor) -> [CGFloat] {
    let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
    let data = UnsafeMutablePointer<CUnsignedChar>.allocate(capacity: 4)
    let context = CGContext(data: data, width: 1, height: 1, bitsPerComponent: 8, bytesPerRow: 4, space: rgbColorSpace, bitmapInfo: 1)
    context?.setFillColor(color.cgColor)
    context?.fill(CGRect.init(x: 0, y: 0, width: 1, height: 1))
    var components: [CGFloat] = []
    for i in 0..<3 {
      components.append(CGFloat(data[i]) / 255.0)
    }
    return components
  }
  //pragma mark - - - 标题按钮的点击事件
  @objc func btnAction(button: UIButton) {
    // 1、改变按钮的选择状态
    self.changeSelectedButton(button)
    // 2、滚动标题选中按钮居中
    if isScroller {
      self.selectedBtnCenter(button)
    }
    // 3、改变指示器的位置以及指示器宽度样式
    self.changeIndicatorViewLocation(button)
    // 4、pageTitleViewDelegate
    self.delegatePageTitleView?.pageTitleView(pageTitleView: self, selectedIndex: button.tag)
    // 5、标记按钮下标
    self.signBtnIndex = button.tag
  }
  //改变按钮的选择状态
  func changeSelectedButton(_ button: UIButton) {
    if self.tempBtn == nil {
      button.isSelected = true
      self.tempBtn = button
    } else if self.tempBtn != nil && self.tempBtn == button {
      button.isSelected = true
    } else if self.tempBtn != nil && self.tempBtn != button {
      self.tempBtn!.isSelected = false
      button.isSelected = true
      self.tempBtn = button
    }

    // 此处作用：避免滚动内容视图时手指不离开屏幕的前提下点击按钮后再次滚动内容视图图导致按钮文字由于文字渐变导致未选中按钮文字的不标准化处理
    if self.configure.isTitleGradientEffect {
      self.btnMArr.forEach({ (button) in
        button.titleLabel?.textColor = self.configure.titleColor
      })
    }
    // 标题文字缩放属性
    if self.configure.isOpenTitleTextZoom {
      self.btnMArr.forEach({ (button) in
        button.transform = CGAffineTransform(scaleX: 1, y: 1)
      })
      button.transform = CGAffineTransform(scaleX: 1 + self.configure.titleTextScaling, y: 1 + self.configure.titleTextScaling)
    }
  }
  //滚动标题选中按钮居中
  func selectedBtnCenter(_ button: UIButton) {
    // 计算偏移量
    var offsetX = button.center.x - self.frame.width * 0.5
    if offsetX < 0 {
      offsetX = 0
    }
    // 获取最大滚动范围
    let maxOffsetX = self.scrollView.contentSize.width - self.frame.width
    if offsetX > maxOffsetX {
      offsetX = maxOffsetX
    }
    // 滚动标题滚动条
    self.scrollView.setContentOffset(CGPoint(x: offsetX, y: 0), animated: true)
  }

  //改变指示器的位置以及指示器宽度样式
  func changeIndicatorViewLocation(_ button: UIButton) {
    UIView.animate(withDuration: TimeInterval(self.configure.indicatorAnimationTime)) {
      let tempIndicatorWidth = button.frame.width + min(self.configure.indicatorAdditionalWidth, self.btnSpace)
      self.indicatorView.frame.size.width = tempIndicatorWidth
      self.indicatorView.center.x = button.center.x
    }
  }
}
//提供给外界的方法
public extension SWPageTitleView {
  /**
     *  根据下标重置标题文字
     *
     *  @param index 标题所对应的下标
     *  @param title 新标题名
     */
  func resetTitle(with index: Int, newTitle title: String) {
    guard index < self.btnMArr.count else {
      return
    }
    let button = self.btnMArr[index]
    button.setTitle(title, for: .normal)
    if self.signBtnIndex == index {
      let tempIndicatorWidth = button.frame.width + min(self.configure.indicatorAdditionalWidth, self.btnSpace)
      self.indicatorView.frame.size.width = tempIndicatorWidth
      self.indicatorView.frame.size.width = button.center.x
    }
  }

  func setPageTitleView(progress: CGFloat, originalIndex: Int, targetIndex: Int) {
    // 1、取出 originalBtn／targetBtn
    let originalButton = self.btnMArr[originalIndex]
    let targetButton = self.btnMArr[targetIndex]
    self.signBtnIndex = targetButton.tag
    
    // 2、 滚动标题选中居中
    self.selectedBtnCenter(targetButton)
    // 3、处理指示器的逻辑
    self.indicatorViewScroll(progress: progress, originalBtn: originalButton, targetBtn: targetButton)
    // 4、颜色的渐变(复杂)
    self.titleGradientEffect(progress: progress, originalBtn: originalButton, targetBtn: targetButton)
    // 5 、标题文字缩放属性
    if self.configure.isOpenTitleTextZoom {
      //左边缩放
      originalButton.transform = CGAffineTransform.init(scaleX: (1 - progress) * self.configure.titleTextScaling + 1,
                                                        y: (1 - progress) * self.configure.titleTextScaling + 1)
      //右边缩放
      targetButton.transform = CGAffineTransform.init(scaleX: progress * self.configure.titleTextScaling + 1,
                                                      y: progress * self.configure.titleTextScaling + 1)
    }
  }

  func indicatorViewScroll(progress: CGFloat, originalBtn: UIButton, targetBtn: UIButton) {
    //计算indicatorView偏移量
    let offsetX = (targetBtn.center.x - originalBtn.center.x) * progress
    //计算indicatorView的宽度
    let offsetWidth = (targetBtn.frame.width - originalBtn.frame.width) * progress
    self.indicatorView.center.x = originalBtn.center.x + offsetX
    self.indicatorView.frame.size.width = originalBtn.frame.width + min(btnSpace, self.configure.indicatorAdditionalWidth) + offsetWidth
  }

  func titleGradientEffect(progress: CGFloat, originalBtn: UIButton, targetBtn: UIButton) {
    if self.configure.isTitleGradientEffect {
      // 获取 targetProgress
      let targetProgress = progress
      // 获取 originalProgress
      let originalProgress = 1 - targetProgress
      
      let r = self.endR - self.startR
      let g = self.endG - self.startG
      let b = self.endB - self.startB
      let originalColor = UIColor.init(red: self.startR + r * originalProgress,
                                       green: self.startG + g * originalProgress,
                                       blue: self.startB + b * originalProgress,
                                       alpha: 1)
      let targetColor = UIColor.init(red: self.startR + r * targetProgress,
                                     green: self.startG + g * targetProgress,
                                     blue: self.startB + b * targetProgress,
                                     alpha: 1)
      
      // 设置文字颜色渐变
      originalBtn.titleLabel?.textColor = originalColor
      targetBtn.titleLabel?.textColor = targetColor
    } else {
      if progress == 1, originalBtn.tag != targetBtn.tag {
        originalBtn.titleLabel?.textColor = self.configure.titleColor
        targetBtn.titleLabel?.textColor = self.configure.titleSelectedColor
        
      }
    }
  }
}

extension String {
  func sw_sizeWithString(font: UIFont) -> CGSize {
    let attrDic = [NSAttributedStringKey.font: font]
    let attrString = NSAttributedString(string: self, attributes: attrDic)
    return attrString.boundingRect(with: CGSize(width: 0, height: 0), options: .usesLineFragmentOrigin, context: nil).integral.size
  }
}

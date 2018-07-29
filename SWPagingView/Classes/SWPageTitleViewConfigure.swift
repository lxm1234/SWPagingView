//
//  SWPageTitleViewConfigure.swift
//  SmartWalnut
//
//  Created by lixiaomeng on 2018/6/15.
//  Copyright © 2018年 com.hetao101. All rights reserved.
//

import UIKit

public enum IndicatorStyle {
  /// 下划线样式
  case underLine
  /// 遮盖样式
  case cover
}

open class SWPageTitleViewConfigure: NSObject {
  /** 是否让标题按钮文字有渐变效果，默认为 true */
  public var isTitleGradientEffect: Bool = true
  /** 是否开启标题按钮文字缩放效果，默认为 false */
  public var isOpenTitleTextZoom: Bool = false
  /** 标题文字缩放比，默认为 0.1f，取值范围 0 ～ 0.3f */
  public var titleTextScaling: CGFloat = 0.1
  /* SWPageTitleView 底部分割线颜色，默认为 lightGrayColor */
  public var bottomSeparatorColor: UIColor = UIColor.lightGray
  /** 普通状态下标题按钮文字的颜色，默认为黑色 */
  public var titleColor: UIColor = UIColor.black
  /** 选中状态下标题按钮文字的颜色，默认为红色 */
  public var titleSelectedColor: UIColor = UIColor.red
  /** 标题文字字号大小，默认 15 号字体 */
  public var titleFont: UIFont = UIFont.systemFont(ofSize: 15)
  /** 按钮之间的间距，默认为 20.0f */
  public var spacingBetweenButtons: CGFloat = 20.0
  /** 指示器高度，默认为 2.0f */
  public var indicatorHeight: CGFloat = 2.0
  /** 指示器颜色，默认为红色 */
  public var indicatorColor: UIColor = UIColor.red
  /** 指示器的额外宽度，介于按钮文字宽度与按钮宽度之间 */
  public var indicatorAdditionalWidth: CGFloat = 0
  /** 指示器动画时间，默认为 0.1f，取值范围 0 ～ 0.3f */
  public var indicatorAnimationTime: TimeInterval = 0.1
  /** 指示器样式，默认为 SWIndicatorStyleDefault */
  public var indicatorStyle: IndicatorStyle = .underLine
  /** 指示器遮盖样式下的圆角大小，默认为 0.1f */
  public var indicatorCornerRadius: CGFloat = 0.1
  /** 指示器遮盖样式下的边框宽度，默认为 0.0f */
  public var indicatorBorderWidth: CGFloat = 0.0
  /** 指示器遮盖样式下的边框颜色，默认为 clearColor */
  public var indicatorBorderColor: UIColor = UIColor.clear
  /** SWPageTitleView 是否需要弹性效果，默认为 true */
  public var isNeedBounces: Bool = true
}

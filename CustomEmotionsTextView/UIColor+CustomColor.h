//
//  UIColor+CustomColor.h
//  jiangzhi
//
//  Created by Cobb on 15/5/15.
//  Copyright (c) 2015年 Hu Zhiyuan. All rights reserved.
//

#import <UIKit/UIKit.h>


/**
 * 酱知app中使用的颜色枚举
 */
typedef NS_ENUM(NSInteger, ColorElement) {
    ColorElementWhite       = 0xffffff,      //白色
    ColorElementDarkGray    = 0x818181,      //灰色（深色）
    ColorElementGray        = 0xbbbbbb,      //灰色（稍深）
    ColorElementLineGray    = 0xe2e4e4,      //灰色（分割线）
    ColorElementLightGray   = 0xededed,      //灰色（浅色）
    ColorElementLowGray     = 0xf9f9f9,      //灰色（最浅）
    ColorElementYellow      = 0xffd727,      //黄色
    ColorElementDarkYellow  = 0xe29818,      //深黄色
    ColorElementRed         = 0xeb5c3b,      //红色
    ColorElementRedYellow   = 0x76161b,      //深红色
    ColorElementBlue        = 0x3a599a,      //蓝色
    ColorElementBlack       = 0x1e1b1a,      //黑色
    ColorElementBrown       = 0x403836,      //棕色
    ColorElementNone        = NSIntegerMax,  //无此选项
};

/**
 * 字体或色块的状态
 */
typedef NS_OPTIONS(NSInteger, ColorState) {
    ColorStateNormal       = 0,      //字体和色块普通状态
    ColorStateHighlighted  = 1 << 0, //字体和色块高亮状态
    ColorStateDisabled     = 1 << 1, //字体和色块不可点击状态
    ColorStateSelected     = 1 << 2, //字体和色块选中状态
};



@interface UIColor (CustomColor)


/**
 * 十六进制的颜色值转换为颜色UIColor（带透明度）
 */
+(UIColor*) colorWithHex:(NSInteger)hexValue alpha:(CGFloat)alphaValue;

/**
 * 十六进制的颜色值转换为颜色UIColor
 */
+(UIColor*) colorWithHex:(NSInteger)hexValue;

/**
 * 颜色UIColor获取十六进制的颜色值
 */
+(NSString *) hexFromUIColor: (UIColor*) color;

/**
 * @brief 根据控件环境返回颜色
 * @param backColor 背景色
 * @param textColor 文字颜色
 * @param blockColor 色块颜色
 * @param state 控件状态
 */
+ (UIColor *) colorWithbackColor:(ColorElement)backColor AndTextColor:(ColorElement)textColor BlockColor:(ColorElement)blockColor AndState:(ColorState)state;

/**
 * @brief 根据控件环境返回颜色
 * @param backColor 背景色
 * @param state 控件状态
 */
+ (UIColor *) colorWithbackColor:(ColorElement)backColor AndState:(ColorState)state;

/**
 * @brief 根据控件环境返回颜色
 * @param backColor 背景色
 * @param blockColor 色块颜色
 * @param state 控件状态
 */
+ (UIColor *) colorWithbackColor:(ColorElement)backColor BlockColor:(ColorElement)blockColor AndState:(ColorState)state;

/**
 * @brief 根据控件环境返回颜色
 * @param backColor 背景色
 * @param textColor 文字颜色
 * @param state 控件状态
 */
+ (UIColor *) colorWithbackColor:(ColorElement)backColor AndTextColor:(ColorElement)textColor AndState:(ColorState)state;


@end

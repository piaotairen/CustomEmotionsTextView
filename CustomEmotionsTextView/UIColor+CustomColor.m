//
//  UIColor+CustomColor.m
//  jiangzhi
//
//  Created by Cobb on 15/5/15.
//  Copyright (c) 2015年 Hu Zhiyuan. All rights reserved.
//

#import "UIColor+CustomColor.h"
#import "CmdCollect.pch"


@implementation UIColor (CustomColor)

+ (UIColor*) colorWithHex:(NSInteger)hexValue alpha:(CGFloat)alphaValue
{
    return [UIColor colorWithRed:((float)((hexValue & 0xFF0000) >> 16))/255.0
                           green:((float)((hexValue & 0xFF00) >> 8))/255.0
                            blue:((float)(hexValue & 0xFF))/255.0 alpha:alphaValue];
}

+ (UIColor*) colorWithHex:(NSInteger)hexValue
{
    return [UIColor colorWithHex:hexValue alpha:1.0];
}

+ (NSString *) hexFromUIColor: (UIColor*) color {
    if (CGColorGetNumberOfComponents(color.CGColor) < 4) {
        const CGFloat *components = CGColorGetComponents(color.CGColor);
        color = [UIColor colorWithRed:components[0]
                                green:components[0]
                                 blue:components[0]
                                alpha:components[1]];
    }
    
    if (CGColorSpaceGetModel(CGColorGetColorSpace(color.CGColor)) != kCGColorSpaceModelRGB) {
        return [NSString stringWithFormat:@"#FFFFFF"];
    }
    
    return [NSString stringWithFormat:@"#%x%x%x", (int)((CGColorGetComponents(color.CGColor))[0]*255.0),
            (int)((CGColorGetComponents(color.CGColor))[1]*255.0),
            (int)((CGColorGetComponents(color.CGColor))[2]*255.0)];
}

/**
 * @brief 根据控件环境返回颜色
 * @param backColor 背景色
 * @param textColor 文字颜色
 * @param blockColor 色块颜色
 * @param state 控件状态
 */
+ (UIColor *) colorWithbackColor:(ColorElement)backColor AndTextColor:(ColorElement)textColor BlockColor:(ColorElement)blockColor AndState:(ColorState)state
{
    if (backColor == ColorElementWhite) {
        //底色--白色（0xffffff）
        if (textColor == ColorElementNone && blockColor == ColorElementNone && state == ColorStateHighlighted){
            //文字或色块--空
            return [UIColor colorWithHex:ColorElementLightGray];
        }else{
            if (textColor == ColorElementDarkGray || blockColor == ColorElementDarkGray) {
                //文字或色块--灰色
                if (state == ColorStateNormal) {
                    return [UIColor colorWithHex:ColorElementDarkGray];
                }else if (state == ColorStateHighlighted){
                    return [UIColor colorWithHex:0x141414];
                }else if (state == ColorStateDisabled){
                    return [UIColor colorWithHex:ColorElementLightGray];
                }
            }else if (textColor == ColorElementYellow || blockColor == ColorElementYellow){
                //文字或色块--黄色
                if (state == ColorStateNormal) {
                    return [UIColor colorWithHex:ColorElementYellow];
                }else if (state == ColorStateHighlighted){
                    return [UIColor colorWithHex:0xc6a000];
                }else if (state == ColorStateDisabled){
                    return [UIColor colorWithHex:ColorElementDarkGray];
                }
            }else if (textColor == ColorElementBlue || blockColor == ColorElementBlue){
                //文字或色块--蓝色
                if (state == ColorStateNormal) {
                    return [UIColor colorWithHex:ColorElementBlue];
                }else if (state == ColorStateHighlighted){
                    return [UIColor colorWithHex:0x223765];
                }else if (state == ColorStateDisabled){
                    return [UIColor colorWithHex:ColorElementDarkGray];
                }
            }
        }
    }else if (backColor == ColorElementLowGray){
        //底色--灰色（0xf9f9f9）
        if (textColor == ColorElementNone && blockColor == ColorElementNone && state == ColorStateHighlighted){
            //文字或色块--空
            return [UIColor colorWithHex:ColorElementLightGray];
        }
    }else if (backColor == ColorElementYellow){
        //底色--黄色（0xffd727）
        if (textColor == ColorElementBrown || blockColor == ColorElementBrown) {
            //文字或色块--棕色
            if (state == ColorStateNormal) {
                return [UIColor colorWithHex:ColorElementBrown];
            }else if (state == ColorStateHighlighted){
                return [UIColor colorWithHex:0x1e1b1a];
            }else if (state == ColorStateDisabled){
                return [UIColor colorWithHex:ColorElementDarkGray];
            }
        }
    }else if (backColor == ColorElementBlack){
        //底色--黑色（0x1e1b1a）
        if (textColor == ColorElementWhite || blockColor == ColorElementWhite) {
            //文字或色块--白色
            if (state == ColorStateNormal) {
                return [UIColor colorWithHex:ColorElementWhite];
            }else if (state == ColorStateHighlighted){
                return [UIColor colorWithHex:0x1e1b1a];
            }else if (state == ColorStateDisabled){
                return [UIColor colorWithHex:ColorElementDarkGray];
            }
        }
    }else if (backColor == ColorElementBrown){
        //底色--棕底（0x403836）
        if (textColor == ColorElementWhite || blockColor == ColorElementWhite) {
            //文字或色块--白色
            if (state == ColorStateNormal) {
                return [UIColor colorWithHex:ColorElementWhite];
            }else if (state == ColorStateHighlighted){
                return [UIColor colorWithHex:0x1e1b1a];
            }else if (state == ColorStateDisabled){
                return [UIColor colorWithHex:ColorElementDarkGray];
            }
        }
    }
    
    //不满足任何要求返回透明色
    return [UIColor clearColor];
}


/**
 * @brief 根据控件环境返回颜色
 * @param backColor 背景色
 * @param textColor 文字颜色
 * @param state 控件状态
 */
+ (UIColor *) colorWithbackColor:(ColorElement)backColor AndTextColor:(ColorElement)textColor AndState:(ColorState)state
{
    return [[self class]colorWithbackColor:backColor AndTextColor:textColor BlockColor:ColorElementNone AndState:state];
}


/**
 * @brief 根据控件环境返回颜色
 * @param backColor 背景色
 * @param blockColor 色块颜色
 * @param state 控件状态
 */
+ (UIColor *) colorWithbackColor:(ColorElement)backColor BlockColor:(ColorElement)blockColor AndState:(ColorState)state
{
    return [[self class]colorWithbackColor:backColor AndTextColor:ColorElementNone BlockColor:blockColor AndState:state];
}

/**
 * @brief 根据控件环境返回颜色
 * @param backColor 背景色
 * @param state 控件状态
 */
+ (UIColor *) colorWithbackColor:(ColorElement)backColor AndState:(ColorState)state
{
    return [[self class]colorWithbackColor:backColor AndTextColor:ColorElementNone BlockColor:ColorElementNone AndState:state];
}

@end

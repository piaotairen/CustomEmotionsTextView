//
//  UIFont+CustomPS.m
//  jiangzhi
//
//  Created by kingly on 15/6/18.
//  Copyright (c) 2015年 kingly. All rights reserved.
//

#import "UIFont+CustomPS.h"
#import "CmdCollect.pch"

#define kIPhone5CorrectSize  (1.294f)  //iPhone5 校正参数
#define kIPhone6CorrectSize  (1.104f)  //iPhone6 校正参数
#define kIPhone6PCorrectSize (1.000f)  //iPhone6P校正参数


@implementation UIFont (CustomPS)

/**
 *  ps 转 系统 SystemFontOfSize
 */
+ (UIFont *) psToSystemFontOfSize:(CGFloat )size{
   return   [UIFont systemFontOfSize:[self psToSystemSize:size]];
}
/**
 * ps 转 ios pointSize 公式  (systemSize/72)*96*2  = pxSize
 */
+(CGFloat ) psToSystemSize :(CGFloat )size{
   
     CGFloat systemSize = (72 * size) / 192 ;
    return systemSize;
}
/**
 * ps 转 iOS字体的算法
 */
+(UIFont *)systemFontOfPx:(CGFloat )size{
    
    CGFloat systemSize = ((72.0f * size) / 192.0f)*((kScreenWidth)/(1433.0f/3.0f));
    
    //校正参数
    if (kScreenWidth == 375.f) {
        systemSize *= kIPhone6CorrectSize;
    }else if (kScreenWidth == 320.f)
    {
        systemSize *= kIPhone5CorrectSize;
    }else{
        systemSize *= kIPhone6PCorrectSize;
    }
//    return [UIFont systemFontOfSize:roundf(systemSize)];
    return [UIFont systemFontOfSize:systemSize];
}

/**
 * ps Bold 转 iOS字体的算法
 */
+(UIFont *)BoldSystemFontOfPx:(CGFloat )size{
    
    CGFloat systemSize = ((72.0f * size) / 192.0f)*((kScreenWidth)/(1433.0f/3.0f));
    
    //校正参数
    if (kScreenWidth == 375.f) {
        systemSize *= kIPhone6CorrectSize;
    }else if (kScreenWidth == 320.f)
    {
        systemSize *= kIPhone5CorrectSize;
    }else{
        systemSize *= kIPhone6PCorrectSize;
    }
    
    return [UIFont boldSystemFontOfSize:systemSize];
}


+ (UIFont *) psToBoldSystemFontOfSize:(CGFloat)fontSize{
    
   return   [UIFont boldSystemFontOfSize:[self psToSystemSize:fontSize]];
}

+ (UIFont *) psToItalicSystemFontOfSize:(CGFloat)fontSize{

    return   [UIFont italicSystemFontOfSize:[self psToSystemSize:fontSize]];
}

@end

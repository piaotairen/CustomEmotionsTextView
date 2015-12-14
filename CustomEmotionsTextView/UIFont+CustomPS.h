//
//  UIFont+CustomPS.h
//  jiangzhi
//
//  Created by kingly on 15/6/18.
//  Copyright (c) 2015年 kingly. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIFont (CustomPS)

/**
 *  ps 转 系统 SystemFontOfSize
 */
+ (UIFont *) psToSystemFontOfSize:(CGFloat)size;
+ (UIFont *) psToBoldSystemFontOfSize:(CGFloat)fontSize;
+ (UIFont *) psToItalicSystemFontOfSize:(CGFloat)fontSize;


/**
 * ps 转 iOS字体的算法
 */
+(UIFont *)systemFontOfPx:(CGFloat )size;
/**
 * ps Bold 转 iOS字体的算法
 */
+(UIFont *)BoldSystemFontOfPx:(CGFloat )size;

@end

//
//  NSString+CustomFunc.h
//  jiangzhi
//
//  Created by Cobb on 15/5/12.
//  Copyright (c) 2015年 Hu Zhiyuan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (CustomFunc)

/**
 * @brief 获取字符串（包含中英文混合的情况）的长度
 * @param strtemp 输入的字符串
 */
- (NSInteger)stringLenth;

/**
 * @brief 获取指定时间格式的字符串
 * format 输出的时间格式
 */
-(NSString *)timeformatString:(NSString *)format;

/**
 * 字符串转时间戳
 */
-(NSTimeInterval)timeIntervalWithFormat:(NSString *)format;


+(long long)longLongFromDate:(NSDate*)date;

+ (NSDate*) dateFormatBODStyle:(NSString*)dateString;

+ (NSString*) dateStringBODStyle:(NSDate*)date;


/**
 * 获得图片 占位符
 */
+(NSString *)replacePicStrWithTag:(unsigned int)tag;

/**
 * 判断给定时间是否等于系统时间
 */
-(BOOL)isEqualToCurrentDate;

/**
 * 判断给定时间是否等于系统时间(精确到年)
 */
-(BOOL)isEqualToCurrentYear;

/**
 * 十六制字符 转 NSData
 */
- (NSData *) stringToHexData;
/**
 * 提问的问题，如果文字后面没有问号，添加问号
 */
+(NSString *)appendQuestionType:(NSString *)str;

/**
 *  检查是否包含 http https
 */
+(BOOL )appendHttpType:(NSString *)str;

/**
 * url编码
 */
+ (NSString *)encodeToPercentEscapeString: (NSString *) input;
/**
 * url解码
 */
+ (NSString *)decodeFromPercentEscapeString: (NSString *) input;
/**
 * 判断字符串为空和只为空格解决办法
 */
+ (BOOL)isBlankString:(NSString *)string;
/**
 * 获取当前的年份
 */
+(int)currentYear;
/**
 * 两端去空格
 */
+(NSString *)whitespace:(NSString *)str;

-(NSString *)deleteEnterChar;
/**
 * 数字格式化单位 （千或万）
 */
+(NSString *)digitalConversion:(float)number;
/**
 * 格式话小数 四舍五入类型  例如： [NSString decimalwithFormat:@"0.0000" floatV:0.334569]
 */
+(NSString *) decimalwithFormat:(NSString *)format  floatV:(float)floatV;
/**
 * 格式  %@ 个评论 · %@次蘸
 **/
+(NSString *)strCommtent:(float )commtentNum withPraiseNumber:(float)praiseNumber;

/**
 * 判断 TextView 是否 写入文字  YES 为空  NO 写入文字
 */
+(BOOL )isNullTexView:(NSString *)text;

//+(NSString *)RandomStr:(int)tag;

/**
 * 对长文本的分割截取（获取首段）
 */
-(NSString *)longTextCut;

@end

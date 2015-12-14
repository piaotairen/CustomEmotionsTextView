//
//  NSString+CustomFunc.m
//  jiangzhi
//
//  Created by Cobb on 15/5/12.
//  Copyright (c) 2015年 Hu Zhiyuan. All rights reserved.
//

#import "NSString+CustomFunc.h"
#import <CoreFoundation/CFURL.h>
//#import "CmdCollect.pch"
//#import "MD5String.h"
//#import "DateUtil.h"

#define kReplacePictureStr @"@@jz-img@@"  //酱知feed长文中的图片占位符
#define kLeftReplacePicStr  @"「#_JZTAG_"      //酱知左侧feed长文中的图片占位符
#define kRightReplacePicStr @"_JZTAG_#」"      //酱知右侧feed长文中的图片占位符
#define BODDateFormat          @"yyyy-MM-dd"

@implementation NSString (CustomFunc)

/**
 * 获取字符串长度
 */
- (NSInteger)stringLenth
{
    NSStringEncoding enc = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
    NSData* da = [self dataUsingEncoding:enc];
    return [da length];
}

/**
 * 时间戳转获取指定格式时间的字符串
 */
-(NSString *)timeformatString:(NSString *)format
{
    NSTimeInterval timeInterVal;
    
    timeInterVal = (NSTimeInterval)([self longLongValue]);
    
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:timeInterVal];
    
    //返回指定格式的time
    NSDateFormatter *outputFormatter = [[NSDateFormatter alloc] init];
    
    [outputFormatter setDateFormat:format];
    
    NSString *newStr = [outputFormatter stringFromDate:date];
    
    return newStr;
}
/**
 * 判断给定时间是否等于系统时间(精确到 MM/dd )
 */
-(BOOL)isEqualToCurrentDate
{
    NSDate *date = [NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    
    // 当前月份
    [formatter setDateFormat:@"MM/dd"];
    NSString *currentMonthString = [formatter stringFromDate:date];
    
    if ([self isEqualToString:currentMonthString]) {
        return YES;
    }else{
        return NO;
    }
}

/**
 * 判断给定时间是否等于系统时间(精确到年)
 */
-(BOOL)isEqualToCurrentYear
{
    NSDate *date = [NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    
    // 当前年份
    [formatter setDateFormat:@"yyyy"];
    NSString *currentYearString = [formatter stringFromDate:date];
    
    if ([self isEqualToString:currentYearString]) {
        return YES;
    }else{
        return NO;
    }
}

/**
 * 字符串转时间戳
 * (将yyyy-MM-dd格式的时间字符串转为时间戳)
 */
-(NSTimeInterval)timeIntervalWithFormat:(NSString *)format
{
    NSDateFormatter *inputFormatter = [[NSDateFormatter alloc] init];
    [inputFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
    [inputFormatter setDateFormat:format];
    NSDate* inputDate = [inputFormatter dateFromString:self];
    
    NSTimeInterval myInterval = [inputDate timeIntervalSince1970];
    return myInterval;
}

+(long long)longLongFromDate:(NSDate*)date{
    return [date timeIntervalSince1970] * 1000;
}

+ (NSDate*) dateFormatBODStyle:(NSString*)dateString
{
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:BODDateFormat];
    return [formatter dateFromString:dateString];
}

+ (NSString*) dateStringBODStyle:(NSDate*)date
{
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:BODDateFormat];
    return [formatter stringFromDate:date];
}



/**
 * 十六制字符 转 NSData
 */
- (NSData *) stringToHexData
{
    NSInteger len = [self length] / 2;    // Target length
    unsigned char *buf = malloc(len);
    unsigned char *whole_byte = buf;
    char byte_chars[3] = {'\0','\0','\0'};
    
    int i;
    for (i=0; i < [self length] / 2; i++) {
        byte_chars[0] = [self characterAtIndex:i*2];
        byte_chars[1] = [self characterAtIndex:i*2+1];
        *whole_byte = strtol(byte_chars, NULL, 16);
        whole_byte++;
    }
    
    NSData *data = [NSData dataWithBytes:buf length:len];
    free( buf );
    return data;
}
/**
 * 提问的问题，如果文字后面没有问号，添加问号
 */
+(NSString *)appendQuestionType:(NSString *)str{
    
//    NSInteger lenth  = str.length;
//    NSInteger LenthFrom  = lenth - 1;
//     NSString *substring = [str substringFromIndex:LenthFrom];
//    if ([substring isEqualToString:@"?"]) {
//        return str;
//    }
//    if ([substring isEqualToString:@"？"]) {
//        return str;
//    }
    BOOL IsExist = NO;
    NSString *rangeString = @"？";
    NSString *rangeString02 = @"?";
    if ([str rangeOfString:rangeString].location != NSNotFound) {
        IsExist = YES;
    }else if ([str rangeOfString:rangeString02].location != NSNotFound) {
        IsExist = YES;
    }
    if (IsExist == YES) {
        return str;
    }
    NSString  *appentStr = [NSString stringWithFormat:@"%@？",str];
    return appentStr;
}

/**
 *  检查是否包含 http https
 */
+(BOOL )appendHttpType:(NSString *)str{

    NSString *lowerCaseString = [str lowercaseString];
    BOOL IsExist = NO;
    NSString *rangeString = @"http";
    NSString *rangeString02 = @"https";
    if ([lowerCaseString rangeOfString:rangeString].location != NSNotFound) {
        IsExist = YES;
    }else if ([lowerCaseString rangeOfString:rangeString02].location != NSNotFound) {
        IsExist = YES;
    }
    if (IsExist==YES) {
        if ([[lowerCaseString substringWithRange:NSMakeRange(0,4)] isEqualToString:rangeString] == NO) {
            IsExist = NO;
        }
        
    }
    return IsExist;
}

/**
 * url编码
 */
+ (NSString *)encodeToPercentEscapeString: (NSString *) input
{
    // Encode all the reserved characters, per RFC 3986
    // ()
    
    NSCharacterSet *charSet = [NSCharacterSet characterSetWithCharactersInString:@"!*'();:@&=+$,/?%#[]"];
    NSString *outputStr = [[NSString alloc]stringByAddingPercentEncodingWithAllowedCharacters:charSet];
    
//    NSString *outputStr = (NSString *)
//    CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
//                                            (CFStringRef)input,
//                                            NULL,
//                                            (CFStringRef)@"!*'();:@&=+$,/?%#[]",
//                                            kCFStringEncodingUTF8));
    
    return outputStr;
}
/**
 * url解码
 */
+ (NSString *)decodeFromPercentEscapeString: (NSString *) input
{
    NSMutableString *outputStr = [NSMutableString stringWithString:input];
    [outputStr replaceOccurrencesOfString:@"+"
                               withString:@" "
                                  options:NSLiteralSearch
                                    range:NSMakeRange(0, [outputStr length])];
//    return [outputStr stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    return [outputStr stringByRemovingPercentEncoding];
}
/**
 * 判断字符串为空和只为空格解决办法
 */
+ (BOOL)isBlankString:(NSString *)string
{
    if (string == nil) {
        
        return YES;
        
    }
    
    if (string == NULL) {
        
        return YES;
        
    }
    
    if ([string isKindOfClass:[NSNull class]]) {
        
        return YES;
        
    }
    
    if ([string isEqual:[NSNull null]]) {
        
        return YES;

    }
    
    if ([[string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length]==0) {
        
        return YES;
        
    }
    
    return NO;
}
/**
 * 获取当前的年份
 */
+(int)currentYear
{
    NSDate *date = [NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    
    // Get Current Year
    [formatter setDateFormat:@"yyyy"];
    
    NSString *currentYearString = [NSString stringWithFormat:@"%@",
                                   [formatter stringFromDate:date]];
    return [currentYearString intValue];
}

/**
 * 两端去空格
 */
+(NSString *)whitespace:(NSString *)str{
    
    NSString *sem = [str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];

    return sem;
}

-(NSString *)deleteEnterChar{

    NSString *sem = [self stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"\n"]];
    return sem;
}

/**
 * 数字格式化单位 （千或万）
 */
+(NSString *)digitalConversion:(float)number{

    NSString *num = [NSString stringWithFormat:@"%d",(int)number];
   
    if (1000 <= number  &&  number < 10000 ) {
        num = [NSString stringWithFormat:@"%@k",[self decimalwithFormat:@"0.0" floatV:number/1000]];
    }else if (10000 <= number  &&  number <= 1000000){
        num = [NSString stringWithFormat:@"%@w",[self decimalwithFormat:@"0.0" floatV:number/10000]];
    }else if (number >1000000){
        num = [NSString stringWithFormat:@"100w+"];
    }
    return num;
}
/**
 * 格式话小数 四舍五入类型  例如： [NSString decimalwithFormat:@"0.0000" floatV:0.334569]
 */
+(NSString *) decimalwithFormat:(NSString *)format  floatV:(float)floatV
{
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setPositiveFormat:format];
    NSString *fl   = [numberFormatter stringFromNumber:[NSNumber numberWithFloat:floatV]];
    NSArray *array = [fl componentsSeparatedByString:@"."];
    NSString *last = [array lastObject];
    if ([last isEqualToString:@"0"]) {
        return [array firstObject];
    }
    return fl;
}
/**
 * 格式  %@ 个评论 · %@次蘸
 **/
+(NSString *)strCommtent:(float )commtentNum withPraiseNumber:(float)praiseNumber{

    return [NSString stringWithFormat:NSLocalizedString(@"commtentOrPraiseText", nil),[self digitalConversion:commtentNum],[self digitalConversion:praiseNumber]];

}
/**
 * 获得图片 占位符
 */
+(NSString *)replacePicStrWithTag:(unsigned int)tag{

    NSString *replacePicStr  =  [NSString stringWithFormat:@"%@%d%@",kLeftReplacePicStr,tag,kRightReplacePicStr];
    return replacePicStr;
}

/**
 * 判断 TextView 是否 写入文字  YES 为空  NO 写入文字
 */
+(BOOL )isNullTexView:(NSString *)text{
    
    NSString *t = [text stringByReplacingOccurrencesOfString:kReplacePictureStr withString:@""];
    if ([NSString isBlankString:t]) {
        return YES;
    }
    return NO;
}


//+(int)getRandomNumber:(int)from to:(int)to
//
//{
//    return (int)(from + (arc4random() % (to - from + 1)));
//    
//}
//
//+(NSString *)RandomStr:(int)tag{
//
//    NSString *st = [NSString stringWithFormat:@"%d",[self getRandomNumber:100000 to:10000000]];
//    
//    NSString *dateStr = [NSDate stringFormateWithYYYYMMDDHHmmssSSS:[NSDate date]];
//    
//    NSString *ts = [NSString stringWithFormat:@"%d%d%@",tag,[self getRandomNumber:100000 to:10000000],dateStr];
//    
//    NSString *stMd5 = [MD5String MD5:st];
//    
//    NSString *tsMd5 = [MD5String MD5:ts];
//    
//    NSString *hb = [NSString stringWithFormat:@"%@%@",stMd5,tsMd5];
//
//    return [MD5String MD5:hb];
//}

/**
 * 对长文本的分割截取（获取首段）
 */
-(NSString *)longTextCut
{
    NSArray *separatedArr = [self componentsSeparatedByString:kReplacePictureStr];
    for (NSString *eachStr in separatedArr) {
        NSString *newStr = [NSString whitespace:eachStr];
         newStr = [newStr deleteEnterChar];
        if (![NSString isBlankString:newStr]) {
            return newStr;
        }
    }
    return nil;
}

@end

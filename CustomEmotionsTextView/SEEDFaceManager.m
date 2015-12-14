//
//  SEEDFaceManager.m
//  CustomEmotionsTextView
//
//  Created by Cobb on 15/12/8.
//  Copyright © 2015年 Cobb. All rights reserved.
//

#import "SEEDFaceManager.h"

@interface SEEDFaceManager ()

@property (strong, nonatomic) NSMutableArray *emojiFaceArrays;
@property (strong, nonatomic) NSMutableArray *seedFaceArrays;
@end

@implementation SEEDFaceManager

#pragma mark - Class Methods
/**
 * @brief 工厂方法返回实例
 */
+ (instancetype)shareInstance{
    static dispatch_once_t onceToken;
    static id shareInstance;
    dispatch_once(&onceToken, ^{
        shareInstance = [[self alloc] init];
    });
    return shareInstance;
}

/**
 * @brief 实例化方法
 */
- (instancetype)init{
    if (self = [super init]) {
        _emojiFaceArrays = [NSMutableArray array];
        NSArray *faceArray = [NSArray arrayWithContentsOfFile:[SEEDFaceManager defaultEmojiFacePath]];
        [_emojiFaceArrays addObjectsFromArray:faceArray];
        
        _seedFaceArrays = [NSMutableArray array];
        NSArray *recentArrays = [NSArray arrayWithContentsOfFile:[SEEDFaceManager defaultSeedFacePath]];
        [_seedFaceArrays addObjectsFromArray:recentArrays];
    }
    return self;
}

#pragma mark - Emoji相关表情处理方法
/**
 *  @brief 获取所有的表情图片名称
 *  @return 所有的表情图片名称
 */
+ (NSArray *)emojiFaces{
    return [[SEEDFaceManager shareInstance] emojiFaceArrays];
}
/**
 * @brief 获取emoji图片的文件路径
 */
+ (NSString *)defaultEmojiFacePath{
    return [[NSBundle mainBundle] pathForResource:@"face" ofType:@"plist"];
}
/**
 *  @brief 通过表情id获取所有的表情图片名称
 *  @return 表情图片名称
 */
+ (NSString *)faceImageNameWithFaceID:(NSUInteger)faceID{
    if (faceID == 999) {
        return @"[删除]";
    }
    for (NSDictionary *faceDict in [[SEEDFaceManager shareInstance] emojiFaceArrays]) {
        if ([faceDict[kFaceIDKey] integerValue] == faceID) {
            return faceDict[kFaceImageNameKey];
        }
    }
    return @"";
}
/**
 *  @brief  通过表情id获取所有的表情名称
 *  @return 表情名称
 */
+ (NSString *)faceNameWithFaceID:(NSUInteger)faceID{
    if (faceID == 999) {
        return @"[删除]";
    }
    for (NSDictionary *faceDict in [[SEEDFaceManager shareInstance] emojiFaceArrays]) {
        if ([faceDict[kFaceIDKey] integerValue] == faceID) {
            return faceDict[kFaceNameKey];
        }
    }
    return @"";
}
/**
 *  @brief 将文字中带表情的字符处理换成图片显示
 *  @param text 未处理的文字
 *  @return 处理后的文字
 */
+ (NSMutableAttributedString *)emotionStrWithString:(NSString *)text
{
    //1、创建一个可变的属性字符串
    NSMutableAttributedString *attributeString = [[NSMutableAttributedString alloc] initWithString:text];
    //2、通过正则表达式来匹配字符串
    NSString *regex_emoji = @"\\[[a-zA-Z0-9\\/\\u4e00-\\u9fa5]+\\]"; //匹配表情
    
    NSError *error = nil;
    NSRegularExpression *re = [NSRegularExpression regularExpressionWithPattern:regex_emoji options:NSRegularExpressionCaseInsensitive error:&error];
    if (!re) {
        NSLog(@"%@", [error localizedDescription]);
        return attributeString;
    }
    
    NSArray *resultArray = [re matchesInString:text options:0 range:NSMakeRange(0, text.length)];
    //3、获取所有的表情以及位置
    //用来存放字典，字典中存储的是图片和图片对应的位置
    NSMutableArray *imageArray = [NSMutableArray arrayWithCapacity:resultArray.count];
    //根据匹配范围来用图片进行相应的替换
    for(NSTextCheckingResult *match in resultArray) {
        //获取数组元素中得到range
        NSRange range = [match range];
        //获取原字符串中对应的值
        NSString *subStr = [text substringWithRange:range];
        
        for (NSDictionary *dict in [[SEEDFaceManager shareInstance] emojiFaceArrays]) {
            if ([dict[kFaceNameKey]  isEqualToString:subStr]) {
                //face[i][@"png"]就是我们要加载的图片
                //新建文字附件来存放我们的图片,iOS7才新加的对象
                NSTextAttachment *textAttachment = [[NSTextAttachment alloc] init];
                //给附件添加图片
                textAttachment.image = [UIImage imageNamed:dict[kFaceImageNameKey]];
                //调整一下图片的位置,如果你的图片偏上或者偏下，调整一下bounds的y值即可
                textAttachment.bounds = CGRectMake(0, -8, textAttachment.image.size.width, textAttachment.image.size.height);
                //把附件转换成可变字符串，用于替换掉源字符串中的表情文字
                NSAttributedString *imageStr = [NSAttributedString attributedStringWithAttachment:textAttachment];
                //把图片和图片对应的位置存入字典中
                NSMutableDictionary *imageDic = [NSMutableDictionary dictionaryWithCapacity:2];
                [imageDic setObject:imageStr forKey:@"image"];
                [imageDic setObject:[NSValue valueWithRange:range] forKey:@"range"];
                //把字典存入数组中
                [imageArray addObject:imageDic];
            }
        }
    }
    
    //4、从后往前替换，否则会引起位置问题
    for (int i = (int)imageArray.count -1; i >= 0; i--) {
        NSRange range;
        [imageArray[i][@"range"] getValue:&range];
        //进行替换
        [attributeString replaceCharactersInRange:range withAttributedString:imageArray[i][@"image"]];
    }
    return attributeString;
}

#pragma mark - 最近使用表情相关方法
/**
 *  @brief 获取所有的种子图片名称
 *  @return 所有的种子图片名称
 */
+ (NSArray *)seedFaces
{
    return [[SEEDFaceManager shareInstance] seedFaceArrays];
}
/**
 * @brief 获取seed图片的文件路径
 */
+ (NSString *)defaultSeedFacePath{
    return [[NSBundle mainBundle] pathForResource:@"seed" ofType:@"plist"];
}
/**
 *  @brief 通过种子id获取所有的表情图片名称
 *  @return 种子图片名称
 */
+ (NSString *)seedImageNameWithSeedID:(NSUInteger)faceID
{
    for (NSDictionary *faceDict in [[SEEDFaceManager shareInstance] seedFaceArrays]) {
        if ([faceDict[kFaceIDKey] integerValue] == faceID) {
            return faceDict[kFaceImageNameKey];
        }
    }
    return @"";
}
/**
 *  @brief  通过种子id获取所有的表情名称
 *  @return 种子名称
 */
+ (NSString *)seedNameWithSeedID:(NSUInteger)faceID
{
    for (NSDictionary *faceDict in [[SEEDFaceManager shareInstance] seedFaceArrays]) {
        if ([faceDict[kFaceIDKey] integerValue] == faceID) {
            return faceDict[kFaceNameKey];
        }
    }
    return @"";
}
/**
 *  @brief 将文字中带表情的字符处理换成种子显示
 *  @param text 未处理的文字
 *  @return 处理后的文字
 */
+ (NSMutableAttributedString *)seedStrWithString:(NSString *)text
{
    //1、创建一个可变的属性字符串
    NSMutableAttributedString *attributeString = [[NSMutableAttributedString alloc] initWithString:text];
    //2、通过正则表达式来匹配字符串
    NSString *regex_emoji = @"\\[[a-zA-Z0-9\\/\\u4e00-\\u9fa5]+\\]"; //匹配表情
    
    NSError *error = nil;
    NSRegularExpression *re = [NSRegularExpression regularExpressionWithPattern:regex_emoji options:NSRegularExpressionCaseInsensitive error:&error];
    if (!re) {
        NSLog(@"%@", [error localizedDescription]);
        return attributeString;
    }
    
    NSArray *resultArray = [re matchesInString:text options:0 range:NSMakeRange(0, text.length)];
    //3、获取所有的表情以及位置
    //用来存放字典，字典中存储的是图片和图片对应的位置
    NSMutableArray *imageArray = [NSMutableArray arrayWithCapacity:resultArray.count];
    //根据匹配范围来用图片进行相应的替换
    for(NSTextCheckingResult *match in resultArray) {
        //获取数组元素中得到range
        NSRange range = [match range];
        //获取原字符串中对应的值
        NSString *subStr = [text substringWithRange:range];
        
        for (NSDictionary *dict in [[SEEDFaceManager shareInstance] emojiFaceArrays]) {
            if ([dict[kFaceNameKey]  isEqualToString:subStr]) {
                //face[i][@"png"]就是我们要加载的图片
                //新建文字附件来存放我们的图片,iOS7才新加的对象
                NSTextAttachment *textAttachment = [[NSTextAttachment alloc] init];
                //给附件添加图片
                textAttachment.image = [UIImage imageNamed:dict[kFaceImageNameKey]];
                //调整一下图片的位置,如果你的图片偏上或者偏下，调整一下bounds的y值即可
                textAttachment.bounds = CGRectMake(0, -8, textAttachment.image.size.width, textAttachment.image.size.height);
                //把附件转换成可变字符串，用于替换掉源字符串中的表情文字
                NSAttributedString *imageStr = [NSAttributedString attributedStringWithAttachment:textAttachment];
                //把图片和图片对应的位置存入字典中
                NSMutableDictionary *imageDic = [NSMutableDictionary dictionaryWithCapacity:2];
                [imageDic setObject:imageStr forKey:@"image"];
                [imageDic setObject:[NSValue valueWithRange:range] forKey:@"range"];
                //把字典存入数组中
                [imageArray addObject:imageDic];
            }
        }
    }
    
    //4、从后往前替换，否则会引起位置问题
    for (int i = (int)imageArray.count -1; i >= 0; i--) {
        NSRange range;
        [imageArray[i][@"range"] getValue:&range];
        //进行替换
        [attributeString replaceCharactersInRange:range withAttributedString:imageArray[i][@"image"]];
    }
    return attributeString;
    
}

@end

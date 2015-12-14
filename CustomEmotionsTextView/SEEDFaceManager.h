//
//  SEEDFaceManager.h
//  CustomEmotionsTextView
//
//  Created by Cobb on 15/12/8.
//  Copyright © 2015年 Cobb. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

#define kFaceIDKey          @"face_id"
#define kFaceNameKey        @"face_name"
#define kFaceImageNameKey   @"face_image_name"

#define kFaceRankKey        @"face_rank"
#define kFaceClickKey       @"face_click"

/**
 *  表情管理类,可以获取所有的表情名称
 *  TODO 直接获取所有的表情Dict,添加排序功能,对表情进行排序,常用表情排在前面
 */
@interface SEEDFaceManager : NSObject

/**
 * @brief 工厂方法返回实例
 */
+ (instancetype)shareInstance;
/**
 * ————————————————————————————————————
 *  @brief 获取所有的表情图片名称
 *  @return 所有的表情图片名称
 */
+ (NSArray *)emojiFaces;
/**
 *  @brief 通过表情id获取所有的表情图片名称
 *  @return 表情图片名称
 */
+ (NSString *)faceImageNameWithFaceID:(NSUInteger)faceID;
/**
 *  @brief  通过表情id获取所有的表情名称
 *  @return 表情名称
 */
+ (NSString *)faceNameWithFaceID:(NSUInteger)faceID;
/**
 *  @brief 将文字中带表情的字符处理换成图片显示
 *  @param text 未处理的文字
 *  @return 处理后的文字
 */
+ (NSMutableAttributedString *)emotionStrWithString:(NSString *)text;
/**
 * ————————————————————————————————————
 *  @brief 获取所有的种子图片名称
 *  @return 所有的种子图片名称
 */
+ (NSArray *)seedFaces;
/**
 *  @brief 通过种子id获取所有的表情图片名称
 *  @return 种子图片名称
 */
+ (NSString *)seedImageNameWithSeedID:(NSUInteger)faceID;
/**
 *  @brief  通过种子id获取所有的表情名称
 *  @return 种子名称
 */
+ (NSString *)seedNameWithSeedID:(NSUInteger)faceID;
/**
 *  @brief 将文字中带表情的字符处理换成种子显示
 *  @param text 未处理的文字
 *  @return 处理后的文字
 */
+ (NSMutableAttributedString *)seedStrWithString:(NSString *)text;

@end

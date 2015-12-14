//
//  SEEDChatBar.h
//  CustomEmotionsTextView
//
//  Created by Cobb on 15/12/8.
//  Copyright © 2015年 Cobb. All rights reserved.
//

#define kMaxHeight 100.0f
#define kMinHeight 45.0f
#define kFunctionViewHeight 210.0f

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

/**
 * 输入框的定制样式
 */
typedef NS_ENUM(NSUInteger, SEEDChartBarType) {
    SEEDChartBarTypeRecord,  //输入框记录样式
    SEEDChartBarTypeComment, //输入框评论样式
    SEEDChartBarTypeFriends  //输入框聊天样式
};

/**
 *  functionView 类型
 */
typedef NS_ENUM(NSUInteger, SEEDFunctionViewShowType){
    SEEDFunctionViewShowNothing /**< 不显示functionView */,
    SEEDFunctionViewShowFace /**< 显示表情View */,
    SEEDFunctionViewShowVoice /**< 显示录音view */,
    SEEDFunctionViewShowMore /**< 显示更多view */,
    SEEDFunctionViewShowKeyboard /**< 显示键盘 */,
    SEEDFunctionViewSendComment /**< 点击发送输入文本 */,
    SEEDFunctionViewSinaShare /**< 点击新浪分享 */,
    SEEDFunctionViewRespondKeyboard /**< 调用其他输入控件显示键盘（SEEDChartBarTypeRecord样式下使用） */
};

@protocol SEEDChatBarDelegate;

/**
 * @class 仿微信信息输入框,支持语音,文字,表情,选择照片,拍照
 */
@interface SEEDChatBar : UIView

/**
 * @brief 类方法，根据输入框类型返回实例
 * @param type 输入框类型
 * @param frame 输入框坐标
 */
+(instancetype)chatBarWithType:(SEEDChartBarType)type Withframe:(CGRect)frame;

@property (weak, nonatomic) id<SEEDChatBarDelegate> delegate;

/**
 *  @brief 结束输入状态
 */
- (void)endInputing;

@end

/**
 *  SEEDChatBar协议,发送图片,地理位置,文字,语音信息等
 */
@protocol SEEDChatBarDelegate <NSObject>


@optional

/**
 *  @brief chatBarFrame改变回调
 *  @param chatBar
 */
- (void)chatBarFrameDidChange:(SEEDChatBar *)chatBar frame:(CGRect)frame;


/**
 *  @brief 发送图片信息,支持多张图片
 *  @param chatBar
 *  @param pictures 需要发送的图片信息
 */
- (void)chatBar:(SEEDChatBar *)chatBar sendPictures:(NSArray *)pictures;

/**
 *  @brief 发送地理位置信息
 *  @param chatBar
 *  @param locationCoordinate 需要发送的地址位置经纬度
 *  @param locationText       需要发送的地址位置对应信息
 */
- (void)chatBar:(SEEDChatBar *)chatBar sendLocation:(CLLocationCoordinate2D)locationCoordinate locationText:(NSString *)locationText;

/**
 *  @brief 发送普通的文字信息,可能带有表情
 *  @param chatBar
 *  @param message 需要发送的文字信息
 */
- (void)chatBar:(SEEDChatBar *)chatBar sendMessage:(NSString *)message;

/**
 *  @brief 发送语音信息
 *  @param chatBar
 *  @param voiceData 语音data数据
 *  @param seconds   语音时长
 */
- (void)chatBar:(SEEDChatBar *)chatBar sendVoice:(NSData *)voiceData seconds:(NSTimeInterval)seconds;

@end
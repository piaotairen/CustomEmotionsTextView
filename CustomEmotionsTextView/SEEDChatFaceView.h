//
//  SEEDChatFaceView.h
//  CustomEmotionsTextView
//
//  Created by Cobb on 15/12/8.
//  Copyright © 2015年 Cobb. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 * enum 视图的样式
 */
typedef NS_ENUM(NSUInteger, SEEDFaceViewStyle) {
    SEEDFaceViewStyleNormal,  //普通视图样式，仅包含普通表情包
    SEEDFaceViewStyleDiverse  //多样视图样式，包含种子表情包大图
};

/**
 * enum 展示的表情类型
 */
typedef NS_ENUM(NSUInteger, SEEDShowFaceViewType) {
    SEEDShowNormalEmojiFace = 0,//展示普通的表情
    SEEDShowSeedEmojiFace   = 1,//展示种子的表情
};

/**
 * @protocol 表情视图的协议
 */
@protocol SEEDChatFaceViewDelegate <NSObject>
/**
 * @brief 发送一个表情
 * @param faceName 表情名
 */
- (void)faceViewSendFace:(NSString *)faceName;

@end

@interface SEEDChatFaceView : UIView

@property (weak, nonatomic) id<SEEDChatFaceViewDelegate> delegate;//协议成员
@property (assign, nonatomic) SEEDShowFaceViewType faceViewType;  //表情视图类型
/**
 * @brief 类方法 根据表情视图的类型返回实例
 */
+(instancetype)faceViewWithFrame:(CGRect)frame Style:(SEEDFaceViewStyle)syle;

@end

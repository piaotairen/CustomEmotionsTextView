//
//  SEEDChatMoreView.h
//  CustomEmotionsTextView
//
//  Created by Cobb on 15/12/8.
//  Copyright © 2015年 Cobb. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 * enum moreItem类型
 */
typedef NS_ENUM(NSUInteger, SEEDChatMoreItemType){
    SEEDChatMoreItemAlbum = 0 /**< 显示相册 */,
    SEEDChatMoreItemCamera /**< 显示相机 */,
    SEEDChatMoreItemLocation /**< 显示地理位置 */
};

@protocol SEEDChatMoreViewDataSource;
@protocol SEEDChatMoreViewDelegate;
/**
 * @class 更多view
 */
@interface SEEDChatMoreView : UIView

@property (weak, nonatomic) id<SEEDChatMoreViewDelegate> delegate;
@property (weak, nonatomic) id<SEEDChatMoreViewDataSource> dataSource;

@property (assign, nonatomic) NSUInteger numberPerLine;//每行个数
@property (assign, nonatomic) UIEdgeInsets edgeInsets; //间隙

- (void)reloadData;

@end

/**
 * @protocol 更多视图的事件协议
 */
@protocol SEEDChatMoreViewDelegate <NSObject>
@optional
/**
 *  @brief moreView选中的index
 *  @param moreView 对应的moreView
 *  @param index    选中的index
 */
- (void)moreView:(SEEDChatMoreView *)moreView selectIndex:(SEEDChatMoreItemType)itemType;

@end

/**
 * @protocol 更多视图的数据源协议
 */
@protocol SEEDChatMoreViewDataSource <NSObject>
@required
/**
 *  @brief 获取数组中一共有多少个titles
 *  @param moreView
 *  @param titles
 *  @return 返回标题数组
 */

- (NSArray *)titlesOfMoreView:(SEEDChatMoreView *)moreView;

/**
 *  @brief 获取moreView展示的所有图片
 *  @param moreView
 *  @param imageNames
 *  @return 返回图片数组
 */
- (NSArray *)imageNamesOfMoreView:(SEEDChatMoreView *)moreView;

@end
//
//  SEEDChatMoreCell.h
//  CustomEmotionsTextView
//
//  Created by Cobb on 15/12/8.
//  Copyright © 2015年 Cobb. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 *  @class 更多列表展示cell
 */
@interface SEEDChatMoreItem : UIControl
/**
 * @brief 设置item的标题和图片
 */
- (void)fillViewWithTitle:(NSString *)title imageName:(NSString *)imageName;

@end

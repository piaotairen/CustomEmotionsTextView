//
//  SEEDChatMoreCell.m
//  CustomEmotionsTextView
//
//  Created by Cobb on 15/12/8.
//  Copyright © 2015年 Cobb. All rights reserved.
//

#import "SEEDChatMoreItem.h"
#import "Masonry.h"

@interface SEEDChatMoreItem   ()

@property (strong, nonatomic) UIButton *button; //按钮
@property (strong, nonatomic) UILabel *titleLabel;//文本

@end

@implementation SEEDChatMoreItem

#pragma mark - Life Cycle
- (instancetype)initWithFrame:(CGRect)frame{
    if ([super initWithFrame:frame]) {
        [self setup];
    }
    return self;
}

- (void)awakeFromNib{
    [self setup];
}

/**
 * @brief 约束
 */
- (void)updateConstraints{
    [super updateConstraints];
    
    [self.button mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_top).with.offset(4);
        make.centerX.equalTo(self.mas_centerX);
        make.width.equalTo(@50);
        make.height.equalTo(@50);
    }];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.button.mas_bottom).with.offset(3);
        make.centerX.equalTo(self.mas_centerX);
    }];
}

#pragma mark - Public Methods
/**
 * @brief 设置标题和图片
 */
- (void)fillViewWithTitle:(NSString *)title imageName:(NSString *)imageName{
    self.titleLabel.text = title;
    [self.button setBackgroundImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
    [self updateConstraintsIfNeeded];
}

#pragma mark - Private Methods
/**
 * @brief 实例化子视图
 */
- (void)setup{
    
    [self addSubview:self.button];
    [self addSubview:self.titleLabel];
    
    [self updateConstraintsIfNeeded];
    
}
/**
 * @brief 按钮点击
 */
- (void)buttonAction{
    [self sendActionsForControlEvents:UIControlEventTouchUpInside];
}
/**
 * @brief 按钮点击高亮
 */
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [super touchesBegan:touches withEvent:event];
    [self.button setHighlighted:YES];
}
/**
 * @brief 按钮取消高亮
 */
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    [super touchesEnded:touches withEvent:event];
    [self.button setHighlighted:NO];
}

#pragma mark - Getters
/**
 * @brief 获取按钮
 */
- (UIButton *)button{
    if (!_button) {
        _button = [UIButton buttonWithType:UIButtonTypeCustom];
        [_button addTarget:self action:@selector(buttonAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _button;
}

/**
 * @brief 获取文本
 */
- (UILabel *)titleLabel{
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = [UIFont systemFontOfSize:13.0f];
        _titleLabel.textColor = [UIColor darkTextColor];
    }
    return _titleLabel;
}
@end

//
//  SEEDChatBar.m
//  CustomEmotionsTextView
//
//  Created by Cobb on 15/12/8.
//  Copyright © 2015年 Cobb. All rights reserved.
//

#import "SEEDChatBar.h"
#import "SEEDChatFaceView.h"
#import "SEEDChatMoreView.h"
#import <Foundation/NSObjCRuntime.h>
#import "TKTextStorage.h"
#import "TKPicTextAttachment.h"
#import "Masonry.h"

@interface SEEDChatBar ()<UITextViewDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate,SEEDChatFaceViewDelegate,SEEDChatMoreViewDelegate,SEEDChatMoreViewDataSource>

@property (strong, nonatomic) UIButton *voiceButton; /**< 切换录音模式按钮 */
@property (strong, nonatomic) UIButton *voiceRecordButton; /**< 录音按钮 */
@property (strong, nonatomic) UIButton *faceButton; /**< 表情按钮 */
@property (strong, nonatomic) UIButton *moreButton; /**< 更多按钮 */
@property (strong, nonatomic) UIButton *sendButton; /**< 发送按钮  当inputType为SEEDChartBarTypeComment时加载*/
@property (strong, nonatomic) UIButton *sinaButton; /**< 新浪按钮 */
@property (strong, nonatomic) UILabel  *sinaLabel;  /**< 同步到按钮 */

@property (strong, nonatomic) SEEDChatFaceView *faceView; /**< 当前活跃的底部view,用来指向faceView */
@property (strong, nonatomic) SEEDChatMoreView *moreView; /**< 当前活跃的底部view,用来指向moreView */
@property (assign, nonatomic) SEEDChartBarType inputType;//当前输入框类型

@property (strong, nonatomic) UITextView *textView; //文本输入框，当inputType为SEEDChartBarTypeRecord时为nil
@property (strong, nonatomic) TKTextStorage *textStorage;//富文本内容

@property (assign, nonatomic, readonly) CGFloat screenHeight;//屏幕高度
@property (assign, nonatomic, readonly) CGFloat bottomHeight;//底部视图高度
@property (assign, nonatomic) CGRect keyboardFrame;//键盘的位置

@property (strong, nonatomic, readonly) UIViewController *rootViewController;//根视图

@end

@implementation SEEDChatBar

#pragma mark - Life Cycle
/**
 * @brief 类方法，根据输入框类型返回实例
 * @param type 输入框类型
 * @param frame 输入框坐标
 */
+(instancetype)chatBarWithType:(SEEDChartBarType)type Withframe:(CGRect)frame
{
    return [[self alloc]initWithFrame:frame type:type];
}
/**
 * @brief 实例化方法
 */
- (instancetype)initWithFrame:(CGRect)frame type:(SEEDChartBarType)type{
    if ([super initWithFrame:frame]) {
        self.inputType = type;
        [self setupWithType:type];
    }
    return self;
}
/**
 * @brief 根据输入框类型进行约束
 */
- (void)updateConstraints{
    [super updateConstraints];
    
    switch (self.inputType) {
        case SEEDChartBarTypeComment:
        {
            [self.sendButton mas_makeConstraints:^(MASConstraintMaker *make) {
                make.right.equalTo(self.mas_right).with.offset(-10);
                make.top.equalTo(self.mas_top).with.offset(4);
                make.width.equalTo(self.sendButton.mas_height);
            }];
            
            [self.faceButton mas_makeConstraints:^(MASConstraintMaker *make) {
                make.right.equalTo(self.sendButton.mas_left).with.offset(-10);
                make.top.equalTo(self.mas_top).with.offset(10);
                make.width.equalTo(self.faceButton.mas_height);
            }];
            
            [self.textView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(self.mas_left).with.offset(10);
                make.right.equalTo(self.faceButton.mas_left).with.offset(-10);
                make.top.equalTo(self.mas_top).with.offset(4);
                make.bottom.equalTo(self.mas_bottom).with.offset(-4);
            }];
        }
            break;
        case SEEDChartBarTypeRecord:
        {
            [self.sinaLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(self.mas_left).with.offset(10);
                make.top.equalTo(self.mas_top).with.offset(-2);
                make.width.equalTo(self.sinaLabel.mas_height);
            }];
            [self.sinaButton mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(self.sinaLabel.mas_right).with.offset(10);
                make.top.equalTo(self.mas_top).with.offset(10);
                make.width.equalTo(self.sinaButton.mas_height);
            }];
            [self.faceButton mas_makeConstraints:^(MASConstraintMaker *make) {
                make.right.equalTo(self.mas_right).with.offset(-10);
                make.top.equalTo(self.mas_top).with.offset(10);
                make.width.equalTo(self.faceButton.mas_height);
            }];
        }
            break;
        case SEEDChartBarTypeFriends:
        {
            [self.voiceButton mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(self.mas_left).with.offset(10);
                make.top.equalTo(self.mas_top).with.offset(8);
                make.width.equalTo(self.voiceButton.mas_height);
            }];
            
            [self.moreButton mas_makeConstraints:^(MASConstraintMaker *make) {
                make.right.equalTo(self.mas_right).with.offset(-10);
                make.top.equalTo(self.mas_top).with.offset(8);
                make.width.equalTo(self.moreButton.mas_height);
            }];
            
            [self.faceButton mas_makeConstraints:^(MASConstraintMaker *make) {
                make.right.equalTo(self.moreButton.mas_left).with.offset(-10);
                make.top.equalTo(self.mas_top).with.offset(8);
                make.width.equalTo(self.faceButton.mas_height);
            }];
            
            [self.textView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(self.voiceButton.mas_right).with.offset(10);
                make.right.equalTo(self.faceButton.mas_left).with.offset(-10);
                make.top.equalTo(self.mas_top).with.offset(4);
                make.bottom.equalTo(self.mas_bottom).with.offset(-4);
            }];
        }
            break;
    }
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillChangeFrameNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

#pragma mark - UITextViewDelegate
/**
 * @brief 输入内容变更
 */
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    
    if ([text isEqualToString:@"\n"]) {
        [self sendTextMessage:textView.text];
        return NO;
    }else if (text.length == 0){
        //判断删除的文字是否符合表情文字规则
        NSString *deleteText = [textView.text substringWithRange:range];
        if ([deleteText isEqualToString:@"]"]) {
            NSUInteger location = range.location;
            NSUInteger length = range.length;
            NSString *subText;
            while (YES) {
                if (location == 0) {
                    return YES;
                }
                location -- ;
                length ++ ;
                subText = [textView.text substringWithRange:NSMakeRange(location, length)];
                if (([subText hasPrefix:@"["] && [subText hasSuffix:@"]"])) {
                    break;
                }
            }
            textView.text = [textView.text stringByReplacingCharactersInRange:NSMakeRange(location, length) withString:@""];
            [textView setSelectedRange:NSMakeRange(location, 0)];
            [self textViewDidChange:self.textView];
            return NO;
        }
    }
    return YES;
}
/**
 * @brief 开始输入设置按钮视图状态
 */
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView{
    self.faceButton.selected = self.moreButton.selected = NO;
    [self showFaceView:NO];
    return YES;
}
/**
 * @brief 输入时设置textView滑动位置
 */
- (void)textViewDidChange:(UITextView *)textView{
   [self textViewScrollToVisiable];
}

#pragma mark - UIImagePickerControllerDelegate
/**
 * @brief 选择图片
 */
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    [self sendImageMessage:image];
    [self.rootViewController dismissViewControllerAnimated:YES completion:nil];
}
/**
 * @brief 取消选择图片
 */
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [self.rootViewController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - SEEDLocationControllerDelegate
/**
 * @brief 发送位置
 */
- (void)sendLocation:(CLPlacemark *)placemark{
    [self cancelLocation];
    if (self.delegate && [self.delegate respondsToSelector:@selector(chatBar:sendLocation:locationText:)]) {
        [self.delegate chatBar:self sendLocation:placemark.location.coordinate locationText:placemark.name];
    }
}
/**
 * @brief 取消定位
 */
- (void)cancelLocation{
    [self.rootViewController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - MP3RecordedDelegate
/**
 * @brief 发送录音数据
 */
- (void)endConvertWithData:(NSData *)voiceData{
    if (voiceData) {
        NSLog(@" [SEEDProgressHUD dismissWithProgressState:SEEDProgressSuccess];");
#warning 此处计算时长 [SEEDProgressHUD seconds]
        //        [self sendVoiceMessage:voiceData seconds:[SEEDProgressHUD seconds]];
    }else{
        NSLog(@"[SEEDProgressHUD dismissWithProgressState:SEEDProgressError];");
    }
}
/**
 * @brief 录音失败
 */
- (void)failRecord{
    NSLog(@"[SEEDProgressHUD dismissWithProgressState:SEEDProgressError];");
}
/**
 * @brief 开始转换
 */
- (void)beginConvert{
    NSLog(@"[SEEDProgressHUD changeSubTitle:正在转换..");
}

#pragma mark - SEEDChatMoreViewDelegate & SEEDChatMoreViewDataSource
/**
 * @brief 更多视图显示类型
 */
- (void)moreView:(SEEDChatMoreView *)moreView selectIndex:(SEEDChatMoreItemType)itemType{
    switch (itemType) {
        case SEEDChatMoreItemAlbum:
        {
            //显示相册
            UIImagePickerController *pickerC = [[UIImagePickerController alloc] init];
            pickerC.delegate = self;
            [self.rootViewController presentViewController:pickerC animated:YES completion:nil];
        }
            break;
        case SEEDChatMoreItemCamera:
        {
            //显示拍照
            if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"您的设备不支持拍照" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
                [alertView show];
                break;
            }
            UIImagePickerController *pickerC = [[UIImagePickerController alloc] init];
            pickerC.sourceType = UIImagePickerControllerSourceTypeCamera;
            pickerC.delegate = self;
            [self.rootViewController presentViewController:pickerC animated:YES completion:nil];
        }
            break;
        case SEEDChatMoreItemLocation:
        {
            //显示位置
        }
            break;
        default:
            break;
    }
    
}
/**
 * @brief 更多视图显示的标题
 */
- (NSArray *)titlesOfMoreView:(SEEDChatMoreView *)moreView{
    return @[@"相册",@"相机"];
}
/**
 * @brief 更多视图显示的图片
 */
- (NSArray *)imageNamesOfMoreView:(SEEDChatMoreView *)moreView{
    return @[@"chat_bar_icons_pic",@"chat_bar_icons_camera"];
}

#pragma mark - SEEDChatFaceViewDelegate
/**
 * @brief 发送表情名
 * 根据表情名，进行删除，发送图片和富文本编辑操作
 */
- (void)faceViewSendFace:(NSString *)faceName{
    if ([faceName isEqualToString:@"[删除]"]) {
        [_textStorage removeCharacterWithTextView:_textView];
        [self textViewScrollToVisiable];
    }else if ([faceName isEqualToString:@"发送"]){
        NSString *text = self.textView.text;
        if (!text || text.length == 0) {
            return;
        }
        if (self.delegate && [self.delegate respondsToSelector:@selector(chatBar:sendMessage:)]) {
            [self.delegate chatBar:self sendMessage:text];
        }
        self.textView.text = @"";
        [self setFrame:CGRectMake(0, self.screenHeight - self.bottomHeight - kMinHeight, self.frame.size.width, kMinHeight) animated:NO];
        [self showViewWithType:SEEDFunctionViewShowFace];
    }else if ([faceName containsString:@"贴纸:"]){
        if (self.delegate && [self.delegate respondsToSelector:@selector(chatBar:sendPictures:)]) {
            UIImage *seedPicture = [UIImage imageNamed:faceName];
            [self.delegate chatBar:self sendPictures:@[seedPicture]];
        }
    }else{
        [self insertPicture:faceName];
    }
}

#pragma mark - Public Methods
/**
 * @brief 结束输入
 */
- (void)endInputing{
    [self showViewWithType:SEEDFunctionViewShowNothing];
}

#pragma mark - Private Methods
/**
 * @brief 键盘隐藏
 */
- (void)keyboardWillHide:(NSNotification *)notification{
    self.keyboardFrame = CGRectZero;
    [self textViewDidChange:self.textView];
}
/**
 * @brief 键盘位置改变
 */
- (void)keyboardFrameWillChange:(NSNotification *)notification{
    self.keyboardFrame = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    [self textViewDidChange:self.textView];
}

/**
 * @brief 进行视图初始化设置
 */
- (void)setupWithType:(SEEDChartBarType)type {
    switch (type) {
        case SEEDChartBarTypeComment:
        {
            [self addSubview:self.sendButton];
            [self addSubview:self.faceButton];
            [self addSubview:self.textView];
        }
            break;
        case SEEDChartBarTypeRecord:
        {
            [self addSubview:self.sinaLabel];
            [self addSubview:self.sinaButton];
            [self addSubview:self.faceButton];
        }
            break;
        case SEEDChartBarTypeFriends:
        {
            [self addSubview:self.voiceButton];
            [self addSubview:self.moreButton];
            [self addSubview:self.faceButton];
            [self addSubview:self.textView];
            [self.textView addSubview:self.voiceRecordButton];
        }
            break;
    }
    
    //顶部线条
    UIImageView *topLine = [[UIImageView alloc] init];
    topLine.backgroundColor = [UIColor colorWithRed:184/255.0f green:184/255.0f blue:184/255.0f alpha:1.0f];
    [self addSubview:topLine];
    
    [topLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.mas_left);
        make.right.equalTo(self.mas_right);
        make.top.equalTo(self.mas_top);
        make.height.mas_equalTo(@.5f);
    }];
    
    self.backgroundColor = [UIColor colorWithRed:235/255.0f green:236/255.0f blue:238/255.0f alpha:1.0f];
    [self updateConstraintsIfNeeded];
    
    //FIX 修复首次初始化页面 页面显示不正确 textView不显示bug
    [self layoutIfNeeded];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardFrameWillChange:) name:UIKeyboardWillChangeFrameNotification object:nil];
}


/**
 *  @brief 开始录音
 */
- (void)startRecordVoice{
    NSLog(@"开始录音 [SEEDProgressHUD show]");
}

/**
 *  @brief 取消录音
 */
- (void)cancelRecordVoice{
    NSLog(@"[SEEDProgressHUD dismissWithMessage:取消录];");
}

/**
 *  @brief 录音结束
 */
- (void)confirmRecordVoice{
    NSLog(@"[self.MP3 stopRecord]; 结束录音");
}

/**
 *  @brief 更新录音显示状态,手指向上滑动后提示松开取消录音
 */
- (void)updateCancelRecordVoice{
    NSLog(@"SEEDProgressHUD 松开取消录音");
}

/**
 *  @brief 更新录音状态,手指重新滑动到范围内,提示向上取消录音
 */
- (void)updateContinueRecordVoice{
    NSLog(@"SEEDProgressHUD 向上滑动取消录音");
}


/**
 * @brief 根据点击的按钮类型显示不同的底部视图
 */
- (void)showViewWithType:(SEEDFunctionViewShowType)showType{
    //显示对应的View
    [self showMoreView:showType == SEEDFunctionViewShowMore && self.moreButton.selected];
    [self showVoiceView:showType == SEEDFunctionViewShowVoice && self.voiceButton.selected];
    [self showFaceView:(showType == SEEDFunctionViewShowFace||showType == SEEDFunctionViewSinaShare) && self.faceButton.selected];
    
    switch (showType) {
        case SEEDFunctionViewShowNothing:
        case SEEDFunctionViewShowVoice:
        {
            self.textView.text = @"";
            [self setFrame:CGRectMake(0, self.screenHeight - kMinHeight, self.frame.size.width, kMinHeight) animated:NO];
            [self.textView resignFirstResponder];
            break;
        }
        case SEEDFunctionViewShowMore:
        case SEEDFunctionViewShowFace:
        {
            [self setFrame:CGRectMake(0, self.screenHeight - kFunctionViewHeight - self.textView.frame.size.height - 10, self.frame.size.width, self.textView.frame.size.height + 10) animated:NO];
            [self.textView resignFirstResponder];
            [self textViewDidChange:self.textView];
            break;
        }
        case SEEDFunctionViewShowKeyboard:
        {
            if (self){
                [self textViewDidChange:self.textView];
            }
            break;
        }
        case SEEDFunctionViewSendComment:
        {
            NSLog(@"发送文本");
            break;
        }
        case  SEEDFunctionViewSinaShare:
        {
            if (self.sinaButton.selected) {
                NSLog(@"同步到新浪微博");
            }else{
                NSLog(@"取消同步到新浪微博");
            }
            break;
        }
        case SEEDFunctionViewRespondKeyboard:
        {
            NSLog(@"调用其他输入控件显示键盘（SEEDChartBarTypeRecord样式下使用）");
            break;
        }
    }
}

/**
 * @brief 点击ChatBar上的按钮事件
 */
- (void)buttonAction:(UIButton *)button{
    SEEDFunctionViewShowType showType = button.tag;
    
    switch (self.inputType) {
        case SEEDChartBarTypeComment:
        {
            //更改对应按钮的状态
            if (button == self.faceButton) {
                [self.faceButton setSelected:!self.faceButton.selected];
                [self.moreButton setSelected:NO];
                [self.voiceButton setSelected:NO];
            }else if (button == self.moreButton){
                [self.faceButton setSelected:NO];
                [self.moreButton setSelected:!self.moreButton.selected];
                [self.voiceButton setSelected:NO];
            }else if (button == self.voiceButton){
                [self.faceButton setSelected:NO];
                [self.moreButton setSelected:NO];
                [self.voiceButton setSelected:!self.voiceButton.selected];
            }
            
            if (!button.selected) {
                showType = SEEDFunctionViewShowKeyboard;
                [self.textView becomeFirstResponder];
            }
        }
            break;
        case SEEDChartBarTypeRecord:
        {
            //更改对应按钮的状态
            if (button == self.faceButton) {
                [self.faceButton setSelected:!self.faceButton.selected];
            }else if (button == self.sinaButton){
                [self.sinaButton setSelected:!self.sinaButton.selected];
            }
            
            if (!button.selected && button == self.faceButton) {
                showType = SEEDFunctionViewRespondKeyboard;
                NSLog(@"记录模式下 调用textView弹键盘");
            }else if (button == self.sinaButton){
                showType = SEEDFunctionViewSinaShare;
            }
        }
            break;
        case SEEDChartBarTypeFriends:
        {
            //更改对应按钮的状态
            if (button == self.faceButton) {
                [self.faceButton setSelected:!self.faceButton.selected];
                [self.moreButton setSelected:NO];
                [self.voiceButton setSelected:NO];
            }else if (button == self.moreButton){
                [self.moreButton setSelected:!self.moreButton.selected];
                [self.faceButton setSelected:NO];
                [self.voiceButton setSelected:NO];
            }else if (button == self.voiceButton){
                [self.voiceButton setSelected:!self.voiceButton.selected];
                [self.faceButton setSelected:NO];
                [self.moreButton setSelected:NO];
            }
            
            if (!button.selected) {
                showType = SEEDFunctionViewShowKeyboard;
                [self.textView becomeFirstResponder];
            }
        }
            break;
    }
    
    [self showViewWithType:showType];
}

/**
 * @brief 是否显示表情视图
 */
- (void)showFaceView:(BOOL)show{
    if (show) {
        [self.superview addSubview:self.faceView];
        [UIView animateWithDuration:.3 animations:^{
            [self.faceView setFrame:CGRectMake(0, self.screenHeight - kFunctionViewHeight, self.frame.size.width, kFunctionViewHeight)];
        } completion:nil];
    }else{
        [UIView animateWithDuration:.3 animations:^{
            [self.faceView setFrame:CGRectMake(0, self.screenHeight, self.frame.size.width, kFunctionViewHeight)];
        } completion:^(BOOL finished) {
            [self.faceView removeFromSuperview];
        }];
    }
}

/**
 *  @brief 是否显示moreView
 */
- (void)showMoreView:(BOOL)show{
    if (show) {
        [self.superview addSubview:self.moreView];
        [UIView animateWithDuration:.3 animations:^{
            [self.moreView setFrame:CGRectMake(0, self.screenHeight - kFunctionViewHeight, self.frame.size.width, kFunctionViewHeight)];
        } completion:nil];
    }else{
        [UIView animateWithDuration:.3 animations:^{
            [self.moreView setFrame:CGRectMake(0, self.screenHeight, self.frame.size.width, kFunctionViewHeight)];
        } completion:^(BOOL finished) {
            [self.moreView removeFromSuperview];
        }];
    }
}

/**
 *  @brief 是否显示的voiceView
 */
- (void)showVoiceView:(BOOL)show{
    self.voiceButton.selected = show;
    self.voiceRecordButton.selected = show;
    self.voiceRecordButton.hidden = !show;
}

/**
 *  @brief 发送普通的文本信息,通知代理
 *  @param text 发送的文本信息
 */
- (void)sendTextMessage:(NSString *)text{
    if (!text || text.length == 0) {
        return;
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(chatBar:sendMessage:)]) {
        [self.delegate chatBar:self sendMessage:text];
    }
    self.textView.text = @"";
    [self setFrame:CGRectMake(0, self.screenHeight - self.bottomHeight - kMinHeight, self.frame.size.width, kMinHeight) animated:NO];
    [self showViewWithType:SEEDFunctionViewShowKeyboard];
}

/**
 *  @brief 通知代理发送语音信息
 *  @param voiceData 发送的语音信息data
 *  @param seconds   语音时长
 */
- (void)sendVoiceMessage:(NSData *)voiceData seconds:(NSTimeInterval)seconds{
    if (self.delegate && [self.delegate respondsToSelector:@selector(chatBar:sendVoice:seconds:)]) {
        [self.delegate chatBar:self sendVoice:voiceData seconds:seconds];
    }
}

/**
 *  @brief 通知代理发送图片信息
 *  @param image 发送的图片
 */
- (void)sendImageMessage:(UIImage *)image{
    if (self.delegate && [self.delegate respondsToSelector:@selector(chatBar:sendPictures:)]) {
        [self.delegate chatBar:self sendPictures:@[image]];
    }
}

#pragma mark - 获取子视图模块
/**
 * @brief 获取表情视图
 * @note 根据不同的输入框类型，定制不同风格的表情视图
 */
- (SEEDChatFaceView *)faceView{
    if (!_faceView) {
        switch (self.inputType) {
            case SEEDChartBarTypeComment:
            case SEEDChartBarTypeRecord:
            {
                _faceView = [SEEDChatFaceView faceViewWithFrame:CGRectMake(0, self.screenHeight , self.frame.size.width, kFunctionViewHeight) Style:SEEDFaceViewStyleNormal];
            }
                break;
                
            case SEEDChartBarTypeFriends:
            {
                _faceView = [SEEDChatFaceView faceViewWithFrame:CGRectMake(0, self.screenHeight , self.frame.size.width, kFunctionViewHeight) Style:SEEDFaceViewStyleDiverse];
            }
                break;
        }
        
        _faceView.delegate = self;
        _faceView.backgroundColor = self.backgroundColor;
    }
    return _faceView;
}
/**
 * @brief 获取更多视图
 */
- (SEEDChatMoreView *)moreView{
    if (!_moreView) {
        _moreView = [[SEEDChatMoreView alloc] initWithFrame:CGRectMake(0, self.screenHeight , self.frame.size.width, kFunctionViewHeight)];
        _moreView.delegate = self;
        _moreView.dataSource = self;
        _moreView.backgroundColor = self.backgroundColor;
    }
    return _moreView;
}
/**
 * @brief 获取输入框视图
 */
- (UITextView *)textView{
    if (!_textView) {
        self.textStorage = [[TKTextStorage alloc] init];
        NSTextContainer *textContainer = [[NSTextContainer alloc] initWithSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX)];
        NSLayoutManager *layoutManager = [[NSLayoutManager alloc] init];
        [layoutManager addTextContainer:textContainer];
        [_textStorage addLayoutManager:layoutManager];
        _textView = [[UITextView alloc] initWithFrame:CGRectZero
                                        textContainer:textContainer];
        
        _textView.returnKeyType = UIReturnKeySend;
        _textView.font = [UIFont systemFontOfSize:16.0f];
        _textView.layer.cornerRadius = 4.0f;
        _textView.layer.borderColor = [UIColor colorWithRed:204.0/255.0f green:204.0/255.0f blue:204.0/255.0f alpha:1.0f].CGColor;
        _textView.layer.borderWidth = .5f;
        _textView.layer.masksToBounds = YES;
        _textView.delegate = self;
        _textView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
        [_textStorage setBodyAttributes:_textView];
    }
    return _textView;
}
/**
 * @brief 获取录音切换按钮视图
 */
- (UIButton *)voiceButton{
    if (!_voiceButton) {
        _voiceButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _voiceButton.tag = SEEDFunctionViewShowVoice;
        [_voiceButton setBackgroundImage:[UIImage imageNamed:@"chat_bar_voice_normal"] forState:UIControlStateNormal];
        [_voiceButton setBackgroundImage:[UIImage imageNamed:@"chat_bar_input_normal"] forState:UIControlStateSelected];
        [_voiceButton addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
        [_voiceButton sizeToFit];
    }
    return _voiceButton;
}

/**
 * @brief 获取按住录音按钮视图
 */
- (UIButton *)voiceRecordButton{
    if (!_voiceRecordButton) {
        _voiceRecordButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _voiceRecordButton.hidden = YES;
        _voiceRecordButton.frame = self.textView.bounds;
        _voiceRecordButton.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [_voiceRecordButton setBackgroundColor:[UIColor lightGrayColor]];
        _voiceRecordButton.titleLabel.font = [UIFont systemFontOfSize:14.0f];
        [_voiceRecordButton setTitle:@"按住录音" forState:UIControlStateNormal];
        [_voiceRecordButton addTarget:self action:@selector(startRecordVoice) forControlEvents:UIControlEventTouchDown];
        [_voiceRecordButton addTarget:self action:@selector(cancelRecordVoice) forControlEvents:UIControlEventTouchUpOutside];
        [_voiceRecordButton addTarget:self action:@selector(confirmRecordVoice) forControlEvents:UIControlEventTouchUpInside];
        [_voiceRecordButton addTarget:self action:@selector(updateCancelRecordVoice) forControlEvents:UIControlEventTouchDragExit];
        [_voiceRecordButton addTarget:self action:@selector(updateContinueRecordVoice) forControlEvents:UIControlEventTouchDragEnter];
    }
    return _voiceRecordButton;
}
/**
 * @brief 获取更多按钮的视图
 */
- (UIButton *)moreButton{
    if (!_moreButton) {
        _moreButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _moreButton.tag = SEEDFunctionViewShowMore;
        [_moreButton setBackgroundImage:[UIImage imageNamed:@"chat_bar_more_normal"] forState:UIControlStateNormal];
        [_moreButton setBackgroundImage:[UIImage imageNamed:@"chat_bar_input_normal"] forState:UIControlStateSelected];
        [_moreButton addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
        [_moreButton sizeToFit];
    }
    return _moreButton;
}
/**
 * @brief 获取切换表情按钮的视图
 */
- (UIButton *)faceButton{
    if (!_faceButton) {
        _faceButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _faceButton.tag = SEEDFunctionViewShowFace;
        [_faceButton setBackgroundImage:[UIImage imageNamed:@"chat_bar_face_normal"] forState:UIControlStateNormal];
        [_faceButton setBackgroundImage:[UIImage imageNamed:@"chat_bar_input_normal"] forState:UIControlStateSelected];
        [_faceButton addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
        [_faceButton sizeToFit];
    }
    return _faceButton;
}
/**
 * @brief 获取发送的按钮
 */
- (UIButton *)sendButton{
    if (!_sendButton) {
        _sendButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _sendButton.tag = SEEDFunctionViewSendComment;
        [_sendButton setTitle:@"发送" forState:UIControlStateNormal];
        [_sendButton setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
        [_sendButton addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
        [_sendButton sizeToFit];
    }
    return _sendButton;
}
/**
 * @brief 获取同步到视图
 */
-(UILabel *)sinaLabel{
    if (!_sinaLabel) {
        _sinaLabel = [[UILabel alloc]init];
        _sinaLabel.text = @"同步到";
        [_sinaLabel sizeToFit];
    }
    return _sinaLabel;
}
/**
 * @brief 获取新浪分享按钮
 */
- (UIButton *)sinaButton{
    if (!_sinaButton) {
        _sinaButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _sinaButton.tag = SEEDFunctionViewSinaShare;
        [_sinaButton setBackgroundImage:[UIImage imageNamed:@"chat_bar_input_normal"] forState:UIControlStateNormal];
        [_sinaButton setBackgroundImage:[UIImage imageNamed:@"chat_bar_input_normal"] forState:UIControlStateSelected];
        [_sinaButton addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
        [_sinaButton sizeToFit];
    }
    return _sinaButton;
}

/**
 * @brief 获取屏幕高度
 */
- (CGFloat)screenHeight{
    return [[UIApplication sharedApplication] keyWindow].bounds.size.height;
}
/**
 * @brief 获取底部高度
 */
- (CGFloat)bottomHeight{
    if (self.faceView.superview || self.moreView.superview) {
        return MAX(self.keyboardFrame.size.height, MAX(self.faceView.frame.size.height, self.moreView.frame.size.height));
    }else{
        return MAX(self.keyboardFrame.size.height, CGFLOAT_MIN);
    }
}
/**
 * @brief 设置根视图
 */
- (UIViewController *)rootViewController{
    return [[UIApplication sharedApplication] keyWindow].rootViewController;
}

#pragma mark - 坐标
/**
 * @brief 设置视图坐标
 */
- (void)setFrame:(CGRect)frame animated:(BOOL)animated{
    if (animated) {
        [UIView animateWithDuration:.3 animations:^{
            [self setFrame:frame];
        }];
    }else{
        [self setFrame:frame];
    }
    NSLog(@"frame is %@",NSStringFromCGRect(frame));
    if (self.delegate && [self.delegate respondsToSelector:@selector(chatBarFrameDidChange:frame:)]) {
        [self.delegate chatBarFrameDidChange:self frame:frame];
    }
}

#pragma mark - 富文本编辑
/**
 * @brief 文本框中插入图片
 */
-(void)insertPicture:(NSString *)pictureName{
    if (pictureName.length != 0) {
        NSMutableArray *newAdd = [NSMutableArray array];
        UIImage *pImg = [UIImage imageNamed:pictureName];
        
        //设置标记和图片
        TKPicTextAttachment *picTextAttachment = [TKPicTextAttachment new];
        NSInteger tag = 1;
        picTextAttachment.picTag = [NSString stringWithFormat:@"%@%lu%@",@"[",tag,@"]"];
        picTextAttachment.image  = pImg;
        //设置插入emoji图片尺寸
        picTextAttachment.picSize = 75.f/4;
        [newAdd addObject:picTextAttachment];
        
        [_textStorage addMorePicture:newAdd withTextView:_textView];
    }
    
    [self textViewScrollToVisiable];
}
/**
 * @brief 将_textView滚动至最底部输入可见
 */
-(void)textViewScrollToVisiable
{
    if (_textView != nil) {
        CGRect textViewFrame = self.textView.frame;
        CGSize textSize = [self.textView sizeThatFits:CGSizeMake(CGRectGetWidth(textViewFrame), 1000.0f)];
        
        CGFloat offset = 10;
        _textView.scrollEnabled = (textSize.height + 0.1 > kMaxHeight-offset);
        textViewFrame.size.height = MAX(34, MIN(kMaxHeight, textSize.height));
        
        CGRect addBarFrame = self.frame;
        addBarFrame.size.height = textViewFrame.size.height+offset;
        addBarFrame.origin.y = self.screenHeight - self.bottomHeight - addBarFrame.size.height;
        [self setFrame:addBarFrame animated:NO];
        
        if (_textView.scrollEnabled) {
            [_textView scrollRangeToVisible:NSMakeRange(_textView.text.length - 2, 1)];
        }
    }
}

@end

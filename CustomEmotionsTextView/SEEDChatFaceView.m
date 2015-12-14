//
//  SEEDChatFaceView.m
//  CustomEmotionsTextView
//
//  Created by Cobb on 15/12/8.
//  Copyright © 2015年 Cobb. All rights reserved.
//

#import "SEEDChatFaceView.h"
#import "SEEDFaceManager.h"

/**
 * @class 预览表情显示的View
 */
@interface SEEDFacePreviewView : UIView

@property (weak,  nonatomic) UIImageView *faceImageView /**< 展示face表情的 */;
@property (weak,  nonatomic) UIImageView *backgroundImageView /**< 默认背景 */;

@end

@implementation SEEDFacePreviewView

/**
 * @brief 实例化方法
 */
- (instancetype)initWithFrame:(CGRect)frame{
    if ([super initWithFrame:frame]) {
        [self setup];
    }
    return self;
}
/**
 * @brief 初始化设置
 */
- (void)setup{
    UIImageView *backgroundImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"preview_background"]];
    [self addSubview:self.backgroundImageView = backgroundImageView];
    
    UIImageView *faceImageView = [[UIImageView alloc] init];
    faceImageView.contentMode = UIViewContentModeScaleAspectFit;
    [self addSubview:self.faceImageView = faceImageView];
    
    self.bounds = self.backgroundImageView.bounds;
}

/**
 *  @brief 设置faceImageView显示的图片
 *  @param image 需要显示的表情图片
 */
- (void)setFaceImage:(UIImage *)image{
    if (self.faceImageView.image == image) {
        return;
    }
    [self.faceImageView setImage:image];
    self.faceImageView.frame = CGRectMake(0, 0, 40, 40);
    self.faceImageView.center = self.backgroundImageView.center;
    [UIView animateWithDuration:.3 animations:^{
        self.faceImageView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.3, 1.3);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:.2 animations:^{
            self.faceImageView.transform = CGAffineTransformIdentity;
        }];
    }];
}

@end


@interface SEEDChatFaceView ()<UIScrollViewDelegate>

@property (assign, nonatomic) SEEDFaceViewStyle seedStyle;//表情视图样式
@property (strong, nonatomic) UIScrollView *scrollView;//展示滚动视图
@property (strong, nonatomic) UIPageControl *pageControl;//分页
@property (strong, nonatomic) SEEDFacePreviewView *facePreviewView;//表情预览

@property (strong, nonatomic) UIView *bottomView;//底部视图
@property (weak,   nonatomic) UIButton *normalEmojiButton; /**< 显示普通emoji表情Button */
@property (weak,   nonatomic) UIButton *seedFaceButton;   /**< 显示种子表情的button */
@property (strong, nonatomic) UIView   *alphaHud; //单个表情按钮蒙层视图

@property (assign, nonatomic, readonly) NSUInteger maxPerLine; /**< 每行显示的表情数量,6,6plus可能相应多显示  默认emoji5s显示7个 最近表情显示4个  gif表情显示4个 */
@property (assign, nonatomic, readonly) NSUInteger maxLine; /**< 每页显示的行数 默认emoji3行  最近表情2行  gif表情2行 */
@property (assign, nonatomic) NSUInteger facePage; /**< 当前显示的facePage */

@end

@implementation SEEDChatFaceView

/**
 * @brief 类方法 根据表情视图的类型返回实例
 */
+(instancetype)faceViewWithFrame:(CGRect)frame Style:(SEEDFaceViewStyle)syle
{
    return [[SEEDChatFaceView alloc]initWithFrame:frame seedStyle:syle];
}
/**
 * @brief 实例化方法
 */
- (instancetype)initWithFrame:(CGRect)frame seedStyle:(SEEDFaceViewStyle)style{
    if ([super initWithFrame:frame]) {
        [self setupWithstyle:style];
    }
    return self;
}

#pragma mark - Private Methods
/**
 * @brief 根据样式设置子视图
 * 当视图样式为SEEDFaceViewStyleDiverse时才显示底部视图
 */
- (void)setupWithstyle:(SEEDFaceViewStyle)style{
    self.seedStyle = style;
    
    [self addSubview:self.scrollView];
    [self addSubview:self.pageControl];
    
    if (style == SEEDFaceViewStyleDiverse){
        [self addSubview:self.bottomView];
    }
    
    [self setupEmojiFaces];//设置类emoji表情
    
    self.userInteractionEnabled = YES;
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    [self.scrollView addGestureRecognizer:longPress];
}
/**
 * @brief 重设底部视图
 */
- (void)resetScrollView{
    [self.normalEmojiButton setSelected:self.faceViewType == SEEDShowNormalEmojiFace];
    [self.seedFaceButton setSelected:self.faceViewType == SEEDShowSeedEmojiFace];
    [self.scrollView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self.scrollView setContentSize:CGSizeZero];
    [self.pageControl setNumberOfPages:0];
}
/**
 * @brief 设置表情视图
 */
- (void)setupFaceView{
    if (self.faceViewType == SEEDShowNormalEmojiFace) {
        [self setupEmojiFaces];
    }else if (self.faceViewType == SEEDShowSeedEmojiFace){
        [self setupSeedFaces];
    }
}
/**
 * @brief 初始化种子的表情view
 */
- (void)setupSeedFaces{
    [self resetScrollView];
    
    //计算每一页最多显示多少个表情 (每行显示数量)*3
    NSLog(@"[self maxPerLine] + 1 is %lu [self maxLine] is %lu",[self maxPerLine] + 1,[self maxLine]);
    NSInteger pageItemCount = ([self maxPerLine] + 1) * [self maxLine];
    
    //获取所有的face表情dict包含face_id,face_name两个key-value
    NSMutableArray *allSeeds = [NSMutableArray arrayWithArray:[SEEDFaceManager seedFaces]];
    
    //计算页数
    NSUInteger pageCount = [allSeeds count] % pageItemCount == 0 ? [allSeeds count] / pageItemCount : ([allSeeds count] / pageItemCount) + 1;
    
    //配置pageControl的页数
    self.pageControl.numberOfPages = pageCount;
    
    //循环添加所有的imageView
    NSUInteger maxPerLine = self.maxPerLine;
    NSUInteger line = 0;
    NSUInteger column = 0;
    NSUInteger page = 0;   //页数
    CGFloat itemWidth = (self.frame.size.width - 20) / (self.maxPerLine + 1);
    for (NSDictionary *faceDict in allSeeds) {
        //判断是否超过每一行显示的最大数量,是则换行
        if (column > maxPerLine) {
            line ++ ;
            column = 0;
        }
        //判断是否超过每一行显示的最大数量,是则换下一页
        if (line >= 2) {
            line = 0;
            column = 0;
            page ++ ;
        }
        //计算每一个图片的起始X位置 10(左边距) + 第几列*itemWidth + 第几页*一页的宽度
        CGFloat startX = 10 + column * itemWidth + page * self.frame.size.width;
        //计算每一个图片的起始Y位置  第几行*每行高度
        CGFloat startY = line * itemWidth;
        
        UIButton *imageButton = [UIButton buttonWithType:UIButtonTypeCustom];
        imageButton.frame = CGRectMake(startX, startY, itemWidth-10, itemWidth-10);
        imageButton.tag = [faceDict[kFaceIDKey] integerValue];
        [imageButton addTarget:self action:@selector(seedFaceClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.scrollView addSubview:imageButton];
        
        UIImageView *imageView = [self faceImageViewWithID:faceDict[kFaceIDKey]];
        imageView.tag = 1000+imageButton.tag;
        [imageView setFrame:CGRectMake((imageButton.frame.size.width-60)/2, (imageButton.frame.size.height-60)/2, 60, 60)];
        [imageButton addSubview:imageView];
        column ++ ;
    }
    //重新配置下scrollView的contentSize
    [self.scrollView setContentSize:CGSizeMake(self.scrollView.frame.size.width * (page + 1), self.scrollView.frame.size.height)];
    [self.scrollView setContentOffset:CGPointMake(self.facePage * self.frame.size.width, 0)];
    self.pageControl.currentPage = self.facePage;
}

/**
 * @brief 初始化普通的emoji表情
 */
- (void)setupEmojiFaces{
    [self resetScrollView];
    
    //计算每一页最多显示多少个表情 (每行显示数量)*3 - 1(删除按钮)
    NSInteger pageItemCount = (self.maxPerLine + 1) * self.maxLine - 1;
    
    //获取所有的face表情dict包含face_id,face_name两个key-value
    NSMutableArray *allFaces = [NSMutableArray arrayWithArray:[SEEDFaceManager emojiFaces]];
    
    //计算页数
    NSUInteger pageCount = [allFaces count] % pageItemCount == 0 ? [allFaces count] / pageItemCount : ([allFaces count] / pageItemCount) + 1;
    
    //配置pageControl的页数
    self.pageControl.numberOfPages = pageCount;
    
    //循环,给每一页末尾加上一个delete图片,如果是最后一页直接在最后一个加上delete图片
    for (int i = 0; i < pageCount; i++) {
        if (pageCount - 1 == i) {
            [allFaces addObject:@{@"face_id":@"999",@"face_name":@"删除"}];
        }else{
            [allFaces insertObject:@{@"face_id":@"999",@"face_name":@"删除"} atIndex:(i + 1) * pageItemCount + i];
        }
    }
    
    //循环添加所有的imageView
    NSUInteger maxPerLine = self.maxPerLine;
    NSUInteger line = 0;   //行数
    NSUInteger column = 0; //列数
    NSUInteger page = 0;   //页数
    //每一行从0开始 显示maxPerLine+1个图片 计算每一个图片的宽度
    CGFloat itemWidth = (self.frame.size.width - 20) / (self.maxPerLine + 1);
    
    for (NSDictionary *faceDict in allFaces) {
        
        //判断是否超过每一行显示的最大数量,是则换行
        if (column > maxPerLine) {
            line ++ ;
            column = 0;
        }
        //判断是否超过每一行显示的最大数量,是则换下一页
        if (line > 2) {
            line = 0;
            column = 0;
            page ++ ;
        }
        //计算每一个图片的起始X位置 10(左边距) + 第几列*itemWidth + 第几页*一页的宽度
        CGFloat startX = 10 + column * itemWidth + page * self.frame.size.width;
        //计算每一个图片的起始Y位置  第几行*每行高度
        CGFloat startY = line * itemWidth;
        
        UIButton *imageButton = [UIButton buttonWithType:UIButtonTypeCustom];
        imageButton.frame = CGRectMake(startX, startY, itemWidth, itemWidth);
        imageButton.tag = [faceDict[kFaceIDKey] integerValue];
        [imageButton addTarget:self action:@selector(handleTap:) forControlEvents:UIControlEventTouchUpInside];
        [self.scrollView addSubview:imageButton];
        
        UIImageView *imageView = [self faceImageViewWithID:faceDict[kFaceIDKey]];
        imageView.tag = 1000+imageButton.tag;
        [imageView setFrame:CGRectMake((imageButton.frame.size.width-30)/2, (imageButton.frame.size.height-30)/2, 30, 30)];
        [imageButton addSubview:imageView];
        column ++ ;
    }
    //重新配置下scrollView的contentSize
    [self.scrollView setContentSize:CGSizeMake(self.scrollView.frame.size.width * (page + 1), self.scrollView.frame.size.height)];
    [self.scrollView setContentOffset:CGPointMake(self.facePage * self.frame.size.width, 0)];
    self.pageControl.currentPage = self.facePage;
}

/**
 *  @brief 根据faceID获取一个imageView实例
 *  @param faceID faceID
 *  @return
 */
- (UIImageView *)faceImageViewWithID:(NSString *)faceID{
    NSString *faceImageName = nil;
    if (self.faceViewType == SEEDShowNormalEmojiFace) {
        faceImageName = [SEEDFaceManager faceImageNameWithFaceID:[faceID integerValue]];
    }else if (self.faceViewType == SEEDShowSeedEmojiFace){
        faceImageName = [SEEDFaceManager seedImageNameWithSeedID:[faceID integerValue]];
    }
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:faceImageName]];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    
    return imageView;
}


/**
 *  @brief 处理每个图片对应的点击手势
 *  特殊处理下tag=999  这是一个删除图片
 */
- (void)handleTap:(UIButton *)sender{
    NSString *faceName = [SEEDFaceManager faceNameWithFaceID:sender.tag];
    if (self.delegate && [self.delegate respondsToSelector:@selector(faceViewSendFace:)]) {
        [self.delegate faceViewSendFace:faceName];
    }
}
/**
 *  @brief 点击seed种子图片
 *  直接发送该图片
 */
- (void)seedFaceClick:(UIButton *)sender{
    NSString *faceName = [SEEDFaceManager seedImageNameWithSeedID:sender.tag];
    if (self.delegate && [self.delegate respondsToSelector:@selector(faceViewSendFace:)]) {
        [self.delegate faceViewSendFace:faceName];
    }
}

/**
 *  @brief 处理scrollView的长按手势
 *  @param longPress
 */
- (void)handleLongPress:(UILongPressGestureRecognizer *)longPress{
    CGPoint touchPoint = [longPress locationInView:self];
    UIImageView *touchFaceView = [self faceViewWitnInPoint:touchPoint];
    if (longPress.state == UIGestureRecognizerStateBegan) {
        [self.facePreviewView setCenter:CGPointMake(touchPoint.x, touchPoint.y - 40)];
        [self.facePreviewView setFaceImage:touchFaceView.image];
        [self addSubview:self.facePreviewView];
    }else if (longPress.state == UIGestureRecognizerStateChanged){
        [self.facePreviewView setCenter:CGPointMake(touchPoint.x, touchPoint.y - 40)];
        [self.facePreviewView setFaceImage:touchFaceView.image];
    }else if (longPress.state == UIGestureRecognizerStateEnded) {
        [self.facePreviewView removeFromSuperview];
    }
}


/**
 *  @brief 根据点击位置获取点击的imageView
 *  @param point 点击的位置
 *  @return 被点击的imageView
 */
- (UIImageView *)faceViewWitnInPoint:(CGPoint)point{
    
    for (UIButton *imageButton in self.scrollView.subviews) {
        UIImageView *currentImageView = (UIImageView *)[imageButton viewWithTag:imageButton.tag+1000];
        if (CGRectContainsPoint(imageButton.frame, CGPointMake(self.pageControl.currentPage * self.frame.size.width + point.x, point.y))) {
            return currentImageView;
        }
    }
    return nil;
}
/**
 * @brief 发送按钮点击，传递给协议成员操作
 */
- (void)sendAction:(UIButton *)button{
    if (self.delegate && [self.delegate respondsToSelector:@selector(faceViewSendFace:)]) {
        [self.delegate faceViewSendFace:@"发送"];
    }
}
/**
 * @brief 更改当前表情类别
 */
- (void)changeFaceType:(UIButton *)button{
    self.faceViewType = button.tag;
    [self setupFaceView];
}

#pragma mark - Getters
/**
 * @brief 获取展示表情的滚动视图
 */
- (UIScrollView *)scrollView{
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 10, self.frame.size.width, self.frame.size.height - 60)];
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.pagingEnabled = YES;
        _scrollView.delegate = self;
    }
    return _scrollView;
}
/**
 * @brief 获取分页视图
 */
- (UIPageControl *)pageControl{
    if (!_pageControl) {
        _pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0, self.scrollView.frame.size.height, self.frame.size.width, 20)];
        _pageControl.pageIndicatorTintColor = [UIColor lightGrayColor];
        _pageControl.currentPageIndicatorTintColor = [UIColor darkGrayColor];
        _pageControl.hidesForSinglePage = YES;
    }
    return _pageControl;
}
/**
 * @brief 获取表情预览视图
 */
- (SEEDFacePreviewView *)facePreviewView{
    if (!_facePreviewView) {
        _facePreviewView = [[SEEDFacePreviewView alloc] initWithFrame:CGRectZero];
    }
    return _facePreviewView;
}
/**
 * @brief 设置底部视图
 */
- (UIView *)bottomView{
    if (!_bottomView) {
        _bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, self.frame.size.height - 40, self.frame.size.width, 40)];
        
        UIImageView *topLine = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width - 70, 1.0f)];
        topLine.backgroundColor = [UIColor lightGrayColor];
        [_bottomView addSubview:topLine];
        
        UIButton *emojiButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [emojiButton setBackgroundImage:[UIImage imageNamed:@"chat_bar_emoji_normal"] forState:UIControlStateNormal];
        [emojiButton setBackgroundImage:[UIImage imageNamed:@"chat_bar_emoji_highlight"] forState:UIControlStateHighlighted];
        [emojiButton setBackgroundImage:[UIImage imageNamed:@"chat_bar_emoji_highlight"] forState:UIControlStateSelected];
        emojiButton.tag = SEEDShowNormalEmojiFace;
        [emojiButton addTarget:self action:@selector(changeFaceType:) forControlEvents:UIControlEventTouchUpInside];
        [emojiButton sizeToFit];
        [_bottomView addSubview:self.normalEmojiButton = emojiButton];
        [emojiButton setFrame:CGRectMake(0, _bottomView.frame.size.height/2-emojiButton.frame.size.height/2, emojiButton.frame.size.width, emojiButton.frame.size.height)];
        
        UIButton *seedButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [seedButton setBackgroundImage:[UIImage imageNamed:@"chat_bar_recent_normal"] forState:UIControlStateNormal];
        [seedButton setBackgroundImage:[UIImage imageNamed:@"chat_bar_recent_highlight"] forState:UIControlStateHighlighted];
        [seedButton setBackgroundImage:[UIImage imageNamed:@"chat_bar_recent_highlight"] forState:UIControlStateSelected];
        seedButton.tag = SEEDShowSeedEmojiFace;
        [seedButton addTarget:self action:@selector(changeFaceType:) forControlEvents:UIControlEventTouchUpInside];
        [seedButton sizeToFit];
        [_bottomView addSubview:self.seedFaceButton = seedButton];
        [seedButton setFrame:CGRectMake(emojiButton.frame.size.width, _bottomView.frame.size.height/2-emojiButton.frame.size.height/2, emojiButton.frame.size.width, emojiButton.frame.size.height)];
    }
    return _bottomView;
}
/**
 * @brief 获取最大每行显示数
 */
- (NSUInteger)maxPerLine{
    if (self.faceViewType == SEEDShowNormalEmojiFace) {
        return 6;
    }else if (self.faceViewType == SEEDShowSeedEmojiFace){
        return 3;
    }
    return 0;
}
/**
 * @brief 获取最大显示行数
 */
- (NSUInteger)maxLine{
    if (self.faceViewType == SEEDShowNormalEmojiFace) {
        return 3;
    }else if (self.faceViewType == SEEDShowSeedEmojiFace){
        return 2;
    }
    return 0;
}

#pragma mark - UIScrollViewDelegate
/**
 * @brief 视图结束滚动时设置页码
 */
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    [self.pageControl setCurrentPage:scrollView.contentOffset.x / scrollView.frame.size.width];
    self.facePage = self.pageControl.currentPage;
}

#pragma mark - 为按钮添加蒙层
/**
 * @brief 按钮的蒙层
 */
-(void)alphaAddTo:(UIButton *)sender
{
    [self addUpAlphaViewToSender:sender];
    [self performSelector:@selector(removeUpAlphaView) withObject:nil afterDelay:0.3f];
}

/**
 * @brief 添加透明层
 */
-(void)addUpAlphaViewToSender:(UIButton *)sender
{
    _alphaHud = [[UIView alloc]init];
    _alphaHud.frame = CGRectMake(0, 0, sender.bounds.size.width, sender.bounds.size.height);
    _alphaHud.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.4];
    [self addSubview:_alphaHud];
}

/**
 * @brief 删除透明层
 */
-(void)removeUpAlphaView
{
    [_alphaHud removeFromSuperview];
}
@end

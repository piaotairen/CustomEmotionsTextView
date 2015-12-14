//
//  ViewController.m
//  CustomEmotionsTextView
//
//  Created by Cobb on 15/12/8.
//  Copyright © 2015年 Cobb. All rights reserved.
//

#import "ViewController.h"
#import "TKTextStorage.h"
#import "TKPicTextAttachment.h"
#import "SEEDChatBar.h"

#define MLString(str) NSLocalizedString(str, @"")   //多国语言
#define kScreenPx(px) (roundf((px)*0.33333))  //用户将px的像素长度转换为屏幕点（四舍五入）
#define kYellowVerSpace (kScreenPx(40.0f)) //黄色视图垂直间隙
#define kYellowhorSpace (kScreenPx(40.0f)) //黄色视图水平间隙
#define kScreenWidth ([[UIScreen mainScreen]bounds].size.width < [[UIScreen mainScreen]bounds].size.height?[[UIScreen mainScreen]bounds].size.width:[[UIScreen mainScreen]bounds].size.height)//屏幕宽度
#define kScreenHeight ([[UIScreen mainScreen]bounds].size.height > [[UIScreen mainScreen]bounds].size.width?[[UIScreen mainScreen]bounds].size.height:[[UIScreen mainScreen]bounds].size.width)//屏幕高度
#define kLeftReplacePicStr  @"「#_JZTAG_"      //酱知左侧feed长文中的图片占位符
#define kRightReplacePicStr @"_JZTAG_#」"      //酱知右侧feed长文中的图片占位符

@interface ViewController () <UITextViewDelegate,SEEDChatBarDelegate>
{
    NSMutableArray *addPicArray;  //添加图片数组
    TKTextStorage *_textStorage;
    UITextView * _textView;  //编辑视图
    CGFloat MaxImgWidth;
}

@property (strong, nonatomic) SEEDChatBar *chatBar;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
        [self customTextView];
    
    [self customChartBar];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/**
 * 自定义的编辑框
 */
-(void)customTextView
{
    _textStorage = [[TKTextStorage alloc] init];
    NSTextContainer *textContainer = [[NSTextContainer alloc] initWithSize:CGSizeMake(kScreenWidth, CGFLOAT_MAX)];
    NSLayoutManager *layoutManager = [[NSLayoutManager alloc] init];
    [layoutManager addTextContainer:textContainer];
    [_textStorage addLayoutManager:layoutManager];
    
    CGRect textViewRect = CGRectMake(kYellowhorSpace/2, 20+kYellowhorSpace/2, kScreenWidth - kYellowVerSpace, kScreenHeight - 344 - 2*kYellowVerSpace);
    
    _textView = [[UITextView alloc] initWithFrame:textViewRect
                                    textContainer:textContainer];
    _textView.layer.borderWidth = 1.0;
    _textView.layer.cornerRadius = 3.0f;
    _textView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    _textView.delegate = self;
    
    _textView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    MaxImgWidth = 75/3;
    
    [_textStorage setBodyAttributes:_textView];
    
    [self.view addSubview:_textView];
    
    
    //插入图片的按钮
    UIButton *insertPicButton = [UIButton buttonWithType:UIButtonTypeSystem];
    insertPicButton.frame = CGRectMake((kScreenWidth - 100)/2, _textView.frame.origin.y + _textView.frame.size.height + 10, 100, 40);
    [insertPicButton setTitle:@"插入图片" forState:UIControlStateNormal];
    [insertPicButton addTarget:self action:@selector(insert:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:insertPicButton];
}

/**
 * 自定义的输入框
 */
-(void)customChartBar
{
    self.chatBar = [SEEDChatBar chatBarWithType:SEEDChartBarTypeRecord Withframe:CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, kMinHeight)];
    self.chatBar.delegate = self;
    [self.view addSubview:self.chatBar];
}

//- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
//{
//    [super touchesEnded:touches withEvent:event];
//
//    [_textView resignFirstResponder];
//}

-(void)insert:(UIButton*)sender
{
    NSArray *pictures = @[@"爱心",@"悲催",@"鄙视",@"不爽",@"不悦"];
    
    [self insertPicture:pictures];
}

#pragma mark - 添加图片
-(void)insertPicture:(NSArray *)picArray{
    
    NSMutableArray *newAdd = [NSMutableArray array];
    if (picArray.count>0) {
        //获得图片的个数
        
        for (unsigned int i= 0; i < picArray.count; i++) {
            [addPicArray addObject:picArray[i]];
            UIImage *pImg = [UIImage imageNamed:picArray[i]];
            
            TKPicTextAttachment *picTextAttachment = [TKPicTextAttachment new];
            NSInteger tag = addPicArray.count-1;
            //Set tag and image
            picTextAttachment.picTag = [NSString stringWithFormat:@"%@%lu%@",kLeftReplacePicStr,tag,kRightReplacePicStr];
            picTextAttachment.image  = pImg;
            //Set pic size
            picTextAttachment.picSize = MaxImgWidth;
            [newAdd addObject:picTextAttachment];
        }
        
        [_textStorage addMorePicture:newAdd withTextView:_textView];
    }
}

#pragma mark - SEEDChatBarDelegate

- (void)chatBar:(SEEDChatBar *)chatBar sendMessage:(NSString *)message{
    NSLog(@"message is %@",message);
}

- (void)chatBarFrameDidChange:(SEEDChatBar *)chatBar frame:(CGRect)frame{
    NSLog(@"frame change");
}

@end

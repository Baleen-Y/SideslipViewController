//
//  BYDrawerVC.h
//
//
//  Created by Baleen.Y on 5/11/16.
//  Copyright © 2016 Baleen.Y. All rights reserved.
//


#import "BYDrawerVC.h"

#define BYScreenBounds [UIScreen mainScreen].bounds

CGFloat const BYPadding = 80;
CGFloat const BYCoverViewMaxAlpha = 0.6;

#pragma mark -
#pragma mark - BYCoverView
@interface BYCoverView : UIView

/**
 隐藏覆盖
 */
- (void)hidden;

/**
 类工厂方法
 */
+ (instancetype)coverView;

@end

@implementation BYCoverView

/**
 创建覆盖 View
 */
+ (instancetype)coverView {
    BYCoverView *coverView = [[BYCoverView alloc] initWithFrame:BYScreenBounds];
    return coverView;
}
/**
 隐藏覆盖 View
 */
- (void)hidden {
    self.alpha = 0;
}

@end


#pragma mark -
#pragma mark - BYDrawerVC
@interface BYDrawerVC ()<UIGestureRecognizerDelegate>

@property (nonatomic, weak) BYCoverView *coverView;

@end

@implementation BYDrawerVC

#pragma mark viewDidLoad
- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupChildView];
    [self setupGesture];
    [self setupCoverView];
}

#pragma mark - 设置右侧遮盖View
- (void)setupCoverView {
    
    // 1.创建
    BYCoverView *coverView = [BYCoverView coverView];
    coverView.backgroundColor = [UIColor blackColor];
    coverView.alpha = 0;
    self.coverView = coverView;
    [self.mainView addSubview:coverView];
    // 2.添加手势方法
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closeDrawer)];
    [coverView addGestureRecognizer:tap];
    
}

#pragma mark - 设置子View
- (void)setupChildView {
    // 1.设置底部View
    UIView *baseView = [[UIView alloc] initWithFrame:BYScreenBounds];
    baseView.backgroundColor = [UIColor greenColor];
    [self.view addSubview:baseView];
    _baseView = baseView;
    // 2.设置主界面View
    UIView *mainView = [[UIView alloc] initWithFrame:BYScreenBounds];
    mainView.backgroundColor = [UIColor redColor];
    [self.view addSubview:mainView];
    _mainView = mainView;
}

#pragma mark - 设置手势
- (void)setupGesture {
    // 1.mainView添加平移手势
    UIPanGestureRecognizer *panGes = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(mainViewPan:)];
    [self.mainView addGestureRecognizer:panGes];
    // 2.self.View添加点按手势
    UITapGestureRecognizer *tapGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(recoverUI)];
    tapGes.delegate = self;
    [self.baseView addGestureRecognizer:tapGes];
}

#pragma mark - 平移手势操作
- (void)mainViewPan:(UIPanGestureRecognizer *)panGes {

    CGPoint offset = [panGes translationInView:self.mainView];
    [self adjustTransformWithOffset:offset.x];
    // 3.手势消失时动画效果

    if (panGes.state == UIGestureRecognizerStateEnded) {
        // 判断位置
            // 屏幕中线X值
        CGFloat centerX = BYScreenBounds.size.width * 0.5;
            // 拿到mainView的X值
        CGFloat mainViewX = self.mainView.frame.origin.x;
        if (mainViewX > centerX) {
            // 如果当前位置大于中心点动画贴到右边
              [self openDrawer];
        } else {
            // 如果当前位置小于中心点动画贴到左边并恢复transform
            [self closeDrawer];
        }
        
    }
    // 重置offset
    [panGes setTranslation:CGPointZero inView:panGes.view];
    
    // 设置覆盖 View 的透明度
    CGFloat alpha = BYCoverViewMaxAlpha * self.mainView.frame.origin.x / BYScreenBounds.size.width;
    self.coverView.alpha = alpha;
}

#pragma mark - 手势代理方法
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if ([NSStringFromClass([touch.view class]) isEqualToString:@"UITableViewCellContentView"]) {
        return NO;
    }
    return YES;
}

#pragma mark - 调整mainView的位置和形变
- (void)adjustTransformWithOffset:(CGFloat)offsetX {
    
    // 1.平移设置
    // 拿到mainView的frame
    CGRect frame = self.mainView.frame;
    frame.origin.x += offsetX;

    if (frame.origin.x <= 0) {
        frame.origin.x = 0;
    }
   
    self.mainView.frame = frame;
    
    // 2.缩放设置
    [self scale];
    

}

#pragma mark - 打开抽屉
- (void)openDrawer {
    
    __block CGRect frame = self.mainView.frame;
    CGFloat offsetX = BYScreenBounds.size.width - BYPadding;
    frame.origin.x = offsetX;
    [UIView animateWithDuration:0.5 animations:^{
        // 第一次更改
        self.mainView.frame = frame;
        // 缩放
        [self scale];
        // 缩放过程中x,y值会变化，防止修改x值中出现的问题
        frame = self.mainView.frame;
        frame.origin.x = offsetX;
        self.mainView.frame = frame;
        
    }];

}

#pragma mark - 关闭抽屉
- (void)closeDrawer {
    
    [UIView animateWithDuration:0.5 animations:^{
        
        self.mainView.transform = CGAffineTransformIdentity;
        self.mainView.frame = BYScreenBounds;
        [self.coverView hidden];
    }];
    
}

#pragma mark - 点按恢复手势
- (void)recoverUI {
    [self closeDrawer];
}

#pragma mark - 缩放
- (void)scale {
    // 2.缩放设置
    static CGFloat maxScale = 0.3;
    // 获取缩放比例
    CGFloat scale = self.mainView.frame.origin.x * maxScale / BYScreenBounds.size.width;
    CGFloat mainScale = 1 - scale;
    // 预防过快的操作
    if (mainScale > 1) {
        mainScale = 1;
    }
    self.mainView.transform = CGAffineTransformMakeScale(mainScale, mainScale);
}

@end

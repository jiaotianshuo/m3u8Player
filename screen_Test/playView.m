//
//  playView.m
//  screen_Test
//
//  Created by 缴天朔 on 2021/8/31.
//

#import "playView.h"

@interface playView()

@property(nonatomic, strong) NSString *url;
//底部视图
@property(nonatomic, strong) BottomControlView *bottomView;

@property (nonatomic,strong) AVURLAsset *anAsset;

@property(nonatomic, strong) decodeTool *decodeTool;
//原视图
@property(nonatomic, assign) CGRect oriFrame;
//原始约束
@property (nonatomic,strong) NSArray *oldConstriants;

@end

@implementation playView

+(Class)layerClass{
    return [AVPlayerLayer class];
}
//MARK: Get方法和Set方法
-(AVPlayer *)player{
    return self.playerLayer.player;
}
-(void)setPlayer:(AVPlayer *)player{
    self.playerLayer.player = player;
}
-(AVPlayerLayer *)playerLayer{
    return (AVPlayerLayer *)self.layer;
}

#pragma mark - 初始化
-(instancetype)initWithUrl:(NSString *)url{
    self = [super init];
    if (self) {
        _url = url;
        [self setupPlayerUI];
        [self assetWithUrl:url];
    }
    return self;
}

-(void)assetWithUrl:(NSString *)url{
    NSString *m3u8Url = url;
    //    检查本地是否已经有缓存的m3u8索引文件
    NSString *path = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject]  stringByAppendingPathComponent:@"movie.m3u8"];
    NSFileManager *fm = [[NSFileManager alloc] init];
        
    if ([fm fileExistsAtPath:path isDirectory:nil]) {
        //存在这个链接
        NSLog(@"存在这个链接");
        m3u8Url = @"http://127.0.0.1:9479/movie.m3u8";
        self.playerItem = [AVPlayerItem playerItemWithURL:[NSURL URLWithString:m3u8Url]];
    }
    else{
        //处理解析m3u8链接，解析成功后开始下载
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        dispatch_async(queue, ^{
            [self.decodeTool handleM3U8Url:m3u8Url];
        });
        
        NSDictionary *options = @{ AVURLAssetPreferPreciseDurationAndTimingKey : @YES };
        NSURL *url = [NSURL URLWithString:m3u8Url];
        self.anAsset = [[AVURLAsset alloc] initWithURL:url options:options];
        self.playerItem = [[AVPlayerItem alloc] initWithAsset:self.anAsset];
    }
    [self setupPlayerWithAsset];
}

-(void)setupPlayerWithAsset{
//    self.playerItem = [[AVPlayerItem alloc] initWithAsset:asset];
    self.player = [[AVPlayer alloc] initWithPlayerItem:self.playerItem];
    [self.playerLayer displayIfNeeded];
    self.playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    //添加KVO
    [self addKVO];
    //添加消息中心
    [self addNotificationCenter];
    
}

-(void)addNotificationCenter{
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(deviceOrientationDidChange:) name:UIDeviceOrientationDidChangeNotification object:nil];
}

-(void)deviceOrientationDidChange:(NSNotification *)notification{
    UIInterfaceOrientation _interfaceOrientation=[[UIApplication sharedApplication]statusBarOrientation];
    switch (_interfaceOrientation) {
        case UIInterfaceOrientationLandscapeLeft:
        case UIInterfaceOrientationLandscapeRight:
        {
            _isFullScreen = YES;
            if (!self.oldConstriants) {
                self.oldConstriants = [self getCurrentVC].view.constraints;
            }
            [self.bottomView updateConstraintsIfNeeded];
            //删除UIView animate可以去除横竖屏切换过渡动画
            [UIView animateWithDuration:kTransitionTime delay:0 usingSpringWithDamping:0.5 initialSpringVelocity:0. options:UIViewAnimationOptionTransitionCurlUp animations:^{
                [[UIApplication sharedApplication].keyWindow addSubview:self];
                [self mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.edges.mas_equalTo([UIApplication sharedApplication].keyWindow);
                }];
                [self layoutIfNeeded];
            } completion:nil];
        }
            break;
        case UIInterfaceOrientationPortraitUpsideDown:
        case UIInterfaceOrientationPortrait:
        {
            _isFullScreen = NO;
            [[self getCurrentVC].view addSubview:self];
            //删除UIView animate可以去除横竖屏切换过渡动画
            [UIView animateKeyframesWithDuration:kTransitionTime delay:0 options:UIViewKeyframeAnimationOptionCalculationModeLinear animations:^{
                if (self.oldConstriants) {
                    [[self getCurrentVC].view addConstraints:self.oldConstriants];
                }
                [self layoutIfNeeded];
            } completion:nil];
        }
            break;
        case UIInterfaceOrientationUnknown:
            NSLog(@"UIInterfaceOrientationUnknown");
            break;
    }
    [[self getCurrentVC].view layoutIfNeeded];

}

//获取当前屏幕显示的viewcontroller
- (UIViewController *)getCurrentVC
{
    UIViewController *result = nil;
    UIWindow * window = [[UIApplication sharedApplication] keyWindow];
    if (window.windowLevel != UIWindowLevelNormal)
    {
        NSArray *windows = [[UIApplication sharedApplication] windows];
        for(UIWindow * tmpWin in windows)
        {
            if (tmpWin.windowLevel == UIWindowLevelNormal)
            {
                window = tmpWin;
                break;
            }
        }
    }
    UIView *frontView = [[window subviews] objectAtIndex:0];
    id nextResponder = [frontView nextResponder];
    if ([nextResponder isKindOfClass:[UIViewController class]])
        result = nextResponder;
    else
        result = window.rootViewController;
    return result;
}

//添加KVO
-(void)addKVO{
    //监听状态属性
    [self.playerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    //监听网络加载情况
    [self.playerItem addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];
}

#pragma mark - 监听回调
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    
    AVPlayerItem *playerItem = (AVPlayerItem *)object;
    if ([keyPath isEqualToString:@"status"]){
        //获取播放状态
        if (playerItem.status == AVPlayerItemStatusReadyToPlay){
            self.isPlaying = YES;
            [self.player play];
            NSLog(@"开始播放");
        } else{
            NSLog(@"播放失败%@", playerItem.error);
        }
    }
    //监听播放器下载进度
    if ([keyPath isEqualToString:@"loadedTimeRanges"]) {
        NSArray *loadedTimeRange = [self.playerItem loadedTimeRanges];
        //获取缓存区域
        CMTimeRange timeRange = [loadedTimeRange.firstObject CMTimeRangeValue];
        //计算缓存总进度
        float startSeconds = CMTimeGetSeconds(timeRange.start);
        float durationSeconds = CMTimeGetSeconds(timeRange.duration);
        NSTimeInterval timeInterval = startSeconds + durationSeconds;
        //获取总时间
        CMTime duration = self.playerItem.duration;
        CGFloat totalDuration = CMTimeGetSeconds(duration);
        //缓存值
        self.bottomView.bufferValue = timeInterval / totalDuration;
    }
    
}

#pragma mark - 初始化视图
-(void)setupPlayerUI{
    //添加底部视图
    [self addBottomView];
    //初始化时间
    [self initTimeLabels];
    //添加点击事件
//    [self addGestureEvent];
}

//添加底部视图
-(void)addBottomView{
    [self addSubview:self.bottomView];
    [self.bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.mas_equalTo(self);
        make.height.mas_equalTo(@30);
    }];
    [self layoutIfNeeded];
}

//初始化时间
-(void)initTimeLabels{
    self.bottomView.currentTime = @"00:00";
    self.bottomView.totalTime = @"00:00";
    [self.bottomView.largeButton setImage:[UIImage imageNamed:@"full_screen"] forState:UIControlStateNormal];
}

//添加点击事件
-(void)addGestureEvent{
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapAction:)];
    tap.delegate = self;
    [self addGestureRecognizer:tap];
}

-(void)handleTapAction:(UITapGestureRecognizer *)gesture{
    [self setSubViewsIsHide:NO];
}

//设置子视图是否隐藏
-(void)setSubViewsIsHide:(BOOL)isHide{
    self.bottomView.hidden = isHide;
}

#pragma mark - BottomControlViewDelegate

-(void)controlView:(BottomControlView *)controlView pointSliderLocationWithCurrentValue:(CGFloat)value{
    CMTime pointTime = CMTimeMake(value * self.playerItem.currentTime.timescale, self.playerItem.currentTime.timescale);
    [self.playerItem seekToTime:pointTime toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
}
-(void)controlView:(BottomControlView *)controlView draggedPositionWithSlider:(UISlider *)slider{
    CMTime pointTime = CMTimeMake(controlView.currentValue * self.playerItem.currentTime.timescale, self.playerItem.currentTime.timescale);
    [self.playerItem seekToTime:pointTime toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
}
-(void)controlView:(BottomControlView *)controlView withLargeButton:(UIButton *)button{
    self.oriFrame = self.frame;
    if (kScreenWidth<kScreenHeight) {
        [self interfaceOrientation:UIInterfaceOrientationLandscapeRight];
    }else{
        [self interfaceOrientation:UIInterfaceOrientationPortrait];
    }
}


//MARK:旋转方向 - 用户界面旋转方向，用户界面方向旋转，则设备方向一定旋转
- (void)interfaceOrientation:(UIInterfaceOrientation)orientation
{
    if ([[UIDevice currentDevice] respondsToSelector:@selector(setOrientation:)]) {
        SEL selector = NSSelectorFromString(@"setOrientation:");
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[UIDevice instanceMethodSignatureForSelector:selector]];
        [invocation setSelector:selector];
        [invocation setTarget:[UIDevice currentDevice]];
        int val = orientation;

        [invocation setArgument:&val atIndex:2];
        [invocation invoke];
    }
}

#pragma mark - 手势识别

-(void)touchOnScreen:(UITapGestureRecognizer *)recognizer{
    if (self.isPlaying) {
        NSLog(@"Player is playing, now pause");
        self.isPlaying = !self.isPlaying;
        [self.player pause];
    }else{
        NSLog(@"Player is pausing, now play");
        self.isPlaying = !self.isPlaying;
        [self.player play];
    }
}

//#pragma mark - 懒加载
-(decodeTool *)decodeTool{
    if (_decodeTool == nil) {
        _decodeTool = [[decodeTool alloc] init];
    }
    return _decodeTool;
}

-(BottomControlView *)bottomView{
    if (_bottomView == nil) {
        _bottomView = [[BottomControlView alloc] init];
        _bottomView.delegate = self;
        _bottomView.backgroundColor = [UIColor clearColor];
    }
    return _bottomView;
}

@end

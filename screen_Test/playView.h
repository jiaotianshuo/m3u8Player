//
//  playView.h
//  screen_Test
//
//  Created by 缴天朔 on 2021/8/31.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "BottomControlView.h"
#import "M3U8/M3U8VideoDownLoader.h"
#import "M3U8/M3U8Handler.h"
#import "M3U8/M3u8ResourceLoader.h"
#import "M3U8/decodeTool.h"
#import <Masonry.h>
#define kTransitionTime 0.2
#define kScreenWidth ([UIScreen mainScreen].bounds.size.width)
#define kScreenHeight ([UIScreen mainScreen].bounds.size.height)

@interface playView : UIView<DecodeToolDelegate,BottomControlViewDelegate>

@property(nonatomic, strong) AVPlayer *player;

@property(nonatomic, strong) AVPlayerItem *playerItem;

@property(nonatomic, strong) AVPlayerLayer *playerLayer;

@property(nonatomic, assign) CMTime totalTime;

@property(nonatomic, assign) CMTime currentTime;
//是否在播放
@property(nonatomic, assign) BOOL isPlaying;

@property(nonatomic, assign) BOOL isFullScreen;
//初始化URL
-(instancetype)initWithUrl:(NSString *)url;

-(void)assetWithUrl;

@end


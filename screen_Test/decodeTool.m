//
//  decodeTool.m
//  m3u8Player
//
//  Created by 缴天朔 on 2021/8/24.
//

#import "decodeTool.h"
#import "M3U8Handler.h"
#import "M3U8VideoDownLoader.h"
#import "M3U8SegmentModel.h"

@interface decodeTool()<M3U8HandlerDelegate,M3U8VideoDownLoaderDelegate>

//解码器
@property(nonatomic, strong) M3U8Handler *handler;

//下载器
@property(nonatomic, strong) M3U8VideoDownLoader *downLoader;

//播放链接
@property(nonatomic,copy) NSString *playUrl;

//定时解码的定时器
@property(nonatomic,strong) NSTimer *decodeTimer;

//标记第一次是否已经创建M3U8
@property(nonatomic,assign) BOOL isM3U8;

@end

@implementation decodeTool

-(instancetype)init{
    self = [super init];
    if (self) {
        //
    }
    return self;
}

/**
 处理M3U8链接
 */
-(void)handleM3U8Url:(NSString *)urlStr{
    //清除缓存
//    [self.downLoader deleteCache];
    [self.handler praseUrl:urlStr];
    self.playUrl = urlStr;
    self.isM3U8 = NO;
}

#pragma mark - M3U8链接解析失败
-(void)praseM3U8Failed:(M3U8Handler *)handler{
    [self.delegate decodeFail];
}

#pragma mark - M3U8链接解析成功
-(void)praseM3U8Finished:(M3U8Handler *)handler{
    //从这里获取解析的TS片段数据
    //解析成功后开始下载
    self.downLoader.keyUrl = handler.keyUrl;
    self.downLoader.playlist = handler.playList;
    self.downLoader.oriM3U8Str = handler.oriM3U8Str;
    [self.downLoader startDownLoadVideo];
    
    //解析成功后开启定时器，定时解析和请求播放数据
    [self openDecodeTimer];
}

#pragma mark - 开启循环解码定时器
-(void)openDecodeTimer{
    if (_decodeTimer == nil) {
        NSLog(@"循环解码定时器已经开启");
        //分析定时器的循环时间，这里取一个M3U8时间的一半
        __block NSTimeInterval time = 0;
        [self.downLoader.playlist.segmentArray enumerateObjectsUsingBlock:^(M3U8SegmentModel  *obj, NSUInteger idx, BOOL * _Nonnull stop) {
            time += obj.duration;
        }];
        
//        time /= self.downLoader.playlist.segmentArray.count;
        time = 30;
        _decodeTimer = [NSTimer scheduledTimerWithTimeInterval:time target:self selector:@selector(circleDecode) userInfo:nil repeats:YES];
    }else{
        return;
    }
}

#pragma mark - 循环解码
-(void)circleDecode{
//    [self.handler praseUrl:self.playUrl];
}

#pragma mark - 数据下载成功
-(void)videoDownLoaderFinished:(M3U8VideoDownLoader *)videoDownloader{
    NSLog(@"数据下载成功");
    
    //文件创建成功开始播放，这里需要建立本地HTTP服务器
    [self.delegate decodeSuccess];
}

#pragma mark - 数据下载失败
-(void)videoDownLoaderFailed:(M3U8VideoDownLoader *)videoDownloader{
    NSLog(@"数据下载失败");
//    [self.delegate decodeFail];
}

#pragma mark - getter
-(M3U8Handler *)handler{
    if (_handler == nil) {
        _handler = [[M3U8Handler alloc] init];
        _handler.delegate = self;
    }
    return _handler;
}

-(M3U8VideoDownLoader *)downLoader{
    if (_downLoader == nil) {
        _downLoader = [[M3U8VideoDownLoader alloc] init];
        _downLoader.delegate = self;
    }
    return _downLoader;
}



@end

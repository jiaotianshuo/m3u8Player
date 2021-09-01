//
//  M3u8ResourceLoader.m
//  m3u8Player
//
//  Created by 缴天朔 on 2021/8/17.
//

#import "M3u8ResourceLoader.h"
#import <UIKit/UIKit.h>

@interface M3u8ResourceLoader(){
    NSString *m3u8_url_vir;
    NSString *m3u8_url;
}

@end

@implementation M3u8ResourceLoader

+(instancetype)allocWithZone:(struct _NSZone *)zone{
    return [M3u8ResourceLoader shared];
}

-(instancetype)copyWitjZone:(NSZone *)zone{
    return [M3u8ResourceLoader shared];
}

-(instancetype)mutableCopyWithZone:(NSZone *)zone{
    return [M3u8ResourceLoader shared];
}

+(M3u8ResourceLoader *)shared{
    static M3u8ResourceLoader *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[super allocWithZone:nil] init];
    });
    return instance;
}

-(M3u8ResourceLoader *)init{
    self = [super init];
    m3u8_url_vir = @"m3u8Scheme://abcd.m3u8";
    return self;
}

/**
 拦截代理方法
 true表示：系统暂时不要播放，等待通知，才可以继续（相当于系统进程被阻断，直到收到了某些消息，才能继续运行）
 false表示：直接播放，不需要等待
 */
-(BOOL)resourceLoader:(AVAssetResourceLoader *)resourceLoader shouldWaitForLoadingOfRequestedResource:(AVAssetResourceLoadingRequest *)loadingRequest{
    //获取到拦截的链接url

//    NSLog(@"------resourceLoader------");
    NSString *url = [[[loadingRequest request] URL] absoluteString];
    
//    NSLog(@"url: %@",url);
    
    if ([url isEqualToString: m3u8_url_vir]) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            NSData *data = [self M3u8Request: self.m3u8Str];
            if (data) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSString *m3u8String = [[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding];

//                    NSLog(@"m3u8String: %@",m3u8String);
                    
                    NSData *data = [m3u8String dataUsingEncoding: NSUTF8StringEncoding];
                    [[loadingRequest dataRequest] respondWithData: data];
                    [loadingRequest finishLoading];
                });
            }
            else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self finishLoadingError: loadingRequest];
                });
            }
        });
        return true;
    }
    
    return false;
}


-(void)finishLoadingError:(AVAssetResourceLoadingRequest *)loadingRequest{
    [loadingRequest finishLoadingWithError:[[NSError alloc] initWithDomain:NSURLErrorDomain code:400 userInfo:nil]];
}

- (NSData *)M3u8Request: (NSString *)url {
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    static NSData *result = NULL;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        result = [url dataUsingEncoding: NSUTF8StringEncoding];
        dispatch_semaphore_signal(semaphore);
    });
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    return result;
}

- (AVPlayerItem *)playItemWith: (NSString *)url {
    m3u8_url = url;
    AVURLAsset *urlAsset = [[AVURLAsset alloc] initWithURL: [[NSURL alloc] initWithString: m3u8_url_vir] options: nil];
    [[urlAsset resourceLoader] setDelegate:self queue: dispatch_get_main_queue()];
    AVPlayerItem *item = [[AVPlayerItem alloc] initWithAsset: urlAsset];
    [item setCanUseNetworkResourcesForLiveStreamingWhilePaused: YES];
    return item;
}


@end

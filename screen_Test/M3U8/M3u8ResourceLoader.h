//
//  M3u8ResourceLoader.h
//  m3u8Player
//
//  Created by 缴天朔 on 2021/8/17.
//

#import <Foundation/Foundation.h>
#import <AVKit/AVKit.h>
#import <AVFoundation/AVAssetResourceLoader.h>
NS_ASSUME_NONNULL_BEGIN

@interface M3u8ResourceLoader : NSObject<AVAssetResourceLoaderDelegate>

@property(nonatomic,strong) NSString *m3u8Str;

+(M3u8ResourceLoader *)shared;

-(AVPlayerItem *)playItemWith:(NSString *)url;

@end

NS_ASSUME_NONNULL_END

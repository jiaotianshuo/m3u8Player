//
//  M3U8Handler.h
//  m3u8Player
//
//  Created by 缴天朔 on 2021/8/17.
//

#import <Foundation/Foundation.h>
 
#import "M3U8Playlist.h"
 
@class M3U8Handler;
 
@protocol M3U8HandlerDelegate <NSObject>
 
/**
 * 解析M3U8连接失败
 */
- (void)praseM3U8Finished:(M3U8Handler *)handler;
 
/**
 * 解析M3U8成功
 */
- (void)praseM3U8Failed:(M3U8Handler *)handler;
 
@end
 
@interface M3U8Handler : NSObject
 
/**
 * 解码M3U8
 */
- (void)praseUrl:(NSString *)urlStr;
 
/**
 * 传输成功或者失败的代理
 */
@property (weak, nonatomic)id <M3U8HandlerDelegate> delegate;
 
/**
 * 存储TS片段的数组
 */
@property (strong, nonatomic) NSMutableArray *segmentArray;
 
/**
 * 打包获取的TS片段
 */
@property (strong, nonatomic) M3U8Playlist *playList;
 
/**
 * 存储原始的M3U8数据
 */
@property (copy, nonatomic) NSString *oriM3U8Str;

/**
 * 存储加密 key 链接
 */
@property (strong,nonatomic) NSString *keyUrl;
 
@end



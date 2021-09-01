//
//  M3U8VideoDownLoader.h
//  m3u8Player
//
//  Created by 缴天朔 on 2021/8/18.
//

#import <Foundation/Foundation.h>
#import "M3U8Playlist.h"
NS_ASSUME_NONNULL_BEGIN

@class M3U8VideoDownLoader;

@protocol M3U8VideoDownLoaderDelegate <NSObject>
/**
 下载成功
 */
-(void)videoDownLoaderFinished:(M3U8VideoDownLoader *)videoDownloader;

/**
 下载失败
 */
-(void)videoDownLoaderFailed:(M3U8VideoDownLoader *)videoDownloader;

@end

@interface M3U8VideoDownLoader : NSObject

@property(strong, nonatomic)M3U8Playlist *playlist;

/**
 记录原始M3U8内容
 */
@property(nonatomic,copy) NSString *oriM3U8Str;

/**
 * 记录加密链接 key
 */
@property(nonatomic,strong) NSString *keyUrl;


/**
 下载TS数据
 */
-(void)startDownLoadVideo;


/**
 存储正在下载的数组
 */
@property(nonatomic ,strong) NSMutableArray *downLoadArray;

/**
 下载成功或者失败的代理
 */
@property(nonatomic,weak) id<M3U8VideoDownLoaderDelegate> delegate;

/**
 创建M3U8文件
 */
-(void)createLocalM3U8File;

-(void)deleteCache;

@end

NS_ASSUME_NONNULL_END

//
//  SegmentDownloader.h
//  m3u8Player
//
//  Created by 缴天朔 on 2021/8/20.
//
#pragma mark - TS下载器

#import <Foundation/Foundation.h>

@class SegmentDownloader;

NS_ASSUME_NONNULL_BEGIN

@protocol SegmentDownloaderDelegate <NSObject>

/**
 下载成功
 */
- (void)segmentDownloadFinished:(SegmentDownloader *)downloader;

/**
 下载失败
 */
- (void)segmentDownloadFailed:(SegmentDownloader *)downloader;

/**
 监听进度
 */
-(void)segmentProgress:(SegmentDownloader *)downloader TotalUnitCount:(int64_t)totalUnitCount completeUnitCount:(int64_t) completeUnitCount;

@end


@interface SegmentDownloader : NSObject

@property(nonatomic,copy) NSString *fileName;

@property(nonatomic,copy) NSString *filePath;

@property(nonatomic,copy) NSString *downloadUrl;

@property(nonatomic,assign) NSInteger duration;

@property(assign,nonatomic) NSInteger index;

@property(assign, nonatomic) BOOL isDownloading;


/**
 标记这个下载器是否在下载
 */
@property(assign,nonatomic) BOOL flag;

/**
 初始化TS下载器
 */
-(instancetype) initWithUrl:(NSString *)url andFilePath:(NSString *)path andFileName:(NSString *)fileName withDuration:(NSInteger)duration withIndex:(NSInteger)index withTotalCount:(NSInteger)totalCount;

/**
 传递数据下载成功或者失败的代理
 */
@property(nonatomic,strong) id<SegmentDownloaderDelegate> delegate;

/**
 开始下载
 */
-(void)start;

@end

NS_ASSUME_NONNULL_END

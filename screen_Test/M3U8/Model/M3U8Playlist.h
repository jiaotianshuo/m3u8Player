//
//  M3U8Playlist.h
//  m3u8Player
//
//  Created by 缴天朔 on 2021/8/17.
//
/**
 存储TS文件的数据模型
 */
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface M3U8Playlist : NSObject

@property(nonatomic, strong) NSArray *segmentArray; //TS列表

@property(copy, nonatomic) NSString *uuid;

@property(assign, nonatomic) NSInteger length; //长度

/**
 设置
 */
-(void)initwithSegmentArray:(NSArray *)array;

@end

NS_ASSUME_NONNULL_END

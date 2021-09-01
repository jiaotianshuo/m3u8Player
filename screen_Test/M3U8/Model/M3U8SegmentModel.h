//
//  M3U8SegmentModel.h
//  m3u8Player
//
//  Created by 缴天朔 on 2021/8/17.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface M3U8SegmentModel : NSObject

@property(nonatomic,assign) NSInteger duration; //TS链接时长

@property(nonatomic,copy) NSString *locationUrl; //TS链接

@property(nonatomic,assign) NSInteger index;

@end

NS_ASSUME_NONNULL_END

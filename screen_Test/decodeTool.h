//
//  decodeTool.h
//  m3u8Player
//
//  Created by 缴天朔 on 2021/8/24.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@protocol DecodeToolDelegate <NSObject>

-(void)decodeSuccess;
-(void)decodeFail;

@end

@interface decodeTool : NSObject

-(void)handleM3U8Url:(NSString *)url;

@property(nonatomic,weak) id <DecodeToolDelegate> delegate;

@end

NS_ASSUME_NONNULL_END

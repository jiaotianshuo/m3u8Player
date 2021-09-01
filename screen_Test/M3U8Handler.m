//
//  M3U8Handler.m
//  m3u8Player
//
//  Created by 缴天朔 on 2021/8/17.
//
#pragma mark - 解码m3u8链接
/**
 解码这一步就做一件事情，拿到播放链接，读取M3U8索引文件，解析出每一个TS文件的下载地址和时长，封装到Model中，供后面使用
 */
#import "M3U8Handler.h"
#import "M3U8SegmentModel.h"

@implementation M3U8Handler

#pragma mark - 解析M3U8链接
-(void)praseUrl:(NSString *)urlStr{
    //判断是否为HTTP链接
    if(!([urlStr hasPrefix:@"http://"] || [urlStr hasPrefix:@"https://"])){
        if(self.delegate != nil && [self.delegate respondsToSelector:@selector(praseM3U8Failed:)]){
            [self.delegate praseM3U8Failed:self];
        }
        return;
    }
    
    //解析出M3U8
    NSError *error = nil;
    NSStringEncoding encoding;
    
    //这一步耗时，在子进程中操作
    NSString *m3u8Url = [[NSString alloc] initWithContentsOfURL:[NSURL URLWithString:urlStr] usedEncoding:&encoding error:&error];
    self.oriM3U8Str = m3u8Url;
    
    
    if(m3u8Url == nil){
        if(!([urlStr hasPrefix:@"http://"] || [urlStr hasPrefix:@"https://"])){
            if(self.delegate != nil && [self.delegate respondsToSelector:@selector(praseM3U8Failed:)]){
                [self.delegate praseM3U8Failed:self];
            }
        }
        return;
    }

    //判断是否有加密 key
    NSRange keyRange = [m3u8Url rangeOfString:@"#EXT-X-KEY:"];
    if (keyRange.location != NSNotFound) {
        //说明文件进行了加密
        NSRange methodRange = [m3u8Url rangeOfString:@"METHOD="];
        NSRange commonRange = [m3u8Url rangeOfString:@","];
        NSString *method = [m3u8Url substringWithRange:NSMakeRange(methodRange.location + [@"METHOD=" length], commonRange.location - (methodRange.location + [@"METHOD=" length]) )];
        
        if ([method isEqualToString:@"AES-128"]) {
            NSRange urlRange = [m3u8Url rangeOfString:@"URI=\""];
            NSRange endRange = [m3u8Url rangeOfString:@"\"\n"];
            NSString *keyUrl = [m3u8Url substringWithRange:NSMakeRange(urlRange.location + [@"URI=\"" length], endRange.location - (urlRange.location + [@"URI=\"" length]) )];
            self.keyUrl = keyUrl;
        }
    }
    
    //解析TS文件
    NSRange segmentRange = [m3u8Url rangeOfString:@"#EXTINF:"];

    //TS文件解析失败
    if(segmentRange.location == NSNotFound){
        if(self.delegate != nil && [self.delegate respondsToSelector:@selector(praseM3U8Failed:)]){
            [self.delegate praseM3U8Failed:self];
        }
        return;
    }
    //清空TS存储列表
    if(self.segmentArray.count > 0){
        [self.segmentArray removeAllObjects];
    }
    
    m3u8Url = [m3u8Url substringFromIndex:(segmentRange.location - [@"#EXTINF:" length])];
    segmentRange = [m3u8Url rangeOfString:@"#EXTINF:"];
    //逐个解析TS文件，并存储
    while (segmentRange.location != NSNotFound) {
        
        //声明一个model文件存储TS文件链接和时长的model
        M3U8SegmentModel *model = [[M3U8SegmentModel alloc] init];

        //读取TS片段时长
        NSRange commaRange = [m3u8Url rangeOfString:@","];

        NSString* value = [m3u8Url substringWithRange:NSMakeRange(segmentRange.location + [@"#EXTINF:" length], commaRange.location -(segmentRange.location + [@"#EXTINF:" length]))];
        model.duration = [value integerValue];

        
        //截取M3U8
        m3u8Url = [m3u8Url substringFromIndex:commaRange.location];
        
        //获取TS下载链接，这需要根据具体的M3U8获取链接
        NSRange linkRangeBegin = [m3u8Url rangeOfString:@","];
        NSRange linkRangeEnd = [m3u8Url rangeOfString:@".ts"];
        NSString* linkUrl = [m3u8Url substringWithRange:NSMakeRange(linkRangeBegin.location + 2, (linkRangeEnd.location + 3) - (linkRangeBegin.location + 2))];
        model.locationUrl = linkUrl;
        [self.segmentArray addObject:model];
        
        //截取m3u8
        m3u8Url = [m3u8Url substringFromIndex:(linkRangeEnd.location + 3)];
        segmentRange = [m3u8Url rangeOfString:@"#EXTINF:"];
    }
    
    
    //已经截取了所有TS片段，继续打包数据
    [self.playList initwithSegmentArray:self.segmentArray];
    self.playList.uuid = @"movie1";
    
    //到此数据TS解析成功，通过代理发送消息成功
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(praseM3U8Finished:)]) {
        [self.delegate praseM3U8Finished:self];
    }
}

#pragma mark - getter

-(NSMutableArray *)segmentArray{
    if(_segmentArray == nil){
        _segmentArray = [[NSMutableArray alloc] init];
    }
    return _segmentArray;
}

-(M3U8Playlist *)playList{
    if (_playList == nil) {
        _playList = [[M3U8Playlist alloc] init];
    }
    return _playList;
}


@end

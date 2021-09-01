//
//  M3U8Playlist.m
//  m3u8Player
//
//  Created by 缴天朔 on 2021/8/17.
//

#import "M3U8Playlist.h"

@implementation M3U8Playlist

-(void)initwithSegmentArray:(NSArray *)array{
    self.segmentArray = array;
    self.length = array.count;
}

@end

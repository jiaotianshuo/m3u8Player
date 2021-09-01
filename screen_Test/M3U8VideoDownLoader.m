//
//  M3U8VideoDownLoader.m
//  m3u8Player
//
//  Created by 缴天朔 on 2021/8/18.
//

#import "M3U8VideoDownLoader.h"
#import "M3U8SegmentModel.h"
#import "SegmentDownloader.h"

@interface M3U8VideoDownLoader() <SegmentDownloaderDelegate>

@property (assign, nonatomic) NSInteger index;//记录一共多少TS文件

@property (strong, nonatomic) NSMutableArray *downloadUrlArray;//记录所有的下载链接

@property (assign, nonatomic) NSInteger sIndex;//记录下载成功的文件的数量（以3为基数）

@property (strong, nonatomic) NSMutableArray *downloadingArray;

@end

@implementation M3U8VideoDownLoader

-(instancetype)init{
    self = [super init];
    if(self){
        self.index = 0;
        self.sIndex = 0;
    }
    return self;
}

#pragma mark - 下载TS数据
-(void)startDownLoadVideo{
    
    //首先检查是否存在路径
    [self checkDirectoryIsCreateM3U8:NO];
    __weak typeof (self) weakSelf = self;
    
    NSInteger totalCount = self.playlist.segmentArray.count - 1;
    
    //将解析的数据打包成一个个独立的下载器装进数组
    [self.playlist.segmentArray enumerateObjectsUsingBlock:^(M3U8SegmentModel *obj, NSUInteger idx, BOOL * _Nonnull stop){
        //检查此对象是否存在
        __block BOOL isE = NO;
        [weakSelf.downloadUrlArray enumerateObjectsUsingBlock:^(NSString *inObj, NSUInteger inIdx, BOOL * _Nonnull inStop) {
            if ([inObj isEqualToString:obj.locationUrl]) {
                //已经存在
                isE = YES;
                *inStop = YES;
            }else{
                //不存在
                isE = NO;
            }
        }];
        
        if (isE) {
            //存在
        }else{
            //不存在
            NSString *fileName = [NSString stringWithFormat:@"movie%ld.ts",weakSelf.index];
            
            NSURL *url = [[NSURL alloc] initWithString:obj.locationUrl];
            
            SegmentDownloader *sgDownloader = [[SegmentDownloader alloc] initWithUrl:url andFilePath:self.playlist.uuid andFileName:fileName withDuration:obj.duration withIndex:weakSelf.index withTotalCount:totalCount];
            sgDownloader.delegate = weakSelf;
            [weakSelf.downLoadArray addObject:sgDownloader];
            [weakSelf.downloadUrlArray addObject:obj.locationUrl];
            weakSelf.index ++;
        }
    }];
    
    //根据新的数据更改playlist
    __block NSMutableArray *newPlaylistArray = [[NSMutableArray alloc] init];
    [self.downLoadArray enumerateObjectsUsingBlock:^(SegmentDownloader *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        M3U8SegmentModel *model = [[M3U8SegmentModel alloc] init];
        model.duration = obj.duration;
        model.locationUrl = obj.fileName;
        model.index = obj.index;
        [newPlaylistArray addObject:model];
    }];
    
    if (newPlaylistArray.count > 0) {
        self.playlist.segmentArray = newPlaylistArray;
    }
    
    //打包下载key
    SegmentDownloader *keyDownloader = [[SegmentDownloader alloc] initWithUrl:self.keyUrl andFilePath:nil andFileName:@"key.key" withDuration:0 withIndex:0 withTotalCount:0];
    [keyDownloader start];
    
    
    //记录下载的数量,并用于加入新的下载器
    self.sIndex = 0;
    for(int i = 0; i < 8; i ++){
        SegmentDownloader *obj = [self.downLoadArray objectAtIndex:i];
        self.sIndex ++;
        [obj start];
    }
}

#pragma mark - 检查路径
-(void)checkDirectoryIsCreateM3U8:(BOOL)isC{
    //创建缓存路径
    NSString *saveTo = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];

    NSFileManager *fm = [[NSFileManager alloc] init];
    
    //路径不存在创建一个
    BOOL isD = [fm fileExistsAtPath:saveTo];
    if (isD) {
        //存在
    }else{
        //不存在
        BOOL isS = [fm createDirectoryAtPath:saveTo withIntermediateDirectories:YES attributes:nil error:nil];
        if (isS) {
            NSLog(@"路径不存在创建成功");
        }else{
            NSLog(@"路径不存在创建失败");
        }
    }
}


#pragma mark - 数据下载失败
- (void)segmentDownloadFailed:(nonnull SegmentDownloader *)downloader {
    [self.delegate videoDownLoaderFailed:self];
    [downloader start];
}

#pragma mark - 数据下载成功
- (void)segmentDownloadFinished:(nonnull SegmentDownloader *)downloader {
    //加入新的下载器po
    if(self.sIndex < self.downLoadArray.count){
        SegmentDownloader *newSegmentDownloader = [self.downLoadArray objectAtIndex:self.sIndex];
        self.sIndex ++;
        [newSegmentDownloader start];
    }
    
    if (downloader.index == self.playlist.segmentArray.count - 1) {
        //每次下载完成后都要创建M3U8文件
        [self createLocalM3U8File];
        //证明所有的TS已经下载完成
        NSLog(@"所有文件已经成功下载");
        [self.delegate videoDownLoaderFinished:self];
    }
}

#pragma mark - 进度更新
- (void)segmentProgress:(nonnull SegmentDownloader *)downloader TotalUnitCount:(int64_t)totalUnitCount completeUnitCount:(int64_t)completeUnitCount {
    NSLog(@"下载进度：%f",completeUnitCount * 1.0 / totalUnitCount *1.0);
}

#pragma mark - 创建M3U8文件
-(void)createLocalM3U8File{
    [self checkDirectoryIsCreateM3U8:YES];
    
    NSString *path = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"movie.m3u8"];
    
    //拼接M3U8链接头部内容
    NSString *header = [NSString stringWithFormat:@"#EXTM3U\n#EXT-X-VERSION:3\n#EXT-X-TARGETDURATION:6\n#EXT-X-PLAYLIST-TYPE:VOD\n#EXT-X-MEDIA-SEQUENCE:0\n#EXT-X-KEY:METHOD=AES-128,URI=\"key.key\"\n"];
    //填充M3U8数据
    __block NSString *tsStr = [[NSString alloc] init];
    [self.playlist.segmentArray enumerateObjectsUsingBlock:^(M3U8SegmentModel *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *fileName = [NSString stringWithFormat:@"movie%ld.ts",obj.index];
        
        //文件时长
        NSString *length = [NSString stringWithFormat:@"#EXTINF:%ld,\n",obj.duration];
        
        //拼接M3u8
        tsStr = [tsStr stringByAppendingString:[NSString stringWithFormat:@"%@%@\n",length,fileName]];
    }];
    
    //m3u8头部和中间拼接，到此我们完成新的M3U8链接拼接
    header = [header stringByAppendingString:tsStr];
    
    header = [header stringByAppendingString:@"#EXT-X-ENDLIST"];
    
    //拼接完成，存储到本地
    NSMutableData *writer = [[NSMutableData alloc] init];
    NSFileManager *fm = [[NSFileManager alloc] init];
    
    //判断m3u8是否存在，已经存在就不再重新创建
    if ([fm fileExistsAtPath:path isDirectory:nil]) {
        //存在这个链接
        NSLog(@"存在这个链接");
    }else{
        //不存在这个链接
        NSString *saveTo = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
        BOOL isS = [fm createDirectoryAtPath:saveTo withIntermediateDirectories:YES attributes:nil error:nil];
        if (isS) {
            //成功
            NSLog(@"M3U8数据保存成功");
        }else{
            //失败
            NSLog(@"M3U8数据保存失败");
        }
    }
        [writer appendData:[header dataUsingEncoding:NSUTF8StringEncoding]];
        BOOL bSucc = [writer writeToFile:path atomically:YES];
        if (bSucc) {
            //成功
            NSLog(@"M3U8数据保存成功");
        }else{
            //失败
            NSLog(@"M3U8数据保存失败");
        }
//    NSLog(@"新数据\n%@",header);
}

#pragma mark - 删除缓存文件
-(void)deleteCache{
    //获取缓存路径
    NSString *saveTo = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    
    NSFileManager *fm = [[NSFileManager alloc] init];
    
    //路径不存在就创建一个
    BOOL isD = [fm fileExistsAtPath:saveTo];
    if (isD) {
        //存在
        NSArray *deleteArray = [fm subpathsAtPath:saveTo];
        //清空当前的M3U8文件
        [deleteArray enumerateObjectsUsingBlock:^(NSString *obj, NSUInteger idx, BOOL * _Nonnull stop) {
            BOOL isS = [fm removeItemAtPath:[saveTo stringByAppendingPathComponent:[NSString stringWithFormat:@"%@", obj]] error:nil];
            if (isS) {
                NSLog(@"多余路径存在清空成功%@",obj);
            }else{
                NSLog(@"多余路径存在清空失败%@",obj);
            }
        }];
        
    }
}

#pragma mark - getter
-(NSMutableArray *)downLoadArray{
    if (_downLoadArray == nil) {
        _downLoadArray = [[NSMutableArray alloc] init];
    }
    return _downLoadArray;
}

-(NSMutableArray *)downloadUrlArray{
    if (_downloadUrlArray == nil) {
        _downloadUrlArray = [[NSMutableArray alloc] init];
    }
    return _downloadUrlArray;
}

-(NSMutableArray *)downloadingArray{
    if (_downloadingArray == nil) {
        _downloadingArray = [[NSMutableArray alloc] init];
    }
    return _downloadingArray;
}

@end

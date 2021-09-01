//
//  SegmentDownloader.m
//  m3u8Player
//
//  Created by 缴天朔 on 2021/8/20.
//

#import "SegmentDownloader.h"


@interface SegmentDownloader ()<NSURLSessionDelegate,NSURLSessionDataDelegate>
@property(nonatomic,strong) NSURL *URL;
@property(nonatomic,strong) NSURLSession *session;
@property(nonatomic,strong) NSURLSessionTask *task;
@property(nonatomic,assign) long long offset;
@property(nonatomic,assign) long long length;
@property(assign,nonatomic) NSInteger totalCount;

//@property(strong,nonatomic) AFHTTPRequestSerializer *serializer;
//
//@property(strong,nonatomic) AFURLSessionManager *downLoadSession;

@end


@implementation SegmentDownloader

#pragma mark - 初始化TS下载器
-(instancetype)initWithUrl:(NSString *)url andFilePath:(NSString *)path andFileName:(NSString *)fileName withDuration:(NSInteger)duration withIndex:(NSInteger)index withTotalCount:(NSInteger)totalCount{
    self = [super init];
    if(self){
        self.downloadUrl = url;
        self.filePath = path;
        self.fileName = fileName;
        self.duration = duration;
        self.index = index;
        self.totalCount = totalCount;
    }
    return  self;
}


#pragma mark - 开始下载

-(BOOL)checkIsDownLoad{
    //获取缓存路径
    /**
     ios 会为每个app生成一个私有目录，并随机生成一个数字字母字符串作为目录名，每次app启动，这个字符串不同
     通常可以使用Documents目录对数据进行持久化保存，Documents目录可以下面这个函数得到
     */
    NSString *caches = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
//    NSString *saveTo = [[NSString alloc] initWithString: pathPrefix];
    NSFileManager *fm = [NSFileManager defaultManager];
    
    __block BOOL isE = NO;
    //获取缓存路径下所有文件名
    NSArray *subFileArray = [fm subpathsAtPath:caches];
    [subFileArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        //判断是否已经缓存了此文件
        if([self.fileName isEqualToString:[NSString stringWithFormat:@"%@",obj]]){
            //已经下载
            isE = YES;
            *stop = YES;
        }else{
            //没有
            isE = NO;
        }
    }];
    return isE;
}

/**
 开始下载
 */
-(void) start{
    //标记正在下载
    self.isDownloading = YES;
    
    //检查是否已经下载
    if ([self checkIsDownLoad]) {
        NSString *file = self.fileName;
        NSLog(@"-----file: %@,本地已经下载过",file);
        //下载了
        [self.delegate segmentDownloadFinished:self];
        return;
    }else{
        //没下载
    }

    
    NSURL *url = [[NSURL alloc] init];

    NSString *downloadUrl = [NSString stringWithFormat:@"%@",self.downloadUrl];
    
    url = [NSURL URLWithString:downloadUrl];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:30.0];
    
    request.timeoutInterval = 30;
    
    //创建会话对象：默认在子线程中进行
    NSURLSession *session = [NSURLSession sharedSession];
    
    NSLog(@"currentThread: %@",[NSThread currentThread]);
    
    //创建下载请求task
    NSURLSessionDownloadTask *downloadTask = [session downloadTaskWithRequest:request completionHandler:^(NSURL * _Nullable location, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        
        NSLog(@"download currentThread: %@",[NSThread currentThread]);
        
        NSString *caches = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
        //下载结束
        NSString *file = [caches stringByAppendingPathComponent:self.fileName];
        
        NSLog(@"-----file: %@",file);
        
        if(location == nil){
            [self.delegate segmentDownloadFailed:self];
            return;
        }
        [[NSFileManager defaultManager] moveItemAtPath:location.path toPath:file error:nil];
        
        [self.delegate segmentDownloadFinished:self];
    }];
    //发送请求
    [downloadTask resume];
}
@end

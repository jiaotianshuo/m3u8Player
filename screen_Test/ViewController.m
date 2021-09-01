//
//  ViewController.m
//  screen_Test
//
//  Created by 缴天朔 on 2021/8/31.
//

#import "ViewController.h"
#import "playView.h"
#import "BottomControlView.h"

@interface ViewController ()

@property(nonatomic, strong) playView *playView;

@property(nonatomic, strong) BottomControlView *bottomView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.playView = [[playView alloc] initWithUrl:@"https://video.buycar5.cn/20200812/LidUUGxX/1000kb/hls/index.m3u8"];
    
    self.playView.backgroundColor = [UIColor blackColor];
    
    [self.view addSubview:self.playView];
    
    [self.playView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.left.mas_equalTo(self.view);
        make.top.mas_equalTo(self.view);
        make.height.mas_equalTo(@250);
    }];

}

@end

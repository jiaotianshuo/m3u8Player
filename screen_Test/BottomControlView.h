//
//  BottomControlView.h
//  m3u8Player
//
//  Created by 缴天朔 on 2021/8/30.
//
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <Masonry.h>

@class BottomControlView;

@protocol BottomControlViewDelegate <NSObject>
@required
/**
 点击UISlider获取点击点
 
 @param controlView  控制视图
 @param value  当前点击点
 */
-(void)controlView:(BottomControlView *) controlView SliderLocationWithCurrentValue:(CGFloat)value;

/**
 拖拽UISlider的时间响应代理方法
 
 @param controlView  控制视图
 @param slider  当前点击点
 */
-(void)controlView:(BottomControlView *)controlView draggedPositionWithSlider:(UISlider *)slider;

/**
 点击放大按钮的响应时间
 
 @param controlView 控制截图
 @param button 全屏按钮
 */
-(void)controlView:(BottomControlView *)controlView withLargeButton:(UIButton *)button;
@end


@interface BottomControlView : UIView

//全屏按钮
@property(nonatomic, strong) UIButton *largeButton;
//进度条当前值
@property(nonatomic, assign) CGFloat currentValue;
//最小值
@property (nonatomic,assign) CGFloat minValue;
//最大值
@property (nonatomic,assign) CGFloat maxValue;
//当前时间
@property(nonatomic, assign) NSString *currentTime;
//总时间
@property(nonatomic, assign) NSString *totalTime;
//缓存条当前值
@property (nonatomic,assign) CGFloat bufferValue;
//UISlider手势
@property(nonatomic, strong) UITapGestureRecognizer *tapRecongnizer;
//代理方法
@property(nonatomic, weak) id<BottomControlViewDelegate>delegate;

@end



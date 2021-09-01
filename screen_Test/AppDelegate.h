//
//  AppDelegate.h
//  screen_Test
//
//  Created by 缴天朔 on 2021/8/31.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (readonly, strong) NSPersistentContainer *persistentContainer;

@property (nonatomic, strong) UIWindow *window;

- (void)saveContext;


@end


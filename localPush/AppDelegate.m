//
//  AppDelegate.m
//  localPush
//
//  Created by binsonchang on 2017/5/18.
//  Copyright © 2017年 tw.com.binson. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (void)registerUserNotificationSettingsForIOS80 {
    // iOS8.0 适配
    if ([[UIApplication sharedApplication] respondsToSelector:@selector(registerUserNotificationSettings:)]) {
        // categories: 推送消息的附加操作，可以为nil,此时值显示消息，如果不为空，可以在推送消息的后面增加几个按钮（如同意、不同意）

        UIMutableUserNotificationCategory *category = [[UIMutableUserNotificationCategory alloc] init];
        category.identifier = @"choose";

        // 同意
        UIMutableUserNotificationAction *action1 = [[UIMutableUserNotificationAction alloc] init];
        action1.identifier = @"yes";
        action1.title = @"同意";
        action1.activationMode = UIUserNotificationActivationModeForeground;  // 点击按钮是否进入前台
        action1.authenticationRequired = true;
        action1.destructive = false;

        // 不同意
        UIMutableUserNotificationAction *action2 = [[UIMutableUserNotificationAction alloc] init];
        action2.identifier = @"no";
        action2.title = @"不同意";
        action2.activationMode = UIUserNotificationActivationModeBackground;  // 后台模式，点击了按钮就完了
        action2.authenticationRequired = true;
        action2.destructive = true;
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 9.0) {
            action2.behavior = UIUserNotificationActionBehaviorTextInput;
            action2.parameters = @{UIUserNotificationTextInputActionButtonTitleKey: @"拒绝原因"};
        }


        [category setActions:@[action1, action2] forContext:UIUserNotificationActionContextDefault];


        NSSet<UIUserNotificationCategory *> *categories = [NSSet setWithObjects:category, nil];

        UIUserNotificationType types = UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert;
        UIUserNotificationSettings *notificationSettings = [UIUserNotificationSettings settingsForTypes:types categories:categories];
        [[UIApplication sharedApplication] registerUserNotificationSettings:notificationSettings];
    }
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.

    if (launchOptions != nil) {
        UILocalNotification *localNotification = launchOptions[UIApplicationLaunchOptionsLocalNotificationKey];
        if (localNotification != nil) {
            // 程序完全退出状态下，点击推送通知后的业务处理
            // 如QQ会打开想对应的聊天窗口
            NSInteger applicationIconBadgeNumber = application.applicationIconBadgeNumber - 1;
            application.applicationIconBadgeNumber = applicationIconBadgeNumber >= 0 ? applicationIconBadgeNumber : 0;
        }
    }

    [self registerUserNotificationSettingsForIOS80];

    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
    application.applicationIconBadgeNumber = 0;
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
}


- (void)application:(UIApplication *)application didReceiveLocalNotification:(nonnull UILocalNotification *)notification {
    NSLog(@"%@", notification);

    // 处理点击通知后对应的业务
    UIApplicationState applicationState = [[UIApplication sharedApplication] applicationState];
    if (applicationState == UIApplicationStateActive) {     // 前台
        // 例如QQ会增加tabBar上的badgeValue未读数量
    } else if (applicationState == UIApplicationStateInactive) {// 从前台进入后台
        // 例如QQ会打开对应的聊天窗口
        NSInteger applicationIconBadgeNumber = application.applicationIconBadgeNumber - 1;
        application.applicationIconBadgeNumber = applicationIconBadgeNumber >= 0 ? applicationIconBadgeNumber : 0;
    }

    [application cancelLocalNotification:notification];
}

// 监听附加操作按钮
- (void)application:(UIApplication *)application handleActionWithIdentifier:(nullable NSString *)identifier forLocalNotification:(nonnull UILocalNotification *)notification completionHandler:(nonnull void (^)())completionHandler {
    NSLog(@"identifier:%@", identifier);
    completionHandler();
}

// 该方法在iOS9.0后调用，iOS9.0之前调用上面那个方法
- (void)application:(UIApplication *)app handleActionWithIdentifier:(nullable NSString *)identifier forLocalNotification:(nonnull UILocalNotification *)notification withResponseInfo:(nonnull NSDictionary *)responseInfo completionHandler:(nonnull void (^)())completionHandler {
    // ====identifier:no, content:{UIUserNotificationActionResponseTypedTextKey = "not agree";}
    NSLog(@"====identifier:%@, content:%@", identifier, responseInfo);
    completionHandler();
}


#pragma mark - Core Data stack

@synthesize persistentContainer = _persistentContainer;

- (NSPersistentContainer *)persistentContainer {
    // The persistent container for the application. This implementation creates and returns a container, having loaded the store for the application to it.
    @synchronized (self) {
        if (_persistentContainer == nil) {
            _persistentContainer = [[NSPersistentContainer alloc] initWithName:@"localPush"];
            [_persistentContainer loadPersistentStoresWithCompletionHandler:^(NSPersistentStoreDescription *storeDescription, NSError *error) {
                if (error != nil) {
                    // Replace this implementation with code to handle the error appropriately.
                    // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                    
                    /*
                     Typical reasons for an error here include:
                     * The parent directory does not exist, cannot be created, or disallows writing.
                     * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                     * The device is out of space.
                     * The store could not be migrated to the current model version.
                     Check the error message to determine what the actual problem was.
                    */
                    NSLog(@"Unresolved error %@, %@", error, error.userInfo);
                    abort();
                }
            }];
        }
    }
    
    return _persistentContainer;
}

#pragma mark - Core Data Saving support

- (void)saveContext {
    NSManagedObjectContext *context = self.persistentContainer.viewContext;
    NSError *error = nil;
    if ([context hasChanges] && ![context save:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, error.userInfo);
        abort();
    }
}

@end

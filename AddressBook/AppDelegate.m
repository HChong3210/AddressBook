//
//  AppDelegate.m
//  AddressBook
//
//  Created by HChong on 2017/4/23.
//  Copyright © 2017年 HChong. All rights reserved.
//

#import "AppDelegate.h"
#import <Contacts/Contacts.h>

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    [self addressBookEmpowerCheck];
    return YES;
}

- (void)addressBookEmpowerCheck {
    CNAuthorizationStatus status = [CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts];
    switch (status) {
        case CNAuthorizationStatusNotDetermined: {
            [[[CNContactStore alloc]init] requestAccessForEntityType:CNEntityTypeContacts completionHandler:^(BOOL granted, NSError * _Nullable error) {
                NSLog(@"还没问");
                if (granted) {
                    NSLog(@"点击了同意");
                } else {
                    NSLog(@"点击了拒绝");
                }
            }];
        }
            break;
        case CNAuthorizationStatusRestricted: {
            NSLog(@"未授权, 例如家长控制");
        }
            break;
        case CNAuthorizationStatusDenied: {
            NSLog(@"未授权, 用户拒绝所致");
        }
            break;
        case CNAuthorizationStatusAuthorized: {
            NSLog(@"已经授权");
        }
            break;
        default: {
        }
            break;
    }
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
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end

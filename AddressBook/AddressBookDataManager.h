//
//  AddressBookDataManager.h
//  AddressBook
//
//  Created by HChong on 2017/5/5.
//  Copyright © 2017年 HChong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AddressBookDataManager : NSObject

+ (void)checkAddressBookAuthorization:(void (^)(bool isAuthorized))block;
+ (NSDictionary *)getTitleAndData;
@end

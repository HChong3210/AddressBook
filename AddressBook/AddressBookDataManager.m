//
//  AddressBookDataManager.m
//  AddressBook
//
//  Created by HChong on 2017/5/5.
//  Copyright © 2017年 HChong. All rights reserved.
//

#import "AddressBookDataManager.h"
#import <AddressBook/AddressBook.h>
#import "AddressBookContact.h"
#import <UIKit/UIKit.h>

@implementation AddressBookDataManager


+ (NSDictionary *)getTitleAndData {
    NSDictionary *dic = [AddressBookDataManager dealDataWithArray:[AddressBookDataManager getAllContact]];
    return dic;
}

+ (NSArray *)getAllContact {
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:0];
    
    CFErrorRef *error = NULL;
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, error);
    
    CFIndex numberOfPeople = ABAddressBookGetPersonCount(addressBook);
    CFArrayRef people = ABAddressBookCopyArrayOfAllPeople(addressBook);
    if (numberOfPeople == 0) {
        CFRelease(people);
        CFRelease(addressBook);
        return @[];
    }
    for ( int i = 0; i < numberOfPeople; i++){
        AddressBookContact *contact = [[AddressBookContact alloc] init];
        
        ABRecordRef person = CFArrayGetValueAtIndex(people, i);
        
        //姓名
        NSString *firstName = (NSString *)CFBridgingRelease(ABRecordCopyValue(person, kABPersonFirstNameProperty));
        NSString *lastName = (NSString *)CFBridgingRelease(ABRecordCopyValue(person, kABPersonLastNameProperty));
        NSString *name = [NSString stringWithFormat:@"%@%@", [AddressBookDataManager strNoNull:lastName], [AddressBookDataManager strNoNull:firstName]];
        contact.name = name;
        
        //读取电话多值
        ABMultiValueRef phone = ABRecordCopyValue(person, kABPersonPhoneProperty);
        NSArray *arr = (NSArray *)CFBridgingRelease(ABMultiValueCopyArrayOfAllValues(phone));
        contact.phone = [AddressBookDataManager strNoNull:[AddressBookDataManager filterPhoneFormate:[arr lastObject]]];
        
        if (contact.phone.length > 0) {
            [array addObject:contact];
        }
    }
    CFRelease(people);
    CFRelease(addressBook);
    return array;
}

+ (void)checkAddressBookAuthorization:(void (^)(bool isAuthorized))block {
    ABAddressBookRef addressBookRef =  ABAddressBookCreateWithOptions(NULL, NULL);
    switch (ABAddressBookGetAuthorizationStatus()) {
        case kABAuthorizationStatusNotDetermined: {
            NSLog(@"未询问用户是否授权");
            ABAddressBookRequestAccessWithCompletion(addressBookRef, ^(bool granted, CFErrorRef error) {
                if (granted) {
                    NSLog(@"成功");
                    block(YES);
                } else {
                    block(NO);
                }
            });
        } break;
        case kABAuthorizationStatusAuthorized: {
            NSLog(@"同意授权通讯录");
            block(YES);
        } break;
        case kABAuthorizationStatusDenied: {
            block(NO);
            NSLog(@"未授权，用户拒绝造成的");
        } break;
        case kABAuthorizationStatusRestricted: {
            block(NO);
            NSLog(@"未授权，例如家长控制");
        } break;
        default: {
        } break;
    }
}

+ (NSString *)returnFirstWordWithString:(NSString *)str {
    NSMutableString * mutStr = [NSMutableString stringWithString:str];
    
    //将mutStr中的汉字转化为带音标的拼音（如果是汉字就转换，如果不是则保持原样）
    CFStringTransform((__bridge CFMutableStringRef)mutStr, NULL, kCFStringTransformMandarinLatin, NO);
    //将带有音标的拼音转换成不带音标的拼音（这一步是从上一步的基础上来的，所以这两句话一句也不能少）
    CFStringTransform((__bridge CFMutableStringRef)mutStr, NULL, kCFStringTransformStripCombiningMarks, NO);
    if (mutStr.length > 0) {
        //全部转换为大写    取出首字母并返回
        NSString * res = [[mutStr uppercaseString] substringToIndex:1];
        return res;
    } else {
        return @"";
    }
}

+ (NSDictionary *)dealDataWithArray:(NSArray *)array {
    if (array.count == 0) {
        return nil;
    }
    NSMutableArray *titleArray = [NSMutableArray arrayWithCapacity:0];
    NSMutableArray *data = [NSMutableArray arrayWithCapacity:0];
    NSMutableArray * tmpArray = [[NSMutableArray alloc]init];
    for (NSInteger i =0; i <27; i++) {
        //给临时数组创建27个数组作为元素，用来存放A-Z和#开头的联系人
        NSMutableArray * array = [[NSMutableArray alloc]init];
        [tmpArray addObject:array];
    }
    
    for (AddressBookContact * model in array) {
        //AddressMode是联系人的数据模型
        //转化为首拼音并取首字母
        NSString * nickName = [AddressBookDataManager returnFirstWordWithString:model.name];
        
        if (nickName.length == 0) {
            //如果不是，就放到最后一个代表#的数组
            NSMutableArray * array =[tmpArray lastObject];
            [array addObject:model];
        } else {
            int firstWord = [nickName characterAtIndex:0];
            //把字典放到对应的数组中去
            
            if (firstWord >= 65 && firstWord <= 90) {
                //如果首字母是A-Z，直接放到对应数组
                NSMutableArray * array = tmpArray[firstWord - 65];
                [array addObject:model];
                
            } else {
                //如果不是，就放到最后一个代表#的数组
                NSMutableArray * array =[tmpArray lastObject];
                [array addObject:model];
            }
        }
    }
    
    //此时数据已按首字母排序并分组
    //遍历数组，删掉空数组
    for (NSMutableArray * mutArr in tmpArray) {
        //如果数组不为空就添加到数据源当中
        if (mutArr.count != 0) {
            [data addObject:mutArr];
            AddressBookContact * model = mutArr[0];
            NSString * nickName = [AddressBookDataManager returnFirstWordWithString:model.name];
            
            if (nickName.length != 0) {
                int firstWord = [nickName characterAtIndex:0];
                //取出其中的首字母放入到标题数组，暂时不考虑非A-Z的情况
                if (firstWord >= 65 && firstWord <= 90) {
                    [titleArray addObject:nickName];
                }
            }
        }
    }
    
    
//        NSMutableArray *sortedArray = [NSMutableArray array];
//        //对每个section中的数组按照name属性排序
//        for (NSInteger index = 0; index < data.count; index++) {
//            NSMutableArray *personArrayForSection = data[index];
//            NSSortDescriptor *nameDesc    = [NSSortDescriptor sortDescriptorWithKey:@"name"
//                                                                          ascending:YES];
//            NSArray *descriptorArray = @[nameDesc];//此处可以按照多个排序规则, 顺序比较, 比较的顺序就是数组里面元素的顺序
//            
//            NSArray *temp = [personArrayForSection sortedArrayUsingDescriptors: descriptorArray];
//            sortedArray[index] = temp;
//        }
    
    
    NSMutableArray *sortedArray = [NSMutableArray array];
    for (NSInteger index = 0; index < data.count; index++) {
        NSMutableArray *personArrayForSection = data[index];
        NSArray *temp = [personArrayForSection sortedArrayUsingComparator:^NSComparisonResult(AddressBookContact * contact1, AddressBookContact * contact2) {
            return [contact1.name compare:contact2.name];
        }];
        sortedArray[index] = temp;
    }
    

    
//    UILocalizedIndexedCollation *collation = [UILocalizedIndexedCollation currentCollation];
//    NSMutableArray *sortedArray = [NSMutableArray array];
//    //对每个section中的数组按照name属性排序
//    for (NSInteger index = 0; index < data.count; index++) {
//        NSMutableArray *personArrayForSection = data[index];
//        NSArray *sortedPersonArrayForSection = [collation sortedArrayFromArray:personArrayForSection collationStringSelector:@selector(name)];
//        sortedArray[index] = sortedPersonArrayForSection;
//    }
    
    //判断是否需要加#
    if (titleArray.count != data.count) {
        [titleArray addObject:@"#"];
    }
    
    NSDictionary *dic = @{@"source": sortedArray,
                          @"title": titleArray};
    return dic;
}




#pragma mark - Tool
+ (BOOL)objectIsNull:(id)obj{
    return ([obj isKindOfClass:[NSNull class]] || obj == nil) ? YES : NO;
}

+ (NSString*)strNoNull:(id)str{
    if ([AddressBookDataManager objectIsNull:str]) {
        str = @"";
    }
    return str;
}

+ (NSString *)filterPhoneFormate:(NSString *)phoneNumber {
    NSCharacterSet *notAllowedChars = [[NSCharacterSet characterSetWithCharactersInString:@"0123456789"] invertedSet];
    NSString *resultString = [[phoneNumber componentsSeparatedByCharactersInSet:notAllowedChars] componentsJoinedByString:@""];
    return resultString;
}

@end

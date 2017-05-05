//
//  ViewController.m
//  AddressBook
//
//  Created by HChong on 2017/4/23.
//  Copyright © 2017年 HChong. All rights reserved.
//

#import "ViewController.h"
#import <AddressBook/AddressBook.h>
#import <Contacts/Contacts.h>
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self createAddressBook];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - AddressBook
- (void)addressBookEmpowerCheck {
    CNAuthorizationStatus status = [CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts];
    switch (status) {
            case CNAuthorizationStatusNotDetermined: {
                [[[CNContactStore alloc]init] requestAccessForEntityType:CNEntityTypeContacts completionHandler:^(BOOL granted, NSError * _Nullable error) {
                    NSLog(@"还没问");
                    if(granted){
                        NSLog(@"点击了同意");
                        
                    }else{
                        NSLog(@"点击了拒绝");
                    }
                }];
            }
            break;
            case CNAuthorizationStatusRestricted: {
                NSLog(@"应用程序未被授权访问联系人数据, 例如家长控制");
            }
            break;
            case CNAuthorizationStatusDenied: {
                NSLog(@"授权被拒绝");
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

- (void)createAddressBook {
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    queue.maxConcurrentOperationCount = 5;
    
    NSBlockOperation *operationA = [NSBlockOperation blockOperationWithBlock:^{
        for (int i = 0; i < 500; i++) {
            NSString *name = [NSString stringWithFormat:@"测试通讯录%d", i];
            NSString *phone = [NSString stringWithFormat:@"%d", i];
            [self creatItemWithName:name phone:phone];
            //            [self removeItemWithName:name phone:phone];
        }
    }];
    NSBlockOperation *operationB = [NSBlockOperation blockOperationWithBlock:^{
        for (int i = 500; i < 1000; i++) {
            NSString *name = [NSString stringWithFormat:@"测试通讯录%d", i];
            NSString *phone = [NSString stringWithFormat:@"%d", i];
            [self creatItemWithName:name phone:phone];
            //            [self removeItemWithName:name phone:phone];
        }
    }];
    NSBlockOperation *operationC = [NSBlockOperation blockOperationWithBlock:^{
        for (int i = 1000; i < 1500; i++) {
            NSString *name = [NSString stringWithFormat:@"测试通讯录%d", i];
            NSString *phone = [NSString stringWithFormat:@"%d", i];
            [self creatItemWithName:name phone:phone];
            //            [self removeItemWithName:name phone:phone];
        }
    }];
    NSBlockOperation *operationD = [NSBlockOperation blockOperationWithBlock:^{
        for (int i = 1500; i < 2000; i++) {
            NSString *name = [NSString stringWithFormat:@"测试通讯录%d", i];
            NSString *phone = [NSString stringWithFormat:@"%d", i];
            [self creatItemWithName:name phone:phone];
            //            [self removeItemWithName:name phone:phone];
        }
    }];
    NSBlockOperation *operationE = [NSBlockOperation blockOperationWithBlock:^{
        for (int i = 2000; i < 2500; i++) {
            NSString *name = [NSString stringWithFormat:@"测试通讯录%d", i];
            NSString *phone = [NSString stringWithFormat:@"%d", i];
            [self creatItemWithName:name phone:phone];
            //            [self removeItemWithName:name phone:phone];
        }
    }];
    [queue addOperation:operationA];
    [queue addOperation:operationB];
    [queue addOperation:operationC];
    [queue addOperation:operationD];
    [queue addOperation:operationE];
}

- (void)creatItemWithName:(NSString *)name phone:(NSString *)phone {
    if((name.length < 1)||(phone.length < 1)){
        NSLog(@"输入属性不能为空");
        return;
    }
    CFErrorRef error = NULL;
    
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, &error);
    ABRecordRef newRecord = ABPersonCreate();
    ABRecordSetValue(newRecord, kABPersonFirstNameProperty, (__bridge CFTypeRef)name, &error);
    
    ABMutableMultiValueRef multi = ABMultiValueCreateMutable(kABMultiStringPropertyType);
    ABMultiValueAddValueAndLabel(multi, (__bridge CFTypeRef)name, kABPersonPhoneMobileLabel, NULL);
    
    ABRecordSetValue(newRecord, kABPersonPhoneProperty, multi, &error);
    CFRelease(multi);
    
    ABAddressBookAddRecord(addressBook, newRecord, &error);
    CFRelease(newRecord);
    CFRelease(addressBook);
}

- (void)removeItemWithName:(NSString *)name phone:(NSString *)phone {
    ABAddressBookRef addressbook = ABAddressBookCreate();
    CFStringRef nameRef = (__bridge CFStringRef) name;
    CFArrayRef  allSearchRecords = ABAddressBookCopyPeopleWithName(addressbook, nameRef);
    [self removeContactWithRecordsList:allSearchRecords];
}

- (void)removeContactWithRecordsList:(CFArrayRef) selectedRecords_ {
    ABAddressBookRef addressbook = ABAddressBookCreate();
    if (selectedRecords_ != NULL)
    {
        CFIndex count = CFArrayGetCount(selectedRecords_);
        for (int i = 0; i < count; ++i)
        {
            ABRecordRef contact = CFArrayGetValueAtIndex(selectedRecords_, i);
            ABAddressBookRemoveRecord(addressbook, contact, nil);
        }
    }
    ABAddressBookSave(addressbook, nil);
    CFRelease(addressbook);
}



@end

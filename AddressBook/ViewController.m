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
#import "AddressBookListVCViewController.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor lightGrayColor];
    
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(100, 200, 100, 50);
    [button addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
    [button setTitle:@"确定" forState:UIControlStateNormal];
    button.backgroundColor = [UIColor darkGrayColor];
    button.titleLabel.font = [UIFont systemFontOfSize:12];
    [self.view addSubview:button];
}

- (void)buttonAction:(id)action {
    AddressBookListVCViewController *vc = [[AddressBookListVCViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
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

//iOS8
- (void)removeItemWithName:(NSString *)name{
    ABAddressBookRef addressbook = ABAddressBookCreate();
    CFStringRef nameRef = (__bridge CFStringRef) name;
    CFArrayRef  allSearchRecords = ABAddressBookCopyPeopleWithName(addressbook, nameRef);
    if (allSearchRecords != NULL)
    {
        CFIndex count = CFArrayGetCount(allSearchRecords);
        for (int i = 0; i < count; ++i)
        {
            ABRecordRef contact = CFArrayGetValueAtIndex(allSearchRecords, i);
            ABAddressBookRemoveRecord(addressbook, contact, nil);
        }
    }
    ABAddressBookSave(addressbook, nil);
    CFRelease(addressbook);
}

//iOS9
- (void)addContactWithName:(NSString *)name {
    
    CNContactStore *store = [[CNContactStore alloc] init];
    [store requestAccessForEntityType:CNEntityTypeContacts completionHandler:^(BOOL granted, NSError * _Nullable error) {
        if (!granted) {
            dispatch_async(dispatch_get_main_queue(), ^{
                //失败原因
            });
            return;
        }
        
        CNMutableContact *contact = [[CNMutableContact alloc] init];
        contact.familyName = @"Doe";
        contact.givenName = @"John";
        
        CNLabeledValue *homePhone = [CNLabeledValue labeledValueWithLabel:CNLabelHome value:[CNPhoneNumber phoneNumberWithStringValue:@"312-555-1212"]];
        contact.phoneNumbers = @[homePhone];
        
        CNSaveRequest *request = [[CNSaveRequest alloc] init];
        [request addContact:contact toContainerWithIdentifier:nil];
        
        // save it
        NSError *saveError;
        if (![store executeSaveRequest:request error:&saveError]) {
            NSLog(@"error = %@", saveError);
        }
    }];
}

- (void)removeContactWithName:(NSString *)name {
    CNContactStore *store = [[CNContactStore alloc] init];
    NSPredicate *predicate = [CNContact predicateForContactsMatchingName:name];
    NSArray *contacts = [store unifiedContactsMatchingPredicate:predicate keysToFetch:@[CNContactGivenNameKey, CNContactFamilyNameKey] error:nil];
    
    for (CNMutableContact *contact in contacts) {
        CNSaveRequest *request = [[CNSaveRequest alloc] init];
        [request deleteContact:contact];
        // save it
        NSError *saveError;
        if (![store executeSaveRequest:request error:&saveError]) {
            NSLog(@"error = %@", saveError);
        }
    }
}

- (void)addItemWithName:(NSString *)name phone:(NSString *)phone {
    // 创建对象
    CNMutableContact * contact = [[CNMutableContact alloc]init];
    contact.givenName = name?:@"defaultname";
    CNLabeledValue *phoneNumber = [CNLabeledValue labeledValueWithLabel:CNLabelPhoneNumberMobile value:[CNPhoneNumber phoneNumberWithStringValue:phone?:@"10086"]];
    contact.phoneNumbers = @[phoneNumber];
    
    // 把对象加到请求中
    CNSaveRequest * saveRequest = [[CNSaveRequest alloc]init];
    [saveRequest addContact:contact toContainerWithIdentifier:nil];
    
    // 执行请求
    CNContactStore * store = [[CNContactStore alloc]init];
    [store executeSaveRequest:saveRequest error:nil];
}

- (void)removeItemWithName:(NSString *)name phone:(NSString *)phone {
    // 创建对象
    CNMutableContact * contact = [[CNMutableContact alloc]init];
    contact.givenName = name?:@"defaultname";
    CNLabeledValue *phoneNumber = [CNLabeledValue labeledValueWithLabel:CNLabelPhoneNumberMobile value:[CNPhoneNumber phoneNumberWithStringValue:phone?:@"10086"]];
    contact.phoneNumbers = @[phoneNumber];
    
    // 把对象加到请求中
    CNSaveRequest * saveRequest = [[CNSaveRequest alloc]init];
    [saveRequest addContact:contact toContainerWithIdentifier:nil];
    
    // 执行请求
    CNContactStore * store = [[CNContactStore alloc]init];
    [store executeSaveRequest:saveRequest error:nil];
}

- (void)getContact {
    
}

- (void)getItem {
    
}

@end

//
//  AddressBookListVCViewController.m
//  AddressBook
//
//  Created by HChong on 2017/5/5.
//  Copyright © 2017年 HChong. All rights reserved.
//

#import "AddressBookListVCViewController.h"
#import "AddressBookDataManager.h"
#import "AddressBookContact.h"
#import <AddressBook/AddressBook.h>
#import <Contacts/Contacts.h>

@interface AddressBookListVCViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) NSArray *dataArray;
@property (nonatomic, strong) NSArray *titleArray;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, assign) ABAddressBookRef addresBook;
@end

@implementation AddressBookListVCViewController

- (instancetype)init {
    self = [super init];
    if (self) {
        _addresBook = ABAddressBookCreateWithOptions(NULL, NULL);
        ABAddressBookRegisterExternalChangeCallback(_addresBook, addressBookChanged, nil);
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addressBookDidChange:) name:CNContactStoreDidChangeNotification object:nil];

    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithRed:0.3 green:0.8 blue:0.7 alpha:1];
    [self tableViewConfig];
    [self getData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)addressBookDidChange:(NSNotification*)notification{
    NSLog(@"chaojibainbianbian....");
}

//监听通讯录变化
void addressBookChanged(ABAddressBookRef addressBook, CFDictionaryRef info, void *context) {
    NSLog(@"通讯录变化啦....");
    //    VC1 *myVC = (__bridge VC1 *)context;
    //    [myVC getPersonOutOfAddressBook];
}

- (void)dealloc {
    NSLog(@"%@-------------------dealloc", self);
    [[NSNotificationCenter defaultCenter] removeObserver:self name:CNContactStoreDidChangeNotification object:nil];
    ABAddressBookUnregisterExternalChangeCallback(_addresBook, addressBookChanged, nil);
}

#pragma mark - Private
- (void)getData {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [AddressBookDataManager checkAddressBookAuthorization:^(bool isAuthorized) {
            if (isAuthorized) {
                NSDictionary *dic = [AddressBookDataManager getTitleAndData];
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.dataArray = dic[@"source"];
                    self.titleArray = dic[@"title"];
                    [self.tableView reloadData];
                });
            }
        }];
    });
}

- (void)tableViewConfig {
    [self.view addSubview:self.tableView];
}

#pragma mark - UITableViewDelegate, UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.dataArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.dataArray[section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (self.dataArray.count == 0) {
        return [[UITableViewCell alloc] initWithFrame:CGRectZero];
    }
    static NSString *cellIdentifier = @"cellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    }
    AddressBookContact *model = self.dataArray[indexPath.section][indexPath.row];
    cell.textLabel.text = model.name;
    cell.detailTextLabel.text = model.phone;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(nonnull NSIndexPath *)indexPath{
    return 44;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if ([self.dataArray[section] count] == 0 || self.dataArray.count == 0) {
        return 0.01;
    }
    return 22;
}

//- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
//    if (self.titleArray.count == 0) {
//        return @"";
//    }
//    return self.titleArray[section];
//}

//- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
//    return self.titleArray;
//}

// 按照索引个数配置tableview区数
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if ([self.dataArray[section] count] == 0 || self.dataArray.count == 0) {
        return @"";
    }
    return [[UILocalizedIndexedCollation currentCollation] sectionTitles][section];
}

// 配置索引内容，就是通讯录中右侧的那一列“A~Z、#”
- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    return [[UILocalizedIndexedCollation currentCollation] sectionIndexTitles];
}

// 索引点击响应
- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
    return [[UILocalizedIndexedCollation currentCollation] sectionForSectionIndexTitleAtIndex:index];
}

#pragma mark - Getter, Setter
- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height) style:UITableViewStylePlain];
        _tableView.backgroundColor = [UIColor whiteColor];
        _tableView.dataSource = self;
        _tableView.delegate = self;
    }
    return _tableView;
}
@end

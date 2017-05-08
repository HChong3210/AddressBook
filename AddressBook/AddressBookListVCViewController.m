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

@interface AddressBookListVCViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) NSArray *dataArray;
@property (nonatomic, strong) NSArray *titleArray;
@property (nonatomic, strong) UITableView *tableView;
@end

@implementation AddressBookListVCViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithRed:0.3 green:0.8 blue:0.7 alpha:1];
    [self tableViewConfig];
    [self getData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)dealloc {
    NSLog(@"%@-------------------dealloc", self);
}

#pragma mark - Private
- (void)getData {
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        NSDictionary *dic = [AddressBookDataManager getTitleAndData];
//        dispatch_async(dispatch_get_main_queue(), ^{
//            self.dataArray = dic[@"source"];
//            self.titleArray = dic[@"title"];
//            [self.tableView reloadData];
//        });
//    });
    
    NSDictionary *dic = [AddressBookDataManager getTitleAndData];
    
        self.dataArray = dic[@"source"];
        self.titleArray = dic[@"title"];
        [self.tableView reloadData];
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
    return 22;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (self.titleArray.count == 0) {
        return @"";
    }
    return self.titleArray[section];
}

#pragma mark - Getter, Setter
- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height) style:UITableViewStyleGrouped];
        _tableView.backgroundColor = [UIColor whiteColor];
        _tableView.dataSource = self;
        _tableView.delegate = self;
    }
    return _tableView;
}
@end

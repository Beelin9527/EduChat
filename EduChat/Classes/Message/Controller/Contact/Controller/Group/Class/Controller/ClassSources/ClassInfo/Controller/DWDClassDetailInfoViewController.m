//
//  DWDClassDetailInfoViewController.m
//  EduChat
//
//  Created by Superman on 15/12/8.
//  Copyright © 2015年 dwd. All rights reserved.
//

#import "DWDClassDetailInfoViewController.h"

@interface DWDClassDetailInfoViewController ()

@end

@implementation DWDClassDetailInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 1;
    }else{
        return 2;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        return 1;
    }
    return 1;
}



@end

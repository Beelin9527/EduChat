//
//  DWDLeavePaperBaseController.m
//  EduChat
//
//  Created by apple on 15/12/8.
//  Copyright © 2015年 dwd. All rights reserved.
//

#import "DWDLeavePaperBaseController.h"
#import "DWDLeavePaperApplyStudentCell.h"


@interface DWDLeavePaperBaseController ()

@end
static NSString *LeavePaperApplyStudentCell = @"DWDLeavePaperApplyStudentCell";
@implementation DWDLeavePaperBaseController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.backgroundColor = DWDColorBackgroud;
    [self registerBaseCell];
}


#pragma mark - view
//注册Cell
-(void)registerBaseCell
{
    [self.tableView registerNib:[UINib nibWithNibName:@"DWDLeavePaperApplyStudentCell" bundle:nil]forCellReuseIdentifier:LeavePaperApplyStudentCell];
}



#pragma mark - Table view data source

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        DWDLeavePaperApplyStudentCell *cell = [tableView dequeueReusableCellWithIdentifier:LeavePaperApplyStudentCell forIndexPath:indexPath];
        
        cell.noteDetailEntity = self.noteDetailEntity;
        cell.authorEntity = self.authorEntity;
        cell.noteEntity = self.noteEntity;
        return cell;
    }
    return nil;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        return 300;
    }
    return 0;
}


@end

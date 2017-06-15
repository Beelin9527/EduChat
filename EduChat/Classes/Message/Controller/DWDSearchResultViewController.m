//
//  DWDSearchResultViewController.m
//  EduChat
//
//  Created by Gatlin on 16/2/16.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import "DWDSearchResultViewController.h"
#import "DWDContactListCell.h"
#import "DWDChatController.h"
@interface DWDSearchResultViewController ()
@property (nonatomic,strong) UILabel *lab;
@end

@implementation DWDSearchResultViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.rowHeight = 60;
    
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([DWDContactListCell class]) bundle:nil ] forCellReuseIdentifier:NSStringFromClass([DWDContactListCell class])];

}
/*
- (UILabel *)lab
{
    if (!_lab) {
        _lab = [[UILabel alloc] init];
        _lab.frame = CGRectMake(DWDScreenW/2-50, 80, 100, 21);
        _lab.textAlignment = NSTextAlignmentCenter;
        _lab.text = @"无结果";
        
    }
    return _lab;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (self.dataSource.count == 0) {
        [self.view addSubview:self.lab];
    }else{
        [self.lab removeFromSuperview];
    }
    return self.dataSource.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  
    DWDContactListCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([DWDContactListCell class])];
    
    NSDictionary *dictContact = self.dataSource[indexPath.row];
    
    switch (self.searchType) {
        case DWDSearchTypeContact:
            
            [cell.headerImv sd_setImageWithURL:[NSURL URLWithString:[DWDCustInfo shared].custPhotoKey] placeholderImage:DWDDefault_MeBoyImage];
            if (dictContact[@"remarkName"]) {
                cell.nameLab.text = dictContact[@"remarkName"];
            }else{
                cell.nameLab.text = dictContact[@"nickname"];
            }
            break;
            
        default:
            break;
    }
  
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSDictionary *dictContact = self.dataSource[indexPath.row];
    switch (self.searchType) {
        case DWDSearchTypeContact:  //好友搜索
        {
            DWDChatController *vc = [[UIStoryboard storyboardWithName:NSStringFromClass([DWDChatController class]) bundle:nil] instantiateViewControllerWithIdentifier:NSStringFromClass([DWDChatController class])];
            vc.chatType = DWDChatTypeFace;
            NSString *remark = dictContact[@"remarkName"];
            if (remark) {
                vc.navigationItem.title = remark;
            }
            else {
                vc.title = dictContact[@"nickname"];
            }
            vc.toUserId = dictContact[@"friendCustId"];
            [self.navigationController pushViewController:vc animated:YES];
            
            break;
        }
        default:
            break;
    }

}
*/


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

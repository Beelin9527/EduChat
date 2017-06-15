//
//  DWDSearchResultController.h
//  EduChat
//
//  Created by Superman on 15/11/19.
//  Copyright © 2015年 dwd. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DWDSearchResultControllerDelegate <NSObject>
@required
- (void)resultControllerCellDidSelectWithResults:(NSArray *)results indexPath:(NSIndexPath *)indexPath;
@end

@interface DWDSearchResultController : UITableViewController
@property (nonatomic , strong) NSArray *results;
@property (nonatomic , strong) UISearchBar *searchBar;
@property (nonatomic , weak) id <DWDSearchResultControllerDelegate> resultVcDelegate;

@end

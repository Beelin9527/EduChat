//
//  DWDProvinceCell.h
//  EduChat
//
//  Created by Superman on 15/12/12.
//  Copyright © 2015年 dwd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DWDProvinceCell : UITableViewCell <UITableViewDataSource , UITableViewDelegate>
@property (nonatomic , strong) NSArray *cities;
@property (nonatomic , weak) UITableView *subTableView;

@end

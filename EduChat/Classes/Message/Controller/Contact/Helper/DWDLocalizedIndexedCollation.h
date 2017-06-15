//
//  DWDLocalizedIndexedCollation.h
//  EduChat
//
//  Created by Gatlin on 16/2/3.
//  Copyright © 2016年 dwd. All rights reserved.
//  通讯录 字母索引

#import <UIKit/UIKit.h>

// 本来想继承UILocalizedIndexedCollation的，发现有些操作会报错，只好继承 NSObject
@interface DWDLocalizedIndexedCollation : NSObject
@property (strong, nonatomic) NSArray *arrDataSource;    //传入的数据源
@property (strong, nonatomic) NSMutableArray *arrSectionsArray; //返回数据

@property (strong, nonatomic) UILocalizedIndexedCollation *localizedIndexedCollation;  //字母索引封装类
+ (instancetype)currentCollation;
@end


//实现以下方法。自动分组
/*
     实现以下方法

 ** 修改这里 设置分区高度、无数据的区设置为0
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if ([[self.contactsData objectAtIndex:section] count] == 0)
    {
        return 0;
    }
    else{
        return 22;
    }
}

** 设置区头名 *
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [self.collation.localizedIndexedCollation sectionTitles][section];
}


** 过滤无数据索引字母 *
- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    //右边索引、这里去掉没有数据的索引字线
    NSMutableArray * existTitles = [NSMutableArray array];
    //section数组为空的title过滤掉，不显示
    for (int i = 0; i < [[self.collation.localizedIndexedCollation sectionTitles] count]; i++) {
        if ([[self.contactsData objectAtIndex:i] count] > 0) {
            [existTitles addObject:[[self.collation.localizedIndexedCollation sectionTitles] objectAtIndex:i]];
        }
    }
    return existTitles;
    
}

** 选择索引触发事件 *
- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
    return [self.collation.localizedIndexedCollation sectionForSectionIndexTitleAtIndex:index];
}

*/

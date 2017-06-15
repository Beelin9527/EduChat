//
//  OOStretchTableHeaderView.m
//  StretchTableHeaderView
//
//  Created by Gatlin-man on 16/4/7.
//  Copyright © 2016年 Gatlin. All rights reserved.
//

#import "OOStretchTableHeaderView.h"

@interface OOStretchTableHeaderView ()
@property (assign , nonatomic) CGRect initialFrame;
@property (assign , nonatomic) CGFloat defaultViewHeight;
@end

@implementation OOStretchTableHeaderView


+ (instancetype)stretchHeaderForTableView:(UITableView*)tableView withView:(UIView*)view
{
    OOStretchTableHeaderView *stretchHeaderView = [OOStretchTableHeaderView new];
    
    stretchHeaderView.tableView = tableView;
    stretchHeaderView.view = view;
    
    stretchHeaderView.initialFrame = stretchHeaderView.view.frame;
    stretchHeaderView.defaultViewHeight = stretchHeaderView.initialFrame.size.height;
    
    stretchHeaderView.tableView.tableHeaderView = view;
    
    return stretchHeaderView;
   
}


- (void)scrollViewDidScroll:(UIScrollView*)scrollView
{
    if(scrollView.contentOffset.y < 0) {
        
        CGFloat offsetY = (scrollView.contentOffset.y + scrollView.contentInset.top) * -1;
        _initialFrame.origin.y = offsetY * -1;
        _initialFrame.size.height = self.defaultViewHeight + offsetY;
        _view.frame = self.initialFrame;
    }
}

- (void)resizeView
{
    _initialFrame.size.width = self.tableView.frame.size.width;
    _view.frame = self.initialFrame;
}


@end

//
//  DWDProvinceCell.m
//  EduChat
//
//  Created by Superman on 15/12/12.
//  Copyright © 2015年 dwd. All rights reserved.
//

#import "DWDProvinceCell.h"
#import "DWDCityModel.h"
@interface DWDProvinceCell() 

@end

@implementation DWDProvinceCell


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.cities.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *ID = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
        
    }
    DWDCityModel *city = self.cities[indexPath.row];
    
    cell.textLabel.text = city.name;
    cell.backgroundColor = DWDRandomColor;
    return cell;
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setCities:(NSArray *)cities{
    _cities = cities;
    // 在这里计算出子tableview有多少行,   一共多高,  通过代理告诉外面 
    [self.subTableView reloadData];
}

@end

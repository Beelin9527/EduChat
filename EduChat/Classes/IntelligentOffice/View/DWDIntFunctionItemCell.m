//
//  DWDIntFunctionItemCell.m
//  EduChat
//
//  Created by Beelin on 16/12/2.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import "DWDIntFunctionItemCell.h"

#import "DWDIntelligenceMenuModel.h"

#import "UIButton+WebCache.h"
@interface DWDIntFunctionItemCell ()
@property (nonatomic, strong) UILabel *headTitleLab;
@property (nonatomic, strong) UIView *line;
@property (nonatomic, strong) NSString *headerTitle;
@end

static const CGFloat ItemViewW = 60;
static const CGFloat ItemViewH = 64;

@implementation DWDIntFunctionItemCell

+ (instancetype)cellWithTableView:(UITableView *)tableView headTitle:(NSString *)title
{
    static NSString *ID = @"DWDIntFunctionItemCell";
    DWDIntFunctionItemCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (!cell) {
        cell = [[DWDIntFunctionItemCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    cell.headTitleLab.text = title;
    return cell;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self.contentView addSubview:self.headTitleLab];
        [self.contentView addSubview:self.line];
    
        
    }
    return self;
}

#pragma mark - Setter
- (void)setDataSource:(NSArray *)dataSource{
    _dataSource = dataSource;
    
    [self.contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self.contentView addSubview:self.headTitleLab];
    [self.contentView addSubview:self.line];
    
    //layout
    for (int i = 0; i < dataSource.count; i ++) {
        DWDIntelligenceMenuModel *model = dataSource[i];
        
        CGFloat paddingX = DWDScreenW > 320.0f ? 20 : 15;
        CGFloat paddingY = 70;
        CGFloat paddingW = (DWDScreenW - ItemViewW *4 - paddingX *2) / 3.0;
        CGFloat paddingH = 25;
        
        CGFloat itemX = paddingX + (paddingW *(i % 4)) + ItemViewW * (i % 4);
        CGFloat itemY = paddingY + (paddingH *(i / 4)) + ItemViewW * (i / 4);
        
        UIView *item = [self createItemViewWithModel:model tag:i];
        item.frame = CGRectMake(itemX, itemY, ItemViewW, ItemViewH);
        [self.contentView addSubview:item];
        
        //计算cell高度
        if(i == dataSource.count - 1){
            model.cellHeight = CGRectGetMaxY(item.frame) + 20;
        }
    }
    
}
#pragma mark - Getter
- (UILabel *)headTitleLab{
    if (!_headTitleLab) {
        _headTitleLab = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, 80, 50)];
        _headTitleLab.textColor = DWDColorBody;
    }
    return _headTitleLab;
}
- (UIView *)line{
    if (!_line) {
        _line = [[UIView alloc] initWithFrame:CGRectMake(0, 50, DWDScreenW, 0.5)];
        _line.backgroundColor = DWDColorSeparator;
    }
    return _line;
}

#pragma mark - Private Method
- (UIView *)createItemViewWithModel:(DWDIntelligenceMenuModel *)model tag:(NSInteger)tag{
    UIView *itemView = [[UIView alloc] init];
    itemView.size = CGSizeMake(ItemViewW, ItemViewH);
    
    [itemView addSubview:({
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(9.5, 0, 41, 41);
        [btn sd_setImageWithURL:[NSURL URLWithString:model.menuIcon] forState:UIControlStateNormal placeholderImage:DWDDefault_infoPhotoImage];
        btn.tag = tag;
        [btn addTarget:self action:@selector(click:) forControlEvents:UIControlEventTouchUpInside];
        btn;
    })];
    [itemView addSubview:({
        UILabel *lab = [[UILabel alloc] initWithFrame:CGRectMake(-7.5, 50, ItemViewW + 15, 14)];
        lab.text = model.menuName;
        lab.textAlignment = NSTextAlignmentCenter;
        lab.textColor = DWDRGBColor(68, 68, 68);
        lab.font = DWDFontContent;
        lab;
    })];
    
    return itemView;
}

#pragma mark - Event Response
- (void)click:(UIButton *)sender{
    if (self.delegate && [self.delegate respondsToSelector:@selector(intFunctionItemCell:selectItemWithModel:)]) {
        [self.delegate intFunctionItemCell:self selectItemWithModel:self.dataSource[sender.tag]];
    }
}
@end

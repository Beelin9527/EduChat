//
//  DWDContactCell.m
//  EduChat
//
//  Created by apple on 12/8/15.
//  Copyright © 2015 dwd. All rights reserved.
//

#import "DWDContactCell.h"

#define DWDContactCellPadding 10
#define DWDContactCellAvatarEdgeLength 40
#define DWDContactDesMaxLength 55
#define DWDContactActionBtnPadding 5
#define DWDContactEditingEdgeLength 20

@interface DWDContactCell () {
    CGRect avatarFrame, nikcnameFrame, subInfoFrame, desFrame, actionFrame, editingFrame;
}
@property (strong, nonatomic) UIButton *actionBtn;
@property (strong, nonatomic) UIImageView *editView;
@end

@implementation DWDContactCell

- (UIEdgeInsets)layoutMargins
{
    return UIEdgeInsetsMake(0, 0, 0, 0);
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
    
    if (editing) {
        [self buildEidingFrame];
        
        UITapGestureRecognizer *editingTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(editingTapHandler:)];
        [self.contentView addGestureRecognizer:editingTap];   // 添加tap手势给contentview
    }
    else {
        editingFrame = CGRectZero;
    }
    [super setEditing:editing animated:animated];
}

- (void)buildEidingFrame {
    editingFrame = CGRectMake(DWDContactCellPadding, 0, DWDContactEditingEdgeLength, DWDContactEditingEdgeLength);
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        _editView = [[UIImageView alloc] initWithFrame:CGRectZero];
        self.editView.userInteractionEnabled = YES;
        self.editView.image = [UIImage imageNamed:@"btn_point_marquee_select_contacts_normal"];
        
        
        _avatarView = [[UIImageView alloc] initWithFrame:CGRectZero];
        
        _nicknameLable = [[UILabel alloc] initWithFrame:CGRectZero];
        self.nicknameLable.font = DWDFontBody;
        self.nicknameLable.textColor = DWDColorBody;
        
        _subInfoLable = [[UILabel alloc] initWithFrame:CGRectZero];
        self.subInfoLable.font = DWDFontMin;
        self.subInfoLable.textColor = DWDColorContent;
        
        _desLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        self.desLabel.font = DWDFontMin;
        self.desLabel.textColor = DWDColorContent;
        
        _identityLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        self.identityLabel.font = DWDFontContent;
        self.identityLabel.textColor = [UIColor whiteColor];
        self.identityLabel.textAlignment = NSTextAlignmentCenter;
        
        _actionBtn = [[UIButton alloc] initWithFrame:CGRectZero];  // 右边的邀请 接受 按钮
        self.actionBtn.titleLabel.font = DWDFontContent;
        
        [self.actionBtn addTarget:self action:@selector(action:) forControlEvents:UIControlEventTouchUpInside];
        
        [self.contentView addSubview:self.editView];
        [self.contentView addSubview:self.avatarView];
        [self.contentView addSubview:self.nicknameLable];
        [self.contentView addSubview:self.subInfoLable];
        [self.contentView addSubview:self.desLabel];
        [self.contentView addSubview:self.identityLabel];
        [self.contentView addSubview:self.actionBtn];
    }
    return self;
}

- (void)setStatus:(DWDContactCellStatus)status {
    
    _status = status;
    
    switch (status) {
            
        case DWDContactCellStatusReject:
            self.desLabel.text = NSLocalizedString(@"Rejected", nil);
            break;
            
        case DWDContactCellStatusMyVerified:
            self.desLabel.text = NSLocalizedString(@"Verified", nil);
            break;
            
        case  DWDContactCellStatusInviting:
            self.desLabel.text = NSLocalizedString(@"Verifing", nil);
            break;
            
        case DWDContactCellStatusMyVerifing:
            [self.actionBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [self.actionBtn setTitle:NSLocalizedString(@"Accept", nil) forState:UIControlStateNormal];
            [self.actionBtn setBackgroundImage:[UIImage imageNamed:@"btn_accept_normal"] forState:UIControlStateNormal];
            [self.actionBtn setBackgroundImage:[UIImage imageNamed:@"btn_accept_press"] forState:UIControlStateHighlighted];
            break;
            
        case DWDContactCellStatusAdd:
            [self.actionBtn setTitleColor:DWDColorContent forState:UIControlStateNormal];
            [self.actionBtn setTitle:NSLocalizedString(@"Add", nil) forState:UIControlStateNormal];
            [self.actionBtn setBackgroundImage:[UIImage imageNamed:@"btn_add_to_normal"] forState:UIControlStateNormal];
            [self.actionBtn setBackgroundImage:[UIImage imageNamed:@"btn_add_to_press"] forState:UIControlStateHighlighted];

            break;
            
        case DWDContactCellStatusInvite:
            [self.actionBtn setTitleColor:DWDColorContent forState:UIControlStateNormal];
            [self.actionBtn setTitle:NSLocalizedString(@"Invite", nil) forState:UIControlStateNormal];
            [self.actionBtn setBackgroundImage:[UIImage imageNamed:@"btn_add_to_normal"] forState:UIControlStateNormal];
            [self.actionBtn setBackgroundImage:[UIImage imageNamed:@"btn_add_to_press"] forState:UIControlStateHighlighted];
            break;
            
        default:
            break;
    }
}

- (void)layoutSubviews {
    
    [super layoutSubviews];
    
    avatarFrame = CGRectMake(DWDContactCellPadding, DWDContactCellPadding, DWDContactCellAvatarEdgeLength, DWDContactCellAvatarEdgeLength);

    CGSize nikcnameSize = [self.nicknameLable.text boundingRectWithSize:CGSizeMake(DWDScreenW - 4 * DWDContactCellPadding - DWDContactCellAvatarEdgeLength - DWDContactDesMaxLength, 99999)
                                                                options:NSStringDrawingUsesLineFragmentOrigin
                                                             attributes:@{NSFontAttributeName:self.nicknameLable.font}
                                                                context:nil].size;
    nikcnameFrame = CGRectMake(avatarFrame.origin.x + avatarFrame.size.width + DWDContactCellPadding, DWDContactCellPadding, nikcnameSize.width, nikcnameSize.height);
    
    CGSize desSize = [self.desLabel.text boundingRectWithSize:CGSizeMake(DWDContactDesMaxLength, 9999)
                                                      options:NSStringDrawingUsesLineFragmentOrigin
                                                   attributes:@{NSFontAttributeName:self.desLabel.font}
                                                      context:nil].size;
    desFrame = CGRectMake(DWDScreenW - DWDContactCellPadding - desSize.width, DWDContactCellPadding, desSize.width, desSize.height);

    if (self.status != DWDContactCellStatusDefault) {
        
        
        CGSize subInfoSize = [self.subInfoLable.text boundingRectWithSize:CGSizeMake(DWDScreenW - 4 * DWDContactCellPadding - DWDContactCellAvatarEdgeLength - DWDContactDesMaxLength, 99999)
                                                                  options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingTruncatesLastVisibleLine
                                                               attributes:@{NSFontAttributeName:self.subInfoLable.font}
                                                                  context:nil].size;
        subInfoFrame = CGRectMake(nikcnameFrame.origin.x, 5 + DWDContactCellPadding + nikcnameFrame.size.height, subInfoSize.width, subInfoSize.height);
        
        switch (self.status) {
                
            case DWDContactCellStatusMyVerifing:
            case DWDContactCellStatusAdd:
            case DWDContactCellStatusInvite: {
                
                CGSize actionSize = [self.actionBtn.titleLabel.text boundingRectWithSize:CGSizeMake(60, 30)
                                                                                 options:NSStringDrawingUsesLineFragmentOrigin
                                                                              attributes:@{NSFontAttributeName:self.actionBtn.titleLabel.font}
                                                                                 context:nil].size;
                
                actionFrame = CGRectMake(DWDScreenW - DWDContactCellPadding -  actionSize.width - 2 * DWDContactActionBtnPadding, DWDContactCellPadding, actionSize.width + 2 * DWDContactActionBtnPadding, actionSize.height + 2 * DWDContactActionBtnPadding);
                break;
            }
                
            default:
                actionFrame = CGRectZero;
                break;
        }
    }

    if (self.isEditing &&
        self.status == DWDContactCellStatusDefault) {
        
        CGFloat offset =  DWDContactEditingEdgeLength + DWDContactCellPadding;
        avatarFrame = CGRectMake(avatarFrame.origin.x + offset, avatarFrame.origin.y, avatarFrame.size.width, avatarFrame.size.height);
        nikcnameFrame = CGRectMake(nikcnameFrame.origin.x + offset, nikcnameFrame.origin.y, nikcnameFrame.size.width, nikcnameFrame.size.height);
        desFrame = CGRectMake(desFrame.origin.x + offset, desFrame.origin.y, desFrame.size.width, desFrame.size.height);
        subInfoFrame = CGRectMake(subInfoFrame.origin.x + offset, subInfoFrame.origin.y, subInfoFrame.size.width, subInfoFrame.size.height);
        actionFrame = CGRectMake(actionFrame.origin.x + offset, actionFrame.origin.y, actionFrame.size.width, actionFrame.size.height);
    }
 
    self.editView.frame = editingFrame;
   
    self.avatarView.frame = avatarFrame;
    self.editView.center = CGPointMake(self.editView.center.x, self.avatarView.center.y);
    self.nicknameLable.frame = nikcnameFrame;
    if (self.status == DWDContactCellStatusDefault) {
        self.nicknameLable.center = CGPointMake(self.nicknameLable.center.x, self.avatarView.center.y);
    }
    self.subInfoLable.frame = subInfoFrame;
    [self.subInfoLable sizeToFit];
    self.subInfoLable.frame = CGRectMake(subInfoFrame.origin.x, subInfoFrame.origin.y, subInfoFrame.size.width, self.subInfoLable.frame.size.height);
    
    self.desLabel.frame = desFrame;
    self.desLabel.center = CGPointMake(self.desLabel.center.x, self.avatarView.center.y);
    self.actionBtn.frame = actionFrame;
    self.actionBtn.center = CGPointMake(self.actionBtn.center.x, self.avatarView.center.y);
    
    self.identityLabel.frame = CGRectMake(CGRectGetMaxX(self.nicknameLable.frame) + 5, self.avatarView.center.y - 16/2, 34, 16);
    
    if (self.isMultEditingSelected) {
        self.editView.image = [UIImage imageNamed:@"btn_point_marquee_select_contacts_selected"];
    } else {
        self.editView.image = [UIImage imageNamed:@"btn_point_marquee_select_contacts_normal"];
    }
}

// 联系人CELL 右边的按钮
- (void)action:(id)sender {
    
    [self throwWaringIfNeeded];
    
    switch (self.status) {
        
        case DWDContactCellStatusMyVerifing: {
            
            if (self.actionDelegate && [self.actionDelegate respondsToSelector:@selector(contactCellDidAccpetVerify:atIndexPath:)]) {
                [self.actionDelegate contactCellDidAccpetVerify:self atIndexPath:self.indexPath];
            }
            
            break;
        }
        
        case DWDContactCellStatusAdd: {  // 添加
            
            if (self.actionDelegate && [self.actionDelegate respondsToSelector:@selector(contactCellDidAddFriend:atIndexPath:)]) {
                [self.actionDelegate contactCellDidAddFriend:self atIndexPath:self.indexPath];
            }
            break;
        }
            
        case DWDContactCellStatusInvite: {  // 邀请
            
            if (self.actionDelegate && [self.actionDelegate respondsToSelector:@selector(contactCellDidInviteFriend:atIndexPath:)]) {
                [self.actionDelegate contactCellDidInviteFriend:self atIndexPath:self.indexPath];
            }
            break;
        }
        default:
            break;
    }
}

- (void)editingTapHandler:(UITapGestureRecognizer *)sender {
 
    [self throwWaringIfNeeded];
    
    if (!self.isMultEditingSelected && self.actionDelegate && [self.actionDelegate respondsToSelector:@selector(contactCellDidMutlEditingSelectedAtIndexPath:)]) {
        self.isMultEditingSelected = YES;
        self.editView.image = [UIImage imageNamed:@"btn_point_marquee_select_contacts_selected"];
        [self.actionDelegate contactCellDidMutlEditingSelectedAtIndexPath:self.indexPath];
    }
    
    else if (self.isMultEditingSelected && self.actionDelegate && [self.actionDelegate respondsToSelector:@selector(contactCellDidMutlEditingDisselectedAtIndexPath:)]) {
        self.isMultEditingSelected = NO;
        self.editView.image = [UIImage imageNamed:@"btn_point_marquee_select_contacts_normal"];
        [self.actionDelegate contactCellDidMutlEditingDisselectedAtIndexPath:self.indexPath];
    }
}

- (void)throwWaringIfNeeded {
    if (!self.indexPath) {
        DWDLog(@"you need set indexPath for this cell, If you do not we do nothing");
        return;
    }
}
@end

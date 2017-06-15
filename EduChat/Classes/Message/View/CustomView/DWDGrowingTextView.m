//
//  DWDGrowingTextView.m
//  EduChat
//
//  Created by apple on 11/11/15.
//  Copyright © 2015 dwd. All rights reserved.
//

#import "DWDGrowingTextView.h"
#import "DWDInteractiveChatCell.h"
@interface DWDGrowingTextView ()

@property (assign, nonatomic) CGFloat maxNumberOfLinesToDisplay;
@property (assign, nonatomic) CGFloat initialHeight;

@property (nonatomic , weak) DWDInteractiveChatCell *cell;
@property (nonatomic , assign) BOOL isCellLongPressCallMenu;
@property (nonatomic , assign) BOOL isMenuItemClick;


@property (nonatomic , weak) NSArray *titles;
@property (nonatomic , assign) CGRect rect;
@property (nonatomic , weak) UITableView *tableView;

@property (nonatomic , strong) UIMenuItem *pasteItem;

@end

@implementation DWDGrowingTextView

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self commenInit];
        
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
        [self commenInit];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(menuWillShow:) name:UIMenuControllerWillShowMenuNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(menuDidShow:) name:UIMenuControllerDidShowMenuNotification object:nil];
        
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    if (self.contentSize.height < [self getMaxHeight]) {
        self.contentOffset = CGPointZero;
    }
}

- (void)scrollRectToVisible:(CGRect)rect animated:(BOOL)animated {
    
}

- (void)scrollRangeToVisible:(NSRange)range {
    
}
#pragma mark -- public method
- (CGFloat)getHeightConstraint {
    CGSize size = [self sizeThatFits:CGSizeMake(self.bounds.size.width, 9999.f)];
    if (size.height > [self getMaxHeight]) {
        self.showsVerticalScrollIndicator = YES;
        self.contentOffset = CGPointMake(0, self.contentSize.height - self.frame.size.height);
        return [self getMaxHeight];
    } else {
        self.showsVerticalScrollIndicator = NO;
        return size.height;
    }
}

- (CGFloat)getMaxHeight {
    CGFloat buffer = self.font.lineHeight / 4.0f;
    return self.initialHeight + self.font.lineHeight * (self.maxNumberOfLinesToDisplay - 1) + buffer;
}

#pragma mark -- private methods
- (void)commenInit {
    self.initialHeight = [self calculateInitialHeight];
    self.maxNumberOfLinesToDisplay = 4;
    //Apple said The default is NO. Do not believe it!!!
    self.layoutManager.allowsNonContiguousLayout = NO;
    self.textColor = DWDColorContent;
    self.backgroundColor = DWDColorBackgroud;
    self.layer.borderColor = DWDColorContent.CGColor;
    self.layer.borderWidth = .5;
    self.layer.cornerRadius = 5.0;
}

- (void)setLineNumberToStopGrowing:(NSInteger)number {
    _maxNumberOfLinesToDisplay = number;
    _initialHeight = [self calculateInitialHeight];
}

- (CGFloat)calculateInitialHeight {
    NSString *text = self.text;
    self.text = @" ";
    CGSize size = [self sizeThatFits:CGSizeMake(self.bounds.size.width, 9999.0)];
    self.text = text;
    return size.height;
}

- (void)showMenuWithTitles:(NSArray *)titles rect:(CGRect)rect tableView:(UITableView *)tableView cell:(DWDInteractiveChatCell *)cell{
    
    _cell= cell;
    _isCellLongPressCallMenu = YES;
    
    _titles = titles;
    _tableView = tableView;
    _rect = rect;
    
    UIMenuController *menu = [UIMenuController sharedMenuController];
    
    NSMutableArray *items = [NSMutableArray array];
    for (int i = 0; i < titles.count; i++) {
        NSString *title = titles[i];
        
        if ([title isEqualToString:@"Revoke"]) { // 满足条件则显示撤销
            double abc = [NSDate date].timeIntervalSince1970;
            long long interval = (long long)abc;
            long long longTypeCreateTime = (long long)[cell.createTime longLongValue] /1000;
            if ((interval - longTypeCreateTime <= 120) && cell.status == DWDChatCellStatusNormal) {
                NSString *selName = [title stringByAppendingString:@":"];
                SEL sel = NSSelectorFromString(selName);
                UIMenuItem *item = [[UIMenuItem alloc] initWithTitle:NSLocalizedString(title, nil) action:sel];
                [items addObject:item];
            }else{
                continue;
            }
        }else{
            NSString *selName = [title stringByAppendingString:@":"];
            SEL sel = NSSelectorFromString(selName);
            UIMenuItem *item = [[UIMenuItem alloc] initWithTitle:NSLocalizedString(title, nil) action:sel];
            [items addObject:item];
        }
    }
    
    [menu setMenuItems:items];
    
    [menu setTargetRect:rect inView:tableView];
    
    [menu setMenuVisible:YES animated:YES];
    [menu setMenuItems:nil];
}

- (void)menuWillShow:(NSNotification *)note{
    
    if (!self.isFirstResponder) return;
    
    if (_isCellLongPressCallMenu) {
        
        _isCellLongPressCallMenu = NO;
        _isMenuItemClick = YES;
        
        NSMutableArray *items = [NSMutableArray array];
        for (int i = 0; i < _titles.count; i++) {
            NSString *title = _titles[i];
            NSString *selName = [title stringByAppendingString:@":"];
            SEL sel = NSSelectorFromString(selName);
            UIMenuItem *item = [[UIMenuItem alloc] initWithTitle:NSLocalizedString(title, nil) action:sel];
            [items addObject:item];
        }
        
        UIMenuController *menu = [UIMenuController sharedMenuController];
        [menu setMenuItems:items];
        
        [menu setTargetRect:_rect inView:_tableView];
        [menu setMenuItems:nil];
        
    }else{
        if (self.text.length == 0) {
            
        }else{  // text 有值
            UIMenuController *menu = [UIMenuController sharedMenuController];
            // 检查是否有选中文本
            if (self.selectedRange.length > 0) {
                UIMenuItem *item = [[UIMenuItem alloc] initWithTitle:NSLocalizedString(@"Copy", nil) action:@selector(copy:)];
                UIMenuItem *item1 = [[UIMenuItem alloc] initWithTitle:NSLocalizedString(@"Paste", nil) action:@selector(paste:)];
                UIMenuItem *item2 = [[UIMenuItem alloc] initWithTitle:NSLocalizedString(@"Cut", nil) action:@selector(cut:)];
                UIMenuItem *item3 = [[UIMenuItem alloc] initWithTitle:NSLocalizedString(@"delete", nil) action:@selector(delete:)];
                
                [menu setMenuItems:@[item , item1 , item2 , item3]];
            }else{
            }
            
        }
        
    }
    
}

- (void)menuDidShow:(NSNotification *)note{
    UIMenuController *menu = [UIMenuController sharedMenuController];
    [menu setMenuItems:nil];
}

- (BOOL)canBecomeFirstResponder {
    return YES;
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender {
    
    if (_isCellLongPressCallMenu) {
        
        return (action == @selector(Copy:) ||
                action == @selector(Relay:) ||
                action == @selector(Collect:) ||
                action == @selector(Delete:) ||
                action == @selector(Revoke:) ||
                action == @selector(More:));
        
    }else{
        
        if (_isMenuItemClick) {
            _isMenuItemClick = NO;
            return (action == @selector(Copy:) ||
                    action == @selector(Relay:) ||
                    action == @selector(Collect:) ||
                    action == @selector(Delete:) ||
                    action == @selector(Revoke:) ||
                    action == @selector(More:));
            
        }else{
            if (self.text.length == 0) {
                return action == @selector(paste:);
            }else{
                if (self.selectedRange.length > 0) {
                    return (action == @selector(copy:) ||
                            action == @selector(paste:) ||
                            action == @selector(cut:) ||
                            action == @selector(delete:));
                }else{
                    return (action == @selector(paste:) ||
                            action == @selector(select:) ||
                            action == @selector(selectAll:));
                }
            }
        }
        
    }
    
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    _isMenuItemClick = NO;
}

- (void)Copy:(id)sender {
    if (self.growingTextViewDelegate && [self.growingTextViewDelegate respondsToSelector:@selector(interactiveChatCellDidCopyWithCell:)]) {
        [self.growingTextViewDelegate interactiveChatCellDidCopyWithCell:self.cell];
    }
}

- (void)Relay:(id)sender {
    if (self.growingTextViewDelegate && [self.growingTextViewDelegate respondsToSelector:@selector(interactiveChatCellDidRelayWithCell:)]) {
        [self.growingTextViewDelegate interactiveChatCellDidRelayWithCell:self.cell];
    }
}

- (void)Collect:(id)sender {
    if (self.growingTextViewDelegate && [self.growingTextViewDelegate respondsToSelector:@selector(interactiveChatCellDidCollectWithCell:)]) {
        [self.growingTextViewDelegate interactiveChatCellDidCollectWithCell:self.cell];
    }
}

- (void)Delete:(id)sender {
    if (self.growingTextViewDelegate && [self.growingTextViewDelegate respondsToSelector:@selector(interactiveChatCellDidDeleteWithCell:)]) {
        [self.growingTextViewDelegate interactiveChatCellDidDeleteWithCell:self.cell];
    }
}

- (void)Revoke:(id)sender {
    if (self.growingTextViewDelegate && [self.growingTextViewDelegate respondsToSelector:@selector(interactiveChatCellDidRevokeWithCell:)]) {
        [self.growingTextViewDelegate interactiveChatCellDidRevokeWithCell:self.cell];
    }
}

- (void)More:(id)sender {
    if (self.growingTextViewDelegate && [self.growingTextViewDelegate respondsToSelector:@selector(interactiveChatCellDidClickMoreWithCell:)]) {
        [self.growingTextViewDelegate interactiveChatCellDidClickMoreWithCell:self.cell];
    }
}

- (void)delete:(id)sender{
    self.text = [self.text stringByReplacingCharactersInRange:self.selectedRange withString:@""];
    
}


- (UIMenuItem *)pasteItem{
    if (!_pasteItem) {
        _pasteItem = [[UIMenuItem alloc] initWithTitle:NSLocalizedString(@"Paste", nil) action:@selector(paste:)];
    }
    return _pasteItem;
}

@end

//
//  DWDClassChatTopView.m
//  EduChat
//
//  Created by Superman on 15/11/20.
//  Copyright © 2015年 dwd. All rights reserved.
//

#import "DWDClassChatTopView.h"
#import "DWDLastNoteModel.h"

#import <Masonry.h>
@interface DWDClassChatTopView()

@property (nonatomic , weak) IBOutlet UILabel *topLabel;
@property (nonatomic , weak) IBOutlet UILabel *midLabel;
@property (nonatomic , weak) IBOutlet UILabel *bottomLabel;

@end

@implementation DWDClassChatTopView

- (void)awakeFromNib{
    self.backgroundColor = [UIColor clearColor];
    
    _topLabel.font = DWDFontMin;
    _topLabel.textColor = DWDRGBColor(195, 195, 195);
    _midLabel.font = DWDFontBody;
    _midLabel.textColor = [UIColor blackColor];
    _bottomLabel.font = DWDFontMin;
    _bottomLabel.textColor = DWDRGBColor(195, 195, 195);
}

- (instancetype)initWithFrame:(CGRect)frame{
    
    if (self = [super initWithFrame:frame]) {
        
    }
    return self;
}


- (void)setLastNote:(DWDLastNoteModel *)lastNote{
    
    _lastNote = lastNote;
    _topLabel.text = lastNote.last.title;
    _midLabel.text = lastNote.last.content;
    _bottomLabel.text = lastNote.last.creatTime;
    
}

@end

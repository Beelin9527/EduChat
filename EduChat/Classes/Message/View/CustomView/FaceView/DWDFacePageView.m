//
//  DWDFacePageView.m
//  EduChat
//
//  Created by Gatlin on 16/1/13.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import "DWDFacePageView.h"

#define kFaceCol 7
#define kFaceItemW 40
#define kFacePaddingLeft  (DWDScreenW - kFaceItemW * kFaceCol) / (kFaceCol + 1)  //左右间隙
#define kFacePaddingTop  (160 - kFaceItemW * 3) / (4)       //上下间隙
@interface DWDFacePageView ()

@property (strong, nonatomic) NSArray *arrFaceFalg;
@end
@implementation DWDFacePageView

- (instancetype)initWithArrayFace:(NSArray *)arrayFace
{
    self = [super init];
    if (self) {

        self.arrFaceFalg = arrayFace;
        
        //show face
        [self showFace:arrayFace];
        
          }
    return self;
}

- (void)showFace:(NSArray *)arrayFace
{
    int col = 0;
    int row = 0;
    
    for (int j = 0;j < arrayFace.count / 20; j ++) {
        NSArray *tempArray = [arrayFace subarrayWithRange:NSMakeRange(j * 20, 20)];
        
        for (NSInteger i = 0 ; i < [tempArray count] + 1; i ++) {
            
            NSDictionary *dict;
            if (i <[tempArray count]){
                
                dict = tempArray[i];
            }
            
            col = i % kFaceCol;
            row = i / kFaceCol;
            int x = (kFacePaddingLeft) * (col+1) + kFaceItemW *col + j * DWDScreenW;
            int y = (kFacePaddingTop) * (row+1) + kFaceItemW *row;
            
            UIButton *faceItem;
            if ( i < [tempArray count]) {
                
                faceItem = [UIButton buttonWithType:UIButtonTypeCustom];
                [faceItem setImage:[UIImage imageNamed:dict[@"faceName"]] forState:UIControlStateNormal];
                faceItem.frame = CGRectMake(x, y, kFaceItemW, kFaceItemW);
                faceItem.tag = i + j*20;
                [faceItem addTarget:self action:@selector(didSelectPace:) forControlEvents:UIControlEventTouchUpInside];
                
            }else if (i == [tempArray count]){
                
                faceItem = [UIButton buttonWithType:UIButtonTypeCustom];
                [faceItem setImage:[UIImage imageNamed:@"[删除]"] forState:UIControlStateNormal];
                faceItem.frame = CGRectMake(x, y, kFaceItemW, kFaceItemW);
                [faceItem addTarget:self action:@selector(didSelectDelete) forControlEvents:UIControlEventTouchUpInside];
            }
            
            [self addSubview:faceItem];
        }
    }
}
#pragma mark - Button Action
- (void)didSelectPace:(UIButton *)sender
{
   NSDictionary *dict = self.arrFaceFalg[sender.tag];
    
    if (self.delegateFace && [self.delegateFace respondsToSelector:@selector(facePageView:didSelectPace:)]) {
        
        [self.delegateFace facePageView:self didSelectPace:dict[@"faceName"]];
    }
    
}

- (void)didSelectDelete
{
    if (self.delegateFace && [self.delegateFace respondsToSelector:@selector(facePageViewDidSelectDelete:)]) {
        
        [self.delegateFace facePageViewDidSelectDelete:self];
    }
}
@end

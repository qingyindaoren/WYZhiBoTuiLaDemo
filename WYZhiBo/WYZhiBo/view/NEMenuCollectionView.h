//
//  NEMenuCollectionView.h
//  LSMediaCaptureDemo
//
//  Created by taojinliang on 16/9/6.
//  Copyright © 2016年 NetEase. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum ModelBtnType{
    ModelBtnTypeAudio,
    ModelBtnTypeFilter,
    ModelBtnTypeInterest,
    ModelBtnTypeWaterMark,
}ModelBtnType;


@protocol DidSelectItemAtIndexPathDelegate <NSObject>
-(void)didSelectItem:(ModelBtnType)modelBtnType itemAtIndexPath:(NSInteger)item type:(NSInteger)type;
@end

@interface NEMenuCollectionView : UIView
@property(nonatomic, weak) id<DidSelectItemAtIndexPathDelegate> didSelDelegate;
-(void)reloadData:(ModelBtnType)modelBtnType;
@end

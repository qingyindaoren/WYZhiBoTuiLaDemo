//
//  NEMenuCollectionCell.m
//  LSMediaCaptureDemo
//
//  Created by taojinliang on 16/9/6.
//  Copyright © 2016年 NetEase. All rights reserved.
//

#import "NEMenuCollectionCell.h"
#import "NEInternalMacro.h"

@implementation NEMenuCollectionCell

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        CGFloat viewW = frame.size.width;
        CGFloat btnW = UIScale(28);
        CGFloat lblW = UIScale(60);
        self.frame=CGRectMake(0, 0,viewW, UIScale(77));
        self.iconImageView=[[UIImageView alloc] initWithFrame:CGRectMake(viewW/2.0-btnW/2.0, UIScale(15), btnW,btnW)];
        self.titleLable=[[UILabel alloc] initWithFrame:CGRectMake(viewW/2.0-lblW/2.0,CGRectGetMaxY(self.iconImageView.frame)+UIScale(10), lblW, UIScale(15))];
        [self.titleLable setTextColor:[UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:0.3]];
        [self.titleLable setTextAlignment:NSTextAlignmentCenter];
        self.titleLable.font=[UIFont systemFontOfSize:13];
        self.seperateBar=[[UIView alloc] initWithFrame:CGRectMake(viewW-UIScale(1), 0, UIScale(1), UIScale(77))];
        self.seperateBar.backgroundColor=[UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:0.1];
        [self.contentView addSubview:self.iconImageView];
        [self.contentView addSubview:self.titleLable];
        [self.contentView addSubview:self.seperateBar];
        self.contentView.backgroundColor = [UIColor blackColor];
    }
    return self;
}
@end

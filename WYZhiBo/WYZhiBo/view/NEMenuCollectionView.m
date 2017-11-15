//
//  NEMenuCollectionView.m
//  LSMediaCaptureDemo
//
//  Created by taojinliang on 16/9/6.
//  Copyright © 2016年 NetEase. All rights reserved.
//

#import "NEMenuCollectionView.h"
#import "NEMenuCollectionCell.h"
#import "nMediaLiveStreamingDefs.h"
#import "NEInternalMacro.h"

@interface NEMenuCollectionView()<UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout>
@property(nonatomic, strong) UICollectionView *mainCollectionView;
//存储滤镜的名称
@property (copy, nonatomic) NSArray* filterDataSource;
//存储icon名称
@property (copy, nonatomic) NSArray *filterIconDataSource;
//存储伴音的名称
@property (copy, nonatomic) NSArray* audioDataSource;
//存储伴音icon名称
@property (copy, nonatomic) NSArray *audioIconSource;
//人脸名称
@property (strong, nonatomic) NSArray *faceMarkData;
//存储人脸icon名称
@property (strong, nonatomic) NSArray *faceIconMarkData;
//存储水印的类别名称
@property(nonatomic, copy) NSArray *waterMarkData;

@property(nonatomic, copy) NSArray *waterMarkIconData;



@property (nonatomic, assign) ModelBtnType modelBtnType;
@end

@implementation NEMenuCollectionView

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.filterDataSource = @[
                                  @{@"name":@"普通",@"type":@(LS_GPUIMAGE_NORMAL)},
                                  @{@"name":@"自然",@"type":@(LS_GPUIMAGE_ZIRAN)},
                                  @{@"name":@"粉嫩",@"type":@(LS_GPUIMAGE_MEIYAN1)},
                                  @{@"name":@"怀旧",@"type":@(LS_GPUIMAGE_MEIYAN2)},
                                  @{@"name":@"黑白",@"type":@(LS_GPUIMAGE_SEPIA)},
                                  ];
        self.filterIconDataSource  = @[@"icon_pt",@"icon_na",@"icon_fn",@"icon_hj",@"icon_bw"];
        self.audioDataSource = @[@"无伴音",@"伴音1",@"伴音2"];
        self.audioIconSource = @[@"audio0",@"audio1",@"audio2"];
        
        self.faceMarkData = [[NSArray alloc] initWithObjects:
                             @"关闭",
                             @"海绵宝宝",
                             @"墨镜",
                             @"兔子",
                             @"小草",
                             @"葫芦娃",
                             @"大眼睛",
                             nil
                             ];
        self.faceIconMarkData = @[@"normal",@"eye1",@"sunglasses",@"ear",@"leaf",@"gourd",@"eye"];
        
        self.waterMarkData = @[@"无水印", @"静态水印", @"动态水印"];
        self.waterMarkIconData = @[@"normal", @"leaf", @"leaf"];
        
        //1.初始化layout
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        //设置collectionView滚动方向
        [layout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
        
        //2.初始化collectionView
        _mainCollectionView = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:layout];
        [self addSubview:_mainCollectionView];
        _mainCollectionView.backgroundColor = [UIColor clearColor];
        _mainCollectionView.bounces = NO;
        _mainCollectionView.showsHorizontalScrollIndicator = NO;
        
        //3.注册collectionViewCell
        //注意，此处的ReuseIdentifier 必须和 cellForItemAtIndexPath 方法中 一致 均为 cellId
        [_mainCollectionView registerClass:[NEMenuCollectionCell class] forCellWithReuseIdentifier:@"cellId"];
        
        //4.设置代理
        _mainCollectionView.delegate = self;
        _mainCollectionView.dataSource = self;
    }
    return self;
}

-(void)reloadData:(ModelBtnType)modelBtnType
{
    self.modelBtnType = modelBtnType;
    [_mainCollectionView reloadData];
}

#pragma mark collectionView代理方法
//返回section个数
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

//每个section的item个数
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    NSInteger numOfItems = 0;
    switch (self.modelBtnType) {
        case ModelBtnTypeAudio:
            numOfItems = [self.audioIconSource count];
            break;
        case ModelBtnTypeFilter:
            numOfItems = [self.filterIconDataSource count];
            break;
        case ModelBtnTypeInterest:
            numOfItems = [self.faceMarkData count];
            break;
        case ModelBtnTypeWaterMark:
            numOfItems = [self.waterMarkData count];
            break;
        default:
            numOfItems = [self.filterIconDataSource count];
            break;
    }
    return numOfItems;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    NEMenuCollectionCell *cell = (NEMenuCollectionCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"cellId" forIndexPath:indexPath];
    
    if (cell == nil) {
        cell = [[NEMenuCollectionCell alloc] init];
    }
    
    if (cell.selected == YES) {
        cell.contentView.backgroundColor = [UIColor grayColor];
    }else{
        cell.contentView.backgroundColor = [UIColor blackColor];
    }
    
    
    switch (self.modelBtnType) {
        case ModelBtnTypeAudio:
        {
            cell.titleLable.text = [self.audioDataSource objectAtIndex:indexPath.item];
            cell.iconImageView.image = [UIImage imageNamed:[self.audioIconSource objectAtIndex:indexPath.item]];
            if (indexPath.item == 0) {
                cell.contentView.backgroundColor = [UIColor grayColor];
            }else{
                cell.contentView.backgroundColor = [UIColor blackColor];
            }
        }
            break;
        case ModelBtnTypeFilter:
        {
            cell.titleLable.text = [self.filterDataSource objectAtIndex:indexPath.item][@"name"];
            cell.iconImageView.image = [UIImage imageNamed:[self.filterIconDataSource objectAtIndex:indexPath.item]];
        }
            break;
        case ModelBtnTypeInterest:
        {
            cell.titleLable.text = [self.faceMarkData objectAtIndex:indexPath.item];
            cell.iconImageView.image = [UIImage imageNamed:[self.faceIconMarkData objectAtIndex:indexPath.item]];
        }
            break;
        case ModelBtnTypeWaterMark:
        {
            cell.titleLable.text = [self.waterMarkData objectAtIndex:indexPath.item];
            cell.iconImageView.image = [UIImage imageNamed:[self.waterMarkIconData objectAtIndex:indexPath.item]];
        }
            break;
        default:
        {
            cell.titleLable.text = [self.filterDataSource objectAtIndex:indexPath.item][@"name"];
            cell.iconImageView.image = [UIImage imageNamed:[self.filterIconDataSource objectAtIndex:indexPath.item]];
        }
            break;
    }
    
    return cell;
}

//设置每个item的尺寸
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGSize size = CGSizeZero;
    switch (self.modelBtnType) {
        case ModelBtnTypeAudio:
        {
            size = CGSizeMake(ceil(UIScreenWidth/3.0), UIScale(77));
        }
            break;
        case ModelBtnTypeFilter:
        {
            size = CGSizeMake(ceil(UIScale(80)), UIScale(77));
        }
            break;
        case ModelBtnTypeInterest:
        {
            size = CGSizeMake(ceil(UIScale(80)), UIScale(77));
        }
            break;
        case ModelBtnTypeWaterMark:
        {
            size = CGSizeMake(ceil(UIScreenWidth/3.0), UIScale(77));
        }
            break;
        default:
        {
            size = CGSizeMake(ceil(UIScale(80)), UIScale(77));
        }
            break;
    }
    return size;
}


//设置每个item的UIEdgeInsets
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsZero;
}

//设置每个item水平间距
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 0;
}


//设置每个item垂直间距
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 0;
}

//点击item方法
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NEMenuCollectionCell *cell = (NEMenuCollectionCell *)[collectionView cellForItemAtIndexPath:indexPath];
    
    NSInteger type = 0;
    NSMutableArray *array;
    switch (self.modelBtnType) {
        case ModelBtnTypeAudio:
        {
            array = [NSMutableArray arrayWithArray:self.audioDataSource];
        }
            break;
        case ModelBtnTypeFilter:
        {
            array = [NSMutableArray arrayWithArray:self.filterDataSource];
            type = [[[self.filterDataSource objectAtIndex:indexPath.item] objectForKey:@"type"] integerValue];
        }
            break;
        case ModelBtnTypeInterest:
        {
            array = [NSMutableArray arrayWithArray:self.faceMarkData];
        }
            break;
        case ModelBtnTypeWaterMark:
        {
            array = [NSMutableArray arrayWithArray:self.waterMarkData];
        }
            break;
        default:
        {
            array = [NSMutableArray arrayWithArray:self.filterDataSource];
        }
            break;
    }
    
    
    if (cell.selected) {
        cell.contentView.backgroundColor = [UIColor grayColor];
    }
    
    for (NSInteger i = 0; i < [array count]; i++) {
        if (i != indexPath.item) {
            NSIndexPath* indexPath1 = [NSIndexPath indexPathForItem:i inSection:0];
            NEMenuCollectionCell *cell1 = (NEMenuCollectionCell *)[collectionView cellForItemAtIndexPath:indexPath1];
            cell1.contentView.backgroundColor = [UIColor blackColor];
        }
    }
    
    if (self.didSelDelegate && [self.didSelDelegate respondsToSelector:@selector(didSelectItem:itemAtIndexPath:type:)]) {
        [self.didSelDelegate didSelectItem:self.modelBtnType itemAtIndexPath:indexPath.item type:type];
    }
}

@end

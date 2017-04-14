//
//  MLPicturesShow.h
//  Huihui
//
//  Created by 伟凯   刘 on 2017/4/14.
//  Copyright © 2017年 pg. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface MLPicturesShow : NSObject
/*
 parms:imagesArray 要显示的图片地址
 parms:index 默认显示第几张图片
 */
- (void)createScrollView:(NSInteger)index andImagesArray:(NSArray *)imagesArray;
@end


@interface MLPicturesShowView : UIView

@property(nonatomic,strong)NSArray * imageStrArray;
- (instancetype)initWithFrame:(CGRect)frame andWithSelectIndex:(NSInteger)index;
@end

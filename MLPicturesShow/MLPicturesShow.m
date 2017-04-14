//
//  MLPicturesShow.m
//  Huihui
//
//  Created by 伟凯   刘 on 2017/4/14.
//  Copyright © 2017年 pg. All rights reserved.
//

#import "MLPicturesShow.h"

@interface MLPicturesShow()
@property(nonatomic,strong)MLPicturesShowView * view;

@end
@implementation MLPicturesShow

- (void)createScrollView:(NSInteger)index andImagesArray:(NSArray *)imagesArray{
    self.view = [[MLPicturesShowView alloc] initWithFrame:[UIScreen mainScreen].bounds andWithSelectIndex:index];
    self.view.imageStrArray = imagesArray;
    UIApplication *app = [UIApplication sharedApplication];
    [app.keyWindow addSubview:self.view];
    
}
@end

@interface MLPicturesShowView()<UIScrollViewDelegate,UIGestureRecognizerDelegate>

@property(nonatomic,assign)NSInteger selectIndex;
@property(nonatomic,strong)UIScrollView * rotatScrollView;
@property(nonatomic,strong)UIPageControl * pageControl;
@property(nonatomic,assign)CGRect detailRect;
@property(nonatomic,strong)NSMutableArray * imageViewFrameArray;
@property(nonatomic,strong)NSMutableArray * imageViewArray;
@property(nonatomic,assign)BOOL isAmplification;
@property(nonatomic,strong)UILabel * promptLable;
@property(nonatomic,strong)UIImage * saveImage;
@end
@implementation MLPicturesShowView

- (NSMutableArray *)imageViewFrameArray{
    if (!_imageViewFrameArray   ){
        _imageViewFrameArray = [[NSMutableArray alloc] init];
    }
    return _imageViewFrameArray ;
}
- (NSMutableArray *)imageViewArray{
    if (!_imageViewArray){
        _imageViewArray = [[NSMutableArray alloc] init];
    }
    return _imageViewArray;
}
- (instancetype)initWithFrame:(CGRect)frame andWithSelectIndex:(NSInteger)index{
    self = [super initWithFrame:frame];
    if (self){
        self.backgroundColor = [UIColor blackColor];
        _selectIndex = index;
        _detailRect = frame;
        [self basisUI];
    }
    return self;
}
- (void)setImageStrArray:(NSArray *)imageStrArray{
    _imageStrArray = imageStrArray;
    [self basisUI];
}
- (void)basisUI{
    if (_imageStrArray.count > 0){
        self.pageControl = [[UIPageControl   alloc] initWithFrame:CGRectMake(0, self.detailRect.size.height - 50, self.detailRect.size.width, 30)];
        self.pageControl.numberOfPages = self.imageStrArray.count;
        self.pageControl.currentPage = 0;
        self.pageControl.currentPageIndicatorTintColor = [UIColor whiteColor];
        self.pageControl.pageIndicatorTintColor = [UIColor colorWithRed:210/255.0 green:210/255.0 blue:210/255.0 alpha:1];
        [self addSubview:self.pageControl];
        
        self.rotatScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.detailRect.size.width, self.detailRect.size.height)];
        self.rotatScrollView.showsVerticalScrollIndicator = NO;
        self.rotatScrollView.showsHorizontalScrollIndicator = NO;
        self.rotatScrollView.pagingEnabled = YES;
        self.rotatScrollView.delegate = self;
        self.rotatScrollView.contentSize = CGSizeMake(self.detailRect.size.width * self.imageStrArray.count, 0);
        [self addSubview:self.rotatScrollView];
        self.rotatScrollView.backgroundColor = [UIColor clearColor];
        [self.imageViewArray removeAllObjects];
        [self.imageViewFrameArray removeAllObjects];
        for (int i = 0 ; i < self.imageStrArray.count; i ++){
            CGFloat width = [UIScreen mainScreen].bounds.size.width;
            CGFloat height = [UIScreen mainScreen].bounds.size.height;
            UIImageView * subImageView = [[UIImageView alloc] initWithFrame:CGRectMake(self.detailRect.size.width * i, (self.detailRect.size.height/2) - (height/(width/self.detailRect.size.width))/2, self.detailRect.size.width, height/(width/self.detailRect.size.width))];
            subImageView.image = [UIImage imageNamed:@"meeting330*300"];
            UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(removeDetailView:)];
            UIPinchGestureRecognizer * pinch = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchEvent:)];
            UITapGestureRecognizer * tapTwo = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapTwoAction:)];
            tapTwo.numberOfTapsRequired = 2;
            [tap requireGestureRecognizerToFail:tapTwo];
            subImageView.userInteractionEnabled = YES;
            [subImageView addGestureRecognizer:tap];
            [subImageView addGestureRecognizer:pinch];
            [subImageView addGestureRecognizer:tapTwo];
            [self.rotatScrollView addSubview:subImageView];
            [self.imageViewArray addObject:subImageView];
            [self.imageViewFrameArray addObject:[NSValue valueWithCGRect:subImageView.frame]];
        }
        for (int i = 0 ; i < self.imageViewArray.count; i ++){
            UIImageView * MLImageVIew = (UIImageView *)self.imageViewArray[i];

            NSData * data = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:self.imageStrArray[i]]];
            
            UIImage * image = [UIImage imageWithData:data];
            MLImageVIew.image = image;
            if (image){
                 [self pictureLayoutWithImage:image andWithIndex:i];
            }
        }
        CGPoint point = CGPointMake(self.detailRect.size.width * self.selectIndex, 0);
        self.rotatScrollView.contentOffset = point;
    }
}
- (void)pictureLayoutWithImage:(UIImage *)image andWithIndex:(NSInteger)i{
    CGFloat height = image.size.height;
    CGFloat width = image.size.width;
    UIImageView * MLImageVIew = (UIImageView *)self.imageViewArray[i];
    MLImageVIew.frame = CGRectMake(self.detailRect.size.width * i, (self.detailRect.size.height/2) - (height/(width/self.detailRect.size.width))/2, self.detailRect.size.width, height/(width/self.detailRect.size.width));
    self.imageViewFrameArray[i] = [NSValue valueWithCGRect:MLImageVIew.frame];
    dispatch_async(dispatch_get_main_queue(), ^{
        MLImageVIew.image = image;
        UILongPressGestureRecognizer * longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longGesAction:)];
        [MLImageVIew addGestureRecognizer:longPress];
    });
}
- (void)longGesAction:(UIGestureRecognizer *)ges{
    if (ges.state == UIGestureRecognizerStateBegan){
        
        _promptLable = [[UILabel alloc] initWithFrame:CGRectMake(0, self.detailRect.size.height - 49, self.detailRect.size.width, 49)];
        _promptLable.backgroundColor = [UIColor whiteColor];
        _promptLable.textAlignment = NSTextAlignmentCenter;
        _promptLable.text = @"保存到相册";
        _promptLable.textColor = [UIColor grayColor];
        [self addSubview:_promptLable];
        _promptLable.userInteractionEnabled = YES;
          UIImageView * imageView = (UIImageView *)ges.view;
        _saveImage = imageView.image;
        UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(savePic:)];
        [_promptLable addGestureRecognizer:tap];
    }
}
- (void)savePic:(UIGestureRecognizer *)ges{
    if (self.promptLable){
        [self.promptLable removeFromSuperview];
    }
    if (self.saveImage){
         UIImageWriteToSavedPhotosAlbum(self.saveImage,self,@selector(image:didFinishSavingWithError:contextInfo:),nil);
    }
    
}
#pragma mark 保存图片后的回调
- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    NSString*message =@"";
    if (!error){
        message =@"成功保存到相册";
    }else{
        message = [error description];
    }
   UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:@"温馨提示" message:message delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
    [alertView show];
}
- (void)pinchEvent:(UIPinchGestureRecognizer *)pinch {
    CGPoint point = pinch.view.center;
    static CGRect frame;
    if (pinch.state == UIGestureRecognizerStateBegan) {
        frame = pinch.view.frame;
    }
    self.isAmplification = YES;
    self.rotatScrollView.scrollEnabled = NO;
    if ( [UIApplication  sharedApplication].statusBarOrientation == UIInterfaceOrientationPortrait){
        if (frame.size.height * pinch.scale >= self.detailRect.size.height * 2.5){
            return;
        }
    }else{
        if (frame.size.width * pinch.scale >= self.detailRect.size.width * 2.5){
            return;
        }
    }
    CGFloat _widths = frame.size.width * pinch.scale;
    CGFloat _heights = frame.size.height * pinch.scale;
    pinch.view.frame = CGRectMake(frame.origin.x, frame.origin.y, _widths, _heights);
    pinch.view.center = point;
    if (pinch.state == UIGestureRecognizerStateEnded){
        if ( [UIApplication  sharedApplication].statusBarOrientation == UIInterfaceOrientationPortrait){
            if (pinch.view.frame.size.width < self.detailRect.size.width){
                for (NSInteger i = 0; i < self.imageViewArray.count; i ++){
                    
                    if ([pinch.view isEqual:self.imageViewArray[i]]){
                        [UIView animateWithDuration:0.3 animations:^{
                            pinch.view.frame = [self.imageViewFrameArray[i] CGRectValue];
                        }];
                    }
                }
                self.isAmplification = NO;
                 self.rotatScrollView.scrollEnabled = YES;
            }
        }else{
            if (pinch.view.frame.size.width < self.detailRect.size.width){
                for (NSInteger i = 0; i < self.imageViewArray.count; i ++){
                    if ([pinch.view isEqual:self.imageViewArray[i]]){
                        [UIView animateWithDuration:0.3 animations:^{
                            pinch.view.frame = [self.imageViewFrameArray[i] CGRectValue];
                        }];
                    }
                }
                self.isAmplification = NO;
            }
        }
    }
}
- (void)tapTwoAction:(UIGestureRecognizer *)ges{
    if (self.promptLable){
        [self.promptLable removeFromSuperview];
    }
    self.isAmplification = YES;
    static CGRect frame;
    CGPoint point = ges.view.center;
    frame = ges.view.frame;
    if ([UIApplication  sharedApplication].statusBarOrientation == UIInterfaceOrientationPortrait){
        if (frame.size.height >= self.detailRect.size.height * 2.5){
            return;
        }
    }else{
        if (frame.size.width >= self.detailRect.size.width * 2.5){
            return;
        }
    }
    CGFloat _widths = frame.size.width * 1.3;
    CGFloat _heights = frame.size.height * 1.3;
    [UIView animateWithDuration:0.2 animations:^{
        ges.view.frame = CGRectMake(frame.origin.x, frame.origin.y, _widths, _heights);
        ges.view.center = point;
    }];
    
}
- (void)removeDetailView:(UIGestureRecognizer *)ges{
    if (self.promptLable){
        [self.promptLable removeFromSuperview];
    }
    if (self.isAmplification == YES){
        
        for (NSInteger i  = 0 ;i < self.imageViewArray.count; i ++){
            
            UIImageView * imageView = (UIImageView *)self.imageViewArray[i];
            imageView.frame = [self.imageViewFrameArray[i] CGRectValue];
        }
        self.isAmplification = NO;
        self.rotatScrollView.scrollEnabled = YES;
    }else{
        if ([UIApplication  sharedApplication].statusBarOrientation != UIInterfaceOrientationPortrait){
            return;
        }
        if (self){
            [UIView animateWithDuration:0.4 animations:^{
                
                self.alpha = 0.00;
            } completion:^(BOOL finished) {
                [self.pageControl removeFromSuperview];
                [self.rotatScrollView removeFromSuperview];
                [self removeFromSuperview];
                self.rotatScrollView = nil;
                self.pageControl = nil;
            }];
        }
//        NSNotificationCenter * center = [NSNotificationCenter defaultCenter];
//        [center postNotificationName:@"Islandscape" object:nil];
    }
}
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    if (self.promptLable){
        [self.promptLable removeFromSuperview];
    }
    self.isAmplification = NO;
    
    NSInteger index = scrollView.contentOffset.x/self.detailRect.size.width;
    self.pageControl.currentPage = index;
    [self bringSubviewToFront:self.pageControl];
    self.selectIndex = index;
}
@end

//
//  ViewController.m
//  pictureComposed
//
//  Created by 明镜止水 on 17/1/19.
//  Copyright © 2017年 明镜止水. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@property (nonatomic, strong) UIImageView *imagView;

@property (nonatomic, strong) NSMutableArray<UIImage *>*imageArr;

@property (nonatomic, strong) UIImageView *tempImage;

@property (nonatomic, strong) UIImageView *boaderImage;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
   
    [self composeImg:self.imagView.bounds.size andPictures:self.imageArr andColums:2.0];
    
    
    CGRect rect = CGRectMake(100, 100, 80, 80);
    _boaderImage = [[UIImageView alloc] initWithFrame:rect];
    _boaderImage.backgroundColor = [UIColor redColor];
    _boaderImage.hidden = YES;
    [self.imagView addSubview:_boaderImage];
    
    
    
    self.tempImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tabBar1_hightLight"]];
    
    [self.view addSubview:self.tempImage];
    
    self.tempImage.center = CGPointMake(50, 300);
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(panImage:)];
    
    //打开图片交互
    [self.tempImage setUserInteractionEnabled:YES];
    [self.tempImage addGestureRecognizer:pan];
    
    CGPoint convertPoint = [self.view convertPoint:self.tempImage.center toView:self.imagView];
    
    NSLog(@"%@",NSStringFromCGPoint(convertPoint));
   
}

#pragma mark - 添加手势
-(void)panImage:(UIPanGestureRecognizer *)rec{
    
    CGFloat KWidth = [UIScreen mainScreen].bounds.size.width;
    CGFloat KHeight = [UIScreen mainScreen].bounds.size.height;
    
    //返回在横坐标上、纵坐标上拖动了多少像素
    CGPoint point=[rec translationInView:self.view];
    
    CGFloat centerX = rec.view.center.x+point.x;
    CGFloat centerY = rec.view.center.y+point.y;
    
    CGFloat viewHalfH = rec.view.frame.size.height/2;
    CGFloat viewhalfW = rec.view.frame.size.width/2;
    
    //确定特殊的centerY
    if (centerY - viewHalfH < 0 ) {
        centerY = viewHalfH;
    }
    if (centerY + viewHalfH > KHeight ) {
        centerY = KHeight - viewHalfH;
    }
    
    //确定特殊的centerX
    if (centerX - viewhalfW < 0){
        centerX = viewhalfW;
    }
    if (centerX + viewhalfW > KWidth){
        centerX = KWidth - viewhalfW;
    }
    rec.view.center=CGPointMake(centerX, centerY);
    //拖动完之后，每次都要用setTranslation:方法制0这样才不至于不受控制般滑动出视图
    [rec setTranslation:CGPointMake(0, 0) inView:self.view];
    
    CGRect rect = CGRectMake(100, 100, 80, 80);
    /*
    _boaderImage.hidden = YES;
    //转化为相对点
    CGPoint convertPoint = [self.view convertPoint:self.tempImage.center toView:self.imagView];
    CGRect rect = CGRectMake(100, 100, 80, 80);
    //判断点在是否在某个范围内 并且手势停止
    if( CGRectContainsPoint(rect, convertPoint)){
        
        _boaderImage.hidden = NO;
        if(rec.state == UIGestureRecognizerStateEnded)
        {
            [self drawSinglePic:self.imagView.bounds.size andNewImage:self.tempImage andOldImage:self.imagView andLocationPoint:_boaderImage.center];
            
            _boaderImage.hidden = YES;
        }
    }
    */
    
    [self convertPoint:self.tempImage.center  toView:self.imagView andNewImage:self.tempImage andAreaRect:rect andCurrentGesture:rec andCurrentGestureState:UIGestureRecognizerStateEnded andHiedOrShowImage:_boaderImage];
    
    
}


#pragma mark - 把一张图片画到另一张图片上, 转化相对应的点

/**
 把一张新图片画到一张就图片上

 @param point 需要转换的点
 @param view 把点转换到相对的位置
 @param newView 新View
 @param rect 新view放置的区域
 @param currentGesture 当前手势
 @param state 当前手势状态
 @param imageView view提醒框
 */
-(void)convertPoint:(CGPoint)point
             toView:(UIView *)view
        andNewImage:(UIView *)newView
        andAreaRect:(CGRect)rect
  andCurrentGesture:(UIGestureRecognizer *)currentGesture
andCurrentGestureState:(UIGestureRecognizerState)state
 andHiedOrShowImage:(UIImageView *)imageView{
    
    imageView.hidden = YES;
    //转化为相对点
    CGPoint convertPoint = [self.view convertPoint:point toView:view];
    //判断点在是否在某个范围内 并且手势停止
    if( CGRectContainsPoint(rect, convertPoint)){
        
        imageView.hidden = NO;
        if(currentGesture.state == state)
        {
            [self drawSinglePic:view.bounds.size andNewImage:(UIImageView *)newView andOldImage:(UIImageView *)view andLocationPoint:imageView.center];
            imageView.hidden = YES;
        }
    }

}

#pragma mark - 把多张图片合成一张图片

/**
 把多张图片组合成一张图片

 @param refSize 画布的大小
 @param pics 图片集合
 @param cols 一行多少列
 */
- (void)composeImg:(CGSize)refSize andPictures:(NSArray<UIImage *>*)pics andColums:(int)cols{
    CGFloat picW = refSize.width / cols;
    CGFloat picH = picW;
    CGFloat col = 0;
    CGFloat row = 0;
    CGFloat picX = 0;
    CGFloat picY = 0;
    //以1.png的图大小为画布创建上下文
    UIGraphicsBeginImageContext(CGSizeMake(refSize.width, refSize.height));
    for (int i = 0; i < pics.count; i++) {
         row = i / cols;  //行标
         col = i % cols;  //列标
         picX = col * picW; //X 坐标
         picY = row * picH; //Y 坐标
        [pics[i] drawInRect:CGRectMake(picX, picY, picW, picH)];    }
    UIImage *resultImg = UIGraphicsGetImageFromCurrentImageContext();    UIGraphicsEndImageContext();
    self.imagView.image = resultImg;
}

#pragma mark - 把新图片和旧图片组合在一起
-(void)drawSinglePic:(CGSize)refSize andNewImage:(UIImageView *)newImageView andOldImage:(UIImageView *)oldImageView andLocationPoint:(CGPoint)Point{
    
    CGFloat picW = newImageView.bounds.size.width;
    CGFloat picH = newImageView.bounds.size.height;
    
    UIGraphicsBeginImageContext(CGSizeMake(refSize.width, refSize.height));
    
    [oldImageView.image drawInRect:CGRectMake(0, 0, refSize.width, refSize.height)];
    
    [newImageView.image drawInRect:CGRectMake(Point.x, Point.y, picW, picH)];
    UIImage *resultImg = UIGraphicsGetImageFromCurrentImageContext();    UIGraphicsEndImageContext();
    self.imagView.image = resultImg;
    
}

-(UIImageView *)imagView{
    
    if (!_imagView) {
        _imagView = [[UIImageView alloc] initWithFrame:CGRectMake(50, 100, 300, 300)];
        _imagView.backgroundColor = [UIColor lightGrayColor];
        [self.view addSubview:_imagView];
    }
    return _imagView;
    
}




-(NSMutableArray<UIImage *> *)imageArr{
    
    if (!_imageArr) {
        UIImage *image0 = [UIImage imageNamed:@"agenceMatter"];
        UIImage *image1 = [UIImage imageNamed:@"bonusSearch"];
        UIImage *image2 = [UIImage imageNamed:@"borrowLoan"];
        UIImage *image3 = [UIImage imageNamed:@"guaranteeAnalyze"];
        UIImage *image4 = [UIImage imageNamed:@"guaranteeSign"];
        UIImage *image5 = [UIImage imageNamed:@"imageIcon"];
        UIImage *image6 = [UIImage imageNamed:@"universalAccount"];
        UIImage *image7 = [UIImage imageNamed:@"activateCard"];
        UIImage *image8 = [UIImage imageNamed:@"settleClaimsSer"];
        UIImage *image9 = [UIImage imageNamed:@"QRScan_hightLight"];
    
//        _imageArr = [NSMutableArray arrayWithObjects:image0,image1,image2,image3,image4,image5,image6,image7,image8,image9, nil];
        _imageArr = [NSMutableArray arrayWithObjects:image0, nil];
    }
    
    
    return _imageArr;
}

-(BOOL)prefersStatusBarHidden{
    return NO;
}

@end

//
//  ViewController.m
//  MyPopStar
//
//  Created by 徐正科 on 2017/8/11.
//  Copyright © 2017年 xzk. All rights reserved.
//

#import "ViewController.h"
#import "Star.h"
#import <AudioToolbox/AudioToolbox.h>

@interface ViewController ()

//最高得分
@property(nonatomic,assign)NSInteger highScore;
//关卡数
@property(nonatomic,assign)NSInteger stageNum;
//目标分数
@property(nonatomic,assign)NSInteger targetScore;
//当前分数
@property(nonatomic,assign)NSInteger nowScore;

//关卡数Label
@property(nonatomic,strong)UILabel *stageNumLabel;
//最高分Label
@property(nonatomic,strong)UILabel *highScoreLabel;
//当前分数Label
@property(nonatomic,strong)UILabel *nowScoreLabel;
//目标分数Label
@property(nonatomic,strong)UILabel *targetLabel;

//关卡目标分数
@property(nonatomic,strong)NSArray *scoreArray;
//每列星星个数
@property(nonatomic,strong)NSMutableArray<NSNumber *> *numInColumn;
////消去前每列星星个数(方便Y方向移动时使用)
//@property(nonatomic,strong)NSMutableArray<NSNumber *> *tmpNumInColumn;
//待移动列列号
@property(nonatomic,strong)NSMutableArray<NSNumber *> *toBeMoveColumn;
//待删除星星tag列表
@property(nonatomic,strong)NSMutableArray *toBeClearList;
//已删除星星tag列表
@property(nonatomic,strong)NSMutableArray *delList;
//全部星星列表
@property(nonatomic,strong)NSMutableArray *allStarsList;
//空列列号
@property(nonatomic,strong)NSMutableArray *emptyColumnList;

//过关提示
@property(nonatomic,assign)BOOL isTipPass;
//是否通过
@property(nonatomic,assign)BOOL isPassGame;

//星星父视图
@property(nonatomic,strong)UIView *starView;

@end

@implementation ViewController

/**
 *懒加载代码区
 */


/**
 *主代码区
 */
- (void)viewDidLoad {
    [super viewDidLoad];
    
    //背景图
    UIImageView *backgroundImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"backgroundA.png"]];
    backgroundImage.frame = self.view.bounds;
    backgroundImage.contentMode = UIViewContentModeScaleToFill;
    
    [self.view addSubview:backgroundImage];
    
    //初始化分数
    [self initAllIntegers];
    
    //初始化界面
    [self initInterface];
    
    //初始化VIP系统
    [self initVipView];

}
//(程序运行)初始化各种分数
- (void)initAllIntegers {
    //读取最高分数
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    _highScore = [defaults integerForKey:@"highScore"];
    
    //初始化关卡目标分数Dic
    _scoreArray = [NSArray arrayWithObjects:@1000,@3000,@5000,@8000,@10000,@13000,@17000,@21000,@25000,@30000,@35000, nil];
    //初始化关卡，目标分数，当前分数
    _stageNum = 1;
    _targetScore = [_scoreArray[_stageNum - 1] integerValue];
    _nowScore = 0;
    
    //初始化代消除星星列表
    _toBeClearList = [[NSMutableArray alloc] init];
    
}

//(程序运行)初始化界面
- (void)initInterface {
    //最高得分Tip
    UILabel *highScoreTipLabel = [self setTipLabelWithFrame:CGRectMake(50, 70, 110, 30) text:@"HIGH SCORE:"];
    
    [self.view addSubview:highScoreTipLabel];
    
    //最高得分
    _highScoreLabel = [self setLabelWithFrame:CGRectMake(180, 70, 150, 30) text:[NSString stringWithFormat:@"%ld",_highScore]];
    
    [self.view addSubview:_highScoreLabel];
    
    //关卡Tip
    UILabel *stageNumTip = [self setTipLabelWithFrame:CGRectMake(30, 110, 55, 30) text:@"STAGE"];
    
    [self.view addSubview:stageNumTip];
    
    //关卡数
    _stageNumLabel = [self setLabelWithFrame:CGRectMake(90, 110, 50, 30) text:[NSString stringWithFormat:@"%ld",_stageNum]];
    
    [self.view addSubview:_stageNumLabel];
    
    //目标分数Tip
    UILabel *targetTip = [self setTipLabelWithFrame:CGRectMake(150, 110, 65, 30) text:@"TARGET"];
    
    [self.view addSubview:targetTip];
    
    //目标分数
    _targetLabel = [self setLabelWithFrame:CGRectMake(225, 110, 110, 30) text:[NSString stringWithFormat:@"%ld",_targetScore]];
    
    [self.view addSubview:_targetLabel];
    
    //当前分数Tip
    UILabel *nowScoreTip = [self setTipLabelWithFrame:CGRectMake(0, 0, 55, 30) text:@"SCORE"];
    nowScoreTip.center = CGPointMake(self.view.bounds.size.width * 0.5, 160);
    
    [self.view addSubview:nowScoreTip];
    
    //当前分数
    _nowScoreLabel = [self setLabelWithFrame:CGRectMake(0, 0, 140, 30) text:[NSString stringWithFormat:@"%ld",_nowScore]];
    _nowScoreLabel.center = CGPointMake(self.view.bounds.size.width * 0.5, 190);
    
    [self.view addSubview:_nowScoreLabel];
    
    //获取星星矩阵
    [self createStars];

}

//初始化会员提示
- (void) initVipView {
    if (VIP == YES) {
        UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width - 30, 0, 30, 30)];
        UIImage *img = [UIImage imageNamed:SVIP ? @"svip.png" : @"vip.png"];
        
        [btn setImage:img forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(vipTip) forControlEvents:UIControlEventTouchUpInside];
        
        [self.view addSubview:btn];
        
        if (SVIP == YES) {
            UIButton *commit = [UIButton buttonWithType:UIButtonTypeCustom];
            [commit setTitle:@"一键通关" forState:(UIControlStateNormal)];
            commit.backgroundColor = [UIColor orangeColor];
            commit.layer.cornerRadius = 10;
            commit.layer.masksToBounds = YES;
            [commit sizeToFit];
            commit.center = CGPointMake(self.view.frame.size.width * 0.5, 30);
            
            [commit addTarget:self action:@selector(clearAllStars:) forControlEvents:UIControlEventTouchUpInside];
            
            [self.view addSubview:commit];
        }
    }
}

//SVIP清除所有星星并且通关
- (void)clearAllStars:(UIButton *)btn {
    //禁止重复点击
    btn.enabled = NO;
    
    //分数改变
    _nowScore += 3000;
    _nowScoreLabel.text = [NSString stringWithFormat:@"%zd",_nowScore];
    
    for(NSInteger row = 0; row < 10;row++){
        for(NSInteger column = 0;column < 10;column++){
            Star *star = [self getStarByRow:row andColumn:column];
            star.hidden = YES;
        }
    }
    //播放爆炸音效
    SystemSoundID system_sound_id;
    NSURL *system_sound_url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"炸" ofType:@"caf"]];
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)system_sound_url, &system_sound_id);
    AudioServicesPlayAlertSound(system_sound_id);
    
    //清除全部星星
    for(UIButton *btn in [_starView subviews]){
        [btn removeFromSuperview];
    }
    
    //提示过关
    _isTipPass = YES;
    _isPassGame = YES;
    UILabel *pass = [[UILabel alloc] init];
    pass.text = @"恭喜过关!";
    pass.textColor = [UIColor whiteColor];
    [pass sizeToFit];
    pass.center = CGPointMake(self.view.frame.size.width * 0.5, -30);
    
    [self.view addSubview:pass];
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.25];
    
    pass.center = CGPointMake(self.view.frame.size.width * 0.5, 240);
    
    [UIView commitAnimations];
    
    //分数，关卡改变
    //判断是否需要更新最高分数
    if (_nowScore > _highScore) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setInteger:_nowScore forKey:@"highScore"];
        _highScore = _nowScore;
        _highScoreLabel.text = [NSString stringWithFormat:@"%ld",_highScore];
    }
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        pass.hidden = YES;
        //更新关卡数，目标分数
        _stageNum += 1;
        _stageNumLabel.text = [NSString stringWithFormat:@"%zd",_stageNum];
        _targetScore = [_scoreArray[_stageNum - 1] integerValue];
        _targetLabel.text = [NSString stringWithFormat:@"%zd",_targetScore];
        
        btn.enabled = YES;
        [self createStars];
    });
}

//vipTip
- (void)vipTip {
    NSString *str = SVIP ? @"「超级会员特权」\n1.尊贵的会员主题\n2.允许点击消除单个星星\n3.支持一键通关" : @"「会员特权」\n1.尊贵的会员主题\n2.允许点击消除单个星星";
    UIAlertController *alertC = [UIAlertController alertControllerWithTitle:@"欢迎您,尊贵的会员用户" message:str preferredStyle:(UIAlertControllerStyleAlert)];
    [alertC addAction:[UIAlertAction actionWithTitle:@"我知道了" style:(UIAlertActionStyleDefault) handler:nil]];
    
    [self presentViewController:alertC animated:YES completion:nil];
}

//(每局)获取星星矩阵
- (void)createStars {
    //新的一局所需要初始化的数据
    _numInColumn = [[NSMutableArray alloc] init];
    _isTipPass = NO;
    _isPassGame = NO;
    
    CGSize size = self.view.frame.size;
    
    //父视图
    _starView = [[UIView alloc] init];
    _starView.frame = CGRectMake(0, size.height - size.width - 20, size.width, size.width);
    
    [self.view addSubview:_starView];
    
    //添加星星矩阵
    CGFloat starW = size.width/10;
    CGFloat starH = starW;
    Star *star = nil;
    
    //初始化全部星星矩阵
    _allStarsList = [[NSMutableArray alloc] init];
    //初始化已删除星星列表
    _delList = [[NSMutableArray alloc] init];

    for(int i = 0;i < 10;i++){
        //初始化每列星星个数
        [_numInColumn addObject:[NSNumber numberWithInt:10]];
        
        for(int j = 0;j < 10;j++){
            int type = arc4random() % 5;
            int tag = 1000 + i * 10 + j;
            star = [[Star alloc] initWithType:type tag:tag];
            star.frame = CGRectMake(starW * j, starH * i, starW - 1, starH - 1);
            star.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.3];
            star.layer.cornerRadius = 5;
            star.layer.masksToBounds = YES;
            
            [star addTarget:self action:@selector(pressBtn:) forControlEvents:UIControlEventTouchUpInside];
            
            [_starView addSubview:star];
            [_allStarsList addObject:star];
        }
    }
}

//点击星星事件
- (void) pressBtn:(Star *)star {
    //初始化
    _toBeClearList = [[NSMutableArray alloc] init];
    //先把点击对象加入
    [_toBeClearList addObject:[NSNumber numberWithInteger:star.tag]];
    //查找相同星星
    [self lookUpSameStars:star];
    
    //清除相同星星
    [self clearSameStar];
    
}

//根据行和列获取星星
- (Star *)getStarByRow:(NSInteger)row andColumn:(NSInteger)column {
    for(Star *star in _allStarsList){
        if (star.row == row && star.column == column && ![self isExistInList:star withArray:_delList]) {
            return star;
        }
    }
    //找不到
    return nil;
}

//查找相同的星星
- (void)lookUpSameStars:(Star *)star {
    //当前列
    NSInteger row = star.row;
    NSInteger column = star.column;
    
    //向上找
    if ( row - 1 >= 0) {
        Star *topStar = [self getStarByRow:row - 1 andColumn:column];
        if (topStar != nil && ![self isExistInList:topStar withArray:_toBeClearList] && ![self isExistInList:topStar withArray:_delList]) {
            if (topStar.type == star.type) {
                [_toBeClearList addObject:[NSNumber numberWithInteger:topStar.tag]];
                [self lookUpSameStars:topStar];
            }
        }
    }
    
    //向下找
    if (row + 1 < 10) {
        Star *bottomStar = [self getStarByRow:row + 1 andColumn:column];
        if (bottomStar != nil && ![self isExistInList:bottomStar withArray:_toBeClearList] && ![self isExistInList:bottomStar withArray:_delList]) {
            if (bottomStar.type == star.type) {
                [_toBeClearList addObject:[NSNumber numberWithInteger:bottomStar.tag]];
                [self lookUpSameStars:bottomStar];
            }
        }
    }
    
    //向左找
    if (column - 1 >= 0) {
        Star *leftStar = [self getStarByRow:row andColumn:column - 1];
        if (leftStar != nil && ![self isExistInList:leftStar withArray:_toBeClearList] && ![self isExistInList:leftStar withArray:_delList]) {
            if (leftStar.type == star.type) {
                [_toBeClearList addObject:[NSNumber numberWithInteger:leftStar.tag]];
                [self lookUpSameStars:leftStar];
            }
        }
    }
    
    //向右找
    if (column + 1 < 10) {
        Star *rightStar = [self getStarByRow:row  andColumn:column + 1];
        if (rightStar != nil && ![self isExistInList:rightStar withArray:_toBeClearList] && ![self isExistInList:rightStar withArray:_delList]) {
            if (rightStar.type == star.type) {
                [_toBeClearList addObject:[NSNumber numberWithInteger:rightStar.tag]];
                [self lookUpSameStars:rightStar];
            }
        }
    }
}

//判断一个星星是否存在于指定列表中
- (BOOL)isExistInList:(Star *)star withArray:(NSMutableArray *)array {
    BOOL res = NO;
    for(NSNumber *tag in array){
        if (star.tag == [tag integerValue]) {
            res = YES;
            break;
        }
    }
    return res;
}
//判断元素是否在数组中(去重)
- (BOOL)isExistInArray:(NSInteger )num withArray:(NSMutableArray<NSNumber *> *)array {
    BOOL res = NO;
    for(NSNumber *one in array){
        NSInteger tmp = [one integerValue];
        if(tmp == num){
            res = YES;
            break;
        }
    }
    return res;
}

//清除相同星星
- (void)clearSameStar {
    static int MIN_NUM = VIP ? 0 : 1;
    
    //待移动列号
    _toBeMoveColumn = [[NSMutableArray alloc] init];
    
    
    
    if (_toBeClearList.count > MIN_NUM) {
        //播放音效
        SystemSoundID system_sound_id;
        NSURL *system_sound_url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"炸" ofType:@"caf"]];
        AudioServicesCreateSystemSoundID((__bridge CFURLRef)system_sound_url, &system_sound_id);
        AudioServicesPlayAlertSound(system_sound_id);
        
        for(NSNumber *tag in _toBeClearList){
            Star *star = [_starView viewWithTag:[tag integerValue]];
    
            if (![self isExistInList:star withArray:_delList]) {
                //加入已清除列表
                [_delList addObject:[NSNumber numberWithInteger:star.tag]];
                star.hidden = YES;
                //更新后每列的星星数
//                _numInColumn[star.column] = _numInColumn[star.column] > 0 ? [NSNumber numberWithInteger:[_numInColumn[star.column] integerValue] - 1] : 0;
            }
            
            //要移动的列表
            if (![self isExistInArray:star.column withArray:_toBeMoveColumn]) {
                [_toBeMoveColumn addObject:[NSNumber numberWithInteger:star.column]];
            }
        }
        
        _nowScore += _toBeClearList.count * 25;
        _nowScoreLabel.text = [NSString stringWithFormat:@"%ld",_nowScore];
        
        //判断是否过关
        [self isPass];
        
        //获取空列星星个数
        [self getEmptyColumn];
        
        //竖直方向移动星星
        [self moveY];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            //水平方向移动星星
            [self moveX];
            
            //本关卡是否可以继续操作
            [self isBeginANewGame];
        });
    }
    
    //初始化代消除星星列表
    _toBeClearList = [[NSMutableArray alloc] init];
}

//空列列号集合
- (void)getEmptyColumn {
    _emptyColumnList = [[NSMutableArray alloc] init];
    for(NSInteger column = 0; column < 10;column++){
        NSInteger count = 0;
        for(NSInteger row = 0; row < 10;row++){
            Star *star = [self getStarByRow:row andColumn:column];
            if (star != nil && ![self isExistInList:star withArray:_delList]) {
                count++;
            }
        }
        
        if (count == 0) {
            [_emptyColumnList addObject:[NSNumber numberWithInteger:column]];
        }
    }
}

//x方向移动星星动画
- (void)moveXStar:(Star *)star newX:(NSInteger)x{
    CGFloat moveLong = self.view.frame.size.width / 10;
    CGRect frame = star.frame;
    
    frame.origin.x -= x * moveLong;
    
    //列数改变一下
    star.column -= x;
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.25];
    
    star.frame = frame;
    
    [UIView commitAnimations];
}
//Y方向移动星星动画
- (void)moveYStar:(Star *)star newY:(NSInteger)y{
    CGFloat moveLong = self.view.frame.size.width / 10;
    CGRect frame = star.frame;
    
    frame.origin.y += y * moveLong;
    
    //列数改变一下
    star.row += y;
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.25];
    
    star.frame = frame;
    
    [UIView commitAnimations];
}

//向下移动
- (void)moveY {
    for(NSNumber *one in _toBeMoveColumn){
        NSInteger column = [one integerValue];
        NSInteger row = 9;
        while (row >= 0) {
            Star *star = [self getStarByRow:row andColumn:column];
            if ([self isExistInList:star withArray:_delList] || star == nil) {
                break;
            }
            row--;
        }
        NSInteger moveStep = 0;
        while (row >= 0) {
            Star *star = [self getStarByRow:row andColumn:column];
            if (star == nil) {
                moveStep++;
            }else{
                [self moveYStar:star newY:moveStep];
            }
            row--;
        }
    }
}

//向左移动
- (void)moveX {
    //判断是否需要移动
    if (_emptyColumnList.count == 0) {
        //无须移动，直接结束
        return ;
    }
    
    NSInteger rowStep = 0;
    
    for(NSInteger column = 0;column < 10;column++){
        if ([self isExistInArray:column withArray:_emptyColumnList]) {
            rowStep++;
            continue;
        }
        
        NSInteger row = 9;
        while(row >= 0){
            Star *star = [self getStarByRow:row andColumn:column];
            if (![self isExistInList:star withArray:_delList] && star != nil) {
                [self moveXStar:star newX:rowStep];
            }
            row--;
        }
    }
    [self getEmptyColumn];
}

//判断是否过关
- (void)isPass {
    if(_nowScore >= [_scoreArray[_stageNum - 1] integerValue] && !_isTipPass){
        _isTipPass = YES;
        _isPassGame = YES;
        UILabel *pass = [[UILabel alloc] init];
        pass.text = @"恭喜过关!";
        pass.textColor = [UIColor whiteColor];
        [pass sizeToFit];
        pass.center = CGPointMake(self.view.frame.size.width * 0.5, -30);
        
        [self.view addSubview:pass];
        
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.25];
        
        pass.center = CGPointMake(self.view.frame.size.width * 0.5, 240);
        
        [UIView commitAnimations];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            pass.hidden = YES;
        });
    }
}

//判断是否可以继续消除
- (BOOL)isGoingPop {
    for(NSInteger row = 0; row < 10;row++){
        for(NSInteger column = 0;column < 10;column++){
            Star *star = [self getStarByRow:row andColumn:column];
            //如果为空，则继续查找
            if (star == nil) {
                continue;
            }
            
            //初始化
            _toBeClearList = [[NSMutableArray alloc] init];
            //先把点击对象加入
            [_toBeClearList addObject:[NSNumber numberWithInteger:star.tag]];
            
            [self lookUpSameStars:star];
            
            //判断是否还有可以消除的数组
            if (_toBeClearList.count > 1) {
                return YES;
            }
        }
    }
    
    return NO;
}

//判断是否进入新的一关
- (void)isBeginANewGame {
    //如果无可消除星星
    if (![self isGoingPop]) {
        //如果已通过
        if (_isPassGame) {
            
            UILabel *pass = [[UILabel alloc] init];
            pass.textColor = [UIColor whiteColor];
            
            NSInteger leftStar = _allStarsList.count - _delList.count;
            NSInteger awardScore = leftStar >= 20 ? 0 : (20 - leftStar) * 10;
            pass.text = leftStar >= 20 ? @"无法继续消除,进入下一关" : [NSString stringWithFormat:@"剩余%zd个,奖励%zd分",leftStar,awardScore];
            [pass sizeToFit];
            pass.center = CGPointMake(self.view.frame.size.width * 0.5, 240);
            
            [self.view addSubview:pass];
            //判断是否需要更新最高分数
            if (_nowScore > _highScore) {
                NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                [defaults setInteger:_nowScore forKey:@"highScore"];
                _highScore = _nowScore;
                _highScoreLabel.text = [NSString stringWithFormat:@"%ld",_highScore];
            }
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                //更新关卡数，目标分数
                _stageNum += 1;
                _stageNumLabel.text = [NSString stringWithFormat:@"%zd",_stageNum];
                _targetScore = [_scoreArray[_stageNum - 1] integerValue];
                _targetLabel.text = [NSString stringWithFormat:@"%zd",_targetScore];
                
                //清除全部星星
                for(UIButton *btn in [_starView subviews]){
                    [btn removeFromSuperview];
                }
                pass.hidden = YES;
                [self createStars];
            });
        }else{
            //如果未通过
            UILabel *pass = [[UILabel alloc] init];
            pass.textColor = [UIColor whiteColor];
        
            pass.text = @"通关失败";
            [pass sizeToFit];
            pass.center = CGPointMake(self.view.frame.size.width * 0.5, 240);
            
            
            
            [self.view addSubview:pass];
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                //更新关卡数，目标分数
                _stageNum = 1;
                _stageNumLabel.text = [NSString stringWithFormat:@"%zd",_stageNum];
                _targetScore = [_scoreArray[_stageNum - 1] integerValue];
                _targetLabel.text = [NSString stringWithFormat:@"%zd",_targetScore];
                _nowScore = 0;
                _nowScoreLabel.text = [NSString stringWithFormat:@"%zd",_nowScore];
                
                pass.hidden = YES;
                //清除全部星星
                for(UIButton *btn in [_starView subviews]){
                    [btn removeFromSuperview];
                }
                
                [self createStars];
            });
        }
    }
}

//获取TipLabel
- (UILabel *)setTipLabelWithFrame:(CGRect)frame text:(NSString *)text {
    UILabel *tipLabel = [[UILabel alloc] initWithFrame:frame];
    tipLabel.text = text;
    tipLabel.font = [UIFont boldSystemFontOfSize:15];
    tipLabel.textColor = [UIColor whiteColor];
    
    return tipLabel;
}

//获取计数Label
- (UILabel *)setLabelWithFrame:(CGRect)frame text:(NSString *)text {
    UILabel *label = [[UILabel alloc] initWithFrame:frame];
    label.text = text;
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor whiteColor];
    label.font = [UIFont systemFontOfSize:15];
    label.backgroundColor = [UIColor colorWithRed:16/255.0 green:63/255.0 blue:132/255.0 alpha:1.0];
    label.layer.cornerRadius = 10;
    label.layer.masksToBounds = YES;
    
    return label;
}

//隐藏状态栏
- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end

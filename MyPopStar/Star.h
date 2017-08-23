//
//  Star.h
//  MyPopStar
//
//  Created by 徐正科 on 2017/8/11.
//  Copyright © 2017年 xzk. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface Star : UIButton

//类型
@property(nonatomic,assign)NSInteger type;
//行号
@property(nonatomic,assign)NSInteger row;
//列号
@property(nonatomic,assign)NSInteger column;

- (instancetype)initWithType:(NSInteger)type tag:(NSInteger) tag;
@end

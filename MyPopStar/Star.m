//
//  Star.m
//  MyPopStar
//
//  Created by 徐正科 on 2017/8/11.
//  Copyright © 2017年 xzk. All rights reserved.
//

#import "Star.h"

@implementation Star

- (instancetype)initWithType:(NSInteger)type tag:(NSInteger)tag{
    if (self = [super init]) {
        //是否是VIP
        NSString *plishName = VIP ? @"vip" : @"common";
        //获取配置文件
        NSString *plishPath = [[NSBundle mainBundle] pathForResource:plishName ofType:@"plist"];
        //配置文件转字典
        NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithContentsOfFile:plishPath];
        
        _type = type;
        
        switch (type) {
            case 0:
                [self setImage:[UIImage imageNamed:dic[@"star01"]] forState:UIControlStateNormal];
                break;
            case 1:
                [self setImage:[UIImage imageNamed:dic[@"star02"]] forState:UIControlStateNormal];
                break;
            case 2:
                [self setImage:[UIImage imageNamed:dic[@"star03"]] forState:UIControlStateNormal];
                break;
            case 3:
                [self setImage:[UIImage imageNamed:dic[@"star04"]] forState:UIControlStateNormal];
                break;
            case 4:
                [self setImage:[UIImage imageNamed:dic[@"star05"]] forState:UIControlStateNormal];
                break;
            default:
                break;
        }
        self.tag = tag;
        
        self.row = (self.tag % 100) / 10;
        self.column = self.tag % 10;
    }
    
    return self;
}

@end

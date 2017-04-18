//
//  KeyValueView.m
//  JSON1
//
//  Created by 葛永晖 on 2017/4/11.
//  Copyright © 2017年 葛永晖. All rights reserved.
//

#import "KeyValueView.h"

@implementation KeyValueView


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self){
        _keyLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,0,CGRectGetWidth(self.frame)/3,CGRectGetHeight(self.frame))];
        _keyLabel.backgroundColor = [UIColor clearColor];
        _keyLabel.textAlignment = NSTextAlignmentLeft;
        _keyLabel.font = [UIFont systemFontOfSize:16];
        _keyLabel.textColor = [UIColor blackColor];
        [self addSubview:_keyLabel];
        
        _valueLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.frame)/3,0,2*CGRectGetWidth(self.frame)/3,CGRectGetHeight(self.frame))];
        _valueLabel.backgroundColor = [UIColor clearColor];
        _valueLabel.textAlignment = NSTextAlignmentLeft;
        _valueLabel.font = [UIFont systemFontOfSize:16];
        _valueLabel.textColor = [UIColor blackColor];
        [self addSubview:_valueLabel];
    }
    return self;
}

-(void) setupKey:(NSString *)key value:(NSString *)value
{
    [_keyLabel setText:key];
    NSLog(@"SETkey%@",key);
    [_valueLabel setText:value];
    NSLog(@"SETvalue%@",value);
}

@end

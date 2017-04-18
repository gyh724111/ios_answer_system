//
//  KeyValueView.h
//  JSON1
//
//  Created by 葛永晖 on 2017/4/11.
//  Copyright © 2017年 葛永晖. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KeyValueView : UIView

@property (nonatomic,strong) UILabel *keyLabel;
@property (nonatomic,strong) UILabel *valueLabel;

- (void)setupKey:(NSString *)key value:(NSString *)value;

@end

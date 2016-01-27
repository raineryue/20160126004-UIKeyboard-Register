//
//  KeyboardView.m
//  20160126004-UIKeyboard-Register
//
//  Created by Rainer on 16/1/26.
//  Copyright © 2016年 Rainer. All rights reserved.
//

#import "KeyboardView.h"

@implementation KeyboardView

- (instancetype)initKeyboardView {
    return [[[NSBundle mainBundle] loadNibNamed:@"KeyboardView" owner:nil options:nil] lastObject];
}

+ (instancetype)keyboardView {
    return [[KeyboardView alloc] initKeyboardView];
}

- (IBAction)toolBarButtonItemDidClickAction:(UIBarButtonItem *)barButtonItem {
//    NSLog(@"%ld", barButtonItem.tag);
    
    NSString *barButtonItemTagString = [NSString stringWithFormat:@"%ld", barButtonItem.tag];
    
    if ([self.delegate respondsToSelector:@selector(keyboardView:didToolBarButtonItemType:)]) {
        [self.delegate keyboardView:self didToolBarButtonItemType:[barButtonItemTagString intValue]];
    }
}


@end

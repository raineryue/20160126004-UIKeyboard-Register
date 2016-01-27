//
//  KeyboardView.h
//  20160126004-UIKeyboard-Register
//
//  Created by Rainer on 16/1/26.
//  Copyright © 2016年 Rainer. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    ToolBarButtonItemTypePrev = 0,
    ToolBarButtonItemTypeNext,
    ToolBarButtonItemTypeDone
} ToolBarButtonItemType;

@class KeyboardView;

@protocol KeyboardViewDelegate <NSObject>

@optional
- (void)keyboardView:(KeyboardView *)keyboardView didToolBarButtonItemType:(ToolBarButtonItemType)toolBarButtonItemType;

@end

@interface KeyboardView : UIView

@property (nonatomic, weak) id<KeyboardViewDelegate> delegate;

- (instancetype)initKeyboardView;

+ (instancetype)keyboardView;

@end

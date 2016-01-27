//
//  ViewController.m
//  20160126004-UIKeyboard-Register
//
//  Created by Rainer on 16/1/26.
//  Copyright © 2016年 Rainer. All rights reserved.
//

#import "ViewController.h"
#import "KeyboardView.h"

@interface ViewController () <KeyboardViewDelegate>

@property (weak, nonatomic) IBOutlet UIView *registerView;
@property (weak, nonatomic) IBOutlet UITextField *birthdayTextFiled;
@property (weak, nonatomic) IBOutlet UIView *textFieldBackView;

@property (nonatomic, strong) UIDatePicker *birthdayPicker;

@property (nonatomic, strong) NSMutableArray *textFieldBackViewArray;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 设置自定义键盘（生日）
    [self setupCustomKeyboard];

    // 设置键盘的工具栏
    [self setupKeyboardView];
    
    // 设置键盘通知
    [self setupNotification];
}

/**
 *  设置自定义键盘（生日）
 */
- (void)setupCustomKeyboard {
    self.birthdayPicker = [[UIDatePicker alloc] init];
    self.birthdayPicker.locale = [NSLocale localeWithLocaleIdentifier:@"zh"];
    self.birthdayPicker.datePickerMode = UIDatePickerModeDate;
    
    self.birthdayTextFiled.inputView = self.birthdayPicker;
}

/**
 *  设置键盘的工具栏
 */
- (void)setupKeyboardView {
    // 获取所有的子控件
    NSArray *subviewArray = self.registerView.subviews;
    
    // 创建键盘工具栏
    KeyboardView *keyboardView = [KeyboardView keyboardView];
    keyboardView.delegate = self;
    
    NSMutableArray *textFieldArray = [NSMutableArray array];
    
    // 循环所有子控件
    for (int i = 0; i < subviewArray.count; i++) {
        UIView *textTieldBackView = subviewArray[i];
        
        // 判断子控件是否为文本框控件
        if ([textTieldBackView isKindOfClass:[UITextField class]]) {
            UITextField *textField = (UITextField *)textTieldBackView;
            
            // 如果是第一个文本框控件就设置为第一响应者
            if (1 == i) {
                [textField becomeFirstResponder];
            }
            
            // 给文本框添加键盘工具栏
            textField.inputAccessoryView = keyboardView;
            
            // 将文本框存入数组中
            [textFieldArray addObject:textField];
        }
    }

    // 将文本框数组赋值给全局变量
    self.textFieldBackViewArray = textFieldArray;
}

/**
 *  设置键盘通知
 */
- (void)setupNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardNotification:) name:UIKeyboardWillChangeFrameNotification object:nil];
}

/**
 *  键盘通知处理事件
 */
- (void)keyboardNotification:(NSNotification *)notification {
//    NSLog(@"%@", notification);

    // 获取键盘的Frame，并取出响应时间和Y值
    CGRect keyboardFrame = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    double keyboardDuration = [notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    
    CGFloat keyboardY = keyboardFrame.origin.y;
    
    // 获取当前的文本框，并获取文本框的Y值
    NSInteger currentIndex = [self getCurrentResponderIndex];
    UITextField *textField = self.textFieldBackViewArray[currentIndex];
    
    CGFloat currentTextFieldY = CGRectGetMaxY(textField.frame) + self.textFieldBackView.frame.origin.y;
    
    // 比较键盘的Y值和当前文本框的Y值：如果当前文本框的Y值大于键盘的Y值的话则需要调整文本框背景视图的位置
    if (keyboardY < currentTextFieldY) {
        // 动画调整背景视图的位置
        [UIView animateWithDuration:keyboardDuration animations:^{
            self.view.transform = CGAffineTransformMakeTranslation(0, keyboardY - currentTextFieldY);
        }];
    } else {
        // 动画还原背景视图的位置
        [UIView animateWithDuration:keyboardDuration animations:^{
            self.view.transform = CGAffineTransformIdentity;
        }];
    }
}

/**
 *  键盘工具栏代理事件
 */
- (void)keyboardView:(KeyboardView *)keyboardView didToolBarButtonItemType:(ToolBarButtonItemType)toolBarButtonItemType {
    NSInteger currentIndex = [self getCurrentResponderIndex];
    
    if (currentIndex == 0)
        keyboardView.previousBarButtonItem.enabled = NO;
    else
        keyboardView.previousBarButtonItem.enabled = YES;
    
    if (currentIndex == self.textFieldBackViewArray.count)
        keyboardView.nextBarButtonItem.enabled = NO;
    else
        keyboardView.nextBarButtonItem.enabled = YES;
    
    // 上一个
    if (ToolBarButtonItemTypePrev == toolBarButtonItemType) {
        [self showProviousTextFiledWithCurrentIndex:currentIndex];
    } else if (ToolBarButtonItemTypeNext == toolBarButtonItemType) { // 下一个
        [self showNextTextFiledWithCurrentIndex:currentIndex];
    } else { // 完成
        [self touchesEnded:nil withEvent:nil];
        
        // 设置生日选中效果
        if (currentIndex == self.textFieldBackViewArray.count - 1) {
            // 创建日期格式
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            dateFormatter.dateFormat = @"yyyy年MM月dd日";
            
            // 获取当前文本框，并赋值选中日期
            UITextField *textField = self.textFieldBackViewArray[currentIndex];
            textField.text = [dateFormatter stringFromDate:self.birthdayPicker.date];
        }
    }
}

/**
 *  获取当前第一响应者的索引
 */
- (NSInteger)getCurrentResponderIndex {
    for (UITextField *textField in self.textFieldBackViewArray) {
        if (textField.isFirstResponder) {
            return [self.textFieldBackViewArray indexOfObject:textField];
        }
    }
    
    return -1;
}

/**
 *  显示上一个文本框为第一响应者
 */
- (void)showProviousTextFiledWithCurrentIndex:(NSInteger)currentIndex {
    NSInteger proviousIndex = currentIndex - 1;
    
    if (proviousIndex >= 0) {
        UITextField *textField = self.textFieldBackViewArray[proviousIndex];
        
        [textField becomeFirstResponder];
    }
}

/**
 *  显示下一个文本框为第一响应者
 */
- (void)showNextTextFiledWithCurrentIndex:(NSInteger)currentIndex {
    NSInteger nextIndex = currentIndex + 1;
    
    if (nextIndex < self.textFieldBackViewArray.count) {
        // 取消当前第一响应者
        UITextField *currentTextField = self.textFieldBackViewArray[currentIndex];
        [currentTextField resignFirstResponder];
        
        // 添加下一个为第一响应者
        UITextField *nextTextField = self.textFieldBackViewArray[nextIndex];
        [nextTextField becomeFirstResponder];
    }
}

/**
 *  触屏完成事件
 */
- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
    
    [UIView animateWithDuration:0.25 animations:^{
        self.view.transform = CGAffineTransformIdentity;
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

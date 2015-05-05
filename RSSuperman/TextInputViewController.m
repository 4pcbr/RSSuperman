//
//  TextInputViewController.m
//  RSSuperman
//
//  Created by Olegs on 04/05/15.
//  Copyright (c) 2015 Brand New Heroes. All rights reserved.
//

#import "TextInputViewController.h"

@interface TextInputViewController () <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UIBarButtonItem *saveButton;
@property (weak, nonatomic) IBOutlet UITextField *textInput;
@end

@implementation TextInputViewController

#pragma mark - navBar actions

- (IBAction)cancelButtonTapped:(UIBarButtonItem *)sender {
    if (self.cancel) {
        self.cancel();
    }
}

- (IBAction)saveButtonTapped:(UIBarButtonItem *)sender {
    if (self.saveButton.enabled) {
        [self reportNewInput];
    }
}

#pragma mark - UIViewController methods

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.title = self.pageTitle;
    self.textInput.placeholder = self.placeholderText;
    [self.textInput becomeFirstResponder];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.textInput resignFirstResponder];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)reportNewInput {
    // TODO: Fetch the feed and detect it's title automatically
    NSString *feedURLString   = self.textInput.text;
    
    if (self.save) {
        self.save(feedURLString);
    }
}

#pragma mark - TextInput methods

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (self.saveButton.enabled) {
        [self reportNewInput];
    }
    return YES;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField {
    self.saveButton.enabled = NO;
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    self.saveButton.enabled = [self textInputIsValidAfterReplacingCharactersInRange:range withReplacementString:string];
    return YES;
}

# pragma mark - validator

- (BOOL)textInputIsValidAfterReplacingCharactersInRange:(NSRange )range withReplacementString:(NSString *)string {
    return [self validateURLString:self.textInput.text];
}

- (BOOL)validateURLString:(NSString *)urlString {
    NSString *urlRegEx = @"(http|https)://((\\w)*|([0-9]*)|([-|_])*)+([\\.|/]((\\w)*|([0-9]*)|([-|_])*))+";
    NSPredicate *urlTester = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", urlRegEx];
    return [urlTester evaluateWithObject:urlString];
}

@end

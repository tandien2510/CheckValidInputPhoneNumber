//
//  ViewController.m
//  CheckValidInputPhoneNumber
//
//  Created by Mee Luoi on 7/22/14.
//  Copyright (c) 2014 DienDo. All rights reserved.
//

#import "ViewController.h"
#import "NBPhoneNumberUtil.h"

#define HEIGHT_SCROLL 100

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showKeyboard:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hideKeyboard:) name:UIKeyboardWillHideNotification object:nil];
    //set default a country code to show dialling code
    [_countryPicker setSelectedCountryCode:@"US"];
    //update dialling code
    [self setCountryPhoneNumberDidChangeCountry];
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (!self.diallingCode) {
        self.diallingCode = [[HMDiallingCode alloc] initWithDelegate:self];
    }
    [self.diallingCode getDiallingCodeForCurrentLocation];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    _countryPicker = nil;
    _labelCountryCodePhoneNumber = nil;
    _labelIndicator = nil;
    _textfieldPhoneNumber = nil;
}

#pragma mark Keyboard notification -------------

-(void) showKeyboard:(NSNotification*)notification {
    [_labelIndicator setHidden:YES];
    NSDictionary* dictionary = [notification userInfo];
    NSValue* value = [dictionary valueForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardFrameBeginRect = [value CGRectValue];
    keyboardFrameBeginRect = [self.view convertRect:keyboardFrameBeginRect fromView:nil];
    [UIView animateWithDuration:0.3 animations: ^ {
        self.view.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y - HEIGHT_SCROLL, self.view.frame.size.width, self.view.frame.size.height);
    }completion: ^ (BOOL finished) {
        
    }];
}

- (void)hideKeyboard:(NSNotification*)notification
{
    NSDictionary* keyboardInfo = [notification userInfo];
    NSValue* keyboardFrameBegin = [keyboardInfo valueForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardFrameBeginRect = [keyboardFrameBegin CGRectValue];
    keyboardFrameBeginRect = [self.view convertRect:keyboardFrameBeginRect fromView:nil];
    [UIView animateWithDuration:0.3 animations: ^ {
        self.view.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y + HEIGHT_SCROLL, self.view.frame.size.width, self.view.frame.size.height);
    }completion: ^ (BOOL finished) {
        
    }];
}


#pragma mark -----Actions ------------

-(IBAction)doDoneInputPhone:(id)sender {
    [self doClickDone:self];
}

-(IBAction)doClickDone:(id)sender {
    [_textfieldPhoneNumber resignFirstResponder];
    NSError* error;
    NBPhoneNumber* phoneNumber = [[NBPhoneNumberUtil sharedInstance] parse:_textfieldPhoneNumber.text defaultRegion:_countryPicker.selectedCountryCode error:&error];
    if (error) {
        [_labelIndicator setText:@"The phone number is not correct! Check again."];
    } else if ([[NBPhoneNumberUtil sharedInstance] isValidNumber:phoneNumber]) {
        [_labelIndicator setText:@"YES! Congratulate!!!"];
    } else {
        [_labelIndicator setText:@"The phone number is not correct! Check again."];
    }
    [_labelIndicator setHidden:NO];
}

#pragma mark -----TextField Delegate ----------

-(void)textFieldDidEndEditing:(UITextField *)textField {
    [textField resignFirstResponder];
}

-(void)textFieldDidBeginEditing:(UITextField *)textField {
    
}

#pragma mark -----CountryPicker Delegate-------------

-(void)countryPicker:(CountryPicker *)picker didSelectCountryWithName:(NSString *)name code:(NSString *)code {
    [self setCountryPhoneNumberDidChangeCountry];
}

#pragma mark -----HMDiallingCode----------

- (void)didGetCountryCode:(NSString *)countryCode {
    [_countryPicker setSelectedCountryCode:countryCode animated:YES];
    [self setCountryPhoneNumberDidChangeCountry];
}

- (void)failedToGetDiallingCode {
    [_countryPicker setSelectedCountryCode:@"US" animated:YES];
}


-(void)setCountryPhoneNumberDidChangeCountry {
    NSNumber* PhoneNumberCode = [[NBPhoneNumberUtil sharedInstance] getCountryCodeForRegion:_countryPicker.selectedCountryCode];
    [_labelCountryCodePhoneNumber setText:[NSString stringWithFormat:@"+%d", [PhoneNumberCode intValue]]];
    
}

@end

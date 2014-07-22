//
//  ViewController.h
//  CheckValidInputPhoneNumber
//
//  Created by Mee Luoi on 7/22/14.
//  Copyright (c) 2014 DienDo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CountryPicker.h"
#import "HMDiallingCode.h"

@interface ViewController : UIViewController <CountryPickerDelegate, HMDiallingCodeDelegate>{
    IBOutlet CountryPicker* _countryPicker;
    IBOutlet UILabel* _labelCountryCodePhoneNumber;
    IBOutlet UITextField* _textfieldPhoneNumber;
    IBOutlet UILabel* _labelIndicator;
}

@property (strong, nonatomic) HMDiallingCode* diallingCode;

@end

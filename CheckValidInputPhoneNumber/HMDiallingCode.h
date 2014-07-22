//
//  HMLocationManager.h
//
//  Created by Hesham Abd-Elmegid on 26/11/12.
//  Copyright (c) 2012 Hesham Abd-Elmegid. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@protocol HMDiallingCodeDelegate <NSObject>

@optional
- (void)didGetCountryCode:(NSString *)countryCode;

@required
- (void)failedToGetDiallingCode;

@end

@interface HMDiallingCode : NSObject <CLLocationManagerDelegate>

- (id)initWithDelegate:(id<HMDiallingCodeDelegate>)delegate;
- (void)getDiallingCodeForCurrentLocation;
- (void)getDiallingCodeForCountry:(NSString *)country;
- (void)getCountriesWithDiallingCode:(NSString *)diallingCode;

@property (nonatomic, assign) id<HMDiallingCodeDelegate> delegate;

@end

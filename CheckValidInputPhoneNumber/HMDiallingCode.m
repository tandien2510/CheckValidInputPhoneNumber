//
//  HMLocationManager.m
//
//  Created by Hesham Abd-Elmegid on 26/11/12.
//  Copyright (c) 2012 Hesham Abd-Elmegid. All rights reserved.
//

#import "HMDiallingCode.h"

@interface HMDiallingCode ()

@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) CLLocation *currentLocation;
@property (nonatomic, strong) NSDictionary *diallingCodesDictionary;

- (void)geocodeLocation:(CLLocation *)location;
- (NSString *)codeFromDictionaryForCountry:(NSString *)country;
@end

@implementation HMDiallingCode

- (id)initWithDelegate:(id<HMDiallingCodeDelegate>)delegate {
    self.delegate  = delegate;
    
    return [self init];
}

- (id)init {
    self = [super init];
    if (self != nil) {
        NSString * plistPath = [[NSBundle mainBundle] pathForResource:@"all_contries" ofType:@"plist"];
        self.diallingCodesDictionary = [NSDictionary dictionaryWithContentsOfFile:plistPath];
    }
    return self;
}

#pragma mark -

- (void)getDiallingCodeForCurrentLocation {
    self.locationManager = [[CLLocationManager alloc] init];
    [self.locationManager setDelegate:self];
    [self.locationManager startUpdatingLocation];
}

- (void)getDiallingCodeForCountry:(NSString *)country {
    NSString *diallingCode = [self codeFromDictionaryForCountry:country];
    
    if (diallingCode && diallingCode.length > 0) {
        if ([self.delegate respondsToSelector:@selector(didGetCountryCode:)])
            [self.delegate didGetCountryCode:country];
    } else {
        if ([self.delegate respondsToSelector:@selector(failedToGetDiallingCode)])
            [self.delegate failedToGetDiallingCode];
    }
}

- (void)getCountriesWithDiallingCode:(NSString *)diallingCode {
    if ([diallingCode hasPrefix:@"+"]) {
        diallingCode = [diallingCode substringFromIndex:1];
    }
    
    NSMutableArray *countriesArray = [[NSMutableArray alloc] init];
    [self.diallingCodesDictionary enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        if ([obj isEqual:diallingCode])
            [countriesArray addObject:key];
    }];
    
//    if (countriesArray.count > 0) {
//        if ([self.delegate respondsToSelector:@selector(didGetCountries:forDiallingCode:)])
//            [self.delegate didGetCountries:countriesArray forDiallingCode:diallingCode];
//    } else {
//        if ([self.delegate respondsToSelector:@selector(failedToGetDiallingCode)])
//            [self.delegate failedToGetDiallingCode];
//    }
}

#pragma mark -

- (void)geocodeLocation:(CLLocation *)location {
    CLGeocoder *geoCoder = [[CLGeocoder alloc] init];
    [geoCoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
        NSLog(@"%@", [error description]);
        [placemarks enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            CLPlacemark *aPlacemark = (CLPlacemark *)obj;
            NSString *country = aPlacemark.ISOcountryCode;
//            NSString *diallingCode = [self codeFromDictionaryForCountry:country];
            
            if (country.length > 0) {
                if ([self.delegate respondsToSelector:@selector(didGetCountryCode:)])
                    [self.delegate didGetCountryCode:country];
            } else {
                if ([self.delegate respondsToSelector:@selector(failedToGetDiallingCode)])
                    [self.delegate failedToGetDiallingCode];
            }
        }];
        
    }];
}

- (NSString *)codeFromDictionaryForCountry:(NSString *)country {
    return [self.diallingCodesDictionary objectForKey:[country uppercaseString]];
}

#pragma mark - CLLocationManagerDelegate
//
//- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
//    [self.locationManager stopUpdatingLocation];
//    
//    // Return if we already have a location or if the returned location is invaled
//    if (self.currentLocation || newLocation.horizontalAccuracy < 0)
//        return;
//    
//    self.currentLocation = newLocation;
//    [self geocodeLocation:newLocation];
//}
//
-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    if (locations.count > 0) {
        [self.locationManager stopUpdatingLocation];
        
        // Return if we already have a location or if the returned location is invaled
        self.currentLocation = [locations lastObject];
        [self geocodeLocation:[locations lastObject]];
    }
    
}
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    if ([self.delegate respondsToSelector:@selector(failedToGetDiallingCode)])
        [self.delegate failedToGetDiallingCode];
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    if (status == kCLAuthorizationStatusAuthorized) {
        [self.locationManager startUpdatingLocation];
    }
}

- (void)dealloc
{
    self.locationManager = nil;
    self.currentLocation = nil;
    self.diallingCodesDictionary = nil;
}
@end

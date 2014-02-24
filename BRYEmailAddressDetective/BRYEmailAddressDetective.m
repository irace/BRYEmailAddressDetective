//
//  BRYEmailAddressDetective.m
//  BRYEmailAddressDetective
//
//  Created by Bryan Irace on 2/24/14.
//  Copyright (c) 2014 Bryan Irace. All rights reserved.
//

#import "BRYEmailAddressDetective.h"
@import AddressBook;
@import UIKit;

@implementation BRYEmailAddressDetective

+ (NSString *)determineEmailAddress:(NSString *)deviceName {
    NSString *userName = userNameForDeviceName(deviceName);
    
    ABAddressBookRef addressBookRef = ABAddressBookCreateWithOptions(NULL, NULL);
    
    __block NSString *emailAddress;
    
    if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusNotDetermined) {
        ABAddressBookRequestAccessWithCompletion(addressBookRef, ^(bool granted, CFErrorRef error) {
            if (granted) {
                emailAddress = emailAddressForUserName(addressBookRef, userName);
            }
        });
    }
    else if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusAuthorized) {
        emailAddress = emailAddressForUserName(addressBookRef, userName);
    }
    
    return emailAddress;
}

#pragma mark - Private

static NSString *userNameForDeviceName(NSString *deviceName) {
    // This is probably far from a definitive list
    NSArray *defaultDeviceNameSuffixes = @[@"iPhone", @"iPad", @"iPod touch"];
    
    // Probably English only
    NSString *pattern = [NSString stringWithFormat:@"'s (%@)",
                         [defaultDeviceNameSuffixes componentsJoinedByString:@"|"]];
    
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern
                                                                           options:0 error:NULL];
    
    NSTextCheckingResult *result = [regex firstMatchInString:deviceName options:0
                                                       range:NSMakeRange(0, [deviceName length])];
    
    if (result.range.location + result.range.length != [deviceName length]) {
        return nil;
    }

    return [deviceName substringToIndex:result.range.location];
}

static NSString *emailAddressForUserName(ABAddressBookRef addressBookRef, NSString *name) {
    NSArray *people = (__bridge_transfer NSArray *)ABAddressBookCopyPeopleWithName(addressBookRef, (__bridge CFStringRef)name);
    
    NSString *emailAddress;
    
    if ([people count] > 0) {
        ABRecordRef person = (__bridge ABRecordRef)([people firstObject]);
        
        ABMultiValueRef emails = ABRecordCopyValue(person, kABPersonEmailProperty);
        CFIndex numberOfEmails = ABMultiValueGetCount(emails);
        
        if (numberOfEmails == 1) {
            emailAddress = (__bridge NSString *)ABMultiValueCopyValueAtIndex(emails, 0);
        }
        else if (numberOfEmails > 1) {
            for (CFIndex i = 0; i < numberOfEmails; i++) {
                NSString *label = (__bridge NSString *)ABMultiValueCopyLabelAtIndex(emails, i);
                
                if ([label isEqualToString:(NSString *)kABHomeLabel]) {
                    emailAddress = (__bridge NSString *)ABMultiValueCopyValueAtIndex(emails, i);
                }
            }
        }
    }
    
    return emailAddress;
}

@end

# BRYEmailAddressDetective

Crude attempt at trying to figure out a user's email address if Contacts access is granted. [As far as I know](http://www.quora.com/Square-Inc-1/How-does-Square-know-my-name-in-their-apps-registration-process), Square first came up with this approach.

This only works if their device has a default name e.g. "Bryan Irace's iPhone".

## Usage

```objectivec
NSString *emailAddress = [BRYEmailAddressDetective determineEmailAddress:
                          [UIDevice currentDevice].name];
```

## License
Available for use under the MIT license: [http://bryan.mit-license.org](http://bryan.mit-license.org)

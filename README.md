AudioKit V5.0 Beta / Developer's Release
===

[![Build Status](https://github.com/AudioKit/AudioKit/workflows/CI/badge.svg)](https://github.com/AudioKit/AudioKit/actions?query=workflow%3ACI)
[![License](https://img.shields.io/cocoapods/l/AudioKit.svg?style=flat)](https://github.com/AudioKit/AudioKit/blob/master/LICENSE)
[![Platform](https://img.shields.io/cocoapods/p/AudioKit.svg?style=flat)](http://cocoadocs.org/docsets/AudioKit)
<img src="https://img.shields.io/badge/in-swift5.0-orange.svg">
[![Reviewed by Hound](https://img.shields.io/badge/Reviewed_by-Hound-8E64B0.svg)](https://houndci.com)
[![Twitter Follow](https://img.shields.io/twitter/follow/AudioKitPro.svg?style=social)](http://twitter.com/AudioKitPro)

AudioKit is an audio synthesis, processing, and analysis platform for iOS, macOS (including Catalyst), and tvOS. 

## Important notes for AudioKit Version 4 Users

If you are using AudioKit in production, you may want to stick to our latest stable release of Version 4 because there are a number of things were are still working out. 
But, since Version 5 is well on its way, we don't think new users should use Version 4 anymore. When AudioKit 5 is ready, we will make a 5.0 release, but even then
a Version 4 branch will be maintained because of its large user base, and also because there are things in AudioKit 4 that are not yet available in version 5.

Most importantly, you must read the [Migration Guide](docs/MigrationGuide.md). 
You will also want to check the progress of the [AudioKit 5 Release Push Project](https://github.com/AudioKit/AudioKit/projects/5).

## Installation via Swift Package Manager

To add AudioKit to your Xcode project, select File -> Swift Packages -> Add Package Depedancy. Enter `https://github.com/AudioKit/AudioKit` for the URL. Check the use branch option and enter `v5-main` or `v5-develop`.

Installing AudioKit via Cocoapods was supported through AudioKit 4, and will be reintroduced when AudioKit 5 is officially released.

## Documentation

In addition to the [Migration Guide](docs/MigrationGuide.md), our documentation is now automatically generated on the [Github wiki](https://github.com/AudioKit/AudioKit/wiki).

## Examples

The [AudioKit Cookbook](https://github.com/AudioKit/Cookbook) contains many recipes for simple uses for AudioKit components. More examples are [here](docs/Examples.md).

## Getting help

1. Post your problem to [StackOverflow with the #AudioKit hashtag](https://stackoverflow.com/questions/tagged/audiokit).

2. Once you are sure the problem is not in your implementation, but in AudioKit itself, you can open a [Github Issue](https://github.com/audiokit/AudioKit/issues).

3. If you, your team or your company is using AudioKit, please consider [sponsoring Aure on Github Sponsors](http://github.com/sponsors/aure).

## Contributing Code

When you want to modify AudioKit, check out the [v5-develop](https://github.com/audiokit/AudioKit/tree/v5-develop) branch (as opposed to v5-main), 
make your changes, and send us a [pull request](https://github.com/audiokit/AudioKit/pulls).


## About Us

AudioKit was created by 
[Aurelius Prochazka](https://github.com/aure) who is your life line if you need help!  
[Matthew Fecher](https://github.com/analogcode), 
[Jeff Cooper](https://github.com/eljeff), and Aure create [AudioKitPro](http://audiokitpro.com/) apps together, and
[Stephane Peter](https://github.com/megastep) is Aure's co-admin and manages AudioKit's releases. 
[Taylor Holliday](https://github.com/wtholliday) has been instrumental in AudioKit 5 improvements.

But, there are many other important people in our family:

| Group                                                                    | Description                                                                      |
| ------------------------------------------------------------------------ | -------------------------------------------------------------------------------- |
| [Core Team](https://github.com/orgs/AudioKit/people)                     | The biggest contributors to AudioKit!                                            |
| [Slack](https://audiokit.slack.com)                                      | Pro-level developer chat group, contact a core team member for an in invitation. |
| [Contributors](https://github.com/AudioKit/AudioKit/graphs/contributors) | A list of all people who have submitted code to AudioKit.                        |

<a href="https://github.com/AudioKit/AudioKit/graphs/contributors"><img src="https://opencollective.com/AudioKit/contributors.svg?width=890&button=false" /></a>




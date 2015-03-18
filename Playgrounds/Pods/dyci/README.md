# WARNING
**Please, Read this.**  
Uninstall dyci before updating Xcode.  
In other case, you'll need to reinstall it :(
We're currenlty working on [this issue](https://github.com/DyCI/dyci-main/issues/8)...   
If you've already expirienced this issue - remove and reinstall Xcode.

# dyci
Dynamic code injection tool.
Allows you to inject your code into running iOS application, whithout restarting it.

## Installation
If you already know, what this tool is about, you can move to [Installation page](https://github.com/DyCI/dyci-main/wiki/Installation)

## Adding to your project
After installation, you need to add dyci library to your project  
If you are using [CocoaPods](https://github.com/CocoaPods/CocoaPods), then, just add this line to your PodFile  

`pod 'dyci', :git => 'https://github.com/DyCI/dyci-main.git'` 

If not, then, you can add dyci in [other ways](https://github.com/DyCI/dyci-main/wiki/Using-dyci)

## Reasons, why do you need this tool 
* It's good for applying small logic changes 
* It's good for quick small fixes on big projects.
* It's good for debugging purposes. Remember, you can inject any code at runtime. Logging is the code also.

## Differences from other tools
* You need minimum moves to enable dyci
* You aren't writing some kind of script, you are writing your code!
* You don't need to prepare/modify/lock your code for dyci 
* Your changes are always saved (They will not be discarded on next run)

## How it works
If you curious about How [how it works](https://github.com/DyCI/dyci-main/wiki/How-it-Works), you can read about it in [wiki](https://github.com/DyCI/dyci-main/wiki/How-it-Works).

##Example
There's one example in sources  
There's video about Tic-Tac-Toe game creation without project restart  
[Video at Youtube](https://www.youtube.com/watch?v=8nyEpAqUug4)


##Some points of view
1. Dyci is not about loading new code in application.
2. Dyci is about speeding up development.
3. Each time, you are using dyci, it saves your time.


##WARNING
Please, do not use this tool in your real applications, that you about to publish in App Store. Dyci won't work on devices by default. It was made for purpose. Dynamic code injection is good for development, but it will leave huge security hole if you put it in your application. Please, do not :) I warned you.

#FAQ
If you have some questions, before asking them , make sure that they aren't listed [here](https://github.com/DyCI/dyci-main/wiki/FAQ)



//
//  main.m
//  SmartChair
//
//  Created by 张志恒 on 2025/11/13.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "AppDelegateTools.h"

int main(int argc, char * argv[]) {
    
    AppDelegateTools.instance.argv = argv;
    AppDelegateTools.instance.argc = argc;
    
    NSString * appDelegateClassName;
    @autoreleasepool {
        // Setup code that might create autoreleased objects goes here.
        appDelegateClassName = NSStringFromClass([AppDelegate class]);
    }
    return UIApplicationMain(argc, argv, nil, appDelegateClassName);
}

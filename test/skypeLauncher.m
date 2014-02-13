//
//  skypeLauncher.m
//  test
//
//  Created by Алексей Саечников on 10.02.14.
//  Copyright (c) 2014 unknown corp. All rights reserved.
//

#import "skypeLauncher.h"
#import "userView.h"

@interface skypeLauncher ()<userViewDelegale>{
}

@end

@implementation skypeLauncher

-(void)awakeFromNib{
    NSArray *usersArray = [skypeLauncher users];
    int numberOfButton = 0;
    for (NSString *currentUser in usersArray)
    {
        NSButton *button = [[NSButton alloc] initWithFrame:NSMakeRect(20, contentView.frame.size.height-20-numberOfButton*40-30, contentView.frame.size.width-40, 30)];
        [button setTarget:self];
        [button setAction:@selector(userButtonTapped:)];
        [button setAutoresizingMask:NSViewWidthSizable | NSViewMinYMargin];
        [button setTitle:currentUser];
        [button setButtonType:NSMomentaryLightButton];
        [button setBezelStyle:NSRoundedBezelStyle];
        if (![skypeLauncher credentalsFromConfigFileForUser:currentUser] && ![skypeLauncher savedCredentalsForUser:currentUser])
            [button setEnabled:NO];
        [contentView addSubview:button];
        
//        userView *currentUserView = [[userView alloc] initWithFrame:NSMakeRect(20, contentView.frame.size.height-20-numberOfButton*40-30, contentView.frame.size.width-40, 30)];
//        [currentUserView setDelegate:self];
//        [currentUserView setUsername:currentUser];
//        if ([skypeLauncher savedCredentalsForUser:currentUser])
//            [currentUserView setState:userViewStateAutologin];
//        else if ([skypeLauncher credentalsFromConfigFileForUser:currentUser])
//            [currentUserView setState:userViewStateSaveForAutologin];
//        else
//            [currentUserView setState:userViewStateLogin];
//        [currentUserView setAutoresizingMask:NSViewWidthSizable | NSViewMinYMargin];
//        [contentView addSubview:currentUserView];
//        
        numberOfButton++;
    }
}

-(void) userButtonTapped:(id)sender{
    [skypeLauncher changeUserTo:[(NSButton*)sender title]];
    [skypeLauncher launchSkype];
    [window close];
}

#pragma mark - credentals
//ключ, необходимый для автовхода, ищем в конфигурационном файле пользователя
+(NSString*)credentalsFromConfigFileForUser:(NSString*)userName{
    NSFileManager *filemanager = [NSFileManager defaultManager];
    NSString *userDirectoryPath = [NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"/Library/Application Support/Skype/%@", userName]];
    if (![filemanager fileExistsAtPath:userDirectoryPath])
        return nil;
    NSString *configFilePath = [userDirectoryPath stringByAppendingPathComponent:@"config.xml"];
    NSError *error;
    NSString *configFileString = [NSString stringWithContentsOfFile:configFilePath encoding:NSUTF8StringEncoding error:&error];
    if (error)
        return nil;
    NSRange beginTagRange = [configFileString rangeOfString:@"<Credentials3>"];
    NSRange endTagRange = [configFileString rangeOfString:@"</Credentials3>"];
    if (beginTagRange.location == NSNotFound || endTagRange.location == NSNotFound)
        return nil;
    NSString *credentals = [configFileString substringWithRange:NSMakeRange(beginTagRange.location+beginTagRange.length, endTagRange.location-beginTagRange.length-beginTagRange.location)];
    return credentals;
}

//сохраняем ключ автовхода для этого пользователя
+(void)saveCredentals:(NSString*)credentals forUser:(NSString*)user{
    [[NSUserDefaults standardUserDefaults] setObject:credentals forKey:user];
}

//ключ, необходимый для автовхода, ищем в сохраненных ключах
+(NSString*)savedCredentalsForUser:(NSString*)username{
    NSString *savedCredentals = [[NSUserDefaults standardUserDefaults] objectForKey:username];
    return savedCredentals;
}

//вписываем в файл config этого пользователя credentals
+(BOOL) setCredentals:(NSString*)credentals toConfigFileforUser:(NSString*)username{
    NSFileManager *filemanager = [NSFileManager defaultManager];
    NSString *userDirectoryPath = [NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"/Library/Application Support/Skype/%@", username]];
    if (![filemanager fileExistsAtPath:userDirectoryPath])
        return NO;
    NSString *configFilePath = [userDirectoryPath stringByAppendingPathComponent:@"config.xml"];
    NSError *error;
    NSMutableString *configFileString = [NSMutableString stringWithString:[NSString stringWithContentsOfFile:configFilePath encoding:NSUTF8StringEncoding error:&error]];
    if (error)
        return NO;
//    проверка, есть ли credentals. если есть - ничего не менять
    if ([configFileString rangeOfString:@"<Credentials3>"].location != NSNotFound)
        return YES;
//    вставка если их нет
    NSRange accountBeginTag = [configFileString rangeOfString:@"<Account>"];
    [configFileString insertString:[NSString stringWithFormat:@"\n<Credentials3>%@</Credentials3>\n", credentals] atIndex:accountBeginTag.location+accountBeginTag.length];
    [configFileString writeToFile:configFilePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
    return YES;
}

#pragma mark - users and shared.xml
//список пользователей, найденных в папке скайпа в application Support
+(NSArray*)users{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *directoryPath = [NSHomeDirectory() stringByAppendingPathComponent:@"/Library/Application Support/Skype"];
    NSArray *filesFolders = [fileManager contentsOfDirectoryAtPath:directoryPath error:nil];
    NSMutableArray *folders = [NSMutableArray array];
//    ищем папки с пользовательскими данными
    for (NSString *currentFile in filesFolders)
    {
        NSString *currentFilePath = [directoryPath stringByAppendingPathComponent:currentFile];
        BOOL isDir = NO;
        [fileManager fileExistsAtPath:currentFilePath isDirectory:&isDir];
        if (isDir)
        {
//            проверяем есть ли внутри файл config.xml
            NSString *currentConfigFilePath = [[directoryPath stringByAppendingPathComponent:currentFile] stringByAppendingPathComponent:@"config.xml"];
            BOOL configFileExist = [fileManager fileExistsAtPath:currentConfigFilePath];
            if (configFileExist)
                [folders addObject:currentFile];
        }
    }
    return folders;
}

+(void)changeUserTo:(NSString*)user{
    //        changeUser
    NSString *xmlPath = [NSHomeDirectory() stringByAppendingPathComponent:@"/Library/Application Support/Skype/shared.xml"];
    NSMutableString *xmlFileString = [NSMutableString stringWithString:[NSString stringWithContentsOfFile:xmlPath encoding:NSUTF8StringEncoding error:nil]];
    NSRange beginTagRange = [xmlFileString rangeOfString:@"<Default>"];
    NSRange endTagRange = [xmlFileString rangeOfString:@"</Default>"];
    if (beginTagRange.location == NSNotFound)  // если не нашлось введенного пользователя
    {
        //            вставляем строку с дефолтным пользователем
        NSString *defaultString = [NSString stringWithFormat:@"\n<Account>\n<Default>%@</Default>", user];
        NSRange acessTagRange = [xmlFileString rangeOfString:@"</Access>"];
        [xmlFileString insertString:defaultString atIndex:acessTagRange.location+acessTagRange.length];
    }
    else
    {
        //            заменяем пользователя
        [xmlFileString replaceCharactersInRange:NSMakeRange(beginTagRange.location+beginTagRange.length, endTagRange.location-beginTagRange.location-beginTagRange.length) withString:user];
    }
    [xmlFileString writeToFile:xmlPath atomically:YES encoding:NSUTF8StringEncoding error:nil];
}

#pragma mark - other
-(void) autologinToUser:(NSString*)username{
    [skypeLauncher changeUserTo:username];
    [skypeLauncher setCredentals:[skypeLauncher savedCredentalsForUser:username] toConfigFileforUser:username];
    [skypeLauncher launchSkype];
    [window close];
}

-(void)tryToLoginWithUser:(NSString*)username{
    
}

-(BOOL)saveCredentalsForUser:(NSString*)username{
    NSString *credentals = [skypeLauncher credentalsFromConfigFileForUser:username];
    if (!credentals)
        return NO;
    [skypeLauncher saveCredentals:credentals forUser:username];
    return YES;
}

+(void)launchSkype{
//    создаем еще одну копию skype
    NSTask *rmTask;
    NSTask *skypeTask;
    NSArray *rmArguments;
    NSArray *skypeArguments;
    
    rmTask = [[NSTask alloc] init];
    skypeTask = [[NSTask alloc] init];
    
    rmArguments = [NSArray arrayWithObjects: [NSHomeDirectory() stringByAppendingPathComponent:@"/Library/Application Support/Skype/Skype.pid"], nil];
    skypeArguments = [NSArray arrayWithObjects: @"-n", @"/Applications/Skype.app", nil];
    
    [rmTask setLaunchPath: @"/bin/rm"];
    [skypeTask setLaunchPath: @"/usr/bin/open"];
    
    [rmTask setArguments: rmArguments];
    [skypeTask setArguments: skypeArguments];
    
    [rmTask launch];
    [skypeTask launch];
}

#pragma mark - userViewDelegate
-(void)buttonPressedInView:(userView *)view{
    switch (view.state) {
        case userViewStateAutologin:
        {
            [self autologinToUser:view.username];
        }
            break;
            
        case userViewStateSaveForAutologin:
        {
            if ([self saveCredentalsForUser:view.username])
                [view setState:userViewStateAutologin];
        }
            break;
            
        case userViewStateLogin:
        {
            [self tryToLoginWithUser:view.username];
        }
            break;
            
        default:
            break;
    }
}

@end

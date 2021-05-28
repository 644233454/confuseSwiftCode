//
//  main.m
//  confuseSwiftCode
//
//  Created by leslie on 2018/12/6.
//  Copyright © 2018年 leslie. All rights reserved.
//

#include <mach-o/dyld.h>
#import <Foundation/Foundation.h>
#import "ReplaceHandle.h"
#import "GenerateClass.h"

#define NOTNULL(x) ((![x isKindOfClass:[NSNull class]])&&x)
#define SWNOTEmptyArr(X) (NOTNULL(X)&&[X isKindOfClass:[NSArray class]]&&[X count])
#define SWNOTEmptyDictionary(X) (NOTNULL(X)&&[X isKindOfClass:[NSDictionary class]]&&[[X allKeys]count])
#define SWNOTEmptyStr(X) (NOTNULL(X)&&[X isKindOfClass:[NSString class]]&&((NSString *)X).length)

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        printf("%s\n", [[NSString stringWithFormat:@"程序默认扫描当前目录下podTest2目录."] UTF8String]);
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSString *homeDirPath;
        NSString *execPath;
        if (argc == 1) {
            // 获取执行路径
//            char path[512];
//            unsigned size = 512;
//            _NSGetExecutablePath(path, &size);
//            path[size] = '\0';
//            printf("%s\n", [[NSString stringWithFormat:@"path = %s",path] UTF8String]);
//            execPath = [NSString stringWithFormat:@"%s",path];
            
            char path[512];
            unsigned size = 512;
            _NSGetExecutablePath(path, &size);
            path[size] = '\0';
            printf("The path is: %s\n", path);
            
            execPath = [NSString stringWithUTF8String:path];
            
            printf("%s\n", [[NSString stringWithFormat:@"execPath = %@",execPath] UTF8String]);
//            execPath = [execPath stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"/%@",[[execPath componentsSeparatedByString:@"/"] lastObject]] withString:@""];
//            homeDirPath = [execPath stringByAppendingString:@"/podTest2"];
//            execPath = [execPath stringByReplacingOccurrencesOfString:@"/confuseSwiftCode" withString:@""];
            NSRange subRange= NSMakeRange(0, execPath.length-17);
            execPath = [execPath substringWithRange:subRange];
            
            homeDirPath = execPath;
            printf("%s\n", [[NSString stringWithFormat:@"当前路径%@",homeDirPath] UTF8String]);
//            BOOL isDir;
            BOOL exists = [fileManager fileExistsAtPath:execPath];
            if (!exists) {
                printf("%s\n", [[NSString stringWithFormat:@"请在ts+根目录运行"] UTF8String]);
                exit(0);
            }
        }
        // 获取当前目录的待替换方法名列表
        NSString *funcNamePath = [NSString stringWithFormat:@"%@/funcname.txt",execPath];
        NSString *funcNameKeyValuePath = [NSString stringWithFormat:@"%@/funcnamekeyvalue",execPath];
        if (![fileManager fileExistsAtPath:funcNamePath]) {
            printf("%s\n", [[NSString stringWithFormat:@"funcname.txt文件不存在, 请先创建文件并导入方法名"] UTF8String]);
            exit(0);
        }
        NSString *funcNameContent = [NSString stringWithContentsOfFile:funcNamePath encoding:NSUTF8StringEncoding error:nil];
        NSArray *funcNameArray = [funcNameContent componentsSeparatedByString:@"\n"];
        NSMutableArray *tmpArray = [NSMutableArray array];
        for (NSString *_str in funcNameArray) {
            NSString *str = [_str stringByReplacingOccurrencesOfString:@" " withString:@""];
            if (!SWNOTEmptyStr(str)) {
                continue;
            } else if ([str hasPrefix:@"#"] || [str hasPrefix:@"//"]) {
                // 跳过注释
                continue;
            }
            [tmpArray addObject:str];
        }
        funcNameArray = [tmpArray copy];
        NSDictionary *funcNameDict;
        NSMutableArray *replaceClassNameArray = [NSMutableArray array];
        if ([fileManager fileExistsAtPath:funcNameKeyValuePath]) {
            funcNameDict = [[NSDictionary alloc] initWithContentsOfFile:funcNameKeyValuePath];
        }
        if (!SWNOTEmptyDictionary(funcNameDict)) {
            NSMutableDictionary *tmpDict = [NSMutableDictionary dictionary];
            for (NSString *str in funcNameArray) {
                if ([str hasSuffix:@"Controller"] || [str hasSuffix:@"VC"]) {
                    // 生成随机类名
                    NSArray *firstArray = @[@"Gift", @"Process", @"Catchs", @"Question", @"Report",@"Task", @"Sign", @"FindPerson", @"Exchange", @"Card", @"Segment", @"Notis", @"Pindao", @"Root", @"Chat", @"Remark", @"Caogao", @"Weiba", @"Circle", @"MyPublish", @"Activity"];
                    NSArray *secondArray = @[@"", @"", @"Item", @"UserInfo", @"MediaInfo", @"Route", @"Commis", @"Loaction", @"DrawMap"];
                    NSArray *thirdArray = @[@"List", @"Detail", @"Manager", @"Comment", @"Common", @"Search", @"Collection", @"Preview", @"Picker", @"Header", @"Setting", @"Info"];
                    NSArray *forthArray = @[@"View", @"VC", @"Controller"];
                    NSString *randomStr = [NSString stringWithFormat:@"%@%@%@%@",firstArray[arc4random() % firstArray.count],secondArray[arc4random() % secondArray.count],thirdArray[arc4random() % thirdArray.count],forthArray[arc4random() % forthArray.count]];
                    NSArray *allkeys = [tmpDict allKeys];
                    for (NSString *key in allkeys) {
                        // 如果已经生成了一样的
                        if ([randomStr isEqualToString:tmpDict[key]]) {
                            randomStr = [NSString stringWithFormat:@"%@%@",randomStr,thirdArray[arc4random() % thirdArray.count]];
                        }
                    }
                    [replaceClassNameArray addObject:randomStr];
                    [tmpDict setValue:randomStr forKey:str];
                } else {
                    // 生成随机方法名 与待替换方法名组成key-value
                    NSArray *firstArray = @[@"sen", @"check", @"upload", @"refresh", @"has",@"rest", @"change", @"add", @"remove", @"is"];
                    NSArray *secondArray = @[@"Item", @"UserInfo", @"MediaInfo", @"Route", @"Common", @"Chat", @"Commis"];
                    NSArray *thirdArray = @[@"By", @"Of", @"With", @"And", @"From", @"To", @"In"];
                    NSArray *forthArray = @[@"Home", @"DrawMap", @"MediaID", @"Message", @"Loaction", @"Username", @"My"];
                    NSArray *fifthArray = @[@"Info", @"Count", @"Name", @"SystemId", @"Title", @"Topic", @"Action"];
                    NSString *randomStr = [NSString stringWithFormat:@"%@%@%@%@%@",firstArray[arc4random() % firstArray.count],secondArray[arc4random() % secondArray.count],thirdArray[arc4random() % thirdArray.count],forthArray[arc4random() % forthArray.count],fifthArray[arc4random() % fifthArray.count]];
                    NSArray *allkeys = [tmpDict allKeys];
                    for (NSString *key in allkeys) {
                        // 如果已经生成了一样的
                        if ([randomStr isEqualToString:tmpDict[key]]) {
                            randomStr = [NSString stringWithFormat:@"%@%@",randomStr,fifthArray[arc4random() % fifthArray.count]];
                        }
                    }
                    [tmpDict setValue:randomStr forKey:str];
                }
            }
            funcNameDict = [tmpDict copy];
        }
        printf("%s\n", [[NSString stringWithFormat:@"待替换和随机方法名对照表"] UTF8String]);
        printf("%s\n", [[NSString stringWithFormat:@"%@", funcNameDict] UTF8String]);
        // 保存对照表
        [funcNameDict writeToFile:funcNameKeyValuePath atomically:NO];
        printf("%s\n", [[NSString stringWithFormat:@"文件已生成"] UTF8String]);
        // 遍历目录 挨行替换
        ReplaceHandle *handle = [ReplaceHandle new];
        printf("%s\n", [[NSString stringWithFormat:@"ReplaceHandle初始化"] UTF8String]);
        printf("funcNameArray = %s\n", [[NSString stringWithFormat:@"%@", funcNameArray] UTF8String]);
        handle.funcNameArray = funcNameArray;
        printf("funcNameDict = %s\n", [[NSString stringWithFormat:@"%@", funcNameDict] UTF8String]);
        handle.funcNameDict = funcNameDict;
        
        printf("homeDirPath = %s\n", [[NSString stringWithFormat:@"%@", homeDirPath] UTF8String]);
        [handle replaceWithPath:homeDirPath];
        printf("%s\n", [[NSString stringWithFormat:@"---------------------------"] UTF8String]);
        printf("%s\n", [[NSString stringWithFormat:@"对照表已保存至funcnamekeyvalue文件, 为避免重复生成随机方法名, 请妥善保管文件"] UTF8String]);
        GenerateClass *gen = [GenerateClass new];
        gen.replaceClassNameArray = replaceClassNameArray;
        [gen generateClass:execPath];
        printf("%s\n", [[NSString stringWithFormat:@"生成的类已保存至newproject, 将其拖入项目即可"] UTF8String]);
        printf("%s\n", [[NSString stringWithFormat:@"---------------------------"] UTF8String]);
    }
    return 0;
}








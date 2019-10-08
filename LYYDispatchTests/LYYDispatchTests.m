//
//  LYYDispatchTests.m
//  LYYDispatchTests
//
//  Created by liyaoyao on 2019/10/6.
//  Copyright © 2019 liyaoyao. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <LYYDispatch/LYYDispatch.h>

@interface LYYDispatchTests : XCTestCase

@end

@implementation LYYDispatchTests

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}


- (void)testQueue {
    
//    全局队列异步执行
    __block int a = 0;
    Lyy_dispatchQueue().async(^{
        NSLog(@"全局队列异步执行 = %d", a);
        XCTAssert(a == 2, @"全局队列异步执行【失败】");
        a = 1;
    });
    a = 2;


//    全局队列同步执行
    __block int b = 0;
    Lyy_dispatchQueue().sync(^{
        NSLog(@"全局队列同步执行 = %d", b);
        XCTAssert(b == 0, @"全局队列同步执行【失败】");
    });
    b = 2;
    
    
    
//    自定义标识的全局队列执行
    Lyy_dispatchQueue().global(LYYDispatchQueuePriority.lyy_high).async(^{

    });
    


//    主线程异步执行
    __block int c = 0;
    Lyy_dispatchQueue().main().async(^{
        NSLog(@"主线程异步执行 = %d", c);
        XCTAssert(c == 2, @"主线程异步执行【失败】");
    });
    c = 2;
    

    
//    主线程同步执行
    __block int d = 0;
    Lyy_dispatchQueue().async(^{
       
        d = 1;
        Lyy_dispatchQueue().main().sync(^{
            NSLog(@"主线程同步执行 = %d", d);
            XCTAssert(d == 1, @"主线程同步执行【失败】");
        });
        d = 2;
        
    });
    
    
    
//    主线程延迟执行
    __block int e = 0;
    Lyy_dispatchQueue().main().asyncAfter(5.0, ^{
        NSLog(@"主线程延迟执行 = %d", e);
        XCTAssert(e == 3, @"主线程延迟执行【失败】");
    });
    e = 1;
    sleep(7);
    e = 3;
    
 
//队列在队列组中执行
    __block int f = 0;
    __block int g = 0;
    LYYDispatchGroup *group = Lyy_dispatchGroup();
    group.wait(20).mainQueueNotify(^{
        NSLog(@"[testQueue] 队列在队列组中执行 = %d, %d", f, g);
        XCTAssert(f == 2 && g == 2, @"[testQueue] 队列在队列组中执行【失败】");
        
    });
    Lyy_dispatchQueue().asyncInGroup(group, ^{
        f = 1;
        NSLog(@"[testQueue] 队列1开始 = %d", f);
        Lyy_dispatchQueue().asyncAfter(3.0, ^{
            f = 2;
            NSLog(@"[testQueue] 队列1完成 = %d", f);
            group.completion();
            
        });
        f = 3;
    });
    
    Lyy_dispatchQueue().asyncInGroup(group, ^{
        g = 1;
        NSLog(@"[testQueue] 队列2开始 = %d", g);
        Lyy_dispatchQueue().asyncAfter(3.0, ^{
            g = 2;
            NSLog(@"[testQueue] 队列2完成 = %d", g);
            group.completion();
            
        });
        g = 3;
    });
    
    sleep(20);
    
   
    
}

- (void)testGroup {
    
    __block int a = 0;
    __block int b = 0;
    __block int c = 0;
    Lyy_dispatchGroup().wait(10).async(^(LYYDispatchGroup * _Nonnull dispatchGroup) {

        NSLog(@"[testGroup] 队列1开始 = %d", a);
        Lyy_dispatchQueue().asyncAfter(2.0, ^{
            a = 2;
            NSLog(@"[testGroup] 队列1完成 = %d", a);
            dispatchGroup.completion();
            
        });
        
    }).async(^(LYYDispatchGroup * _Nonnull dispatchGroup) {
        
        NSLog(@"[testGroup] 队列2开始 = %d", b);
        Lyy_dispatchQueue().asyncAfter(5.0, ^{
            b = 2;
            NSLog(@"[testGroup] 队列2完成 = %d", b);
            dispatchGroup.completion();
            
        });
        
    }).async(^(LYYDispatchGroup * _Nonnull dispatchGroup) {
        
        NSLog(@"[testGroup] 队列3开始 = %d", c);
        Lyy_dispatchQueue().asyncAfter(8.0, ^{
            c = 2;
            NSLog(@"[testGroup] 队列3完成 = %d", c);
            dispatchGroup.completion();
            
        });
        
    }).mainQueueNotify(^{
        NSLog(@"[testGroup] 队列在队列组中执行 = %d, %d, %d", a, b, c);
        XCTAssert(a == 2 && b == 2 && c == 2, @"[testGroup] 队列在队列组中执行【失败】");
    });
    
    
    sleep(15);
    
    
    Lyy_dispatchGroup().wait(10).async(^(LYYDispatchGroup * _Nonnull dispatchGroup) {
        //任务1
        dispatchGroup.completion();
        
    }).async(^(LYYDispatchGroup * _Nonnull dispatchGroup) {
        
        //任务2
        dispatchGroup.completion();
        
    }).mainQueueNotify(^{
        // 任务完成
    });
}

- (void)testGroupInQueue {
    
    __block int a = 0;
    __block int b = 0;
    __block int c = 0;
    
    LYYDispatchGroup *group2 = Lyy_dispatchGroup().wait(10);

     group2.asyncInQueue(Lyy_dispatchQueue().getCurrentQueue, ^(LYYDispatchGroup * _Nonnull dispatchGroup) {
         
         NSLog(@"队列1开始 = %d", a);
               Lyy_dispatchQueue().asyncAfter(2.0, ^{
                   a = 2;
                   NSLog(@"队列1完成 = %d", a);
                   dispatchGroup.completion();
                   
               });

     });
     
     group2.asyncInQueue(Lyy_dispatchQueue().getCurrentQueue, ^(LYYDispatchGroup * _Nonnull dispatchGroup) {
         
         NSLog(@"队列2开始 = %d", b);
               Lyy_dispatchQueue().asyncAfter(5.0, ^{
                   b = 2;
                   NSLog(@"队列2完成 = %d", b);
                   dispatchGroup.completion();
                   
               });

     });
     
     group2.asyncInQueue(Lyy_dispatchQueue().getCurrentQueue, ^(LYYDispatchGroup * _Nonnull dispatchGroup) {
         
         NSLog(@"队列3开始 = %d", c);
                Lyy_dispatchQueue().asyncAfter(8.0, ^{
                    c = 2;
                    NSLog(@"队列3完成 = %d", c);
                    dispatchGroup.completion();
                    
                });

     });
    
    group2.mainQueueNotify(^{
        NSLog(@"[testGroupInQueue] 队列在队列组中执行 = %d, %d, %d", a, b, c);
        XCTAssert(a == 2 && b == 2 && c == 2, @"[testGroupInQueue] 队列在队列组中执行【失败】");
    });
    
    sleep(15);
    
}

- (void)testSema {
    
    __block int i = 0;
    LYYDispatchSemaphore *sema = Lyy_dispatchSemaphore(2);
    
    Lyy_dispatchQueue().asyncAfter(3.0, ^{
        i = 1;
        sema.signal();
    });
    
    sema.wait(10);
    i = 5;
    
    NSLog(@"信号量 = %d", i);
    XCTAssert(i == 5, @"信号量【失败】");

}

- (void)testOnce {
    
    NSObject *a = [self once];
    NSObject *b = [self once];
    NSObject *c = [self once];
    
    NSLog(@"a = %@, b = %@, c = %@", a, b, c);
    XCTAssert((a == b && b == c), @"代码执行一次【失败】");
    
}

- (NSObject *)once {
    static NSObject *instance = nil;
    Lyy_dispatchOnce(^{
        instance = [[NSObject alloc] init];
    });
    return instance;
}

- (void)testTimer {
    
    XCTestExpectation *exp = [[XCTestExpectation alloc] init];
    
    __block int i = 1;
   
    // 初始化定时器
    LYYDispatchSourceTimer *timer =  Lyy_dispatchSourceTimer(Lyy_dispatchQueue().getCurrentQueue);
    
    timer.setTimer(LYYDispatchTime.seconds(1))
    .eventHandler(^{
        NSLog(@"定时器，i = %d", i);
        i++;
    })
    .resume();
    
    
    Lyy_dispatchQueue().main().asyncAfter(20, ^{
        NSLog(@"定时器取消");
        timer.cancel();
        [exp fulfill];
    });
    
    [self waitForExpectations:@[exp] timeout:25];
    
}

- (void)testDispatchTime {
    
    // 永远
    LYYDispatchTime.distantFuture();
    // 当前
    LYYDispatchTime.now();
    // 10秒
    LYYDispatchTime.seconds(10);
    // 100毫秒
    LYYDispatchTime.milliseconds(100);
    // 100微秒
    LYYDispatchTime.microseconds(100);
}

@end

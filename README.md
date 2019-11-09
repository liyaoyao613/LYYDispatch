# LYYDispatch

[![Version](https://img.shields.io/cocoapods/v/LYYDispatch.svg?style=flat)](https://cocoapods.org/pods/LYYDispatch)	[![Platform](https://img.shields.io/badge/platform-ios%20%7C%20osx-green?style=flat)](https://cocoapods.org/pods/LYYDispatch)	[![License](https://img.shields.io/badge/license-MIT-green?style=flat)](https://cocoapods.org/pods/LYYDispatch)


## 简介

`LYYDispatch` 是对系统GCD的封装，采用链式思想，去除重复函数名，只保留函数名中的功能名称，使其看起来更简洁，调用更流畅

`LYYDispatch` 对`dispatch_time_t` 进行了函数封装，使用 `LYYDispatchTime`类创建时间类型， 使其调用时语义更明确

`LYYDispatch` 对GCD队列中的优先级，使用了类属性进行封装并对入参的优先级做了类型限定，使用时入参更明确

如使用`dispatch_group_t` 创建两个任务， 需要写很多`dispatch_group`相关的代码，代码如下：

```objective-c
dispatch_group_t group = dispatch_group_create();
dispatch_queue_t queue = dispatch_get_global_queue(0, 0);

dispatch_group_async(group, dispatch_get_global_queue(0, 0), ^{
   dispatch_group_enter(group);

    /// .....
    dispatch_group_leave(group);
});

dispatch_group_async(group, queue, ^{
   dispatch_group_enter(group);

    /// .....
    dispatch_group_leave(group);
});

dispatch_group_wait(group, 10);
dispatch_group_notify(group, dispatch_get_main_queue(), ^{

});
```

使用LYYDispatch后，dispatchGroup用于初始化，其他函数名只保留功能名，调用更加简单

```objective-c
Lyy_dispatchGroup().wait(10).async(^(LYYDispatchGroup * _Nonnull dispatchGroup) {

    //任务1
    dispatchGroup.completion();

}).async(^(LYYDispatchGroup * _Nonnull dispatchGroup) {

    //任务2
    dispatchGroup.completion();
    
}).mainQueueNotify(^{
    // 任务完成
});
```

## 支持的GCD类型

- dispatch_group_t
- dispatch_queue_t
- dispatch_semaphore
- dispatch_source_t
- dispatch_once
- dispatch_time_t

## 安装

在 `podfile` 文件中加入  `pod 'LYYDispatch' ` 即可

## 使用

- #### LYYDispatchQueue
  1、全局队列异步执行
  
	````objective-c
	Lyy_dispatchQueue().async(^{
     // 异步执行代码
	});
	````

  2、全局队列同步执行

	``` objective-c
	Lyy_dispatchQueue().sync(^{
     // 同步执行代码
	});
	```

  3、主线程异步执行

	```objective-c
  Lyy_dispatchQueue().main().async(^{
      // 主线程异步执行代码
  });
	```

  4、主线程同步执行

	```objective-c
  Lyy_dispatchQueue().async(^{
  
    Lyy_dispatchQueue().main().sync(^{
        // 主线程同步执行
    });
  });
	```

  5、主线程延迟执行

	```objective-c
  Lyy_dispatchQueue().main().asyncAfter(5.0, ^{
      // 主线程延迟执行
  });
	```

- #### LYYDispatchGroup
  1、创建队列组在默认队列中执行

	```objective-c
  Lyy_dispatchGroup().wait(10).async(^(LYYDispatchGroup * _Nonnull dispatchGroup) {
  
      // 任务1开始
      Lyy_dispatchQueue().asyncAfter(2.0, ^{
          // 任务1完成
          dispatchGroup.completion();
  
      });
  
  }).async(^(LYYDispatchGroup * _Nonnull dispatchGroup) {
  
      // 任务2开始
      Lyy_dispatchQueue().asyncAfter(5.0, ^{
          // 任务2完成
          dispatchGroup.completion();
  
      });
  
  }).mainQueueNotify(^{
      // 队列组所有任务执行完成后回调
  });
  ```

  2、创建队列组在自定义队列中执行

	```objective-c
  LYYDispatchGroup *group2 = Lyy_dispatchGroup().wait(10);
  group2.asyncInQueue(Lyy_dispatchQueue().getCurrentQueue, ^(LYYDispatchGroup * _Nonnull dispatchGroup) {
        
       // 任务1开始
       Lyy_dispatchQueue().asyncAfter(2.0, ^{
          // 任务1完成
           dispatchGroup.completion();
       });
   });
  
   group2.asyncInQueue(Lyy_dispatchQueue().getCurrentQueue, ^(LYYDispatchGroup * _Nonnull dispatchGroup) {
       // 任务2开始 
       Lyy_dispatchQueue().asyncAfter(5.0, ^{
          // 任务2完成
           dispatchGroup.completion();
       });
   });
  
  group2.mainQueueNotify(^{
     // 队列组所有任务执行完成后回调
  });
	```

- #### LYYDispatchOnce

	```objective-c
  static NSObject *instance = nil;
  Lyy_dispatchOnce(^{
       instance = [[NSObject alloc] init];
  });
  return instance;
	```

- #### LYYDispatchSemaphore

	```objective-c
  // 初始化信号量
  LYYDispatchSemaphore *sema = Lyy_dispatchSemaphore(2);
  Lyy_dispatchQueue().asyncAfter(3.0, ^{
      // 信号量释放
      sema.signal();
  });
  // 信号量等待
  sema.wait(10);
	```

- #### LYYDispatchSourceTimer
	
	```objective-c
	// 初始化定时器
	LYYDispatchSourceTimer *timer = Lyy_dispatchSourceTimer(Lyy_dispatchQueue().getCurrentQueue);
	  
	timer.setTimer(LYYDispatchTime.seconds(1))
	.eventHandler(^{
	    // 定时器事件
	})
	.resume();
	
	Lyy_dispatchQueue().main().asyncAfter(20, ^{
	    NSLog(@"定时器取消");
	    timer.cancel();
	});
	```

- #### LYYDispatchTime

  ```objective-c
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
  ```


## Unit Tests

`LYYDispatch` 包含了` unit tests`，见 `LYYDispatchTests/LYYDispatchTests.m` 文件，这些测试用例包含了 `LYYDispatch` 中常用方法的使用代码，您可以运行这些测试用例查看使用结果，或者参照测试用例中的写法。

## License

LYYDispatch is available under the [MIT license](https://github.com/liyaoyao613/LYYDispatch/blob/master/LICENSE). See the LICENSE file for more info.

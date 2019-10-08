//
//  LYYDispatch.h
//  LYYDispatch
//
//  Created by liyaoyao on 2019/10/4.
//  Copyright © 2019 liyaoyao. All rights reserved.
//

#import <Foundation/Foundation.h>

//! Project version number for LYYDispatch.
FOUNDATION_EXPORT double LYYDispatchVersionNumber;

//! Project version string for LYYDispatch.
FOUNDATION_EXPORT const unsigned char LYYDispatchVersionString[];

NS_ASSUME_NONNULL_BEGIN

typedef long LYYPriority;

@interface LYYDispatchQueuePriority : NSObject

@property (nonatomic, readonly, class) LYYPriority lyy_default;
@property (nonatomic, readonly, class) LYYPriority lyy_high;
@property (nonatomic, readonly, class) LYYPriority lyy_low;
@property (nonatomic, readonly, class) LYYPriority lyy_background;

LYYPriority lyy_dispatchQueuePriority(LYYPriority identifier);

@end

@interface LYYDispatchTime : NSObject


/// 当前时间
@property (nonatomic, readonly, class) unsigned long long (^now)(void);

/// 从不执行
@property (nonatomic, readonly, class) unsigned long long (^distantFuture)(void);

/// 获取秒
@property (nonatomic, readonly, class) unsigned long long (^seconds)(NSUInteger);

/// 获取毫秒
@property (nonatomic, readonly, class) unsigned long long (^milliseconds)(NSUInteger milliseconds);

/// 获取微秒
@property (nonatomic, readonly, class) unsigned long long (^microseconds)(NSUInteger microseconds);

@end

@interface LYYDispatchObject : NSObject

- (instancetype)init NS_UNAVAILABLE;

@end

@interface LYYDispatchGroup : LYYDispatchObject


/// 获取当前队列组
@property (nonatomic, readonly) dispatch_group_t getGroup;

/// 获取代码执行的队列
@property (nonatomic, readonly) dispatch_queue_t getCurrentQueue;

/// 当执行完代码调用此方法
@property (nonatomic, readonly) LYYDispatchGroup * (^completion)(void);

/// 异步执行，默认在全局队列执行，当 队列 中任务执行完毕后需要调用，dispatchGroup.completion();
@property (nonatomic, readonly) LYYDispatchGroup * (^async)(void (^block)(LYYDispatchGroup *dispatchGroup));

/// 异步在  queue 队列中执行，当 队列 中任务 执行完毕后需要调用，dispatchGroup.completion();
@property (nonatomic, readonly) LYYDispatchGroup * (^asyncInQueue)(dispatch_queue_t queue, void (^block)(LYYDispatchGroup *dispatchGroup));

/// 设置队列组的超时时间
@property (nonatomic, readonly) LYYDispatchGroup * (^wait)(dispatch_time_t timeout);

/// 当所以任务执行完成后，会调用此方法
@property (nonatomic, readonly) LYYDispatchGroup * (^mainQueueNotify)(dispatch_block_t notify);


/// 初始化线程组
LYYDispatchGroup * Lyy_dispatchGroup(void);

@end


@interface LYYDispatchQueue : LYYDispatchObject

/// 获取当前队列
@property (nonatomic, readonly) dispatch_queue_t getCurrentQueue;


/// 通过 dispatch_queue_create 创建队列，DISPATCH_QUEUE_SERIAL,
//* DISPATCH_QUEUE_CONCURRENT
@property (nonatomic, readonly) LYYDispatchQueue * (^create)(const char *_Nullable label,
dispatch_queue_attr_t _Nullable attr);

/// 异步执行
@property (nonatomic, readonly) LYYDispatchQueue * (^async)(dispatch_block_t block);

/// 将当前队列在队列组中执行，当任务执行完成之后需要调用 group.completion();
@property (nonatomic, readonly) LYYDispatchQueue * (^asyncInGroup)(LYYDispatchGroup *group, dispatch_block_t block);

/// 延迟 second 时间 异步执行
@property (nonatomic, readonly) LYYDispatchQueue * (^asyncAfter)(NSTimeInterval second, dispatch_block_t block);

/// 同步执行
@property (nonatomic, readonly) LYYDispatchQueue * (^sync)(dispatch_block_t block);

/// 获取主线程
@property (nonatomic, readonly) LYYDispatchQueue * (^main)(void);

/// 获取全局队列，传入优先级
@property (nonatomic, readonly) LYYDispatchQueue * (^global)(LYYPriority priority);

/// 栅栏同步
@property (nonatomic, readonly) LYYDispatchQueue * (^barrierSync)(dispatch_block_t block);

/// 栅栏异步
@property (nonatomic, readonly) LYYDispatchQueue * (^barrierAsync)(dispatch_block_t block);


/// 创建队列，默认为 global(0,0) 的全局队列
LYYDispatchQueue * Lyy_dispatchQueue(void);

@end


@interface LYYDispatchSemaphore : LYYDispatchObject

/// 设置等待超时时间
@property (nonatomic, readonly) LYYDispatchSemaphore * (^wait)(dispatch_time_t timeout);

/// 释放
@property (nonatomic, readonly) LYYDispatchSemaphore * (^signal)(void);

/// 初始化信号量实例
/// @param value 允许通过的最大信号数
LYYDispatchSemaphore * Lyy_dispatchSemaphore(long value);

@end


@interface LYYDispatchSourceTimer : LYYDispatchObject

/// 开始定时器
@property (nonatomic, readonly) LYYDispatchSourceTimer * (^resume)(void);

/// 挂起定时器
@property (nonatomic, readonly) LYYDispatchSourceTimer * (^suspend)(void);

/// 取消定时器，定时器实例也会被销毁
@property (nonatomic, readonly) LYYDispatchSourceTimer * (^cancel)(void);

/// 设置定时间隔
@property (nonatomic, readonly) LYYDispatchSourceTimer * (^setTimer)(uint64_t interval);

/// 设置定时器事件
@property (nonatomic, readonly) LYYDispatchSourceTimer * (^eventHandler)(dispatch_block_t handler);

/// 初始化定时器
/// @param queue 定时器在 queue 队列执行
LYYDispatchSourceTimer * Lyy_dispatchSourceTimer(dispatch_queue_t queue);

@end

@interface LYYDispatchOnce : LYYDispatchObject


/// 执行一次 block 中的代码
/// @param block 要执行一次的代码
void Lyy_dispatchOnce(dispatch_block_t block);

@end


NS_ASSUME_NONNULL_END

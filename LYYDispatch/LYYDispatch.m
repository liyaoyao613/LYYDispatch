//
//  LYYDispatch.m
//  LYYDispatch
//
//  Created by liyaoyao on 2019/10/4.
//  Copyright © 2019 liyaoyao. All rights reserved.
//

#import "LYYDispatch.h"

@implementation LYYDispatchQueuePriority

+ (LYYPriority)lyy_default {
    return DISPATCH_QUEUE_PRIORITY_DEFAULT;
}

+ (LYYPriority)lyy_low {
    return DISPATCH_QUEUE_PRIORITY_LOW;
}

+ (LYYPriority)lyy_high {
    return DISPATCH_QUEUE_PRIORITY_HIGH;
}

+ (LYYPriority)lyy_background {
    return DISPATCH_QUEUE_PRIORITY_BACKGROUND;
}

LYYPriority lyy_dispatchQueuePriority(LYYPriority identifier) {
    return identifier;
}

@end

@implementation LYYDispatchTime

+ (unsigned long long (^)(void))now {
    return ^{
        return DISPATCH_TIME_NOW;
    };
}

+ (unsigned long long (^)(void))distantFuture {
    return ^{
        return DISPATCH_TIME_FOREVER;
    };
}

+ (unsigned long long (^)(NSUInteger))seconds {
    return ^(NSUInteger second) {
        return second * NSEC_PER_SEC;
    };
}

+ (unsigned long long (^)(NSUInteger))milliseconds {
    return ^(NSUInteger mseconds) {
        return mseconds * NSEC_PER_MSEC;
    };
}

+ (unsigned long long (^)(NSUInteger))microseconds {
    return ^(NSUInteger mircseconds) {
        return mircseconds * NSEC_PER_USEC;
    };
}

@end

@implementation LYYDispatchObject

@end


@interface LYYDispatchGroup()

@property (nonatomic) dispatch_group_t group;
@property (nonatomic) dispatch_queue_t globalQueue;

@property (atomic, assign) NSUInteger taskCount;

@end

@implementation LYYDispatchGroup

LYYDispatchGroup * Lyy_dispatchGroup() {
    return [[[LYYDispatchGroup class] alloc] init];
}

- (dispatch_group_t)group {
    if (!_group) {
        _group = dispatch_group_create();
    }
    return _group;
}

- (dispatch_queue_t)globalQueue {
    if (!_globalQueue) {
        _globalQueue = dispatch_get_global_queue(0, 0);
    }
    return _globalQueue;
}

- (dispatch_group_t)getGroup {
    return self.group;
}

- (dispatch_queue_t)getCurrentQueue {
    return self.globalQueue;
}

- (LYYDispatchGroup * _Nonnull (^)(void))completion {
    return ^{
        if (self.taskCount > 0) {
            dispatch_group_leave(self.group);
        }
        return self;
    };
}

- (LYYDispatchGroup * _Nonnull (^)(void (^ _Nonnull)(LYYDispatchGroup * _Nonnull)))async {
    return ^(void(^block)(LYYDispatchGroup* _Nonnull)) {
       return self.asyncInQueue(self.globalQueue, block);
    };
}

- (LYYDispatchGroup * _Nonnull (^)(dispatch_queue_t, void (^ _Nonnull)(LYYDispatchGroup * _Nonnull)))asyncInQueue {
    
    return ^(dispatch_queue_t queue, void(^block)(LYYDispatchGroup* _Nonnull)) {

       if (queue == NULL) {
            return self;
       }
       dispatch_group_async(self.group, self.globalQueue, ^{
           if (block) {
               dispatch_group_enter(self.group);
               self.taskCount++;
               block(self);
           }
       });
       return self;
    };
}


- (LYYDispatchGroup * _Nonnull (^)(dispatch_time_t))wait {
       return ^(dispatch_time_t timeout) {
           dispatch_wait(self.group, timeout);
           return self;
        };
}

- (LYYDispatchGroup * _Nonnull (^)(dispatch_block_t _Nonnull))mainQueueNotify {
    return ^(dispatch_block_t block) {
        dispatch_group_notify(self.group, dispatch_get_main_queue(), ^{
            if (block) { block(); }
        });
        return self;
    };
}

@end


@interface LYYDispatchQueue ()

@property (nonatomic) dispatch_queue_t queue;

@end

@implementation LYYDispatchQueue

LYYDispatchQueue * Lyy_dispatchQueue() {
    LYYDispatchQueue *queue = [[[LYYDispatchQueue class] alloc] init];
    queue.global(0);
    return queue;
}

- (dispatch_queue_t)getCurrentQueue {
    return self.queue;
}

- (LYYDispatchQueue * _Nonnull (^)(const char * _Nullable, dispatch_queue_attr_t _Nullable))create {
    return ^(const char *_Nullable label,
    dispatch_queue_attr_t _Nullable attr) {
        self.queue = dispatch_queue_create(label, attr);
        return self;
    };
}

- (BOOL)isMainExecute {
    return self.queue == dispatch_get_main_queue()
    && [NSThread isMainThread];
}

- (LYYDispatchQueue * _Nonnull (^)(dispatch_block_t _Nonnull))async {
    return ^(dispatch_block_t block) {
        dispatch_async(self.queue, block);
        return self;
    };
}

- (LYYDispatchQueue * _Nonnull (^)( LYYDispatchGroup * _Nonnull, dispatch_block_t _Nonnull))asyncInGroup {
    return ^(LYYDispatchGroup *group, dispatch_block_t block) {

        group.asyncInQueue(self.queue, ^(LYYDispatchGroup * _Nonnull dispatchGroup) {
            if(block) block();
        });
        return self;
    };
}

- (LYYDispatchQueue * _Nonnull (^)(dispatch_block_t _Nonnull))sync {
    return ^(dispatch_block_t block) {
        if ([self isMainExecute]) {
            if (block) { block(); }
        }
        else {
            dispatch_sync(self.queue, block);
        }
        return self;
    };
}

- (LYYDispatchQueue * _Nonnull (^)(LYYPriority))global {
    return ^(LYYPriority identifier) {
        self.queue = dispatch_get_global_queue(identifier, 0);
        return self;
    };
}

- (LYYDispatchQueue * _Nonnull (^)(void))main {
    return ^{
        self.queue = dispatch_get_main_queue();
        return self;
    };
}

- (LYYDispatchQueue * _Nonnull (^)(NSTimeInterval, dispatch_block_t _Nonnull))asyncAfter {
    return ^(NSTimeInterval second, dispatch_block_t block) {
        
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(second * NSEC_PER_SEC)), self.queue, ^{
                if (block) { block(); }
            });
        return self;
    };
}

- (LYYDispatchQueue * _Nonnull (^)(dispatch_block_t _Nonnull))barrierAsync {
    return ^(dispatch_block_t block) {
        dispatch_barrier_async(self.queue, block);
        return self;
    };
}

- (LYYDispatchQueue * _Nonnull (^)(dispatch_block_t _Nonnull))barrierSync {
    return ^(dispatch_block_t block) {
        dispatch_barrier_sync(self.queue, block);
        return self;
    };
}

@end

@interface LYYDispatchSemaphore ()

@property (nonatomic) dispatch_semaphore_t sema;

@end

@implementation LYYDispatchSemaphore

LYYDispatchSemaphore * Lyy_dispatchSemaphore(long value) {
    LYYDispatchSemaphore *sema = [[[LYYDispatchSemaphore class] alloc] init];
    sema.sema = dispatch_semaphore_create(value);
    return sema;
}

- (LYYDispatchSemaphore * _Nonnull (^)(dispatch_time_t))wait {
    return ^(dispatch_time_t timeout) {
        dispatch_semaphore_wait(self.sema, timeout);
        return self;
    };
}

- (LYYDispatchSemaphore * _Nonnull (^)(void))signal {
    return ^{
        dispatch_semaphore_signal(self.sema);
        return self;
    };
}

@end


@interface LYYDispatchSourceTimer ()

@property (nonatomic) dispatch_source_t timer;

@end

@implementation LYYDispatchSourceTimer


- (LYYDispatchSourceTimer * _Nonnull (^)(void))resume {
    return ^{
        dispatch_resume(self.timer);
        return self;
    };
}

- (LYYDispatchSourceTimer * _Nonnull (^)(void))suspend {
    return ^{
        dispatch_suspend(self.timer);
        return self;
    };
}

- (LYYDispatchSourceTimer * _Nonnull (^)(void))cancel {
    return ^{
        dispatch_source_cancel(self.timer);
        self.timer = nil;
        return self;
    };
}


- (LYYDispatchSourceTimer * _Nonnull (^)(uint64_t))setTimer {
    return ^(uint64_t interval) {
        dispatch_source_set_timer(self.timer, dispatch_walltime(NULL, 0), interval, 0);
        return self;
    };
}

- (LYYDispatchSourceTimer * _Nonnull (^)(dispatch_block_t _Nonnull))eventHandler {
    return ^(dispatch_block_t handler) {
        dispatch_source_set_event_handler(self.timer, handler);
        return self;
    };
}

LYYDispatchSourceTimer * Lyy_dispatchSourceTimer(dispatch_queue_t queue) {
    LYYDispatchSourceTimer *source = [[[LYYDispatchSourceTimer class] alloc] init];
    source.timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    return source;
}

@end


@implementation LYYDispatchOnce

void Lyy_dispatchOnce(dispatch_block_t block) {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (block) { block(); }
    });
}


@end


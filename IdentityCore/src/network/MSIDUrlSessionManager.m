// Copyright (c) Microsoft Corporation.
// All rights reserved.
//
// This code is licensed under the MIT License.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files(the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and / or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions :
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "MSIDUrlSessionManager.h"
#import "MSIDUrlSessionDelegate.h"

static MSIDUrlSessionManager *s_defaultManager = nil;

@implementation MSIDUrlSessionManager

+ (void)initialize
{
    if (self == [MSIDUrlSessionManager self])
    {
        __auto_type configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        s_defaultManager = [[MSIDUrlSessionManager alloc] initWithConfiguration:configuration
                                                                       delegate:[MSIDUrlSessionDelegate new]];
    }
}

- (instancetype _Nullable )initWithConfiguration:(nonnull NSURLSessionConfiguration *)configuration
                                        delegate:(nullable MSIDUrlSessionDelegate *)delegate
{
    self = [super init];
    if (self)
    {
        _configuration = configuration;
        _session = [NSURLSession sessionWithConfiguration:configuration delegate:delegate delegateQueue:nil];
        _delegate = delegate;
    }
    
    return self;
}

- (void)dealloc
{
    [_session invalidateAndCancel];
}

+ (MSIDUrlSessionManager *)defaultManager
{
    return s_defaultManager;
}

+ (void)setDefaultManager:(MSIDUrlSessionManager *)defaultManager
{
    s_defaultManager = defaultManager;
}

@end

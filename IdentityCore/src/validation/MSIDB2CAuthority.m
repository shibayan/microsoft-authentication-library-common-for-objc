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

#import "MSIDB2CAuthority.h"
#import "MSIDB2CAuthorityResolver.h"
#import "MSIDTelemetryEventStrings.h"

@implementation MSIDB2CAuthority

- (instancetype)initWithURL:(NSURL *)url
                    context:(id<MSIDRequestContext>)context
                      error:(NSError **)error
{
    self = [super initWithURL:url context:context error:error];
    if (self)
    {
        _url = [self.class normalizedAuthorityUrl:url context:context error:error];
        if (!_url) return nil;
    }
    
    return self;
}

+ (BOOL)isAuthorityFormatValid:(NSURL *)url
                       context:(id<MSIDRequestContext>)context
                         error:(NSError **)error
{    
    if (![super isAuthorityFormatValid:url context:context error:error]) return NO;
    
    BOOL isB2c = NO;
    if (url.pathComponents.count >= 2)
    {
        isB2c = [[url.pathComponents[1] lowercaseString] isEqualToString:@"tfp"];
    }

    if (!isB2c)
    {
        if (error)
        {
            *error = MSIDCreateError(MSIDErrorDomain, MSIDErrorInternal, @"It is not B2C authority.", nil, nil, nil, context.correlationId, nil);
        }
        return NO;
    }
    
    if (url.pathComponents.count < 4)
    {
        if (error)
        {
            *error = MSIDCreateError(MSIDErrorDomain, MSIDErrorInternal, @"B2C authority should have at least 3 segments in the path (i.e. https://<host>/tfp/<tenant>/<policy>/...)", nil, nil, nil, context.correlationId, nil);
        }
        
        return NO;
    }
    
    return YES;
}

- (nonnull NSString *)telemetryAuthorityType
{
    return MSID_TELEMETRY_VALUE_AUTHORITY_B2C;
}

#pragma mark - Protected

- (id<MSIDAuthorityResolving>)resolver
{
    return [MSIDB2CAuthorityResolver new];
}

#pragma mark - Private

+ (NSURL *)normalizedAuthorityUrl:(NSURL *)url
                          context:(id<MSIDRequestContext>)context
                            error:(NSError **)error
{
    if (![self isAuthorityFormatValid:url context:context error:error])
    {
        return nil;
    }
    
    NSString *normalizedAuthorityUrl = [NSString stringWithFormat:@"https://%@/%@/%@/%@", [url msidHostWithPortIfNecessary], url.pathComponents[1], url.pathComponents[2], url.pathComponents[3]];
    
    return [NSURL URLWithString:normalizedAuthorityUrl];
}

@end
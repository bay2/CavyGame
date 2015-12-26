//
//  PropertyListing.h
//  goplay
//
//  Created by on 14-12-13.
//  Copyright (c) 2014年 goplay. All rights reserved.
//

#ifndef CavyGame_PropertyListing_h
#define CavyGame_PropertyListing_h
@interface NSObject (PropertyListing)

// aps suffix to avoid namespace collsion
//   ...for Andrew Paul Sardone
- (NSDictionary *)properties_aps;
- (NSDictionary *)properties_types;
@end
#endif

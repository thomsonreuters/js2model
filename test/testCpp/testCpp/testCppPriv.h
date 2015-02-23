/*
 *  testCppPriv.h
 *  testCpp
 *
 *  Created by Kevin on 2/23/15.
 *  Copyright (c) 2015 Thomson Retuers. All rights reserved.
 *
 */

/* The classes below are not exported */
#pragma GCC visibility push(hidden)

class testCppPriv
{
	public:
		void HelloWorldPriv(const char *);
};

#pragma GCC visibility pop

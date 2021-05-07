/*  RawData.h
 *  WhirlyGlobeLib
 *
 *  Created by Steve Gifford on 1/15/14.
 *  Copyright 2011-2021 mousebird consulting
 *
 *  Licensed under the Apache License, Version 2.0 (the "License");
 *  you may not use this file except in compliance with the License.
 *  You may obtain a copy of the License at
 *  http://www.apache.org/licenses/LICENSE-2.0
 *
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS,
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  See the License for the specific language governing permissions and
 *  limitations under the License.
 */

#import <ctime>
#import <vector>
#import <string>
#import <memory>
#import "WhirlyTypes.h"

namespace WhirlyKit
{

// Base class for NSData replacement (sort of).
// In this state it's read only
class RawData
{
public:
    RawData() = default;
    virtual ~RawData() = default;
    // Return a pointer to the raw data we're keeping
    virtual const unsigned char *getRawData() const = 0;
    // Length of the buffer
    virtual unsigned long getLen() const = 0;
    
protected:
};
    
typedef std::shared_ptr<RawData> RawDataRef;

// Read only version that wraps a random collection of bytes
class RawDataWrapper : public RawData
{
public:
    RawDataWrapper(const void *data,unsigned long dataLen,bool freeWhenDone);
    // If the data should be freed using something other than `::operator delete[](char*)`
    RawDataWrapper(const void *data,unsigned long dataLen,std::function<void(const void*)> freer);
    RawDataWrapper(const RawDataWrapper &) = delete;
    RawDataWrapper(RawDataWrapper &&) noexcept;
    virtual ~RawDataWrapper();

    // Return a pointer to the raw data we're keeping
    virtual const unsigned char *getRawData() const override { return data; }

    // Length of the raw data collected thus far
    unsigned long getLen() const override { return len; }
    
protected:
    const unsigned char *data;
    unsigned int len;
    std::function<void(const void*)> freeFunc;
};
typedef std::shared_ptr<RawDataWrapper> RawDataWrapperRef;
    
// Wrapper on top of a raw data object for reading more structured data
class RawDataReader
{
public:
    RawDataReader(const RawData *);
    virtual ~RawDataReader() = default;
    
    // True if we've reached the end of the buffer
    bool done() const;
    
    // Read an integer
    bool getInt(int &val);
    // Read a long integer
    bool getInt64(int64_t &val);
    // Read a double
    bool getDouble(double &val);
    // Read a string
    bool getString(std::string &str);
    
protected:
    const RawData *rawData;
    int pos;
};
    
// Read data from a file, return null if we fail
// Caller responsible for deletion
RawDataWrapper *RawDataFromFile(FILE *fp,unsigned int dataLen);

// You can add data to this one as needed
class MutableRawData : public RawData
{
public:
    MutableRawData() = default;
    // Make a copy of the data and store it
    MutableRawData(void *data,unsigned int size);
    // Allocate the given space
    MutableRawData(unsigned int size);
    virtual ~MutableRawData() = default;
    // Return a pointer to the raw data we're keeping
    virtual const unsigned char *getRawData() const override;
    // Length of the raw data collected thus far
    virtual unsigned long getLen() const override { return data.size(); }

    // Add an integer
    virtual void addInt(int iVal);
    // Add a long integer
    virtual void addInt64(int64_t iVal);
    // Add a double
    virtual void addDouble(double dVal);
    // Add a string
    virtual void addString(const std::string &str);
    
protected:
    std::vector<unsigned char> data;
};
    
typedef std::shared_ptr<MutableRawData> MutableRawDataRef;

}

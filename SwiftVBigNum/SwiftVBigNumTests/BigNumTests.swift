//
//  SwiftVBigNumTests.swift
//  SwiftVBigNumTests
//
//  Created by idz on 10/19/15.
//  Copyright © 2015 iOS Developer Zone. All rights reserved.
//

import XCTest
@testable import SwiftVBigNum

class SwiftVBigNumTests: XCTestCase {
    let u256_0 = UInt256()
    let u512_0 = UInt512()
    let u1024_0 = UInt1024()
    let s256_0 = SInt256()
    let s512_0 = SInt512()
    let s1024_0 = SInt1024()
    let u256_1 = UInt256(1)
    let u512_1 = UInt512(1)
    let u1024_1 = UInt1024(1)
    let s256_1 = SInt256(1)
    let s512_1 = SInt512(1)
    let s1024_1 = SInt1024(1)
    let u256_2 = UInt256(2)
    let u512_2 = UInt512(2)
    let u1024_2 = UInt1024(2)
    let s256_2 = SInt256(2)
    let s512_2 = SInt512(2)
    let s1024_2 = SInt1024(2)
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testInitializeToZero() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        let u256 = UInt256()
        let u512 = UInt512()
        let u1024 = UInt1024()
        let s256 = SInt256()
        let s512 = SInt512()
        let s1024 = SInt1024()
        let zero256 = Array<UInt8>(count: 256/8, repeatedValue: 0)
        let zero512 = Array<UInt8>(count: 512/8, repeatedValue: 0)
        let zero1024 = Array<UInt8>(count: 1024/8, repeatedValue: 0)
        XCTAssertEqual(u256.bytes, zero256)
        XCTAssertEqual(u512.bytes, zero512)
        XCTAssertEqual(u1024.bytes, zero1024)
        XCTAssertEqual(s256.bytes, zero256)
        XCTAssertEqual(s512.bytes, zero512)
        XCTAssertEqual(s1024.bytes, zero1024)
    }
    
    func testSignedInitialization() {
        let s256 = SInt256(-1)
        let s512 = SInt512(-1)
        let s1024 = SInt1024(-1)
        XCTAssertEqual(s256.intValue, -1)
        XCTAssertEqual(s512.intValue, -1)
        XCTAssertEqual(s1024.intValue, -1)
    }
    
    func testSimpleAddition() {
        XCTAssertEqual(u256_1 + u256_1, u256_2)
        XCTAssertEqual(u512_1 + u512_1, u512_2)
        XCTAssertEqual(u1024_1 + u1024_1, u1024_2)
        XCTAssertEqual(s256_1 + s256_1, s256_2)
        XCTAssertEqual(s512_1 + s512_1, s512_2)
        XCTAssertEqual(s1024_1 + s1024_1, s1024_2)
    }
    
    func testSimpleSubtraction() {
        XCTAssertEqual(u256_1 - u256_1, u256_0)
        XCTAssertEqual(u512_1 - u512_1, u512_0)
        XCTAssertEqual(u1024_1 - u1024_1, u1024_0)
        XCTAssertEqual(s256_1 - s256_1, s256_0)
        XCTAssertEqual(s512_1 - s512_1, s512_0)
        XCTAssertEqual(s1024_1 - s1024_1, s1024_0)
    }
    
    func simpleComparison<T:Comparable>(v1: T, _ v2: T) {
        XCTAssert(v1 < v2, "\(v1) is less than \(v2)")
        XCTAssertFalse(v2 < v1)
        XCTAssert(v2 > v1)
        XCTAssertFalse(v1 > v2)
        XCTAssert(v1 != v2)
        XCTAssert(v2 == v2)
    }
    
    func testSimpleComparison() {
        simpleComparison(u256_1, u256_2)
        simpleComparison(u512_1, u512_2)
        simpleComparison(u1024_1, u1024_2)
        simpleComparison(s256_1, s256_2)
        simpleComparison(s512_1, s512_2)
        simpleComparison(s1024_1, s1024_2)
        simpleComparison(s256_0 - s256_2, s256_0 - s256_1)
        simpleComparison(s512_0 - s512_1, s512_2)
        simpleComparison(s1024_1, s1024_2)

    }
    
    func testIntegerConversion() {
        XCTAssertEqual(UInt256(Int.max).intValue, Int.max)
        XCTAssertEqual(UInt512(Int.max).intValue, Int.max)
        XCTAssertEqual(UInt1024(Int.max).intValue, Int.max)
        XCTAssertEqual(SInt256(Int.max).intValue, Int.max)
        XCTAssertEqual(SInt512(Int.max).intValue, Int.max)
        XCTAssertEqual(SInt1024(Int.max).intValue, Int.max)
    }
    
    func hexStringConversion<T: BigNumWrapper>(type: T.Type, _ value: Int) {
        XCTAssertEqual(type.init(value).description, String(format:"%llx", value))
        // Currently the below is not used by the wrapper, but for code coverage we'll hit it
        XCTAssertEqual(hexStringFromArray(type.init(value).bytes.reverse(), uppercase: true), String(format:"%llX", value))
    }
    
    func testHexStringConversion() {
        for i in [0, 1, Int.max>>8, Int.max] {
            hexStringConversion(UInt256.self, i)
            hexStringConversion(UInt512.self, i)
            hexStringConversion(UInt1024.self, i)
        }
    }
    
    func hexStringInitialization<T: BigNumWrapper>(type: T.Type, _ value: Int) {
        XCTAssertEqual(type.init(hexString: String(format:"%llx", value)).intValue, value)
        XCTAssertEqual(type.init(hexString: String(format:"%llX", value)).intValue, value)
    }
    
    func testHexStringInitialization() {
        for i in [0, 1, Int.max>>8, Int.max] {
            hexStringInitialization(UInt256.self, i)
            hexStringInitialization(UInt512.self, i)
            hexStringInitialization(UInt1024.self, i)
            hexStringInitialization(SInt256.self, i)
            hexStringInitialization(SInt512.self, i)
            hexStringInitialization(SInt1024.self, i)
        }
    }
    func testUnsignedBitShifting() {
        for i in 0..<256 {
            let sl256 = u256_1 << i
            let sl512 = u512_1 << i
            let sl1024 = u1024_1 << i
            
            XCTAssertTrue(sl256.isBitSet(i))
            XCTAssertTrue(sl512.isBitSet(i))
            XCTAssertTrue(sl1024.isBitSet(i))
            
            XCTAssertEqual(sl256.highestSetBit(), i)
            XCTAssertEqual(sl512.highestSetBit(), i)
            XCTAssertEqual(sl1024.highestSetBit(), i)
        }
        for i in 256..<512 {
            let sl512 = u512_1 << i
            XCTAssertTrue(sl512.isBitSet(i))
            let sl1024 = u1024_1 << i
            XCTAssertTrue(sl1024.isBitSet(i))
        }
        for i in 512..<1024 {
            let sl1024 = u1024_1 << i
            XCTAssertTrue(sl1024.isBitSet(i))
        }
        var high1024 = UInt1024()
        high1024.setBit(1023)
        var high512 = UInt512()
        high512.setBit(511)
        var high256 = UInt256()
        high256.setBit(255)

        for i in 1023.stride(through: 512, by: -1) {
            let sr1024 = high1024 >> i
            XCTAssertTrue(sr1024.isBitSet(1023-i))
        }
        for i in 511.stride(through: 256, by: -1) {
            let sr1024 = high1024 >> i
            XCTAssertTrue(sr1024.isBitSet(1023-i))
            let sr512 = high512 >> i
            XCTAssertTrue(sr512.isBitSet(511-i))
        }
        for i in 255.stride(through: 0, by: -1) {
            let sr1024 = high1024 >> i
            XCTAssertTrue(sr1024.isBitSet(1023-i))
            let sr512 = high512 >> i
            XCTAssertTrue(sr512.isBitSet(511-i))
            let sr256 = high256 >> i
            XCTAssertTrue(sr256.isBitSet(255-i))
        }
    }
    
    func testSignedBitShifting() {
        for i in 0..<256 {
            let sl256 = s256_1 << i
            XCTAssertTrue(sl256.isBitSet(i))
            let sl512 = s512_1 << i
            XCTAssertTrue(sl512.isBitSet(i))
            let sl1024 = s1024_1 << i
            XCTAssertTrue(sl1024.isBitSet(i))
        }
        for i in 256..<512 {
            let sl512 = s512_1 << i
            XCTAssertTrue(sl512.isBitSet(i))
            let sl1024 = s1024_1 << i
            XCTAssertTrue(sl1024.isBitSet(i))
        }
        for i in 512..<1024 {
            let sl1024 = s1024_1 << i
            XCTAssertTrue(sl1024.isBitSet(i))
        }
        var high1024 = SInt1024()
        high1024.setBit(1023)
        var high512 = SInt512()
        high512.setBit(511)
        var high256 = SInt256()
        high256.setBit(255)
        
        for i in 1023.stride(through: 512, by: -1) {
            let sr1024 = high1024 >> i
            XCTAssertTrue(sr1024.isBitSet(1023-i))
        }
        for i in 511.stride(through: 256, by: -1) {
            let sr1024 = high1024 >> i
            XCTAssertTrue(sr1024.isBitSet(1023-i))
            let sr512 = high512 >> i
            XCTAssertTrue(sr512.isBitSet(511-i))
        }
        for i in 255.stride(through: 0, by: -1) {
            let sr1024 = high1024 >> i
            XCTAssertTrue(sr1024.isBitSet(1023-i))
            let sr512 = high512 >> i
            XCTAssertTrue(sr512.isBitSet(511-i))
            let sr256 = high256 >> i
            XCTAssertTrue(sr256.isBitSet(255-i))
        }
    }
    
    func mulAndDiv<T: BigNumWrapper>(v: T) {
        let vsq = v * v
        let vdiv = vsq / v
        XCTAssertEqual(v, vdiv)
    }
    
    func testMultiplicationAndDivision() {
        mulAndDiv(UInt256(Int.max))
        mulAndDiv(UInt512(Int.max))
        mulAndDiv(UInt1024(Int.max))
        mulAndDiv(SInt256(Int.max))
        mulAndDiv(SInt512(Int.max))
        mulAndDiv(SInt1024(Int.max))
    }
    
    func mod<T: BigNumWrapper>(v: T) {
        XCTAssertEqual(v.intValue, Int.max)
        let zero = T(0)
        let one = T(1)
        let two = T(2)
        XCTAssertEqual(v % v, zero)
        XCTAssertEqual(v % one, zero)
        XCTAssertEqual(v % two, one)
    }
    
    func testMod() {
        mod(UInt256(Int.max))
        mod(UInt512(Int.max))
        mod(UInt1024(Int.max))
        mod(SInt256(Int.max))
        mod(SInt512(Int.max))
        mod(SInt1024(Int.max))
    }
    
    func fmul<T:BigNumFullMultiplyWrapper where T.FullMultiplyResult: CustomStringConvertible>(m: T, _ r:String) {
        XCTAssertEqual((m.fmul(m)).description, r)
    }
    
    func testFullMultiplication() {
        let max256 = "7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff"
        let result256 = "3fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0000000000000000000000000000000000000000000000000000000000000001"
        let max512 = "7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff"
        let result512 = "3fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001"
        
        fmul(UInt256(hexString: max256), result256)
        fmul(SInt256(hexString: max256), result256)
        fmul(UInt512(hexString: max512), result512)
        fmul(SInt512(hexString: max512), result512)
        
    }
    
    func testCapacitites() {
        XCTAssertEqual(UInt256.capacityInBits, 256)
        XCTAssertEqual(UInt512.capacityInBits, 512)
        XCTAssertEqual(UInt1024.capacityInBits, 1024)
        XCTAssertEqual(SInt256.capacityInBits, 256)
        XCTAssertEqual(SInt512.capacityInBits, 512)
        XCTAssertEqual(SInt1024.capacityInBits, 1024)
    }
}

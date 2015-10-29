import Foundation
import Accelerate

public protocol BigNumWrapper: CustomStringConvertible, Comparable {
    typealias NativeType
    var bytes : [UInt8] { get set }
    var pointer : UnsafePointer<NativeType> { get }
    var mutablePointer : UnsafeMutablePointer<NativeType> { get }
    static var operations : Operations<NativeType> { get }
    /** Size in bytes of this type */
    static var capacityInBytes: Int { get }
    /** Size in bits of this count */
    static var capacityInBits: Int { get }
    
    init()
    init(_ intValue: Int)

    func add(_: Self) -> Self
    func sub(_: Self) -> Self
    func mul(_: Self) -> Self
    func div(_: Self) -> (Self, Self)
    func div(_: Self) -> Self
    func mod(_: Self) -> Self
    func shiftLeft(bits: UInt32) -> Self
    func shiftRight(bits: UInt32) -> Self
    
    var intValue : Int { get }
}

public protocol BigNumFullMultiplyWrapper : BigNumWrapper {
    typealias FullMultiplyResult
    func fmul(rsh: Self) -> FullMultiplyResult
}

//MARK: - Unsigned Types
public struct UInt256: CustomStringConvertible, BigNumFullMultiplyWrapper, UnsignedBigNum {
    public typealias NativeType = vU256
    public typealias FullMultiplyResult = UInt512
    public var bytes : [UInt8]
    public static let operations = Operations(neg: vU256Neg,
        shiftLeft: vLL256Shift, shiftRight: vLR256Shift,
        add: vU256Add, sub: vU256Sub, mul: vU256HalfMultiply, mod: vU256Mod, div: vU256Divide)
    public init() {
        bytes = Array<UInt8>(count: sizeof(NativeType), repeatedValue: 0)
    }
    public func fmul(rhs: UInt256) -> UInt512 {
        let r = UInt512()
        vU256FullMultiply(self.pointer, rhs.pointer, r.mutablePointer)
        return r
    }
}


public struct UInt512: CustomStringConvertible, BigNumFullMultiplyWrapper, UnsignedBigNum {
    public typealias NativeType = vU512
    public var bytes : [UInt8]
    public static let operations = Operations(neg: vU512Neg,
        shiftLeft: vLL512Shift, shiftRight: vLR512Shift,
        add: vU512Add, sub: vU512Sub, mul: vU512HalfMultiply,  mod: vU512Mod, div: vU512Divide)
    public init() {
        bytes = Array<UInt8>(count: sizeof(NativeType), repeatedValue: 0)
    }
    public func fmul(rhs: UInt512) -> UInt1024 {
        let r = UInt1024()
        vU512FullMultiply(self.pointer, rhs.pointer, r.mutablePointer)
        return r
    }
}

public struct UInt1024: CustomStringConvertible, BigNumWrapper, UnsignedBigNum {
    public typealias NativeType = vU1024
    public var bytes : [UInt8]
    public static let operations = Operations(neg: vU1024Neg,
        shiftLeft: vLL1024Shift, shiftRight: vLR1024Shift,
        add: vU1024Add, sub: vU1024Sub, mul: vU1024HalfMultiply, mod: vU1024Mod, div: vU1024Divide)
    public init() {
        bytes = Array<UInt8>(count: sizeof(NativeType), repeatedValue: 0)
    }
}

//MARK: - Signed Types
public func vAL256Shift(a: UnsafePointer<vS256>, _ shiftAmount: UInt32, _ result: UnsafeMutablePointer<vS256>) {
    vLL256Shift(UnsafePointer<vU256>(a), shiftAmount, UnsafeMutablePointer<vU256>(result))
}

public func vAR256Shift(a: UnsafePointer<vS256>, _ shiftAmount: UInt32, _ result: UnsafeMutablePointer<vS256>) {
    vA256Shift(a, shiftAmount, result)
}

public struct SInt256: CustomStringConvertible, BigNumFullMultiplyWrapper, SignedBigNum {
    public typealias NativeType = vS256
    public typealias FullMultiplyResult = SInt512
    public var bytes : [UInt8]
    public static let operations = Operations(neg: vS256Neg,
        shiftLeft: vAL256Shift, shiftRight: vAR256Shift,
        add: vS256Add, sub: vS256Sub, mul: vS256HalfMultiply, mod: vS256Mod, div: vS256Divide)
    public init() {
        bytes = Array<UInt8>(count: sizeof(NativeType), repeatedValue: 0)
    }
    public func fmul(rhs: SInt256) -> SInt512 {
        let r = SInt512()
        vS256FullMultiply(self.pointer, rhs.pointer, r.mutablePointer)
        return r
    }
}

public struct SInt512: CustomStringConvertible, BigNumFullMultiplyWrapper, SignedBigNum {
    public typealias NativeType = vS512
    public typealias FullMultiplyResult = SInt1024
    public var bytes : [UInt8]
    public static let operations = Operations(neg: vS512Neg,
        shiftLeft: vAL512Shift, shiftRight: vAR512Shift,
        add: vS512Add, sub: vS512Sub, mul: vS512HalfMultiply,  mod: vS512Mod, div: vS512Divide)
    public init() {
        bytes = Array<UInt8>(count: sizeof(NativeType), repeatedValue: 0)
    }
    public func fmul(rhs: SInt512) -> SInt1024 {
        let r = SInt1024()
        vS512FullMultiply(self.pointer, rhs.pointer, r.mutablePointer)
        return r
    }
}



//MARK: - Common Implementations
extension BigNumWrapper {

    public static var capacityInBytes : Int { return sizeof(NativeType)  }
    public static var capacityInBits : Int { return capacityInBytes*8 }
    
    public init<T: BigNumWrapper>(bigNumValue: T) {
        self.init(bytes: bigNumValue.bytes)
    }
    
    public init(hexString: String) {
        self.init(bytes:arrayFromHexString(hexString).reverse())
    }
    
    public init(bytes: [UInt8]) {
        self.init()
        let count = min(self.bytes.count, bytes.count)
        for var i = 0; i < count; i++ {
            self.bytes[i] = bytes[i]
        }
    }
    
    public var pointer : UnsafePointer<NativeType> {
        return UnsafePointer<NativeType>.init(self.bytes)
    }
    public var mutablePointer : UnsafeMutablePointer<NativeType> {
        return UnsafeMutablePointer<NativeType>.init(self.bytes)
    }
    public var description : String {
        return hexStringFromArray(bytes.reverse())
    }
    
    public func add(rhs: Self) -> Self {
        let r = Self()
        Self.operations.add(self.pointer, rhs.pointer, r.mutablePointer)
        return r
    }
    public func sub(rhs: Self) -> Self {
        let r = Self()
        Self.operations.sub(self.pointer, rhs.pointer, r.mutablePointer)
        return r
    }
    public func mul(rhs: Self) -> Self {
        let r = Self()
        Self.operations.mul(self.pointer, rhs.pointer, r.mutablePointer)
        return r
    }
    
    public func div(rhs: Self) -> (Self, Self) {
        let result = Self()
        let remainder = Self()
        Self.operations.div(self.pointer, rhs.pointer, result.mutablePointer, remainder.mutablePointer)
        return (result, remainder)
    }
    
    public func div(rhs: Self) -> Self {
        let (result, _) = div(rhs)
        return result
    }
    
    public func mod(rhs: Self) -> Self {
        let r = Self()
        Self.operations.mod(self.pointer, rhs.pointer, r.mutablePointer)
        return r
    }
    
    public func shiftLeft(bits: UInt32) -> Self {
        let r = Self()
        Self.operations.shiftLeft(self.pointer, bits, r.mutablePointer)
        return r
    }
    
    public func shiftRight(bits: UInt32) -> Self {
        let r = Self()
        Self.operations.shiftRight(self.pointer, bits, r.mutablePointer)
        return r
    }
    
    public func highestSetBit() -> Int {
        var i : Int
        for i = (bytes.count - 1); (i >= 0) && (bytes[i] == 0); i-- {
            /* empty body */
        }
        var j : Int
        for j = 7; j >= 0 && (bytes[i] & UInt8(1<<j) == 0); j-- {
            /* empty body */
        }
        return i * 8 + j
    }
    
    public mutating func setBit(index: Int) {
        bytes[index / 8] |= UInt8(1 << (index % 8))
    }
    
    public mutating func clearBit(index: Int) {
        bytes[index / 8] &= ~UInt8(1 << (index % 8))
    }
    
    public func isBitSet(index: Int) -> Bool {
        return (bytes[index / 8] & (UInt8(1 << (index % 8))) != 0)
    }
    
    /**
    * Signed compare
    */
    public func scmp(rhs: Self) -> Int {
        let msb = Self.capacityInBytes - 1
        // note reversed compare for msb
        for var i = msb; i >= 0; --i {
            if self.bytes[i] < rhs.bytes[i] {
                return (i == msb) ? 1 : -1
            }
            if self.bytes[i] > rhs.bytes[i] {
                return (i == msb) ? -1 : 1
            }
        }
        return 0
    }
    /**
    * Signed compare
    */
    public func ucmp(rhs: Self) -> Int {
        for var i = self.bytes.count - 1; i >= 0; --i {
            if self.bytes[i] < rhs.bytes[i] {
                return -1
            }
            if self.bytes[i] > rhs.bytes[i] {
                return 1
            }
        }
        return 0
    }
}

public protocol SignedBigNum : BigNumWrapper, Comparable {}
public protocol UnsignedBigNum : BigNumWrapper, Comparable {}

extension SignedBigNum {
    public init(_ intValue: Int) {
        self.init()
        let p = UnsafeMutablePointer<Int>(self.bytes)
        p.memory = intValue
        if(intValue < 0) {
            for i in sizeof(Int)..<self.bytes.count {
                self.bytes[i] = 0xFF
            }
        }
    }
    
    public var intValue: Int {
        return UnsafeMutablePointer<Int>(self.bytes)[0]
    }
}
extension UnsignedBigNum {
    public init(_ intValue: Int) {
        self.init()
        let count = self.bytes.count
        let p = UnsafeMutablePointer<Int>(self.bytes)
        p.memory = intValue
        assert(self.bytes.count == count)
    }
    
    public var intValue: Int {
        return UnsafeMutablePointer<Int>(self.bytes)[0]
    }
}

// vU128 Operations (in vBasicOps do not seem to be available in Swift (yet))
//public struct UInt128: CustomStringConvertible, BigNumWrapper {
//    public typealias NativeType = vU128
//    public var bytes : [UInt8]
//    public let operations = Operations(add: vU128Add, sub: vU128Sub, mul: vU128HalfMultiply, div : vU128Divide, mod: vU128Mod)
//    public init() {
//        bytes = Array<UInt8>(count: sizeof(NativeType), repeatedValue: 0)
//    }
//}


//MARK: - Shifting
public func vAL512Shift(a: UnsafePointer<vS512>, _ shiftAmount: UInt32, _ result: UnsafeMutablePointer<vS512>) {
    vLL512Shift(UnsafePointer<vU512>(a), shiftAmount, UnsafeMutablePointer<vU512>(result))
}

public func vAR512Shift(a: UnsafePointer<vS512>, _ shiftAmount: UInt32, _ result: UnsafeMutablePointer<vS512>) {
    vA512Shift(a, shiftAmount, result)
}



public func vAL1024Shift(a: UnsafePointer<vS1024>, _ shiftAmount: UInt32, _ result: UnsafeMutablePointer<vS1024>) {
    vLL1024Shift(UnsafePointer<vU1024>(a), shiftAmount, UnsafeMutablePointer<vU1024>(result))
}

public func vAR1024Shift(a: UnsafePointer<vS1024>, _ shiftAmount: UInt32, _ result: UnsafeMutablePointer<vS1024>) {
    vA1024Shift(a, shiftAmount, result)
}

public struct SInt1024: CustomStringConvertible, BigNumWrapper, SignedBigNum {
    public typealias NativeType = vS1024
    public var bytes : [UInt8]
    public static let operations = Operations(neg: vS1024Neg,
        shiftLeft: vAL1024Shift, shiftRight: vAR1024Shift,
        add: vS1024Add, sub: vS1024Sub, mul: vS1024HalfMultiply, mod: vS1024Mod, div: vS1024Divide)
    public init() {
        bytes = Array<UInt8>(count: sizeof(NativeType), repeatedValue: 0)
    }
}

//MARK: - Operators
//MARK: Arithmethic
public func +<T: BigNumWrapper>(lhs: T, rhs: T) -> T {
    return lhs.add(rhs)
}

public func -<T: BigNumWrapper>(lhs: T, rhs: T) -> T {
    return lhs.sub(rhs)
}

public func *<T: BigNumWrapper>(lhs: T, rhs: T) -> T  {
    return lhs.mul(rhs)
}

public func /<T: BigNumWrapper>(lhs: T, rhs: T) -> T {
    return lhs.div(rhs)
}

public func %<T: BigNumWrapper>(lhs: T, rhs: T) -> T {
    return lhs.mod(rhs)
}
//MARK: Shift
public func << <T: BigNumWrapper>(lhs: T, rhs: Int) -> T {
    return lhs.shiftLeft(UInt32(rhs))
}
public func >> <T: BigNumWrapper>(lhs: T, rhs: Int) -> T {
    return lhs.shiftRight(UInt32(rhs))
}
//MARK: Comparable
public func == <T: UnsignedBigNum>(lhs: T, rhs: T) -> Bool {
    return (lhs.ucmp(rhs) == 0)
}

public func < <T: UnsignedBigNum>(lhs: T, rhs: T) -> Bool {
    return (lhs.ucmp(rhs) == -1)
}

public func == <T: SignedBigNum>(lhs: T, rhs: T) -> Bool {
    return (lhs.scmp(rhs) == 0)
}

public func < <T: SignedBigNum>(lhs: T, rhs: T) -> Bool {
    return (lhs.scmp(rhs) == -1)
}
//MARK: - Utilities
func convertHexDigit(c : UnicodeScalar) -> UInt8
{
    switch c {
    case UnicodeScalar("0")...UnicodeScalar("9"): return UInt8(c.value - UnicodeScalar("0").value)
    case UnicodeScalar("a")...UnicodeScalar("f"): return UInt8(c.value - UnicodeScalar("a").value + 0xa)
    case UnicodeScalar("A")...UnicodeScalar("F"): return UInt8(c.value - UnicodeScalar("A").value + 0xa)
    default: fatalError("convertHexDigit: Invalid hex digit")
    }
}

public func arrayFromHexString(var s : String) -> [UInt8]
{
    if(s.unicodeScalars.count % 2 == 1) {
        s = "0" + s
    }
    var g = s.unicodeScalars.generate()
    var a : [UInt8] = []
    while let msn = g.next(), let lsn = g.next() {
        a += [ (convertHexDigit(msn) << 4 | convertHexDigit(lsn)) ]
    }
    return a
}

public func hexStringFromArray(a : [UInt8], uppercase : Bool = false) -> String
{
    let s = a.reduce("") {
        switch ($0, $1) {
            case ("", 0): // suppress leading zeros
                return ""
            case ("", let x) where x <= 0x0F: // first digit is single
                return String(format:uppercase ? "%X" : "%x", $1)
            default: // after first digit ensure two digits
                return String(format:uppercase ? "\($0)%02X" : "\($0)%02x", $1)
        }
    }
    return s == "" ? "0" : s
}

//MARK: - Implementation Details
public struct Operations<T> {
    typealias PT = UnsafePointer<T>
    typealias MPT = UnsafeMutablePointer<T>
    let neg: (PT, MPT) -> Void
    let shiftLeft, shiftRight: (PT, UInt32, MPT) -> Void
    let add, sub, mul, mod: (PT, PT, MPT) -> Void
    let div: (PT, PT, MPT, MPT) -> Void
}




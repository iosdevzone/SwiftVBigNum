/*:
# SwiftVBigNum Playground

Let's get the imports out of the way

*/
import Cocoa
import SwiftVBigNum
/*:

In the text that follows we will use `BigNum` where any one of the following is applicable: `UInt256`, `UInt512`, `UInt1024`, `SInt256`, `SInt512`, `SInt1024`.

## Initializing 

The default initializer creates a `BigNum` with the value of zero.

*/

let uzero256 = UInt256()
let uzero512 = UInt512()
let uzero1024 = UInt1024()
let szero256 = SInt256()
let szero512 = SInt512()
let szero1024 = SInt1024()
/*:
If the initialization value is small enough to be held in an `Int` you can use a literal `Int` value.
*/
let uint256_one = UInt256(1)
let uint512_two = UInt512(2)
let uint1024_three = UInt1024(3)
let sint256 = SInt256(-1)
sint256.description.characters.count
let sint512 = SInt512(-2)
sint512.description.characters.count
let sint1024 = SInt256(Int.min)
sint1024.description.characters.count
szero512 - sint512
/*:
You can also use big-endian hex strings. 

**WARNING**: Negative hex strings are not supported (yet).
*/

/*:
## Arithmetic Operators

The usual operations of addition, subtraction, division, multiplication and modulus are supported via the `+`, `-`, `/`, `*` and '%' operators respectively.

Unlike builtin Swift operators, these operators will not crash on overflow.
*/
let uint256two = uint256_one + uint256_one
let uint256one = uint256two - uint256_one
let intMax = UInt1024(Int.max)
let intMaxSquared = intMax * intMax
let intMaxSquaredSqrt = intMaxSquared / intMax
/*:
## Comparison Operators 

You can use all your favorite comparison operators

*/
uint256two >  uint256one
uint256two >= uint256one
uint256one >  uint256two
uint256one >= uint256two

uint256two <  uint256one
uint256two <= uint256one
uint256one <  uint256two
uint256one <= uint256two

uint256two != uint256one
uint256two != (uint256one + uint256one)

uint256two == uint256one
uint256two == (uint256one + uint256one)

/*:
## Shifting Operators

On both unsigned and signed types the `<<` operator shifts in zeros.
On unsigned types the `>>` operator shifts in zeros.
On signed types the `>>` operator shifts in the sign bit.
*/
let shifted5 = uint256one << 5
let rshifted5 = shifted5 >> 5
// ssl = Signed Shift Left (or Arithmetic)
let sslEg = SInt512(Int.min)
let sslEg1 = sslEg >> 1
let sslEg63 = sslEg >> 63
/*:
## Obtaining results

Given a `BigNum` `x` the easiest way to export the result of a calculation is to access the `x.bytes` array. This is a little endian array of the value. In the signed case, it is 2's complement.

For an unsigned `BigNum` `x`in the range `[0...Int.max]` the read-only propery `x.intValue` may be used.

For an signed `BigNum` `x`in the range `[Int.min...Int.max]` the read-only propery `x.intValue` may be used.

*/


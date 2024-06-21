/// Work with non-octet aligned bitstrings.
///
/// This library provides a class to work with bitstrings that are not
/// octet aligned. This is useful when working with BLE characteristics
/// that are not byte aligned.
library ble_bitstring;

/// Extract a sequence of bits from a list of integers and creates a list of
/// integers that are octet aligned.
///
/// This method assumes little-endian bit order.
///
/// The [bits] parameter represents the list of integers containing the bits.
/// The [startBit] parameter represents the starting bit offset of LSB.
/// The [numBits] parameter represents the number of bits to extract.
///
/// Returns a list of integers each containing an octet of the extracted bits.
///
/// The list is padded with zeros if the number of bits is not a multiple of 8
/// or if the extracted bits go beyond the end of the input list.
///
// FIXME: Handle null [numBits] and compute it from the length of the list
//        and [startBit].
List<int> extractBits(List<int> bits, int startBit, int numBits) {
// Calculate the starting byte index and bit offset within the byte
  int startByteIndex = startBit ~/ 8;
  int bitOffset = startBit % 8;

// Calculate the number of bytes needed to store the extracted bits
  int numBytes = (numBits + 7) ~/ 8;

// Create a new list to store the octet aligned bytes
  List<int> alignedBytes = List<int>.filled(numBytes, 0);

// Iterate over the bits and copy them to the aligned bytes
  int srcByteIndex = startByteIndex;
  int srcBitIndex = bitOffset;

  int dstByteIndex = 0;
  int dstBitIndex = 0;

  int remainingBits = numBits;

  while (remainingBits > 0) {
    // If we run out of bits, break so everything else is zero
    if (srcByteIndex >= bits.length) {
      break;
    }

    final bit = (bits[srcByteIndex] >> srcBitIndex) & 1;
    alignedBytes[dstByteIndex] |= (bit << dstBitIndex);

    // Next source bit
    srcBitIndex++;
    if (srcBitIndex >= 8) {
      srcBitIndex = 0;
      srcByteIndex++;
    }

    // Next destination bit
    dstBitIndex++;
    if (dstBitIndex >= 8) {
      dstBitIndex = 0;
      dstByteIndex++;
    }

    // Remaining bits
    remainingBits--;
  }

  return alignedBytes;
}

/// Version byte for the serialization format.
/// 0x01 = AES-256-GCM, nonce 12 bytes, mac 16 bytes.
const int payloadVersion = 0x01;
const int nonceLength = 12;
const int macLength = 16;

class EncryptedPayload {
  const EncryptedPayload({
    required this.nonce,
    required this.cipherText,
    required this.mac,
  });

  final List<int> nonce;
  final List<int> cipherText;
  final List<int> mac;

  List<int> toBytes() {
    return [
      payloadVersion,
      ...nonce,
      ...cipherText,
      ...mac,
    ];
  }

  static EncryptedPayload fromBytes(List<int> bytes) {
    if (bytes.length < 1 + nonceLength + macLength) {
      throw const FormatException('Payload too short');
    }
    if (bytes.first != payloadVersion) {
      throw FormatException('Unknown version byte: ${bytes.first}');
    }
    final cipherLength = bytes.length - 1 - nonceLength - macLength;
    return EncryptedPayload(
      nonce: bytes.sublist(1, 1 + nonceLength),
      cipherText: bytes.sublist(1 + nonceLength, 1 + nonceLength + cipherLength),
      mac: bytes.sublist(bytes.length - macLength),
    );
  }
}

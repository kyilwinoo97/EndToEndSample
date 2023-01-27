import 'dart:ffi';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:encrypt/encrypt.dart';
import 'package:tuple/tuple.dart';

class Utils {
  // static String strKey =
  //     '46779827415344318540240115946468';
  static String strKey =
      '42592728428703321236925148474342434122344263071636976354277340783285804493961';

  static Future<String> encryptAES(String plainText) async {
    final key = Key.fromUtf8(strKey.substring(0, 32));
    final iv = IV.fromLength(16);
    final encrypter = Encrypter(AES(key, mode: AESMode.cbc, padding: 'PKCS7'));
    Encrypted encrypted = encrypter.encrypt(plainText, iv: iv);
    return encrypted.base64;
  }

  static Future<Encrypted> encryptFile(List<int> data) async {
    final key = Key.fromUtf8(strKey.substring(0, 32));
    final iv = IV.fromLength(16);
    final encrypter = Encrypter(AES(key, mode: AESMode.cbc, padding: 'PKCS7'));
    Encrypted encrypted = encrypter.encryptBytes(data, iv: iv);
    return encrypted;
  }

  static Future<List<int>> decrypteFile(Encrypted data) async {
    final key = Key.fromUtf8(strKey.substring(0, 32));
    final iv = IV.fromLength(16);
    final encrypter = Encrypter(AES(key, mode: AESMode.cbc, padding: 'PKCS7'));
    final encrypted = encrypter.decryptBytes(data, iv: iv);
    return encrypted;
  }

  static Future<String> decryptAES(String cipherText) async {
    final key = Key.fromUtf8(strKey.substring(0, 32));
    final iv = IV.fromLength(16);
    final encrypter = Encrypter(AES(key, mode: AESMode.cbc, padding: 'PKCS7'));
    Encrypted encrypted = Encrypted.fromBase64(cipherText);

    final decryptedResult = encrypter.decrypt(encrypted, iv: iv);
    return decryptedResult;
  }

  //ECDH secp256k1
  static BigInt p = BigInt.parse(
      '0xfffffffffffffffffffffffffffffffffffffffffffffffffffffffefffffc2f');
  static BigInt a = BigInt.zero;
  static BigInt b = BigInt.from(7);
  static final g = Tuple2<BigInt, BigInt>(
      BigInt.parse(
          '0x79be667ef9dcbbac55a06295ce870b07029bfcdb2dce28d959f2815b16f81798'),
      BigInt.parse(
          '0x483ada7726a3c4655da4fbfc0e1108a8fd17b448a68554199c47d08ffb10d4b8'));
  static BigInt n = BigInt.parse(
      '0xfffffffffffffffffffffffffffffffebaaedce6af48a03bbfd25e8cd0364141');
  static BigInt h = BigInt.one;

  //Keypair generation and ECDSA}
  static Tuple2<BigInt, Tuple2<BigInt, BigInt>> makeKeyPair() {
    var privateKey = randomBigInt();

    // var privateKey = BigInt.parse(
    //     '8212308448452011741385831231354850718450218905446315711330357683071695536724433685434406444140353518533101161145472267315860604100878219089608213102799724');

    print("privateKey => $privateKey");
    var public_key = scalar_mult(privateKey, g);
    print("public key => $public_key");
    return Tuple2(BigInt.parse("$privateKey"), public_key);
  }

  ///testing
  ///60002328251770189352540919336565775490897309918916548218128552714741316630973
  ///60002328251770189352540919336565775490897309918916548218128552714741316630973
  ///104731356404495024724278121814638990198916867835497415851248168313806175297269
  ///104731356404495024724278121814638990198916867835497415851248168313806175297269
  static BigInt randomBigInt() {
    const size = 64;
    final random = Random.secure();
    final builder = BytesBuilder();
    for (var i = 0; i < size; ++i) {
      builder.addByte(random.nextInt(256));
    }
    final bytes = builder.toBytes();
    return readBytes(bytes);
  }

  static BigInt readBytes(Uint8List bytes) {
    BigInt read(int start, int end) {
      if (end - start <= 4) {
        int result = 0;
        for (int i = end - 1; i >= start; i--) {
          result = result * 256 + bytes[i];
        }
        return BigInt.from(result);
      }
      int mid = start + ((end - start) >> 1);
      var result = read(start, mid) +
          read(mid, end) * (BigInt.one << ((mid - start) * 8));
      return result;
    }

    return read(0, bytes.length);
  }

  static Tuple2<BigInt, BigInt>? point_add(
      Tuple2<BigInt, BigInt> point1, Tuple2<BigInt, BigInt> point2) {
    if (point1.item1 != BigInt.zero && point1.item2 != BigInt.zero) {
      assert(isOnCurve(point1));
    }
    if (point2.item1 != BigInt.zero && point2.item2 != BigInt.zero) {
      assert(isOnCurve(point2));
    }

    if (point1.item1 == BigInt.zero && point1.item2 == BigInt.zero) {
      ///0 + point2 = point2
      return point2;
    }
    if (point2.item1 == BigInt.zero && point2.item2 == BigInt.zero) {
      ///0 + point1 = point1
      return point1;
    }
    BigInt x1, x2, y1, y2;
    x1 = point1.item1;
    y1 = point1.item2;
    x2 = point2.item1;
    y2 = point2.item2;

    BigInt m;
    if (x1 == x2 && y1 != y2) {
      return null;
    }

    ///finding slope

    if (x1 == x2) {
      ///point addition
      m = (BigInt.from(3) * x1 * x1 + a) * inverse_mod(BigInt.two * y1, p);
    } else {
      ///point doubling
      m = (y1 - y2) * inverse_mod(x1 - x2, p);
    }

    BigInt x3 = m * m - x1 - x2;
    BigInt y3 = y1 + m * (x3 - x1);
    var result = Tuple2(x3 % p, -y3 % p);
    // print(result);
    //assert(isOnCurve(result));

    return result;
  }

  static Tuple2<BigInt, BigInt> scalar_mult(
      BigInt privateKey, Tuple2<BigInt, BigInt> point) {
    ///"""Returns k * point computed using the double and point_add algorithm."""

    assert(isOnCurve(point));

    if (privateKey % n == BigInt.zero || point == null) {
      return Tuple2(BigInt.zero, BigInt.zero);
    }
    if (privateKey < BigInt.zero) {
      ///# k * point = -k * (-point)
      return scalar_mult(-privateKey, point_neg(point));
    }
    Tuple2<BigInt, BigInt> result = Tuple2(BigInt.zero, BigInt.zero);
    var addend = point;
    while (privateKey > BigInt.zero) {
      if (privateKey & BigInt.one > BigInt.zero) {
        result = point_add(result, addend)!;
      }
      addend = point_add(addend, addend)!;

      privateKey >>= 1;
    }
    assert(isOnCurve(result!));
    return result!;
  }

  static bool isOnCurve(Tuple2<BigInt, BigInt> point) {
    /// """Returns True if the given point lies on the elliptic curve."""

    if (point == null) {
      return true;
    }
    BigInt x = point.item1;
    BigInt y = point.item2;

    return ((y * y - x * x * x - a * x - b) % p) == BigInt.zero;
  }

  static Tuple2<BigInt, BigInt> point_neg(Tuple2<BigInt, BigInt> point) {
    return Tuple2(point.item1, -point.item2);
  }

  static BigInt inverse_mod(BigInt a, BigInt b) {
    /// a = k, p = b
    ///    """Returns the inverse of k modulo p.
    ///    This function returns the only integer x such that (x * k) % p == 1.
    ///    k must be non-zero and p must be a prime.
    ///    """
    if (a == BigInt.zero) {
      throw Exception('Division by zero');
    }
    if (a < BigInt.zero) {
      ///k ** -1 = p - (-k) ** -1  (mod p)
      return b - inverse_mod(-a, b);
    }

    /// Extended Euclidean algorithm.

    BigInt k = a;
    BigInt p = b;
    BigInt x = BigInt.zero;
    BigInt y = BigInt.one;
    BigInt u = BigInt.one;
    BigInt v = BigInt.zero;

    while (a != BigInt.zero) {
      BigInt q = BigInt.from((b / a).floor());
      BigInt r = (b % a);
      BigInt m = x - u * q;
      BigInt n = y - v * q;
      b = a;
      a = r;
      x = u;
      y = v;
      u = m;
      v = n;
    }
    BigInt gcd = b;
    assert(gcd == BigInt.one);
    assert((k * x) % p == BigInt.one);
    //83174505189910067536517124096019359197644205712500122884473429251812128958118
    //83174505189910067536517124096019359197644205712500122884473429251812128958118
    return x % p;
  }
}

import 'package:end_to_end_sample/Utils.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test("Testing initial point p", () {
    expect(Utils.p, BigInt.parse(''));
  });
}

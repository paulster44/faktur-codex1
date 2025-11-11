import 'package:flutter_test/flutter_test.dart';

import 'package:faktur/src/domain/value_objects/money.dart';

void main() {
  test('money arithmetic maintains integer cents', () {
    const money = Money(1500); // $15.00
    const other = Money(349);
    expect((money + other).cents, 1849);
    expect((money - other).cents, 1151);
  });

  test('percentage calculation rounds to nearest cent', () {
    const money = Money(1000); // $10.00
    expect(money.percentage(7.25).cents, 73);
  });

  test('clamp at zero prevents negative balances', () {
    const money = Money(-50);
    expect(money.clampAtZero().cents, 0);
  });
}

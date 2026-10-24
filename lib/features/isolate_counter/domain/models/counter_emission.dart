import 'package:grand_app_ia_challange1/features/isolate_counter/domain/models/parity_enum.dart';

final class CounterEmission {
  const CounterEmission({required this.value, required this.parity});

  final int value;
  final ParityEnum parity;

  @override
  bool operator ==(Object other) =>
      other is CounterEmission &&
      other.value == value &&
      other.parity == parity;

  @override
  int get hashCode => Object.hash(value, parity);

  @override
  String toString() => 'CounterEmission($value, ${parity.name})';
}

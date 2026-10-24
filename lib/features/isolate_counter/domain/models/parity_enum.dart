enum ParityEnum {
  odd(firstValue: 1),
  even(firstValue: 2);

  const ParityEnum({required this.firstValue});

  final int firstValue;

  ParityEnum get opposite => switch (this) {
    ParityEnum.odd => ParityEnum.even,
    ParityEnum.even => ParityEnum.odd,
  };
}

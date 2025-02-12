typedef RecordParameter = (String package, String author, int year, bool valid);

const RecordParameter getRecordParameter =
    ('dart_ddi', 'Willian Marchesan', 2024, true);

class FactoryParameter {
  FactoryParameter(this.parameter);

  final RecordParameter parameter;
}

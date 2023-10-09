class CreateTableWrapper {
  CreateTableWrapper({
    required this.table,
    required this.query,
    this.checkTableExist = true,
  })  : assert(
          table.isNotEmpty,
          'Table name cannot be empty',
        ),
        assert(
          query.isNotEmpty,
          'Query cannot be empty',
        ),
        assert(
          query.contains('CREATE TABLE'),
          'Your query should start with CREATE TABLE',
        );

  final String table;
  final String query;
  final bool checkTableExist;
}

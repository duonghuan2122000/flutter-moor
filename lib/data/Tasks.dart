import 'package:moor_flutter/moor_flutter.dart';

part 'Tasks.g.dart';

class Tasks extends Table{
  IntColumn get id => integer().autoIncrement()();
  TextColumn get tagName =>
      text().nullable().customConstraint("REFERENCES tags(name)")();
  TextColumn get name => text().withLength(min: 1, max: 50)();
  DateTimeColumn get dueDate => dateTime().nullable()();
  BoolColumn get completed => boolean().withDefault(Constant(false))();
}

class Tags extends Table{
  TextColumn get name => text().withLength(min: 1, max: 10)();
  IntColumn get color => integer()();

  @override
  Set<Column> get primaryKey => {name};
}

class TaskWithTag{
  final Task task;
  final Tag tag;

  TaskWithTag({
    @required this.task,
    @required this.tag
});
}

@UseMoor(tables: [Tasks, Tags], daos: [TaskDao, TagDao])
class AppDatabase extends _$AppDatabase{
  AppDatabase(): super(
    FlutterQueryExecutor.inDatabaseFolder(path: "db.sqlite", logStatements: false)
  );

  @override
  // TODO: implement schemaVersion
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onUpgrade: (migrator, from, to) async{
      if(from == 1){
        await migrator.addColumn(tasks, tasks.tagName);
        await migrator.createTable(tags);
      }
    },
    beforeOpen: (details) async{
      await customStatement("PRAGMA foreign_keys = ON");
    }
  ) ;
}

@UseDao(tables: [Tasks, Tags])
class TaskDao extends DatabaseAccessor<AppDatabase> with _$TaskDaoMixin{
  final AppDatabase db;

  TaskDao(this.db) : super(db);

  Future<List<Task>> getAllTasks() => select(tasks).get();

  Stream<List<TaskWithTag>> watchAllTasks(){
    return (
        select(tasks)
          ..orderBy([
                (t) => OrderingTerm(expression: t.dueDate, mode: OrderingMode.desc),
                (t) => OrderingTerm(expression: t.name)
          ])

    ).join([
      leftOuterJoin(tags, tags.name.equalsExp(tasks.tagName))
    ]).watch().map((rows) => rows.map((row){
          return TaskWithTag(task: row.readTable(tasks), tag: row.readTable(tags));
      }).toList()
    );
  }

  Stream<List<TaskWithTag>> watchCompletedTasks(){
    return (
        select(tasks)
        ..orderBy([
          (t) => OrderingTerm(expression: t.dueDate, mode: OrderingMode.desc),
          (t) => OrderingTerm(expression: t.name)
        ])
        ..where((t) => t.completed.equals(true))
    ).join([
      leftOuterJoin(tags, tags.name.equalsExp(tasks.tagName))
    ])
        .watch().map((rows) => rows.map((row){
          return TaskWithTag(task: row.readTable(tasks), tag: row.readTable(tags));
    }).toList()
    );
  }

  Stream<List<Task>> watchCompletedTasksCustom(){
    return customSelectQuery(
      'SELECT * FROM tasks WHERE completed = 1 ORDER BY due_date DESC, name;',
      readsFrom: {tasks}
    ).watch().map((rows){
      return rows.map((row) => Task.fromData(row.data, db)).toList();
    });
  }

  Future insertTask(Task task) => into(tasks).insert(task);

  Future updateTask(Task task) => update(tasks).replace(task);

  Future deleteTask(Task task) => delete(tasks).delete(task);
}

@UseDao(tables: [Tags])
class TagDao extends DatabaseAccessor<AppDatabase> with _$TagDaoMixin{
  final AppDatabase db;

  TagDao(this.db) : super(db);

  Stream<List<Tag>> watchTags() => select(tags).watch();

  Future insertTag(Tag tag) => into(tags).insert(tag);
}
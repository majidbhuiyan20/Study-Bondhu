import 'dart:async';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import '../core/constants/app_constants.dart';
import 'database_tables.dart';

class AppDatabase {
  AppDatabase._();
  static final AppDatabase instance = AppDatabase._();

  Database? _db;
  Completer<Database>? _opening;

  Future<Database> get database async {
    if (_db != null) return _db!;
    if (_opening != null) return _opening!.future;
    _opening = Completer<Database>();
    try {
      final dir = await getApplicationDocumentsDirectory();
      final path = p.join(dir.path, AppConstants.dbName);
      final db = await openDatabase(
        path,
        version: AppConstants.dbVersion,
        onConfigure: (d) async {
          await d.execute('PRAGMA foreign_keys = ON');
        },
        onCreate: _onCreate,
        onUpgrade: _onUpgrade,
      );
      _db = db;
      _opening!.complete(db);
      return db;
    } catch (e, st) {
      _opening!.completeError(e, st);
      _opening = null;
      rethrow;
    }
  }

  Future<void> _onCreate(Database db, int version) async {
    final batch = db.batch();

    // Profiles — academic context (school/college/university/madrasa,
    // class label, institution). Subjects and semesters are grouped under a
    // profile so a student who switches between e.g. school and a coaching
    // batch keeps things separate.
    batch.execute('''
      CREATE TABLE ${Tables.profiles} (
        ${Columns.id} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${Columns.profileName} TEXT NOT NULL,
        ${Columns.profileLevel} TEXT NOT NULL DEFAULT 'school',
        ${Columns.profileClassLabel} TEXT,
        ${Columns.profileInstitution} TEXT,
        ${Columns.profileDepartment} TEXT,
        ${Columns.profileStudentId} TEXT,
        ${Columns.profileActive} INTEGER NOT NULL DEFAULT 0,
        ${Columns.createdAt} INTEGER NOT NULL
      )
    ''');

    // Semesters
    batch.execute('''
      CREATE TABLE ${Tables.semesters} (
        ${Columns.id} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${Columns.semesterName} TEXT NOT NULL,
        ${Columns.semesterStart} INTEGER,
        ${Columns.semesterEnd} INTEGER,
        ${Columns.semesterActive} INTEGER NOT NULL DEFAULT 0,
        ${Columns.semesterProfile} INTEGER,
        ${Columns.createdAt} INTEGER NOT NULL,
        FOREIGN KEY(${Columns.semesterProfile}) REFERENCES ${Tables.profiles}(${Columns.id}) ON DELETE SET NULL
      )
    ''');

    // Subjects
    batch.execute('''
      CREATE TABLE ${Tables.subjects} (
        ${Columns.id} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${Columns.subjectName} TEXT NOT NULL,
        ${Columns.subjectCode} TEXT,
        ${Columns.subjectCredit} REAL,
        ${Columns.subjectTeacher} TEXT,
        ${Columns.subjectColor} TEXT NOT NULL DEFAULT '#4F46E5',
        ${Columns.subjectSemesterId} INTEGER,
        ${Columns.subjectTarget} REAL NOT NULL DEFAULT 75,
        ${Columns.createdAt} INTEGER NOT NULL,
        FOREIGN KEY(${Columns.subjectSemesterId}) REFERENCES ${Tables.semesters}(${Columns.id}) ON DELETE SET NULL
      )
    ''');

    // Topics
    batch.execute('''
      CREATE TABLE ${Tables.topics} (
        ${Columns.id} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${Columns.topicName} TEXT NOT NULL,
        ${Columns.topicSubjectId} INTEGER NOT NULL,
        ${Columns.topicCompleted} INTEGER NOT NULL DEFAULT 0,
        ${Columns.topicConfidence} INTEGER NOT NULL DEFAULT 3,
        ${Columns.topicOrder} INTEGER NOT NULL DEFAULT 0,
        ${Columns.topicParentId} INTEGER,
        ${Columns.topicStatus} TEXT NOT NULL DEFAULT 'notStarted',
        ${Columns.createdAt} INTEGER NOT NULL,
        FOREIGN KEY(${Columns.topicSubjectId}) REFERENCES ${Tables.subjects}(${Columns.id}) ON DELETE CASCADE,
        FOREIGN KEY(${Columns.topicParentId}) REFERENCES ${Tables.topics}(${Columns.id}) ON DELETE CASCADE
      )
    ''');

    // Syllabus
    batch.execute('''
      CREATE TABLE ${Tables.syllabusItems} (
        ${Columns.id} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${Columns.syllabusSubjectId} INTEGER NOT NULL,
        ${Columns.syllabusTitle} TEXT NOT NULL,
        ${Columns.syllabusDescription} TEXT,
        ${Columns.syllabusDone} INTEGER NOT NULL DEFAULT 0,
        ${Columns.syllabusOrder} INTEGER NOT NULL DEFAULT 0,
        ${Columns.syllabusCompletedAt} INTEGER,
        ${Columns.createdAt} INTEGER NOT NULL,
        FOREIGN KEY(${Columns.syllabusSubjectId}) REFERENCES ${Tables.subjects}(${Columns.id}) ON DELETE CASCADE
      )
    ''');

    // Assignments
    batch.execute('''
      CREATE TABLE ${Tables.assignments} (
        ${Columns.id} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${Columns.assignmentSubjectId} INTEGER,
        ${Columns.assignmentTopicId} INTEGER,
        ${Columns.assignmentTitle} TEXT NOT NULL,
        ${Columns.assignmentDescription} TEXT,
        ${Columns.assignmentDue} INTEGER,
        ${Columns.assignmentPriority} TEXT NOT NULL DEFAULT 'medium',
        ${Columns.assignmentStatus} TEXT NOT NULL DEFAULT 'pending',
        ${Columns.assignmentCompletedAt} INTEGER,
        ${Columns.assignmentType} TEXT NOT NULL DEFAULT 'assignment',
        ${Columns.assignmentEstimatedMinutes} INTEGER,
        ${Columns.assignmentNotes} TEXT,
        ${Columns.createdAt} INTEGER NOT NULL,
        FOREIGN KEY(${Columns.assignmentSubjectId}) REFERENCES ${Tables.subjects}(${Columns.id}) ON DELETE SET NULL,
        FOREIGN KEY(${Columns.assignmentTopicId}) REFERENCES ${Tables.topics}(${Columns.id}) ON DELETE SET NULL
      )
    ''');

    // Assignment subtasks — spec 06 §"Subtasks". CASCADE on parent.
    batch.execute('''
      CREATE TABLE ${Tables.assignmentSubtasks} (
        ${Columns.id} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${Columns.subtaskAssignmentId} INTEGER NOT NULL,
        ${Columns.subtaskTitle} TEXT NOT NULL,
        ${Columns.subtaskIsDone} INTEGER NOT NULL DEFAULT 0,
        ${Columns.subtaskOrder} INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY(${Columns.subtaskAssignmentId}) REFERENCES ${Tables.assignments}(${Columns.id}) ON DELETE CASCADE
      )
    ''');

    // Exams
    batch.execute('''
      CREATE TABLE ${Tables.exams} (
        ${Columns.id} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${Columns.examSubjectId} INTEGER,
        ${Columns.examTitle} TEXT NOT NULL,
        ${Columns.examDate} INTEGER NOT NULL,
        ${Columns.examStartTime} INTEGER,
        ${Columns.examTime} TEXT,
        ${Columns.examLocation} TEXT,
        ${Columns.examType} TEXT NOT NULL DEFAULT 'midterm',
        ${Columns.examSyllabus} TEXT,
        ${Columns.examNotes} TEXT,
        ${Columns.examTotalMarks} REAL,
        ${Columns.examObtained} REAL,
        ${Columns.createdAt} INTEGER NOT NULL,
        FOREIGN KEY(${Columns.examSubjectId}) REFERENCES ${Tables.subjects}(${Columns.id}) ON DELETE SET NULL
      )
    ''');

    // Attendance
    batch.execute('''
      CREATE TABLE ${Tables.attendance} (
        ${Columns.id} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${Columns.attendanceSubjectId} INTEGER NOT NULL,
        ${Columns.attendanceDate} INTEGER NOT NULL,
        ${Columns.attendanceStatus} TEXT NOT NULL DEFAULT 'present',
        ${Columns.attendanceNote} TEXT,
        ${Columns.createdAt} INTEGER NOT NULL,
        FOREIGN KEY(${Columns.attendanceSubjectId}) REFERENCES ${Tables.subjects}(${Columns.id}) ON DELETE CASCADE
      )
    ''');

    // Study sessions
    batch.execute('''
      CREATE TABLE ${Tables.studySessions} (
        ${Columns.id} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${Columns.sessionSubjectId} INTEGER,
        ${Columns.sessionTopicId} INTEGER,
        ${Columns.sessionStart} INTEGER NOT NULL,
        ${Columns.sessionEnd} INTEGER NOT NULL,
        ${Columns.sessionDurationSec} INTEGER NOT NULL,
        ${Columns.sessionNotes} TEXT,
        ${Columns.sessionFocusRating} INTEGER NOT NULL DEFAULT 3,
        ${Columns.sessionMode} TEXT NOT NULL DEFAULT 'focus',
        ${Columns.createdAt} INTEGER NOT NULL,
        FOREIGN KEY(${Columns.sessionSubjectId}) REFERENCES ${Tables.subjects}(${Columns.id}) ON DELETE SET NULL,
        FOREIGN KEY(${Columns.sessionTopicId}) REFERENCES ${Tables.topics}(${Columns.id}) ON DELETE SET NULL
      )
    ''');

    // Revision
    batch.execute('''
      CREATE TABLE ${Tables.revisionItems} (
        ${Columns.id} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${Columns.revisionSubjectId} INTEGER,
        ${Columns.revisionTopicId} INTEGER,
        ${Columns.revisionDate} INTEGER NOT NULL,
        ${Columns.revisionStatus} TEXT NOT NULL DEFAULT 'pending',
        ${Columns.revisionInterval} INTEGER NOT NULL DEFAULT 1,
        ${Columns.createdAt} INTEGER NOT NULL,
        FOREIGN KEY(${Columns.revisionSubjectId}) REFERENCES ${Tables.subjects}(${Columns.id}) ON DELETE SET NULL,
        FOREIGN KEY(${Columns.revisionTopicId}) REFERENCES ${Tables.topics}(${Columns.id}) ON DELETE SET NULL
      )
    ''');

    // Notes
    batch.execute('''
      CREATE TABLE ${Tables.notes} (
        ${Columns.id} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${Columns.noteSubjectId} INTEGER,
        ${Columns.noteTopicId} INTEGER,
        ${Columns.noteTitle} TEXT NOT NULL,
        ${Columns.noteBody} TEXT NOT NULL,
        ${Columns.notePinned} INTEGER NOT NULL DEFAULT 0,
        ${Columns.createdAt} INTEGER NOT NULL,
        ${Columns.updatedAt} INTEGER NOT NULL,
        FOREIGN KEY(${Columns.noteSubjectId}) REFERENCES ${Tables.subjects}(${Columns.id}) ON DELETE SET NULL,
        FOREIGN KEY(${Columns.noteTopicId}) REFERENCES ${Tables.topics}(${Columns.id}) ON DELETE SET NULL
      )
    ''');

    // Flashcards (decks stored as subjects rows, cards below)
    batch.execute('''
      CREATE TABLE ${Tables.flashcards} (
        ${Columns.id} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${Columns.deckSubjectId} INTEGER,
        ${Columns.deckName} TEXT NOT NULL,
        ${Columns.createdAt} INTEGER NOT NULL,
        FOREIGN KEY(${Columns.deckSubjectId}) REFERENCES ${Tables.subjects}(${Columns.id}) ON DELETE SET NULL
      )
    ''');

    // Use a separate table to store cards (re-using 'flashcards' name conflicts)
    // We'll add cards via a separate table name:
    // NOTE: cards table
    batch.execute('''
      CREATE TABLE flash_cards (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        deck_id INTEGER NOT NULL,
        front TEXT NOT NULL,
        back TEXT NOT NULL,
        created_at INTEGER NOT NULL,
        FOREIGN KEY(deck_id) REFERENCES ${Tables.flashcards}(${Columns.id}) ON DELETE CASCADE
      )
    ''');

    batch.execute('''
      CREATE TABLE ${Tables.flashcardReviews} (
        ${Columns.id} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${Columns.reviewCardId} INTEGER NOT NULL,
        ${Columns.reviewDate} INTEGER NOT NULL,
        ${Columns.reviewQuality} INTEGER NOT NULL,
        FOREIGN KEY(${Columns.reviewCardId}) REFERENCES flash_cards(${Columns.id}) ON DELETE CASCADE
      )
    ''');

    // Expenses (single table for both expense + income — type column discriminates)
    batch.execute('''
      CREATE TABLE ${Tables.expenses} (
        ${Columns.id} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${Columns.expenseTitle} TEXT NOT NULL,
        ${Columns.expenseAmount} REAL NOT NULL,
        ${Columns.expenseCategory} TEXT NOT NULL DEFAULT 'other',
        ${Columns.expenseDate} INTEGER NOT NULL,
        ${Columns.expenseNote} TEXT,
        ${Columns.expenseType} TEXT NOT NULL DEFAULT 'expense',
        ${Columns.createdAt} INTEGER NOT NULL
      )
    ''');

    // Goals
    batch.execute('''
      CREATE TABLE ${Tables.goals} (
        ${Columns.id} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${Columns.goalTitle} TEXT NOT NULL,
        ${Columns.goalType} TEXT NOT NULL DEFAULT 'daily',
        ${Columns.goalTarget} INTEGER NOT NULL,
        ${Columns.goalProgress} INTEGER NOT NULL DEFAULT 0,
        ${Columns.createdAt} INTEGER NOT NULL
      )
    ''');

    // Routines (recurring assignments)
    batch.execute('''
      CREATE TABLE ${Tables.routines} (
        ${Columns.id} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${Columns.routineSubjectId} INTEGER,
        ${Columns.routineTitle} TEXT NOT NULL,
        ${Columns.routineDays} TEXT NOT NULL DEFAULT '1,2,3,4,5,6,7',
        ${Columns.routineTimeOfDay} TEXT,
        ${Columns.routineNotes} TEXT,
        ${Columns.routineActive} INTEGER NOT NULL DEFAULT 1,
        ${Columns.routineLastDone} INTEGER,
        ${Columns.createdAt} INTEGER NOT NULL,
        FOREIGN KEY(${Columns.routineSubjectId}) REFERENCES ${Tables.subjects}(${Columns.id}) ON DELETE SET NULL
      )
    ''');

    // Class timetable (spec #26) — one row per weekly class slot.
    batch.execute('''
      CREATE TABLE ${Tables.timetable} (
        ${Columns.id} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${Columns.classSubjectId} INTEGER NOT NULL,
        ${Columns.classDayOfWeek} INTEGER NOT NULL,
        ${Columns.classStartTime} TEXT NOT NULL,
        ${Columns.classEndTime} TEXT NOT NULL,
        ${Columns.classLocation} TEXT,
        ${Columns.createdAt} INTEGER NOT NULL,
        FOREIGN KEY(${Columns.classSubjectId}) REFERENCES ${Tables.subjects}(${Columns.id}) ON DELETE CASCADE
      )
    ''');

    // Local file resources (spec #27) — stores paths only, never copies
    // file contents. Privacy stance: see spec #36.
    batch.execute('''
      CREATE TABLE ${Tables.resources} (
        ${Columns.id} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${Columns.classSubjectId} INTEGER NOT NULL,
        ${Columns.resourceTitle} TEXT NOT NULL,
        ${Columns.resourcePath} TEXT NOT NULL,
        ${Columns.resourceMimeType} TEXT,
        ${Columns.createdAt} INTEGER NOT NULL,
        FOREIGN KEY(${Columns.classSubjectId}) REFERENCES ${Tables.subjects}(${Columns.id}) ON DELETE CASCADE
      )
    ''');

    // Indexes
    batch.execute(
        'CREATE INDEX idx_subjects_semester ON ${Tables.subjects}(${Columns.subjectSemesterId})');
    batch.execute(
        'CREATE INDEX idx_topics_subject ON ${Tables.topics}(${Columns.topicSubjectId})');
    batch.execute(
        'CREATE INDEX idx_attendance_subject_date ON ${Tables.attendance}(${Columns.attendanceSubjectId}, ${Columns.attendanceDate})');
    batch.execute(
        'CREATE INDEX idx_sessions_start ON ${Tables.studySessions}(${Columns.sessionStart})');
    batch.execute(
        'CREATE INDEX idx_assignments_due ON ${Tables.assignments}(${Columns.assignmentDue})');
    batch.execute(
        'CREATE INDEX idx_exams_date ON ${Tables.exams}(${Columns.examDate})');
    batch.execute(
        'CREATE INDEX idx_timetable_day ON ${Tables.timetable}(${Columns.classDayOfWeek})');

    await batch.commit(noResult: true);
  }

  Future<void> close() async {
    await _db?.close();
    _db = null;
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // v1 → v2: introduce profiles table + link semesters + routines.
      final batch = db.batch();
      batch.execute('''
        CREATE TABLE IF NOT EXISTS ${Tables.profiles} (
          ${Columns.id} INTEGER PRIMARY KEY AUTOINCREMENT,
          ${Columns.profileName} TEXT NOT NULL,
          ${Columns.profileLevel} TEXT NOT NULL DEFAULT 'school',
          ${Columns.profileClassLabel} TEXT,
          ${Columns.profileInstitution} TEXT,
          ${Columns.createdAt} INTEGER NOT NULL
        )
      ''');
      batch.rawInsert('''
        INSERT INTO ${Tables.profiles}
          (${Columns.profileName}, ${Columns.profileLevel}, ${Columns.profileClassLabel}, ${Columns.createdAt})
        VALUES (?, 'school', NULL, ?)
      ''', ['My studies', DateTime.now().millisecondsSinceEpoch]);
      try {
        batch.execute(
          'ALTER TABLE ${Tables.semesters} ADD COLUMN ${Columns.semesterProfile} INTEGER',
        );
      } catch (_) {/* already exists */}
      batch.execute('''
        CREATE TABLE IF NOT EXISTS ${Tables.routines} (
          ${Columns.id} INTEGER PRIMARY KEY AUTOINCREMENT,
          ${Columns.routineSubjectId} INTEGER,
          ${Columns.routineTitle} TEXT NOT NULL,
          ${Columns.routineDays} TEXT NOT NULL DEFAULT '1,2,3,4,5,6,7',
          ${Columns.routineTimeOfDay} TEXT,
          ${Columns.routineNotes} TEXT,
          ${Columns.routineActive} INTEGER NOT NULL DEFAULT 1,
          ${Columns.routineLastDone} INTEGER,
          ${Columns.createdAt} INTEGER NOT NULL,
          FOREIGN KEY(${Columns.routineSubjectId}) REFERENCES ${Tables.subjects}(${Columns.id}) ON DELETE SET NULL
        )
      ''');
      await batch.commit(noResult: true);
    }
    if (oldVersion < 3) {
      // v2 → v3: add fields for richer study tracking.
      final batch = db.batch();
      try {
        batch.execute(
          'ALTER TABLE ${Tables.profiles} ADD COLUMN ${Columns.profileDepartment} TEXT',
        );
        batch.execute(
          'ALTER TABLE ${Tables.profiles} ADD COLUMN ${Columns.profileStudentId} TEXT',
        );
        batch.execute(
          'ALTER TABLE ${Tables.profiles} ADD COLUMN ${Columns.profileActive} INTEGER NOT NULL DEFAULT 0',
        );
      } catch (_) {}
      try {
        batch.execute(
          'ALTER TABLE ${Tables.topics} ADD COLUMN ${Columns.topicParentId} INTEGER',
        );
        batch.execute(
          'ALTER TABLE ${Tables.topics} ADD COLUMN ${Columns.topicStatus} TEXT NOT NULL DEFAULT \'notStarted\'',
        );
      } catch (_) {}
      try {
        batch.execute(
          'ALTER TABLE ${Tables.syllabusItems} ADD COLUMN ${Columns.syllabusOrder} INTEGER NOT NULL DEFAULT 0',
        );
        batch.execute(
          'ALTER TABLE ${Tables.syllabusItems} ADD COLUMN ${Columns.syllabusCompletedAt} INTEGER',
        );
      } catch (_) {}
      try {
        batch.execute(
          'ALTER TABLE ${Tables.assignments} ADD COLUMN ${Columns.assignmentTopicId} INTEGER',
        );
        batch.execute(
          'ALTER TABLE ${Tables.assignments} ADD COLUMN ${Columns.assignmentType} TEXT NOT NULL DEFAULT \'assignment\'',
        );
        batch.execute(
          'ALTER TABLE ${Tables.assignments} ADD COLUMN ${Columns.assignmentEstimatedMinutes} INTEGER',
        );
        batch.execute(
          'ALTER TABLE ${Tables.assignments} ADD COLUMN ${Columns.assignmentNotes} TEXT',
        );
      } catch (_) {}
      try {
        batch.execute(
          'ALTER TABLE ${Tables.exams} ADD COLUMN ${Columns.examTime} TEXT',
        );
        batch.execute(
          'ALTER TABLE ${Tables.exams} ADD COLUMN ${Columns.examLocation} TEXT',
        );
      } catch (_) {}
      try {
        batch.execute(
          'ALTER TABLE ${Tables.notes} ADD COLUMN ${Columns.notePinned} INTEGER NOT NULL DEFAULT 0',
        );
      } catch (_) {}
      await batch.commit(noResult: true);
    }
    if (oldVersion < 4) {
      // v3 → v4: add assignment_subtasks (spec 06).
      final batch = db.batch();
      batch.execute('''
        CREATE TABLE IF NOT EXISTS ${Tables.assignmentSubtasks} (
          ${Columns.id} INTEGER PRIMARY KEY AUTOINCREMENT,
          ${Columns.subtaskAssignmentId} INTEGER NOT NULL,
          ${Columns.subtaskTitle} TEXT NOT NULL,
          ${Columns.subtaskIsDone} INTEGER NOT NULL DEFAULT 0,
          ${Columns.subtaskOrder} INTEGER NOT NULL DEFAULT 0,
          FOREIGN KEY(${Columns.subtaskAssignmentId}) REFERENCES ${Tables.assignments}(${Columns.id}) ON DELETE CASCADE
        )
      ''');
      await batch.commit(noResult: true);
    }
    if (oldVersion < 5) {
      // v4 → v5: add class timetable (spec #26).
      final batch = db.batch();
      batch.execute('''
        CREATE TABLE IF NOT EXISTS ${Tables.timetable} (
          ${Columns.id} INTEGER PRIMARY KEY AUTOINCREMENT,
          ${Columns.classSubjectId} INTEGER NOT NULL,
          ${Columns.classDayOfWeek} INTEGER NOT NULL,
          ${Columns.classStartTime} TEXT NOT NULL,
          ${Columns.classEndTime} TEXT NOT NULL,
          ${Columns.classLocation} TEXT,
          ${Columns.createdAt} INTEGER NOT NULL,
          FOREIGN KEY(${Columns.classSubjectId}) REFERENCES ${Tables.subjects}(${Columns.id}) ON DELETE CASCADE
        )
      ''');
      batch.execute(
          'CREATE INDEX IF NOT EXISTS idx_timetable_day ON ${Tables.timetable}(${Columns.classDayOfWeek})');
      await batch.commit(noResult: true);
    }
    if (oldVersion < 6) {
      // v5 → v6: add local resources (spec #27).
      final batch = db.batch();
      batch.execute('''
        CREATE TABLE IF NOT EXISTS ${Tables.resources} (
          ${Columns.id} INTEGER PRIMARY KEY AUTOINCREMENT,
          ${Columns.classSubjectId} INTEGER NOT NULL,
          ${Columns.resourceTitle} TEXT NOT NULL,
          ${Columns.resourcePath} TEXT NOT NULL,
          ${Columns.resourceMimeType} TEXT,
          ${Columns.createdAt} INTEGER NOT NULL,
          FOREIGN KEY(${Columns.classSubjectId}) REFERENCES ${Tables.subjects}(${Columns.id}) ON DELETE CASCADE
        )
      ''');
      await batch.commit(noResult: true);
    }
    if (oldVersion < 7) {
      // v6 → v7: add `type` to expenses so the same table tracks both
      // expenses and income (allowance / part-time / etc). Defaults to
      // 'expense' so all existing rows remain expenses.
      try {
        await db.execute(
          'ALTER TABLE ${Tables.expenses} ADD COLUMN ${Columns.expenseType} TEXT NOT NULL DEFAULT \'expense\'',
        );
      } catch (_) {/* already migrated */}
    }
  }
}

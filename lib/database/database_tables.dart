class Tables {
  Tables._();

  static const String semesters = 'semesters';
  static const String profiles = 'profiles';
  static const String subjects = 'subjects';
  static const String topics = 'topics';
  static const String syllabusItems = 'syllabus_items';
  static const String routines = 'routines';

  static const String assignments = 'assignments';
  static const String assignmentSubtasks = 'assignment_subtasks';
  static const String exams = 'exams';
  static const String attendance = 'attendance';

  static const String studySessions = 'study_sessions';
  static const String revisionItems = 'revision_items';

  static const String notes = 'notes';
  static const String flashcards = 'flashcards';
  static const String flashcardReviews = 'flashcard_reviews';

  static const String expenses = 'expenses';
  static const String goals = 'goals';

  // Class timetable (spec #26)
  static const String timetable = 'class_slots';

  // Local resources (spec #27)
  static const String resources = 'local_resources';
}

class Columns {
  Columns._();

  // Common
  static const String id = 'id';
  static const String createdAt = 'created_at';
  static const String updatedAt = 'updated_at';

  // Semesters
  static const String semesterName = 'name';
  static const String semesterStart = 'start_date';
  static const String semesterEnd = 'end_date';
  static const String semesterActive = 'is_active';
  static const String semesterProfile = 'profile_id';
  static const String profileName = 'name';
  static const String profileLevel = 'level';
  static const String profileClassLabel = 'class_label';
  static const String profileInstitution = 'institution';
  static const String profileDepartment = 'department';
  static const String profileStudentId = 'student_id';
  static const String profileActive = 'is_active';

  // Subjects
  static const String subjectName = 'name';
  static const String subjectCode = 'code';
  static const String subjectCredit = 'credit';
  static const String subjectTeacher = 'teacher';
  static const String subjectColor = 'color';
  static const String subjectSemesterId = 'semester_id';
  static const String subjectTarget = 'target_attendance';

  // Topics
  static const String topicName = 'name';
  static const String topicSubjectId = 'subject_id';
  static const String topicCompleted = 'is_completed';
  static const String topicConfidence = 'confidence'; // 1..5
  static const String topicOrder = 'sort_order';
  static const String topicParentId = 'parent_id';
  static const String topicStatus = 'status'; // notStarted/learning/weak/mastered

  // Syllabus
  static const String syllabusSubjectId = 'subject_id';
  static const String syllabusTitle = 'title';
  static const String syllabusDescription = 'description';
  static const String syllabusDone = 'is_done';
  static const String syllabusOrder = 'order_index';
  static const String syllabusCompletedAt = 'completed_at';

  // Assignments
  static const String assignmentSubjectId = 'subject_id';
  static const String assignmentTopicId = 'topic_id';
  static const String assignmentTitle = 'title';
  static const String assignmentDescription = 'description';
  static const String assignmentDue = 'due_date';
  static const String assignmentPriority = 'priority'; // low/med/high
  static const String assignmentStatus = 'status'; // pending/done
  static const String assignmentCompletedAt = 'completed_at';
  static const String assignmentType =
      'type'; // assignment/homework/project/presentation/labWork/report
  static const String assignmentEstimatedMinutes = 'estimated_minutes';
  static const String assignmentNotes = 'notes';

  // Assignment subtasks
  static const String subtaskAssignmentId = 'assignment_id';
  static const String subtaskTitle = 'title';
  static const String subtaskIsDone = 'is_done';
  static const String subtaskOrder = 'order_index';

  // Routines (recurring assignments)
  static const String routineSubjectId = 'subject_id';
  static const String routineTitle = 'title';
  static const String routineDays = 'days_of_week'; // CSV "1,3,5" (Mon=1..Sun=7)
  static const String routineTimeOfDay = 'time_of_day';
  static const String routineNotes = 'notes';
  static const String routineActive = 'is_active';
  static const String routineLastDone = 'last_done_date';

  // Exams
  static const String examSubjectId = 'subject_id';
  static const String examTitle = 'title';
  static const String examDate = 'exam_date';
  static const String examStartTime = 'start_time';
  static const String examTime = 'time'; // "09:00 – 11:00" string
  static const String examLocation = 'location';
  static const String examSyllabus = 'syllabus';
  static const String examNotes = 'notes';
  static const String examType = 'type'; // midterm/final/quiz
  static const String examTotalMarks = 'total_marks';
  static const String examObtained = 'obtained_marks';

  // Attendance
  static const String attendanceSubjectId = 'subject_id';
  static const String attendanceDate = 'date';
  static const String attendanceStatus = 'status'; // present/absent/late
  static const String attendanceNote = 'note';

  // Study sessions
  static const String sessionSubjectId = 'subject_id';
  static const String sessionTopicId = 'topic_id';
  static const String sessionStart = 'start_time';
  static const String sessionEnd = 'end_time';
  static const String sessionDurationSec = 'duration_seconds';
  static const String sessionNotes = 'notes';
  static const String sessionFocusRating = 'focus_rating'; // 1..5
  static const String sessionMode = 'mode'; // focus/pomodoro/free

  // Revision
  static const String revisionSubjectId = 'subject_id';
  static const String revisionTopicId = 'topic_id';
  static const String revisionDate = 'scheduled_date';
  static const String revisionStatus = 'status'; // pending/done/missed
  static const String revisionInterval = 'interval_days';
  static const String revisionRating = 'rating'; // 1=weak / 3=okay / 5=strong

  // Notes
  static const String noteSubjectId = 'subject_id';
  static const String noteTopicId = 'topic_id';
  static const String noteTitle = 'title';
  static const String noteBody = 'body';
  static const String notePinned = 'is_pinned';

  // Flashcards
  static const String deckSubjectId = 'subject_id';
  static const String deckName = 'name';
  static const String cardDeckId = 'deck_id';
  static const String cardFront = 'front';
  static const String cardBack = 'back';
  static const String reviewCardId = 'card_id';
  static const String reviewDate = 'reviewed_at';
  static const String reviewQuality = 'quality'; // 0..5

  // Expenses
  static const String expenseTitle = 'title';
  static const String expenseAmount = 'amount';
  static const String expenseCategory = 'category';
  static const String expenseDate = 'date';
  static const String expenseNote = 'note';
  static const String expenseType = 'type'; // 'expense' | 'income'

  // Goals
  static const String goalTitle = 'title';
  static const String goalType = 'type'; // daily/weekly/total
  static const String goalTarget = 'target';
  static const String goalProgress = 'progress';

  // Class timetable (spec #26)
  static const String classSubjectId = 'subject_id';
  static const String classDayOfWeek = 'day_of_week'; // 1=Mon..7=Sun
  static const String classStartTime = 'start_time'; // "HH:mm"
  static const String classEndTime = 'end_time'; // "HH:mm"
  static const String classLocation = 'location';

  // Local resources (spec #27)
  static const String resourceTitle = 'title';
  static const String resourcePath = 'path';
  static const String resourceMimeType = 'mime_type';
}

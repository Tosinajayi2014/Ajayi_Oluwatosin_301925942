-- Portfolio 2: Query Optimisation
-- Student: Ajayi Oluwatosin (301925942)
-- Database: unia_buja_cs
USE unia_buja_cs;

-- =====================================================
-- PART A: BEFORE OPTIMISATION - EXPLAIN (No Indexes)
-- Run these FIRST, note type=ALL, key=NULL, rows=high
-- =====================================================

-- Q1: Find student by matric_number
EXPLAIN SELECT student_id, matric_number, first_name, last_name
FROM Student WHERE matric_number = 'U21CS1001';

-- Q2: All results for one student (Transcript query)
EXPLAIN SELECT c.course_code, r.total_score, r.grade
FROM Student s
JOIN Enrollment e ON s.student_id = e.student_id
JOIN Course c ON e.course_id = c.course_id
JOIN Result r ON e.enrollment_id = r.enrollment_id
WHERE s.matric_number = 'U21CS1001';

-- Q3: Carry-over list
EXPLAIN SELECT s.matric_number, c.course_code, r.grade
FROM Student s
JOIN Enrollment e ON s.student_id = e.student_id
JOIN Course c ON e.course_id = c.course_id
JOIN Result r ON e.enrollment_id = r.enrollment_id
WHERE r.grade = 'F';

-- Q4: Courses for a lecturer in a semester
EXPLAIN SELECT c.course_code, c.title
FROM Course_Assignment ca
JOIN Course c ON ca.course_id = c.course_id
WHERE ca.lecturer_id = 1 AND ca.semester_id = 1;

-- =====================================================
-- PART B: CREATE INDEXES
-- =====================================================
CREATE INDEX idx_student_matric ON Student(matric_number);
CREATE INDEX idx_enrollment_student ON Enrollment(student_id);
CREATE INDEX idx_enrollment_course ON Enrollment(course_id);
CREATE INDEX idx_result_grade ON Result(grade);
CREATE INDEX idx_result_enrollment ON Result(enrollment_id);
CREATE INDEX idx_assignment_lecturer ON Course_Assignment(lecturer_id, semester_id);

-- Check indexes created
SHOW INDEX FROM Student;
SHOW INDEX FROM Enrollment;
SHOW INDEX FROM Result;

-- =====================================================
-- PART C: AFTER OPTIMISATION - EXPLAIN AGAIN
-- Now type should be const/ref, key should show index name,
-- rows should be much lower
-- =====================================================
EXPLAIN SELECT student_id, matric_number, first_name, last_name
FROM Student WHERE matric_number = 'U21CS1001';

EXPLAIN SELECT c.course_code, r.total_score, r.grade
FROM Student s
JOIN Enrollment e ON s.student_id = e.student_id
JOIN Course c ON e.course_id = c.course_id
JOIN Result r ON e.enrollment_id = r.enrollment_id
WHERE s.matric_number = 'U21CS1001';

EXPLAIN SELECT s.matric_number, c.course_code, r.grade
FROM Student s
JOIN Enrollment e ON s.student_id = e.student_id
JOIN Course c ON e.course_id = c.course_id
JOIN Result r ON e.enrollment_id = r.enrollment_id
WHERE r.grade = 'F';

-- =====================================================
-- PART D: REWRITTEN QUERIES (SARGable - Can Use Index)
-- =====================================================

-- BAD: Function on column prevents index use
-- SELECT * FROM Student WHERE UPPER(matric_number) = 'U21CS1001';
-- GOOD:
SELECT student_id, matric_number FROM Student
WHERE matric_number = 'U21CS1001';

-- BAD: YEAR() on column prevents index use
-- SELECT * FROM Result WHERE YEAR(entered_at) = 2026;
-- GOOD: Range search uses index
SELECT result_id, enrollment_id, total_score FROM Result
WHERE entered_at BETWEEN '2026-01-01' AND '2026-12-31';

-- BAD: Leading wildcard kills index
-- SELECT * FROM Course WHERE title LIKE '%Database%';
-- GOOD: Trailing wildcard can use index
SELECT course_id, course_code, title FROM Course
WHERE course_code LIKE 'CSC%';

-- BAD: SELECT * forces full row read
-- GOOD: Covering index - only indexed columns
SELECT matric_number, first_name, last_name FROM Student
WHERE matric_number = 'U21CS1001';

-- GOOD: Top 3 with LIMIT + ORDER BY using index
SELECT s.matric_number,
ROUND(SUM(r.grade_point * c.credit_unit) / SUM(c.credit_unit), 2) AS CGPA
FROM Student s
JOIN Enrollment e ON s.student_id = e.student_id
JOIN Course c ON e.course_id = c.course_id
JOIN Result r ON e.enrollment_id = r.enrollment_id
GROUP BY s.student_id, s.matric_number
ORDER BY CGPA DESC LIMIT 3;

-- =====================================================
-- PART E: ANALYSE TABLE (Update statistics)
-- =====================================================
ANALYZE TABLE Student, Enrollment, Result, Course;
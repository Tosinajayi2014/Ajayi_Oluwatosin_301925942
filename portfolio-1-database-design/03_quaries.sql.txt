-- Portfolio 1: Queries - GPA, Transcript, Carry-over
-- Student: Ajayi Oluwatosin (301925942)
USE unia_buja_cs;

-- Q1: Transcript for one student (Tosin Ajayi U21CS1001)
SELECT
  s.matric_number,
  CONCAT(s.first_name, ' ', s.last_name) AS student_name,
  c.course_code,
  c.title,
  c.credit_unit,
  r.ca_score,
  r.exam_score,
  r.total_score,
  r.grade,
  r.grade_point
FROM Student s
JOIN Enrollment e ON s.student_id = e.student_id
JOIN Course c ON e.course_id = c.course_id
JOIN Result r ON e.enrollment_id = r.enrollment_id
WHERE s.matric_number = 'U21CS1001'
ORDER BY c.course_code;

-- Q2: GPA for a student in a semester
-- GPA = SUM(grade_point * credit_unit) / SUM(credit_unit)
SELECT
  s.matric_number,
  ROUND(SUM(r.grade_point * c.credit_unit) / SUM(c.credit_unit), 2) AS GPA,
  SUM(c.credit_unit) AS total_units
FROM Student s
JOIN Enrollment e ON s.student_id = e.student_id
JOIN Course c ON e.course_id = c.course_id
JOIN Result r ON e.enrollment_id = r.enrollment_id
WHERE s.matric_number = 'U21CS1001' AND e.semester_id = 1
GROUP BY s.matric_number;

-- Q3: CGPA for all students
SELECT
  s.matric_number,
  CONCAT(s.first_name, ' ', s.last_name) AS student_name,
  ROUND(SUM(r.grade_point * c.credit_unit) / SUM(c.credit_unit), 2) AS CGPA
FROM Student s
JOIN Enrollment e ON s.student_id = e.student_id
JOIN Course c ON e.course_id = c.course_id
JOIN Result r ON e.enrollment_id = r.enrollment_id
GROUP BY s.student_id, s.matric_number, s.first_name, s.last_name
ORDER BY CGPA DESC;

-- Q4: Carry-over list (grade = F)
SELECT
  s.matric_number,
  CONCAT(s.first_name, ' ', s.last_name) AS student_name,
  c.course_code,
  c.title,
  r.total_score,
  r.grade
FROM Student s
JOIN Enrollment e ON s.student_id = e.student_id
JOIN Course c ON e.course_id = c.course_id
JOIN Result r ON e.enrollment_id = r.enrollment_id
WHERE r.grade = 'F'
ORDER BY s.matric_number;

-- Q5: Class average per course
SELECT
  c.course_code,
  c.title,
  ROUND(AVG(r.total_score), 2) AS class_average,
  COUNT(*) AS num_students
FROM Course c
JOIN Enrollment e ON c.course_id = e.course_id
JOIN Result r ON e.enrollment_id = r.enrollment_id
GROUP BY c.course_id, c.course_code, c.title
ORDER BY class_average DESC;

-- Q6: Students who have not enrolled in CSC 204
SELECT s.matric_number, CONCAT(s.first_name, ' ', s.last_name) AS student_name
FROM Student s
WHERE NOT EXISTS (
  SELECT 1 FROM Enrollment e
  JOIN Course c ON e.course_id = c.course_id
  WHERE e.student_id = s.student_id AND c.course_code = 'CSC 204'
);

-- Q7: Top 3 students by CGPA using CTE
WITH StudentGPA AS (
  SELECT s.student_id, s.matric_number,
  SUM(r.grade_point * c.credit_unit) / SUM(c.credit_unit) AS cgpa
  FROM Student s
  JOIN Enrollment e ON s.student_id = e.student_id
  JOIN Course c ON e.course_id = c.course_id
  JOIN Result r ON e.enrollment_id = r.enrollment_id
  GROUP BY s.student_id, s.matric_number
)
SELECT matric_number, ROUND(cgpa, 2) AS CGPA
FROM StudentGPA
ORDER BY cgpa DESC
LIMIT 3;
-- Portfolio 4: Security & Roles
-- Student: Ajayi Oluwatosin (301925942)
-- Database: unia_buja_cs
USE unia_buja_cs;

-- =====================================================
-- PART A: CREATE ROLES (MySQL 8+)
-- Role = Group of permissions, easier than per-user GRANT
-- =====================================================
CREATE ROLE IF NOT EXISTS student_role;
CREATE ROLE IF NOT EXISTS lecturer_role;
CREATE ROLE IF NOT EXISTS hod_role;
CREATE ROLE IF NOT EXISTS admin_role;

-- =====================================================
-- PART B: CREATE VIEWS - Hide Tables, Show Only Needed Data
-- Students NEVER get direct access to Result table.
-- They get a VIEW.
-- =====================================================

-- View 1: For Students - Shows results but hides internal IDs
CREATE OR REPLACE VIEW Student_Result_View AS
SELECT
  s.matric_number,
  CONCAT(s.first_name, ' ', s.last_name) AS student_name,
  c.course_code,
  c.title AS course_title,
  e.semester_id,
  r.ca_score,
  r.exam_score,
  r.total_score,
  r.grade
FROM Student s
JOIN Enrollment e ON s.student_id = e.student_id
JOIN Course c ON e.course_id = c.course_id
JOIN Result r ON e.enrollment_id = r.enrollment_id;

-- View 2: For Lecturers - Only courses they are assigned to
CREATE OR REPLACE VIEW Lecturer_Course_View AS
SELECT
  ca.lecturer_id,
  l.first_name AS lecturer_first_name,
  c.course_code,
  c.title,
  ca.semester_id
FROM Course_Assignment ca
JOIN Lecturer l ON ca.lecturer_id = l.lecturer_id
JOIN Course c ON ca.course_id = c.course_id;

-- View 3: For HOD - CGPA Report, no raw scores needed
CREATE OR REPLACE VIEW HOD_CGPA_View AS
SELECT
  s.matric_number,
  CONCAT(s.first_name, ' ', s.last_name) AS student_name,
  d.name AS department,
  ROUND(SUM(r.grade_point * c.credit_unit) / SUM(c.credit_unit), 2) AS CGPA
FROM Student s
JOIN Department d ON s.department_id = d.department_id
JOIN Enrollment e ON s.student_id = e.student_id
JOIN Course c ON e.course_id = c.course_id
JOIN Result r ON e.enrollment_id = r.enrollment_id
GROUP BY s.student_id, s.matric_number, student_name, d.name;

-- Test Views
SELECT * FROM Student_Result_View WHERE matric_number = 'U21CS1001';
SELECT * FROM Lecturer_Course_View WHERE lecturer_id = 1;
SELECT * FROM HOD_CGPA_View ORDER BY CGPA DESC LIMIT 5;

-- =====================================================
-- PART C: GRANT PERMISSIONS - Least Privilege
-- =====================================================

-- STUDENT: Can ONLY SELECT from the View. NOTHING else.
GRANT SELECT ON unia_buja_cs.Student_Result_View TO student_role;
-- Student CANNOT: INSERT, UPDATE, DELETE, or SELECT from base tables
-- REVOKE test: REVOKE INSERT ON unia_buja_cs.* FROM student_role;

-- LECTURER: Can SELECT views + SELECT courses, INSERT/UPDATE Result
GRANT SELECT ON unia_buja_cs.Lecturer_Course_View TO lecturer_role;
GRANT SELECT ON unia_buja_cs.Course TO lecturer_role;
GRANT SELECT, INSERT, UPDATE ON unia_buja_cs.Result TO lecturer_role;
GRANT SELECT ON unia_buja_cs.Enrollment TO lecturer_role;
-- Lecturer CANNOT DELETE results, CANNOT DROP tables
-- Lecturer CANNOT see Audit_Log

-- HOD: Can SELECT all reports + Audit Log, can approve results
GRANT SELECT ON unia_buja_cs.HOD_CGPA_View TO hod_role;
GRANT SELECT ON unia_buja_cs.Student_Result_View TO hod_role;
GRANT SELECT ON unia_buja_cs.Audit_Log TO hod_role;
GRANT SELECT, UPDATE ON unia_buja_cs.Result TO hod_role;
-- HOD CANNOT DELETE students, CANNOT DROP tables

-- ADMIN: Full control (only IT Admin)
GRANT ALL PRIVILEGES ON unia_buja_cs.* TO admin_role WITH GRANT OPTION;

-- Show grants
SHOW GRANTS FOR student_role;
SHOW GRANTS FOR lecturer_role;

-- =====================================================
-- PART D: CREATE USERS & ASSIGN ROLES
-- =====================================================
CREATE USER IF NOT EXISTS 'student_001'@'localhost' IDENTIFIED BY 'StudentPass123!';
CREATE USER IF NOT EXISTS 'lecturer_musa'@'localhost' IDENTIFIED BY 'LecturerPass123!';
CREATE USER IF NOT EXISTS 'hod_cs'@'localhost' IDENTIFIED BY 'HodPass123!';

GRANT student_role TO 'student_001'@'localhost';
GRANT lecturer_role TO 'lecturer_musa'@'localhost';
GRANT hod_role TO 'hod_cs'@'localhost';

-- Activate role by default when user logs in
SET DEFAULT ROLE student_role TO 'student_001'@'localhost';
SET DEFAULT ROLE lecturer_role TO 'lecturer_musa'@'localhost';
SET DEFAULT ROLE hod_role TO 'hod_cs'@'localhost';

-- To test: Login as student_001, try:
-- SELECT * FROM Result; -- Should FAIL: Access denied
-- SELECT * FROM Student_Result_View; -- Should SUCCEED

-- =====================================================
-- PART E: SECURE STORED PROCEDURE - Lecturer Can Only Edit Own Course
-- This is the REAL protection. Even if lecturer tries to hack,
-- procedure checks Course_Assignment first.
-- =====================================================
DELIMITER //

CREATE PROCEDURE IF NOT EXISTS Enter_Result_Secure(
  IN p_lecturer_id INT,
  IN p_enrollment_id INT,
  IN p_ca_score DECIMAL(5,2),
  IN p_exam_score DECIMAL(5,2)
)
BEGIN
  DECLARE v_course_id INT;
  DECLARE v_is_assigned INT DEFAULT 0;
  DECLARE v_total DECIMAL(5,2);

  -- Find which course this enrollment is for
  SELECT course_id INTO v_course_id
  FROM Enrollment WHERE enrollment_id = p_enrollment_id;

  -- Check: Is this lecturer assigned to this course?
  SELECT COUNT(*) INTO v_is_assigned
  FROM Course_Assignment
  WHERE lecturer_id = p_lecturer_id AND course_id = v_course_id;

  IF v_is_assigned = 0 THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'ACCESS DENIED: You are not assigned to this course';
  ELSE
    SET v_total = p_ca_score + p_exam_score;
    INSERT INTO Result (enrollment_id, ca_score, exam_score, total_score, grade)
    VALUES (p_enrollment_id, p_ca_score, p_exam_score, v_total,
      CASE WHEN v_total >= 70 THEN 'A'
           WHEN v_total >= 60 THEN 'B'
           WHEN v_total >= 50 THEN 'C'
           WHEN v_total >= 45 THEN 'D'
           WHEN v_total >= 40 THEN 'E' ELSE 'F' END)
    ON DUPLICATE KEY UPDATE
      ca_score = p_ca_score, exam_score = p_exam_score, total_score = v_total;

    INSERT INTO Audit_Log (action, enrollment_id, done_by)
    VALUES ('Result Entered via Secure Procedure', p_enrollment_id, CONCAT('Lecturer ', p_lecturer_id));
  END IF;
END //

DELIMITER ;

-- Test Secure Procedure:
-- This should SUCCEED if lecturer 1 teaches enrollment 1's course
-- CALL Enter_Result_Secure(1, 1, 32, 55);
-- This should FAIL if lecturer 99 does NOT teach it
-- CALL Enter_Result_Secure(99, 1, 32, 55); -- ERROR: ACCESS DENIED

-- =====================================================
-- PART F: SQL INJECTION - BAD vs GOOD (For Report)
-- =====================================================
-- BAD - App code builds SQL by concatenation (NEVER DO THIS):
-- query = "SELECT * FROM Student WHERE matric_number = '" + user_input + "'"
-- Attacker input: ' OR '1'='1
-- Becomes: SELECT * FROM Student WHERE matric_number = '' OR '1'='1'
-- Result: Returns ALL students!

-- GOOD - Prepared Statement (Parameterised):
-- In Python: cursor.execute("SELECT * FROM Student WHERE matric_number = %s", (user_input,))
-- In Java: PreparedStatement ps = conn.prepareStatement("SELECT * FROM Student WHERE matric_number = ?");
-- The input is treated as DATA, never as SQL code. Injection impossible.

-- GOOD - Use the Stored Procedure above, it uses parameters only.

-- =====================================================
-- PART G: REVOKE EXAMPLE & CLEANUP
-- =====================================================
-- If a lecturer leaves, remove access immediately:
-- REVOKE lecturer_role FROM 'lecturer_musa'@'localhost';
-- DROP USER 'lecturer_musa'@'localhost';

-- If student graduates, remove access:
-- REVOKE student_role FROM 'student_001'@'localhost';

FLUSH PRIVILEGES;

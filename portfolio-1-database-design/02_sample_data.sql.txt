-- Portfolio 1: Sample Data
-- Student: Ajayi Oluwatosin (301925942)

USE unia_buja_cs;

INSERT INTO Department (dept_name, faculty, hod_name) VALUES
('Computer Science', 'Science', 'Dr. A. Bello');

INSERT INTO Semester (session, semester_name, status) VALUES
('2025/2026', 'First', 'Active');

INSERT INTO Lecturer (staff_number, first_name, last_name, email, department_id) VALUES
('UAB/CS/001', 'Mary', 'Okoro', 'm.okoro@uniabuja.edu.ng', 1),
('UAB/CS/002', 'James', 'Adeyemi', 'j.adeyemi@uniabuja.edu.ng', 1);

INSERT INTO Student (matric_number, first_name, last_name, email, level, department_id, entry_year) VALUES
('U21CS1001', 'Tosin', 'Ajayi', 'tosin.ajayi@uniabuja.edu.ng', 200, 1, 2021),
('U21CS1002', 'Ada', 'Okafor', 'ada.okafor@uniabuja.edu.ng', 200, 1, 2021),
('U21CS1003', 'Musa', 'Ibrahim', 'musa.ibrahim@uniabuja.edu.ng', 200, 1, 2021),
('U21CS1004', 'Funke', 'Alabi', 'funke.alabi@uniabuja.edu.ng', 200, 1, 2021),
('U21CS1005', 'Chidi', 'Nwosu', 'chidi.nwosu@uniabuja.edu.ng', 200, 1, 2021);

INSERT INTO Course (course_code, title, credit_unit, level, department_id) VALUES
('CSC 201', 'Data Structures', 3, 200, 1),
('CSC 202', 'Discrete Mathematics', 3, 200, 1),
('CSC 203', 'Computer Architecture', 2, 200, 1),
('CSC 204', 'Database Systems', 3, 200, 1);

INSERT INTO Course_Assignment (course_id, lecturer_id, semester_id) VALUES
(1, 1, 1),
(2, 2, 1),
(3, 1, 1),
(4, 2, 1);

INSERT INTO Enrollment (student_id, course_id, semester_id) VALUES
(1,1,1),(1,2,1),(1,3,1),(1,4,1),
(2,1,1),(2,2,1),(2,4,1),
(3,1,1),(3,2,1),(3,3,1),
(4,1,1),(4,4,1),
(5,1,1),(5,2,1),(5,3,1),(5,4,1);

-- Results for Tosin Ajayi (enrollment 1-4) and others
INSERT INTO Result (enrollment_id, ca_score, exam_score, grade, grade_point, entered_by) VALUES
(1, 32, 45, 'A', 5, 1),
(2, 28, 38, 'B', 4, 2),
(3, 25, 30, 'C', 3, 1),
(4, 35, 48, 'A', 5, 2),
(5, 30, 42, 'A', 5, 1),
(6, 20, 18, 'F', 0, 2);
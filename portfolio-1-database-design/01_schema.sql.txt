-- Portfolio 1: UniAbuja CS Student Result Portal
-- Student: Ajayi Oluwatosin (301925942)
-- Course: MIT 8103 Advanced Database Systems

CREATE DATABASE IF NOT EXISTS unia_buja_cs;
USE unia_buja_cs;

-- Department
CREATE TABLE Department (
  department_id INT AUTO_INCREMENT PRIMARY KEY,
  dept_name VARCHAR(100) NOT NULL UNIQUE,
  faculty VARCHAR(100) NOT NULL,
  hod_name VARCHAR(100)
);

-- Lecturer
CREATE TABLE Lecturer (
  lecturer_id INT AUTO_INCREMENT PRIMARY KEY,
  staff_number VARCHAR(20) NOT NULL UNIQUE,
  first_name VARCHAR(50) NOT NULL,
  last_name VARCHAR(50) NOT NULL,
  email VARCHAR(100) NOT NULL UNIQUE,
  department_id INT NOT NULL,
  FOREIGN KEY (department_id) REFERENCES Department(department_id)
    ON UPDATE CASCADE ON DELETE RESTRICT
);

-- Student
CREATE TABLE Student (
  student_id INT AUTO_INCREMENT PRIMARY KEY,
  matric_number VARCHAR(20) NOT NULL UNIQUE,
  first_name VARCHAR(50) NOT NULL,
  last_name VARCHAR(50) NOT NULL,
  email VARCHAR(100) NOT NULL UNIQUE,
  level INT NOT NULL CHECK (level IN (100,200,300,400)),
  department_id INT NOT NULL,
  entry_year INT NOT NULL,
  FOREIGN KEY (department_id) REFERENCES Department(department_id)
    ON UPDATE CASCADE ON DELETE RESTRICT
);

-- Semester
CREATE TABLE Semester (
  semester_id INT AUTO_INCREMENT PRIMARY KEY,
  session VARCHAR(20) NOT NULL,
  semester_name VARCHAR(20) NOT NULL,
  status VARCHAR(20) DEFAULT 'Active',
  UNIQUE (session, semester_name)
);

-- Course
CREATE TABLE Course (
  course_id INT AUTO_INCREMENT PRIMARY KEY,
  course_code VARCHAR(20) NOT NULL UNIQUE,
  title VARCHAR(150) NOT NULL,
  credit_unit INT NOT NULL CHECK (credit_unit BETWEEN 1 AND 6),
  level INT NOT NULL CHECK (level IN (100,200,300,400)),
  department_id INT NOT NULL,
  FOREIGN KEY (department_id) REFERENCES Department(department_id)
    ON UPDATE CASCADE ON DELETE RESTRICT
);

-- Course Assignment - resolves Lecturer M:N Course per Semester
CREATE TABLE Course_Assignment (
  assignment_id INT AUTO_INCREMENT PRIMARY KEY,
  course_id INT NOT NULL,
  lecturer_id INT NOT NULL,
  semester_id INT NOT NULL,
  UNIQUE (course_id, semester_id),
  FOREIGN KEY (course_id) REFERENCES Course(course_id) ON UPDATE CASCADE ON DELETE RESTRICT,
  FOREIGN KEY (lecturer_id) REFERENCES Lecturer(lecturer_id) ON UPDATE CASCADE ON DELETE RESTRICT,
  FOREIGN KEY (semester_id) REFERENCES Semester(semester_id) ON UPDATE CASCADE ON DELETE RESTRICT
);

-- Enrollment - resolves Student M:N Course per Semester
CREATE TABLE Enrollment (
  enrollment_id INT AUTO_INCREMENT PRIMARY KEY,
  student_id INT NOT NULL,
  course_id INT NOT NULL,
  semester_id INT NOT NULL,
  enrollment_date DATE DEFAULT (CURRENT_DATE),
  UNIQUE (student_id, course_id, semester_id),
  FOREIGN KEY (student_id) REFERENCES Student(student_id) ON UPDATE CASCADE ON DELETE RESTRICT,
  FOREIGN KEY (course_id) REFERENCES Course(course_id) ON UPDATE CASCADE ON DELETE RESTRICT,
  FOREIGN KEY (semester_id) REFERENCES Semester(semester_id) ON UPDATE CASCADE ON DELETE RESTRICT
);

-- Result - 1 to 1 with Enrollment
CREATE TABLE Result (
  result_id INT AUTO_INCREMENT PRIMARY KEY,
  enrollment_id INT NOT NULL UNIQUE,
  ca_score DECIMAL(5,2) NOT NULL CHECK (ca_score BETWEEN 0 AND 40),
  exam_score DECIMAL(5,2) NOT NULL CHECK (exam_score BETWEEN 0 AND 60),
  total_score DECIMAL(5,2) GENERATED ALWAYS AS (ca_score + exam_score) STORED,
  grade CHAR(1),
  grade_point INT,
  entered_by INT,
  entered_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (enrollment_id) REFERENCES Enrollment(enrollment_id) ON UPDATE CASCADE ON DELETE CASCADE,
  FOREIGN KEY (entered_by) REFERENCES Lecturer(lecturer_id) ON UPDATE CASCADE ON DELETE SET NULL
);

-- Indexes for performance (Portfolio 2 preview)
CREATE INDEX idx_student_matric ON Student(matric_number);
CREATE INDEX idx_enrollment_student ON Enrollment(student_id);
CREATE INDEX idx_enrollment_course ON Enrollment(course_id);
CREATE INDEX idx_result_enrollment ON Result(enrollment_id);
# Portfolio 1: Database Design - UniAbuja CS Student Result Portal

**Student:** Ajayi Oluwatosin
**Student ID:** 301925942
**Course:** MIT 8103 Advanced Database Systems
**Case Study:** University of Abuja - Department of Computer Science

## 1. Problem Statement
The Department of Computer Science, University of Abuja, manages results manually with spreadsheets. This causes duplicate student records, wrong GPA calculation, lost CA scores, and delays in transcript generation.

This portfolio designs a relational database for a Student Result Portal that will store departments, lecturers, students, courses, enrollment and results in one consistent place.

## 2. Users and Requirements
- **Student:** View courses, register courses, view CA + Exam + Grade + GPA.
- **Lecturer:** Enter CA (0-40) and Exam (0-60) for courses assigned to them.
- **HOD / Exams Officer:** Approve results, view carry-over list, generate transcripts.
- **Admin:** Manage students, lecturers, courses, semesters.

Functional Requirements:
- FR1: Register a student in a department with a unique matric number.
- FR2: Create a course with code, title, credit unit, level and semester.
- FR3: Assign a lecturer to a course for a semester.
- FR4: Enroll a student in a course for a semester.
- FR5: Record CA and Exam scores, compute total (0-100) and grade automatically.
- FR6: Compute GPA per semester and CGPA overall.
- FR7: Identify carry-over courses where grade = F.
- FR8: Prevent duplicate enrollment for same student, course and semester.

Non-Functional Requirements:
- Data must be consistent: total = CA + Exam, no duplicate matric numbers.
- Results must be auditable: who entered score, when.
- System must handle 5,000+ students and 100+ courses.

## 3. Entities and Attributes

### Department (department_id PK)
department_id, dept_name, faculty, hod_name

### Lecturer (lecturer_id PK)
lecturer_id, staff_number UNIQUE, first_name, last_name, email UNIQUE, department_id FK

### Student (student_id PK)
student_id, matric_number UNIQUE, first_name, last_name, email UNIQUE, level, department_id FK, entry_year

### Semester (semester_id PK)
semester_id, session e.g. 2025/2026, semester_name e.g. First, status

### Course (course_id PK)
course_id, course_code UNIQUE e.g. CSC 201, title, credit_unit, level, department_id FK

### Course_Assignment (assignment_id PK)
assignment_id, course_id FK, lecturer_id FK, semester_id FK, UNIQUE(course_id, semester_id)

### Enrollment (enrollment_id PK)
enrollment_id, student_id FK, course_id FK, semester_id FK, UNIQUE(student_id, course_id, semester_id), enrollment_date

### Result (result_id PK)
result_id, enrollment_id FK UNIQUE, ca_score 0-40, exam_score 0-60, total_score 0-100, grade A-F, grade_point 0-5, entered_by FK Lecturer, entered_at

## 4. Relationships
- Department 1 - N Lecturer: One department has many lecturers.
- Department 1 - N Student: One department has many students.
- Department 1 - N Course: One department offers many courses.
- Lecturer 1 - N Course_Assignment: One lecturer teaches many course offerings.
- Course 1 - N Course_Assignment: One course is offered in many semesters.
- Semester 1 - N Course_Assignment / Enrollment: One semester has many assignments and enrollments.
- Student 1 - N Enrollment: One student enrolls in many courses.
- Course 1 - N Enrollment: One course has many enrolled students.
- Enrollment 1 - 1 Result: One enrollment has one result.

## 5. ER Diagram (Text Description)


## 6. Normalisation to 3NF
**1NF:** No repeating groups. Each column atomic. Student name split into first_name, last_name. No list of courses in student table.

**2NF:** No partial dependency. All non-key attributes depend on full PK. Enrollment uses surrogate PK enrollment_id. Result depends fully on enrollment_id.

**3NF:** No transitive dependency. dept_name stays only in Department table, not in Student table. course_title stays only in Course, not in Enrollment or Result. Grade and grade_point are derived from total_score via grading rule.

Final schema is in 3NF.

## 7. Integrity Constraints
- PRIMARY KEY on every table.
- UNIQUE: matric_number, staff_number, email, course_code.
- FOREIGN KEY with ON UPDATE CASCADE, ON DELETE RESTRICT for master data to prevent accidental deletion of results.
- CHECK: ca_score BETWEEN 0 AND 40, exam_score BETWEEN 0 AND 60, total_score BETWEEN 0 AND 100, credit_unit BETWEEN 1 AND 6, level IN (100,200,300,400).
- UNIQUE(student_id, course_id, semester_id) in Enrollment prevents duplicate registration.
- UNIQUE(enrollment_id) in Result ensures one result per enrollment.
- NOT NULL on all business-critical fields.

## 8. Grading Rule (UniAbuja CS)
Total = CA + Exam
- 70-100 = A, 5 points
- 60-69 = B, 4 points
- 50-59 = C, 3 points
- 45-49 = D, 2 points
- 40-44 = E, 1 point
- 0-39 = F, 0 points

GPA = SUM(grade_point * credit_unit) / SUM(credit_unit) for a semester.

## 9. Assumptions
- One department case study, but design supports many departments.
- One lecturer per course per semester.
- CA is 40, Exam is 60.
- Semester is defined by session + semester_name.
- Results are entered after enrollment, not before.

## 10. Files
- 01_schema.sql - CREATE TABLE statements
- 02_sample_data.sql - INSERT sample data
- 03_queries.sql - Sample GPA / transcript queries
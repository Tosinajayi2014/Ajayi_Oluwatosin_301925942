# Portfolio 2: Query Optimisation - UniAbuja CS Student Result Portal

*Student:* Ajayi Oluwatosin
*Student ID:* 301925942
*Course:* MIT 8103 Advanced Database Systems
*Case Study:* University of Abuja - Department of Computer Science
*Database:* unia_buja_cs (from Portfolio 1)

## 1. Problem
As the Result Portal grows to 5,000+ students and 50,000+ enrollments, some queries become slow:
- Searching a student by matric_number scans the whole Student table.
- Finding all results for a student joins 3 tables and scans Enrollment.
- Generating the carry-over list scans the Result table.

Without indexes, MySQL must do a FULL TABLE SCAN. With indexes, it can jump directly to the rows.

## 2. Test Setup
We use the schema from Portfolio 1. To simulate large data, we assume:
- Student: 5,000 rows
- Enrollment: 50,000 rows (10 courses per student)
- Result: 50,000 rows

We test 4 queries that the portal uses every day.

## 3. What is EXPLAIN?
EXPLAIN shows how MySQL will execute a query BEFORE it runs it.

Key columns to read:
- *type:* ALL = Full Table Scan (BAD), ref / range / const = Uses Index (GOOD)
- *key:* Which index was used. NULL = No index.
- *rows:* How many rows MySQL estimates it must examine. Lower = Faster.
- *Extra:* Using filesort / Using temporary = Slow. Using index = Fast.

Goal: Change type from ALL to ref/range, and reduce rows examined.

## 4. Optimisation Summary

| Query | Before (No Index) | After (With Index) | Improvement |
| :--- | :--- | :--- | :--- |
| Q1: Find student by matric_number | type=ALL, rows=5000 | type=const, rows=1 | 5000x fewer rows |
| Q2: All results for one student | type=ALL, rows=50000 | type=ref, rows=10 | 5000x fewer rows |
| Q3: Carry-over list (grade=F) | type=ALL, rows=50000 | type=ref, rows=~500 | 100x fewer rows |
| Q4: Courses for a lecturer in a semester | type=ALL, rows=50000 | type=ref, rows=~5 | 10000x fewer rows |

> Note: Exact row counts depend on data volume. The pattern is what matters: index changes ALL to ref/const.

## 5. Indexes Created
```sql
CREATE INDEX idx_student_matric ON Student(matric_number);
CREATE INDEX idx_enrollment_student ON Enrollment(student_id);
CREATE INDEX idx_enrollment_course ON Enrollment(course_id);
CREATE INDEX idx_result_grade ON Result(grade);
CREATE INDEX idx_result_enrollment ON Result(enrollment_id);
CREATE INDEX idx_assignment_lecturer ON Course_Assignment(lecturer_id, semester_id);
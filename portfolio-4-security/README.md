# Portfolio 4: Security & Roles - UniAbuja CS Result Portal

*Student:* Ajayi Oluwatosin
*Student ID:* 301925942
*Course:* MIT 8103 Advanced Database Systems
*Case Study:* University of Abuja - Department of Computer Science
*Database:* unia_buja_cs (from Portfolio 1)

## 1. Problem
Results are sensitive. Without security:
- A student could see another student's results.
- A student could UPDATE their own grade from F to A.
- A lecturer could change results for a course they don't teach.
- An attacker could use SQL Injection to delete the whole database.

Security must be enforced IN THE DATABASE, not just in the app. Even if the app is hacked, the database should still protect the data.

## 2. Principle of Least Privilege
Every user gets ONLY the permissions they need to do their job, nothing more.

| Role | Can Do | Cannot Do |
| :--- | :--- | :--- |
| *student_role* | SELECT own results via View, SELECT own enrollment | Cannot INSERT, UPDATE, DELETE. Cannot see others' results |
| *lecturer_role* | SELECT assigned courses, INSERT/UPDATE results for own courses only | Cannot DELETE results. Cannot see other lecturers' courses |
| *hod_role* | SELECT all reports, UPDATE result approval, SELECT audit log | Cannot DELETE students. Cannot DROP tables |
| *admin_role* | Full control: CREATE, ALTER, BACKUP | Only HOD + IT Admin. Never for students |

## 3. How We Enforce It

### A. Users & Roles in MySQL
```sql
CREATE USER 'student_user'@'localhost' IDENTIFIED BY 'StrongPass123!';
GRANT SELECT ON unia_buja_cs.Student_Result_View TO 'student_user'@'localhost';
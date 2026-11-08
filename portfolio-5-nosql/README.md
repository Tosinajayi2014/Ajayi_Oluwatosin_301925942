# Portfolio 5: NoSQL & Advanced - UniAbuja CS Result Portal

*Student:* Ajayi Oluwatosin
*Student ID:* 301925942
*Course:* MIT 8103 Advanced Database Systems
*Case Study:* University of Abuja - Department of Computer Science

## 1. Problem
MySQL (Portfolio 1-4) is perfect for RESULTS because results need:
- Strict structure (CA + Exam = Total)
- ACID transactions
- Joins (Student + Course + Result)

But MySQL is BAD for:
- Student feedback: "The lecturer was good, but..." - Free text, different fields every time
- System logs: Millions of clicks, "User X viewed page Y at 10:02"
- Notifications: "Your result is out!" - Unstructured, fast changing
- Course materials: PDFs, videos, comments with different shapes

If we force feedback into MySQL, we get many NULL columns, slow ALTER TABLE every time we add a field, and painful scaling.

## 2. Solution: Hybrid Architecture (Polyglot Persistence)

Use the RIGHT database for the RIGHT job:

| Data | Database | Why |
| :--- | :--- | :--- |
| Results, Grades, Enrollment | *MySQL (SQL)* | Needs ACID, joins, consistency. Money/grades cannot be lost. |
| Student Feedback, Course Reviews | *MongoDB (NoSQL Document)* | Flexible schema. One student writes 2 fields, another writes 10. |
| Activity Logs, Audit Trail | *MongoDB* | High write volume, no joins needed, easy to scale horizontally. |
| Notifications, Chat | *MongoDB / Redis* | Fast, unstructured, temporary data. |

We do NOT replace MySQL. We ADD MongoDB alongside it.

## 3. SQL vs NoSQL Comparison

| Feature | MySQL (SQL) | MongoDB (NoSQL) |
| :--- | :--- | :--- |
| Data Model | Tables, Rows | Documents (JSON-like BSON) |
| Schema | Fixed, must ALTER to change | Flexible, each document can differ |
| Joins | Strong (JOIN) | Weak (Embed or $lookup) |
| Transactions | Full ACID (Portfolio 3) | Single-document ACID, multi-doc since v4.0 |
| Scaling | Vertical (bigger server) / Hard to shard | Horizontal (sharding easy) |
| Best For | Results, Payments, Enrollment | Feedback, Logs, Social, Catalogs |

## 4. MongoDB Document Example

In MySQL, feedback would be a rigid table. In MongoDB, it is a flexible document:

```json
{
  "_id": "feedback_001",
  "student_matric": "U21CS1001",
  "course_code": "CSC 301",
  "semester": "2024/2025 - 1st Semester",
  "rating": 5,
  "comment": "Dr. Musa explained DBMS very well",
  "tags": ["clear", "helpful", "practical"],
  "lecturer": { "name": "Dr. Musa", "department": "Computer Science" },
  "created_at": "2025-11-09T10:00:00Z"
}
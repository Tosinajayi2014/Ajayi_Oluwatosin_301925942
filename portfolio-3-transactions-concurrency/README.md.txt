# Portfolio 3: Transactions & Concurrency - UniAbuja CS Result Portal

**Student:** Ajayi Oluwatosin
**Student ID:** 301925942
**Course:** MIT 8103 Advanced Database Systems
**Case Study:** University of Abuja - Department of Computer Science
**Database:** unia_buja_cs (from Portfolio 1)

## 1. Problem
Result entry is not a single INSERT. It is a multi-step process:
1. Check student is enrolled
2. Insert / Update Result (CA + Exam)
3. Update Enrollment status to 'Completed'
4. Log the change in Audit Log

What if the system crashes after step 2 but before step 4?
- Result is saved but no audit log. No one knows who changed it.
- Or worse: Two lecturers update the SAME result at the SAME time.

Example of Lost Update:
- Lecturer A reads CA = 30
- Lecturer B reads CA = 30 at same time
- A updates to 32 and saves
- B updates to 35 and saves - A's change is LOST!

We need Transactions to make all steps succeed together, or fail together.

## 2. ACID Properties

| Property | Meaning | In Our System |
| :--- | :--- | :--- |
| **A**tomicity | All or Nothing | Insert Result + Audit Log must both succeed, or both rollback |
| **C**onsistency | Valid state to valid state | Total = CA + Exam always 0-100, CHECK constraints never broken |
| **I**solation | Concurrent transactions don't interfere | Lecturer A cannot see Lecturer B's uncommitted change |
| **D**urability | Once committed, never lost | Even if power fails after COMMIT, result stays |

## 3. Transaction Example - Enter Result Safely

```sql
START TRANSACTION;
  INSERT INTO Result (enrollment_id, ca_score, exam_score, grade)
  VALUES (1, 32, 55, 'A');
  UPDATE Enrollment SET status = 'Completed' WHERE enrollment_id = 1;
  INSERT INTO Audit_Log (action, done_by) VALUES ('Result Entered', 'Lecturer 1');
COMMIT;
-- If ANY step fails: ROLLBACK;
-- Portfolio 3: Transactions & Concurrency
-- Student: Ajayi Oluwatosin (301925942)
-- Database: unia_buja_cs
USE unia_buja_cs;

-- =====================================================
-- SETUP: Create Audit Log table if not exists
-- Needed to prove Atomicity: Result + Audit must both succeed
-- =====================================================
CREATE TABLE IF NOT EXISTS Audit_Log (
  log_id INT AUTO_INCREMENT PRIMARY KEY,
  action VARCHAR(100) NOT NULL,
  enrollment_id INT,
  done_by VARCHAR(100),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- =====================================================
-- PART A: SAFE RESULT ENTRY - All or Nothing (Atomicity)
-- Run this as ONE block. All 3 steps succeed together.
-- =====================================================
START TRANSACTION;

  -- Step 1: Insert Result for enrollment 2
  INSERT INTO Result (enrollment_id, ca_score, exam_score, grade, grade_point)
  VALUES (2, 30, 55, 'A', 5.00)
  ON DUPLICATE KEY UPDATE ca_score = 30, exam_score = 55, grade = 'A', grade_point = 5.00;

  -- Step 2: Mark enrollment as Completed
  UPDATE Enrollment SET status = 'Completed' WHERE enrollment_id = 2;

  -- Step 3: Log who did it (Audit)
  INSERT INTO Audit_Log (action, enrollment_id, done_by)
  VALUES ('Result Entered', 2, 'Lecturer 1 - Dr. Musa');

COMMIT;
-- If any step above had failed, we would run ROLLBACK instead of COMMIT

SELECT * FROM Result WHERE enrollment_id = 2;
SELECT * FROM Audit_Log ORDER BY log_id DESC LIMIT 3;

-- =====================================================
-- PART B: ROLLBACK DEMO - Crash Simulation
-- This simulates: Insert succeeds, then error happens.
-- ROLLBACK should undo the insert.
-- =====================================================
START TRANSACTION;

  INSERT INTO Result (enrollment_id, ca_score, exam_score, grade, grade_point)
  VALUES (3, 10, 20, 'F', 0.00)
  ON DUPLICATE KEY UPDATE ca_score = 10, exam_score = 20;

  -- Simulate error: e.g. Invalid grade, or system crash here
  -- We decide to cancel everything:
ROLLBACK;

-- Check: enrollment 3 should NOT have the bad 10/20 result
-- It should still have its ORIGINAL result from Portfolio 1
SELECT * FROM Result WHERE enrollment_id = 3;

-- =====================================================
-- PART C: PREVENT LOST UPDATE - Row Locking
-- Open TWO MySQL windows to test this:
-- Window 1 (Lecturer A): Run this, DO NOT COMMIT yet
-- Window 2 (Lecturer B): Try to UPDATE same row - it will WAIT / BLOCK
-- =====================================================
-- --- WINDOW 1 ---
-- START TRANSACTION;
-- SELECT * FROM Result WHERE enrollment_id = 1 FOR UPDATE;
-- -- Row 1 is now LOCKED. Lecturer B cannot update it.
-- UPDATE Result SET ca_score = 35 WHERE enrollment_id = 1;
-- -- Now COMMIT to release lock:
-- COMMIT;

-- --- WINDOW 2 (Run while Window 1 has NOT committed) ---
-- START TRANSACTION;
-- UPDATE Result SET ca_score = 38 WHERE enrollment_id = 1;
-- -- This will HANG / WAIT until Window 1 COMMITs or ROLLBACKs
-- COMMIT;

-- =====================================================
-- PART D: SAVEPOINT - Partial Rollback
-- You can rollback to a point, not all the way
-- =====================================================
START TRANSACTION;

  INSERT INTO Audit_Log (action, enrollment_id, done_by)
  VALUES ('Started Result Entry', 4, 'Lecturer 2');

  SAVEPOINT sp1;

  INSERT INTO Audit_Log (action, enrollment_id, done_by)
  VALUES ('Bad Entry - Will Undo', 4, 'Lecturer 2');

  -- Undo only the second insert, keep the first
  ROLLBACK TO SAVEPOINT sp1;

COMMIT;

SELECT * FROM Audit_Log ORDER BY log_id DESC LIMIT 5;

-- =====================================================
-- PART E: DEADLOCK DEMO (Explanation + How to Avoid)
-- =====================================================
-- Deadlock happens when:
-- Transaction A locks Result 1, wants Result 2
-- Transaction B locks Result 2, wants Result 1
-- Both wait forever. MySQL kills one with ERROR 1213.

-- --- Transaction A (Window 1) ---
-- START TRANSACTION;
-- UPDATE Result SET ca_score = 30 WHERE enrollment_id = 1;
-- -- Wait 2 seconds, then:
-- UPDATE Result SET ca_score = 32 WHERE enrollment_id = 2;
-- COMMIT;

-- --- Transaction B (Window 2) - Run AT SAME TIME as A ---
-- START TRANSACTION;
-- UPDATE Result SET ca_score = 31 WHERE enrollment_id = 2;
-- UPDATE Result SET ca_score = 33 WHERE enrollment_id = 1;
-- COMMIT;
-- One of them will get: ERROR 1213 Deadlock found

-- HOW TO AVOID DEADLOCK:
-- 1. Always lock rows in SAME ORDER: ORDER BY enrollment_id
-- 2. Keep transactions SHORT - don't wait for user input inside
-- 3. Retry the failed transaction in your app code

-- Safe order example - BOTH transactions lock 1 then 2:
START TRANSACTION;
  SELECT * FROM Result WHERE enrollment_id IN (1, 2)
  ORDER BY enrollment_id FOR UPDATE;
  UPDATE Result SET ca_score = 30 WHERE enrollment_id = 1;
  UPDATE Result SET ca_score = 32 WHERE enrollment_id = 2;
COMMIT;

-- =====================================================
-- PART F: CHECK ISOLATION LEVEL
-- =====================================================
SELECT @@transaction_isolation;
-- MySQL default should be REPEATABLE-READ
-- This prevents Dirty Reads and Non-Repeatable Reads

-- To change for a session (e.g. for reports):
-- SET SESSION TRANSACTION ISOLATION LEVEL READ COMMITTED;
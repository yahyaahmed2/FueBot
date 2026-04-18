CREATE TABLE degree_requirement (
    req_id          SERIAL PRIMARY KEY,
    description     TEXT NOT NULL,
    major           VARCHAR(100) NOT NULL,		-- e.g. 'IS', 'CS', 'DM'
    credits_needed  INTEGER      NOT NULL CHECK (credits_needed > 0),
    is_active       BOOLEAN      NOT NULL DEFAULT TRUE,
    effective_date  DATE         NOT NULL
);

CREATE TABLE student (
    student_id   SERIAL PRIMARY KEY,
    first_name   VARCHAR(100) NOT NULL,
    last_name    VARCHAR(100) NOT NULL,
    email        VARCHAR(255) NOT NULL UNIQUE,
    password     VARCHAR(255) NOT NULL,
    gpa          NUMERIC(3,2) CHECK (gpa BETWEEN 0 AND 4.00),
    major        VARCHAR(100) NOT NULL,
    req_id       INTEGER      REFERENCES degree_requirement(req_id)
                               ON UPDATE CASCADE ON DELETE SET NULL
);

CREATE TABLE course (
    course_id     SERIAL PRIMARY KEY,        -- internal PK
    code          VARCHAR(20)  NOT NULL UNIQUE,  -- e.g. "CS101"
    name          VARCHAR(255) NOT NULL,
    description   TEXT,
    credits       INTEGER      NOT NULL CHECK (credits > 0),
    instructor    VARCHAR(255),
    semester      VARCHAR(50)               -- e.g. 'Fall 2026'
);

CREATE TABLE course_prerequisite (
    course_id        INTEGER NOT NULL,
    prereq_course_id INTEGER NOT NULL,
    PRIMARY KEY (course_id, prereq_course_id),
    FOREIGN KEY (course_id)
        REFERENCES course(course_id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    FOREIGN KEY (prereq_course_id)
        REFERENCES course(course_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
);

CREATE TABLE student_course (
    student_id  INTEGER NOT NULL REFERENCES student(student_id)
                           ON UPDATE CASCADE ON DELETE CASCADE,
    course_id   INTEGER NOT NULL REFERENCES course(course_id)
                           ON UPDATE CASCADE ON DELETE RESTRICT,
    PRIMARY KEY (student_id, course_id)
);

CREATE TABLE chat_history (
    chat_id        SERIAL PRIMARY KEY,
    student_id     INTEGER NOT NULL REFERENCES student(student_id)
                              ON UPDATE CASCADE ON DELETE CASCADE,
    user_message   TEXT NOT NULL,
    bot_response   TEXT,
    session_status VARCHAR(50),          -- e.g. 'open', 'closed'
    timestamp      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);


-- Editing For The Tables

ALTER TABLE student_course
ADD COLUMN status VARCHAR(20) NOT NULL DEFAULT 'in_progress'
    CHECK (status IN ('completed', 'in_progress', 'planned'));


-- Dummy Data Insertion

INSERT INTO degree_requirement (description, major, credits_needed, effective_date)
VALUES
  ('Computer Science BSc 2024 plan', 'CS', 120, '2024-09-01'),
  ('Information Systems BSc 2024 plan', 'IS', 120, '2024-09-01');
  

INSERT INTO student (first_name, last_name, email, password, gpa, major, req_id)
VALUES
  ('Hassan',  'Amr', 'hassan@example.com',  'hash1', 3.40, 'CS', 1),
  ('Yahya', 'Ahmed', 'yahya@example.com', 'hash2', 2.80, 'CS', 1),
  ('Mostafa', 'Tarek', 'mostafa@example.com', 'hash3', 3.90, 'IS', 2);
  

INSERT INTO course (code, name, description, credits, instructor, semester)
VALUES
  ('MATH101', 'Calculus I',       'Intro calculus',              3, 'Dr. Fathy', 'Fall 2026'),
  ('MATH102', 'Calculus II',      'Continuation of calculus',    3, 'Dr. Fathy', 'Spring 2027'),
  ('CS101',   'Intro to CS',      'Basics of programming',       3, 'Dr. Mona',  'Fall 2026'),
  ('CS102',   'Data Structures',  'Data structures in depth',    3, 'Dr. Mona',  'Spring 2027'),
  ('CS201',   'Algorithms',       'Algorithm design and analysis',3,'Dr. Adel', 'Fall 2027');

-- MATH102 requires MATH101
INSERT INTO course_prerequisite (course_id, prereq_course_id)
VALUES (2, 1);

-- CS102 requires CS101
INSERT INTO course_prerequisite (course_id, prereq_course_id)
VALUES (4, 3);

-- CS201 requires CS102
INSERT INTO course_prerequisite (course_id, prereq_course_id)
VALUES (5, 4);


-- Hassan (student_id = 1)
INSERT INTO student_course (student_id, course_id, status) VALUES
  (1, 1, 'completed'),   -- MATH101
  (1, 3, 'completed'),   -- CS101
  (1, 4, 'in_progress'); -- CS102

-- Yahya (student_id = 2)
INSERT INTO student_course (student_id, course_id, status) VALUES
  (2, 3, 'completed');   -- CS101

-- Mostafa (student_id = 3)
INSERT INTO student_course (student_id, course_id, status) VALUES
  (3, 1, 'completed'),   -- MATH101
  (3, 2, 'completed');   -- MATH102



-- Testing With Chatbot‑style Queries
-- 1. “What are the prerequisites for CS201?”
SELECT prereq.code, prereq.name
FROM course_prerequisite cp
JOIN course target
  ON target.course_id = cp.course_id
JOIN course prereq
  ON prereq.course_id = cp.prereq_course_id
WHERE target.code = 'CS201';
-- Should return CS102

-- 2. “Has Hassan completed all prerequisites for CS201?”
-- Hassan's student id == 1
SELECT NOT EXISTS (
    SELECT 1
    FROM course_prerequisite cp
    JOIN course target
      ON target.course_id = cp.course_id
    LEFT JOIN student_course sc
      ON sc.course_id  = cp.prereq_course_id
     AND sc.student_id = 1
     AND sc.status     = 'completed'
    WHERE target.code = 'CS201'
      AND sc.course_id IS NULL
) AS can_take;
-- Should return false

-- 3. “Which prerequisites is Yahya missing for CS201?”
SELECT prereq.code, prereq.name
FROM course_prerequisite cp
JOIN course target
  ON target.course_id = cp.course_id
JOIN course prereq
  ON prereq.course_id = cp.prereq_course_id
LEFT JOIN student_course sc
  ON sc.course_id  = prereq.course_id
 AND sc.student_id = 2
 AND sc.status     = 'completed'
WHERE target.code = 'CS201'
  AND sc.course_id IS NULL;
-- Should return CS102

-- 4. “List all courses Mostafa is allowed to take next (all prereqs completed)”
SELECT c.code, c.name
FROM course c
WHERE NOT EXISTS (
    SELECT 3
    FROM course_prerequisite cp
    LEFT JOIN student_course sc
      ON sc.course_id  = cp.prereq_course_id
     AND sc.student_id = 3
     AND sc.status     = 'completed'
    WHERE cp.course_id = c.course_id
      AND sc.course_id IS NULL
);
-- This will include courses with no prerequisites

-- 5. “Show Hassan’s completed courses”
SELECT c.code, c.name
FROM student_course sc
JOIN course c ON c.course_id = sc.course_id
WHERE sc.student_id = 1 AND sc.status = 'completed'
ORDER BY c.code;
-- Should return CS101 & MATH101
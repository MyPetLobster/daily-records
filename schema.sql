----------------------------------------
---------- REPRESENT EACH DAY ----------
----------------------------------------

CREATE TABLE day (
    id INT unsigned NOT NULL AUTO_INCREMENT,
    day_date DATE NOT NULL,
    day_summary TEXT NOT NULL,
    PRIMARY KEY (id)
);


-----------------------------------------
---------- WORK RELATED TABLES ----------
-----------------------------------------

-- Represent all blocks of time spent working for my handyman business
CREATE TABLE work_time_block (
    id INT unsigned NOT NULL AUTO_INCREMENT,
    work_day_id INT unsigned NOT NULL,
    work_hours DECIMAL(4,2) NOT NULL,
    travel_hours DECIMAL(4,2) NOT NULL,
    work_summary TEXT NOT NULL,
    PRIMARY KEY (id),
    CONSTRAINT fk_work_day_id FOREIGN KEY (work_day_id) REFERENCES day(id)
);

-- Represent all of my clients for my handyman business
CREATE TABLE client (
    id INT unsigned NOT NULL AUTO_INCREMENT,
    client_name VARCHAR(255) NOT NULL,
    client_phone VARCHAR(20) NOT NULL,
    PRIMARY KEY (id)
);

-- Represent all of the individual jobs for my handyman business
CREATE TABLE job (
    id INT unsigned NOT NULL AUTO_INCREMENT,
    client_id INT unsigned NOT NULL,
    job_name VARCHAR(255) NOT NULL,
    job_location VARCHAR(255) NOT NULL,
    job_description TEXT NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE default NULL,
    job_rate INT unsigned NOT NULL,
    job_active BOOLEAN NOT NULL default 1, -- 0 = false, 1 = true
    PRIMARY KEY (id),
    CONSTRAINT fk_job_client FOREIGN KEY (client_id) REFERENCES client(id)
);

-- Association table to represent the jobs I worked on in a given time block
CREATE TABLE blocks_jobs (
    work_time_block_id INT unsigned NOT NULL,
    job_id INT unsigned NOT NULL,
    CONSTRAINT fk_blocks_jobs_work_block FOREIGN KEY (work_time_block_id) REFERENCES work_time_block(id),
    CONSTRAINT fk_block_jobs_job FOREIGN KEY (job_id) REFERENCES job(id),
    PRIMARY KEY (work_time_block_id, job_id)
);

-- Represent all purchases made for jobs
CREATE TABLE purchase (
    id INT unsigned NOT NULL AUTO_INCREMENT,
    job_id INT unsigned NOT NULL,
    purchase_date DATE NOT NULL,
    purchase_store VARCHAR(150) NOT NULL,
    purchase_items TEXT NOT NULL,
    purchase_amount DECIMAL(6,2) NOT NULL,
    reimbursed BOOLEAN NOT NULL default 0, -- 0 = false, 1 = true
    PRIMARY KEY (id),
    CONSTRAINT fk_purchase_job FOREIGN KEY (job_id) REFERENCES job(id)
);

-- Represent all of the invoices for my handyman business
CREATE TABLE invoice (
    id INT unsigned NOT NULL AUTO_INCREMENT,
    job_id INT unsigned NOT NULL,
    invoice_date DATE NOT NULL,
    work_hours_total DECIMAL(5,2) NOT NULL,
    reimbursement_total DECIMAL(6,2) NOT NULL,
    invoice_amount DECIMAL(6,2) NOT NULL,
    invoice_paid BOOLEAN NOT NULL default 0, -- 0 = false, 1 = true
    PRIMARY KEY (id),
    CONSTRAINT fk_invoice_job FOREIGN KEY (job_id) REFERENCES job(id)
);


----------------------------------------------
---------- EDUCATION RELATED TABLES ----------
----------------------------------------------

-- Represent all of blocks of time spent learning
CREATE TABLE learning_time_block (
    id INT unsigned NOT NULL AUTO_INCREMENT,
    learn_day_id INT unsigned NOT NULL,
    learn_hours DECIMAL(4,2) NOT NULL,
    learn_summary VARCHAR(255) NOT NULL,
    learn_topics TEXT NOT NULL,
    PRIMARY KEY (id),
    CONSTRAINT fk_learn_day_id FOREIGN KEY (learn_day_id) REFERENCES day(id)
);

-- Represent all of my courses
CREATE TABLE course (
    id INT unsigned NOT NULL AUTO_INCREMENT,
    course_name VARCHAR(255) NOT NULL,
    course_school VARCHAR(255) NOT NULL,
    course_website VARCHAR(255) NOT NULL,
    course_description TEXT NOT NULL,
    course_topics TEXT NOT NULL,
    PRIMARY KEY (id)
);

-- Represent all my coding projects
CREATE TABLE project (
    id INT unsigned NOT NULL AUTO_INCREMENT,
    course_id INT unsigned,
    project_name VARCHAR(255) NOT NULL,
    project_description TEXT NOT NULL,
    project_tools TEXT NOT NULL,
    PRIMARY KEY (id),
    CONSTRAINT fk_project_course FOREIGN KEY (course_id) REFERENCES course(id)
);

-- Association table to represent the courses I worked on in a given time block
CREATE TABLE blocks_courses (
    learning_time_block_id INT unsigned NOT NULL,
    course_id INT unsigned NOT NULL,
    CONSTRAINT fk_blocks_courses_learning_block FOREIGN KEY (learning_time_block_id) REFERENCES learning_time_block(id),
    CONSTRAINT fk_blocks_courses_course FOREIGN KEY (course_id) REFERENCES course(id),
    PRIMARY KEY (learning_time_block_id, course_id)
);

-- Association table to represent the projects I worked on in a given time block
CREATE TABLE blocks_projects (
    learning_time_block_id INT unsigned NOT NULL,
    project_id INT unsigned NOT NULL,
    CONSTRAINT fk_blocks_projects_learning_block FOREIGN KEY (learning_time_block_id) REFERENCES learning_time_block(id),
    CONSTRAINT fk_blocks_projects_project FOREIGN KEY (project_id) REFERENCES project(id),  
    PRIMARY KEY (learning_time_block_id, project_id)
);


--------------------------------------------------------------------------
---------- STORED PROCEDURES FOR ADDING INFORMATION TO DATABASE ----------

----------------------------- WORK PROCEDURE -----------------------------
--------------------------------------------------------------------------

DELIMITER $$

CREATE PROCEDURE AddWorkInformation(
    IN p_day_date DATE, IN p_day_summary TEXT,
    IN p_work_hours DECIMAL(4,2), IN p_travel_hours DECIMAL(4,2), IN p_work_summary TEXT,
    IN p_client_name VARCHAR(255), IN p_client_phone VARCHAR(20),
    IN p_job_name VARCHAR(255), IN p_job_location VARCHAR(255), IN p_job_description TEXT, IN p_start_date DATE, IN p_end_date DATE, IN p_job_rate INT,
    IN p_purchase_date DATE, IN p_purchase_store VARCHAR(150), IN p_purchase_items TEXT, IN p_purchase_amount DECIMAL(6,2),
    IN p_invoice_date DATE, IN p_work_hours_total DECIMAL(5,2), IN p_reimbursement_total DECIMAL(6,2), IN p_invoice_amount DECIMAL(6,2)
)
BEGIN
    -- Insert into 'day' table
    INSERT INTO day (day_date, day_summary) VALUES (p_day_date, p_day_summary);
    SET @day_id = LAST_INSERT_ID();

    -- Insert into 'client' table
    INSERT INTO client (client_name, client_phone) VALUES (p_client_name, p_client_phone);
    SET @client_id = LAST_INSERT_ID();

    -- Insert into 'job' table
    INSERT INTO job (client_id, job_name, job_location, job_description, start_date, end_date, job_rate, job_active) VALUES (@client_id, p_job_name, p_job_location, p_job_description, p_start_date, p_end_date, p_job_rate, 1);
    SET @job_id = LAST_INSERT_ID();

    -- Insert into 'work_time_block' table
    INSERT INTO work_time_block (work_day_id, work_hours, travel_hours, work_summary) VALUES (@day_id, p_work_hours, p_travel_hours, p_work_summary);
    SET @work_time_block_id = LAST_INSERT_ID();

    -- Insert into 'purchase' table
    INSERT INTO purchase (job_id, purchase_date, purchase_store, purchase_items, purchase_amount, reimbursed) VALUES (@job_id, p_purchase_date, p_purchase_store, p_purchase_items, p_purchase_amount, 0);

    -- Insert into 'invoice' table
    INSERT INTO invoice (job_id, invoice_date, work_hours_total, reimbursement_total, invoice_amount, invoice_paid) VALUES (@job_id, p_invoice_date, p_work_hours_total, p_reimbursement_total, p_invoice_amount, 0);

    -- Insert into 'blocks_jobs' table
    INSERT INTO blocks_jobs (work_time_block_id, job_id) VALUES (@work_time_block_id, @job_id);
END$$

DELIMITER ;


----------------------------------------------------------------------------
--------------------------- EDUCATION PROCEDURE ----------------------------
----------------------------------------------------------------------------

DELIMITER $$

CREATE PROCEDURE AddLearningInformation(
    IN p_day_date DATE, IN p_day_summary TEXT,
    IN p_learn_hours DECIMAL(4,2), IN p_learn_summary VARCHAR(255), IN p_learn_topics TEXT,
    IN p_course_name VARCHAR(255), IN p_course_school VARCHAR(255), IN p_course_website VARCHAR(255), IN p_course_description TEXT, IN p_course_topics TEXT,
    IN p_project_name VARCHAR(255), IN p_project_description TEXT, IN p_project_tools TEXT
)
BEGIN
    -- Insert into 'day' table
    INSERT INTO day (day_date, day_summary) VALUES (p_day_date, p_day_summary);
    SET @day_id = LAST_INSERT_ID();

    -- Insert into 'course' table
    INSERT INTO course (course_name, course_school, course_website, course_description, course_topics) VALUES (p_course_name, p_course_school, p_course_website, p_course_description, p_course_topics);
    SET @course_id = LAST_INSERT_ID();

    -- Insert into 'project' table
    INSERT INTO project (course_id, project_name, project_description, project_tools) VALUES (@course_id, p_project_name, p_project_description, p_project_tools);
    SET @project_id = LAST_INSERT_ID();

    -- Insert into 'learning_time_block' table
    INSERT INTO learning_time_block (learn_day_id, learn_hours, learn_summary, learn_topics) VALUES (@day_id, p_learn_hours, p_learn_summary, p_learn_topics);
    SET @learning_time_block_id = LAST_INSERT_ID();

    -- Insert into 'blocks_courses' table
    INSERT INTO blocks_courses (learning_time_block_id, course_id) VALUES (@learning_time_block_id, @course_id);

    -- Insert into 'blocks_projects' table
    INSERT INTO blocks_projects (learning_time_block_id, project_id) VALUES (@learning_time_block_id, @project_id);
END$$

DELIMITER ;


---------------------------------------------------------------
---------- EXAMPLES OF CALLING THE STORED PROCEDURES ----------
---------------------------------------------------------------

CALL AddWorkInformation(
    'Summary of the day',       -- day_summary
    '2024-01-20',               -- day_date
    8.00,                       -- work_hours
    1.00,                       -- travel_hours
    'Fixed kitchen sink',       -- work_summary
    'John Doe',                 -- client_name
    '123-456-7890',             -- client_phone
    'Kitchen Repair',           -- job_name
    '123 Main St',              -- job_location
    'Repaired leaking sink',    -- job_description
    '2024-01-20',               -- start_date
    NULL,                       -- end_date
    500,                        -- job_rate
    '2024-01-20',               -- purchase_date
    'Hardware Store',           -- purchase_store
    'Pipes and wrench',         -- purchase_items
    50.00, '2024-01-20',        -- purchase_amount
    8.00,                       -- invoice_date
    50.00,                      -- work_hours_total
    550.00                      -- reimbursement_total
);

CALL AddLearningInformation(
    '2024-01-20',                       -- day_date
    'Studied SQL',                      -- day_summary
    4.00,                               -- learn_hours
    'SQL Practice',                     -- learn_summary
    'Advanced SQL techniques',          -- learn_topics
    'SQL for Beginners',                -- course_name
    'Online University',                -- course_school
    'http://sqlcourse.com',             -- course_website
    'Introduction to SQL',              -- course_description
    'Basics, Queries, Joins',           -- course_topics
    'Database Project',                 -- project_name
    'Creating a personal database',     -- project_description
    'MySQL, PHP'                        -- project_tools
);
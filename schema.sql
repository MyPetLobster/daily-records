-- REPRESENT EACH DAY
CREATE TABLE day (
    id INT unsigned NOT NULL AUTO_INCREMENT,
    day_date DATE NOT NULL,
    day_summary TEXT NOT NULL,
    PRIMARY KEY (id)
);


-- WORK RELATED TABLES
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

-- Represent all of the individual jobs for my handyman business
CREATE TABLE job (
    id INT unsigned NOT NULL AUTO_INCREMENT,
    client_id INT unsigned NOT NULL,
    job_name VARCHAR(255) NOT NULL,
    job_location VARCHAR(255) NOT NULL,
    job_description TEXT NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE,
    job_rate INT unsigned NOT NULL,
    job_active BOOLEAN NOT NULL default 1, -- 0 = false, 1 = true
    PRIMARY KEY (id),
    CONSTRAINT fk_job_client FOREIGN KEY (client_id) REFERENCES client(id)
);

-- Represent all of my clients for my handyman business
CREATE TABLE client (
    id INT unsigned NOT NULL AUTO_INCREMENT,
    client_name VARCHAR(255) NOT NULL,
    client_phone VARCHAR(20) NOT NULL,
    PRIMARY KEY (id)
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

-- Association table to represent the jobs I worked on in a given time block
CREATE TABLE blocks_jobs (
    work_time_block_id INT unsigned NOT NULL,
    job_id INT unsigned NOT NULL,
    CONSTRAINT fk_blocks_jobs_work_block FOREIGN KEY (work_time_block_id) REFERENCES work_time_block(id),
    CONSTRAINT fk_block_jobs_job FOREIGN KEY (job_id) REFERENCES job(id),
    PRIMARY KEY (work_time_block_id, job_id)
);


-- EDUCATION RELATED TABLES
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
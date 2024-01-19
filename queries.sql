-- WORK RELATED QUERIES

-- Get a list of all the jobs that are still active (haven't been paid yet)
SELECT * 
FROM job 
WHERE job_active = 1;

-- Get the total hours spent on a specific job
SELECT SUM(work_hours) 
FROM work_time_block 
WHERE job_id = (
    SELECT id 
    FROM job 
    WHERE job_name = 'Job Name'
);

-- Get the total hours spent on a specific job in a specific time period
SELECT SUM(work_hours)
FROM work_time_block
WHERE job_id = (
    SELECT id
    FROM job
    WHERE job_name = 'Job Name'
) AND work_date BETWEEN '2024-01-01' AND '2024-01-31';

-- Generate data for an invoice for a specific job with the current date 
INSERT INTO invoice (job_id, invoice_date, work_hours_total, reimbursement_total, invoice_amount, invoice_paid)
VALUES (
    (SELECT id FROM job WHERE job_name = 'Job Name'),
    CURDATE(),
    (SELECT SUM(work_hours) FROM work_time_block WHERE job_id = (SELECT id FROM job WHERE job_name = 'Job Name')),
    (SELECT SUM(purchase_amount) FROM purchase WHERE job_id = (SELECT id FROM job WHERE job_name = 'Job Name')),
    (SELECT SUM(work_hours) * job_rate FROM work_time_block WHERE job_id = (SELECT id FROM job WHERE job_name = 'Job Name')) + (SELECT SUM(purchase_amount) FROM purchase WHERE job_id = (SELECT id FROM job WHERE job_name = 'Job Name')),
    0
);

-- Get the total income from all invoices within a specific time period
SELECT SUM(invoice_amount)
FROM invoice
WHERE invoice_date BETWEEN '2024-01-01' AND '2024-01-31';

-- Get a list of all clients and contact information
SELECT client_name, client_phone
FROM client;

-- Total expenditure on purchases for active jobs 
SELECT job.id, job.job_description, SUM(purchase.purchase_amount) AS Total_Expenditure
FROM job
JOIN purchase ON job.id = purchase.job_id
WHERE job.job_active = 1
GROUP BY job.id;


-- EDUCATION RELATED QUERIES

-- Get a list of all the courses I've taken that involve a specific topic (SQL for example)
SELECT course_name
FROM course
WHERE course_topics LIKE '%SQL%';

-- Get the total hours I've spent working on a specific programming project
SELECT SUM(ltb.learn_hours) AS Total_Hours
FROM learning_time_block ltb
JOIN blocks_projects bp ON ltb.id = bp.learning_time_block_id
JOIN project p ON bp.project_id = p.id
WHERE p.project_name = 'Project Name';

-- Get the total hours I've spent working on a specific course
SELECT SUM(ltb.learn_hours) AS Total_Hours
FROM learning_time_block ltb
JOIN blocks_courses bc ON ltb.id = bc.learning_time_block_id
JOIN course c ON bc.course_id = c.id
WHERE c.course_name = 'Course Name';

-- Average learning hours per course
SELECT course.course_name, AVG(learning_time_block.learn_hours) AS Avg_Learning_Hours
FROM learning_time_block
JOIN blocks_courses ON learning_time_block.id = blocks_courses.learning_time_block_id
JOIN course ON blocks_courses.course_id = course.id
GROUP BY course.id;

-- List of projects with total learning hours and tools used
SELECT project.project_name, project.project_tools, SUM(learning_time_block.learn_hours) AS Total_Learning_Hours
FROM learning_time_block
JOIN blocks_projects ON learning_time_block.id = blocks_projects.learning_time_block_id
JOIN project ON blocks_projects.project_id = project.id
GROUP BY project.id;
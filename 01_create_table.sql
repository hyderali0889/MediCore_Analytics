-- create database hospital_project

-- drop table IF EXISTS hospital_data;

-- Create table hospital_data (
--    "Name" varchar(100) Default 'not Found',
--     "Age" int,
--     "GENDER" varchar(10),
--     "Blood Type" varchar(10),
--     "Medical Condition" varchar(255),
--     "Doctor" varchar (255),
--     "Hospital" VARCHAR(100),
--     "Insurance Provider" varchar(150),
--     "Billing Amount" decimal(15,2),
--     "Room Number" int,
--     "Admission Type" varchar(50),
--     "Medication" VARCHAR(150),
--     "Test Results" varchar(150),
--     "Date of Admission" TIMESTAMP NOT NULL,
--     "Discharge Date" TIMESTAMP
-- )


-- Select * from information_schema.tables where table_name = 'main';

-- SELECT Count(*) from hospital_data;

-- drop table hospital_data;

-- CREATE INDEX idx_date_of_admission ON hospital_data ("Date of Admission");
-- CREATE INDEX idx_medical_condition ON hospital_data ("Medical Condition");


-- create table subset1k as select * from hospital_data limit 1000;
-- create table subset10k as select * from hospital_data limit 10000;

-- drop table subset1k;
-- drop table subset10k;

-- SELECT Count(*) from hospital_data;
-- SELECT Count(*) from subset1k;
-- SELECT Count(*) from subset10k;



-- select * from subset1k;
-- select * from subset10k;



-- select * from subset1k;

-- select * from subset1k where age < 50 
-- order by "Medical Condition";


-- create database backup_project;

-- create Role Andy with LOGIN PASSWORD 'andy@123';
-- create Role Ali with LOGIN PASSWORD 'ali@123';

-- GRANT CONNECT ON DATABASE hospital_project TO ali;
-- GRANT CONNECT ON DATABASE hospital_project TO andy;

-- GRANT USAGE ON SCHEMA public TO ali;

-- GRANT pg_read_all_data TO Andy;
-- GRANT pg_read_all_data TO Ali;
-- GRANT pg_write_all_data TO Ali;

-- REVOKE ALL ON DATABASE hospital_project FROM PUBLIC;
-- REVOKE CREATE ON SCHEMA public FROM PUBLIC;
-- SELECT current_user;

-- select count(*) from hospital_data;

-- TRUNCATE table hospital_data;

-- drop table main;
-- create table main as select * from hospital_data limit 0;

-- select * from main;

-- -- Check constraints on the table
-- SELECT conname, pg_get_constraintdef(oid) 
-- FROM pg_constraint 
-- WHERE conrelid = 'hospital_data'::regclass;


-- select Count(*) from main;
-- select * from main limit 100;

-- CREATE INDEX idx_medical_condition ON main("Medical Condition", "Admission Type");
-- select * from main limit 100;


-- alter table main add COLUMN  "avg_length_of_stay" INTERVAL default '0 days'::interval;
-- alter table main drop COLUMN "avg_length_of_stay";




-- update main set "avg_length_of_stay" = ("Discharge Date" - "Date of Admission");
-- select "avg_length_of_stay" from main limit 100;

-- create MATERIALIZED VIEW mv_av_los as select "avg_length_of_stay" from main 


-- VACUUM:
-- Cleans up "dead tuples" (old row versions left behind after updates or deletes).
-- Marks that space as reusable for future inserts.
-- Prevents table bloat (your table growing much larger than the actual data size).
-- Helps with transaction ID management (avoids future wraparound issues).

-- ANALYZE:
-- Collects fresh statistics about your data (how many rows, value distribution, most/least common values, etc.).
-- These statistics are used by the PostgreSQL query planner to decide the best way to run your queries (e.g., which index to use, join order, etc.).



-- VACUUM ANALYZE main;



-- 1. Total Admissions and Unique Patients
-- select * from main limit 100;
-- Select count(*) as total_admissions, count (distinct "Name") as unique_patients from main;
-- 2. Overall Average Length of Stay (LOS)
-- select "avg_length_of_stay" as Overall_length_of_stay from main limit 100;
-- 3. Average Length of Stay by Department
-- select "avg_length_of_stay" as Overall_length_of_stay , "Medical Condition" from main 
-- Order by "Medical Condition" 
-- limit 100;




-- 4. Average Length of Stay by Diagnosis
-- select distinct "Medical Condition" from main;
-- select distinct "Medical Condition", avg_length_of_stay from main 
-- group by "Medical Condition", avg_length_of_stay ;



-- 5. Top 10 Highest Billing Conditions (by Total Revenue)

-- select sum("Billing Amount") as total_revenue , "Medical Condition" from main
-- group by "Medical Condition" order by total_revenue;

-- With top_doctors As ( 
--     select "Medical Condition", "Doctor", 
--     Rank() OVER (Partition by "Medical Condition" order by "Doctor" ) as doctor_rank  
--     from main 
--     limit 100
-- )
-- Select * from top_doctors

-- Select "Doctor" , date_trunc('year', "Date of Admission") as mnth from main limit 100

-- create VIEW v_patient_count_by_condition AS select "Medical Condition", count(*) as "All Patients" from main group by "Medical Condition"


-- select * from v_patient_count_by_condition limit 100

-- create or replace view top_insurance_provider as ( 
--     Select "Insurance Provider" , Count(*) as "All Patients" from main GROUP BY "Insurance Provider" order by "All Patients" desc limit 100
-- )

-- drop view top_insurance_provider

-- Select "Insurance Provider" , Count(*) as "All Patients" from main GROUP BY "Insurance Provider" order by "All Patients" limit 100


-- select * from top_insurance_provider


-- select * from main



-- ## 6. Top 10 Most Expensive Individual Admissions

-- select "Billing Amount" , "Name" from main 
-- order by "Billing Amount" desc
-- limit 10;




-- ## 7. Average Billing Amount by Department

-- select avg("Billing Amount") as avg_billing  , "Medical Condition" from main
-- group by  "Medical Condition"
-- order by avg_billing desc limit 10;







-- ```sql
-- SELECT 
--     department,
--     COUNT(*) AS admissions,
--     ROUND(AVG(billing_amount), 2) AS avg_billing,
--     ROUND(SUM(billing_amount), 2) AS total_revenue
-- FROM main
-- GROUP BY department
-- ORDER BY total_revenue DESC;
-- ```

-- ## 8. Patient Distribution by Gender

-- select "GENDER" , 
-- count(*) as "Gender Count",
-- round(count(*) * 100.0 / (select count(*) from main), 2) as "Percentage"
-- from main
-- group by "GENDER"


-- ```sql
-- SELECT 
--     gender,
--     COUNT(*) AS count,
--     ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) AS percentage
-- FROM main
-- GROUP BY gender
-- ORDER BY count DESC;
-- ```

-- ## 9. Patient Distribution by Age Group

-- Select "Name", "Medical Condition",
--         CASE 
--             WHEN "Age" < 18 THEN 'Child'
--             WHEN "Age" < 40 Then 'Adult'
--             WHEN "Age" < 60 Then 'Aged'
--             WHEN "Age" < 80 Then 'Senior'
--             ELSE 'Elder'
--         End as "Age Group"
--         from main
--         group by "Age Group" , "Name", "Medical Condition"
--         limit 100;




-- ```sql
-- SELECT 
--     CASE 
--         WHEN age < 18 THEN '0-17 (Child)'
--         WHEN age < 40 THEN '18-39 (Young Adult)'
--         WHEN age < 60 THEN '40-59 (Adult)'
--         WHEN age < 80 THEN '60-79 (Senior)'
--         ELSE '80+ (Elderly)'
--     END AS age_group,
--     COUNT(*) AS patient_count,
--     ROUND(AVG(billing_amount), 2) AS avg_billing
-- FROM main
-- GROUP BY age_group
-- ORDER BY patient_count DESC;
-- ```

-- 10. Monthly Admission Trends

-- select date_trunc('month',"Date of Admission") as month, Count(*)  as admissions from main 
-- group by month
-- order by admissions desc 



-- select
-- a."Name" as name,
-- a."Age" as age,
-- a."Date of Admission" as admission_date,
-- a."Discharge Date" as discharge_date,
-- b."Name" as name,
-- b."Age" as age,
-- b."Date of Admission" as admission_date,
-- b."Discharge Date" as discharge_date
-- from main a Join main b on a."Name" = b."Name" where a."Date of Admission" < b."Date of Admission" 

-- SELECT
--     "Name",
--     SUM("Billing Amount") FILTER (WHERE "Blood Type" = 'A+') AS product_a,
--     SUM("Billing Amount") FILTER (WHERE "Blood Type" = 'B+') AS product_b,
--     SUM("Billing Amount") FILTER (WHERE "Blood Type" = 'AB-') AS product_c
-- FROM main
-- GROUP BY "Name" limit 10;

-- select * from main limit 10;

-- CREATE OR REPLACE FUNCTION get_top_doctors()
-- RETURNS TABLE(doctor VARCHAR(255), total_patients BIGINT) AS $$
-- BEGIN
--     RETURN QUERY
--     SELECT 
--         "Doctor",
--         COUNT(*) AS total_patients
--     FROM main
--     GROUP BY "Doctor"
--     ORDER BY total_patients DESC
--     LIMIT 100;
-- END;
-- $$ LANGUAGE plpgsql;

-- drop function get_top_doctors();


-- select * from get_top_doctors();









-- ## 11. Top 5 Conditions with Longest Average Stay


-- Select "Medical Condition" , "avg_length_of_stay" , Count(*) as patient_count from main
-- group by "Medical Condition" , "avg_length_of_stay"
-- order by "avg_length_of_stay" desc limit 10;





-- ```sql
-- SELECT 
--     diagnosis,
--     COUNT(*) AS cases,
--     ROUND(AVG(EXTRACT(DAY FROM ("Date of Discharge" - "Date of Admission"))), 2) AS avg_los_days
-- FROM main
-- WHERE "Date of Discharge" IS NOT NULL
-- GROUP BY diagnosis
-- ORDER BY avg_los_days DESC
-- LIMIT 5;
-- ```

-- ## 12. 30-Day Readmission Rate


-- select a."Name" , a."Date of Admission" , a."Discharge Date", b."Name" , b."Date of Admission" as "Readmission Date" from main a Join main b 
-- on a."Name" = b."Name" and b."Date of Admission" != a."Date of Admission" and b."Date of Admission" - a."Date of Admission" <= interval '30 days' limit 100;
-- SELECT *
-- FROM (
--     SELECT
--         "Name",
--         "Date of Admission",
--         "Discharge Date",
--         LEAD("Date of Admission") OVER (
--             PARTITION BY "Name"
--          ORDER BY "Date of Admission"
--         ) AS next_admission
--     FROM main
-- ) t
-- WHERE next_admission IS NOT NULL And (next_admission  > "Date of Admission" ) OR ( "Discharge Date" < "Date of Admission" )
-- AND next_admission <= "Discharge Date" + interval '30 days' limit 100;


-- ```sql
-- WITH next_admission AS (
--     SELECT 
--         patient_id,
--         "Date of Discharge",
--         LEAD("Date of Admission") OVER (PARTITION BY patient_id ORDER BY "Date of Admission") AS next_admit_date
--     FROM main
-- )
-- SELECT 
--     ROUND(100.0 * COUNT(CASE WHEN next_admit_date - "Date of Discharge" <= 30 THEN 1 END) 
--           / COUNT(*), 2) AS readmission_rate_percent
-- FROM next_admission
-- WHERE next_admit_date IS NOT NULL;
-- ```

-- ## 13. Most Common Diagnoses

-- select count(*) as frequenct , "Medical Condition" from main
-- group by "Medical Condition"




-- ```sql
-- SELECT 
--     diagnosis, 
--     COUNT(*) AS frequency
-- FROM main
-- GROUP BY diagnosis
-- ORDER BY frequency DESC
-- LIMIT 10;
-- ```

-- ## 14. Average Billing by Age Group and Gender


-- select 
--         CASE WHEN "Age" < 18 THEN 'Child'
--              WHEN "Age" < 40 THEN 'Young Adult'
--              WHEN "Age" < 60 THEN 'Adult'
--              ELSE 'Senior' END AS age_group,
--              AVG("Billing Amount") as avg_billing,
--              "GENDER"
             
--              from main 
--              group by "Age", "GENDER"
--              order by "GENDER" desc
--              limit 100;








-- ```sql
-- SELECT 
--     CASE 
--         WHEN age < 18 THEN 'Child'
--         WHEN age < 40 THEN 'Young Adult'
--         WHEN age < 60 THEN 'Adult'
--         ELSE 'Senior'
--     END AS age_group,
--     gender,
--     ROUND(AVG(billing_amount), 2) AS avg_billing,
--     COUNT(*) AS patients
-- FROM main
-- GROUP BY age_group, gender
-- ORDER BY avg_billing DESC;
-- ```

-- ## 15. Hospital Performance Summary (Dashboard)

    -- select 
    -- count(*) as total_admissions,
    -- count (distinct "Name") as all_patients,
    -- avg_length_of_stay as overall_avg_los_days,
    -- round(avg("Billing Amount"), 2) as overall_avg_billing,
    -- round(sum("Billing Amount"), 2) as total_revenue
    -- from main
    -- group by overall_avg_los_days




-- ```sql
-- SELECT 
--     COUNT(*) AS total_admissions,
--     COUNT(DISTINCT patient_id) AS unique_patients,
--     ROUND(AVG(EXTRACT(DAY FROM ("Date of Discharge" - "Date of Admission"))), 2) AS overall_avg_los_days,
--     ROUND(AVG(billing_amount), 2) AS overall_avg_billing,
--     ROUND(SUM(billing_amount), 2) AS total_revenue
-- FROM main
-- WHERE "Date of Discharge" IS NOT NULL;
-- ```



-- create view v_hospital_performance_summary as
    -- select 
    -- count(*) as total_admissions,
    -- count (distinct "Name") as all_patients,
    -- avg_length_of_stay as overall_avg_los_days,
    -- round(avg("Billing Amount"), 2) as overall_avg_billing,
    -- round(sum("Billing Amount"), 2) as total_revenue
    -- from main
    -- group by overall_avg_los_days

-- select * from v_hospital_performance_summary;

-- create view avg_bill_by_age as
-- select 
--         CASE WHEN "Age" < 18 THEN 'Child'
--              WHEN "Age" < 40 THEN 'Young Adult'
--              WHEN "Age" < 60 THEN 'Adult'
--              ELSE 'Senior' END AS age_group,
--              AVG("Billing Amount") as avg_billing,
--              "GENDER"
             
--              from main 
--              group by "Age", "GENDER"
--              order by "GENDER" desc
--              limit 100;


-- select * from avg_bill_by_age


-- create view readmission_rate_of_hospital as

-- select a."Name" as "Patient Name" , a."Date of Admission" , a."Discharge Date", b."Name" , b."Date of Admission" as "Readmission Date" from main a Join main b 
-- on a."Name" = b."Name" and b."Date of Admission" != a."Date of Admission" and b."Date of Admission" - a."Date of Admission" <= interval '30 days' limit 100;

-- select b."Date of Admission" as "Readmission Date" , Count(a."Name") as "Re Admission Rate"  from main a Join main b 
-- on a."Name" = b."Name" and b."Date of Admission" != a."Date of Admission" and b."Date of Admission" - a."Date of Admission" <= interval '30 days' group by b."Date of Admission" 
-- order by "Re Admission Rate" desc  limit 100;
-- select * from readmission_rate_of_hospital




-- SELECT *
-- FROM (
--     SELECT
--         "Name",
--         "Date of Admission",
--         "Discharge Date",
--         LEAD("Date of Admission") OVER (
--             PARTITION BY "Name"
--             ORDER BY "Date of Admission"
--         ) AS next_admission
--     FROM main
-- ) t
-- WHERE next_admission IS NOT NULL
-- AND next_admission <= "Discharge Date" + interval '30 days';


-- select "Date of Admission", Count("Date of Admission") as Admissions_per_Hour from main
-- group by "Date of Admission" 
-- order by "Date of Admission"
--  limit 100; 


-- CREATE USER debezium WITH REPLICATION LOGIN PASSWORD 'dbz';

-- GRANT ALL PRIVILEGES ON DATABASE hospital_project TO debezium;

-- Drop user debezium;
-- REVOKE all Privileges on database hospital_project from debezium;

-- Select * from pg_user;



-- INSERT INTO main ("Name" , "Age","GENDER" ,"Blood Type" , "Medical Condition" , "Doctor" , "Hospital" , "Insurance Provider" , "Billing Amount" , "Room Number" , "Admission Type" , "Medication" , "Test Results" , "Date of Admission" , "Discharge Date")
-- VALUES ('John Doe', 30, 'Male', 'O+', 'Hypertension', 'Dr. Smith', 'General Hospital', 'Blue Cross', 1500.00, 101, 'Emergency', 'Lisinopril', 'Normal', '2023-10-01', '2023-10-05');
-----------------------------------------------
-- Debezium Setup for Logical Replication:
-----------------------------------------------

-- This enables logical replication on the table, allowing Debezium to capture changes effectively.
-- ALTER TABLE public.main REPLICA IDENTITY FULL;
-- SELECT * FROM pg_replication_slots;


-- these commands are used to configure the PostgreSQL server for logical replication, which is necessary for Debezium to capture changes from the database. The settings include enabling logical replication, increasing the number of replication slots and WAL senders to accommodate Debezium's requirements, and reloading the configuration to apply the changes without restarting the server.
-- ALTER SYSTEM SET wal_level = 'logical';
-- ALTER SYSTEM SET max_replication_slots = 4;
-- ALTER SYSTEM SET max_wal_senders = 4;

-- this command is used to reload the PostgreSQL configuration after making changes to the system settings. It allows the new settings to take effect without needing to restart the database server.
-- SELECT pg_reload_conf();

-- Check the current settings to ensure they have been applied correctly:
-- SHOW wal_level;
-- SHOW max_replication_slots;
-- SHOW max_wal_senders;
-- This command create a PUBLICATION named 'debezium_pub' for all tables in the public schema. This publication will be used by Debezium to subscribe to changes in the database and capture them for real-time data streaming.
-- CREATE PUBLICATION debezium_pub FOR TABLE public.main;

-- Drop Publication IF EXISTS debezium_pub;

-- This command creates a logical replication slot named 'debezium_slot' using the 'pgoutput' plugin, which is compatible with Debezium. The replication slot will capture changes from the database and allow Debezium to read those changes for real-time data streaming.
-- SELECT slot_name, plugin, active FROM pg_replication_slots;

-- SELECT * FROM pg_publication_tables;


-- SELECT column_name, constraint_name 
-- FROM information_schema.key_column_usage 
-- WHERE table_name = 'main';
-- SHOW hba_file;

-- Check current pg_hba rules loaded in memory
-- SELECT type, database, user_name, address, auth_method 
-- FROM pg_hba_file_rules;
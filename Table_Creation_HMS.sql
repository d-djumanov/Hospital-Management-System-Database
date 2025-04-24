
select * from ERP_Master_Patient
--Petient 
--Doctors table
--Nurse table
--Billing
--Insurance
--Rooms

SELECT COLUMN_NAME 
FROM INFORMATION_SCHEMA.COLUMNS 
WHERE TABLE_NAME = 'erp_master_patient'
exec sp_help 'erp_master_patient'
exec sp_help 'patients'


-- Changing the data collation type from Latin1 to UTF-8 for future data collection, will help to prevent future data entering problems
begin transaction

-- Creating dynamic SQL to convert varchar to nvarchar and update collation
DECLARE @sql NVARCHAR(MAX) = N'';

-- First handle varchar to nvarchar conversion and collation change
SELECT @sql = @sql + N'
ALTER TABLE ERP_Master_Patient 
ALTER COLUMN ' + QUOTENAME(c.name) + ' ' + 
    CASE WHEN t.name = 'varchar' THEN 'nvarchar(' + 
        CASE WHEN c.max_length = -1 THEN 'MAX' 
             ELSE CAST(c.max_length AS VARCHAR(10)) END + ')'
         WHEN t.name = 'char' THEN 'nchar(' + CAST(c.max_length AS VARCHAR(10)) + ')'
         ELSE t.name + 
            CASE WHEN t.name IN ('nvarchar', 'nchar') THEN '(' + 
                CASE WHEN c.max_length = -1 THEN 'MAX' 
                     ELSE CAST(c.max_length/2 AS VARCHAR(10)) END + ')'
                 WHEN t.name IN ('text', 'ntext') THEN ''
            END
    END + 
    ' COLLATE Latin1_General_100_CI_AS_SC_UTF8;'
FROM sys.columns c
JOIN sys.types t ON c.user_type_id = t.user_type_id
WHERE c.object_id = OBJECT_ID('ERP_Master_Patient')
AND t.name IN ('char', 'varchar', 'nchar', 'nvarchar', 'text', 'ntext');

-- Print the SQL for review (optional - you can uncomment if you want to see what will be executed)
-- PRINT @sql;

-- Execute the SQL (comment this out if you just want to review the SQL first)
EXEC sp_executesql @sql;

rollback transaction
commit transaction

ALTER DATABASE SQL_Project_Hospital
COLLATE Latin1_General_100_CI_AS_SC_UTF8;

--*****************************************************************
-- Patients Table

begin transaction
select patient_id,first_name,last_name,dob,gender,address,city,state,postal_code,phone_number,email,insurance_provider
		,insurance_policy_number,blood_type,allergies,medications,diagnosis,admission_date,discharge_date,emergency_contact_name
		,emergency_contact_phone,emergency_contact_relationship,insurance_expiration_date,blood_pressure,heart_rate
		,weight,height,temperature
into Patients from ERP_Master_Patient

select * from Patients
exec sp_help 'patients'

commit transaction

--*****************************************************************
-- Physicians table
-- Had to generate physicians data because of lack of information with help of python
-- Imported csv file as doctors table
select * from doctors 
exec sp_help 'doctors'
exec sp_rename 'doctors', 'Doctors'
truncate table doctors

ALTER TABLE Doctors
ALTER COLUMN first_name NVARCHAR(100) 
COLLATE Latin1_General_100_CI_AS_SC_UTF8;

ALTER TABLE Doctors
ALTER COLUMN last_name NVARCHAR(100) 
COLLATE Latin1_General_100_CI_AS_SC_UTF8;

ALTER TABLE Doctors
ALTER COLUMN specialty NVARCHAR(100) 
COLLATE Latin1_General_100_CI_AS_SC_UTF8;

ALTER TABLE Doctors
ALTER COLUMN phone_number NVARCHAR(100) 
COLLATE Latin1_General_100_CI_AS_SC_UTF8;

ALTER TABLE Doctors
ALTER COLUMN email NVARCHAR(100) 
COLLATE Latin1_General_100_CI_AS_SC_UTF8;


--*****************************************************************
-- Nurses table
-- Had to generate nurses data because of lack of information
select * from nurses a
join ERP_Master_Patient b on a.nurse_id = b.nurse_id
exec sp_help 'nurses'
exec sp_rename 'nurses', 'Nurses'

ALTER TABLE Nurses
ALTER COLUMN first_name NVARCHAR(100) 
COLLATE Latin1_General_100_CI_AS_SC_UTF8;

ALTER TABLE Nurses
ALTER COLUMN last_name NVARCHAR(100) 
COLLATE Latin1_General_100_CI_AS_SC_UTF8;

ALTER TABLE Nurses
ALTER COLUMN phone_number NVARCHAR(100) 
COLLATE Latin1_General_100_CI_AS_SC_UTF8;

ALTER TABLE Nurses
ALTER COLUMN email NVARCHAR(100) 
COLLATE Latin1_General_100_CI_AS_SC_UTF8;



--*****************************************************************
-- Billing Table
-- Creating table with existing information
create table Billing (
					billing_id int identity(1,1)
					,patient_id nvarchar(100) COLLATE Latin1_General_100_CI_AS_SC_UTF8
					,total_amount decimal(18,2)
					,amount_paid decimal(18,2)
					,billing_date date
					,due_date date
					,payment_status nvarchar(50) COLLATE Latin1_General_100_CI_AS_SC_UTF8
					,insurance_id smallint
					,billing_description nvarchar(255) COLLATE Latin1_General_100_CI_AS_SC_UTF8
					,payment_method nvarchar(50) COLLATE Latin1_General_100_CI_AS_SC_UTF8
					)
-- Randomly choosing from patient information to fill the billing table
-- For collumns billing_id, patient_id, insurance_id
insert into Billing1 (patient_id,insurance_id)
			select top 2000
			ptn.patient_id
			,ins.insurance_id

from ERP_Master_Patient ptn
join Insurance ins on ptn.patient_id = ins.patient_id
order by NEWID()
select * from Billing1

-- Now inserting values for the rest of the columns

insert into Billing select 
						
						bl.patient_id
						,hbd.total_amount
						,hbd.amount_paid
						,hbd.billing_date
						,hbd.due_date
						,hbd.payment_status
						,bl.insurance_id
						,hbd.billing_description
						,hbd.payment_method

from Billing1 bl
join hospital_billing_data hbd on bl.billing_id = hbd.billing_id

select * from Billing
select * from hospital_billing_data
exec sp_help 'billing'
drop table billing1


--*****************************************************************
-- Rooms table

select * from rooms
exec sp_help 'Rooms'

ALTER TABLE Rooms
ALTER COLUMN room_type NVARCHAR(100) 
COLLATE Latin1_General_100_CI_AS_SC_UTF8;

--*****************************************************************
-- Insurance table

create table Insurance (
			insurance_id smallint identity(1,1)
			,insurance_provider nvarchar(50)
			,policy_number nvarchar (100)
			,coverage_start_date date
			,coverage_end_date date
			,patient_id nvarchar(100)
)

ALTER TABLE Insurance
ALTER COLUMN insurance_provider NVARCHAR(50) 
COLLATE Latin1_General_100_CI_AS_SC_UTF8;

ALTER TABLE Insurance
ALTER COLUMN policy_number NVARCHAR(100) 
COLLATE Latin1_General_100_CI_AS_SC_UTF8;

ALTER TABLE Insurance
ALTER COLUMN patient_id NVARCHAR(100) 
COLLATE Latin1_General_100_CI_AS_SC_UTF8;

exec sp_help 'insurance'

-- Repeat for each text column in the table

begin transaction
insert into Insurance select insurance_provider,insurance_policy_number, dateadd(year,-1,insurance_expiration_date),insurance_expiration_date, patient_id from ERP_Master_Patient

--Filling Insurance1 table with necessary data
select a.insurance_id,a.insurance_provider,a.policy_number,a.coverage_start_date,a.coverage_end_date,a.patient_id
,b.plan_type,b.coverage_type,b.annual_deductible,b.max_out_of_pocket,b.prescription_coverage,b.dental_coverage,b.vision_coverage
into Insurance1
from Insurance a
join insurance_coverage_data b on a.insurance_id = b.insurance_id

rollback transaction
commit transaction
-- generated data for to fill insurance table
select * from insurance_coverage_data
-- Renaming Insurance1 to Insurance
exec sp_rename 'Insurance1', 'Insurance'

select * from Insurance
select * from ERP_Master_Patient
select * from billing_data

--*****************************************************************
-- Extra tables for more realism

-- Admissions table

create table Admissions (
						admission_id int identity(1,1)
						,patient_id nvarchar (100) COLLATE Latin1_General_100_CI_AS_SC_UTF8
						,admission_date datetime 
						,discharge_date datetime
						,doctor_id int
						,nurse_id int
						,room_number int
						,diagnosis nvarchar(30) COLLATE Latin1_General_100_CI_AS_SC_UTF8
						)
insert into Admissions select 
						patient_id
						,admission_date
						,discharge_date
						,doctor_id
						,nurse_id + 1000
						,room_number
						,diagnosis
						from ERP_Master_Patient	
select * from Admissions

--*****************************************************************
create table VitalSigns (
						patient_id nvarchar(100) COLLATE Latin1_General_100_CI_AS_SC_UTF8
						,recorded_at datetime
						,blood_pressure decimal (5,2)
						,heart_rate int
						,weight decimal(5,2)
						,height decimal(5,2)
						,temperature decimal(5,1)
						,recorded_by int
						)
insert into VitalSigns select 
						patient_id
						,admission_date
						,blood_pressure
						,heart_rate
						,weight
						,height
						,temperature
						,ABS(CHECKSUM(NEWID())) % 1000 + 1001 as random_value
						from ERP_Master_Patient

select ABS(CHECKSUM(NEWID())) % 1000 + 1 as random_value
exec sp_help 'vitalsigns'

select * from VitalSigns vs
left join Nurses nr on vs.recorded_by = nr.nurse_id
where nr.nurse_id is null



--*****************************************************************
CREATE TABLE MedicalStaff (
    staff_id INT identity(1,1),
    first_name VARCHAR(50) COLLATE Latin1_General_100_CI_AS_SC_UTF8,
    last_name VARCHAR(50) COLLATE Latin1_General_100_CI_AS_SC_UTF8,
    role VARCHAR(20) COLLATE Latin1_General_100_CI_AS_SC_UTF8, -- 'Doctor' or 'Nurse'
    specialization VARCHAR(50) COLLATE Latin1_General_100_CI_AS_SC_UTF8,
    phone_number VARCHAR(15) COLLATE Latin1_General_100_CI_AS_SC_UTF8,
    email VARCHAR(100) COLLATE Latin1_General_100_CI_AS_SC_UTF8
);

insert into MedicalStaff(first_name,last_name,role,specialization,phone_number,email) select 
								first_name, last_name
								,'Physician', specialty
								,phone_number, email
							from Doctors
insert into MedicalStaff(first_name,last_name,role,specialization,phone_number,email) select 
								first_name, last_name
								,'Nurse', 'N/A'
								,phone_number, email
							from Nurses
select * from Nurses
select * from Doctors
select * from MedicalStaff
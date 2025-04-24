--*******************************************************************
--*******************************************************************

--      Window Function - Average length of stay, Ranking by age, Grouping by age, Moving average

select top 1 AVG(DATEDIFF(DAY, admission_date, discharge_date)) over() [Average Length of Stay] from Patients

select first_name,last_name, DATEDIFF(YEAR,dob,GETDATE()) as Age, ROW_NUMBER() over(order by dob) as age_rank  from Patients


select first_name,last_name, DATEDIFF(YEAR,dob,GETDATE()) as Age, NTILE(4) over(order by dob) as age_quartile  from Patients

select 
		admission_date
		,COUNT(*) as registration_on_date
		,AVG(COUNT(*)) over (order by admission_date
							rows between 6 preceding and current row) as seven_day_moving_avg

from Admissions
group by admission_date
--********************************************************************
--       Window Function, Trigger, Common Table Expression
--********************************************************************

--********************************************************************
--Implementing Trigger
-- First, create the audit table to store the change history
CREATE TABLE PatientAudit (
    audit_id INT IDENTITY(1,1) PRIMARY KEY,
    patient_id NVARCHAR(50) NOT NULL,
    field_name NVARCHAR(100) NOT NULL,
    old_value NVARCHAR(MAX) NULL,
    new_value NVARCHAR(MAX) NULL,
    modified_by NVARCHAR(100) NULL,
    modified_date DATETIME NOT NULL DEFAULT GETDATE(),
    operation_type CHAR(1) NOT NULL, -- 'I' = Insert, 'U' = Update, 'D' = Delete
    workstation NVARCHAR(100) NULL
);
GO
select * from PatientAudit

-- Create the trigger to track updates to patient records
CREATE TRIGGER trg_PatientAudit
ON Patients
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @operation_type CHAR(1);
    
    -- Determine the operation type
    IF EXISTS (SELECT * FROM inserted) AND EXISTS (SELECT * FROM deleted)
        SET @operation_type = 'U'; -- Update
    ELSE IF EXISTS (SELECT * FROM inserted)
        SET @operation_type = 'I'; -- Insert
    ELSE
        SET @operation_type = 'D'; -- Delete
    
    -- Get the current user and workstation
    DECLARE @modified_by NVARCHAR(100) = SUSER_SNAME();
    DECLARE @workstation NVARCHAR(100) = HOST_NAME();
    
    -- Handle INSERT operations
    IF @operation_type = 'I'
    BEGIN
        INSERT INTO PatientAudit (
            patient_id, field_name, old_value, new_value, 
            modified_by, modified_date, operation_type, workstation
        )
        SELECT
            i.patient_id,
            'RECORD CREATED',
            NULL,
            'New patient record created',
            @modified_by,
            GETDATE(),
            @operation_type,
            @workstation
        FROM
            inserted i;
    END
    
    -- Handle DELETE operations
    ELSE IF @operation_type = 'D'
    BEGIN
        INSERT INTO PatientAudit (
            patient_id, field_name, old_value, new_value, 
            modified_by, modified_date, operation_type, workstation
        )
        SELECT
            d.patient_id,
            'RECORD DELETED',
            'Patient record deleted',
            NULL,
            @modified_by,
            GETDATE(),
            @operation_type,
            @workstation
        FROM
            deleted d;
    END
    
    -- Handle UPDATE operations
    ELSE IF @operation_type = 'U'
    BEGIN
        -- Audit changes to patient_id
        IF UPDATE(patient_id)
        BEGIN
            INSERT INTO PatientAudit (
                patient_id, field_name, old_value, new_value, 
                modified_by, modified_date, operation_type, workstation
            )
            SELECT
                d.patient_id,
                'patient_id',
                d.patient_id,
                i.patient_id,
                @modified_by,
                GETDATE(),
                @operation_type,
                @workstation
            FROM
                deleted d
                INNER JOIN inserted i ON d.patient_id = i.patient_id
            WHERE
                d.patient_id <> i.patient_id;
        END
        
        -- Audit changes to first_name
        IF UPDATE(first_name)
        BEGIN
            INSERT INTO PatientAudit (
                patient_id, field_name, old_value, new_value, 
                modified_by, modified_date, operation_type, workstation
            )
            SELECT
                i.patient_id,
                'first_name',
                d.first_name,
                i.first_name,
                @modified_by,
                GETDATE(),
                @operation_type,
                @workstation
            FROM
                deleted d
                INNER JOIN inserted i ON d.patient_id = i.patient_id
            WHERE
                ISNULL(d.first_name, '') <> ISNULL(i.first_name, '');
        END
        
        -- Audit changes to last_name
        IF UPDATE(last_name)
        BEGIN
            INSERT INTO PatientAudit (
                patient_id, field_name, old_value, new_value, 
                modified_by, modified_date, operation_type, workstation
            )
            SELECT
                i.patient_id,
                'last_name',
                d.last_name,
                i.last_name,
                @modified_by,
                GETDATE(),
                @operation_type,
                @workstation
            FROM
                deleted d
                INNER JOIN inserted i ON d.patient_id = i.patient_id
            WHERE
                ISNULL(d.last_name, '') <> ISNULL(i.last_name, '');
        END
        
        -- Audit changes to dob
        IF UPDATE(dob)
        BEGIN
            INSERT INTO PatientAudit (
                patient_id, field_name, old_value, new_value, 
                modified_by, modified_date, operation_type, workstation
            )
            SELECT
                i.patient_id,
                'dob',
                CONVERT(NVARCHAR(50), d.dob, 120),
                CONVERT(NVARCHAR(50), i.dob, 120),
                @modified_by,
                GETDATE(),
                @operation_type,
                @workstation
            FROM
                deleted d
                INNER JOIN inserted i ON d.patient_id = i.patient_id
            WHERE
                ISNULL(d.dob, '') <> ISNULL(i.dob, '');
        END
        
        -- Continue with similar blocks for other columns...
        -- For brevity, I'm showing a few more important fields:
        
        -- Audit changes to phone_number
        IF UPDATE(phone_number)
        BEGIN
            INSERT INTO PatientAudit (
                patient_id, field_name, old_value, new_value, 
                modified_by, modified_date, operation_type, workstation
            )
            SELECT
                i.patient_id,
                'phone_number',
                d.phone_number,
                i.phone_number,
                @modified_by,
                GETDATE(),
                @operation_type,
                @workstation
            FROM
                deleted d
                INNER JOIN inserted i ON d.patient_id = i.patient_id
            WHERE
                ISNULL(d.phone_number, '') <> ISNULL(i.phone_number, '');
        END
        
        -- Audit changes to email
        IF UPDATE(email)
        BEGIN
            INSERT INTO PatientAudit (
                patient_id, field_name, old_value, new_value, 
                modified_by, modified_date, operation_type, workstation
            )
            SELECT
                i.patient_id,
                'email',
                d.email,
                i.email,
                @modified_by,
                GETDATE(),
                @operation_type,
                @workstation
            FROM
                deleted d
                INNER JOIN inserted i ON d.patient_id = i.patient_id
            WHERE
                ISNULL(d.email, '') <> ISNULL(i.email, '');
        END
        
        -- Audit changes to diagnosis
        IF UPDATE(diagnosis)
        BEGIN
            INSERT INTO PatientAudit (
                patient_id, field_name, old_value, new_value, 
                modified_by, modified_date, operation_type, workstation
            )
            SELECT
                i.patient_id,
                'diagnosis',
                d.diagnosis,
                i.diagnosis,
                @modified_by,
                GETDATE(),
                @operation_type,
                @workstation
            FROM
                deleted d
                INNER JOIN inserted i ON d.patient_id = i.patient_id
            WHERE
                ISNULL(d.diagnosis, '') <> ISNULL(i.diagnosis, '');
        END
        
        -- Audit changes to medications
        IF UPDATE(medications)
        BEGIN
            INSERT INTO PatientAudit (
                patient_id, field_name, old_value, new_value, 
                modified_by, modified_date, operation_type, workstation
            )
            SELECT
                i.patient_id,
                'medications',
                d.medications,
                i.medications,
                @modified_by,
                GETDATE(),
                @operation_type,
                @workstation
            FROM
                deleted d
                INNER JOIN inserted i ON d.patient_id = i.patient_id
            WHERE
                ISNULL(d.medications, '') <> ISNULL(i.medications, '');
        END
        
        -- Add more IF UPDATE blocks for each column you want to track
        
    END
END;
GO

-- Add a comment to the trigger for documentation
EXEC sp_addextendedproperty 
    @name = N'MS_Description', 
    @value = N'Tracks changes to patient records and logs them in the PatientAudit table',
    @level0type = N'SCHEMA', @level0name = N'dbo',
    @level1type = N'TABLE', @level1name = N'Patients',
    @level2type = N'TRIGGER', @level2name = N'trg_PatientAudit';
GO

-- Create a view to easily retrieve and analyze audit records

ALTER TABLE PatientAudit ALTER COLUMN patient_id NVARCHAR(50) COLLATE SQL_Latin1_General_CP1_CI_AS;

-- First drop the existing view if it exists
IF EXISTS (SELECT * FROM sys.views WHERE name = 'vw_PatientAuditTrail')
    DROP VIEW vw_PatientAuditTrail;
GO

-- Create a view to easily retrieve and analyze audit records
-- First drop the existing view if it exists
IF EXISTS (SELECT * FROM sys.views WHERE name = 'vw_PatientAuditTrail')
    DROP VIEW vw_PatientAuditTrail;
GO

-- Create a view to easily retrieve and analyze audit records
CREATE VIEW vw_PatientAuditTrail AS
SELECT 
    a.audit_id,
    a.patient_id,
    p.first_name + ' ' + p.last_name AS patient_name,
    a.field_name,
    a.old_value,
    a.new_value,
    a.modified_by,
    a.modified_date,
    CASE a.operation_type
        WHEN 'I' THEN 'Insert'
        WHEN 'U' THEN 'Update'
        WHEN 'D' THEN 'Delete'
    END AS operation_type,
    a.workstation
FROM 
    PatientAudit a
LEFT JOIN 
    Patients p ON CAST(a.patient_id AS NVARCHAR(50)) COLLATE SQL_Latin1_General_CP1_CI_AS = p.patient_id;
GO


-- Testing
-- First, make sure there's a test patient
-- If you don't have test data, add a test patient
INSERT INTO Patients (
    patient_id, first_name, last_name, dob, gender, phone_number, email
)
VALUES (
    'P99999', 'Test', 'Patient', '1980-01-01', 'Female', '555-123-4567', 'test@example.com'
);

-- Test 1: Update a patient record to see the trigger work
UPDATE Patients
SET 
    phone_number = '555-987-6543',
    email = 'updated@example.com',
    diagnosis = 'Common cold'
WHERE 
    patient_id = 'P99999';

-- Test 2: Check the audit trail
SELECT * FROM PatientAudit
WHERE patient_id = 'P99999'
ORDER BY modified_date DESC;

-- Test 3: Use the view to see the audit trail in a more readable format
SELECT * FROM vw_PatientAuditTrail
WHERE patient_id = 'P99999'
ORDER BY modified_date DESC;

-- Test 4: Update multiple fields to see multiple audit entries
UPDATE Patients
SET 
    medications = 'Aspirin 325mg',
    address = '123 Main St',
    city = 'Springfield',
    state = 'IL'
WHERE 
    patient_id = 'P99999';

-- Test 5: Check the new audit entries
SELECT * FROM vw_PatientAuditTrail
WHERE patient_id = 'P99999'
ORDER BY modified_date DESC;

-- Test 6: Delete a patient to test delete tracking
-- Note: Only run this if you're using a test database or if you want to delete the test patient
/*
DELETE FROM Patients
WHERE patient_id = 'P99999';

-- Test 7: Check that the delete was recorded
SELECT * FROM vw_PatientAuditTrail
WHERE patient_id = 'P99999'
ORDER BY modified_date DESC;
*/


--*****************************************************************************
--*****************************************************************************

-- Function to find family relationships using recursive CTEs
CREATE FUNCTION dbo.fn_GetFamilyNetwork (@PatientID NVARCHAR(50))
RETURNS TABLE
AS
RETURN
(
    WITH FamilyNetwork AS
    (
        -- Base case: Start with the specified patient
        SELECT 
            p.patient_id,
            p.first_name,
            p.last_name,
            p.emergency_contact_name,
            p.emergency_contact_relationship,
            p.emergency_contact_phone,
            0 AS relationship_level,
            CAST(p.first_name + ' ' + p.last_name AS NVARCHAR(200)) AS relationship_path
        FROM 
            Patients p
        WHERE 
            p.patient_id = @PatientID
        
        UNION ALL
        
        -- Recursive part: Find patients who have the current patient as their emergency contact
        SELECT 
            p.patient_id,
            p.first_name,
            p.last_name,
            p.emergency_contact_name,
            p.emergency_contact_relationship,
            p.emergency_contact_phone,
            fn.relationship_level + 1,
            CAST(fn.relationship_path + ' → ' + p.first_name + ' ' + p.last_name AS NVARCHAR(200))
        FROM 
            Patients p
        INNER JOIN 
            FamilyNetwork fn 
        ON 
            -- Match on either full name or phone number of emergency contact
            (p.emergency_contact_name = fn.first_name + ' ' + fn.last_name 
            OR p.emergency_contact_phone = fn.emergency_contact_phone) 
            AND p.patient_id <> fn.patient_id -- Avoid self-references
    )
    SELECT * FROM FamilyNetwork
);
GO

-- Now, let's create a procedure that uses this function to show family networks
CREATE PROCEDURE sp_ShowFamilyRelationships
    @PatientID NVARCHAR(50) = NULL,
    @RelationshipType NVARCHAR(50) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    -- If no patient ID is provided, find patients in family groups
    IF @PatientID IS NULL
    BEGIN
        -- Find all patient pairs that are emergency contacts for each other
        WITH MutualContacts AS (
            SELECT 
                p1.patient_id AS patient1_id,
                p1.first_name + ' ' + p1.last_name AS patient1_name,
                p1.emergency_contact_name AS patient1_emergency_contact,
                p1.emergency_contact_relationship AS patient1_relationship,
                p2.patient_id AS patient2_id,
                p2.first_name + ' ' + p2.last_name AS patient2_name
            FROM 
                Patients p1
            JOIN 
                Patients p2 
            ON 
                (p1.emergency_contact_name = p2.first_name + ' ' + p2.last_name
                OR p1.emergency_contact_phone = p2.phone_number)
            WHERE
                p1.patient_id <> p2.patient_id
        )
        SELECT 
            patient1_id,
            patient1_name,
            patient1_emergency_contact,
            patient1_relationship,
            patient2_id,
            patient2_name,
            'Mutual Emergency Contacts' AS relationship_type
        FROM 
            MutualContacts
        WHERE 
            @RelationshipType IS NULL OR patient1_relationship = @RelationshipType
        ORDER BY 
            patient1_name;
    END
    ELSE
    BEGIN
        -- Show the family network for the specified patient
        SELECT 
            fn.patient_id,
            fn.first_name,
            fn.last_name,
            fn.emergency_contact_name,
            fn.emergency_contact_relationship,
            fn.emergency_contact_phone,
            fn.relationship_level,
            CASE 
                WHEN fn.relationship_level = 0 THEN 'Primary Patient'
                WHEN fn.relationship_level = 1 THEN 'Direct Contact'
                ELSE 'Extended Family Member (Level ' + CAST(fn.relationship_level AS NVARCHAR(10)) + ')'
            END AS relationship_description,
            fn.relationship_path
        FROM 
            dbo.fn_GetFamilyNetwork(@PatientID) fn
        WHERE 
            @RelationshipType IS NULL OR fn.emergency_contact_relationship = @RelationshipType
        ORDER BY 
            fn.relationship_level, fn.first_name, fn.last_name;
    END
END;
GO

-- Examples of how to use the procedure:

-- 1. View all family relationships for a specific patient
-- EXEC sp_ShowFamilyRelationships @PatientID = 'P12345';

-- 2. View only spouse relationships for a specific patient
-- EXEC sp_ShowFamilyRelationships @PatientID = 'P12345', @RelationshipType = 'Spouse';

-- 3. View all mutual emergency contacts in the system
-- EXEC sp_ShowFamilyRelationships;

-- 4. View all parent-child relationships in the system
-- EXEC sp_ShowFamilyRelationships @RelationshipType = 'Parent';

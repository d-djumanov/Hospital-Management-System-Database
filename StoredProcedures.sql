
--********************************************************************
--                           Stored Procedures
--********************************************************************

--Loading Data Into Patients Table

CREATE PROCEDURE sp_LoadPatientsFromERP
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- Insert only records that don't already exist in the Patients table
        INSERT INTO Patients (
            patient_id, first_name, last_name, dob, gender, address, city, state, 
            postal_code, phone_number, email, insurance_provider, insurance_policy_number, 
            blood_type, allergies, medications, diagnosis, admission_date, discharge_date,
            emergency_contact_name, emergency_contact_phone, emergency_contact_relationship,
            insurance_expiration_date, blood_pressure, heart_rate, weight, height, temperature
        )
        SELECT 
            erp.patient_id, erp.first_name, erp.last_name, erp.dob, erp.gender, erp.address, 
            erp.city, erp.state, erp.postal_code, erp.phone_number, erp.email, 
            erp.insurance_provider, erp.insurance_policy_number, erp.blood_type, 
            erp.allergies, erp.medications, erp.diagnosis, erp.admission_date, 
            erp.discharge_date, erp.emergency_contact_name, erp.emergency_contact_phone, 
            erp.emergency_contact_relationship, erp.insurance_expiration_date, 
            erp.blood_pressure, erp.heart_rate, erp.weight, erp.height, erp.temperature
        FROM 
            ERP_Master_Patient erp
        WHERE 
            NOT EXISTS (
                SELECT 1 
                FROM Patients p 
                WHERE p.patient_id = erp.patient_id
            );
            
        -- Log the number of new records inserted
        DECLARE @RowCount INT = @@ROWCOUNT;
        
        -- SQL Server specific output
        RAISERROR('Inserted %d new patient records.', 0, 1, @RowCount) WITH NOWAIT;
        
        COMMIT TRANSACTION;
        
        -- Return success code
        RETURN 0;
    END TRY
    BEGIN CATCH
        -- Rollback transaction in case of error
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
            
        -- Get error information using SQL Server specific functions
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorLine INT = ERROR_LINE();
        DECLARE @ErrorProcedure NVARCHAR(200) = ISNULL(ERROR_PROCEDURE(), '-');
        
        -- Log the error using SQL Server specific method
        RAISERROR('Error in %s (Line %d): %s', 16, 1, @ErrorProcedure, @ErrorLine, @ErrorMessage);
        
        -- Return error code
        RETURN -1;
    END CATCH
END;
GO

-- Add extended properties for documentation
EXEC sp_addextendedproperty 
    @name = N'MS_Description', 
    @value = N'Loads patient data from ERP_Master_Patient table into Patients table, avoiding duplicates',
    @level0type = N'SCHEMA', @level0name = N'dbo',
    @level1type = N'PROCEDURE', @level1name = N'sp_LoadPatientsFromERP';


--********************************************************************

-- Update Patient Information

CREATE PROCEDURE sp_UpdatePatientInformation
    @patient_id NVARCHAR(50),
    @first_name NVARCHAR(50) = NULL,
    @last_name NVARCHAR(50) = NULL,
    @dob DATE = NULL,
    @gender NVARCHAR(10) = NULL,
    @address NVARCHAR(100) = NULL,
    @city NVARCHAR(50) = NULL,
    @state NVARCHAR(50) = NULL,
    @postal_code NVARCHAR(20) = NULL,
    @phone_number NVARCHAR(20) = NULL,
    @email NVARCHAR(100) = NULL,
    @insurance_provider NVARCHAR(50) = NULL,
    @insurance_policy_number NVARCHAR(50) = NULL,
    @blood_type NVARCHAR(10) = NULL,
    @allergies NVARCHAR(MAX) = NULL,
    @medications NVARCHAR(MAX) = NULL,
    @diagnosis NVARCHAR(MAX) = NULL,
    @emergency_contact_name NVARCHAR(100) = NULL,
    @emergency_contact_phone NVARCHAR(20) = NULL,
    @emergency_contact_relationship NVARCHAR(50) = NULL,
    @insurance_expiration_date DATE = NULL,
    @blood_pressure DECIMAL(5,2) = NULL,
    @heart_rate INT = NULL,
    @weight DECIMAL(5,2) = NULL,
    @height DECIMAL(5,2) = NULL,
    @temperature DECIMAL(5,2) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        -- Check if patient exists
        IF NOT EXISTS (SELECT 1 FROM Patients WHERE patient_id = @patient_id)
        BEGIN
            RAISERROR('Patient with ID %s does not exist.', 16, 1, @patient_id);
            RETURN -1;
        END
        
        BEGIN TRANSACTION;
        
        -- Build dynamic SQL to update only the provided fields
        DECLARE @SQL NVARCHAR(MAX) = 'UPDATE Patients SET ';
        DECLARE @ParamCount INT = 0;
        
        -- For each parameter, check if it's provided and add it to the update statement
        IF @first_name IS NOT NULL 
        BEGIN
            SET @SQL = @SQL + 'first_name = @first_name, ';
            SET @ParamCount = @ParamCount + 1;
        END
        
        IF @last_name IS NOT NULL 
        BEGIN
            SET @SQL = @SQL + 'last_name = @last_name, ';
            SET @ParamCount = @ParamCount + 1;
        END
        
        IF @dob IS NOT NULL 
        BEGIN
            SET @SQL = @SQL + 'dob = @dob, ';
            SET @ParamCount = @ParamCount + 1;
        END
        
        IF @gender IS NOT NULL 
        BEGIN
            SET @SQL = @SQL + 'gender = @gender, ';
            SET @ParamCount = @ParamCount + 1;
        END
        
        IF @address IS NOT NULL 
        BEGIN
            SET @SQL = @SQL + 'address = @address, ';
            SET @ParamCount = @ParamCount + 1;
        END
        
        IF @city IS NOT NULL 
        BEGIN
            SET @SQL = @SQL + 'city = @city, ';
            SET @ParamCount = @ParamCount + 1;
        END
        
        IF @state IS NOT NULL 
        BEGIN
            SET @SQL = @SQL + 'state = @state, ';
            SET @ParamCount = @ParamCount + 1;
        END
        
        IF @postal_code IS NOT NULL 
        BEGIN
            SET @SQL = @SQL + 'postal_code = @postal_code, ';
            SET @ParamCount = @ParamCount + 1;
        END
        
        IF @phone_number IS NOT NULL 
        BEGIN
            SET @SQL = @SQL + 'phone_number = @phone_number, ';
            SET @ParamCount = @ParamCount + 1;
        END
        
        IF @email IS NOT NULL 
        BEGIN
            SET @SQL = @SQL + 'email = @email, ';
            SET @ParamCount = @ParamCount + 1;
        END
        
        IF @insurance_provider IS NOT NULL 
        BEGIN
            SET @SQL = @SQL + 'insurance_provider = @insurance_provider, ';
            SET @ParamCount = @ParamCount + 1;
        END
        
        IF @insurance_policy_number IS NOT NULL 
        BEGIN
            SET @SQL = @SQL + 'insurance_policy_number = @insurance_policy_number, ';
            SET @ParamCount = @ParamCount + 1;
        END
        
        IF @blood_type IS NOT NULL 
        BEGIN
            SET @SQL = @SQL + 'blood_type = @blood_type, ';
            SET @ParamCount = @ParamCount + 1;
        END
        
        IF @allergies IS NOT NULL 
        BEGIN
            SET @SQL = @SQL + 'allergies = @allergies, ';
            SET @ParamCount = @ParamCount + 1;
        END
        
        IF @medications IS NOT NULL 
        BEGIN
            SET @SQL = @SQL + 'medications = @medications, ';
            SET @ParamCount = @ParamCount + 1;
        END
        
        IF @diagnosis IS NOT NULL 
        BEGIN
            SET @SQL = @SQL + 'diagnosis = @diagnosis, ';
            SET @ParamCount = @ParamCount + 1;
        END
        
        IF @emergency_contact_name IS NOT NULL 
        BEGIN
            SET @SQL = @SQL + 'emergency_contact_name = @emergency_contact_name, ';
            SET @ParamCount = @ParamCount + 1;
        END
        
        IF @emergency_contact_phone IS NOT NULL 
        BEGIN
            SET @SQL = @SQL + 'emergency_contact_phone = @emergency_contact_phone, ';
            SET @ParamCount = @ParamCount + 1;
        END
        
        IF @emergency_contact_relationship IS NOT NULL 
        BEGIN
            SET @SQL = @SQL + 'emergency_contact_relationship = @emergency_contact_relationship, ';
            SET @ParamCount = @ParamCount + 1;
        END
        
        IF @insurance_expiration_date IS NOT NULL 
        BEGIN
            SET @SQL = @SQL + 'insurance_expiration_date = @insurance_expiration_date, ';
            SET @ParamCount = @ParamCount + 1;
        END
        
        IF @blood_pressure IS NOT NULL 
        BEGIN
            SET @SQL = @SQL + 'blood_pressure = @blood_pressure, ';
            SET @ParamCount = @ParamCount + 1;
        END
        
        IF @heart_rate IS NOT NULL 
        BEGIN
            SET @SQL = @SQL + 'heart_rate = @heart_rate, ';
            SET @ParamCount = @ParamCount + 1;
        END
        
        IF @weight IS NOT NULL 
        BEGIN
            SET @SQL = @SQL + 'weight = @weight, ';
            SET @ParamCount = @ParamCount + 1;
        END
        
        IF @height IS NOT NULL 
        BEGIN
            SET @SQL = @SQL + 'height = @height, ';
            SET @ParamCount = @ParamCount + 1;
        END
        
        IF @temperature IS NOT NULL 
        BEGIN
            SET @SQL = @SQL + 'temperature = @temperature, ';
            SET @ParamCount = @ParamCount + 1;
        END
        
        -- Check if any parameters were provided for update
        IF @ParamCount = 0
        BEGIN
            ROLLBACK TRANSACTION;
            RAISERROR('No parameters provided for update.', 16, 1);
            RETURN -2;
        END
        
        -- Remove the trailing comma and space
        SET @SQL = LEFT(@SQL, LEN(@SQL) - 1);
        
        -- Add the WHERE clause for patient_id
        SET @SQL = @SQL + ' WHERE patient_id = @patient_id';
        
        -- Execute the dynamic SQL
        EXEC sp_executesql @SQL, 
            N'@patient_id NVARCHAR(50), @first_name NVARCHAR(50), @last_name NVARCHAR(50), 
            @dob DATE, @gender NVARCHAR(10), @address NVARCHAR(100), @city NVARCHAR(50), 
            @state NVARCHAR(50), @postal_code NVARCHAR(20), @phone_number NVARCHAR(20), 
            @email NVARCHAR(100), @insurance_provider NVARCHAR(50), 
            @insurance_policy_number NVARCHAR(50), @blood_type NVARCHAR(10), 
            @allergies NVARCHAR(MAX), @medications NVARCHAR(MAX), @diagnosis NVARCHAR(MAX), 
            @emergency_contact_name NVARCHAR(100), @emergency_contact_phone NVARCHAR(20), 
            @emergency_contact_relationship NVARCHAR(50), @insurance_expiration_date DATE, 
            @blood_pressure DECIMAL(5,2), @heart_rate INT, @weight DECIMAL(5,2), 
            @height DECIMAL(5,2), @temperature DECIMAL(5,2)',
            @patient_id, @first_name, @last_name, @dob, @gender, @address, @city, @state, 
            @postal_code, @phone_number, @email, @insurance_provider, @insurance_policy_number, 
            @blood_type, @allergies, @medications, @diagnosis, @emergency_contact_name, 
            @emergency_contact_phone, @emergency_contact_relationship, @insurance_expiration_date, 
            @blood_pressure, @heart_rate, @weight, @height, @temperature;
            
        -- Check if the update actually changed anything
        IF @@ROWCOUNT = 0
        BEGIN
            ROLLBACK TRANSACTION;
            RAISERROR('Update failed: No records affected.', 16, 1);
            RETURN -3;
        END
        
        COMMIT TRANSACTION;
        
        RAISERROR('Patient information updated successfully.', 0, 1) WITH NOWAIT;
        RETURN 0;
    END TRY
    BEGIN CATCH
        -- Rollback transaction in case of error
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
            
        -- Get error information
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorLine INT = ERROR_LINE();
        DECLARE @ErrorProcedure NVARCHAR(200) = ISNULL(ERROR_PROCEDURE(), '-');
        
        -- Log the error
        RAISERROR('Error in %s (Line %d): %s', 16, 1, @ErrorProcedure, @ErrorLine, @ErrorMessage);
        
        -- Return error code
        RETURN -999;
    END CATCH
END;
GO

-- Add extended properties for documentation
EXEC sp_addextendedproperty 
    @name = N'MS_Description', 
    @value = N'Updates patient information for a specific patient ID. Only the provided parameters will be updated.',
    @level0type = N'SCHEMA', @level0name = N'dbo',
    @level1type = N'PROCEDURE', @level1name = N'sp_UpdatePatientInformation';


--*********************************************************************
-- Manage Billing Information

CREATE PROCEDURE sp_ManageBillingInformation
    @billing_id INT = NULL,                  -- NULL for new records, provide ID for updates
    @patient_id NVARCHAR(50),                -- Required
    @total_amount DECIMAL(10,2),             -- Required
    @amount_paid DECIMAL(10,2) = 0.00,       -- Default to zero for new bills
    @billing_date DATE = NULL,               -- Default to current date if not provided
    @due_date DATE = NULL,                   -- Required
    @payment_status NVARCHAR(20) = 'Pending',-- Default status
    @insurance_id SMALLINT = NULL,           -- Optional
    @billing_description NVARCHAR(MAX) = NULL,-- Optional
    @payment_method NVARCHAR(50) = NULL      -- Optional
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        -- Set default values if not provided
        SET @billing_date = ISNULL(@billing_date, GETDATE());
        
        -- Validate required parameters
        IF @patient_id IS NULL
        BEGIN
            RAISERROR('Patient ID is required.', 16, 1);
            RETURN -1;
        END
        
        IF @total_amount IS NULL OR @total_amount < 0
        BEGIN
            RAISERROR('Valid total amount is required.', 16, 1);
            RETURN -2;
        END
        
        IF @due_date IS NULL
        BEGIN
            RAISERROR('Due date is required.', 16, 1);
            RETURN -3;
        END
        
        -- Validate amount_paid doesn't exceed total_amount
        IF @amount_paid > @total_amount
        BEGIN
            RAISERROR('Amount paid cannot exceed total amount.', 16, 1);
            RETURN -4;
        END
        
        -- Validate patient exists
        IF NOT EXISTS (SELECT 1 FROM Patients WHERE patient_id = @patient_id)
        BEGIN
            RAISERROR('Patient with ID %s does not exist.', 16, 1, @patient_id);
            RETURN -5;
        END
        
        -- Validate insurance_id if provided
        IF @insurance_id IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Insurance WHERE insurance_id = @insurance_id)
        BEGIN
            RAISERROR('Insurance with ID %d does not exist.', 16, 1, @insurance_id);
            RETURN -6;
        END
        
        -- Validate insurance belongs to patient if both are provided
        IF @insurance_id IS NOT NULL AND EXISTS (
            SELECT 1 FROM Insurance 
            WHERE insurance_id = @insurance_id 
            AND patient_id <> @patient_id
        )
        BEGIN
            RAISERROR('Insurance ID %d does not belong to patient %s.', 16, 1, @insurance_id, @patient_id);
            RETURN -7;
        END
        
        -- Determine if this is a new record or an update
        DECLARE @IsUpdate BIT = 0;
        IF @billing_id IS NOT NULL AND EXISTS (SELECT 1 FROM Billing WHERE billing_id = @billing_id)
            SET @IsUpdate = 1;
            
        -- Begin transaction
        BEGIN TRANSACTION;
        
        -- Auto-calculate payment status based on amount_paid vs total_amount
        IF @amount_paid = 0
            SET @payment_status = 'Pending';
        ELSE IF @amount_paid < @total_amount
            SET @payment_status = 'Partial';
        ELSE IF @amount_paid = @total_amount
            SET @payment_status = 'Paid';
        
        -- Insert or update based on @IsUpdate flag
        IF @IsUpdate = 0
        BEGIN
            -- This is a new record, so insert
            INSERT INTO Billing (
                patient_id, total_amount, amount_paid, billing_date, due_date,
                payment_status, insurance_id, billing_description, payment_method
            )
            VALUES (
                @patient_id, @total_amount, @amount_paid, @billing_date, @due_date,
                @payment_status, @insurance_id, @billing_description, @payment_method
            );
            
            -- Get the new billing_id
            SET @billing_id = SCOPE_IDENTITY();
            
            RAISERROR('New billing record created with ID: %d', 0, 1, @billing_id) WITH NOWAIT;
        END
        ELSE
        BEGIN
            -- This is an update, so update existing record
            UPDATE Billing
            SET 
                patient_id = @patient_id,
                total_amount = @total_amount,
                amount_paid = @amount_paid,
                billing_date = @billing_date,
                due_date = @due_date,
                payment_status = @payment_status,
                insurance_id = @insurance_id,
                billing_description = @billing_description,
                payment_method = @payment_method
            WHERE billing_id = @billing_id;
            
            RAISERROR('Billing record with ID %d updated successfully.', 0, 1, @billing_id) WITH NOWAIT;
        END
        
        COMMIT TRANSACTION;
        
        -- Return the billing_id for reference
        RETURN @billing_id;
    END TRY
    BEGIN CATCH
        -- Rollback transaction in case of error
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
            
        -- Get error information
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorLine INT = ERROR_LINE();
        DECLARE @ErrorProcedure NVARCHAR(200) = ISNULL(ERROR_PROCEDURE(), '-');
        
        -- Log the error
        RAISERROR('Error in %s (Line %d): %s', 16, 1, @ErrorProcedure, @ErrorLine, @ErrorMessage);
        
        -- Return error code
        RETURN -999;
    END CATCH
END;
GO

-- Add extended properties for documentation
IF EXISTS (SELECT 1 FROM sys.fn_listextendedproperty(N'MS_Description', N'SCHEMA', N'dbo', N'PROCEDURE', N'sp_ManageBillingInformation', NULL, NULL))
    EXEC sp_dropextendedproperty 
        @name = N'MS_Description', 
        @level0type = N'SCHEMA', @level0name = N'dbo',
        @level1type = N'PROCEDURE', @level1name = N'sp_ManageBillingInformation';
GO

EXEC sp_addextendedproperty 
    @name = N'MS_Description', 
    @value = N'Inserts new billing records or updates existing ones with validation of patient and insurance data.',
    @level0type = N'SCHEMA', @level0name = N'dbo',
    @level1type = N'PROCEDURE', @level1name = N'sp_ManageBillingInformation';


--***********************************************************************
-- Allocate Room to Patient

CREATE PROCEDURE sp_AllocateRoomToPatient
    @patient_id NVARCHAR(50),            -- Required: Patient to allocate room to
    @admission_date DATETIME = NULL,     -- Optional: Default to current date/time
    @discharge_date DATETIME = NULL,     -- Optional: For planned stays
    @doctor_id INT,                       -- Required: Assigned doctor
    @nurse_id INT,                        -- Required: Assigned nurse
    @diagnosis NVARCHAR(MAX) = NULL,      -- Optional: Patient diagnosis
    @room_type NVARCHAR(50) = NULL,       -- Optional: Preferred room type
    @room_number INT = NULL,              -- Optional: Specific room requested
    @admission_id INT = NULL OUTPUT       -- Output: Generated admission ID
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        -- Initialize variables
        SET @admission_date = ISNULL(@admission_date, GETDATE());
        DECLARE @allocated_room INT;
        
        -- Validate required parameters
        IF @patient_id IS NULL
        BEGIN
            RAISERROR('Patient ID is required.', 16, 1);
            RETURN -1;
        END
        
        IF @doctor_id IS NULL
        BEGIN
            RAISERROR('Doctor ID is required.', 16, 1);
            RETURN -2;
        END
        
        IF @nurse_id IS NULL
        BEGIN
            RAISERROR('Nurse ID is required.', 16, 1);
            RETURN -3;
        END
        
        -- Validate patient exists
        IF NOT EXISTS (SELECT 1 FROM Patients WHERE patient_id = @patient_id)
        BEGIN
            RAISERROR('Patient with ID %s does not exist.', 16, 1, @patient_id);
            RETURN -4;
        END
        
        -- Validate doctor exists
        IF NOT EXISTS (SELECT 1 FROM Doctors WHERE doctor_id = @doctor_id)
        BEGIN
            RAISERROR('Doctor with ID %d does not exist.', 16, 1, @doctor_id);
            RETURN -5;
        END
        
        -- Validate nurse exists
        IF NOT EXISTS (SELECT 1 FROM Nurses WHERE nurse_id = @nurse_id)
        BEGIN
            RAISERROR('Nurse with ID %d does not exist.', 16, 1, @nurse_id);
            RETURN -6;
        END
        
        -- Check if patient is already admitted and not discharged
        IF EXISTS (
            SELECT 1 
            FROM Admissions 
            WHERE patient_id = @patient_id 
            AND discharge_date IS NULL
        )
        BEGIN
            RAISERROR('Patient %s is already admitted and not discharged.', 16, 1, @patient_id);
            RETURN -7;
        END
        
        -- Begin transaction
        BEGIN TRANSACTION;
        
        -- Room allocation logic
        IF @room_number IS NOT NULL
        BEGIN
            -- Specific room requested, check if it's available
            IF NOT EXISTS (SELECT 1 FROM Rooms WHERE room_number = @room_number)
            BEGIN
                ROLLBACK TRANSACTION;
                RAISERROR('Room %d does not exist.', 16, 1, @room_number);
                RETURN -8;
            END
            
            IF NOT EXISTS (SELECT 1 FROM Rooms WHERE room_number = @room_number AND is_available = 1)
            BEGIN
                ROLLBACK TRANSACTION;
                RAISERROR('Room %d is not available.', 16, 1, @room_number);
                RETURN -9;
            END
            
            -- Specific room is available, allocate it
            SET @allocated_room = @room_number;
        END
        ELSE
        BEGIN
            -- Find available room of requested type or any available room
            IF @room_type IS NOT NULL
            BEGIN
                -- Try to find room of specific type
                SELECT TOP 1 @allocated_room = room_number
                FROM Rooms
                WHERE room_type = @room_type 
                AND is_available = 1
                AND current_occupancy < capacity
                ORDER BY room_number;
                
                -- If no room of requested type is available, return error
                IF @allocated_room IS NULL
                BEGIN
                    ROLLBACK TRANSACTION;
                    RAISERROR('No available rooms of type %s.', 16, 1, @room_type);
                    RETURN -10;
                END
            END
            ELSE
            BEGIN
                -- Find any available room
                SELECT TOP 1 @allocated_room = room_number
                FROM Rooms
                WHERE is_available = 1
                AND current_occupancy < capacity
                ORDER BY room_number;
                
                -- If no room is available at all
                IF @allocated_room IS NULL
                BEGIN
                    ROLLBACK TRANSACTION;
                    RAISERROR('No available rooms in the hospital.', 16, 1);
                    RETURN -11;
                END
            END
        END
        
        -- Update room occupancy
        UPDATE Rooms
        SET 
            current_occupancy = current_occupancy + 1,
            is_available = CASE 
                            WHEN (current_occupancy + 1) >= capacity THEN 0
                            ELSE 1
                           END
        WHERE room_number = @allocated_room;
        
        -- Create admission record
        INSERT INTO Admissions (
            patient_id,
            admission_date,
            discharge_date,
            doctor_id,
            nurse_id,
            room_number,
            diagnosis
        )
        VALUES (
            @patient_id,
            @admission_date,
            @discharge_date,
            @doctor_id,
            @nurse_id,
            @allocated_room,
            @diagnosis
        );
        
        -- Get the admission ID
        SET @admission_id = SCOPE_IDENTITY();
        
        -- Update patient info in Patients table
        UPDATE Patients
        SET 
            admission_date = @admission_date,
            discharge_date = @discharge_date
        WHERE patient_id = @patient_id;
        
        COMMIT TRANSACTION;
        
        -- Return success message
        RAISERROR('Patient %s admitted to room %d. Admission ID: %d', 0, 1, 
                 @patient_id, @allocated_room, @admission_id) WITH NOWAIT;
        
        -- Return the admission ID
        RETURN @admission_id;
    END TRY
    BEGIN CATCH
        -- Rollback transaction in case of error
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
            
        -- Get error information
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorLine INT = ERROR_LINE();
        DECLARE @ErrorProcedure NVARCHAR(200) = ISNULL(ERROR_PROCEDURE(), '-');
        
        -- Log the error
        RAISERROR('Error in %s (Line %d): %s', 16, 1, @ErrorProcedure, @ErrorLine, @ErrorMessage);
        
        -- Return error code
        RETURN -999;
    END CATCH
END;
GO

-- Add extended properties for documentation
IF EXISTS (SELECT 1 FROM sys.fn_listextendedproperty(N'MS_Description', N'SCHEMA', N'dbo', N'PROCEDURE', N'sp_AllocateRoomToPatient', NULL, NULL))
    EXEC sp_dropextendedproperty 
        @name = N'MS_Description', 
        @level0type = N'SCHEMA', @level0name = N'dbo',
        @level1type = N'PROCEDURE', @level1name = N'sp_AllocateRoomToPatient';
GO

EXEC sp_addextendedproperty 
    @name = N'MS_Description', 
    @value = N'Allocates a room to a patient upon admission, updates room occupancy, and creates admission record.',
    @level0type = N'SCHEMA', @level0name = N'dbo',
    @level1type = N'PROCEDURE', @level1name = N'sp_AllocateRoomToPatient';
GO



-- ***********************************************************************
-- Record Patient Discharge

CREATE PROCEDURE sp_RecordPatientDischarge
    @admission_id INT,                    -- Required: Admission to discharge
    @discharge_date DATETIME = NULL,      -- Optional: Default to current date/time
    @discharge_notes NVARCHAR(MAX) = NULL -- Optional: Notes about discharge
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        -- Initialize variables
        SET @discharge_date = ISNULL(@discharge_date, GETDATE());
        DECLARE @patient_id NVARCHAR(50);
        DECLARE @room_number INT;
        
        -- Validate required parameters
        IF @admission_id IS NULL
        BEGIN
            RAISERROR('Admission ID is required.', 16, 1);
            RETURN -1;
        END
        
        -- Check if admission exists
        IF NOT EXISTS (SELECT 1 FROM Admissions WHERE admission_id = @admission_id)
        BEGIN
            RAISERROR('Admission with ID %d does not exist.', 16, 1, @admission_id);
            RETURN -2;
        END
        
        -- Check if patient is already discharged
        IF EXISTS (
            SELECT 1 
            FROM Admissions 
            WHERE admission_id = @admission_id 
            AND discharge_date IS NOT NULL
        )
        BEGIN
            RAISERROR('Patient has already been discharged for admission ID %d.', 16, 1, @admission_id);
            RETURN -3;
        END
        
        -- Get patient_id and room_number for this admission
        SELECT 
            @patient_id = patient_id,
            @room_number = room_number
        FROM Admissions
        WHERE admission_id = @admission_id;
        
        -- Begin transaction
        BEGIN TRANSACTION;
        
        -- Update admission record with discharge date
        UPDATE Admissions
        SET 
            discharge_date = @discharge_date,
            diagnosis = CASE 
                          WHEN @discharge_notes IS NOT NULL AND diagnosis IS NOT NULL 
                          THEN diagnosis + ' | Discharge notes: ' + @discharge_notes
                          WHEN @discharge_notes IS NOT NULL 
                          THEN 'Discharge notes: ' + @discharge_notes
                          ELSE diagnosis
                        END
        WHERE admission_id = @admission_id;
        
        -- Update patient's discharge date in Patients table
        UPDATE Patients
        SET discharge_date = @discharge_date
        WHERE patient_id = @patient_id;
        
        -- Update room availability
        UPDATE Rooms
        SET 
            current_occupancy = current_occupancy - 1,
            is_available = 1  -- Room becomes available again
        WHERE room_number = @room_number;
        
        COMMIT TRANSACTION;
        
        -- Return success message
        RAISERROR('Patient discharged successfully from admission ID %d. Room %d is now available.', 0, 1, 
                 @admission_id, @room_number) WITH NOWAIT;
        
        -- Return success
        RETURN 0;
    END TRY
    BEGIN CATCH
        -- Rollback transaction in case of error
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
            
        -- Get error information
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorLine INT = ERROR_LINE();
        DECLARE @ErrorProcedure NVARCHAR(200) = ISNULL(ERROR_PROCEDURE(), '-');
        
        -- Log the error
        RAISERROR('Error in %s (Line %d): %s', 16, 1, @ErrorProcedure, @ErrorLine, @ErrorMessage);
        
        -- Return error code
        RETURN -999;
    END CATCH
END;
GO

-- Add extended properties for documentation
IF EXISTS (SELECT 1 FROM sys.fn_listextendedproperty(N'MS_Description', N'SCHEMA', N'dbo', N'PROCEDURE', N'sp_RecordPatientDischarge', NULL, NULL))
    EXEC sp_dropextendedproperty 
        @name = N'MS_Description', 
        @level0type = N'SCHEMA', @level0name = N'dbo',
        @level1type = N'PROCEDURE', @level1name = N'sp_RecordPatientDischarge';
GO

EXEC sp_addextendedproperty 
    @name = N'MS_Description', 
    @value = N'Records a patient discharge, updates the room availability, and records discharge information.',
    @level0type = N'SCHEMA', @level0name = N'dbo',
    @level1type = N'PROCEDURE', @level1name = N'sp_RecordPatientDischarge';
GO

--************************************************************************
-- Process Payment

CREATE PROCEDURE sp_ProcessPayment
    @billing_id INT,                     -- Required: Billing record to process payment for
    @payment_amount DECIMAL(10,2),       -- Required: Amount being paid
    @payment_method NVARCHAR(50),        -- Required: Method of payment (Cash, Credit Card, etc.)
    @payment_date DATETIME = NULL,       -- Optional: Default to current date/time
    @payment_reference NVARCHAR(100) = NULL  -- Optional: Reference number, check number, etc.
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        -- Initialize variables
        SET @payment_date = ISNULL(@payment_date, GETDATE());
        DECLARE @current_amount_paid DECIMAL(10,2);
        DECLARE @total_amount DECIMAL(10,2);
        DECLARE @new_amount_paid DECIMAL(10,2);
        DECLARE @patient_id NVARCHAR(50);
        DECLARE @new_payment_status NVARCHAR(20);
        
        -- Validate required parameters
        IF @billing_id IS NULL
        BEGIN
            RAISERROR('Billing ID is required.', 16, 1);
            RETURN -1;
        END
        
        IF @payment_amount IS NULL OR @payment_amount <= 0
        BEGIN
            RAISERROR('Valid payment amount is required.', 16, 1);
            RETURN -2;
        END
        
        IF @payment_method IS NULL
        BEGIN
            RAISERROR('Payment method is required.', 16, 1);
            RETURN -3;
        END
        
        -- Check if billing record exists
        IF NOT EXISTS (SELECT 1 FROM Billing WHERE billing_id = @billing_id)
        BEGIN
            RAISERROR('Billing record with ID %d does not exist.', 16, 1, @billing_id);
            RETURN -4;
        END
        
        -- Get current billing information
        SELECT 
            @current_amount_paid = amount_paid,
            @total_amount = total_amount,
            @patient_id = patient_id
        FROM Billing
        WHERE billing_id = @billing_id;
        
        -- Calculate new amount paid
        SET @new_amount_paid = @current_amount_paid + @payment_amount;
        
        -- Validate payment doesn't exceed total amount
        IF @new_amount_paid > @total_amount
        BEGIN
            DECLARE @payment_str NVARCHAR(50) = CONVERT(NVARCHAR(50), @payment_amount);
            DECLARE @total_str NVARCHAR(50) = CONVERT(NVARCHAR(50), @total_amount);
            DECLARE @current_paid_str NVARCHAR(50) = CONVERT(NVARCHAR(50), @current_amount_paid);
            
            RAISERROR('Payment amount of %s would exceed the total bill amount of %s. Current amount paid: %s', 
                     16, 1, @payment_str, @total_str, @current_paid_str);
            RETURN -5;
        END
        
        -- Determine new payment status
        IF @new_amount_paid = 0
            SET @new_payment_status = 'Pending';
        ELSE IF @new_amount_paid < @total_amount
            SET @new_payment_status = 'Partial';
        ELSE -- @new_amount_paid = @total_amount
            SET @new_payment_status = 'Paid';
        
        -- Begin transaction
        BEGIN TRANSACTION;
        
        -- Update billing record with new payment information
        UPDATE Billing
        SET 
            amount_paid = @new_amount_paid,
            payment_status = @new_payment_status,
            payment_method = CASE 
                               WHEN payment_method IS NULL THEN @payment_method
                               WHEN payment_method <> @payment_method THEN payment_method + ', ' + @payment_method
                               ELSE payment_method
                             END
        WHERE billing_id = @billing_id;
        
        -- Optional: Insert into a PaymentHistory table if one exists
        /* 
        INSERT INTO PaymentHistory (
            billing_id, 
            payment_amount, 
            payment_date, 
            payment_method, 
            payment_reference
        )
        VALUES (
            @billing_id,
            @payment_amount,
            @payment_date,
            @payment_method,
            @payment_reference
        );
        */
        
        COMMIT TRANSACTION;
        
        -- Return success message
        DECLARE @success_payment_str NVARCHAR(50) = CONVERT(NVARCHAR(50), @payment_amount);
        DECLARE @balance_str NVARCHAR(50) = CONVERT(NVARCHAR(50), (@total_amount - @new_amount_paid));
        
        RAISERROR('Payment of %s processed successfully for billing ID %d. New balance: %s', 
                 0, 1, @success_payment_str, @billing_id, @balance_str) WITH NOWAIT;
        
        -- Return success
        RETURN 0;
    END TRY
    BEGIN CATCH
        -- Rollback transaction in case of error
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
            
        -- Get error information
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorLine INT = ERROR_LINE();
        DECLARE @ErrorProcedure NVARCHAR(200) = ISNULL(ERROR_PROCEDURE(), '-');
        
        -- Log the error
        RAISERROR('Error in %s (Line %d): %s', 16, 1, @ErrorProcedure, @ErrorLine, @ErrorMessage);
        
        -- Return error code
        RETURN -999;
    END CATCH
END;
GO

-- Add extended properties for documentation
IF EXISTS (SELECT 1 FROM sys.fn_listextendedproperty(N'MS_Description', N'SCHEMA', N'dbo', N'PROCEDURE', N'sp_ProcessPayment', NULL, NULL))
    EXEC sp_dropextendedproperty 
        @name = N'MS_Description', 
        @level0type = N'SCHEMA', @level0name = N'dbo',
        @level1type = N'PROCEDURE', @level1name = N'sp_ProcessPayment';
GO

EXEC sp_addextendedproperty 
    @name = N'MS_Description', 
    @value = N'Processes a payment for a billing record, updates payment status and validates amount.',
    @level0type = N'SCHEMA', @level0name = N'dbo',
    @level1type = N'PROCEDURE', @level1name = N'sp_ProcessPayment';
GO

-- ********************************************************************************
-- ********************************************************************************
-- Procedure execution examples

-- =============================================
-- EXECUTE LOAD PATIENTS FROM ERP PROCEDURE
-- =============================================
-- Simple execution
EXEC sp_LoadPatientsFromERP;

-- Capture return value
DECLARE @LoadPatientsResult INT;
EXEC @LoadPatientsResult = sp_LoadPatientsFromERP;
SELECT @LoadPatientsResult AS 'Load Patients Result';

-- =============================================
-- EXECUTE UPDATE PATIENT INFORMATION PROCEDURE
-- =============================================
-- Update basic contact information
EXEC sp_UpdatePatientInformation 
    @patient_id = 'P12345',
    @phone_number = '555-123-4567',
    @email = 'patient@example.com';

-- Update medical information
EXEC sp_UpdatePatientInformation 
    @patient_id = 'P12345',
    @blood_pressure = 120.80,
    @heart_rate = 75,
    @medications = 'Lisinopril 10mg daily, Atorvastatin 20mg daily';

-- Update multiple fields with return value
DECLARE @UpdatePatientResult INT;
EXEC @UpdatePatientResult = sp_UpdatePatientInformation 
    @patient_id = 'P12345',
    @address = '123 Main St',
    @city = 'Springfield',
    @state = 'IL',
    @postal_code = '62701';
SELECT @UpdatePatientResult AS 'Update Patient Result';

-- =============================================
-- EXECUTE MANAGE BILLING INFORMATION PROCEDURE
-- =============================================
-- Create a new billing record
DECLARE @NewBillingID INT;
EXEC @NewBillingID = sp_ManageBillingInformation
    @patient_id = 'P12345',
    @total_amount = 1250.00,
    @due_date = '2025-04-15',
    @billing_description = 'Initial consultation and lab tests';
SELECT @NewBillingID AS 'New Billing ID';

-- Update an existing billing record
DECLARE @UpdateBillingResult INT;
EXEC @UpdateBillingResult = sp_ManageBillingInformation
    @billing_id = 1001,
    @patient_id = 'P12345',
    @total_amount = 1250.00,
    @amount_paid = 500.00,
    @billing_date = '2025-03-15',
    @due_date = '2025-04-15',
    @payment_method = 'Credit Card',
    @billing_description = 'Initial consultation and lab tests';
SELECT @UpdateBillingResult AS 'Update Billing Result';

-- =============================================
-- EXECUTE ALLOCATE ROOM TO PATIENT PROCEDURE
-- =============================================
-- Basic room allocation (system finds available room)
DECLARE @NewAdmissionID INT;
EXEC @NewAdmissionID = sp_AllocateRoomToPatient
    @patient_id = 'P12345',
    @doctor_id = 101,
    @nurse_id = 201,
    @diagnosis = 'Pneumonia',
    @admission_id = @NewAdmissionID OUTPUT;
SELECT @NewAdmissionID AS 'New Admission ID';

-- Request a specific room type
DECLARE @AdmissionID2 INT;
EXEC @AdmissionID2 = sp_AllocateRoomToPatient
    @patient_id = 'P23456',
    @doctor_id = 102,
    @nurse_id = 202,
    @diagnosis = 'Post-surgical recovery',
    @room_type = 'Private',
    @admission_id = @AdmissionID2 OUTPUT;
SELECT @AdmissionID2 AS 'Admission ID (Private Room)';

-- Request a specific room number
DECLARE @AdmissionID3 INT;
EXEC @AdmissionID3 = sp_AllocateRoomToPatient
    @patient_id = 'P34567',
    @doctor_id = 103,
    @nurse_id = 203,
    @room_number = 301,
    @admission_id = @AdmissionID3 OUTPUT;
SELECT @AdmissionID3 AS 'Admission ID (Specific Room)';

-- =============================================
-- EXECUTE RECORD PATIENT DISCHARGE PROCEDURE
-- =============================================
-- Basic discharge (current date/time)
DECLARE @DischargeResult1 INT;
EXEC @DischargeResult1 = sp_RecordPatientDischarge 
    @admission_id = 1001;
SELECT @DischargeResult1 AS 'Discharge Result';

-- Discharge with specific date
EXEC sp_RecordPatientDischarge 
    @admission_id = 1002,
    @discharge_date = '2025-03-20 14:30:00';

-- Discharge with notes
EXEC sp_RecordPatientDischarge 
    @admission_id = 1003,
    @discharge_notes = 'Patient recovered well. Follow-up in 2 weeks.';

-- Full discharge with all parameters
DECLARE @DischargeResult2 INT;
EXEC @DischargeResult2 = sp_RecordPatientDischarge 
    @admission_id = 1004,
    @discharge_date = '2025-03-21 10:15:00',
    @discharge_notes = 'Patient recovered well. Prescribed antibiotics for 7 days. Follow-up in 2 weeks.';
SELECT @DischargeResult2 AS 'Full Discharge Result';

-- =============================================
-- EXECUTE PROCESS PAYMENT PROCEDURE
-- =============================================
-- Basic payment
DECLARE @PaymentResult1 INT;
EXEC @PaymentResult1 = sp_ProcessPayment
    @billing_id = 1001,
    @payment_amount = 250.00,
    @payment_method = 'Cash';
SELECT @PaymentResult1 AS 'Payment Result';

-- Payment with reference
EXEC sp_ProcessPayment
    @billing_id = 1002,
    @payment_amount = 500.00,
    @payment_method = 'Credit Card',
    @payment_date = '2025-03-15 10:30:00',
    @payment_reference = 'AUTH-12345678';

-- Multiple payments for one bill
-- First payment
EXEC sp_ProcessPayment
    @billing_id = 1003,
    @payment_amount = 300.00,
    @payment_method = 'Check',
    @payment_reference = 'Check #1234';

-- Second payment
EXEC sp_ProcessPayment
    @billing_id = 1003,
    @payment_amount = 450.00,
    @payment_method = 'Credit Card',
    @payment_reference = 'AUTH-98765432';

-- Payment with verification
DECLARE @VerifyBillingID INT = 1004;
DECLARE @PaymentResult2 INT;

EXEC @PaymentResult2 = sp_ProcessPayment
    @billing_id = @VerifyBillingID,
    @payment_amount = 750.00,
    @payment_method = 'Insurance',
    @payment_reference = 'Claim #INS-487652';

-- Verify updated record
IF @PaymentResult2 = 0
BEGIN
    SELECT 
        billing_id,
        patient_id,
        total_amount,
        amount_paid,
        (total_amount - amount_paid) AS remaining_balance,
        payment_status,
        payment_method
    FROM Billing
    WHERE billing_id = @VerifyBillingID;
END
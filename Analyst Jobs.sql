--Check data
SELECT * FROM analysts


--Analyst Levels in this dataset
SELECT DISTINCT Level FROM analysts
WHERE Level NOT IN ('n/a')


--Group Salary Range by Levels
SELECT Level, STRING_AGG([Salary Range], '|| ') AS Level_Salary_Range FROM analysts 
WHERE [Salary Range] NOT IN ('n/a') AND Level NOT IN ('n/a')
GROUP BY Level 
ORDER BY Level Desc


--Query Location column to find jobs that are remote
SELECT Location FROM analysts
WHERE Location LIKE 'Remote%'
OR Location LIKE '%Remote'
OR Location LIKE '%Remote%'


--Create a new column base off Loaction (Onsite/Remote)
SELECT Location,
	(CASE
		WHEN Location LIKE 'Remote%' OR Location LIKE '%Remote' OR Location LIKE '%Remote%' THEN 'Remote'
		ELSE 'Onsite'
	END) as Onsite_Remote
FROM analysts

ALTER TABLE analysts
ADD Onsite_Remote VARCHAR(255)

UPDATE analysts
SET Onsite_Remote = 
	CASE
		WHEN Location LIKE 'Remote%' OR Location LIKE '%Remote' OR Location LIKE '%Remote%' THEN 'Remote'
		ELSE 'Onsite'
	END

SELECT * FROM analysts


-- Remove NonAlphaCharacters from necessary columns
--First, create a function that removes all NonAlphaCharacter
Create Function [dbo].[RemoveNonAlphaCharacters](@Temp VarChar(1000))
Returns VarChar(1000)
AS
Begin
    Declare @KeepValues as varchar(50)
    Set @KeepValues = '%[^a-z, ]%'
    While PatIndex(@KeepValues, @Temp) > 0
        Set @Temp = Stuff(@Temp, PatIndex(@KeepValues, @Temp), 1, '')
    Return @Temp
End

--Call the function with the Columns to initiate cleaning
Select  dbo.RemoveNonAlphaCharacters([Required Skills]) AS [Required Skills (Cleaned)], [Required Skills] FROM analysts --Required Skills
Select dbo.RemoveNonAlphaCharacters(Benefits) AS [Job Benefits (Cleaned)], Benefits FROM analysts --Benefits

-- Permanent the Cleaning in the Columns
UPDATE analysts
SET [Required Skills] = dbo.RemoveNonAlphaCharacters([Required Skills])

UPDATE analysts
SET Benefits = dbo.RemoveNonAlphaCharacters(Benefits)


--Clean the Salary Range Column
UPDATE analysts
SET [Salary Range] = REPLACE([Salary Range], ' *', '')

SELECT * FROM analysts
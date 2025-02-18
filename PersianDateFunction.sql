﻿
	--declare @intdate datetime = '2026-02-20 18:48:00.000'
	--declare @format as nvarchar(50)
CREATE FUNCTION [dbo].[ShDate] (@intDate DATETIME , @format as nvarchar(50))
 
RETURNS NVARCHAR(50)

BEGIN

	--declare @intdate datetime = '2016-03-14 18:48:00.000'
	DECLARE @Year Smallint=year(@intdate),@Month Tinyint=10,@Day Smallint=11,@DayCNT Tinyint,@YearDD Smallint=0,
        @SHMM NVARCHAR(8),@SHDD NVARCHAR(8),@Quarter Smallint,@QuarterName NVARCHAR(20)
	DECLARE @ShDate NVARCHAR(max)
	
	/* Format Rules: (پنجشنبه 7 اردیبهشت 1394)
	DWN -> پنجشنبه (روز هفته به حروف)
	DW -> 6 (روز هفته به عدد)
	d -> 7 (چندمین روز از ماه)
	DD -> 07 (چندمین روز از ماه دو کاراکتری)
	m -> 2 (چندمین ماه از سال)
	MM -> 02 (چندمین ماه از سال دو کاراکتری)
	MMN -> اردیبهشت (نام ماه به حروف)
	YYYY -> 1394 (سال چهار کاراکتری)
	YY -> 94 (سال دو کاراکتری)
	YYYY -> 1394 (سال چهار کاراکتری)
	q -> 1 (شماره فصل)
	QQ -> 01 (شماره فصل دو رقمی)
	QQN -> (فصل به حروف)
	DoY -> 38 (چندمین روز سال)
	Default Format -> 'DWN d MMN YYYY'
	*/

	/* ==> "FYYYY" = First Leap(Kabiseh) Year in five Years Period <==*/
	/* ==> "SYYYY" = Second Leap(Kabiseh) Year in five Years Period <==*/
	/* ==> "NFYYYY" = First Leap(Kabiseh) Year in Next five Years Period <==*/
	/* ==> "NSYYYY" = Second Leap(Kabiseh) Year in Next five Years Period <==*/

	IF @Year < 1000 SET @Year += 2000

	--IF (@Format IS NULL) OR NOT LEN(@Format)>0 SET @Format = 'DWN d MMN YYYY'
	IF (@Format IS NULL) OR NOT LEN(@Format)>0 SET @Format = 'YYYY-MM-DD'

	SET @Year -= 622

	/*===================================================================*/
	--IF @Year % 4 = ("FYYYY + 1" % 4) and (@Year BETWEEN "FYYYY +1" AND "NFYYYY +1") SET @Day = 12 
	  IF @Year % 4 = 3 and (@Year > 1371) SET @Day = 12  --BETWEEN 1372 AND 1407
	  IF @Year % 4 = 0 and (@Year > 1407) SET @Day = 12  --BETWEEN 1408 AND 1437
	  IF @Year % 4 = 1 and @Year > 1437 SET @Day = 12  --(@Year BETWEEN 1437 AND 1470)
	
	/*===================================================================*/
	SET @Day += DATEPART(DY,@intdate) - 1



	WHILE 1 = 1
	BEGIN

		SET @DayCNT =
			CASE
				WHEN @Month < 7 THEN 31

		      --WHEN @Year % 4 > ("FYYYY +1" % 4) and @Month=12 and @Year > "FYYYY" THEN 29    
			  --WHEN @Year % 4 <> ("SYYYY -1" % 4) and @Month=12 and @Year > "SYYYY" THEN 29    
		
		        WHEN @Year % 4 < 3 and @Month=12 and (@Year BETWEEN 1370 AND 1403) THEN 29
		        WHEN @Year % 4 <> 2 and @Month=12 and @Year < 1375 THEN 29
		
				WHEN @Year % 4 > 0 and @Month=12 and (@Year BETWEEN 1404 AND 1437) THEN 29
				WHEN @Year % 4 <> 3 and @Month=12 and (@Year BETWEEN 1404 AND 1407) THEN 29
		
				WHEN @Year % 4 > 1 and @Month=12 and (@Year BETWEEN 1436 AND 1470) THEN 29  
				WHEN @Year % 4 <> 0 and @Month=12 and (@Year BETWEEN 1436 AND 1441) THEN 29 
		
		        ELSE 30
		    END
		IF @Day > @DayCNT
			BEGIN
				SET @Day -= @DayCNT
				SET @Month += 1
				SET @YearDD += @DayCNT
			END
		IF @Month > 12
			BEGIN
				SET @Month = 1
				SET @Year += 1
				SET @YearDD = 0
			END

	    IF @Month < 7 AND @Day < 32 BREAK
	    IF @Month BETWEEN 7 AND 11 AND @Day < 31 BREAK
	
	  --BEGIN
	  --    IF @Month = 12 AND @Year % 4 < ("FYYYY +1" % 4)  AND @Year > "FYYYY" AND @Day < 30 BREAK
	  --    IF @Month = 12 AND @Year % 4 <> ("SYYYY -1" % 4) AND @Year < "SYYYY" AND @Day < 30 BREAK
	  --    IF @Month = 12 AND @Year % 4 = ("SYYYY -1" % 4) AND @Year < "FYYYY +1" AND @Day < 31 BREAK
	  --    IF @Month = 12 AND @Year % 4 = ("FYYYY +1" % 4) AND @Year > "FYYYY +1" AND @Day < 31 BREAK
	  --END
	 
		IF @Year BETWEEN 1370 AND 1404
		BEGIN
		    IF @Month = 12 AND @Year % 4 < 3 AND @Year > 1370 AND @Day < 30 BREAK
		    IF @Month = 12 AND @Year % 4 <> 2 AND @Year < 1375 AND @Day < 30 BREAK
		    IF @Month = 12 AND @Year % 4 = 2 AND @Year < 1371 AND @Day < 31 BREAK
		    IF @Month = 12 AND @Year % 4 = 3 AND @Year > 1371 AND @Day < 31 BREAK
		END
	
		IF @Year BETWEEN 1405 AND 1437
		BEGIN
		    IF @Month = 12 AND @Year % 4 > 0 AND @Year > 1403 AND @Day < 30 BREAK
		    IF @Month = 12 AND @Year % 4 <> 3 AND @Year < 1408 AND @Day < 30 BREAK
		    IF @Month = 12 AND @Year % 4 = 3 AND @Year < 1404 AND @Day < 31 BREAK
		    IF @Month = 12 AND @Year % 4 = 0 AND @Year > 1404 AND @Day < 31 BREAK
		END
	
		IF @Year BETWEEN 1436 AND 1470
		BEGIN
		    IF @Month = 12 AND @Year % 4 > 1 AND @Year > 1436 AND @Day < 30 BREAK
		    IF @Month = 12 AND @Year % 4 <> 0 AND @Year < 1441 AND @Day < 30 BREAK
		    IF @Month = 12 AND @Year % 4 = 0 AND @Year < 1437 AND @Day < 31 BREAK
		    IF @Month = 12 AND @Year % 4 = 1 AND @Year > 1437 AND @Day < 31 BREAK
		END

	
	
	END

	SET @YearDD += @Day
	
	SET @SHMM =
	    CASE
	        WHEN @Month=1 THEN N'فروردین'
	        WHEN @Month=2 THEN N'اردیبهشت'
	        WHEN @Month=3 THEN N'خرداد'
	        WHEN @Month=4 THEN N'تیر'
	        WHEN @Month=5 THEN N'مرداد'
	        WHEN @Month=6 THEN N'شهریور'
	        WHEN @Month=7 THEN N'مهر'
	        WHEN @Month=8 THEN N'آبان'
	        WHEN @Month=9 THEN N'آذر'
	        WHEN @Month=10 THEN N'دی'
	        WHEN @Month=11 THEN N'بهمن'
	        WHEN @Month=12 THEN N'اسفند'
	    END
	   
	
	set @SHDD=
	    CASE
	        WHEN DATEPART(DW,@intdate)=7 THEN N'شنبه'
	        WHEN DATEPART(DW,@intdate)=1 THEN N'یکشنبه'
	        WHEN DATEPART(DW,@intdate)=2 THEN N'دوشنبه'
	        WHEN DATEPART(DW,@intdate)=3 THEN N'سه شنبه'
	        WHEN DATEPART(DW,@intdate)=4 THEN N'چهارشنبه'
	        WHEN DATEPART(DW,@intdate)=5 THEN N'پنجشنبه'
	        WHEN DATEPART(DW,@intdate)=6 THEN N'جمعه'
	    END
	SET @DayCNT=
	    CASE
	        WHEN @SHDD=N'شنبه' THEN 1
	        WHEN @SHDD=N'یکشنبه' THEN 2
	        WHEN @SHDD=N'دوشنبه' THEN 3
	        WHEN @SHDD=N'سه شنبه' THEN 4
	        WHEN @SHDD=N'چهارشنبه' THEN 5
	        WHEN @SHDD=N'پنجشنبه' THEN 6
	        WHEN @SHDD=N'جمعه' THEN 7
	    END
	
	SET @Quarter =
		CASE
			WHEN @Month BETWEEN 1 AND 3 THEN 1
			WHEN @Month BETWEEN 4 AND 6 THEN 2
			WHEN @Month BETWEEN 7 AND 9 THEN 3
			WHEN @Month BETWEEN 10 AND 12 THEN 4
		END

	SET @QuarterName =
		CASE
			WHEN @Quarter = 1 THEN N'بهار'
			WHEN @Quarter = 2 THEN N'تابستان'
			WHEN @Quarter = 3 THEN N'پاییز'
			WHEN @Quarter = 4 THEN N'زمستان'
		END
	IF @Month=10 AND @Day>10 SET @YearDD += 276
	IF @Month>10 SET @YearDD += 276
	

	SET @ShDate = REPLACE(@format,'YYYY',STR(@Year,4))
	SET @ShDate = REPLACE(@ShDate,'YY',SUBSTRING(STR(@Year,4),3,2))
	SET @ShDate = REPLACE(@ShDate,'DoY',LTRIM(STR(@YearDD,3)))
	SET @ShDate = REPLACE(@ShDate,'MMN',@SHMM)
	SET @ShDate = REPLACE(@ShDate,'MM',REPLACE(STR(@Month, 2), ' ', '0'))
	SET @ShDate = REPLACE(@ShDate,'m',LTRIM(STR(@Month,2)))
	SET @ShDate = REPLACE(@ShDate,'DWN',@SHDD)
	SET @ShDate = REPLACE(@ShDate,'DW',@DayCNT)
	SET @ShDate = REPLACE(@ShDate,'DD',REPLACE(STR(@Day,2), ' ', '0'))
	SET @ShDate = REPLACE(@ShDate,'d',LTRIM(STR(@Day,2)))
	SET @ShDate = REPLACE(@ShDate,'QQN',@QuarterName)
	SET @ShDate = REPLACE(@ShDate,'QQ',REPLACE(STR(@Quarter, 2), ' ', '0'))
	SET @ShDate = REPLACE(@ShDate,'q',@Quarter)

	RETURN @ShDate
END
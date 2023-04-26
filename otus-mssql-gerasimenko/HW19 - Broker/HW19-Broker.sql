USE master
ALTER DATABASE WideWorldImporters
SET ENABLE_BROKER  WITH NO_WAIT; 

ALTER DATABASE WideWorldImporters SET TRUSTWORTHY ON;

ALTER AUTHORIZATION    
   ON DATABASE::WideWorldImporters TO [sa];

USE WideWorldImporters
create schema rep

create table rep.OrderByCustomerID (
id int identity(0,1) primary key,
CustomerID int,
COUNTOrder int,
[Period] varchar(20),
RecordDate datetime default getdate()
)

--truncate table rep.OrderByCustomerID

--2
--Создание типов сообщений для запроса и ответного сообщения
USE WideWorldImporters
-- For Request
CREATE MESSAGE TYPE
[RequestReportMessage]
VALIDATION=WELL_FORMED_XML;
-- For Reply
CREATE MESSAGE TYPE
[ResponseReportMessage]
VALIDATION=WELL_FORMED_XML; 

GO

CREATE CONTRACT [ReportContract]
      ([RequestReportMessage]
         SENT BY INITIATOR,
       [ResponseReportMessage]
         SENT BY TARGET
      );
GO

--3)
CREATE QUEUE Target_q_Report;

CREATE SERVICE [Target_s_Report]
       ON QUEUE Target_q_Report
       ([ReportContract]);
GO


CREATE QUEUE Initiator_q_Report;

CREATE SERVICE [Initiator_s_Report]
       ON QUEUE Initiator_q_Report
       ([ReportContract]);
GO

--4 Создание процедуры (добавляем сообщение в очередь)
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE OR ALTER PROCEDURE rep.RequestParamReport
	@CustomerID INT,
	@DateStart date,
	@DateEnd date
AS
BEGIN
	SET NOCOUNT ON;

    --Отправка сообщения с запросом целевому объекту	
	DECLARE @InitDlgHandle UNIQUEIDENTIFIER;
	DECLARE @RequestMessage NVARCHAR(4000);
	
	BEGIN TRAN 

	--Сообщение
	SELECT @RequestMessage = (SELECT [CustomerID] = @CustomerID,
									 [DateStart] = @DateStart,
									 [DateEnd] = @DateEnd
							   FOR XML RAW, root('RequestMessage')); 
							   
	--Determine the Initiator Service, Target Service and the Contract 
	BEGIN DIALOG @InitDlgHandle
	FROM SERVICE
	[Initiator_s_Report]
	TO SERVICE
	'Target_s_Report'
	ON CONTRACT
	[ReportContract]
	WITH ENCRYPTION=OFF; 

	--Отправляем сообщение
	SEND ON CONVERSATION @InitDlgHandle 
	MESSAGE TYPE
	[RequestReportMessage]
	(@RequestMessage);
	SELECT @RequestMessage AS SentRequestMessage;
	COMMIT TRAN 
END
GO


--5 Завершение диалога(обработка сообщения)
CREATE or ALTER PROCEDURE rep.GetOrderByCustomerID
AS
BEGIN

	DECLARE @TargetDlgHandle UNIQUEIDENTIFIER,
			@Message NVARCHAR(4000),
			@MessageType Sysname,
			@ResponseMessage NVARCHAR(4000),
			@ResponseMessageName Sysname,
			@CustomerID INT,
			@DateStart date,
			@DateEnd date,
			@xml XML; 
	
	BEGIN TRAN; 

	--Получаем сообщение от инициатора
	RECEIVE TOP(1)
		@TargetDlgHandle = Conversation_Handle,
		@Message = Message_Body,
		@MessageType = Message_Type_Name
	FROM dbo.Target_q_Report; 

	--SELECT @Message;

	SET @xml = CAST(@Message AS XML);

	SELECT
	@CustomerID = a.item.value('@CustomerID','INT'),
	@DateStart = a.item.value('@DateStart','DATE'),
	@DateEnd = a.item.value('@DateEnd','DATE')
	FROM @xml.nodes('/RequestMessage/row') as a(item);

	insert into rep.OrderByCustomerID(CustomerID, COUNTOrder, [Period])
	select @CustomerID, COUNT(distinct a.OrderID), CONVERT(varchar(10), @DateStart, 120) +'/'+ CONVERT(varchar(10), @DateEnd, 120)
	from Sales.Invoices as a
	where a.CustomerID = @CustomerID
	and InvoiceDate between @DateStart and @DateEnd
	
	SELECT @Message AS ReceivedRequestMessage, @MessageType as MessageType; 
	
	-- Confirm and Send a reply
	IF @MessageType=N'RequestReportMessage'
	BEGIN
		SET @ResponseMessage =N'<ResponseReportMessage>Message received</ResponseReportMessage>'; 
	
		SEND ON CONVERSATION @TargetDlgHandle
		MESSAGE TYPE
		[ResponseReportMessage]
		(@ResponseMessage);
		END CONVERSATION @TargetDlgHandle;
	END 
	
	SELECT @ResponseMessage AS SentResponseMessage; 

	COMMIT TRAN;
END

--6 Обработка сообщений на инициаторе (повесили трубку)
CREATE or ALTER PROCEDURE rep.CommitOrderByCustomerID
AS
BEGIN
	--Получение ответного сообщения от  Target.	
	DECLARE @InitiatorReplyDlgHandle UNIQUEIDENTIFIER,
			@ReplyReceivedMessage NVARCHAR(1000) 
	
	BEGIN TRAN; 

		RECEIVE TOP(1)
			@InitiatorReplyDlgHandle=Conversation_Handle
			,@ReplyReceivedMessage=Message_Body
		FROM dbo.Initiator_q_Report; 
		
		END CONVERSATION @InitiatorReplyDlgHandle; 
		
		SELECT @ReplyReceivedMessage AS ReceivedRepliedMessage; 

	COMMIT TRAN; 
END

--7 Очереди без процедур обработки
ALTER QUEUE [dbo].Initiator_q_Report WITH STATUS = ON , RETENTION = OFF , POISON_MESSAGE_HANDLING (STATUS = OFF) 
	, ACTIVATION (   STATUS = OFF ,
        PROCEDURE_NAME = rep.CommitOrderByCustomerID, MAX_QUEUE_READERS = 1, EXECUTE AS OWNER) ; 

GO
ALTER QUEUE [dbo].Target_q_Report WITH STATUS = ON , RETENTION = OFF , POISON_MESSAGE_HANDLING (STATUS = OFF)
	, ACTIVATION (  STATUS = OFF ,
        PROCEDURE_NAME = rep.GetOrderByCustomerID, MAX_QUEUE_READERS = 1, EXECUTE AS OWNER) ; 

GO

--8 Смотрим конкретное сообщение
SELECT *
FROM rep.OrderByCustomerID

--Send message
EXEC rep.RequestParamReport
	@CustomerID = 832, @DateStart = '2013-01-01', @DateEnd = '2013-01-02';

SELECT CAST(message_body AS XML),*
FROM dbo.Target_q_Report;

SELECT CAST(message_body AS XML),*
FROM dbo.Initiator_q_Report;

--Target
EXEC rep.GetOrderByCustomerID;

--Initiator
EXEC rep.CommitOrderByCustomerID;

/* смотрим обработку сообщений
SELECT conversation_handle, is_initiator, s.name as 'local service', far_service, sc.name  'contract', ce.state_desc
FROM sys.conversation_endpoints ce
LEFT JOIN sys.services s
ON ce.service_id = s.service_id
LEFT JOIN sys.service_contracts sc
ON ce.service_contract_id = sc.service_contract_id
ORDER BY conversation_handle;
*/

--END CONVERSATION '2DDBD97C-3DE4-ED11-BCEC-08002734F6CD'
--END CONVERSATION '30DBD97C-3DE4-ED11-BCEC-08002734F6CD'
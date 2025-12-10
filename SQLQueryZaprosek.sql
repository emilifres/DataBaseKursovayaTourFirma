-- ЗАПРОСЫ ДЛЯ ПРОВЕРКИ ДАННЫХ

-- Посмотреть всех клиентов
SELECT * FROM Client ORDER BY Registration_Date DESC;

-- Посмотреть все услуги
SELECT Service_ID, Name, Type, Description FROM Service ORDER BY Type, Name;

-- Посмотреть бронирования с деталями
SELECT 
    b.Booking_ID,
    b.Booking_Date,
    b.Status,
    c.Full_Name as Client,
    t.Title as Tour,
    e.Full_Name as Manager,
    b.Total_Price
FROM Booking b
JOIN Client c ON b.Client_ID = c.Client_ID
JOIN Tour t ON b.Tour_ID = t.Tour_ID
JOIN Employee e ON b.Employee_ID = e.Employee_ID
ORDER BY b.Booking_Date DESC;

-- Посмотреть дополнительные услуги для конкретного бронирования (например, для Анны в Турцию)
SELECT 
    bs.Booking_Service_ID,
    s.Name as Service_Name,
    s.Type,
    bs.Quantity,
    bs.Price,
    (bs.Quantity * bs.Price) as Subtotal
FROM Booking_Service bs
JOIN Service s ON bs.Service_ID = s.Service_ID
WHERE bs.Booking_ID = 1;

-- Общая стоимость дополнительных услуг для бронирования
SELECT 
    SUM(bs.Quantity * bs.Price) as Total_Additional_Services
FROM Booking_Service bs
WHERE bs.Booking_ID = 1;

-- Платежи по бронированиям
SELECT 
    p.Payment_ID,
    p.Payment_Date,
    p.Amount,
    p.Payment_Method,
    p.Status,
    b.Booking_ID,
    c.Full_Name as Client
FROM Payment p
JOIN Booking b ON p.Booking_ID = b.Booking_ID
JOIN Client c ON b.Client_ID = c.Client_ID
ORDER BY p.Payment_Date DESC;

-- ЗАПРОСЫ ИЗ ТЕХНИЧЕСКОГО ЗАДАНИЯ по примеру

-- 1. Список всех клиентов с персональными данными
SELECT 
    Client_ID,
    Full_Name,
    Phone,
    Email,
    Passport_Data,
    Birth_Date,
    Registration_Date,
    DATEDIFF(YEAR, Birth_Date, GETDATE()) as Age
FROM Client
ORDER BY Full_Name;

-- 2. Клиенты, получившие заданную услугу (например, SPA-процедуры)
SELECT DISTINCT
    c.Client_ID,
    c.Full_Name,
    c.Phone,
    c.Email,
    s.Name as Service_Name
FROM Client c
JOIN Booking b ON c.Client_ID = b.Client_ID
JOIN Booking_Service bs ON b.Booking_ID = bs.Booking_ID
JOIN Service s ON bs.Service_ID = s.Service_ID
WHERE s.Name = 'SPA-процедуры';

-- 3. Клиенты, обслуживавшиеся в заданный период (например, в январе 2024)
SELECT 
    c.Client_ID,
    c.Full_Name,
    b.Booking_Date,
    t.Title as Tour,
    b.Total_Price
FROM Client c
JOIN Booking b ON c.Client_ID = b.Client_ID
JOIN Tour t ON b.Tour_ID = t.Tour_ID
WHERE b.Booking_Date BETWEEN '2024-01-01' AND '2024-01-31'
ORDER BY b.Booking_Date;

-- 4. Клиенты, обслуживавшиеся у заданного менеджера в период
SELECT 
    c.Client_ID,
    c.Full_Name as Client_Name,
    e.Full_Name as Manager_Name,
    b.Booking_Date,
    t.Title as Tour,
    b.Status,
    b.Total_Price
FROM Client c
JOIN Booking b ON c.Client_ID = b.Client_ID
JOIN Employee e ON b.Employee_ID = e.Employee_ID
JOIN Tour t ON b.Tour_ID = t.Tour_ID
WHERE e.Full_Name = 'Козлов Петр Александрович'
    AND b.Booking_Date BETWEEN '2024-01-01' AND '2024-06-30'
ORDER BY b.Booking_Date DESC;

-- 5. Стоимость услуг для заданного клиента
SELECT 
    c.Client_ID,
    c.Full_Name,
    COUNT(DISTINCT b.Booking_ID) as Total_Bookings,
    SUM(b.Total_Price) as Total_Spent,
    SUM(p.Amount) as Total_Paid,
    (SUM(b.Total_Price) - SUM(p.Amount)) as Balance
FROM Client c
LEFT JOIN Booking b ON c.Client_ID = b.Client_ID
LEFT JOIN Payment p ON b.Booking_ID = p.Booking_ID AND p.Status = 'Успешно'
WHERE c.Client_ID = 1
GROUP BY c.Client_ID, c.Full_Name;

-- 6. Общая стоимость реализованных услуг за период
SELECT 
    '2024-01-01 to 2024-06-30' as Period,
    SUM(b.Total_Price) as Total_Revenue,
    COUNT(b.Booking_ID) as Completed_Bookings,
    AVG(b.Total_Price) as Average_Booking_Price
FROM Booking b
WHERE b.Status IN ('Оплачено', 'Завершено')
    AND b.Booking_Date BETWEEN '2024-01-01' AND '2024-06-30';

-- 7. Список туристов по заданному туру (например, Турция)
SELECT 
    bp.Full_Name,
    bp.Passport_Data,
    bp.Birth_Date,
    b.Booking_Date,
    c.Phone,
    c.Email
FROM Booking_Participant bp
JOIN Booking b ON bp.Booking_ID = b.Booking_ID
LEFT JOIN Client c ON bp.Client_ID = c.Client_ID
JOIN Tour t ON b.Tour_ID = t.Tour_ID
WHERE t.Title LIKE '%Турция%'
ORDER BY b.Booking_Date;

-- 8. Полная информация по туру для клиента
DECLARE @ClientID INT = 1;
DECLARE @BookingID INT = 1;

-- Информация о бронировании
SELECT 
    b.Booking_ID,
    b.Booking_Date,
    b.Status,
    t.Title,
    t.Country,
    t.City,
    t.Start_Date as Tour_Start,
    t.End_Date as Tour_End,
    b.Total_Price,
    e.Full_Name as Manager
FROM Booking b
JOIN Tour t ON b.Tour_ID = t.Tour_ID
JOIN Employee e ON b.Employee_ID = e.Employee_ID
WHERE b.Booking_ID = @BookingID AND b.Client_ID = @ClientID;

-- Участники
SELECT 
    Full_Name,
    Passport_Data,
    Birth_Date
FROM Booking_Participant
WHERE Booking_ID = @BookingID;

-- Услуги и стоимость
SELECT 
    s.Name as Service,
    s.Type,
    bs.Quantity,
    bs.Price,
    (bs.Quantity * bs.Price) as Subtotal
FROM Booking_Service bs
JOIN Service s ON bs.Service_ID = s.Service_ID
WHERE bs.Booking_ID = @BookingID
ORDER BY s.Type;

-- 9. Сумма реализованных услуг по каждому менеджеру
SELECT 
    e.Employee_ID,
    e.Full_Name,
    e.Position,
    COUNT(b.Booking_ID) as Total_Bookings,
    SUM(b.Total_Price) as Total_Sales,
    AVG(b.Total_Price) as Average_Sale
FROM Employee e
LEFT JOIN Booking b ON e.Employee_ID = b.Employee_ID
    AND b.Status IN ('Оплачено', 'Завершено')
GROUP BY e.Employee_ID, e.Full_Name, e.Position
ORDER BY Total_Sales DESC;
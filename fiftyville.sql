-- Checking all the availabe tables
.tables

-- QUESTION 1

-- To find the suspect
SELECT description
FROM crime_scene_reports
WHERE year = 2021
AND month = 7
AND day = 28
AND street = "Humphrey Street";


-- QUESTION 2

-- Theft took place at 10:15am and interviews with three witnesses were conducted
-- each of them mentions the bakery
SELECT transcript
FROM interviews
WHERE year = 2021
AND month = 7
AND day = 28
AND transcript LIKE "%bakery%";


-- Between 10:15 to 10:25 the theif get into the car in bakery parking lot
-- Thief withdraw money from ATM on Leggett Street
-- Thief called someone for less than a minute on the day of thieft
-- Took the first flight on 29th out of Fiftyville
-- Select the name of the person
WITH bakery_license_plates AS (
    -- Select license plates from bakery_security_logs on a specific date and time
    SELECT license_plate
    FROM bakery_security_logs
    WHERE year = 2021
      AND month = 7
      AND day = 28
      AND hour = 10
      AND minute BETWEEN 15 AND 25
),

people_with_license_plate AS (
-- Select ids of people based on the license plates found in bakery_security_logs
SELECT id
FROM people
WHERE license_plate IN (SELECT license_plate FROM bakery_license_plates)
),

accounts_with_matching_person AS (
-- Select account_number from bank_accounts where the person has a matching license plate
SELECT account_number
FROM bank_accounts
WHERE person_id IN (SELECT id FROM people_with_license_plate)
),

atm_transactions_with_location AS (
-- Select account_number from atm_transactions where the location is Leggett Street
SELECT account_number
FROM atm_transactions
WHERE atm_location = 'Leggett Street'
    AND day = 28
    AND month = 7
    AND year = 2021
),

bank_accounts_with_matching_atm_transactions AS (
-- Select person_id from bank_accounts where the account_number matches with specific atm transactions
SELECT person_id
FROM bank_accounts
WHERE account_number IN (SELECT account_number FROM atm_transactions_with_location)
),

phone_numbers_with_short_calls AS (
-- Select caller phone numbers where call duration is less than 60 seconds
SELECT caller
FROM phone_calls
WHERE duration < 60
),

passengers_on_flight AS (
-- Select passport numbers from passengers who were on a specific flight
SELECT passport_number
FROM passengers
WHERE flight_id IN (
    -- Select the flight that happened on July 29, 2021, ordered by hour and limit to the first one
    SELECT id
    FROM flights
    WHERE day = 29
    AND year = 2021
    AND month = 7
    ORDER BY hour
    LIMIT 1
)
)

-- Main query
SELECT name
FROM people
WHERE id IN (
  -- Select person_id from bank_accounts where the account_number matches with specific transactions
  SELECT person_id
  FROM bank_accounts
  WHERE account_number IN (SELECT account_number FROM accounts_with_matching_person)
)
AND phone_number IN (SELECT caller FROM phone_numbers_with_short_calls)
AND passport_number IN (SELECT passport_number FROM passengers_on_flight);



-- QUESTION 3
-- Select the city from airports where the destination matches the earliest flight on July 29, 2021
SELECT city
FROM airports
WHERE id IN
(

  -- Select the destination airport ID from flights on July 29, 2021
  SELECT destination_airport_id
  FROM flights
  WHERE day = 29
  AND month = 7
  AND year = 2021

  -- Order by the flight hour and limit to the earliest flight
  ORDER BY hour
  LIMIT 1
);

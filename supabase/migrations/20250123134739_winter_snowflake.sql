/*
  # Add recurring payments support

  1. Changes
    - Add recurring payment fields to payments table:
      - `is_recurring` (boolean): Indicates if payment is recurring
      - `recurring_end_date` (date): Optional end date for recurring payments
      - `recurring_interval` (text): Interval for recurring payments (monthly, yearly, etc.)

  2. Security
    - Maintain existing RLS policies
*/

ALTER TABLE payments 
ADD COLUMN IF NOT EXISTS is_recurring boolean DEFAULT false,
ADD COLUMN IF NOT EXISTS recurring_end_date date,
ADD COLUMN IF NOT EXISTS recurring_interval text CHECK (recurring_interval IN ('weekly', 'monthly', 'yearly'));
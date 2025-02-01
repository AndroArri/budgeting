/*
  # Add incomes table

  1. New Tables
    - `incomes`
      - `id` (uuid, primary key)
      - `title` (text, not null)
      - `price` (decimal, not null)
      - `is_personal` (boolean, default false)
      - `user_id` (uuid, references auth.users)
      - `created_at` (timestamptz, default now())

  2. Security
    - Enable RLS on `incomes` table
    - Add policies for authenticated users to manage their own incomes
    - Add policy for users to view non-personal (shared) incomes
*/

-- Create incomes table
CREATE TABLE IF NOT EXISTS incomes (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    title text NOT NULL,
    price decimal NOT NULL,
    is_personal boolean DEFAULT false,
    user_id uuid REFERENCES auth.users NOT NULL,
    created_at timestamptz DEFAULT now()
);

-- Enable RLS
ALTER TABLE incomes ENABLE ROW LEVEL SECURITY;

-- Create policies
CREATE POLICY "Users can manage their own incomes"
    ON incomes
    FOR ALL
    TO authenticated
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can view shared incomes"
    ON incomes
    FOR SELECT
    TO authenticated
    USING (NOT is_personal);
/*
  # Family Finance Schema Setup

  1. New Tables
    - `categories`
      - `id` (uuid, primary key)
      - `title` (text, required)
      - `icon` (text, required)
      - `color` (text, required)
      - `user_id` (uuid, references auth.users)
      - `created_at` (timestamp)

    - `payments`
      - `id` (uuid, primary key)
      - `title` (text, required)
      - `price` (decimal, required)
      - `category_id` (uuid, references categories)
      - `date` (date, required)
      - `is_personal` (boolean, default false)
      - `user_id` (uuid, references auth.users)
      - `created_at` (timestamp)

    - `budgets`
      - `id` (uuid, primary key)
      - `title` (text, required)
      - `category_id` (uuid, references categories)
      - `is_percentage` (boolean, default false)
      - `amount` (decimal, required)
      - `user_id` (uuid, references auth.users)
      - `created_at` (timestamp)

  2. Security
    - Enable RLS on all tables
    - Add policies for authenticated users to manage their own data
    - Family members can view shared data
*/

-- Categories table
CREATE TABLE categories (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    title text NOT NULL,
    icon text NOT NULL,
    color text NOT NULL,
    user_id uuid REFERENCES auth.users NOT NULL,
    created_at timestamptz DEFAULT now()
);

ALTER TABLE categories ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can manage their own categories"
    ON categories
    FOR ALL
    TO authenticated
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);

-- Payments table
CREATE TABLE payments (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    title text NOT NULL,
    price decimal NOT NULL,
    category_id uuid REFERENCES categories NOT NULL,
    date date NOT NULL,
    is_personal boolean DEFAULT false,
    user_id uuid REFERENCES auth.users NOT NULL,
    created_at timestamptz DEFAULT now()
);

ALTER TABLE payments ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can manage their own payments"
    ON payments
    FOR ALL
    TO authenticated
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can view family payments"
    ON payments
    FOR SELECT
    TO authenticated
    USING (NOT is_personal);

-- Budgets table
CREATE TABLE budgets (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    title text NOT NULL,
    category_id uuid REFERENCES categories NOT NULL,
    is_percentage boolean DEFAULT false,
    amount decimal NOT NULL,
    user_id uuid REFERENCES auth.users NOT NULL,
    created_at timestamptz DEFAULT now()
);

ALTER TABLE budgets ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can manage their own budgets"
    ON budgets
    FOR ALL
    TO authenticated
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can view family budgets"
    ON budgets
    FOR SELECT
    TO authenticated
    USING (true);
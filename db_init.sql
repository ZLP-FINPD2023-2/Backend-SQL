-- DROP
-- CREATE DATABASE lfp;


-- Гендер
DROP TYPE  IF EXISTS gender_enum CASCADE;
CREATE TYPE gender_enum AS ENUM ('male', 'female');

--Пользователи
DROP TABLE  IF EXISTS users CASCADE;
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    email VARCHAR(255) UNIQUE NOT NULL,
    firstName VARCHAR(100) NOT NULL,
    lastName VARCHAR(100) NOT NULL,
    patronymic VARCHAR(100),
    gender gender_enum,
    birthday DATE,
    password VARCHAR(255) NOT NULL,

    -- Валидаторы
    CONSTRAINT valid_email CHECK (email ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}$'),
    CONSTRAINT valid_password_length CHECK (LENGTH(password) >= 8)
);

-- Цели
DROP TABLE IF EXISTS goals CASCADE;
CREATE TABLE goals (
    id SERIAL PRIMARY KEY,
    userId INTEGER NOT NULL REFERENCES users(id),
    targetAmount INTEGER NOT NULL ,
    title VARCHAR(255) NOT NULL
);

-- Бюджеты
DROP TABLE IF EXISTS budgets CASCADE;
CREATE TABLE budgets (
    id SERIAL PRIMARY KEY,
    userId INTEGER NOT NULL REFERENCES users(id),
    goalId INTEGER NOT NULL REFERENCES goals(id),
    title VARCHAR(255) NOT NULL
);

-- Транзакции
DROP TABLE IF EXISTS transactions CASCADE;
CREATE TABLE transactions (
    id SERIAL PRIMARY KEY,
    userId INTEGER NOT NULL REFERENCES users(id),
    title VARCHAR(255),
    date TIMESTAMP,
    amount NUMERIC NOT NULL,
    budgetFromId INTEGER NOT NULL REFERENCES budgets(id),
    budgetToId INTEGER NOT NULL REFERENCES budgets(id)
);




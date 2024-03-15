-- Создание пользователя
CREATE OR REPLACE FUNCTION add_user(
    email VARCHAR(255),
    firstName VARCHAR(100),
    lastName VARCHAR(100),
    password VARCHAR(255),
    patronymic VARCHAR(100) DEFAULT NULL,
    gender gender_enum DEFAULT NULL,
    birthday DATE DEFAULT NULL
) RETURNS INTEGER AS $$
DECLARE
    user_id INTEGER;
BEGIN
    -- Проверка обязательного поля email
    IF email IS NULL THEN
        RAISE EXCEPTION 'Не заполнено обязательное поле: почта';
    END IF;

    -- Проверка обязательного поля firstName
    IF firstName IS NULL THEN
        RAISE EXCEPTION 'Не заполнено обязательное поле: Имя';
    END IF;

    -- Проверка обязательного поля lastName
    IF lastName IS NULL THEN
        RAISE EXCEPTION 'Не заполнено обязательное поле: Фамилия';
    END IF;

    -- Проверка обязательного поля password
    IF password IS NULL THEN
        RAISE EXCEPTION 'Не заполнено обязательное поле: Пароль';
    END IF;

     -- Добавление пользователя
    BEGIN
        INSERT INTO users (email, firstName, lastName, patronymic, gender, birthday, password)
        VALUES (email, firstName, lastName, patronymic, gender, birthday, password)
        RETURNING id INTO user_id;
    EXCEPTION
        WHEN unique_violation THEN
            RAISE EXCEPTION 'Пользователь с таким email уже существует';
    END;

    RETURN user_id;
EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'Ошибка при регистрации пользователя: %', SQLERRM;
END;
$$ LANGUAGE plpgsql;

-- Удаление пользователя
CREATE OR REPLACE FUNCTION delete_user(
    user_identifier TEXT
) RETURNS VOID AS $$
BEGIN
    IF user_identifier IS NULL THEN
        RAISE EXCEPTION 'Идентификатор пользователя не может быть NULL';
    END IF;

    -- Проверяем, является ли user_identifier числом (ID) или строкой (email)
    IF user_identifier ~ '^\d+$' THEN
        DELETE FROM users WHERE id = CAST(user_identifier AS INTEGER);
    ELSE
        DELETE FROM users WHERE email = user_identifier;
    END IF;

    -- Проверяем, была ли удалена запись
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Пользователь с указанным идентификатором или почтой не найден';
    END IF;
END;
$$ LANGUAGE plpgsql;

-- Получить данные по пользователю
CREATE OR REPLACE FUNCTION get_user_info(
    user_id INTEGER
) RETURNS users AS $$
DECLARE
    user_record users%ROWTYPE;
BEGIN
    -- Проверяем, существует ли пользователь с указанным ID
    SELECT * INTO user_record FROM users WHERE id = user_id;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Пользователь с указанным идентификатором не найден';
    END IF;

    RETURN user_record;
END;
$$ LANGUAGE plpgsql;

-- Обновление пользовтеля
CREATE OR REPLACE FUNCTION update_user(
    user_id INTEGER,
    new_email VARCHAR(255) DEFAULT NULL,
    new_firstName VARCHAR(100) DEFAULT NULL,
    new_lastName VARCHAR(100) DEFAULT NULL,
    new_patronymic VARCHAR(100) DEFAULT NULL,
    new_gender gender_enum DEFAULT NULL,
    new_birthday DATE DEFAULT NULL,
    new_password VARCHAR(255) DEFAULT NULL
) RETURNS VOID AS $$
BEGIN
    -- Проверяем, существует ли пользователь с указанным ID
    IF NOT EXISTS (SELECT 1 FROM users WHERE id = user_id) THEN
        RAISE EXCEPTION 'Пользователь с указанным идентификатором не найден';
    END IF;

    -- Обновляем поля пользователя, если они были переданы
    UPDATE users SET
        email = COALESCE(new_email, email),
        firstName = COALESCE(new_firstName, firstName),
        lastName = COALESCE(new_lastName, lastName),
        patronymic = COALESCE(new_patronymic, patronymic),
        gender = COALESCE(new_gender, gender),
        birthday = COALESCE(new_birthday, birthday),
        password = COALESCE(new_password, password)
    WHERE id = user_id;
END;
$$ LANGUAGE plpgsql;



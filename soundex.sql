-- SQL statements that are used to define the soundex function
-- Include all your tried solutions in the SQL file
-- with commenting below the functions the execution times on the tested dictionaries.

CREATE OR REPLACE FUNCTION american_soundex(str VARCHAR) RETURNS varchar AS $$
DECLARE
    drop_chars char[] := '{"a", "e", "i", "o", "u", "y", "h", "w"}';
    one_chars varchar := 'bfpv';
    two_chars varchar := 'cgjkqsxz';
    three_chars varchar := 'dt';
    four_chars varchar := 'l';
    replace_chars text[] := '{bfpv, cgjkqsxz, dt, l, mn, r}';
    input_array char[] := string_to_array(str, NULL);
    result_array char[] := '{}';
    result varchar := substr(str, 1, 1);
    soundex varchar := '';
BEGIN
    str := substr(str, 2, length(str));
    DECLARE
        i char := '';
    BEGIN
        FOREACH i IN ARRAY drop_chars
        LOOP
            str := replace(str, i, '');
        END LOOP;
    END;

    input_array := string_to_array(str, NULL);

    FOR j IN 1..LENGTH(str)
    LOOP
        FOR k in 1..array_upper(replace_chars, 1) LOOP
            IF position(input_array[j] IN replace_chars[k]) > 0 THEN
                IF position(k::CHAR IN str) = 0 THEN
                    str := replace(str, input_array[j], k::CHAR);
                    soundex := soundex || k::CHAR;
                END IF;
            END IF;
        END LOOP;

    END LOOP;

    soundex := rpad(soundex, 3, '0');
    result := result || soundex;
    RETURN result;
END;
$$ LANGUAGE plpgsql;

SELECT american_soundex('Robert') as robert,
       american_soundex('Rupert') as rupert,
       american_soundex('Rubin') as rubin;
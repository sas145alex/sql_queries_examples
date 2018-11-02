-- Выявление медицинских программ без приборов для их дальнейшей обработки



-- SELECT count(*) FROM qq;

COPY (

  WITH initial_table AS (
    SELECT
    med_programs.id as med_program_id,
    med_programs.state as med_program_state,
    (people.surname || ' ' || people.name || ' ' || people.patronymic) as patient_full_name,
    (p2.surname     || ' ' || p2.name     || ' ' || p2.patronymic) as doctor_full_name,
    le.name as legal_entity_name,
    sub.name as subject_name,
    reg.name as region_name,
    tem.name as template_name

    FROM med_programs
      LEFT JOIN people                            ON (med_programs.patient_id = people.id)
      LEFT JOIN people                     as p2  ON (med_programs.doctor_id = p2.id)
      LEFT JOIN legal_entities             as le  ON (p2.legal_entity_id = le.id)
      LEFT JOIN subjects                   as sub ON (le.subject_id = sub.id)
      LEFT JOIN regions                    as reg ON (le.region_id = reg.id)
      LEFT JOIN med_program_templates      as tem ON (med_programs.template_id = tem.id)


    WHERE (med_programs.complect_id IS NULL)
  )

  SELECT
    CASE
      WHEN med_program_state = 10 THEN 'Оформление'
      WHEN med_program_state = 20 THEN 'Активная'
      WHEN med_program_state = 30 THEN 'Завершена'
      WHEN med_program_state = 40 THEN 'Завершена'
    END
    med_program_state,
    med_program_id,
    template_name,
    patient_full_name,
    doctor_full_name,
    region_name,
    subject_name,
    legal_entity_name
  FROM initial_table

)
TO '/home/mtr/formated_output.csv' WITH CSV HEADER DELIMITER ',';

-- SELECT * FROM initial_table;

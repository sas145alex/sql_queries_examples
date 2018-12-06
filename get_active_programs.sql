

COPY (

-- SELECT count(*)
SELECT
 mp.id as med_program,
 mp.patient_id,
 mp.doctor_id,
 patients.surname as patient_surname,
 patients.name as patient_name,
 patients.patronymic as patient_patronymic,
 mp_t.name as nosology,
 to_char(mp.begin_date, 'YYYY-MM-DD HH24:MI:SS') as begin_date,
 mp.end_date

  FROM med_programs AS mp

  LEFT JOIN people AS patients ON (mp.patient_id = patients.id)
  JOIN med_program_templates AS mp_t ON (mp.template_id = mp_t.id)
  LEFT JOIN nosologies AS nos ON (mp_t.nosology_id = nos.id)


WHERE state=20
-- ;

) TO '/home/mtr/active_programs.csv' WITH CSV HEADER DELIMITER ',';

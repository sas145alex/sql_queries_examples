-- ID программы
-- Дата начала программы
-- Дата завершения программы
-- ID прибора
-- № тонометра
-- № GSM-модуля
-- № SIM-карты
-- ID пациента
-- Пол
-- Дата рождения
-- Округ/Субъект (Лечащий врач - Юр.Лицо)
-- ID измерения
-- Дата и время измерения и отправки результатов (Дата, время ПРИБОР)
-- Дата и время получения сообщения телемедицинской системой (Дата, время СИСТЕМА)
-- Статуса ответа сервера на полученное сообщение (Константа - ОК)

COPY (

  WITH tc_3 AS (
    SELECT
    complects.id,
    s.inventory_number as tonometry_number

    FROM complects
      JOIN complects_shipments AS cs ON (complects.id = cs.complect_id)
      JOIN shipments AS s ON (s.id = cs.shipment_id)

    WHERE (s.tmc_type_id = 3)
  )

  ,tc_9 AS (
    SELECT
    complects.id,
    s.inventory_number as sim_card

    FROM complects
      JOIN complects_shipments AS cs ON (complects.id = cs.complect_id)
      JOIN shipments AS s ON (s.id = cs.shipment_id)

    WHERE (s.tmc_type_id = 9)
  )

  ,tc_10 AS (
    SELECT
    complects.id,
    s.inventory_number as gsm_module

    FROM complects
      JOIN complects_shipments AS cs ON (complects.id = cs.complect_id)
      JOIN shipments AS s ON (s.id = cs.shipment_id)

    WHERE (s.tmc_type_id = 10)
  )

  ,complect_types as (

    SELECT
    complects.id,
    tc_3.tonometry_number,
    tc_9.sim_card,
    tc_10.gsm_module

    FROM complects

      JOIN tc_3  ON (complects.id = tc_3.id)
      JOIN tc_9  ON (complects.id = tc_9.id)
      JOIN tc_10 ON (complects.id = tc_10.id)
  )

  ,main_table AS (
    SELECT
    tdata.id as tonometry_data_id,
    mp.id as med_program_id,
    to_char(mp.begin_date, 'yyyy-mm-dd') as med_program_begin_date,
    mp.end_date as med_program_end_date,
    mp.complect_id as complect_id,
    ctypes.tonometry_number,
    ctypes.sim_card,
    ctypes.gsm_module,
    patients.id as patient_id,

    patients.male,
    patients.birthday,
    doctors.id as doctor_id,
    regions.name as region_name,
    subjects.name as subject_name,
    to_char(tdata.created_at, 'yyyy-mm-dd') as tonometry_data_server_date,
    to_char(tdata.created_at, 'HH24:MI:SS.MS') as tonometry_data_server_time,
    to_char(tdata.occurred_at, 'yyyy-mm-dd') as tonometry_data_date,
    to_char(tdata.occurred_at, 'HH24:MI:SS.MS') as tonometry_data_time

    FROM tonometry_data AS tdata
      JOIN med_programs as mp ON (tdata.med_program_id = mp.id)
      LEFT JOIN complect_types as ctypes ON (mp.complect_id = ctypes.id)
      LEFT JOIN people as patients ON (mp.patient_id = patients.id)
      LEFT JOIN people as doctors ON (mp.doctor_id = doctors.id)
      LEFT JOIN legal_entities as le ON (doctors.legal_entity_id = le.id)
      LEFT JOIN regions ON (le.region_id = regions.id)
      LEFT JOIN subjects ON (le.subject_id = subjects.id)

    WHERE (tdata.created_at > '2018-09-01')
  )

  -- SELECT count(*) FROM main_table;

  SELECT

    med_program_id,
    med_program_begin_date,
    med_program_end_date,
    complect_id,
    tonometry_number,
    gsm_module,
    sim_card,

    patient_id,
    CASE
      WHEN male = 't' THEN 'муж'
      WHEN male = 'f' THEN 'жен'
    END
    male,
    birthday,

    region_name,
    subject_name,

    tonometry_data_id,

    tonometry_data_server_date,
    tonometry_data_server_time,
    tonometry_data_date,
    tonometry_data_time,
    'OK' server_respond


  FROM main_table
  -- ;

)
TO '/home/mtr/rep1.csv' WITH CSV HEADER DELIMITER ',';

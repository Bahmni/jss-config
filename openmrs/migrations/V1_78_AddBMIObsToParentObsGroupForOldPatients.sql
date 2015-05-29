DROP PROCEDURE IF EXISTS add_bmi_obs_to_parent_obs_group;;
CREATE PROCEDURE add_bmi_obs_to_parent_obs_group (parent_concept_name VARCHAR(255), obs_concept_name VARCHAR(255), abnormal_concept_name VARCHAR(255))
  BEGIN
    DECLARE done BOOLEAN DEFAULT False;
    DECLARE bmi_obs_id INT;
    DECLARE status VARCHAR(255);
    DECLARE encounter_id INT;
    DECLARE person_id INT;
    DECLARE order_id INT;
    DECLARE creator INT;
    DECLARE obs_date_time DATETIME;
    DECLARE date_created DATETIME;
    DECLARE uuid VARCHAR(255);
    DECLARE parent_concept_id INT DEFAULT (SELECT concept_id FROM concept_name WHERE name = parent_concept_name AND concept_name_type='FULLY_SPECIFIED');
    DECLARE obs_concept_id INT DEFAULT (SELECT concept_id FROM concept_name WHERE name = obs_concept_name AND concept_name_type='FULLY_SPECIFIED');
    DECLARE abnormal_concept_id INT DEFAULT (SELECT concept_id FROM concept_name WHERE name = abnormal_concept_name AND concept_name_type='FULLY_SPECIFIED');
    DECLARE bmi_status_concept_id INT DEFAULT (SELECT concept_id FROM concept_name WHERE name = 'BMI STATUS' AND concept_name_type='FULLY_SPECIFIED');
    DECLARE true_concept_id INT DEFAULT (select property_value from global_property where property = 'concept.true');
    DECLARE false_concept_id INT DEFAULT (select property_value from global_property where property = 'concept.false');
    DECLARE abnormal_obs_coded_value INT DEFAULT false_concept_id;
    DECLARE parent_obs_id INT;
    
    DECLARE obs_cursor CURSOR FOR (SELECT obs.obs_id, bmi_status.value_text, obs.encounter_id, obs.person_id, obs.order_id, obs.obs_datetime, obs.creator, obs.date_created
                                FROM obs obs
                                  INNER JOIN obs parent on obs.obs_group_id = parent.obs_id
                                  LEFT OUTER JOIN obs bmi_status on obs.obs_group_id = bmi_status.obs_group_id and bmi_status.concept_id = bmi_status_concept_id and bmi_status.voided = false
                                WHERE
                                  obs.voided = false
                                  AND obs.concept_id = obs_concept_id
                                  AND obs.obs_group_id IS NOT NULL
                                  AND parent.concept_id != parent_concept_id)
                                UNION
                                (SELECT obs.obs_id, bmi_status.value_text, obs.encounter_id, obs.person_id, obs.order_id, obs.obs_datetime, obs.creator, obs.date_created
                                FROM obs obs
                                  INNER join encounter on obs.encounter_id = encounter.encounter_id and encounter.voided = false
                                  LEFT OUTER JOIN obs bmi_status on bmi_status.encounter_id = obs.encounter_id and bmi_status.concept_id = bmi_status_concept_id and bmi_status.voided = false
                                WHERE
                                  obs.voided = false
                                  AND obs.concept_id = obs_concept_id
                                  AND obs.obs_group_id is NULL
                                );
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
    OPEN obs_cursor;

    READ_LOOP: WHILE done IS NOT TRUE DO
      SET abnormal_obs_coded_value = false_concept_id;
      FETCH obs_cursor INTO bmi_obs_id, status, encounter_id, person_id, order_id, obs_date_time, creator, date_created;

      IF done THEN
        LEAVE READ_LOOP;
      END IF;

      IF status != 'Normal' THEN
        SET abnormal_obs_coded_value = true_concept_id;
      END IF;

      SELECT uuid() INTO uuid;
      INSERT into obs(concept_id, encounter_id, person_id, order_id, obs_datetime, creator, date_created, uuid) VALUES(parent_concept_id, encounter_id, person_id, order_id, obs_date_time, creator, date_created, uuid);
      SELECT max(obs_id) INTO parent_obs_id FROM obs;

      SELECT uuid() INTO uuid;
      INSERT into obs(concept_id, obs_group_id, value_coded, encounter_id, person_id, order_id, obs_datetime, creator, date_created, uuid) VALUES(abnormal_concept_id, parent_obs_id, abnormal_obs_coded_value, encounter_id, person_id, order_id, obs_date_time, creator, date_created, uuid);

      UPDATE obs SET obs_group_id = parent_obs_id WHERE obs_id = bmi_obs_id;
    END WHILE;

    CLOSE obs_cursor;
  END;;

call add_bmi_obs_to_parent_obs_group('BMI DATA', 'BMI', 'BMI ABNORMAL');;
call add_bmi_obs_to_parent_obs_group('BMI STATUS DATA', 'BMI STATUS', 'BMI STATUS ABNORMAL');;

DROP PROCEDURE IF EXISTS add_bmi_obs_to_parent_obs_group;;
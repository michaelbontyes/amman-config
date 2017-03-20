UPDATE
    global_property
SET property_value = "SELECT DISTINCT
        pi.identifier                                         AS identifier,
        concat(pn.given_name, ' ', pn.family_name)            AS PATIENT_LISTING_QUEUES_HEADER_NAME,
        FLOOR(DATEDIFF(CURDATE(), p.birthdate) / 365)         AS age,
        p.gender                                              AS gender,
        parentLocation.name                                   AS department,
        b.bed_number                                          AS `Bed No`,
        DATE_FORMAT(bpam.date_started, '%d %b %Y %h:%i %p')   AS `Admitted On`,
        'Transfer/Discharge'                                  AS `Bed Management`,
        'Enter Disposition'                                   AS disposition,
        concat('', p.uuid)                                    AS uuid,
        concat('', v.uuid)                                    AS activeVisitUuid,
        concat('', prog.uuid)                                 AS programUuid,
        concat('', pp.uuid)                                   AS enrollment
    FROM visit v
        INNER JOIN person_name pn ON v.patient_id = pn.person_id AND pn.voided IS FALSE
        INNER JOIN patient_identifier pi ON v.patient_id = pi.patient_id AND pi.voided IS FALSE
        INNER JOIN patient_identifier_type pit ON pi.identifier_type = pit.patient_identifier_type_id AND pit.retired IS FALSE
        INNER JOIN global_property gp ON gp.property = 'emr.primaryIdentifierType' AND gp.property_value = pit.uuid
        INNER JOIN person p ON v.patient_id = p.person_id AND p.voided IS FALSE
        INNER JOIN patient_program pp ON p.person_id = pp.patient_id
        INNER JOIN program prog ON pp.program_id = prog.program_id
        INNER JOIN bed_patient_assignment_map bpam ON bpam.patient_id = p.person_id AND bpam.date_stopped IS NULL AND bpam.voided IS FALSE
        INNER JOIN bed b ON b.bed_id = bpam.bed_id AND b.voided IS FALSE
        INNER JOIN bed_location_map blm ON b.bed_id = blm.bed_id
        INNER JOIN location childLocation on blm.location_id = childLocation.location_id AND childLocation.retired IS FALSE
        INNER JOIN location parentLocation ON parentLocation.location_id = childLocation.parent_location AND parentLocation.retired IS FALSE
    WHERE v.date_stopped IS NULL AND v.voided IS FALSE
    ORDER BY bpam.date_started;"
WHERE property = "emrapi.sqlSearch.admittedPatients";

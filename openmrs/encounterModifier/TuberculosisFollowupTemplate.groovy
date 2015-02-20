import org.apache.commons.collections.Predicate
import org.bahmni.module.bahmnicore.contract.encounter.data.EncounterModifierData
import org.bahmni.module.bahmnicore.encounterModifier.EncounterModifier
import org.bahmni.module.bahmnicore.service.impl.BahmniBridge
import org.openmrs.ConceptAnswer
import org.openmrs.module.emrapi.encounter.domain.EncounterTransaction
import org.bahmni.module.bahmnicore.contract.encounter.data.EncounterModifierObservation
import groovy.lang.GroovyObject
import groovy.lang.GroovyClassLoader
import org.openmrs.util.OpenmrsUtil;

import static org.apache.commons.collections.CollectionUtils.filter

public class TuberculosisFollowupTemplate extends EncounterModifier {
    public static final String TREATMENT_PLAN_CONCEPT_NAME = "Tuberculosis, Treatment Plan"
    public static final String FOLLOWUP_VISIT_CONCEPT_NAME = "Tuberculosis, Followup Visit"
    public static final String WEIGHT_CONCEPT_NAME = "Weight"
    public static final String ENCOUNTER_MODIFIER_ALGORITHM_DIRECTORY = "/encounterModifier/";

    public BahmniBridge bahmniBridge;

    private File sourceFile = new File(OpenmrsUtil.getApplicationDataDirectory() + ENCOUNTER_MODIFIER_ALGORITHM_DIRECTORY + "TBRegimen.groovy");
    private Class TBRegimen = new GroovyClassLoader(getClass().getClassLoader()).parseClass(sourceFile);

    public EncounterModifierData run(EncounterModifierData encounterModifierData) {


        this.bahmniBridge = BahmniBridge
                .create()
                .forPatient(encounterModifierData.getPatientUuid());

        def nowAsOfEncounter = encounterModifierData.getEncounterDateTime() != null ? encounterModifierData.getEncounterDateTime() : new Date();

        def weight = fetchLatestValueNumeric(WEIGHT_CONCEPT_NAME);
        if (weight == null) {
            throw new RuntimeException("Patient Weight is not Available");
        }

        Collection<EncounterModifierObservation> bahmniObservations = encounterModifierData.getEncounterModifierObservations();

        String regimenName = getRegimenName(bahmniObservations)
        String followUp = getFollowUp(bahmniObservations)

        List<EncounterTransaction.DrugOrder> drugOrders = encounterModifierData.getDrugOrders();
        drugOrders.addAll(bahmniBridge.drugOrdersForRegimen(regimenName));

        TBRegimen.generateDrugsForFollowup(regimenName, followUp, isAdult(nowAsOfEncounter), weight, drugOrders);
        encounterModifierData.setDrugOrders(drugOrders);

        return encounterModifierData;
    }

    private String getFollowUp(List<EncounterModifierObservation> bahmniObservations) {
        EncounterModifierObservation followupVisitObservation = findObservation(FOLLOWUP_VISIT_CONCEPT_NAME, bahmniObservations);

        String followUp;

        if (followupVisitObservation.getValue() == null) {
            throw new RuntimeException("Please fill in Followup Visit before using the Compute button");
        }

        if (followupVisitObservation.getValue().get("name") instanceof String) {
            followUp = followupVisitObservation.getValue().get("name");
        } else {
            followUp = followupVisitObservation.getValue().get("name").get("name");
        }


        followUp
    }

    private String getRegimenName(List<EncounterModifierObservation> bahmniObservations) {
        String regimenName;
        EncounterModifierObservation regimenObservation = findObservation(TREATMENT_PLAN_CONCEPT_NAME, bahmniObservations);
        if (regimenObservation != null && regimenObservation.getValue() != null) {
            regimenName = getCodedObsValue(regimenObservation.getValue());
        }
        if (regimenName == null) {
            regimenName = fetchLatestValueCoded(TREATMENT_PLAN_CONCEPT_NAME);
        }

        if (regimenName == null) {
            throw new RuntimeException("Please fill in Treatment plan before using the Compute button");
        }
        regimenName
    }

    private static String getCodedObsValue(Object codeObsVal) {
        if (codeObsVal instanceof HashMap) {
            def value = ((HashMap) codeObsVal).get("name")
            if (value instanceof HashMap) {
                return (String) ((HashMap) value).get("name")
            } else {
                return value;
            }
        };
        return (String) codeObsVal;
    }

    private boolean isAdult(Date nowAsOfEncounter) {
        return bahmniBridge.ageInYears(nowAsOfEncounter) > 12;
    }

    private EncounterModifierObservation findObservation(String conceptName, Collection<EncounterModifierObservation> bahmniObservations) {
        for (EncounterModifierObservation bahmniObservation : bahmniObservations) {
            if (conceptName.equals(bahmniObservation.getConcept().getName())) {
                return bahmniObservation;
            } else if (bahmniObservation.getGroupMembers() != null) {
                EncounterModifierObservation observation = findObservation(conceptName, bahmniObservation.getGroupMembers());
                if (observation != null) {
                    return observation;
                }
            }
        }
        return null;
    }

    Double fetchLatestValueNumeric(String conceptName) {
        def obs = bahmniBridge.latestObs(conceptName)
        return obs ? obs.getValueNumeric() : null
    }

    String fetchLatestValueCoded(String conceptName) {
        def obs = bahmniBridge.latestObs(conceptName)
        return obs ? obs.getValueCoded().getName().getName() : null
    }

}



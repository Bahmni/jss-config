import org.apache.commons.collections.Predicate
import org.bahmni.module.bahmnicore.contract.encounter.data.EncounterModifierData
import org.bahmni.module.bahmnicore.contract.encounter.data.EncounterModifierObservation
import org.bahmni.module.bahmnicore.encounterModifier.EncounterModifier
import org.bahmni.module.bahmnicore.service.impl.BahmniBridge
import org.openmrs.module.bahmniemrapi.drugorder.DrugOrderUtil
import org.openmrs.module.emrapi.encounter.domain.EncounterTransaction
import org.openmrs.util.OpenmrsUtil

import static org.apache.commons.collections.CollectionUtils.filter

public class TuberculosisIntakeTemplate extends EncounterModifier {

    public static final String TREATMENT_PLAN_CONCEPT_NAME = "Tuberculosis, Treatment Plan"
    public static final String WEIGHT_CONCEPT_NAME = "Weight"
    public static final String HEIGHT_CONCEPT_NAME = "Height"
    public static final String BMI_CONCEPT_NAME = "BMI"
    public static final String ENCOUNTER_MODIFIER_ALGORITHM_DIRECTORY = "/encounterModifier/";

    public BahmniBridge bahmniBridge;

    private File sourceFile = new File(OpenmrsUtil.getApplicationDataDirectory() + ENCOUNTER_MODIFIER_ALGORITHM_DIRECTORY + "TBRegimen.groovy");
    private Class TBRegimen = new GroovyClassLoader(getClass().getClassLoader()).parseClass(sourceFile);

    public EncounterModifierData run(EncounterModifierData encounterModifierData) {

        this.bahmniBridge = BahmniBridge
                .create()
                .forPatient(encounterModifierData.getPatientUuid());

        List<EncounterTransaction.DrugOrder> activeDrugOrders = bahmniBridge.activeDrugOrdersForPatient();

        def nowAsOfEncounter = encounterModifierData.getEncounterDateTime() != null ? encounterModifierData.getEncounterDateTime() : new Date();

        def weight = fetchLatestValueNumeric(WEIGHT_CONCEPT_NAME);
        if(weight == null || weight <= 0){
            throw new RuntimeException("Patient Weight is not Available");
        }


        Collection<EncounterModifierObservation> bahmniObservations = encounterModifierData.getEncounterModifierObservations();
        String regimenName = getRegimenName(bahmniObservations);

        def height = fetchLatestValueNumeric(HEIGHT_CONCEPT_NAME);
        if(height == null || height <= 0){
            throw new RuntimeException("Patient Height is not Available");
        }
        double bmi = fetchLatestValueNumeric(BMI_CONCEPT_NAME);

        List<EncounterTransaction.DrugOrder> drugOrders = encounterModifierData.getDrugOrders();
        drugOrders.addAll(bahmniBridge.drugOrdersForRegimen(regimenName));
        for (EncounterTransaction.DrugOrder drugOrder: drugOrders ) {
            for (EncounterTransaction.DrugOrder activeDrugOrder : activeDrugOrders) {
                if(areSameDrugOrders(activeDrugOrder, drugOrder)){
                    drugOrder.setEffectiveStartDate(DrugOrderUtil.aSecondAfter(activeDrugOrder.getEffectiveStopDate()));
                }
            }
        }
        TBRegimen.generateDrugsForIntake(regimenName, isAdult(nowAsOfEncounter), weight, bmi, drugOrders);
        encounterModifierData.setDrugOrders(drugOrders);

        return encounterModifierData;
    }

    private String getRegimenName(List<EncounterModifierObservation> bahmniObservations) {
        EncounterModifierObservation regimenObservation = findObservation(TREATMENT_PLAN_CONCEPT_NAME, bahmniObservations);
        if (regimenObservation == null || regimenObservation.getValue() == null) {
            throw new RuntimeException("Please fill in Treatment plan before using the Compute button");
        }
        String regimenName = getCodedObsValue(regimenObservation.getValue());
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

    private boolean areSameDrugOrders(EncounterTransaction.DrugOrder activeDrugOrder, EncounterTransaction.DrugOrder drugOrder){
        return drugOrder.getDrug() != null &&  activeDrugOrder.getDrug() != null ? drugOrder.getDrug().getName().equals(activeDrugOrder.getDrug().getName())  &&
                activeDrugOrder.getDrug().getForm().equals(drugOrder.getDrug().getForm()):
                drugOrder.getDrugNonCoded().equals(activeDrugOrder.getDrugNonCoded() &&
                        drugOrder.getDosingInstructions().getDoseUnits().equals(activeDrugOrder.getDosingInstructions().getDoseUnits()))
    }

}

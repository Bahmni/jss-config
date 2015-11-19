import org.bahmni.module.bahmnicore.encounterModifier.EncounterModifier
import org.bahmni.module.bahmnicore.service.impl.BahmniBridge
import org.openmrs.module.emrapi.encounter.domain.EncounterTransaction
import org.bahmni.module.bahmnicore.contract.encounter.data.EncounterModifierData
import org.openmrs.module.bahmniemrapi.drugorder.DrugOrderUtil
import org.bahmni.module.bahmnicore.contract.encounter.data.EncounterModifierObservation


public class BreastCancerIntakeTemplate extends EncounterModifier {

    public static final String REGIMEN_CONCEPT_NAME = "Breast Cancer, Regimen Type"
    public static final String PERCENTAGE_AMPUTATED_CONCEPT_NAME = "Percentage Amputated"
    public static final String HEIGHT_CONCEPT_NAME = "Height"
    public static final String WEIGHT_CONCEPT_NAME = "Weight"
    public BahmniBridge bahmniBridge;

    public EncounterModifierData run(EncounterModifierData encounterModifierData) {

        this.bahmniBridge = BahmniBridge
                .create()
                .forPatient(encounterModifierData.getPatientUuid());

        def nowAsOfEncounter = encounterModifierData.getEncounterDateTime() != null ? encounterModifierData.getEncounterDateTime() : new Date();
        def patientAgeInYears = bahmniBridge.ageInYears(nowAsOfEncounter);

        def height = fetchLatestValueNumeric(HEIGHT_CONCEPT_NAME);
        def weight = fetchLatestValueNumeric(WEIGHT_CONCEPT_NAME);
        def bsa = calculateBSA(height, weight, patientAgeInYears);

        Collection<EncounterModifierObservation> bahmniObservations = encounterModifierData.getEncounterModifierObservations();

        EncounterModifierObservation regimenObservation = findObservation(REGIMEN_CONCEPT_NAME, bahmniObservations);

        if (regimenObservation == null || regimenObservation.getValue() == null) {
            return encounterModifierData;
        }

        EncounterModifierObservation percentageAmputatedObservation = findObservation(PERCENTAGE_AMPUTATED_CONCEPT_NAME, bahmniObservations);

        List<EncounterTransaction.DrugOrder> drugOrders = encounterModifierData.getDrugOrders();
        drugOrders.addAll(bahmniBridge.drugOrdersForRegimen(getCodedObsValue(regimenObservation.getValue())));

        List<EncounterTransaction.DrugOrder> activeDrugOrders = bahmniBridge.activeDrugOrdersForPatient();
        for (EncounterTransaction.DrugOrder drugOrder: drugOrders ) {
            for (EncounterTransaction.DrugOrder activeDrugOrder : activeDrugOrders) {
                if(areSameDrugOrders(activeDrugOrder, drugOrder)){
                    drugOrder.setEffectiveStartDate(DrugOrderUtil.aSecondAfter(activeDrugOrder.getEffectiveStopDate()));
                }
            }
        }

        if ("Cyclophosphamide + Doxorubicin + Fluorouracil".equals(getCodedObsValue(regimenObservation.getValue()))) {
            setDoseAndQuantity(drugOrders, "Cyclophosphamide 500mg", bsa, 600.0, percentageAmputatedObservation)
            setDoseAndQuantity(drugOrders, "Doxorubicin Hydrochloride 50mg", bsa, 50.0, percentageAmputatedObservation)
            setDoseAndQuantity(drugOrders, "Flurouracil 10ml", bsa, 600, percentageAmputatedObservation)
        }

        if ("Doxorubicin + Cyclophosphamide".equals(getCodedObsValue(regimenObservation.getValue()))) {
            setDoseAndQuantity(drugOrders, "Cyclophosphamide 500mg", bsa, 600.0, percentageAmputatedObservation)
            setDoseAndQuantity(drugOrders, "Doxorubicin Hydrochloride 10mg", bsa, 50.0, percentageAmputatedObservation)
        }

        if ("Paclitaxel".equals(getCodedObsValue(regimenObservation.getValue()))) {
            setDoseAndQuantity(drugOrders, "Texeleon 260mg", bsa, 175, percentageAmputatedObservation)   
        }
        
        encounterModifierData.setDrugOrders(drugOrders);

        return encounterModifierData;
    }

    private void setDoseAndQuantity(List<EncounterTransaction.DrugOrder> drugOrders, String drugName, double bsa, BigDecimal baseDose, EncounterModifierObservation percentageAmputatedObservation) {
        def cyclophosphamideOrder = getDrugOrder(drugOrders, drugName)
        def cyclophosphamideDose = calculateDose(baseDose, bsa, percentageAmputatedObservation)
        cyclophosphamideOrder.getDosingInstructions().setDose(cyclophosphamideDose)
        cyclophosphamideOrder.getDosingInstructions().setQuantity(cyclophosphamideDose)
    }

    private EncounterTransaction.DrugOrder getDrugOrder(List<EncounterTransaction.DrugOrder> drugOrders, String drugName) {
        for (EncounterTransaction.DrugOrder drugOrder : drugOrders) {
            if (areSameDrugNames(drugOrder, drugName)) {
                return drugOrder;
            }
        }
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

    static double calculateDose(double referenceDose, double bsa, EncounterModifierObservation percentageAmputatedObservation) {
        double percentageAmputated = percentageAmputatedObservation != null && percentageAmputatedObservation.getValue() != null ? (Double.parseDouble((String) percentageAmputatedObservation.getValue())) : 0;
        return Math.round(referenceDose * bsa * (100 - percentageAmputated) / 100);
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

    //Calculation of BSA by Du Bois Formula: http://www.cato.eu/body-surface-area.html
    static Double calculateBSA(Double height, Double weight, Integer patientAgeInYears) {
        if (weight == null) {
            throw new RuntimeException("Weight is not captured for patient. Failed to compute drug orders");
        }
        if (height == null) {
            throw new RuntimeException("Height is not captured for patient. Failed to compute drug orders");
        }

        if (patientAgeInYears <= 15 && weight <= 40) {
            return Math.sqrt(weight * height / 3600);
        }
        return Math.pow(weight, 0.425) * Math.pow(height, 0.725) * 0.007184;
    }

    private boolean areSameDrugOrders(EncounterTransaction.DrugOrder activeDrugOrder, EncounterTransaction.DrugOrder drugOrder){
        return drugOrder.getDrug() != null &&  activeDrugOrder.getDrug() != null ? drugOrder.getDrug().getName().equals(activeDrugOrder.getDrug().getName())  &&
                activeDrugOrder.getDrug().getForm().equals(drugOrder.getDrug().getForm()):
                drugOrder.getDrugNonCoded().equals(activeDrugOrder.getDrugNonCoded() &&
                        drugOrder.getDosingInstructions().getDoseUnits().equals(activeDrugOrder.getDosingInstructions().getDoseUnits()))
    }

    private boolean areSameDrugNames(EncounterTransaction.DrugOrder drugOrder, String drugName){
        return drugOrder.getDrug() ? drugOrder.getDrug().getName().equals(drugName) : drugOrder.getDrugNonCoded().equals(drugName);
    }
}

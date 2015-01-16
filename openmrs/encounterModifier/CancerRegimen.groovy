import org.bahmni.module.bahmnicore.contract.encounter.data.ConceptData
import org.bahmni.module.bahmnicore.encounterModifier.EncounterModifier
import org.bahmni.module.bahmnicore.service.impl.BahmniBridge
import org.codehaus.jackson.map.ObjectMapper
import org.openmrs.module.bahmniemrapi.encountertransaction.contract.BahmniEncounterTransaction
import org.openmrs.module.bahmniemrapi.encountertransaction.contract.BahmniObservation
import org.openmrs.module.emrapi.encounter.domain.EncounterTransaction

public class CancerRegimen extends EncounterModifier {

    public static final String REGIMEN_CONCEPT_NAME = "Cancer Regimen Name"
    public static final String PERCENTAGE_AMPUTATED_CONCEPT_NAME = "Percentage Amputated"
    public static final String HEIGHT_CONCEPT_NAME = "Height"
    public static final String WEIGHT_CONCEPT_NAME = "Weight"
    public BahmniBridge bahmniBridge;

    private static final ObjectMapper objectMapper = new ObjectMapper();

    public BahmniEncounterTransaction run(BahmniEncounterTransaction bahmniEncounterTransaction, ConceptData conceptSetData) {

        this.bahmniBridge = BahmniBridge
                .create()
                .forPatient(bahmniEncounterTransaction.patientUuid);

        def nowAsOfEncounter = bahmniEncounterTransaction.getEncounterDateTime() != null ? bahmniEncounterTransaction.getEncounterDateTime() : new Date();
        def patientAgeInYears = bahmniBridge.ageInYears(nowAsOfEncounter);

        def height = fetchLatestValueNumeric(HEIGHT_CONCEPT_NAME);
        def weight = fetchLatestValueNumeric(WEIGHT_CONCEPT_NAME);
        def bsa = calculateBSA(height, weight, patientAgeInYears);

        Collection<BahmniObservation> bahmniObservations = bahmniEncounterTransaction.getObservations();

        BahmniObservation regimenObservation = findObservation(REGIMEN_CONCEPT_NAME, bahmniObservations);

        if (regimenObservation == null || regimenObservation.getValue() == null) {
            return bahmniEncounterTransaction;
        }

        BahmniObservation percentageAmputatedObservation = findObservation(PERCENTAGE_AMPUTATED_CONCEPT_NAME, bahmniObservations);

        List<EncounterTransaction.DrugOrder> drugOrders = bahmniEncounterTransaction.getDrugOrders();
        drugOrders.addAll(bahmniBridge.drugOrdersForRegimen(getCodedObsValue(regimenObservation.getValue())));

        if ("Cancer Regimen, CAF".equals(getCodedObsValue(regimenObservation.getValue()))) {
            setDoseAndQuantity(drugOrders, "Cyclophosphamide 500mg", bsa, 600.0, percentageAmputatedObservation)
            setDoseAndQuantity(drugOrders, "Doxorubicin Hydrochloride 50mg", bsa, 600.0, percentageAmputatedObservation)
            setDoseAndQuantity(drugOrders, "Flurouracil 10ml", bsa, 50, percentageAmputatedObservation)
        }

        if ("Breast Cancer - AC".equals(getCodedObsValue(regimenObservation.getValue()))) {
            setDoseAndQuantity(drugOrders, "Cyclophosphamide 500mg", bsa, 600.0, percentageAmputatedObservation)
            setDoseAndQuantity(drugOrders, "Doxorubicin Hydrochloride 50mg", bsa, 600.0, percentageAmputatedObservation)
            setDoseAndQuantity(drugOrders, "Flurouracil 10ml", bsa, 50, percentageAmputatedObservation)
        }

        if ("Breast Cancer - Paclitaxel".equals(getCodedObsValue(regimenObservation.getValue()))) {
            setDoseAndQuantity(drugOrders, "Texeleon 260mg", bsa, 175, percentageAmputatedObservation)   
        }
        
        bahmniEncounterTransaction.setDrugOrders(drugOrders);

        return bahmniEncounterTransaction;
    }

    private void setDoseAndQuantity(List<EncounterTransaction.DrugOrder> drugOrders, String drugName, double bsa, BigDecimal baseDose, BahmniObservation percentageAmputatedObservation) {
        def cyclophosphamideOrder = getDrugOrder(drugOrders, drugName)
        def cyclophosphamideDose = calculateDose(baseDose, bsa, percentageAmputatedObservation)
        cyclophosphamideOrder.getDosingInstructions().setDose(cyclophosphamideDose)
        cyclophosphamideOrder.getDosingInstructions().setQuantity(cyclophosphamideDose)
    }

    private EncounterTransaction.DrugOrder getDrugOrder(List<EncounterTransaction.DrugOrder> drugOrders, String drugName) {
        for (EncounterTransaction.DrugOrder drugOrder : drugOrders) {
            if (drugOrder.getDrug().getName().equals(drugName)) {
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

    static double calculateDose(double referenceDose, double bsa, BahmniObservation percentageAmputatedObservation) {
        double percentageAmputated = percentageAmputatedObservation != null && percentageAmputatedObservation.getValue() != null ? (Double.parseDouble((String) percentageAmputatedObservation.getValue())) : 0;
        return Math.round(referenceDose * bsa * (100 - percentageAmputated) / 100);
    }

    private BahmniObservation findObservation(String conceptName, Collection<BahmniObservation> bahmniObservations) {
        for (BahmniObservation bahmniObservation : bahmniObservations) {
            if (conceptName.equals(bahmniObservation.getConcept().getName())) {
                return bahmniObservation;
            } else if (bahmniObservation.getGroupMembers() != null) {
                BahmniObservation observation = findObservation(conceptName, bahmniObservation.getGroupMembers());
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
        if (patientAgeInYears <= 15 && weight <= 40) {
            return Math.sqrt(weight * height / 3600);
        }
        return Math.pow(weight, 0.425) * Math.pow(height, 0.725) * 0.007184;
    }
}

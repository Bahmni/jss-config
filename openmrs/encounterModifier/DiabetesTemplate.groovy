import org.bahmni.module.bahmnicore.contract.encounter.data.EncounterModifierData
import org.bahmni.module.bahmnicore.encounterModifier.EncounterModifier
import org.codehaus.jackson.map.ObjectMapper
import org.openmrs.Drug
import org.openmrs.Patient
import org.openmrs.api.context.Context
import org.openmrs.module.emrapi.diagnosis.Diagnosis
import org.openmrs.module.emrapi.diagnosis.DiagnosisService
import org.openmrs.module.emrapi.encounter.domain.EncounterTransaction

public class DiabetesTemplate extends EncounterModifier {
    private static final ObjectMapper objectMapper = new ObjectMapper();
    static private String TYPE1 = 'Diabetes Mellitus, Type 1'
    static private String TYPE2 = 'Diabetes Mellitus, Type 2'
    static private String UNSPECIFIED = 'Diabetes Mellitus, Unspecified'
    static private String KETOACIDOSIS = 'Diabetes, Ketoacidosis'
    static private String GESTATIONAL = 'Diabetes, Gestational'
    static private diabetesDiagnosis = [TYPE1, TYPE2, UNSPECIFIED, KETOACIDOSIS, GESTATIONAL]

    static private String INSULIN_30_70_CARTIGES = "Insulin 30/70 Cartriges"
    static private String BIPHASIC_ISOPHANE_INSULIN_30_70 = "Biphasic Isophane Insulin 30/70"
    static private String BIPHASIC_ISOPHANE_INSULIN_50_50 = "Biphasic Isophane Insulin 50/50"
    static private String INSULIN_PLAIN = "Insulin, plain"
    static private String PIOGLITAZONE = "Pioglitazone 15mg"
    static private String GLIPIZIDE = "Glipizide 5mg"
    static private String METFORMIN = "Metformin 500mg (SR)"
    static private String GLIBENCLAMIDE = "Glibenclamide 5mg"
    static private String GLIMEPIRIDE = "Glimepiride"

    public EncounterModifierData run(EncounterModifierData encounterModifierData) {
        Patient patient = Context.getPatientService().getPatientByUuid(encounterModifierData.getPatientUuid())
        def diabetesType = whichDiabetes(patient)

        List<EncounterTransaction.DrugOrder> drugOrders = encounterModifierData.getDrugOrders();
        switch (diabetesType) {
            case TYPE1:
                drugOrders.addAll(
                        drugOrder(INSULIN_30_70_CARTIGES, ROUTE.SUBCUTANEOUS),
                        drugOrder(BIPHASIC_ISOPHANE_INSULIN_30_70, ROUTE.SUBCUTANEOUS),
                        drugOrder(BIPHASIC_ISOPHANE_INSULIN_50_50, ROUTE.SUBCUTANEOUS),
//                        drugOrder(INSULIN_PLAIN, ROUTE.SUBCUTANEOUS)
                )
                break
            case TYPE2:
                drugOrders.addAll(
                        drugOrder(GLIPIZIDE, 1, DOSAGE.TABLETS, ROUTE.ORAL, DOSAGE_FREQUENCY.ONCE_A_DAY, 30, DOSAGE.TABLETS, 1, DURATION.MONTHS, "Before breakfast"),
                        drugOrder(METFORMIN, 1, DOSAGE.TABLETS, ROUTE.ORAL, DOSAGE_FREQUENCY.ONCE_A_DAY, 30, DOSAGE.TABLETS, 1, DURATION.MONTHS, "After lunch"),
                        drugOrder(PIOGLITAZONE, 1, DOSAGE.TABLETS, ROUTE.ORAL, DOSAGE_FREQUENCY.ONCE_A_DAY, 30, DOSAGE.TABLETS, 1, DURATION.MONTHS, "After lunch"),
                        drugOrder(INSULIN_30_70_CARTIGES, null, DOSAGE.IU, ROUTE.SUBCUTANEOUS, DOSAGE_FREQUENCY.TWICE_A_DAY, null, DOSAGE.IU, 1, DURATION.MONTHS, "Before breakfast and before dinner"),
                        drugOrder(BIPHASIC_ISOPHANE_INSULIN_30_70, null, DOSAGE.IU, ROUTE.SUBCUTANEOUS, DOSAGE_FREQUENCY.TWICE_A_DAY, null, DOSAGE.IU, 1, DURATION.MONTHS, "Before breakfast and before dinner"),
                )
                break
            case KETOACIDOSIS:
                drugOrders.addAll(
//                        drugOrder(INSULIN_PLAIN, null, DOSAGE.IU, ROUTE.SUBCUTANEOUS, DOSAGE_FREQUENCY.THRICE_A_DAY, null, "Unit(s)", null, null, "Before meals"),
                        drugOrder(BIPHASIC_ISOPHANE_INSULIN_50_50, null, DOSAGE.IU, ROUTE.SUBCUTANEOUS, DOSAGE_FREQUENCY.TWICE_A_DAY, null, DOSAGE.IU, 1, DURATION.MONTHS, null),
                        drugOrder(GLIBENCLAMIDE, 1, DOSAGE.TABLETS, ROUTE.ORAL, DOSAGE_FREQUENCY.ONCE_A_DAY, 30, DOSAGE.TABLETS, 1, DURATION.MONTHS, null),
//                        drugOrder(GLIMEPIRIDE, 1, DOSAGE.TABLETS, ROUTE.ORAL, DOSAGE_FREQUENCY.ONCE_A_DAY, 30, DOSAGE.TABLETS, 1, DURATION.MONTHS, "With breakfast or lunch"),
                )
                break
            case GESTATIONAL:
                drugOrders.addAll(
                        drugOrder(INSULIN_30_70_CARTIGES, ROUTE.SUBCUTANEOUS),
                        drugOrder(BIPHASIC_ISOPHANE_INSULIN_30_70, ROUTE.SUBCUTANEOUS),
                        drugOrder(BIPHASIC_ISOPHANE_INSULIN_50_50, ROUTE.SUBCUTANEOUS),
                        drugOrder(PIOGLITAZONE, ROUTE.ORAL))
                break
        }
        encounterModifierData.setDrugOrders(drugOrders)

        return encounterModifierData
    }

    static String form(String name) {
        Drug drug = Context.getConceptService().getDrug(name)
        if (drug == null) throw new NullPointerException("Drug with name: $name doesn't exist")
        return drug.getDosageForm().getName().getName()
    }

    static String whichDiabetes(Patient patient) {
        DiagnosisService diagnosisService = Context.getService(DiagnosisService.class)
        List<Diagnosis> diagnoses = new ArrayList<Diagnosis>(diagnosisService.getUniqueDiagnoses(patient, null))
        Collections.sort(diagnoses, new DiagnosisComparator())
        if (diagnoses.size() == 0) return ""
        return diagnoses.last().getDiagnosis().getCodedAnswer().getName().getName()
    }

    private static EncounterTransaction.DrugOrder drugOrder(String drugName, String route) {
        return drugOrder(drugName, null, null, route, null, null, null, null, null, null);
    }

    private static EncounterTransaction.DrugOrder drugOrder(String drugName, Double dose,
                                                            String doseUnits, String route, String frequency, Double quantity,
                                                            String quantityUnit, Integer duration, String durationUnits, String additionalInstructions) {
        def drugOrder = createDrugOrder(drugName, form(drugName), doseUnits, route, frequency, quantity, quantityUnit, duration, durationUnits)
        drugOrder.dosingInstructions.dose = dose;
        if (additionalInstructions != null) {
            def instructions = ["additionalInstructions": additionalInstructions]
            def administrationInstructions = convertToJSON(instructions);
            drugOrder.dosingInstructions.setAdministrationInstructions(administrationInstructions);
        }
        return drugOrder;
    }

    private static String convertToJSON(LinkedHashMap<String, Double> doses) {
        objectMapper.writeValueAsString(doses)
    }

    private
    static EncounterTransaction.DrugOrder createDrugOrder(String drugName, String drugForm, String doseUnits, String route, String frequency,
                                                          Double quantity, String quantityUnit, Integer duration, String durationUnits) {
        EncounterTransaction.DrugOrder drugOrder = new EncounterTransaction.DrugOrder();
        EncounterTransaction.Drug drug = new EncounterTransaction.Drug();
        drug.setName(drugName);
        drug.setForm(drugForm);
        drugOrder.setDrug(drug);
        drugOrder.setCareSetting("Outpatient");
        drugOrder.setOrderType("Drug Order");
        drugOrder.setDosingInstructionType("org.openmrs.module.bahmniemrapi.drugorder.dosinginstructions.FlexibleDosingInstructions");

        EncounterTransaction.DosingInstructions dosingInstructions = new EncounterTransaction.DosingInstructions();
        dosingInstructions.setDoseUnits(doseUnits);
        dosingInstructions.setRoute(route);
        dosingInstructions.setFrequency(frequency);
        if (quantity != null)
            dosingInstructions.setQuantity(quantity);
        dosingInstructions.setQuantityUnits(quantityUnit);
        dosingInstructions.setAsNeeded(false);
        drugOrder.setDosingInstructions(dosingInstructions);

        if (quantity != null)
            drugOrder.setDuration(duration);
        drugOrder.setDurationUnits(durationUnits);

        return drugOrder;
    }

    static class ROUTE {
        public static String SUBCUTANEOUS = "Sub Cutaneous"
        public static String ORAL = "Oral"
    }

    static class DOSAGE {
        public static String TABLETS = "Tablet(s)"
        public static String IU = "IU"
    }

    static class DOSAGE_FREQUENCY {
        public static String ONCE_A_DAY = "Once a day"
        public static String TWICE_A_DAY = "Twice a day"
        public static String THRICE_A_DAY = "Thrice a day"
    }

    static class DURATION {
        public static String MONTHS = "Month(s)"
    }

    static class DiagnosisComparator implements Comparator<Diagnosis> {
        @Override
        int compare(Diagnosis o1, Diagnosis o2) {
            Date date1 = o1.getExistingObs().getObsDatetime()
            Date date2 = o2.getExistingObs().getObsDatetime()
            return date1.compareTo(date2)
        }
    }
}

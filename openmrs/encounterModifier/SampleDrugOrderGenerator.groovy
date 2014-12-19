import org.apache.commons.lang.StringUtils
import org.bahmni.module.bahmnicore.contract.encounter.data.ConceptData
import org.bahmni.module.bahmnicore.encounterModifier.EncounterModifier
import org.codehaus.jackson.map.ObjectMapper
import org.hibernate.Query
import org.hibernate.SessionFactory
import org.joda.time.LocalDate
import org.joda.time.Years
import org.openmrs.Obs
import org.openmrs.Patient
import org.openmrs.api.context.Context
import org.openmrs.module.bahmniemrapi.encountertransaction.contract.BahmniEncounterTransaction
import org.openmrs.module.bahmniemrapi.encountertransaction.contract.BahmniObservation
import org.openmrs.module.emrapi.encounter.domain.EncounterTransaction

public class SampleDrugOrderGenerator extends EncounterModifier {

    public static final String REGIMEN_CONCEPT_NAME = "Breast Cancer Regimen 2"
    public static final String PERCENTAGE_AMPUTATED_CONCEPT_NAME = "Percentage Amputated"
    public static final String HEIGHT_CONCEPT_NAME = "Height"
    public static final String WEIGHT_CONCEPT_NAME = "Weight"

    private static final ObjectMapper objectMapper = new ObjectMapper();

    public BahmniEncounterTransaction run(BahmniEncounterTransaction bahmniEncounterTransaction, ConceptData conceptSetData) {

        Patient patient = Context.getPatientService().getPatientByUuid(bahmniEncounterTransaction.getPatientUuid());
        def nowAsOfEncounter = bahmniEncounterTransaction.getEncounterDateTime() != null ? bahmniEncounterTransaction.getEncounterDateTime() : new Date();
        def patientAgeInYears = Years.yearsBetween(new LocalDate(patient.getBirthdate()), new LocalDate(nowAsOfEncounter)).getYears();

        def height = fetchLatestValue(HEIGHT_CONCEPT_NAME, bahmniEncounterTransaction.getPatientUuid());
        def weight = fetchLatestValue(WEIGHT_CONCEPT_NAME, bahmniEncounterTransaction.getPatientUuid());

        if (height == null || weight == null) {
            throw new RuntimeException("No height or weight set for this patient");
        }

        def bsa = calculateBSA(height, weight, patientAgeInYears);
        List<BahmniObservation> bahmniObservations = bahmniEncounterTransaction.getObservations();

        BahmniObservation regimenObservation = findObservation(REGIMEN_CONCEPT_NAME, bahmniObservations);

        if (regimenObservation == null || regimenObservation.getValue() == null) {
            return bahmniEncounterTransaction;
        }

        BahmniObservation percentageAmputatedObservation = findObservation(PERCENTAGE_AMPUTATED_CONCEPT_NAME, bahmniObservations);

        List<EncounterTransaction.DrugOrder> drugOrders = bahmniEncounterTransaction.getDrugOrders();
        if ("CAF (6 cycles)".equals(getCodedObsValue(regimenObservation.getValue()))) {
            drugOrders.add(createUniformDrugOrder("DNS", "Injection", 1000.0, "ml", "Intravenous", "Immediately", 2.0, "Unit(s)", 4, "Hour(s)", null));
            drugOrders.add(createUniformDrugOrder("Dexamethasone 8mg/2ml", "Injection", 2.0, "ml", "Intravenous", "Immediately", 1.0, "Unit(s)", 1, "Minute(s)", null));
            drugOrders.add(createUniformDrugOrder("Ondansetron 8mg/4ml", "Injection", 2.0, "ml", "Intravenous", "Immediately", 1.0, "Unit(s)", 1, "Minute(s)", null));
            def cyclophosphamideDose = calculateDose(600.0, bsa, percentageAmputatedObservation);
            drugOrders.add(createUniformDrugOrder("Cyclophosphamide 500mg", "Injection", cyclophosphamideDose, "mg", "Intravenous", "Immediately", cyclophosphamideDose, "Unit(s)", 4, "Hour(s)", "with Dextrox 5% (Injection)"));
            def doxorubicinHydrochlorideDose = calculateDose(600.0, bsa, percentageAmputatedObservation);
            drugOrders.add(createUniformDrugOrder("Doxorubicin Hydrochloride 50mg", "Injection", doxorubicinHydrochlorideDose, "mg", "Intravenous", "Immediately", doxorubicinHydrochlorideDose, "Unit(s)", 4, "Hour(s)", "with Dextrox 5% (Injection)"));
            def flurouracilDose = calculateDose(50.0, bsa, percentageAmputatedObservation);
            drugOrders.add(createUniformDrugOrder("Flurouracil 10ml", "Injection", flurouracilDose, "mg", "Intravenous", "Immediately", flurouracilDose, "Unit(s)", 4, "Hour(s)", "with Dextrox 5% (Injection)"));
            drugOrders.add(createUniformDrugOrder("Dextrox 5%", "Injection", 500.0, "ml", "Intravenous", "Immediately", 0, "Unit(s)", 1, "Day(s)", "diluent"));
            drugOrders.add(createVariableDrugOrder("Ondan Setron 4mg", "Tablet", 1, 0, 1, "Tablet(s)", "Oral", null, 6, "Tablet(s)", 3, "Day(s)", null));
            drugOrders.add(createVariableDrugOrder("Chlorpromazine 50mg", "Tablet", 0.5, 0, 0.5, "Tablet(s)", "Oral", null, 5, "Tablet(s)", 5, "Day(s)", null));
            drugOrders.add(createUniformDrugOrder("Tamoxifen 10mg", "Tablet", 2, "Tablet(s)", "Oral", "Once a day", 120, "Tablet(s)", 2, "Month(s)", null));
            drugOrders.add(createUniformDrugOrder("B-Complex", "Tablet", 1, "Tablet(s)", "Oral", "Once a day", 30, "Tablet(s)", 1, "Month(s)", null));
            drugOrders.add(createUniformDrugOrder("Ferrous Sulphate with Folic Acid Large", "Tablet", 1, "Tablet(s)", "Oral", "Once a day", 30, "Tablet(s)", 1, "Month(s)", null));
        }
        bahmniEncounterTransaction.setDrugOrders(drugOrders);

        return bahmniEncounterTransaction;
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
        double percentageAmputated = percentageAmputatedObservation != null && StringUtils.isNotBlank(percentageAmputatedObservation.getValue()) ? (Double.parseDouble((String) percentageAmputatedObservation.getValue())) : 0;
        return Math.round(referenceDose * bsa * (100 - percentageAmputated) / 100);
    }

    private BahmniObservation findObservation(String conceptName, List<BahmniObservation> bahmniObservations) {

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

    static Double fetchLatestValue(String conceptName, String patientUuid) {
        SessionFactory sessionFactory = Context.getRegisteredComponents(SessionFactory.class).get(0)
        Query queryToGetObservations = sessionFactory.getCurrentSession()
                .createQuery("select obs " +
                " from Obs as obs, ConceptName as cn " +
                " where obs.person.uuid = :patientUuid " +
                " and cn.concept = obs.concept.conceptId " +
                " and cn.name = :conceptName " +
                " and obs.voided = false" +
                " order by obs.obsDatetime desc limit 1");
        queryToGetObservations.setString("patientUuid", patientUuid);
        queryToGetObservations.setParameterList("conceptName", conceptName);
        List<Obs> observations = queryToGetObservations.list();
        if (observations.size() > 0) {
            return observations.get(0).getValueNumeric();
        }
        return null
    }

    //Calculation of BSA by Du Bois Formula: http://www.cato.eu/body-surface-area.html
    static Double calculateBSA(double height, double weight, int patientAgeInYears) {
        if (patientAgeInYears <= 15 && weight <= 40) {
            return Math.sqrt(weight * height / 3600);
        }
        return Math.pow(weight, 0.425) * Math.pow(height, 0.725) * 0.007184;
    }

    private
    static EncounterTransaction.DrugOrder createUniformDrugOrder(String drugName, String drugForm, Double dose,
                                                                 String doseUnits, String route, String frequency, Double quantity,
                                                                 String quantityUnit, Integer duration, String durationUnits, String additionalInstructions) {
        def drugOrder = createDrugOrder(drugName, drugForm, doseUnits, route, frequency, quantity, quantityUnit, duration, durationUnits, additionalInstructions)
        drugOrder.dosingInstructions.dose = dose;
        if (additionalInstructions != null) {
            def instructions = ["additionalInstructions": additionalInstructions]
            def administrationInstructions = convertToJSON(instructions);
            drugOrder.dosingInstructions.setAdministrationInstructions(administrationInstructions);
        }
        return drugOrder;
    }


    private
    static EncounterTransaction.DrugOrder createVariableDrugOrder(String drugName, String drugForm, Double morningDose, Double afternoonDose, Double eveningDose,
                                                                  String doseUnits, String route, String frequency, Double quantity, String quantityUnit,
                                                                  Integer duration, String durationUnits, String additionalInstructions) {
        def drugOrder = createDrugOrder(drugName, drugForm, doseUnits, route, frequency, quantity, quantityUnit, duration, durationUnits, additionalInstructions)
        def doses = ["morningDose": morningDose, "afternoonDose": afternoonDose, "eveningDose": eveningDose];
        if (additionalInstructions != null) {
            doses.put("additionalInstructions", additionalInstructions);
        }
        def administrationInstructions = convertToJSON(doses);
        drugOrder.dosingInstructions.setAdministrationInstructions(administrationInstructions);
        return drugOrder;
    }

    private static String convertToJSON(LinkedHashMap<String, Double> doses) {
        objectMapper.writeValueAsString(doses)
    }

    private
    static EncounterTransaction.DrugOrder createDrugOrder(String drugName, String drugForm, String doseUnits, String route, String frequency, double quantity, String quantityUnit, int duration, String durationUnits, String additionalInstructions) {
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
        dosingInstructions.setQuantity(quantity);
        dosingInstructions.setQuantityUnits(quantityUnit);
        dosingInstructions.setAsNeeded(false);
        drugOrder.setDosingInstructions(dosingInstructions);

        drugOrder.setDuration(duration);
        drugOrder.setDurationUnits(durationUnits);

        return drugOrder;
    }
}
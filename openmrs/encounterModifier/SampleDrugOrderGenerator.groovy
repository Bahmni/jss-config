import org.bahmni.module.bahmnicore.contract.encounter.data.ConceptData
import org.bahmni.module.bahmnicore.encounterModifier.EncounterModifier
import org.codehaus.jackson.map.ObjectMapper
import org.codehaus.jackson.type.TypeReference
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

    public BahmniEncounterTransaction run(BahmniEncounterTransaction bahmniEncounterTransaction, ConceptData conceptSetData) {

        Patient patient = Context.getPatientService().getPatientByUuid(bahmniEncounterTransaction.getPatientUuid());
        def nowAsOfEncounter = bahmniEncounterTransaction.getEncounterDateTime() != null ? bahmniEncounterTransaction.getEncounterDateTime() : new Date();
        def patientAgeInYears = Years.yearsBetween(new LocalDate(patient.getBirthdate()), new LocalDate(nowAsOfEncounter)).getYears();

        def height = fetchLatestValue("Height", bahmniEncounterTransaction.getPatientUuid());
        def weight = fetchLatestValue("Weight", bahmniEncounterTransaction.getPatientUuid());
        def bsa = calculateBSA(height, weight, patientAgeInYears);

        ObjectMapper objectMapper = new ObjectMapper();
        bahmniEncounterTransaction = objectMapper.convertValue(bahmniEncounterTransaction, new TypeReference<BahmniEncounterTransaction>() {
        });

        List<BahmniObservation> bahmniObservations = bahmniEncounterTransaction.getObservations();

        BahmniObservation regimenObservation = findObservation("Breast Cancer Regimen 2", bahmniObservations);

        if (regimenObservation == null || regimenObservation.getValue() == null) {
            return bahmniEncounterTransaction;
        }

        BahmniObservation percentageAmputatedObservation = findObservation("Percentage Amputated", bahmniObservations);

        List<EncounterTransaction.DrugOrder> drugOrders = bahmniEncounterTransaction.getDrugOrders();
        if ("CAF (6 cycles)".equals(getCodedObsValue(regimenObservation.getValue()))) {
            drugOrders.add(getDrugOrder("DNS", "Injection", 1000.0, "ml", "Intravenous", "Immediately", null, 2.0, "Unit(s)", 4, "Hour(s)", null));
            drugOrders.add(getDrugOrder("Dexamethasone 8mg/2ml", "Injection", 2.0, "ml", "Intravenous", "Immediately", null, 1.0, "Unit(s)", 1, "Hour(s)", null));
            drugOrders.add(getDrugOrder("Ondansetron 8mg/4ml", "Injection", 2.0, "ml", "Intravenous", "Immediately", null, 1.0, "Unit(s)", 1, "Hour(s)", null));
            def cyclophosphamideDose = calculateDose(600.0, bsa, percentageAmputatedObservation);
            drugOrders.add(getDrugOrder("Cyclophosphamide 500mg", "Injection", cyclophosphamideDose, "ml", "Intravenous", "Immediately", null, Math.round(cyclophosphamideDose), "Unit(s)", 4, "Hour(s)", "with Dextrox 5% (Injection)"));
            def doxorubicinHydrochlorideDose = calculateDose(600.0, bsa, percentageAmputatedObservation);
            drugOrders.add(getDrugOrder("Doxorubicin Hydrochloride 50mg", "Injection", doxorubicinHydrochlorideDose, "ml", "Intravenous", "Immediately", null, Math.round(doxorubicinHydrochlorideDose), "Unit(s)", 4, "Hour(s)", "with Dextrox 5% (Injection)"));
            def flurouracilDose = calculateDose(50.0, bsa, percentageAmputatedObservation);
            drugOrders.add(getDrugOrder("Flurouracil 10ml", "Injection", flurouracilDose, "ml", "Intravenous", "Immediately", null, Math.round(flurouracilDose), "Unit(s)", 4, "Hour(s)", "with Dextrox 5% (Injection)"));
            drugOrders.add(getDrugOrder("Dextrox 5%", "Injection", 500.0, "ml", "Intravenous", "Immediately", null, 0, "Unit(s)", 1, "Day(s)", "diluent"));
            drugOrders.add(getDrugOrder("Ondan Setron 4mg", "Tablet", null, "Tablet(s)", "Oral", null, "{\"morningDose\":1,\"afternoonDose\":0,\"eveningDose\":1}", 6, "Tablet(s)", 3, "Day(s)", null));
            drugOrders.add(getDrugOrder("Chlorpromazine 50mg", "Tablet", null, "Tablet(s)", "Oral", null, "{\"morningDose\":0.5,\"afternoonDose\":0,\"eveningDose\":0.5}", 5, "Tablet(s)", 10, "Day(s)", null));
            drugOrders.add(getDrugOrder("Tamoxifen 10mg", "Tablet", 2, "Tablet(s)", "Oral", "Once a day", null, 120, "Tablet(s)", 2, "Month(s)", null));
            drugOrders.add(getDrugOrder("B-Complex", "Tablet", 1, "Tablet(s)", "Oral", "Once a day", null, 30, "Tablet(s)", 1, "Month(s)", null));
            drugOrders.add(getDrugOrder("Ferrous Sulphate with Folic Acid Large", "Tablet", 1, "Tablet(s)", "Oral", "Once a day", null, 30, "Tablet(s)", 1, "Month(s)", null));
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
        double percentageAmputated = percentageAmputatedObservation != null && percentageAmputatedObservation.getValue() != null ? (Double.parseDouble((String)percentageAmputatedObservation.getValue())) : 0;
        return referenceDose * bsa * (100 - percentageAmputated) / 100;
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

    static Double calculateBSA(double height, double weight, int patientAgeInYears) {
        if (patientAgeInYears <= 15 && weight <= 40) {
            return Math.sqrt(weight * height / 3600);
        }
        return Math.pow(weight, 0.425) * Math.pow(height, 0.725) * 0.007184;
    }

    private
    static EncounterTransaction.DrugOrder getDrugOrder(String drugName, String drugForm, Double dose, String doseUnits,
                                                       String route, String frequency,
                                                       String administrationInstructions, Double quantity,
                                                       String quantityUnit, Integer duration, String durationUnits,
                                                       String additionalInstructions) {
        EncounterTransaction.DrugOrder drugOrder = new EncounterTransaction.DrugOrder();
        EncounterTransaction.Drug drug = new EncounterTransaction.Drug();
        drug.setName(drugName);
        drug.setForm(drugForm);
        drugOrder.setDrug(drug);
        drugOrder.setCareSetting("Outpatient");
        drugOrder.setOrderType("Drug Order");
        drugOrder.setDosingInstructionType("org.openmrs.module.bahmniemrapi.drugorder.dosinginstructions.FlexibleDosingInstructions");

        EncounterTransaction.DosingInstructions dosingInstructions = new EncounterTransaction.DosingInstructions();
        dosingInstructions.setDose(dose);
        dosingInstructions.setDoseUnits(doseUnits);
        dosingInstructions.setRoute(route);
        dosingInstructions.setFrequency(frequency);
        dosingInstructions.setAdministrationInstructions(administrationInstructions);
        dosingInstructions.setQuantity(quantity);
        dosingInstructions.setQuantityUnits(quantityUnit);
        dosingInstructions.setAsNeeded(false);
        drugOrder.setDosingInstructions(dosingInstructions);

        drugOrder.setDuration(duration);
        drugOrder.setDurationUnits(durationUnits);

        drugOrder.setInstructions(additionalInstructions);

        return drugOrder;
    }
}
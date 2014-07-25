import com.oracle.javafx.jmx.json.JSONDocument
import org.codehaus.jackson.map.util.JSONPObject
import org.hibernate.Query
import org.hibernate.SessionFactory
import org.openmrs.Obs
import org.openmrs.api.context.Context
import org.openmrs.module.bahmniemrapi.obscalculator.ObsValueCalculator;
import org.openmrs.module.bahmniemrapi.encountertransaction.contract.BahmniEncounterTransaction
import org.openmrs.module.emrapi.encounter.domain.EncounterTransaction;
import groovy.json.*


public class BahmniObsValueCalculator implements ObsValueCalculator {

    static int BMI_VERY_SEVERELY_UNDERWEIGHT = 16;
    static int BMI_SEVERELY_UNDERWEIGHT = 17;
    static int BMI_UNDERWEIGHT = 18.5;
    static int BMI_NORMAL = 25;
    static int BMI_OVERWEIGHT = 30;
    static int BMI_OBESE = 35;
    static int BMI_SEVERELY_OBESE = 40;

    public void run(BahmniEncounterTransaction bahmniEncounterTransaction) {
        setBMI(bahmniEncounterTransaction);
    }

    static def setBMI(BahmniEncounterTransaction bahmniEncounterTransaction) {
        List<EncounterTransaction.Observation> observations = bahmniEncounterTransaction.getObservations()

        EncounterTransaction.Observation heightObservation = find("HEIGHT", observations)
        EncounterTransaction.Observation weightObservation = find("WEIGHT", observations)
        if (heightObservation || weightObservation) {

            EncounterTransaction.Observation nutritionLevelsObservation = find("Nutritional Levels", observations)

            Double height = heightObservation != null ? heightObservation.getValue() as Double : fetchLatestValue("HEIGHT", bahmniEncounterTransaction.getPatientUuid()) 
            Double weight = weightObservation != null ? weightObservation.getValue() as Double : fetchLatestValue("WEIGHT", bahmniEncounterTransaction.getPatientUuid())
            if(height == null || weight == null) return 
            def bmi = bmi(height, weight)
            EncounterTransaction.Observation bmiObservation = find("BMI", observations) ?: createObs("BMI", nutritionLevelsObservation)
            bmiObservation.setValue(bmi);
            bmiObservation.setComment([height: height, weight: weight, bmi: bmi].toString())
            
            EncounterTransaction.Observation bmiStatusObservation = find("BMI STATUS", observations) ?: createObs("BMI STATUS", nutritionLevelsObservation)
            def bmiStatus = bmiStatus(bmi);
            bmiStatusObservation.setValue(bmiStatus);
            bmiStatusObservation.setComment([height: height, weight: weight, bmi: bmi, bmiStatus: bmiStatus].toString())
        }
    }

    static EncounterTransaction.Observation createObs(String conceptName, EncounterTransaction.Observation parent) {
        def concept = Context.getConceptService().getConceptByName(conceptName)
        EncounterTransaction.Observation newObservation = new EncounterTransaction.Observation()
        newObservation.setConcept(new EncounterTransaction.Concept(concept.getUuid(), conceptName))
        
        parent.addGroupMember(newObservation);
        return newObservation
    }

    static def bmi(Double height, Double weight) {
        Double heightInMeters = height / 100;
        Double value = weight / (heightInMeters * heightInMeters);
        return new BigDecimal(value).setScale(2, BigDecimal.ROUND_HALF_UP).doubleValue();
    };

    static def bmiStatus(Double bmi) {
        if (bmi < BMI_VERY_SEVERELY_UNDERWEIGHT) {
            return 'Very Severely Underweight';
        }
        if (bmi < BMI_SEVERELY_UNDERWEIGHT) {
            return 'Severely Underweight';
        }
        if (bmi < BMI_UNDERWEIGHT) {
            return 'Underweight';
        }
        if (bmi < BMI_NORMAL) {
            return 'Normal';
        }
        if (bmi < BMI_OVERWEIGHT) {
            return 'Overweight';
        }
        if (bmi < BMI_OBESE) {
            return 'Obese';
        }
        if (bmi < BMI_SEVERELY_OBESE) {
            return 'Severely Obese';
        }
        if (bmi >= BMI_SEVERELY_OBESE) {
            return 'Very Severely Obese';
        }
        return null
    };

    public static Double fetchLatestValue(String conceptName, String patientUuid) {
        SessionFactory sessionFactory = Context.getRegisteredComponents(SessionFactory.class).get(0)
        Query queryToGetObservations = sessionFactory.getCurrentSession().createQuery(
                "select obs " +
                        " from Obs as obs, ConceptName as cn " +
                        " where obs.person.uuid = :patientUuid " +
                        " and cn.concept = obs.concept.conceptId " +
                        " and cn.name = :conceptName " +
                        " order by obs.obsDatetime desc limit 1");
        queryToGetObservations.setString("patientUuid", patientUuid);
        queryToGetObservations.setParameterList("conceptName", conceptName);
        List<Obs> observations = queryToGetObservations.list();
        if (observations.size() > 0) {
            return observations.get(0).getValueNumeric();
        }
        return null
    }

    static EncounterTransaction.Observation find(def conceptName, List<EncounterTransaction.Observation> observations) {
        for (EncounterTransaction.Observation observation : observations) {
            if (conceptName.equals(observation.getConcept().getName()) && !observation.getVoided()) {
                return observation;
            }
            EncounterTransaction.Observation matchingObservation = find(conceptName, observation.getGroupMembers())
            if (matchingObservation) return matchingObservation;
        }
        return null
    }
}
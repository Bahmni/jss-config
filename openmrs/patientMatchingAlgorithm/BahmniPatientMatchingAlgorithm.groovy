import org.bahmni.module.admin.csv.patientmatchingalgorithm.PatientMatchingAlgorithm
import org.openmrs.Patient;


public class BahmniPatientMatchingAlgorithm implements PatientMatchingAlgorithm{


    @Override
    Patient run(List<Patient> patientList, List<org.bahmni.csv.KeyValue> patientAttributes) {
        return null
    }
}
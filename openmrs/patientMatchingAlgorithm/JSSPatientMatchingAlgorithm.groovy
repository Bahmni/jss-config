import org.bahmni.csv.KeyValue
import org.bahmni.module.admin.csv.patientmatchingalgorithm.PatientMatchingAlgorithm
import org.bahmni.module.admin.csv.patientmatchingalgorithm.exception.CannotMatchPatientException
import org.openmrs.Patient

public class JSSPatientMatchingAlgorithm extends PatientMatchingAlgorithm {
    @Override
    Patient run(List<Patient> patientList, List<KeyValue> patientAttributes) {
        String genderFromCSV = valueFor("Gender", patientAttributes);
        String nameFromCSV = valueFor("Name", patientAttributes);

        List<Patient> matchingPatients = new ArrayList<Patient>();
        if (patientList == null || patientList.size() < 1) {
            throw new CannotMatchPatientException();
        }
        for (Patient patient : patientList) {
            if (matchGenderAndName(patient, genderFromCSV, nameFromCSV)) {
                matchingPatients.add(patient);
            }
        }
        if (matchingPatients.size() == 1) {
            return matchingPatients.get(0);
        } else if (matchingPatients.size() > 1) {
            throw new CannotMatchPatientException(matchingPatients);
        } else {
            throw new CannotMatchPatientException(patientList);
        }
    }

    private boolean matchGenderAndName(Patient patient, String genderFromCSV, String nameFromCSV) {
        return patient.getGender().equalsIgnoreCase(genderFromCSV) &&
                doesAnyNamePartMatch(patient, nameFromCSV);
    }

    private boolean doesAnyNamePartMatch(Patient patient, String uploadedPatientName) {
        def nameParts = uploadedPatientName.split(" ");
        return nameParts.any { it.equalsIgnoreCase(patient.getGivenName()) } ||
               nameParts.any { it.equalsIgnoreCase(patient.getFamilyName()) }
    }
}
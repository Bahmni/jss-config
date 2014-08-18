import org.bahmni.csv.KeyValue
import org.bahmni.module.admin.csv.patientmatchingalgorithm.PatientMatchingAlgorithm
import org.bahmni.module.admin.csv.patientmatchingalgorithm.exception.CannotMatchPatientException
import org.openmrs.Patient


public class JSSPatientMatchingAlgorithm implements PatientMatchingAlgorithm {
    private Map<String, String> patientAttributesMap;


    @Override
    Patient run(List<Patient> patientList, List<KeyValue> patientAttributes) {
        patientAttributesMap = getPatientAttributes(patientAttributes);
        List<Patient> matchingPatients = new ArrayList<Patient>();
        if (patientList == null || patientList.size() < 1) {
            throw new CannotMatchPatientException();
        }
        for (Patient patient : patientList) {
            if (fitsCriteria(patient)) {
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

    private boolean fitsCriteria(Patient patient) {
        if (isGenderSame(patient.getGender())) {
            if (isNameSame(patient)) {
                return true;
            }
        }
        return false;
    }

    private boolean isNameSame(Patient patient) {
        String uploadedPatientName = patientAttributesMap.get("Name");
        def givenName = patient.getGivenName();
        def familyName = patient.getFamilyName();
        if (uploadedPatientName.contains(givenName) ||
                uploadedPatientName.contains(familyName)) {
            return true;
        }
        return false;
    }

    private boolean isGenderSame(String gender) {
        if (gender.equals(patientAttributesMap.get("Gender"))) {
            return true;
        }
        return false;
    }

    private Map<String, String> getPatientAttributes(List<KeyValue> patientAttributes) {
        Map<String, String> patientAttributeMap = new HashMap<String, String>();
        for (KeyValue patientAttribute : patientAttributes) {
            patientAttributeMap.put(patientAttribute.getKey(), patientAttribute.getValue());
        }
        return patientAttributeMap;
    }
}
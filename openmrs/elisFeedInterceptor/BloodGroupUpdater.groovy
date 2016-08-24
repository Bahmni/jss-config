import org.bahmni.module.bahmnicore.service.impl.BahmniBridge
import org.openmrs.*
import org.bahmni.module.elisatomfeedclient.api.elisFeedInterceptor.ElisFeedEncounterInterceptor;
import java.util.Locale
import java.util.Set

public class BloodGroupUpdater implements ElisFeedEncounterInterceptor {
    public static final String BLOOD_GROUP_TEST_NAME = "Patient Blood Group";
    public static final String BLOOD_GROUP_PATIENT_ATTRIBUTE_TYPE = "bloodGroup";
    public BahmniBridge bahmniBridge;

    @Override
    public void run(Set<Encounter> encounters) {
        Obs bloodGroupObs = getBloodGroupObs(encounters);
        System.out.println(bloodGroupObs);
        if (bloodGroupObs == null) {
            return;
        }

        Patient patient = bloodGroupObs.getOrder().getPatient();
        this.bahmniBridge = BahmniBridge.create();

        PersonAttributeType personAttributeType = bahmniBridge.getPersonAttributeType(BLOOD_GROUP_PATIENT_ATTRIBUTE_TYPE);
        Concept resultConcept = bahmniBridge.getConcept(bloodGroupObs.getValueText());
        String value = resultConcept != null ? resultConcept.getId().toString() : null;

        if (isPatientAlreadyHaveAttribute(patient, personAttributeType)) {
            patient.getAttribute(personAttributeType).setValue(value);
        } else {
            patient.addAttribute(createPersonAttribute(personAttributeType, value));
        }
    }

    private PersonAttribute createPersonAttribute(PersonAttributeType personAttributeType, String value) {
        PersonAttribute attribute = new PersonAttribute();
        attribute.setAttributeType(personAttributeType);
        attribute.setValue(value);
        return attribute;
    }

    private boolean isPatientAlreadyHaveAttribute(Patient patient, PersonAttributeType personAttributeType) {
        return patient.getAttribute(personAttributeType) != null;
    }

    private Obs getBloodGroupObs(Set<Encounter> encounters) {
        for (Encounter encounter : encounters) {
            for (Obs obs : encounter.getObs()) {
                if (obs.getOrder() != null && obs.getConcept().getFullySpecifiedName(Locale.ENGLISH).getName().equals(BLOOD_GROUP_TEST_NAME)
                        && obs.getOrder().getConcept().getUuid().equals(obs.getConcept().getUuid())) {
                    return obs;
                }
            }
        }
        return null;
    }
}

import org.bahmni.module.bahmnicore.contract.encounter.data.EncounterModifierData
import org.bahmni.module.bahmnicore.contract.encounter.data.EncounterModifierObservation
import org.bahmni.module.bahmnicore.encounterModifier.EncounterModifier
import org.bahmni.module.bahmnicore.service.impl.BahmniBridge
import org.openmrs.module.emrapi.encounter.domain.EncounterTransaction

public class BloodGroup extends EncounterModifier {

    public static final String BLOOD_GROUP_CONCEPT_NAME = "bloodGroup"
    public BahmniBridge bahmniBridge;

    public EncounterModifierData run(EncounterModifierData encounterModifierData) {

        this.bahmniBridge = BahmniBridge
                .create()
                .forPatient(encounterModifierData.getPatientUuid());
                .updatePatientAttributeType(BLOOD_GROUP_CONCEPT_NAME);

        Collection<EncounterModifierObservation> bloodGroupObservations;

        Collection<EncounterModifierObservation> bahmniObservations = encounterModifierData.getEncounterModifierObservations();

        EncounterModifierObservation bloodGroupObservation = findObservation(BLOOD_GROUP_CONCEPT_NAME, bahmniObservations);

        if (bloodGroupObservation != null || bloodGroupObservation.getValue() != null) {
            bloodGroupObservations.add(bloodGroupObservation);
        }
        
        encounterModifierData.setEncounterModifierObservations(bloodGroupObservations);
       
        return encounterModifierData;
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
}

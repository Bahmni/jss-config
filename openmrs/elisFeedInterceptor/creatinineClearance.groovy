import org.bahmni.module.bahmnicore.service.impl.BahmniBridge
import org.openmrs.*
import org.openmrs.module.bahmniemrapi.elisFeedInterceptor.ElisFeedInterceptor
import java.util.Locale
import java.util.Set


public class CreatinineUpdate implements ElisFeedInterceptor {
    public static final String BLOOD_GROUP_TEST_NAME = "Culture (Urine)";
    public static final String CREATINIE_CLEARANCE_TEST_NAME = "Colour (Urine)";

    public void run(Set<Encounter> encounters) {
        Obs creatinineObs = getCreatinineObs(encounters);

    }

    private Obs getCreatinineObs(Set<Encounter> encounters) {
        for (Encounter encounter : encounters) {
            println("IN the first for loop");
            for (Obs obs : encounter.getObs()) {
                if (obs.getOrder() != null && obs.getConcept().getFullySpecifiedName(Locale.ENGLISH).getName().equals(BLOOD_GROUP_TEST_NAME)
                        && obs.getOrder().getConcept().getUuid().equals(obs.getConcept().getUuid())) {

                    Concept creatinineClearanceRateConcept = BahmniBridge.create().getConcept(CREATINIE_CLEARANCE_TEST_NAME);
//                    Order order = new Order();
//                    order.setOrderType(obs.getOrder().getOrderType());
//                    order.setConcept(creatinineClearanceRateConcept);
//                    order.setOrderer(obs.getOrder().getOrderer());
//                    order.setCareSetting(obs.getOrder().getCareSetting());
//                    order.setEncounter(encounter);
//                    encounter.addOrder(order);

                    Obs creatinineClearanceObs = new Obs();
                    creatinineClearanceObs.setConcept(creatinineClearanceRateConcept);
                    creatinineClearanceObs.setValueText(obs.getValueText() + "i have modified");
                    creatinineClearanceObs.setOrder(new Order());
                    encounter.addObs(creatinineClearanceObs);
                    return creatinineClearanceObs;


                }
            }
        }
        return null;
    }

}
import org.bahmni.module.bahmnicore.service.impl.BahmniBridge
import org.openmrs.*
import org.openmrs.module.bahmniemrapi.elisFeedInterceptor.ElisFeedInterceptor
import java.util.Locale
import java.util.Set
import org.openmrs.api.OrderContext;
import org.openmrs.api.context.Context;



public class CreatinineUpdate implements ElisFeedInterceptor {
    public static final String CREATININE_TEST_NAME = "Creatinine";
    public static final String CREATINIE_CLEARANCE_TEST_NAME = "Creatinine Clearance";
    public static final String HEIGHT_CONCEPT_NAME = "HEIGHT";
    public static final String WEIGHT_CONCEPT_NAME = "WEIGHT";
    public BahmniBridge bahmniBridge;

    public void run(Set<Encounter> encounters) {
        Obs creatinineObs = getCreatinineObs(encounters);
    }

    private Obs getCreatinineObs(Set<Encounter> encounters) {
        for (Encounter encounter : encounters) {

            println("IN the first for loop");
            for (Obs obs : encounter.getObs()) {
                if (obs.getOrder() != null && obs.getConcept().getFullySpecifiedName(Locale.ENGLISH).getName().equals(CREATININE_TEST_NAME)
                        && obs.getOrder().getConcept().getUuid().equals(obs.getConcept().getUuid())) {

                    Concept creatinineClearanceRateConcept = BahmniBridge.create().getConcept(CREATINIE_CLEARANCE_TEST_NAME);
                    Order order = new Order();
                    order.setOrderType(obs.getOrder().getOrderType());
                    order.setConcept(creatinineClearanceRateConcept);
                    order.setOrderer(obs.getOrder().getOrderer());
                    order.setCareSetting(obs.getOrder().getCareSetting());
                    order.setAccessionNumber(obs.getAccessionNumber());
                    order.setEncounter(encounter);
                    order.setPatient(obs.getOrder().getPatient());
                    OrderContext orderCtx = new OrderContext();
                    orderCtx.setCareSetting(obs.getOrder().getCareSetting());
                    orderCtx.setOrderType(obs.getOrder().getOrderType());
                    Context.getOrderService().saveOrder(order,orderCtx);
                    encounter.addOrder(order);
                    Obs creatinineClearanceObs = getObs(obs, creatinineClearanceRateConcept,order);
                    Obs creatinineClearanceObsOne = getObs(obs, creatinineClearanceRateConcept,order);
                    creatinineClearanceObsOne.setObsGroup(creatinineClearanceObs);
                    Obs creatinineClearanceObsTwo = getObs(obs, creatinineClearanceRateConcept,order);


                    creatinineClearanceObsTwo.setObsGroup(creatinineClearanceObsOne);

                    encounter.addObs(creatinineClearanceObs);
                    encounter.addObs(creatinineClearanceObsOne);
                    encounter.addObs(creatinineClearanceObsTwo);
                    Context.getEncounterService().saveEncounter(encounter);
                    return creatinineClearanceObs;


                }
            }
        }
        return null;
    }

    private Obs getObs(Obs obs, Concept creatinineClearanceRateConcept, Order order) {

        this.bahmniBridge = BahmniBridge.create().forPatient(obs.getPerson().getUuid());
        Obs weighttval=bahmniBridge.latestObs(WEIGHT_CONCEPT_NAME);
        Integer personage = obs.getPerson().getAge();
        String gender = obs.getPerson().getGender();
        double CreatinineClearanceRate = 0.0;

        if (gender.equals('M')) {
            CreatinineClearanceRate = ((140 - (personage * weighttval.getValueNumeric())) / (72 * (obs.getValueNumeric())));
        } else if (gender.equals('F')) {
            CreatinineClearanceRate = (((140 - (personage * weighttval.getValueNumeric())) / (72 * (obs.getValueNumeric()))) * 0.85);
        }


        Obs creatinineClearanceObs = new Obs();
        creatinineClearanceObs.setConcept(creatinineClearanceRateConcept);
        creatinineClearanceObs.setValueNumeric(CreatinineClearanceRate);
        creatinineClearanceObs.setOrder(order);
        return creatinineClearanceObs;
    }

}

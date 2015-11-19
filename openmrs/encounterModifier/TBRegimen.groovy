import org.apache.commons.collections.Predicate
import org.openmrs.module.emrapi.encounter.domain.EncounterTransaction

import static org.apache.commons.collections.CollectionUtils.filter

public static class TBRegimen {


    public
    static void generateDrugsForFollowup(String regimenName, String followUp, Boolean isAdult, double weight, double bmi, List<EncounterTransaction.DrugOrder> drugOrders) {
        String subRegimen = null;
        switch (regimenName) {
            case "2HRZE + 4HR":
                switch (followUp) {
                    case "1 Month":
                        subRegimen = "HRZE";
                        break;
                    case "2 Month":
                    case "3 Month":
                    case "4 Month":
                    case "5 Month":
                    case "6 Month":
                        subRegimen = "HR";
                }
                break;
            case "3HRZE + 6HRE":
                switch (followUp) {
                    case "1 Month":
                    case "2 Month":
                        subRegimen = "HRZE";
                        break;
                    case "3 Month":
                    case "4 Month":
                    case "5 Month":
                    case "6 Month":
                    case "7 Month":
                    case "8 Month":
                    case "9 Month":
                        subRegimen = "HRE";
                }
                break;
            case "12RZFqE":
                switch (followUp) {
                    case "1 Month":
                    case "2 Month":
                    case "3 Month":
                    case "4 Month":
                    case "5 Month":
                    case "6 Month":
                    case "7 Month":
                    case "8 Month":
                    case "9 Month":
                    case "10 Month":
                    case "11 Month":
                    case "12 Month":
                        subRegimen = "RZFqE";
                }
                break;
            case "9H":
                switch (followUp) {
                    case "1 Month":
                    case "2 Month":
                    case "3 Month":
                    case "4 Month":
                    case "5 Month":
                    case "6 Month":
                    case "7 Month":
                    case "8 Month":
                    case "9 Month":
                        subRegimen = "H";
                }
                break;
            case "Tuberculosis, Other Treatment Plan":
                drugOrders.clear();
                return;
        }
        if (subRegimen == null) {
            throw new RuntimeException("Follow up cycle " + followUp + " not applicable for regimen " + regimenName);
        }
        generateDrugsForSubRegimen(subRegimen, weight, bmi, isAdult, drugOrders);
        filterDrugOrdersWithBaseDoseNotSet(drugOrders);
    }

    public
    static void generateDrugsForIntake(String regimenName, Boolean isAdult, double weight, double bmi, List<EncounterTransaction.DrugOrder> drugOrders) {
        String subRegimen = null;
        switch (regimenName) {
            case "2HRZE + 4HR":
            case "3HRZE + 6HRE":
                subRegimen = "HRZE"
                break;
            case "12RZFqE":
                subRegimen = "RZFqE"
                break;
            case "9H":
                subRegimen = "H"
                break;
            case "Tuberculosis, Other Treatment Plan":
                drugOrders.clear();
                return;
        }
        generateDrugsForSubRegimen(subRegimen, weight, bmi, isAdult, drugOrders);
        filterDrugOrdersWithBaseDoseNotSet(drugOrders);
    }

    public static EncounterTransaction.DrugOrder chanaSupplement(){
        EncounterTransaction.DrugOrder chanaDrugOrder = new EncounterTransaction.DrugOrder();
        chanaDrugOrder.setDrug(new EncounterTransaction.Drug());
        chanaDrugOrder.setDosingInstructions(new EncounterTransaction.DosingInstructions());

        chanaDrugOrder.getDrug().setName("Chana");
        chanaDrugOrder.getDrug().setForm("Food Supplement");
        chanaDrugOrder.getDosingInstructions().setAsNeeded(false);


        chanaDrugOrder.getDosingInstructions().setFrequency("Twice a day");
        chanaDrugOrder.getDosingInstructions().setRoute("Oral");
        chanaDrugOrder.getDosingInstructions().setQuantity(2.0);
        chanaDrugOrder.getDosingInstructions().setQuantityUnits("Unit(s)");

        chanaDrugOrder.setDuration(30);
        chanaDrugOrder.setDurationUnits("Day(s)");

        return chanaDrugOrder;
    }


    private static filterDrugOrdersWithBaseDoseNotSet(List<EncounterTransaction.DrugOrder> drugOrders) {
        filter(drugOrders, new Predicate() {
            @Override
            boolean evaluate(Object drugOrder) {
                return drugOrder.getDosingInstructions().getDose() != null || areSameDrugNames(drugOrder, "Chana")
            }
        })
    }

    public
    static void generateDrugsForSubRegimen(String subRegimen, double weight, double bmi, Boolean isAdult, List<EncounterTransaction.DrugOrder> drugOrders) {
        for (int i = 0; i < subRegimen.length(); i++) {
            setDoseFor(subRegimen.charAt(i), isAdult, weight, bmi, drugOrders);
        }
    }

    private
    static void setDoseFor(Character drugPrefix, boolean isAdult, double weight, double bmi, List<EncounterTransaction.DrugOrder> drugOrders) {
        switch (drugPrefix) {
            case 'H':
                if (isAdult) {
                    if (weight >= 20 && weight < 25) {
                        setDrugDose(drugOrders, "INH", 150);
                    } else if (weight >= 25 && weight < 30) {
                        setDrugDose(drugOrders, "INH", 150);
                    } else if (weight >= 30 && weight < 37) {
                        setDrugDose(drugOrders, "INH", 200);
                    } else if (weight >= 37 && weight < 45) {
                        setDrugDose(drugOrders, "INH", 300);
                    } else if (weight >= 45 && weight < 48) {
                        setDrugDose(drugOrders, "INH", 300);
                    } else if (weight >= 48 && weight < 56) {
                        setDrugDose(drugOrders, "INH", 300);
                    } else if (weight >= 56) {
                        setDrugDose(drugOrders, "INH", 300);
                    }
                } else {
                    if (weight <= 5) {
                        //TODO Compute this
                    } else if (weight > 5 && weight <= 7) {
                        setDrugDose(drugOrders, "INH", 50);
                    } else if (weight > 7 && weight <= 10) {
                        setDrugDose(drugOrders, "INH", 100);
                    } else if (weight > 10 && weight <= 15) {
                        setDrugDose(drugOrders, "INH", 150);
                    } else if (weight > 15 && weight <= 20) {
                        setDrugDose(drugOrders, "INH", 200);
                    } else if (weight > 20 && weight <= 25) {
                        setDrugDose(drugOrders, "INH", 300);
                    } else if (weight > 25 && weight <= 30) {
                        setDrugDose(drugOrders, "INH", 300);
                    } else if (weight > 30 && weight <= 35) {
                        setDrugDose(drugOrders, "INH", 300);
                    }
                }
                if(bmi < 16){
                    setDrugDose(drugOrders, "Pyridoxine", 25);
                } else{
                    setDrugDose(drugOrders, "Pyridoxine", 10);
                }
                break;
            case 'R':
                if (isAdult) {
                    if (weight >= 20 && weight < 25) {
                        setDrugDose(drugOrders, "RIF", 300);
                    } else if (weight >= 25 && weight < 30) {
                        setDrugDose(drugOrders, "RIF", 300);
                    } else if (weight >= 30 && weight < 37) {
                        setDrugDose(drugOrders, "RIF", 450);
                    } else if (weight >= 37 && weight < 45) {
                        setDrugDose(drugOrders, "RIF", 450);
                    } else if (weight >= 45 && weight < 48) {
                        setDrugDose(drugOrders, "RIF", 600);
                    } else if (weight >= 48 && weight < 56) {
                        setDrugDose(drugOrders, "RIF", 600);
                    } else if (weight >= 56) {
                        setDrugDose(drugOrders, "RIF", 600);
                    }
                } else {
                    if (weight <= 5) {
                        //TODO Compute this
                    } else if (weight > 5 && weight <= 7) {
                        setDrugDose(drugOrders, "RIF", 75);
                    } else if (weight > 7 && weight <= 10) {
                        setDrugDose(drugOrders, "RIF", 150);
                    } else if (weight > 10 && weight <= 15) {
                        setDrugDose(drugOrders, "RIF", 150);
                    } else if (weight > 15 && weight <= 20) {
                        setDrugDose(drugOrders, "RIF", 300);
                    } else if (weight > 20 && weight <= 25) {
                        setDrugDose(drugOrders, "RIF", 300);
                    } else if (weight > 25 && weight <= 30) {
                        setDrugDose(drugOrders, "RIF", 450);
                    } else if (weight > 30 && weight <= 35) {
                        setDrugDose(drugOrders, "RIF", 600);
                    }

                }

                break;
            case 'Z':
                if (isAdult) {
                    if (weight >= 20 && weight < 25) {
                        setDrugDose(drugOrders, "PYZ", 625);
                    } else if (weight >= 25 && weight < 30) {
                        setDrugDose(drugOrders, "PYZ", 750);
                    } else if (weight >= 30 && weight < 37) {
                        setDrugDose(drugOrders, "PYZ", 750);
                    } else if (weight >= 37 && weight < 45) {
                        setDrugDose(drugOrders, "PYZ", 1000);
                    } else if (weight >= 45 && weight < 48) {
                        setDrugDose(drugOrders, "PYZ", 1000);
                    } else if (weight >= 48 && weight < 56) {
                        setDrugDose(drugOrders, "PYZ", 1250);
                    } else if (weight >= 56) {
                        setDrugDose(drugOrders, "PYZ", 1500);
                    }
                } else {
                    if (weight <= 5) {
                        //TODO Compute this
                    } else if (weight > 5 && weight <= 7) {
                        setDrugDose(drugOrders, "PYZ", 180);
                    } else if (weight > 7 && weight <= 10) {
                        setDrugDose(drugOrders, "PYZ", 300);
                    } else if (weight > 10 && weight <= 15) {
                        setDrugDose(drugOrders, "PYZ", 375);
                    } else if (weight > 15 && weight <= 20) {
                        setDrugDose(drugOrders, "PYZ", 625);
                    } else if (weight > 20 && weight <= 25) {
                        setDrugDose(drugOrders, "PYZ", 750);
                    } else if (weight > 25 && weight <= 30) {
                        setDrugDose(drugOrders, "PYZ", 1000);
                    } else if (weight > 30 && weight <= 35) {
                        setDrugDose(drugOrders, "PYZ", 1000);
                    }

                }

                break;
            case 'E':
                if (isAdult) {
                    if (weight >= 20 && weight < 25) {
                        setDrugDose(drugOrders, "ETHAM", 500);
                    } else if (weight >= 25 && weight < 30) {
                        setDrugDose(drugOrders, "ETHAM", 600);
                    } else if (weight >= 30 && weight < 37) {
                        setDrugDose(drugOrders, "ETHAM", 600);
                    } else if (weight >= 37 && weight < 45) {
                        setDrugDose(drugOrders, "ETHAM", 800);
                    } else if (weight >= 45 && weight < 48) {
                        setDrugDose(drugOrders, "ETHAM", 800);
                    } else if (weight >= 48 && weight < 56) {
                        setDrugDose(drugOrders, "ETHAM", 800);
                    } else if (weight >= 56) {
                        setDrugDose(drugOrders, "ETHAM", 800);
                    }
                } else {
                    if (weight <= 5) {
                        //TODO Compute this
                    } else if (weight > 5 && weight <= 7) {
                        setDrugDose(drugOrders, "ETHAM", 100);
                    } else if (weight > 7 && weight <= 10) {
                        setDrugDose(drugOrders, "ETHAM", 200);
                    } else if (weight > 10 && weight <= 15) {
                        setDrugDose(drugOrders, "ETHAM", 200);
                    } else if (weight > 15 && weight <= 20) {
                        setDrugDose(drugOrders, "ETHAM", 400);
                    } else if (weight > 20 && weight <= 25) {
                        setDrugDose(drugOrders, "ETHAM", 500);
                    } else if (weight > 25 && weight <= 30) {
                        setDrugDose(drugOrders, "ETHAM", 600);
                    } else if (weight > 30 && weight <= 35) {
                        setDrugDose(drugOrders, "ETHAM", 700);
                    }
                }
                break;
            case 'F':
            case 'q':
                //TODO Add for this drugs
                break;
        }

    }

    private static void setDrugDose(List<EncounterTransaction.DrugOrder> drugOrders, String drugName, int totalDrugDose) {
        switch (drugName) {
            case "INH":
                if (totalDrugDose == 50) {
                    setDoseAndQuantity(drugOrders, "Isoniazid 100mg", 0.5, 15);
                } else if (totalDrugDose == 100) {
                    setDoseAndQuantity(drugOrders, "Isoniazid 100mg", 1, 30);
                } else if (totalDrugDose == 150) {
                    setDoseAndQuantity(drugOrders, "Isoniazid 300mg", 0.5, 15);
                } else if (totalDrugDose == 200) {
                    setDoseAndQuantity(drugOrders, "Isoniazid 100mg", 2, 60);
                } else if (totalDrugDose == 300) {
                    setDoseAndQuantity(drugOrders, "Isoniazid 300mg", 1, 30);
                }
                break;
            case "RIF":
                if (totalDrugDose == 75) {
                    setDoseAndQuantity(drugOrders, "Rifampicin 150mg", 0.5, 30);
                } else if (totalDrugDose == 150) {
                    setDoseAndQuantity(drugOrders, "Rifampicin 150mg", 1, 30);
                } else if (totalDrugDose == 300) {
                    setDoseAndQuantity(drugOrders, "Rifampicin 150mg", 2, 60);
                } else if (totalDrugDose == 450) {
                    setDoseAndQuantity(drugOrders, "Rifampicin 450mg", 1, 30);
                } else if (totalDrugDose == 600) {
                    setDoseAndQuantity(drugOrders, "Rifampicin 450mg", 1, 30);
                    setDoseAndQuantity(drugOrders, "Rifampicin 150mg", 1, 30);
                }
                break;
            case "PYZ":
                if (totalDrugDose == 180) {
                    setDoseAndQuantity(drugOrders, "Pyrazinamide 750mg", 0.25, 8);
                } else if (totalDrugDose == 300) {
                    setDoseAndQuantity(drugOrders, "Pyrazinamide 300mg", 1, 30);
                } else if (totalDrugDose == 375) {
                    setDoseAndQuantity(drugOrders, "Pyrazinamide 750mg", 0.5, 15);
                } else if (totalDrugDose == 625) {
                    setDoseAndQuantity(drugOrders, "Pyrazinamide 500mg", 1.25, 38);
                } else if (totalDrugDose == 750) {
                    setDoseAndQuantity(drugOrders, "Pyrazinamide 750mg", 1, 30);
                } else if (totalDrugDose == 1000) {
                    setDoseAndQuantity(drugOrders, "Pyrazinamide 500mg", 2, 60);
                } else if (totalDrugDose == 1250) {
                    setDoseAndQuantity(drugOrders, "Pyrazinamide 750mg", 1, 30);
                    setDoseAndQuantity(drugOrders, "Pyrazinamide 500mg", 1, 30);
                } else if (totalDrugDose == 1500) {
                    setDoseAndQuantity(drugOrders, "Pyrazinamide 750mg", 2, 60);
                }
                break;
            case "ETHAM":
                if (totalDrugDose == 100) {
                    setDoseAndQuantity(drugOrders, "Ethambutal 200mg", 0.5, 15);
                } else if (totalDrugDose == 200) {
                    setDoseAndQuantity(drugOrders, "Ethambutal 200mg", 1, 30);
                } else if (totalDrugDose == 400) {
                    setDoseAndQuantity(drugOrders, "Ethambutal 200mg", 2, 60);
                } else if (totalDrugDose == 500) {
                    setDoseAndQuantity(drugOrders, "Ethambutal 400mg", 1, 30);
                    setDoseAndQuantity(drugOrders, "Ethambutal 200mg", 0.5, 15);
                } else if (totalDrugDose == 600) {
                    setDoseAndQuantity(drugOrders, "Ethambutal 400mg", 1, 30);
                    setDoseAndQuantity(drugOrders, "Ethambutal 200mg", 1, 30);
                } else if (totalDrugDose == 700) {
                    setDoseAndQuantity(drugOrders, "Ethambutal 400mg", 1, 30);
                    setDoseAndQuantity(drugOrders, "Ethambutal 200mg", 1.5, 45);
                } else if (totalDrugDose == 800) {
                    setDoseAndQuantity(drugOrders, "Ethambutal 800mg", 1, 30);
                }
                break;
            case "Pyridoxine":
                if (totalDrugDose == 10) {
                    setDoseAndQuantity(drugOrders, "Pyridoxine 10mg", 1, 30);
                } else if (totalDrugDose == 25){
                    setDoseAndQuantity(drugOrders, "Pyridoxine 100mg", 0.25, 8);
                }
                break;
        }
    }

    private static void setDoseAndQuantity(List<EncounterTransaction.DrugOrder> drugOrders, String drugName, BigDecimal baseDose, BigDecimal baseQuantity) {
        def drugOrder = getDrugOrder(drugOrders, drugName)
        drugOrder.getDosingInstructions().setDose(baseDose)
        drugOrder.getDosingInstructions().setQuantity(baseQuantity)
    }

    private static EncounterTransaction.DrugOrder getDrugOrder(List<EncounterTransaction.DrugOrder> drugOrders, String drugName) {
        for (EncounterTransaction.DrugOrder drugOrder : drugOrders) {
            if (areSameDrugNames(drugOrder, drugName)) {
                return drugOrder;
            }
        }
        return null;
    }

    private static boolean areSameDrugNames(EncounterTransaction.DrugOrder drugOrder, String drugName){
        return drugOrder.getDrug() ? drugOrder.getDrug().getName().equals(drugName) : drugOrder.getDrugNonCoded().equals(drugName);
    }

}
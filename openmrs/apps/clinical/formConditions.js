Bahmni.ConceptSet.FormConditions.rules = { 
  'RMRCT, Previsiosly treated with TB' : function (formName, formFieldValues) {
	var conditions = {
		enable : [],
		disable : []
	};
	var previousTreatmentWhere = "RMRCT, If treatment taken, Where was the patient treated ?";
	var previousTreamentWhen = "RMRCT, If treatment taken, When was the patient treated ?";
	var previousTreatmentCount = "RMRCT, If treatment taken, How many times was the patient treated ?";
	var previousTreatmentDots = "RMRCT, If treatment taken, If Dots taken : Category";
	var previousTreatmentDrugs = "CDST Form, Drugs used in his treatment";
	var result = formFieldValues['RMRCT, Previsiosly treated with TB'];
	if (result == "Yes") {
		conditions.enable.push(previousTreatmentWhere,previousTreamentWhen,previousTreatmentCount,previousTreatmentDots,previousTreatmentDrugs);
	} else {
		conditions.disable.push(previousTreatmentWhere,previousTreamentWhen,previousTreatmentCount,previousTreatmentDots,previousTreatmentDrugs);
	}
	return conditions;
  }
};
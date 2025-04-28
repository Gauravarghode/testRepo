/*public without sharing class StudentResultsTableController {
	public Id studentId { get; set; }
	public String appType { get; set; }
	public String lan { get; set; }

	public List<Waitlist_School_Ranking__c> wsrs {
		get {
			return new WaitlistSchoolRankingDA().getByStudentIdAndAppType(studentId, appType, Application_Settings__c.getOrgDefaults().Future_School_Year__c);
		}
		set;
	}
} added*/
public without sharing class StudentResultsTableController {
    public Id studentId { get; set; }
    public String appType { get; set; }
    public String lan { get; set; }

    // List to store final results combining wsrs and ineligible applications
    public List<WrapperClass> finalResults {
        get {
            if (finalResults == null) {
                finalResults = new List<WrapperClass>();
                
                // Fetch data from Waitlist_School_Ranking__c
                List<Waitlist_School_Ranking__c> wsrsList = new WaitlistSchoolRankingDA()
                    .getByStudentIdAndAppType(studentId, appType, Application_Settings__c.getOrgDefaults().Future_School_Year__c);

                // Fetch ineligible applications
                List<hed__Application__c> ineligibleApplications = new List<hed__Application__c>();
                for (hed__Application__c app : [
                    SELECT Id, Eligibility_Decision__c, Program_Rank__c, Program__r.Name, 
                           hed__Application_Status__c, hed__Applicant__r.Student__c 
                    FROM hed__Application__c 
                    WHERE hed__Applicant__r.Student__c = :studentId AND Eligibility_Decision__c = :'Ineligible'
                ]) {
                    
                        ineligibleApplications.add(app);
                    
                }

                // Convert wsrsList to WrapperClass objects
                for (Waitlist_School_Ranking__c wsr : wsrsList) {
                    finalResults.add(new WrapperClass(wsr.Wsr_Rank__c, wsr.Wsr_Program__r.Name, wsr.Offer_Status__c));
                }

                // Add ineligible applications that are not in wsrsList
                for (hed__Application__c app : ineligibleApplications) {
                    finalResults.add(new WrapperClass(String.valueOf(app.Program_Rank__c), app.Program__r.Name, Label.AisdApp_Not_Admitted));
                }
            }
            return finalResults;
        }
        private set;
    }

    // Wrapper class to store rank, school, and status
    public class WrapperClass {
        public String rank { get; set; }
        public String school { get; set; }
        public String status { get; set; }

        public WrapperClass(String rank, String school, String status) {
            this.rank = rank;
            this.school = school;
            this.status = status;
        }
    }
}
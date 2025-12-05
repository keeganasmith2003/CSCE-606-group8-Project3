Scrum Events Log

Sprint 1 (Nov 11 - Nov 18)
Goal: Establish the core ticketing workflow (Create, View, Close) and Authentication.

Sprint 1 Planning
Date: Nov 11, 2025

Outcomes:

The team looked over the existing state of the project and identified new features/user stories to be picked up for current project.

Assignments:

@Shreya: User Profile Page.

@Keegan: Enhanced Ticket Search and Filtering.

@Malvika: Email Notifications.

@Sean: UI Improvements.

Daily Standup (Sample: Nov 13)
Updates:

@Keegan finished the searching feature.

@Shreya proposed a "Development" branch workflow to prevent main breaking.

Blockers:

Heroku Costs: @Keegan flagged that the student tier only allows $13/month.

Action Item: @Malvika to investigate alternative Heroku configs or free tier options.

Sprint 1 Review & Retrospective
Date: Nov 18, 2025

What went well:

User profile page and enhanced search work seamlessly with improved UI.

Round-robin assignment logic works correctly in testing.

What went wrong:

Deployment: We hit the Heroku credit limit on the initial repo setup.

Email Bug: "Tamu.edu" emails are blocking our automated notifications due to strict firewalls.

Adjustments:

Process: We will fork the repository to reset the Heroku connection.

Backlog: Added a story for "Personal Email Field" to bypass the firewall issue.

Sprint 2 (Nov 19 - Nov 25)
Goal: Polish UI (Kanban, Dashboards) and finalize Admin Analytics.

Sprint 2 Planning
Date: Nov 19, 2025

Outcomes:

@Shreya to implement the Analytics on Dashboard.

@Malvika to enhance ticket interface by adding option to attach evidence as well as view audit log.

@Keegan to introduce bulk operations for editing/closing tickets. 

Tech Debt:

Agreed to increase RSpec coverage for the MetricsController before the final demo.

Daily Standup (Sample: Nov 25)
Updates:

@Shreya: New Heroku deployment is live on the fresh fork.

@Keegan: Working on "Bulk Close" feature for admins.

Blockers:

@Malvika is unavailable Thursday; team agreed to async check-ins via Slack.

Final Project Retrospective
Date: Nov 26, 2025

Successes:

High Velocity: Delivered the complex "Kanban Board" feature ahead of schedule.

Quality: Achieved >90% test coverage using RSpec and Cucumber.

Lessons Learned:

Deployment: Early deployment is critical. The Heroku config issue nearly derailed the Git history.
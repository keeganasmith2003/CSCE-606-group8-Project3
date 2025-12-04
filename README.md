# Ticket Tracking System (Group 8)

A robust SaaS application for managing support tickets, designed for University environments. This system allows Users to report issues, Staff to manage and resolve them via a Kanban workflow, and System Administrators to monitor performance metrics.

**Course:** CSCE 606 (Software Engineering) **Semester:** Fall 2025

## Team Members

-   **Shreya Sahni:** User Profile, Analytics Dashboard, Documentation
    
-   **Malvika Koushik:** Email Notifications, Ticket Enhancements - Assignment, Evidence
    
-   **Keegan Smith:** Ticket Management, Filtering, Search
    
-   **Sean Ge:** UI Improvements
    

----------

## Features

-   **Role-Based Access Control (RBAC):** Distinct interfaces for **Users**, **Agents (Staff)**, and **Sysadmins** .
    
-   **Google OAuth2 Authentication:** Secure sign-in using university credentials.
    
-   **Real-Time Kanban Board:** Clean and intuitive UI for Agents to manage ticket status.
    
-   **Analytics Dashboards:**
    
    -   **User:** Personal resolution metrics.
        
    -   **Admin:** System-wide performance charts using Chart.js.
        
-   **Email Notifications:** Automated alerts on ticket status changes.

## Repository Structure

```
group-8-project/
│── app/             # Rails app code (models, controllers, views)
│── features/        # Cucumber acceptance tests
│── spec/            # RSpec unit tests
│── docs_project2/   # Archived docs from previous project phase
│── docs_project3/   # Technical docs, ADRs, scrum logs
│── config/          # Configurations & routes
│── db/              # Migrations & schema
│── README.md        # Project overview

```
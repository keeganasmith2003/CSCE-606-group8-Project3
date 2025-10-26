# CSCE-606-group6-Project2
# README


This application is a Role-Based Ticket Management System built with Ruby on Rails. It enables authenticated users to create, assign, and comment on support tickets, with visibility rules and administrative controls.

Key Layers

Presentation Layer (Views & Routes):
Provides the UI for users to view, create, edit, and manage tickets and comments. Interacts with controllers to trigger application logic.

Controller Layer:
Handles incoming HTTP requests, applies Pundit authorization policies, and interacts with models to retrieve or modify data.
Includes:

TicketsController for ticket lifecycle management.

CommentsController for threaded discussion on tickets.

UsersController for sysadmin-level user management.

SessionsController for OAuth2-based authentication.

Model Layer (ActiveRecord):
Encapsulates business logic and relationships:

User: Authenticated via Google OAuth (OmniAuth), assigned roles (user, staff, sysadmin).

Ticket: Core entity with category, status, and priority enums.

Comment: Threaded messages on tickets with visibility controls.

Setting: Key-value storage used for dynamic system configurations (e.g., round-robin agent assignment).

Authorization & Authentication:

Authentication: via Google OAuth2 (omniauth-google-oauth2).

Authorization: via Pundit, enforcing role-based permissions on each resource.

Database Layer:
Persistent storage for users, tickets, comments, and system settings.
Foreign key constraints ensure data integrity (e.g., tickets must have a requester).

Highlights

Round-Robin Auto Assignment:
When a ticket is created, it can automatically be assigned to the next available staff agent, managed through Setting.

Role-Based Access Control:

Requester (User): Can create and view own tickets and public comments.

Staff (Agent): Can view assigned tickets and add internal comments.

Sysadmin: Can manage users and system settings.

Extensibility:
Easily expandable to add new categories, notification systems, or analytics dashboards.




This README would normally document whatever steps are necessary to get the
application up and running.

Things you may want to cover:

* Ruby version

* System dependencies

* Configuration

* Database creation

* Database initialization

* How to run the test suite

* Services (job queues, cache servers, search engines, etc.)

* Deployment instructions

* ...

## Architecture & Class Diagrams

Below are the system diagrams for this project. Copy the files from your local screenshots folder into the repository (suggested path: `docs/images/`) and then view them here.

Project architecture diagram:

![Project Architecture](docs/images/project2architecture_diagram.png)

Project class diagram:

![Project Class Diagram](docs/images/project2_class_diagram.png)

If you haven't already copied the images into the repo, run the following from your machine to add them (replace paths if yours differ):

```bash
# create the images folder in the repo
mkdir -p /home/mihir/CSCE-606-group6-Project2/Ticketing-System/docs/images

# copy screenshots into the repo images folder
cp /home/mihir/Pictures/Screenshots/project2architecture_diagram.png /home/mihir/CSCE-606-group6-Project2/Ticketing-System/docs/images/
cp /home/mihir/Pictures/Screenshots/project2_class_diagram.png /home/mihir/CSCE-606-group6-Project2/Ticketing-System/docs/images/

# commit (example)
cd /home/mihir/CSCE-606-group6-Project2/Ticketing-System
git add docs/images/project2architecture_diagram.png docs/images/project2_class_diagram.png
git commit -m "Add architecture and class diagrams to README"
```

After copying the images, the figures will render on GitHub and other Markdown viewers.

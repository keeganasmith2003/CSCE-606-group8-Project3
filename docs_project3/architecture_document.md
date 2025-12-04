## Architecture Documentation

### 1. Class Structure

-   **User**
    
    -   `has_many :tickets` (as requester)
        
    -   `has_many :assigned_tickets` (as assignee)
        
    -   `has_many :team_memberships`
        
    -   `has_many :teams, through: :team_memberships`
        
    -   _Attributes:_ `role` (enum), `provider`, `uid`, `email`.
        
-   **Ticket**
    
    -   `belongs_to :requester (User)`
        
    -   `belongs_to :assignee (User, optional)`
        
    -   `belongs_to :team`
        
    -   `has_many :comments`
        
    -   _Attributes:_ `status`, `priority`, `approval_status`, `category`.
        
-   **Team**
    
    -   `has_many :users`
        
    -   `has_many :tickets`
        
-   **Comment**
    
    -   `belongs_to :ticket`
        
    -   `belongs_to :author (User)`
        
    -   _Attributes:_  `visibility` (public/internal).

### 2. System Diagrams

#### 2.1 Entity Relationship Diagram (ERD)

This schema reflects the associations found in the User, Team, Ticket, and Comment models.


```
erDiagram
    User ||--o{ Ticket : "requests"
    User ||--o{ Ticket : "assigned_to"
    User ||--o{ TeamMembership : "has"
    User ||--o{ Comment : "authors"
    
    Team ||--o{ TeamMembership : "includes"
    Team ||--o{ Ticket : "owns"
    
    Ticket ||--o{ Comment : "has"
    Ticket ||--o{ Attachment : "has_many"

    User {
        integer id
        string email
        string role "user|agent|sysadmin"
        string uid "Google UID"
    }

    Ticket {
        integer id
        string status "open|resolved"
        string priority
        string approval_status
        datetime created_at
    }

    Team {
        integer id
        string name
        text description
    }

```

#### 2.2 System Architecture

This diagram illustrates the request flow from the client to the database and external services.


```
graph TD
    Client[Web Browser / User] -->|HTTPS| LoadBalancer
    LoadBalancer -->|Traffic| WebServer[Puma Web Server]
    
    subgraph Rails_Monolith
        WebServer --> Router[Rails Router]
        Router --> Auth[SessionsController]
        Router --> App[Tickets/Metrics Controllers]
        
        Auth -->|OmniAuth| GoogleAPI[Google OAuth 2.0]
        
        App -->|Query| Models[ActiveRecord Models]
        App -->|Render| Views[ERB Views + Chart.js]
        
        Models -->|SQL| DB[(PostgreSQL Database)]
    end
    
    subgraph Background_Jobs
        App -->|Enqueue| Sidekiq
        Sidekiq -->|Send| SendGrid[Email Service]
    end
```
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


```mermaid
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



```mermaid
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

#### 2.3 Database Diagram
- **USERS**: Stores all system users. Authentication is handled via OmniAuth (Google), storing `provider` and `uid`. The `role` column defines permissions (User, Sysadmin, Staff).

- **TICKETS**: The core entity. It links to `USERS` in three ways: `requester` (who created it), `assignee` (staff working on it), and `approver` (staff who approved/rejected it). It also belongs to a `TEAM`.

- **TEAMS**: Groups of staff members (e.g., "Support", "Ops"). Used for routing tickets.

- **TEAM_MEMBERSHIPS**: Join table for the many-to-many relationship between `USERS` and `TEAMS`.

- **COMMENTS**: Discussion threads on tickets. Includes a `visibility` flag for internal staff notes.

- **SETTINGS**: A simple key-value store for system-wide configurations (e.g., assignment strategies).
```mermaid
erDiagram
    USERS ||--o{ TICKETS : "requests"
    USERS ||--o{ TICKETS : "assigned_to"
    USERS ||--o{ TICKETS : "approves"
    USERS ||--o{ COMMENTS : "authors"
    USERS ||--o{ TEAM_MEMBERSHIPS : "has"
    TEAMS ||--o{ TEAM_MEMBERSHIPS : "has"
    TEAMS ||--o{ TICKETS : "owns"
    TICKETS ||--o{ COMMENTS : "has"

    USERS {
        bigint id PK
        string email
        string name
        integer role "0:user, 1:sysadmin, 2:staff"
        string provider "OmniAuth"
        string uid
        string personal_email
        datetime created_at
        datetime updated_at
    }

    TICKETS {
        bigint id PK
        string subject
        text description
        integer status "0:open, 1:in_progress, 2:on_hold, 3:resolved"
        integer priority "0:low, 1:medium, 2:high"
        string category
        integer approval_status "0:pending, 1:approved, 2:rejected"
        text approval_reason
        datetime approved_at
        datetime closed_at
        bigint requester_id FK
        bigint assignee_id FK
        bigint approver_id FK
        bigint team_id FK
        datetime created_at
        datetime updated_at
    }

    TEAMS {
        bigint id PK
        string name
        text description
        datetime created_at
        datetime updated_at
    }

    TEAM_MEMBERSHIPS {
        bigint id PK
        bigint team_id FK
        bigint user_id FK
        integer role "0:member, 1:manager"
        datetime created_at
        datetime updated_at
    }

    COMMENTS {
        bigint id PK
        text body
        integer visibility "0:public, 1:internal"
        bigint ticket_id FK
        bigint author_id FK
        datetime created_at
        datetime updated_at
    }

    SETTINGS {
        bigint id PK
        string key
        text value
        datetime created_at
        datetime updated_at
    }
```

#### 2.4 Class Diagram

- **User**: Contains logic for role verification (`sysadmin?`, `agent?`) and OAuth login handling. It acts as the central actor in the system.

- **Ticket**: Contains the bulk of the business logic, including state management (enums for status, priority, approval), workflow methods (`approve!`, `reject!`), and class methods for generating dashboard metrics (e.g., `completion_rate_by_week`).

- **Team**: Represents organizational units. It has a many-to-many relationship with Users through `TeamMembership`.

- **Comment**: Simple model for communication. The `visibility` enum is critical for separating public communication from internal staff discussions.

- **Setting**: Provides a singleton-like interface (`Setting.get`, `Setting.set`) for managing dynamic system configurations without redeploying.
```mermaid
classDiagram
    class ApplicationRecord {
        <<abstract>>
    }
    ApplicationRecord <|-- User
    ApplicationRecord <|-- Ticket
    ApplicationRecord <|-- Team
    ApplicationRecord <|-- TeamMembership
    ApplicationRecord <|-- Comment
    ApplicationRecord <|-- Setting

    class User {
        +Integer role (user:0, sysadmin:1, staff:2)
        +string email
        +string name
        +string provider
        +string uid
        +from_omniauth(auth) User$
        +sysadmin?() bool
        +agent?() bool
        +requester?() bool
    }

    class Ticket {
        +Integer status (open:0, in_progress:1, on_hold:2, resolved:3)
        +Integer priority (low:0, medium:1, high:2)
        +Integer approval_status (pending:0, approved:1, rejected:2)
        +string subject
        +text description
        +string category
        +belongs_to :requester (User)
        +belongs_to :assignee (User)
        +belongs_to :approver (User)
        +belongs_to :team
        +has_many :comments
        +has_many_attached :attachments
        +approve!(user)
        +reject!(user, reason)
        +completion_rate_by_week(user, days)$
        +tickets_by_category()$
        +average_resolution_time()$
    }

    class Team {
        +string name
        +text description
        +has_many :members (User)
        +has_many :tickets
    }

    class TeamMembership {
        +Integer role (member:0, manager:1)
        +belongs_to :team
        +belongs_to :user
    }

    class Comment {
        +Integer visibility (public:0, internal:1)
        +text body
        +belongs_to :ticket
        +belongs_to :author (User)
        +scope chronological()
    }

    class Setting {
        +string key
        +string value
        +get(key)$
        +set(key, value)$
        +auto_round_robin?()$
    }

    User "1" --> "*" Ticket : requests
    User "1" --> "*" Ticket : assigned
    User "1" --> "*" Ticket : approves
    User "1" -- "*" Team : memberships
    Team "1" --> "*" Ticket : owns
    Ticket "1" *-- "*" Comment : contains
    User "1" --> "*" Comment : authors
```
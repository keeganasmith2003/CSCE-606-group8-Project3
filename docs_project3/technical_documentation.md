### Technical Documentation

#### 1. Prerequisites

-   **Ruby:** 3.x
    
-   **Rails:** 7.x
    
-   **Database:** PostgreSQL
    
-   **Google Cloud Console:** Project with OAuth credentials
    

#### 2. Environment Variables

Create a `.env` file in the root directory:

Bash

```
GOOGLE_CLIENT_ID=your_client_id
GOOGLE_CLIENT_SECRET=your_client_secret

```

#### 3. Installation (Local)

1.  **Clone the Repository:**
    
    Bash
    
    ```
    git clone https://github.com/tamu-edu-students/CSCE606-Group8-Project3.git
    cd CSCE606-Group8-Project3
    
    ```
    
2.  **Install Dependencies:**
    
    Bash
    
    ```
    bundle install
    
    ```
    
3.  **Database Setup:**
    
    Bash
    
    ```
    rails db:create
    rails db:migrate
    rails db:seed # Populates initial Sysadmin and Categories
    
    ```
    

#### 4. Running the App

Start the Rails server and CSS watcher:

Bash

```
bin/rails s

```

Access the app at `http://localhost:3000`. Use the "Developer Login" route (`/dev_login`) if you do not have Google Credentials set up locally.

#### 5. Deployment (Heroku)

1.  **Create App:** `heroku create group-8-project`
    
2.  **Add Database:** `heroku addons:create heroku-postgresql:mini`
    
3.  **Set Config Vars:**
    
    Bash
    
    ```
    heroku config:set GOOGLE_CLIENT_ID=... GOOGLE_CLIENT_SECRET=...
    
    ```
    
4.  **Push Code:** `git push heroku main`
    
5.  **Migrate:** `heroku run rails db:migrate`

6.  **Running Tests:**

	We use **RSpec** for unit tests and **Cucumber** for acceptance tests.

	Bash

    ```		
    # Run all Unit Tests
    bundle exec rspec

    # Run all Acceptance Tests
    bundle exec cucumber

    # View Coverage Report
    open coverage/index.html
    
    ```
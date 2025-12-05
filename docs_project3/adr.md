# Architecture Decision Records (ADRs)

### ADR-001: Client-Side Visualization for Analytics

* **Status:** Accepted
* **Context:** The System Admin requires a "Performance Dashboard" to view metrics like "Tickets Resolved Per Week" and "Tickets by Category". We evaluated generating static images server-side (using Python/Matplotlib or Ruby/Gruff) versus rendering interactive charts in the browser.
* **Decision:** We decided to use **Chart.js** via CDN for client-side rendering.
* **Consequences:**
    * **Pro:** Offloads processing power from our limited Heroku dynos to the client's browser, improving server response times.
    * **Pro:** Provides interactivity (tooltips, legend toggling) out-of-the-box.
    * **Con:** Creates an external dependency on the CDN (`cdn.jsdelivr.net`); charts will fail to render if the user is offline or has strict script blocking.

### ADR-002: Automated Ticket Assignment Strategy

* **Status:** Accepted
* **Context:** Relying on Sysadmins to manually triage and assign every incoming ticket creates a bottleneck. We needed an automated way to distribute the workload among Staff Agents immediately upon ticket creation.
* **Decision:** We decided to implement a **Round-Robin Assignment** algorithm directly in the `TicketsController` create action.
* **Consequences:**
    * **Pro:** Ensures an exactly even distribution of ticket volume across all staff members.
    * **Pro:** Simple implementation using a pointer (`last_assigned_index`) stored in the database settings, avoiding complex queue infrastructure.
    * **Con:** Does not account for current agent workload or ticket complexity (e.g., a junior agent might get a difficult ticket just because it's their turn).

### ADR-003: Kanban Board View Implementation

* **Status:** Accepted
* **Context:** Staff Agents found the standard "List View" difficult for visualizing their workflow and prioritizing tasks. They requested a board view similar to Trello or Jira.
* **Decision:** We decided to build a **Server-Rendered Kanban Board** using standard Rails Views and CSS Grid, rather than a Single Page Application (SPA) framework like React.
* **Consequences:**
    * **Pro:** Maintains the simplicity of the Rails Monolith architecture without introducing a separate frontend build pipeline or API layer.
    * **Pro:** Data grouping logic (`@tickets_by_status`) leverages existing ActiveRecord scopes.
    * **Con:** Changing a ticket's status requires a full page reload or a specific form submission, rather than a smooth drag-and-drop experience (unless Turbo Frames are heavily utilized).

### ADR-004: Asynchronous Email Notifications

* **Status:** Accepted
* **Context:** Users must be notified via email when their ticket is updated or resolved. Sending emails synchronously during the HTTP request can cause page load delays or timeouts if the SMTP provider (SendGrid) is slow.
* **Decision:** We decided to use **ActiveJob** to send emails asynchronously (`deliver_later`).
* **Consequences:**
    * **Pro:** The user interface remains snappy; the controller redirects immediately without waiting for the email to send.
    * **Pro:** Built-in retry logic if the external email service is temporarily down.
    * **Con:** Requires a background worker process (or thread) to be running, which consumes additional resources on the hosting platform.
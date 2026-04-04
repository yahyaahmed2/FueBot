# FueBot
AI academic advisor chatbot

project-root/
├─ backend/          # Node.js API + DB connectors
├─ frontend/         # React app
├─ ai_model/         # Python AI model
├─ database/         # SQL scripts
├─ docs/             # architecture & workflow guides
└─ README.md

Prerequisites
-node.js
-Python
-PostgreSQL
-Git
<<<<<<< HEAD

=======
### Database Setup
1. Install PostgreSQL and create a database named `fuebot_db`
2. Run the SQL script to create tables and insert dummy data:
   ```bash
   psql -U your_username -d fuebot_db -f db/advising_chatbot.sql
   ```
3. Copy `.env.example` to `.env` and fill in your database credentials
4. Run the password hashing script to secure existing passwords:
   ```bash
   cd backend
   node hashPasswords.js
   ```

### Authentication Features
- User registration with password hashing
- Secure login with bcrypt password verification
- Session-based authentication
- Protected routes with middleware
- User dashboard with profile information

### API Endpoints
- `POST /auth/register` - Register new user
- `POST /auth/login` - Login user
- `POST /auth/logout` - Logout user
- `GET /auth/dashboard` - Get user dashboard (requires auth)

### Development Workflow
>>>>>>> yahya-signup
### 1. Clone the Repo (One-Time)
git clone https://github.com/https://github.com/yahyaahmed2/FueBot.git
cd FueBot

### 2. Start from Dev branch
git checkout dev
git pull origin dev

### 3. Feature branch
git checkout -b feature/<your-name>-<task>
ex:
git checkout -b feature/mostafa-database

### 4. Make changes in your IDE
Make any changes in the AI model, frontend, backend or documents.
Test your changes to see if it works correctly

### 5. Stage and commit changes
for example:
git add .
git commit -m "Added an extra button"

### 6. push your feature branch
git push origin feature/<your-name>-<task>

### 7. Open a pull request(PR)
Go to GitHub → Pull Requests → New Pull Request
Base branch: dev
Compare: your feature branch
Add a short description of your changes
Assign the lead (or designated reviewer) to approve
Do NOT merge yourself. Only the lead merges into dev.

### 8. Daily routine
git checkout dev
git pull origin dev
etc

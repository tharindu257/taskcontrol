# TaskControl - Setup & Run Instructions

## Prerequisites

- **Flutter SDK** (>= 3.2.0) - installed at `C:\Users\THARINDHU\flutter`
- **Node.js** (>= 18)
- **MySQL 8.0** - running on `localhost:3306`
- **Chrome** browser (for Flutter web)

## Database Credentials

| Field    | Value                                           |
| -------- | ----------------------------------------------- |
| Host     | localhost                                       |
| Port     | 3306                                            |
| User     | root                                            |
| Password | 1234                                            |
| Database | taskcontrol                                     |
| Full URL | `mysql://root:1234@localhost:3306/taskcontrol`  |

## JWT Configuration

| Key                  | Value                                      |
| -------------------- | ------------------------------------------ |
| JWT_SECRET           | taskcontrol-jwt-secret-dev-key-2024        |
| JWT_REFRESH_SECRET   | taskcontrol-refresh-secret-dev-key-2024    |
| JWT_EXPIRES_IN       | 15m                                        |
| JWT_REFRESH_EXPIRES_IN | 7d                                       |

## Default App Users (after seeding)

Run `npx prisma db seed` in the backend folder to create these accounts.

| Role   | Full Name   | Username | Email                    | Password      |
| ------ | ----------- | -------- | ------------------------ | ------------- |
| ADMIN  | Admin User  | admin    | admin@taskcontrol.com    | password123   |
| MEMBER | John Doe    | john     | john@taskcontrol.com     | password123   |
| MEMBER | Jane Smith  | jane     | jane@taskcontrol.com     | password123   |

> Login uses **email** + **password** (not username).

## All Passwords & Credentials Summary

| Service          | Username / Key           | Password / Value                          |
| ---------------- | ------------------------ | ----------------------------------------- |
| MySQL Database   | root                     | 1234                                      |
| App Login (Admin)| admin@taskcontrol.com    | password123                               |
| App Login (User) | john@taskcontrol.com     | password123                               |
| App Login (User) | jane@taskcontrol.com     | password123                               |
| JWT Secret       | JWT_SECRET               | taskcontrol-jwt-secret-dev-key-2024       |
| JWT Refresh      | JWT_REFRESH_SECRET       | taskcontrol-refresh-secret-dev-key-2024   |

## How to Run

### 1. Backend (Express + Prisma + MySQL)

```bash
cd backend

# Install dependencies
npm install

# Generate Prisma client
npx prisma generate

# Run database migrations
npx prisma migrate dev

# Start the server (development)
npm run dev

# OR build and run production
npm run build
node dist/index.js
```

Backend runs on: **http://localhost:3000**

Health check: **http://localhost:3000/api/health**

### 2. Frontend (Flutter Web)

```bash
cd frontend

# Install Flutter dependencies
flutter pub get

# Run on Chrome (web)
flutter run -d chrome --web-port 8080

# OR build for production
flutter build web
```

Frontend runs on: **http://localhost:8080**

### 3. Run Both Together

Open two terminals:

**Terminal 1 - Backend:**
```bash
cd backend
npm run dev
```

**Terminal 2 - Frontend:**
```bash
cd frontend
flutter run -d chrome --web-port 8080
```

## Useful Commands

### Backend
| Command                  | Description                    |
| ------------------------ | ------------------------------ |
| `npm run dev`            | Start dev server with nodemon  |
| `npm run build`          | Compile TypeScript             |
| `npm start`              | Run compiled JS                |
| `npx prisma studio`     | Open Prisma database GUI       |
| `npx prisma migrate dev`| Run pending migrations         |
| `npx prisma db seed`    | Seed the database              |

### Frontend
| Command                          | Description                |
| -------------------------------- | -------------------------- |
| `flutter pub get`                | Install dependencies       |
| `flutter run -d chrome`          | Run on Chrome              |
| `flutter build web`              | Build for production       |
| `flutter analyze`                | Run code analysis          |

## API Endpoints

| Method | Endpoint                          | Description           |
| ------ | --------------------------------- | --------------------- |
| GET    | `/api/health`                     | Health check          |
| POST   | `/api/auth/register`              | Register new user     |
| POST   | `/api/auth/login`                 | Login                 |
| POST   | `/api/auth/refresh`               | Refresh token         |
| GET    | `/api/projects`                   | List projects         |
| POST   | `/api/projects`                   | Create project        |
| GET    | `/api/projects/:id`               | Get project details   |
| GET    | `/api/boards/:id`                 | Get board with tasks  |
| POST   | `/api/tasks`                      | Create task           |
| PATCH  | `/api/tasks/:id`                  | Update task           |
| POST   | `/api/tasks/:id/comments`         | Add comment           |

## Project Structure

```
flutter-app/
├── backend/                 # Express.js + TypeScript API
│   ├── prisma/              # Database schema & migrations
│   ├── src/
│   │   ├── config/          # Environment & database config
│   │   ├── controllers/     # Route handlers
│   │   ├── middleware/       # Auth & error middleware
│   │   ├── routes/          # API route definitions
│   │   ├── services/        # Business logic
│   │   ├── validators/      # Request validation (Zod)
│   │   └── utils/           # JWT, password helpers
│   └── .env                 # Environment variables
│
├── frontend/                # Flutter web app
│   ├── lib/
│   │   ├── config/          # Theme, routes, app config
│   │   ├── models/          # Data models
│   │   ├── providers/       # Riverpod state management
│   │   ├── screens/         # UI screens
│   │   ├── services/        # API & storage services
│   │   └── widgets/         # Reusable UI components
│   └── web/                 # Web platform files
│
└── SETUP.md                 # This file
```

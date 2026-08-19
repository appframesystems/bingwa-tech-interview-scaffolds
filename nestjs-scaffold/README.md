# NestJS Interview Scaffold

This is a minimal, working NestJS project designed for the pair-programming interview.

## The Brief

You have **15 minutes** of independent coding followed by **8 minutes** of integration with the frontend.

### Requirements

Build a REST API with two endpoints:
1. **Create a Task**: Accepts a title, stores it (in-memory, e.g. using an array or map in a service), and returns the created task.
2. **Mark a Task Complete**: Given a task's ID, marks it done and returns the updated task.

Use in-memory storage (no database setup needed).

### Getting Started

1. Open this directory in your IDE.
2. Start the development server (runs by default on port 3000):
   ```bash
   npm run start:dev
   ```
3. Start implementing your controller, service, and DTOs as needed.

---

## Standard NestJS Info

### Project setup

```bash
$ npm install
```

### Compile and run the project

```bash
# development
$ npm run start

# watch mode
$ npm run start:dev

# production mode
$ npm run start:prod
```

### Run tests

```bash
# unit tests
$ npm run test

# e2e tests
$ npm run test:e2e

# test coverage
$ npm run test:cov
```

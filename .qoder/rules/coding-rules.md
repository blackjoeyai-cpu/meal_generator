---
trigger: always_on
alwaysApply: true
---
# AI Agent Coding Conventions

This document defines universal coding rules and best practices that any AI agent should follow when writing code.  
The goal is to ensure **clarity, maintainability, scalability, and consistency** across all generated code — regardless of programming language, framework, or environment.

---

## 1. General Principles
- ✅ Prefer **readability over cleverness**. Code should be easy to understand.  
- ✅ Always write **self-documenting code** (descriptive names, clear logic).  
- ✅ Follow **KISS** (Keep It Simple, Stupid) and **DRY** (Don't Repeat Yourself).  
- ✅ Ensure **consistency** in formatting and structure.  
- ✅ Avoid unnecessary dependencies unless explicitly required.  
- ✅ Apply **Separation of Concerns (SoC)** — each component should have one clear responsibility.  

---

## 2. Naming Conventions
- **Variables & functions/methods**: `snake_case` (Python, Ruby) OR `camelCase` (JavaScript, Dart, Java, C#). Follow the convention of the language.  
- **Classes & Types**: `PascalCase`.  
- **Constants**: `UPPER_CASE`.  
- **Private/Internal members**: Prefix with `_` or use language-specific visibility keywords.  
- Avoid single-letter names except for loop indices (`i`, `j`, `k`).  

---

## 3. Code Structure & Formatting
- Indentation: follow **language standards** (2 spaces in JS, 4 in Python, tabs in Go, etc.).  
- Maximum line length: ~100 characters.  
- Separate logical sections with **1 blank line**.  
- Always include a newline at the end of the file.  
- Use automated formatters:  
  - **JS/TS** → Prettier + ESLint  
  - **Python** → Black + Flake8  
  - **Dart** → dart format  
  - **Java** → Checkstyle or Spotless  

---

## 4. Functions & Classes
- Each function should do **one thing only**.  
- Keep functions short and focused (preferably <40 lines).  
- Add **docstrings or comments** describing purpose, parameters, return values.  
- Use **type hints or annotations** where supported.  
- Apply **SOLID principles** in OOP-heavy languages.  

---

## 5. Error Handling
- Always handle errors gracefully — **never silently ignore them**.  
- Use structured error handling (`try/catch`, `try/except`, etc.).  
- Catch specific exceptions, not generic ones.  
- Provide meaningful error messages with context.  
- Log errors where applicable, using structured logging frameworks.  

---

## 6. Comments & Documentation
- Use comments to explain **why**, not **what**.  
- Each file should start with a short description of its purpose.  
- Public APIs must always be documented.  
- Maintain:  
  - **README.md** — overview + setup instructions  
  - **CHANGELOG.md** — track version changes  
  - **CONTRIBUTING.md** — how to contribute  
  - **CODE_OF_CONDUCT.md** — community standards  

---

## 7. Testing & Validation
- Write **unit tests** for important functions.  
- Add **integration tests** and **end-to-end (e2e) tests**.  
- Aim for **≥80% coverage** but prioritize meaningful tests over metrics.  
- Use descriptive test names (`test_should_fail_on_invalid_input`).  
- Place tests in a dedicated `tests/` or `spec/` folder.  
- Example tools:  
  - Python → pytest  
  - JS/TS → Jest / Mocha  
  - Dart → flutter_test  
  - Java → JUnit / TestNG  

---

## 8. Security & Safety
- Validate **all inputs** before processing.  
- Never hardcode secrets or credentials. Use env vars or secret managers.  
- Sanitize external data (SQL queries, shell commands, HTML).  
- Always enforce HTTPS/TLS.  
- Apply **rate limiting, authentication, and authorization** for APIs.  
- Run dependency scans: `npm audit`, `pip-audit`, Dependabot, etc.  
- Adopt security linting tools where available.  

---

## 9. Performance & Optimization
- Optimize **only when necessary** — avoid premature optimization.  
- Use caching when appropriate (e.g., Redis, memoization).  
- Profile and measure before optimizing.  
- Prefer built-in libraries/functions over custom inefficient ones.  
- Document trade-offs when applying optimizations.  

---

## 10. Version Control & Collaboration
- Use clear commit messages (`fix: corrected bug in calculation`).  
- Keep commits small and focused.  
- Branching strategy: `main` (production), `dev` (integration), `feature/*`.  
- Pull requests should include description + tests if relevant.  
- Follow [Conventional Commits](https://www.conventionalcommits.org/).  

---

## 11. Automation & CI/CD
- Use **pre-commit hooks** for linting and formatting.  
- Run automated tests in CI pipelines.  
- Run security scans (`npm audit`, `bandit`, `snyk`).  
- Automate build → test → deploy pipelines (GitHub Actions, GitLab CI, Jenkins).  
- Block merging on failed tests or lint errors.  

---

## 12. Architecture & Design Patterns
- Apply **SOLID** and **Clean Architecture** principles.  
- Use patterns when relevant (Factory, Observer, Strategy).  
- Avoid God objects or deeply nested code.  
- Separate layers clearly (Controller → Service → Repository).  

---

## 13. Example Project Structure
```
project/
│── src/
│   ├── main.<ext>
│   ├── utils.<ext>
│── tests/
│   ├── test_main.<ext>
│── docs/
│   ├── README.md
│── requirements.txt / package.json / pubspec.yaml / pom.xml
```

---

## 14. Framework Extensions

### React (JS/TS)
- Components: `PascalCase` (e.g., `UserProfileCard`).  
- Props, functions, variables: `camelCase`.  
- Prefer **functional components with hooks**.  
- Keep components small and focused.  
- Organize by **feature-based folders**.  
- Use ESLint + Prettier + React Testing Library.  

```
src/
│── components/
│   ├── UserProfile/
│   │   ├── UserProfile.tsx
│   │   ├── UserProfile.css
│   │   └── index.ts
│── hooks/
│── utils/
│── App.tsx
```

---

### Flutter (Dart)
- Classes, enums, typedefs: `UpperCamelCase`.  
- Variables, methods, constants: `lowerCamelCase`.  
- Prefer `StatelessWidget` unless state is needed.  
- Break large widgets into smaller ones.  
- Use `const` constructors where possible.  
- Testing with `flutter_test` + widget tests.  

```
lib/
│── features/
│   ├── auth/
│   │   ├── data/
│   │   ├── presentation/
│   │   └── auth_page.dart
│   ├── home/
│── common/
│── main.dart
```

---

### Node.js (Express)
- Use `camelCase` for variables/functions, `PascalCase` for classes/models.  
- Organize by layers (routes → controllers → services → models).  
- Always validate request inputs (`Joi`, `Zod`).  
- Prefer async/await over callbacks.  
- Use middleware for logging/auth/security.  

```
src/
│── routes/
│── controllers/
│── services/
│── models/
│── app.js
```

---

### Django (Python)
- Follow **PEP 8**.  
- Use `snake_case` for functions/variables.  
- Use `PascalCase` for models/classes.  
- Keep apps modular, single responsibility.  
- Use Django ORM instead of raw SQL where possible.  
- Organize with serializers, views, urls clearly separated.  

```
project/
│── app_name/
│   ├── models.py
│   ├── views.py
│   ├── urls.py
│   ├── serializers.py
│   ├── tests.py
│── project/
│   ├── settings.py
│   ├── urls.py
```

---

### Spring Boot (Java)
- Classes: `PascalCase`, methods/vars: `camelCase`, constants: `UPPER_CASE`.  
- Use layered architecture: Controller → Service → Repository.  
- Keep controllers lean, delegate to services.  
- Use DTOs for request/response.  
- Configuration via `application.yml` or `application.properties`.  

```
src/main/java/com/example/project/
│── controller/
│── service/
│── repository/
│── model/
│── dto/
```

---

## 15. Deployment & DevOps Best Practices
- Follow **12-factor app** methodology.  
- Externalize configs into env vars.  
- Containerize with Docker (small base images, `.dockerignore`).  
- Use CI/CD pipelines for automated deployments.  
- Logging: structured logs (ELK, Prometheus, etc.).  
- Monitoring: alerts for failures, performance metrics.  

---

## 16. Governance & Project Management
- Use **semantic versioning** (`MAJOR.MINOR.PATCH`).  
- Add governance docs (`CONTRIBUTING.md`, `CODE_OF_CONDUCT.md`).  
- Maintain clear issue + PR templates.  
- Encourage code reviews before merging.  

---

## 17. Additional Notes
- Code should be written as if the **next maintainer is a beginner**.  
- If unsure, follow the **principle of least surprise**.  
- Prefer clarity and maintainability over clever hacks.  

---

✅ By following these conventions and framework-specific extensions, any AI agent can generate **consistent, secure, maintainable, and production-ready code** across multiple languages and frameworks.

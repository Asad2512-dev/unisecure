# Mobile architecture

The app uses GetX for dependency injection, reactive controller state and route navigation. `app/` contains configuration, theme and routes. `core/` contains the Dio client, secure storage, authentication controller, models and reusable state widgets. `features/` uses MVC-oriented `views` with controllers/services added per role as features are expanded.

The Laravel API is authoritative for identity, role, attendance, gate authorization and entry/exit action. The client never selects a role or security outcome.

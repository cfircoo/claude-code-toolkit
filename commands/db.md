---
description: SQLAlchemy + Pydantic + PostgreSQL database operations
argument-hint: [setup|model|migration|query]
allowed-tools: Skill(sqlalchemy-postgres)
---

<objective>
Execute database operations using SQLAlchemy 2.0 + Pydantic + PostgreSQL patterns.

Invoke the sqlalchemy-postgres skill for: $ARGUMENTS
</objective>

<routing>
| Argument | Operation |
|----------|-----------|
| `setup` | Initialize database layer from scratch |
| `model <Name>` | Define a new model with schemas |
| `migration` | Create Alembic migration |
| `query` | Repository and CRUD patterns |
</routing>

<process>
1. Parse $ARGUMENTS to determine operation type
2. Invoke sqlalchemy-postgres skill with context
3. Follow skill's workflow for the operation
4. Verify database changes applied correctly
</process>

<success_criteria>
- Correct skill workflow triggered based on argument
- Database operation completes without errors
- Code follows SQLAlchemy 2.0 patterns
</success_criteria>

# sqlalchemy-postgres Skill

SQLAlchemy 2.0 with Pydantic and PostgreSQL for building robust database layers.

## Overview

Expert guidance on building database layers with SQLAlchemy 2.0, Pydantic models, and PostgreSQL, including migrations with Alembic.

## When to Use

Use this skill when:
- Setting up a new database layer
- Creating ORM models for PostgreSQL
- Implementing repositories and queries
- Managing schema migrations
- Optimizing database queries

## Key Components

### Models
- SQLAlchemy ORM models
- Pydantic data validation schemas
- Type hints and constraints
- Relationship definitions

### Repositories
- Query abstractions
- CRUD operations
- Transaction management
- Batch operations

### Migrations
- Alembic schema management
- Version control for database
- Rollback strategies
- Migration best practices

### Queries
- Efficient SQL generation
- Relationship loading strategies
- Pagination and filtering
- Join optimization

## Usage Example

```
> Use sqlalchemy-postgres to set up a User model with authentication
```

This will:
1. Create SQLAlchemy model with proper constraints
2. Create Pydantic schemas for validation
3. Create repository for CRUD operations
4. Generate Alembic migration
5. Include example usage

## Best Practices

### Model Design
- Use proper SQLAlchemy column types
- Add constraints (NOT NULL, UNIQUE, etc.)
- Define relationships clearly
- Use enums for fixed values
- Add indexes for performance

### Schema Validation
- Pydantic schemas for input validation
- Separate create/update schemas
- Type hints throughout
- Document field requirements

### Relationships
- One-to-many with backrefs
- Many-to-many with association tables
- Lazy loading strategies
- Cascade behavior

### Queries
- Use repository pattern
- Avoid N+1 queries (use `joinedload`, `selectinload`)
- Filter before loading
- Paginate large result sets

### Transactions
- Use context managers
- Rollback on errors
- Commit explicitly
- Handle constraint violations

## Integration with Agents

The db-expert agent uses this skill:
- [db-expert](../agents/db-expert.md) — Database implementation

## Integration with Commands

Available for:
- `/db setup` — Initialize database layer
- `/db model User` — Create new model
- `/db migration` — Generate migration

## Database Setup Process

The skill guides you through:
1. Creating database connection
2. Setting up SQLAlchemy session
3. Creating base model class
4. Defining models
5. Creating Alembic migrations
6. Creating repositories
7. Writing tests

## Advanced Topics

### Connection Pooling
- Pool size configuration
- Echo SQL for debugging
- Connection timeout handling
- Pool pre-ping for reliability

### Async Support
- Using async SQLAlchemy
- Async sessions
- Async repositories
- Managing event loops

### Performance
- Index strategies
- Query optimization
- Connection pooling
- Caching patterns

### Testing
- Fixtures for test databases
- Transaction rollback isolation
- Mock repositories
- Migration testing

## Related Skills

- [pytest-best-practices](pytest-best-practices.md) — Testing database code
- [debug-like-expert](debug-like-expert.md) — Debugging queries
- [create-plans](create-plans.md) — Planning schema

## Related Agents

- [db-expert](../agents/db-expert.md) — Database implementation specialist

## Tools and Libraries

- **SQLAlchemy 2.0** — ORM and query builder
- **Pydantic** — Data validation
- **Alembic** — Schema migrations
- **PostgreSQL** — Database engine
- **psycopg2** — PostgreSQL driver

## Resources

- [SQLAlchemy documentation](https://docs.sqlalchemy.org/)
- [SQLAlchemy ORM](https://docs.sqlalchemy.org/en/20/orm/)
- [Pydantic documentation](https://docs.pydantic.dev/)
- [Alembic documentation](https://alembic.sqlalchemy.org/)
- [PostgreSQL documentation](https://www.postgresql.org/docs/)

# db-expert Agent

SQLAlchemy 2.0 and PostgreSQL database layer implementation specialist.

## Overview

The db-expert agent implements robust database layers with SQLAlchemy 2.0, Pydantic models, and PostgreSQL, including migrations with Alembic.

## When to Use

The db-expert agent is automatically triggered when you:
- Ask to "set up a database layer"
- Request to "create a User model"
- Ask to "implement database models"
- Mention database-related implementation tasks

## Capabilities

### Database Setup
- SQLAlchemy connection configuration
- Session management
- Connection pooling
- Transaction handling

### Model Creation
- SQLAlchemy ORM models
- Pydantic validation schemas
- Relationships and foreign keys
- Indexes and constraints

### Repositories
- CRUD operation abstractions
- Query optimization
- Pagination and filtering
- Batch operations

### Migrations
- Alembic migration generation
- Schema evolution
- Data migrations
- Rollback capability

## Configuration

The agent uses:
- **Model**: Sonnet
- **Tools**: Bash, Read, Write, Edit, Glob, Grep
- **Context**: Conversation context
- **Invocation**: Automatic on database-related requests

## Process

### Model Creation

1. **Understand Requirements**
   - Discuss data structure
   - Identify relationships
   - Define constraints

2. **Create SQLAlchemy Model**
   - Define columns with types
   - Add constraints and indexes
   - Define relationships

3. **Create Pydantic Schema**
   - Separate create/update/read schemas
   - Add validation rules
   - Type hints throughout

4. **Create Repository**
   - Implement CRUD methods
   - Add query helpers
   - Handle transactions

5. **Generate Migration**
   - Create Alembic migration
   - Document changes
   - Test migration

### Setup Process

1. Configure database connection
2. Set up SQLAlchemy session
3. Create base model class
4. Define required models
5. Create Alembic environment
6. Generate initial migration
7. Create repositories
8. Write tests

## Model Example

The agent creates models like:

```python
from sqlalchemy import Column, String, DateTime, Boolean
from sqlalchemy.orm import relationship
from datetime import datetime

class User(Base):
    __tablename__ = "users"

    id = Column(Integer, primary_key=True)
    email = Column(String, unique=True, nullable=False, index=True)
    password_hash = Column(String, nullable=False)
    created_at = Column(DateTime, default=datetime.utcnow)
    is_active = Column(Boolean, default=True)

    posts = relationship("Post", back_populates="author")
```

With Pydantic schema:

```python
from pydantic import BaseModel, EmailStr

class UserCreate(BaseModel):
    email: EmailStr
    password: str

class UserRead(BaseModel):
    id: int
    email: str
    is_active: bool
    created_at: datetime

    class Config:
        from_attributes = True
```

## Workflow

### Database Initialization

```
> Set up a database layer for an e-commerce platform
# Agent interviews about models needed, creates structure
```

### Add Model

```
> Add a Product model with categories and inventory
# Agent creates model, schema, repository, migration
```

### Migration

```
> Add a discount_percentage column to products
# Agent updates model, creates migration, tests it
```

## Integration with Skills

The db-expert agent uses:
- [sqlalchemy-postgres skill](../skills/sqlalchemy-postgres.md) — For guidance
- [pytest-best-practices skill](../skills/pytest-best-practices.md) — For testing

## Integration with Commands

Available through:
- [/db command](../commands/db.md) — Database operations

## Safety Constraints

The db-expert agent:
- Never modifies data without testing
- Always generates migrations (never manual SQL)
- Tests migrations before applying
- Validates schema constraints
- Handles errors gracefully

## Best Practices Applied

### Schema Design
- Proper column types and constraints
- Appropriate indexes for performance
- Foreign key relationships
- NOT NULL constraints where required

### Validation
- Pydantic for input validation
- Database constraints for integrity
- Type hints throughout
- Clear error messages

### Performance
- Strategic indexes
- Relationship loading strategies
- Query optimization
- Connection pooling

### Testing
- Fixture-based test database
- Transaction isolation for tests
- Full CRUD test coverage
- Migration testing

## Common Tasks

### Create New Model

```
> Create a Post model with title, content, published date, and author reference
```

### Add Relationship

```
> Add a many-to-many relationship between users and groups
```

### Create Migration

```
> Add a status column to the orders table with allowed values: pending, shipped, delivered
```

### Set Up Database

```
> Initialize the database layer for a project management app
```

## Output Structure

The agent creates:

```
project/
├── models.py           # SQLAlchemy models
├── schemas.py          # Pydantic schemas
├── repositories.py     # Data access layer
├── migrations/         # Alembic migrations
│   ├── versions/
│   └── env.py
├── database.py         # Connection setup
└── tests/
    └── test_models.py  # Model tests
```

## Error Handling

The agent handles:
- **Circular relationships** — Uses lazy loading strategies
- **Data type mismatches** — Converts/validates as needed
- **Migration conflicts** — Resolves with reversible migrations
- **Constraint violations** — Suggests schema improvements

## Troubleshooting

### Model not created
- Provide clear model requirements
- Specify data types and relationships
- Clarify constraints and validation

### Migration fails
- Review migration for syntax errors
- Check database compatibility
- Verify data doesn't violate constraints

### Performance issues
- Ask about query patterns
- Agent suggests indexes
- Reviews relationship loading
- Optimizes queries

## Advanced Features

### Async Support
- Async SQLAlchemy sessions
- Async repositories
- Event loop management
- Concurrent query handling

### JSON/HSTORE Columns
- Storing structured data
- Validation with Pydantic
- Efficient querying
- Type safety

### Full-Text Search
- PostgreSQL text search
- Custom indexes
- Ranking and relevance
- Integration in repositories

### Soft Deletes
- Logical deletion
- Filtering active records
- Recovery capability
- Audit trailing

## Related Skills

- [sqlalchemy-postgres](../skills/sqlalchemy-postgres.md) — Database guidance
- [pytest-best-practices](../skills/pytest-best-practices.md) — Database testing
- [debug-like-expert](../skills/debug-like-expert.md) — Debugging queries

## Related Agents

- [pytest-writer](pytest-writer.md) — Creates database tests
- [ralph-coder](ralph-coder.md) — Uses models in feature implementation

## Best Practices

1. **Plan schema before implementation**
2. **Use migrations for all changes**
3. **Write tests for models and repositories**
4. **Index columns used in WHERE clauses**
5. **Use repositories for all database access**
6. **Document relationship behavior**
7. **Test migration rollbacks**
8. **Use enums for fixed values**
9. **Add soft deletes when appropriate**
10. **Monitor query performance**

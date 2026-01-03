# [Project Name] Specification

> Generated via spec-interview on [DATE]
> Status: [DRAFT | REVIEW | APPROVED]

---

## 1. Overview

### 1.1 Problem Statement
[What specific problem does this solve? Who experiences this pain?]

### 1.2 Solution Summary
[One paragraph describing the solution at a high level]

### 1.3 Success Metrics
[How will we know this worked? Specific, measurable outcomes]

- Metric 1: [description] — Target: [value]
- Metric 2: [description] — Target: [value]

### 1.4 Non-Goals
[What are we explicitly NOT doing? Important for scope clarity]

---

## 2. Users & Use Cases

### 2.1 Target Users
| User Type | Description | Technical Level | Usage Frequency |
|-----------|-------------|-----------------|-----------------|
| [Role] | [Who they are] | [Low/Medium/High] | [Daily/Weekly/Monthly] |

### 2.2 Primary Use Cases
[Numbered list of the main things users will do]

1. **[Use Case Name]**: [Brief description of the user journey]
2. **[Use Case Name]**: [Brief description of the user journey]

### 2.3 User Journey
[Step-by-step flow for the primary use case]

```
[Entry Point] → [Step 1] → [Step 2] → [Decision Point] → [Outcome]
                                            ↓
                                    [Alternative Path]
```

---

## 3. Functional Requirements

### 3.1 Core Features (MVP)
[Features required for initial launch]

| Feature | Description | Priority | Acceptance Criteria |
|---------|-------------|----------|---------------------|
| [Name] | [What it does] | P0 | [How to verify it works] |

### 3.2 Phase 2 Features
[Features planned for subsequent release]

### 3.3 Future Considerations
[Features explicitly deferred but worth designing for]

---

## 4. Technical Architecture

### 4.1 System Overview
[High-level architecture description]

```
┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│   Client    │────▶│   Server    │────▶│  Database   │
└─────────────┘     └─────────────┘     └─────────────┘
```

### 4.2 Data Model
[Core entities and their relationships]

```
Entity: [Name]
- field1: type (constraints)
- field2: type (constraints)
- relationship: [Entity] (cardinality)
```

### 4.3 API Design
[Key endpoints or interfaces]

| Endpoint | Method | Description | Auth |
|----------|--------|-------------|------|
| /path | GET/POST | [What it does] | [Required/Public] |

### 4.4 State Management
[Where state lives and source of truth]

- Client state: [what and why]
- Server state: [what and why]
- Persistent state: [what and why]

### 4.5 Technology Stack
| Layer | Technology | Rationale |
|-------|------------|-----------|
| Frontend | [tech] | [why] |
| Backend | [tech] | [why] |
| Database | [tech] | [why] |
| Infrastructure | [tech] | [why] |

---

## 5. UI/UX Design

### 5.1 Key Screens/Views
[List of main UI components]

1. **[Screen Name]**: [Purpose and key elements]

### 5.2 Navigation Flow
[How users move through the interface]

### 5.3 Empty States
[What users see with no data]

### 5.4 Error States
[How errors are communicated to users]

### 5.5 Responsive Behavior
[How UI adapts to different screen sizes]

### 5.6 Accessibility Requirements
[WCAG level, specific accommodations]

---

## 6. Integration & Dependencies

### 6.1 External Systems
| System | Purpose | Protocol | Owner |
|--------|---------|----------|-------|
| [Name] | [What we use it for] | [REST/GraphQL/etc] | [Team/Vendor] |

### 6.2 Data Flows
[What data moves in/out and how]

```
[Source] ──[format]──▶ [Our System] ──[format]──▶ [Destination]
```

### 6.3 Failure Handling
[What happens when dependencies fail]

| Dependency | Failure Mode | Handling Strategy |
|------------|--------------|-------------------|
| [System] | [How it fails] | [What we do] |

---

## 7. Error Handling & Edge Cases

### 7.1 Error Taxonomy
| Error Type | User Message | Technical Detail | Recovery |
|------------|--------------|------------------|----------|
| [Category] | [What user sees] | [What we log] | [How to recover] |

### 7.2 Edge Cases
| Scenario | Expected Behavior |
|----------|-------------------|
| [What happens] | [How system responds] |

### 7.3 Partial Failure Handling
[What happens when operations partially succeed]

---

## 8. Security & Privacy

### 8.1 Authentication
[How users prove identity]

### 8.2 Authorization
[Permission model - who can do what]

| Role | Create | Read | Update | Delete |
|------|--------|------|--------|--------|
| [Role] | ✓/✗ | ✓/✗ | ✓/✗ | ✓/✗ |

### 8.3 Data Classification
| Data Type | Classification | Encryption | Retention |
|-----------|---------------|------------|-----------|
| [Type] | [PII/Sensitive/Public] | [At-rest/In-transit] | [Duration] |

### 8.4 Compliance Requirements
[GDPR, SOC2, HIPAA, etc. and implications]

### 8.5 Audit Trail
[What actions are logged and how]

---

## 9. Performance & Reliability

### 9.1 Performance Targets
| Metric | Target | Measurement |
|--------|--------|-------------|
| Response time (p50) | [ms] | [How measured] |
| Response time (p99) | [ms] | [How measured] |
| Throughput | [req/sec] | [How measured] |

### 9.2 Availability Target
[SLA: 99%, 99.9%, 99.99%]

### 9.3 Scalability Plan
[How system handles growth]

### 9.4 Graceful Degradation
[What features degrade under load and how]

---

## 10. Operations

### 10.1 Deployment
[How code gets to production]

### 10.2 Monitoring & Alerting
| Metric | Threshold | Alert | Response |
|--------|-----------|-------|----------|
| [What] | [Value] | [Who/How] | [Action] |

### 10.3 Debugging
[How to investigate issues]

### 10.4 Rollback Plan
[How to undo a bad deploy]

### 10.5 Configuration Management
[How config is stored and changed]

---

## 11. Testing Strategy

### 11.1 Test Levels
| Level | Scope | Tooling | Coverage Target |
|-------|-------|---------|-----------------|
| Unit | [What] | [Tool] | [%] |
| Integration | [What] | [Tool] | [%] |
| E2E | [What] | [Tool] | [Scenarios] |

### 11.2 Test Data Strategy
[How test data is created/managed]

### 11.3 Acceptance Criteria
[Definition of "done" for the feature]

---

## 12. Implementation Plan

### 12.1 Phases
| Phase | Scope | Duration | Milestone |
|-------|-------|----------|-----------|
| 1 | [What's included] | [Time] | [Deliverable] |

### 12.2 Risks & Mitigations
| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| [What could go wrong] | [H/M/L] | [H/M/L] | [How to prevent/respond] |

### 12.3 Open Questions
[Anything still unresolved - should be minimal]

- [ ] [Question] — Owner: [who will answer] — Due: [when]

---

## 13. Appendix

### 13.1 Glossary
| Term | Definition |
|------|------------|
| [Term] | [What it means in this context] |

### 13.2 References
- [Link to related docs, designs, or prior art]

### 13.3 Change Log
| Date | Author | Change |
|------|--------|--------|
| [Date] | [Who] | [What changed] |

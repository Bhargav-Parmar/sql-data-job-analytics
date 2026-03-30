# Skill Economics Across Compensation Tiers in Data Roles

A SQL and Power BI project that explores how technical skills influence compensation in Data Analyst and Data Scientist roles. Instead of looking at the job market as a single pool, this analysis breaks it into three salary tiers to understand which skills drive entry, growth, and premium earnings at each level.

![Dashboard Preview](Assets/Dashboard_preview.png)

📄 [View Full Analysis Report](Assets/Skill_Economics_Report.pdf)

---

## Table of Contents

- [Project Overview](#project-overview)
- [Database Schema](#database-schema)
- [How the Tiers Were Defined](#how-the-tiers-were-defined)
- [Tools Used](#tools-used)
- [Key Findings](#key-findings)
- [Limitations](#limitations)

---

## Project Overview

Most skill analyses treat the job market as one flat list of job postings. This project doesn't. By segmenting roles into three distinct salary tiers — the Specialized Tier, the Premium Tier, and the Mass Market — the analysis reveals how the same skill can mean very different things depending on where in the market it appears.

The core question driving the project was straightforward: do certain skills genuinely command higher pay, or does compensation depend more on the level and context of the role? The answer, it turns out, is both. SQL appears in every tier for both roles, but the average salary associated with it goes from $82K in the Mass Market to $215K in the Specialized Tier for Data Analysts. The skill is the same. The context is not.

All ranking and segmentation logic lives in a single master query using `ROW_NUMBER()` and `NTILE(4)` window functions, both partitioned by job title. This prevents tier drift and ensures that every number in this analysis comes from the same consistent classification framework.

---

## Database Schema

![ERD](Assets/ERD.png)

| Table | Description |
|---|---|
| `job_postings_fact` | Job-level data including role title and average yearly salary |
| `skills_job_dim` | Many-to-many mapping between jobs and required skills |
| `skills_dim` | Standardized technical skill reference table |
| `company_dim` | Company-level metadata |

All joins were reviewed carefully to avoid duplication and inflated aggregation counts.

---

## How the Tiers Were Defined

| Tier | Definition | SQL Method |
|---|---|---|
| Specialized Tier | Top 100 highest-paying roles per job title | `ROW_NUMBER() <= 100` |
| Premium Tier | Top 25% by salary, partitioned by job title | `NTILE(4) = 1` |
| Mass Market | Remaining 75% of the broad market | `NTILE(4) > 1` |

Skill mappings were joined after segmentation, not before, to make sure the tier classification wasn't influenced by which skills happened to be present in a posting.

---

## Tools Used

| Tool | Purpose |
|---|---|
| PostgreSQL | Core querying engine — window functions, CTEs, aggregations |
| SQL | Segmentation logic, salary ranking, skill demand analysis |
| Power BI | Interactive dashboard with tier and job title filters |
| VS Code | Query development and project management |
| Git & GitHub | Version control and project hosting |

---

## Key Findings

### SQL and Python dominate the broad market, but they don't explain premium pay

In the Mass Market, SQL leads Data Analyst demand with 2,238 postings, followed by Excel at 1,795 and Python at 1,245. For Data Scientists in the same tier, Python leads at 3,194 postings, followed by SQL at 2,324 and R at 1,918. These foundational tools are essentially table stakes for getting into either role.

What's more interesting is what happens when you look at the same skills across tiers. SQL's associated average salary for Data Analysts goes from $82K in the Mass Market to $134K in the Premium Tier and $215K in the Specialized Tier. The skill doesn't change — the role context and depth of expertise expected do.

### Cloud and infrastructure skills carry a consistent salary premium

Azure, AWS, and Oracle rank among the highest-paying skills in the Premium Tier for both roles. Even in the Mass Market, niche tools like Electron ($111K average) and Terraform ($110K) outperform the tier average for Data Analysts. This suggests that cloud and infrastructure knowledge lifts compensation regardless of seniority level, not just at the top.

### Data Scientist roles have a significantly higher salary ceiling at every tier

The gap between Data Analyst and Data Scientist compensation isn't just real — it compounds as you move up tiers. In the Mass Market, Data Scientists average $112K versus $82K for Data Analysts, a difference of roughly $30K. In the Premium Tier that gap grows to around $52K ($195K vs $143K). At the Specialized Tier it's most dramatic: Data Scientists average $337K compared to $213K for Data Analysts, a difference of over $124K.

This confirms that while both roles share foundational skill requirements, the Data Scientist path has a substantially higher earnings ceiling and the premium grows with seniority.

### The skills that appear only at the top tell a different story

In the Specialized Tier, C++ is associated with an average salary of $447K for Data Scientists, and Java with $382K. These skills barely appear in the Mass Market. Their high compensation isn't driven by broad demand — it's driven by scarcity. The roles that require them are few, specialized, and pay accordingly.

For Data Analysts in the Specialized Tier, Matlab ($271K) and Kafka ($263K) show the same pattern. High pay, low volume, niche context.

The structural picture that emerges from this analysis is consistent: foundational skills get you in the door. Scalable skills like cloud platforms and advanced frameworks move you up the tiers. Specialized skills at the top are less about breadth and more about the specific, high-impact problems they solve.

---

## Limitations

The dataset is primarily US-focused, so the findings may not generalize to other markets. Soft skills like communication and stakeholder management weren't captured in any of the skill mappings. Some high-paying roles also lacked complete skill data, which may underrepresent certain specialized technologies. Only postings with reported average yearly salaries were included, which could skew results toward employers who are more transparent about compensation. And like any snapshot analysis, this reflects the state of the job market at the time the data was collected — skill demand shifts over time.
# Week 2 – SQL ETL & Excel Analysis

## Overview

In this phase, raw COVID-19 datasets were cleaned, transformed, and integrated using SQL. Excel was then used to perform exploratory analysis and build a preliminary dashboard.

## Datasets Used

- covid_19_india
- covid_vaccine_statewise
- statewise_testing_details

## SQL Tasks Performed

- Data cleaning
- Data type conversion
- Handling missing values
- Standardizing state names
- Removing invalid records
- Calculating analytical metrics

## Key SQL Techniques

Window Functions

Example:

```sql
- confirmed - LAG(confirmed) OVER (PARTITION BY state ORDER BY date)

- Common Table Expressions (CTE)

- Used for multi-step transformations and calculations.

## Metrics Calculated

- Daily New Cases

- Active Cases

- Vaccination Rate

- Positive Test Rate

- Case Fatality Rate

- Excel Analysis

Excel was used to build an interactive dashboard and analyze trends.

## Key Excel functions used:

- INDEX

- MATCH

- SUMIFS

- FILTER

FORECAST.ETS

Outcome

This phase produced a cleaned analytical dataset and early insights into pandemic trends across India.

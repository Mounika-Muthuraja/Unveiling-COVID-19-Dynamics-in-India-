#  AI-Powered COVID Situation Report Automation (n8n + GenAI)

## Project Overview

This project automates the generation of a daily COVID-19 situation report for India using:

- Python (Data Aggregation Layer)
- n8n (Workflow Automation)
- OpenAI (GenAI Report Generation)
- Gmail Integration (Automated Distribution)

The system reads aggregated COVID data, generates a simplified AI-based summary, and sends a professional email report daily.

---

## Problem Statement

Public health data often exists in raw tabular format and requires:

- Aggregation
- Trend interpretation
- Simplified communication
- Automated distribution

This project solves that by converting structured data into an easy-to-understand daily health briefing using AI.

---

## Architecture

Raw Excel Data  
⬇  
Python Aggregation  
⬇  
Structured CSV Output  
⬇  
n8n Workflow  
⬇  
OpenAI Prompt  
⬇  
Automated Gmail Report  

---

## n8n Workflow Steps

1. Schedule Trigger (Daily execution)
2. Read India summary CSV
3. Read State summary CSV
4. Extract and process data
5. Identify top affected states
6. Merge national + state data
7. Generate AI summary using OpenAI
8. Send email via Gmail node

---

## GenAI Usage

### Input to AI:
- National new cases
- Recoveries and deaths
- Test positivity rate
- Vaccination progress
- Top affected states

### Prompt Strategy:
- Non-technical language
- Highlight current situation
- Mention rising/falling trends (if available)

### Output:
AI-generated simplified daily COVID situation report.

---

## Repository Contents

- `n8n-workflow/` – Exported workflow JSON
- `data/` – Sample aggregated datasets
- `screenshots/` – Workflow & output previews

---

## Sample Output

> On 12 May, India reported 72,341 new COVID-19 cases. The situation shows a moderate level of spread with a national positivity rate of 5.3%. Recoveries continue to outpace new infections, while vaccination efforts remain steady across the country. Maharashtra and Kerala reported the highest number of new cases today. Overall, continued monitoring and vaccination progress remain essential.


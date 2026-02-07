# SpendWise - Presentation Draft (15 Slides)

Use this as ready content for PowerPoint/Canva/Google Slides.

---

## Slide 1 - Title
- **Project:** SpendWise
- **Course:** Mobile Development (SwiftUI)
- **Team:** [Group Name]
- **Members:** [Member 1], [Member 2], [Member 3], [Member 4]

**Speaker line:**  
"Hello, we are team [Group Name], and today we present SpendWise, our iOS personal finance app built with SwiftUI."

---

## Slide 2 - Introduction
- SpendWise is a personal finance tracker for daily money control.
- Users can add, edit, delete, and review transactions.
- App combines budgeting, analytics, goals, and currency exchange in one place.

**Speaker line:**  
"Our goal was to create a practical app that helps users track spending and make better financial decisions."

---

## Slide 3 - Relevance
- Many users still track expenses manually or in separate apps.
- Common issues: no clear overview, weak planning, no real-time currency support.
- SpendWise solves this with a unified mobile experience.

**Speaker line:**  
"In a volatile economy, users need fast and clear financial visibility, especially in mobile format."

---

## Slide 4 - Idea and Purpose
- **Idea:** one app for operations + planning + insights.
- **Purpose:** simplify financial discipline and daily decisions.
- **Objectives:**
  - track income/expenses,
  - monitor monthly budget,
  - set and track goals,
  - convert money with live rates.

---

## Slide 5 - Comparison Analysis
- Compared with standard expense trackers:
  - SpendWise includes built-in goals and exchange converter.
  - Clean tab-based navigation and simple onboarding.
  - Local settings + cloud-like realtime sync behavior for transactions.

**Table suggestion:**  
Columns: Feature | Typical App | SpendWise

---

## Slide 6 - Work Division
- **Member 1:** UI/UX, screens, design system.
- **Member 2:** Transaction logic, CRUD, filtering, sorting.
- **Member 3:** Networking (exchange rates), error/loading states.
- **Member 4:** Analytics, goals module, testing, presentation/report.

---

## Slide 7 - Architecture
- Pattern: **MVVM**.
- Layers:
  - **Models** (`Transaction`, `FinancialGoal`, enums),
  - **Views** (SwiftUI screens),
  - **ViewModels** (`TransactionViewModel`, `GoalsViewModel`, `ExchangeViewModel`),
  - **Services** (`TipsAPIService`, repository).
- Data flow: View -> ViewModel -> Service -> ViewModel -> View.

---

## Slide 8 - Diagrams
- **ERD:** User -> Transactions, FinancialGoals, Settings.
- **Use Case Diagram:** add/edit/delete transaction, view analytics, convert currency, manage goals.
- **Sequence Diagram:** user action -> ViewModel -> Service/API -> state update -> UI refresh.

**Tip:** insert 3 simple visuals on this slide.

---

## Slide 9 - Functional & Non-Functional Requirements
- **Functional:**
  - CRUD transactions,
  - filters/sorting/search,
  - analytics and goal progress,
  - exchange conversion.
- **Non-functional:**
  - responsive UI (portrait/landscape),
  - stable navigation,
  - maintainable architecture,
  - clear loading/error/success states.

---

## Slide 10 - Technologies Used
- Swift 5, SwiftUI
- MVVM
- Alamofire (REST networking)
- Firebase Realtime Database (transactions repository)
- UserDefaults (preferences and goals persistence)
- Xcode, Git/GitHub

---

## Slide 11 - User Interface
- Tabs:
  - Home
  - Transactions
  - Analytics
  - Goals
  - Exchange
  - Settings
- Show screenshots:
  - Home summary
  - Transaction list + form
  - Analytics
  - Goals
  - Exchange converter

---

## Slide 12 - Business Model & SWOT
- **Business model options:**
  - freemium (basic free, premium analytics),
  - subscription,
  - partner offers (banks/fintech).
- **SWOT:**
  - Strengths: all-in-one features, simple UX.
  - Weaknesses: early-stage product, limited localization.
  - Opportunities: growing personal finance app market.
  - Threats: high competition, fast feature parity by large apps.

---

## Slide 13 - Experimental Verification & Economic Effectiveness
- Estimated impact for users:
  - lower impulsive spending through visibility,
  - better monthly budget adherence,
  - faster decisions with exchange rates.
- Team cost: development time + testing time.
- Potential value: user retention and premium monetization paths.

---

## Slide 14 - Practical Value
- Daily practical use:
  - students managing allowances,
  - freelancers with mixed income,
  - users with multi-currency expenses.
- SpendWise helps move from reactive spending to planned finance behavior.

---

## Slide 15 - Conclusion
- SpendWise meets key course requirements:
  - SwiftUI components, navigation, state management, MVVM,
  - CRUD + persistence + networking.
- Delivered value: actionable financial dashboard in one mobile app.
- Next steps:
  - notifications,
  - CSV export,
  - deeper analytics and recommendations.

**Final line:**  
"Thank you for your attention. We are ready to demonstrate the app and answer your questions."

---

## Demo Plan (for 15-minute defense)
1. Home overview (1 min)  
2. Create/Edit/Delete transaction (3 min)  
3. Filters + search + sections (2 min)  
4. Analytics screen (2 min)  
5. Goals flow: create goal + contribution (3 min)  
6. Exchange conversion (2 min)  
7. Settings and wrap-up (2 min)

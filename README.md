# apple-retail-sales-sql-analysis
 🍎 Apple Retail Sales Analysis (SQL + Excel)

 📌 Project Overview
This project analyzes Apple retail sales data using **PostgreSQL** for data modeling and querying, and **Excel** for dashboarding and visualization. The dataset covers products, categories, stores, sales transactions, and warranty claims across multiple countries.

The goal is to answer real-world business questions — revenue performance, store/category comparisons, sales trends, and product warranty reliability — using SQL from basic to advanced level (joins, aggregations, subqueries, CTEs, window functions), then present the findings in an interactive Excel dashboard.

---

🗂️ Dataset
The dataset consists of 5 related tables:

| Table       | Description                                      | Rows (approx.) |
|-------------|---------------------------------------------------|----------------|
| `category`  | Product categories                                 | 10             |
| `products`  | Apple products with price and launch date          | 90             |
| `store`     | Retail store locations                              | 75             |
| `sales`     | Individual sales transactions                       | 10,000         |
| `warranty`  | Warranty claims linked to sales                      | 385            |

**Source:** *[add dataset source/link here, e.g. Kaggle]*

### Entity Relationship
```
category (1) ───< (many) products (1) ───< (many) sales (1) ───< (many) warranty
                                              │
                                store (1) ───<┘
```

---

 🛠️ Tools Used
- **PostgreSQL** — schema design, data loading, querying
- **SQL** — joins, aggregations, subqueries, CTEs, window functions
- **Excel** — PivotTables, PivotCharts, dashboard building
- *(optional)* **Power Query** — connecting Excel directly to PostgreSQL

---

 🏗️ Database Schema
sql
CREATE TABLE category (
    category_id VARCHAR(20) PRIMARY KEY,
    category_name VARCHAR(50) NOT NULL
);

CREATE TABLE store (
    store_id VARCHAR(15) PRIMARY KEY,
    store_name VARCHAR(100) NOT NULL,
    city VARCHAR(50) NOT NULL,
    country VARCHAR(50) NOT NULL
);

CREATE TABLE products (
    product_id VARCHAR(20) PRIMARY KEY,
    product_name VARCHAR(50) NOT NULL,
    category_id VARCHAR(10),
    launch_date DATE,
    price DECIMAL(10,2),
    FOREIGN KEY (category_id) REFERENCES category(category_id)
);

CREATE TABLE sales (
    sale_id VARCHAR(10) PRIMARY KEY,
    sale_date DATE NOT NULL,
    store_id VARCHAR(15) NOT NULL,
    product_id VARCHAR(20) NOT NULL,
    quantity INT NOT NULL CHECK (quantity > 0),
    FOREIGN KEY (store_id) REFERENCES store(store_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

CREATE TABLE warranty (
    claim_id VARCHAR(15) PRIMARY KEY,
    claim_date DATE NOT NULL,
    sale_id VARCHAR(10) NOT NULL,
    repair_status VARCHAR(20) DEFAULT 'Pending',
    FOREIGN KEY (sale_id) REFERENCES sales(sale_id)
);


Full schema + data loading script: [`schema.sql`](./sql/schema.sql)

---

 🧹 Data Cleaning
- Checked for null values, duplicate rows, and duplicate primary keys across all 5 tables → none found.
- Verified referential integrity (every `sales.product_id` exists in `products`, every `sales.store_id` exists in `store`, every `warranty.sale_id` exists in `sales`) → no orphan records.
- Standardized inconsistent column-naming conventions across source CSVs (mixed `CamelCase`/`snake_case`) to a single `snake_case` convention before loading into SQL.
- Validated date fields and numeric ranges (price, quantity) → no invalid or out-of-range values.

---

 ❓ Business Questions & SQL Solutions
20 questions, ranging from basic to advanced, are solved in [`queries.sql`](./sql/queries.sql), including:

Basic
- Highest and lowest priced products
- Products launched in a given year
- Stores by country

Intermediate
- Total revenue per category
- Stores with revenue above a threshold (`HAVING`)
- Monthly sales trend
- Products never sold (`LEFT JOIN` + `IS NULL`)
- Warranty claims per product

Advanced
- Top 3 best-selling products per category (`RANK() OVER (PARTITION BY ...)`)
- Month-over-month revenue growth (`LAG()`)
- Running total revenue per store (`SUM() OVER`)
- Product warranty claim rate (`CTE`)
- Top-selling category per country (`CTE` + `RANK()`)
- Average claim delay by repair status

*(See [`queries.sql`](./sql/queries.sql) for the full list and solutions.)*

---

## 📊 Dashboard
An interactive Excel dashboard was built from the query results, including:
- KPI cards: Total Revenue, Total Units Sold, Average Order Value
- Category-wise revenue breakdown (PivotChart)
- Store performance comparison
- Monthly sales trend
- Warranty claim rate by product

📁 File: [`dashboard.xlsx`](./excel/dashboard.xlsx)

![Dashboard Screenshot](./screenshots/dashboard.png)

---

💡 Key Insights
*(Replace with your actual findings once the dashboard is built)*

1. [Category] generates the highest share of total revenue (**X%**), driven mainly by **[Store/Country]**.
2. [Product] has the highest warranty claim rate (**X%**), suggesting a potential quality concern worth reviewing.
3. Sales show a [seasonal pattern/trend]** — revenue peaks in **[month(s)]**.
4. [Store/Country] consistently ranks as the top performer by revenue and units sold.
5. [X%] of products in the catalog recorded zero sales during the analyzed period.

---

📁 Repository Structure
```
├── sql/
│   ├── schema.sql        -- table creation + constraints
│   └── queries.sql       -- all 20 business questions with solutions
├── excel/
│   └── dashboard.xlsx    -- final Excel dashboard
├── screenshots/
│   └── dashboard.png     -- dashboard preview image
└── README.md
```

---

 🚀 How to Reproduce
1. Clone this repo.
2. Create a PostgreSQL database and run [`sql/schema.sql`](./sql/schema.sql) to create the tables.
3. Load the CSV data using the `COPY` commands included in the schema file (update file paths to your local machine).
4. Run [`sql/queries.sql`](./sql/queries.sql) to reproduce the analysis.
5. Open [`excel/dashboard.xlsx`](./excel/dashboard.xlsx) to view the dashboard, or connect Excel's Power Query to your PostgreSQL instance to refresh it live.

---

👤 Author
MD.SHAHADUZZAMAN
[LinkedIn](#) · [GitHub](#) · [Portfolio](#)

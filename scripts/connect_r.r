# connect_R.R

# install.packages("DBI")
# install.packages("RPostgres")

library(DBI)
library(RPostgres)

# Connect to Postgres
con <- dbConnect(
  RPostgres::Postgres(),
  dbname   = "lung_cancer_db",
  host     = "localhost",
  port     = 5432,
  user     = "username",
  password = "password"
)

# Example: Retrieve the entire table
df <- dbGetQuery(con, "SELECT * FROM lung_cancer_data;")
print(head(df))

# Example: Some aggregator query
agg_query <- "
  SELECT gender, pulmonary_disease, COUNT(*) as total
  FROM lung_cancer_data
  GROUP BY gender, pulmonary_disease
  ORDER BY total DESC;
"
df_agg <- dbGetQuery(con, agg_query)
print(df_agg)

# Close the connection
dbDisconnect(con)

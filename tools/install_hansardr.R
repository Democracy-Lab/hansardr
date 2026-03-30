# 1. Ensure remotes is installed
if (!"remotes" %in% rownames(installed.packages())) {
  install.packages("remotes")
}

# 2. Load remotes
library(remotes)

# 3. Give slow networks plenty of time (30 mins)
options(timeout = max(1800, getOption("timeout")))
Sys.setenv(CURL_TIMEOUT = "1800")

# 4. Install hansardr from GitHub
remotes::install_github(
  "Democracy-Lab/hansardr",
  dependencies = TRUE,
  upgrade = "always")

# fix btyd package
library(BTYD)

# ====================
# Pareto - NBD
# ====================
cdnowElog = system.file("data/cdnowElog.csv", package = "BTYD")
elog = dc.ReadLines(cdnowElog, cust.idx = 2, date.idx = 3, sales.idx = 5)
elog$date = as.Date(elog$date, "%Y%m%d")
cal.cbs = dc.ElogToCbsCbt(elog)
params = pnbd.EstimateParameters(cal.cbs$cal$cbs)

# create a data set with large transactions,
# by adding an integer 60-120 to the existing transactions.
data_cal_fail = cal.cbs$cal$cbs
N = length(data_cal_fail[,"x"])
data_cal_fail[,"x"] = data_cal_fail[,"x"] + floor(runif(N, 60,120)) 
params = pnbd.EstimateParameters(data_cal_fail)
# erorr message:
# Error in optim(logparams, pnbd.eLL, cal.cbs = cal.cbs, max.param.value = max.param.value,  : 
#                  L-BFGS-B needs finite values of 'fn
# log likelihood calculation blows up.

# The problem is in the way the log likelihood is computed with pnbd.LL
pnbd.LL(params, 600, 100, 120)
# [1] NaN
# Warning message:
#   In log(F1 - F2) : NaNs produced

# do the log exp sum trick on the term:
# log(exp(part2) + exp(part3))
pnbd.LL2= function (params, x, t.x, T.cal) 
{
  max.length <- max(length(x), length(t.x), length(T.cal))
  if (max.length%%length(x)) 
    warning("Maximum vector length not a multiple of the length of x")
  if (max.length%%length(t.x)) 
    warning("Maximum vector length not a multiple of the length of t.x")
  if (max.length%%length(T.cal)) 
    warning("Maximum vector length not a multiple of the length of T.cal")
  dc.check.model.params(c("r", "alpha", "s", "beta"), params, 
                        "pnbd.LL")
  if (any(x < 0) || !is.numeric(x)) 
    stop("x must be numeric and may not contain negative numbers.")
  if (any(t.x < 0) || !is.numeric(t.x)) 
    stop("t.x must be numeric and may not contain negative numbers.")
  if (any(T.cal < 0) || !is.numeric(T.cal)) 
    stop("T.cal must be numeric and may not contain negative numbers.")
  x <- rep(x, length.out = max.length)
  t.x <- rep(t.x, length.out = max.length)
  T.cal <- rep(T.cal, length.out = max.length)
  r <- params[1]
  alpha <- params[2]
  s <- params[3]
  beta <- params[4]
  maxab <- max(alpha, beta)
  absab <- abs(alpha - beta)
  param2 <- s + 1
  if (alpha < beta) {
    param2 <- r + x
  }
  part1 <- r * log(alpha) + s * log(beta) - lgamma(r) + lgamma(r + x)
  part2 <- -(r + x) * log(alpha + T.cal) - s * log(beta + T.cal)
  if (absab == 0) {    
    part2_times_F1_min_F2 <- ( (alpha+T.cal)/(maxab+t.x) )^(r+x) * (beta+T.cal)^s / 
      ((maxab+t.x)^s) -
      ( (alpha+T.cal)/(maxab+T.cal) )^(r+x) * (beta+T.cal)^s / 
      ((maxab+t.x)^s) 
  }
  else {
    part2_times_F1_min_F2 = h2f1(r+s+x, param2, r+s+x+1, absab / (maxab+t.x)) * 
      ( (alpha+T.cal)/(maxab+t.x) )^(r+x) * (beta+T.cal)^s / 
      ((maxab+t.x)^s) -
      h2f1(r+s+x, param2, r+s+x+1, absab / (maxab+T.cal)) * 
      ( (alpha+T.cal)/(maxab+T.cal) )^(r+x) * (beta+T.cal)^s / 
      ((maxab+t.x)^s)
  }
  return(part1 + part2 + log(1+(s/(r+s+x))*part2_times_F1_min_F2) )
}

# test
pnbd.LL(params, 4, 58, 77.85714)
# [1] -17.72723
pnbd.LL2(params, 4, 58, 77.85714)
# [1] -17.73464
pnbd.LL2(params, 600, 100, 120)
# [1] 395.4643


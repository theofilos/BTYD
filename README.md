## fix for BTYD

BTYD is an R package for computing customer lifetime value. The fix is for the model called Pareto/NBD. It assumes Poisson distributed purchases with a Gamma prior and exponentially distributed customer lifetimes with a Gamma prior. It calculates the optimal parameters for these distributions by maximizing the log likelihood of the observed customer purchase history.

In its current form the package cannot compute a solution when the number of customer purchases is on the order of 100. The reason is that in the computation of log likelihood there is a a^(r+s+x) where x is the number of transactions, which blows up for large x. I use the log exp sum trick to combine it with the log which makes the computation of the log likelihood numerically stable.

The error is demonstrtated in fix_btyd.R, corrected and tested on the data set of the package. The corrected R code is in pnbd.R

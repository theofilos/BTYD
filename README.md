## fix for BTYD

BTYD is an R package for computing customer lifetime value. The fix is for the model called Pareto/NBD. It assumes Poisson distributed purchases with a Gamma prior and exponentially distributed customer lifetimes with a Gamma prior. It calculates the optimal parameters for these distributions by maximizing the log likelihood of the observed customer purchase history.

In its current form the package cannot compute a solution when the number of customer purchases is on the order of 100. The reason is that in the computation of log likelihood there is a a^(r+s+x) where x is the number of transactions, which blows up for large x. I use the log exp sum trick to combine it with the log which makes the computation of the log likelihood numerically stable. For a>b the original likelihood is
![equation](http://www.sciweavers.org/tex2img.php?eq=%5Cfrac%7B%5CGamma%28r%2Bx%29%5Calpha%5Er%5Cbeta%5Es%7D%7B%5CGamma%28r%29%7D%5Cleft%5C%7B%5Cfrac%7B1%7D%7B%28%5Calpha%2BT%29%5E%7Br%2Bx%7D%28%5Cbeta%2BT%29%5Es%7D%2B%5Cleft%28%5Cfrac%7Bs%7D%7Br%2Bs%2Bx%5Cright%29%5Cleft%28%5Cfrac%7B2F1%28...%29%7D%7B%28%5Calpha%2Bt_x%29%5E%7Br%2Bs%2Bx%7D%7D-%5Cfrac%7B2F1%28...%29%7D%7B%28%5Calpha%2BT%29%5E%7Br%2Bs%2Bx%7D%7D%5Cright%29%5Cright%5C%7D&bc=White&fc=Blue&im=jpg&fs=12&ff=arev&edit=0)

Factor out the offending term:
![equation](http://www.sciweavers.org/tex2img.php?eq=%5Cfrac%7B%5CGamma%28r%2Bx%29%5Calpha%5Er%5Cbeta%5Es%7D%7B%5CGamma%28r%29%7D%5Cfrac%7B1%7D%7B%28%5Calpha%2BT%29%5E%7Br%2Bx%7D%28%5Cbeta%2BT%29%5Es%7D%5Cleft%5C%7B1%2B%5Cleft%28%5Cfrac%7Bs%7D%7Br%2Bs%2Bx%5Cright%29%5Cleft%28%5Cfrac%7B%28%5Calpha%2BT%29%5E%7Br%2Bx%7D%28%5Cbeta%2BT%29%5Es%7D%7B%28%5Calpha%2Bt_x%29%5E%7Br%2Bs%2Bx%7D%7D2F1%28...%29-%5Cfrac%7B%28%5Calpha%2BT%29%5E%7Br%2Bx%7D%28%5Cbeta%2BT%29%5Es%7D%7B%28%5Calpha%2BT%29%5E%7Br%2Bs%2Bx%7D%7D2F1%28...%29%5Cright%29%5Cright%5C%7D%0A%0A%0A%0A&bc=White&fc=Blue&im=jpg&fs=12&ff=arev&edit=0)

Combine terms with the same exponents:
![equation](http://www.sciweavers.org/tex2img.php?eq=%5Cfrac%7B%5CGamma%28r%2Bx%29%5Calpha%5Er%5Cbeta%5Es%7D%7B%5CGamma%28r%29%7D%5Cfrac%7B1%7D%7B%28%5Calpha%2BT%29%5E%7Br%2Bx%7D%28%5Cbeta%2BT%29%5Es%7D%5Cleft%5C%7B1%2B%5Cleft%28%5Cfrac%7Bs%7D%7Br%2Bs%2Bx%5Cright%29%5Cleft%28%5Cleft%28%5Cleft%5Cfrac%7B%5Calpha%2BT%7D%7B%5Calpha%2Bt_x%7D%5Cright%29%5E%7Br%2Bx%7D%5Cleft%28%5Cfrac%7B%5Cbeta%2BT%7D%7B%5Calpha%2Bt_x%7D%5Cright%29%5Es2F1%28...%29-%5Cleft%28%5Cfrac%7B%5Cbeta%2BT%7D%7B%5Calpha%2BT%7D%5Cright%29%5Es2F1%28...%29%5Cright%29%5Cright%5C%7D&bc=White&fc=Blue&im=jpg&fs=12&ff=arev&edit=0)

The term ![equation](http://www.sciweavers.org/tex2img.php?eq=%5Cfrac%7B%5Calpha%2BT%7D%7B%5Calpha%2Bt_x%7D&bc=White&fc=Blue&im=jpg&fs=12&ff=arev&edit=0) is very close to one so it can be exponentiated.

We take the logarithm of ![equation](http://www.sciweavers.org/tex2img.php?eq=%5Cfrac%7B1%7D%7B%28%5Calpha%2BT%29%5E%7Br%2Bx%7D%28%5Cbeta%2BT%29%5Es%7D&bc=White&fc=Blue&im=jpg&fs=12&ff=arev&edit=0) so it does not blow up even if x is large.



The error is demonstrtated in fix_btyd.R, corrected and tested on the data set of the package. The corrected R code is in pnbd.R

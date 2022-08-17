# >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
# Project: chapter II 
# Date started: 09-04-2021
# Date last modified: 09-04-2021
# Author: Simeon Q. Smeele
# Description: Simple cross correlation of two vectors. Uses zero embedding to find optimal overlap. Also 
# has an option to normalise by the longest vector (divides final difference by length).
# >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

simple.cc = function(s1, s2, # two vectors
                     norm = F){ # if T, the final difference is divided by the length of the longest vector
  
  # Run through positions
  np = length(s1) + length(s2) - 1
  os = sapply(seq(1, np, 1), function(i){
    r = length(s1)
    t1 = c(rep(0, max(0, i - length(s1))),
           s1,
           rep(0, max(0, length(s2) - i)))
    t2 = c(rep(0, max(0, length(s1) - i)),
           s2,
           rep(0, max(0, i - length(s2))))
    o = sum(abs(t2 - t1))
    return(o)
  })
  
  # Return
  if(norm) os = os / max(c(length(s1), length(s2)))
  return(min(os))
  
}
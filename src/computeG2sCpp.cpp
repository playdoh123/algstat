#include <Rcpp.h>
using namespace Rcpp;

// [[Rcpp::export]]
NumericVector computeG2sCpp(NumericMatrix x, NumericVector exp){

  int ncol = x.ncol();
  int n = x.nrow();
  NumericVector out(ncol);
  double chisq;

  for(int i = 0; i < ncol; ++i){
    chisq = 0;
    for(int j = 0; j < n; ++j){
      if(x(j,i) > 0){
        if(exp[j] > 0) chisq += x(j,i) * log(x(j,i) / exp[j]); // 0 ow, contributes nothing to sum
      }
    }
    out[i] = 2*chisq;
  }

  return out;
}

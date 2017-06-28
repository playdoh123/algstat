#include <Rcpp.h>
#include "rcddAPI.h"




using namespace Rcpp;

// [[Rcpp::export]]


IntegerVector timesTwo(NumericVector constr, NumericVector objfun, LogicalVector minimize, CharacterVector solver) {
  SEXP out = lpcdd_f(constr, objfun, minimize, solver);
  IntegerVector tmp = VECTOR_ELT(out, 3);
  
  return tmp;
}




//***Things to do before running the code***
//set_4ti2_path("/home/ubuntu/Documents/LattE/dest/bin")
// library(algstat)
// library(Rcpp)
// sourceCpp("/home/ubuntu/algstat/src/SIS.cpp")

//***CODE GUIDE***A
//SEXP lpsolver(NumericVector const, NumbericVector objfun, LogicalVector minimize, CharacterVector solver) {
//SEXP out = lpcdd_f(const, objfun, minimize, solver);
//IntegerVector tmp = VECTOR_ELT(out, 3); <------ this is extracting the 4th element from SEXP; check 'x' == "optimal"
//return tmp;
//}
///solver is "DualSimplex"


//I need to mamke tbl, A, suff_stats (A %*% tbl)



/*** R
##tbl <- matrix(c(2, 4, 6, 8, 10, 12, 14, 16),nrow = 8, ncol = 1)
##A <- hmat(c(4,2), 1:2)
##suff_stats <- matrix(A %*% tbl)

##constr(A,suff_stats)

tbl <- matrix(c(2, 4, 6, 8, 10, 12, 14, 16, 18), ncol = 1) ##Making the vector into a matrix
A <- hmat(c(3,3), 1:2)
suff_stats <- A %*% tbl ##I need to transpose this? ----> t(t(tbl))?????
constraint <- cbind(rep(1,6),suff_stats,A)
constraint1 <- cbind(rep(0,9),rep(0,9),diag(-1,9))
constraint2 <- rbind(constraint,constraint1)

timesTwo(constraint2, c(0,-1,0,0,0,0,0,0,0,0),minimize = FALSE, solver = "DualSimplex") ##don't add '0' for R
*/

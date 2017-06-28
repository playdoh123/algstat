#include <Rcpp.h>
using namespace Rcpp;

// This is a simple example of exporting a C++ function to R. You can
// source this function into an R session using the Rcpp::sourceCpp 
// function (or via the Source button on the editor toolbar). Learn
// more about Rcpp at:
//
//   http://www.rcpp.org/
//   http://adv-r.had.co.nz/Rcpp.html
//   http://gallery.rcpp.org/
//

// [[Rcpp::export]]
IntegerMatrix constr(IntegerMatrix A, IntegerMatrix suffstat) {
  //Finding the CONSTRAINTS
  int row = A.nrow() + A.ncol();
  int col = A.ncol();
  
  IntegerMatrix dummy(row, col+2);
  IntegerMatrix diag(col,col);  // <----- Is this EFF?????
  
  for(int i = 0; i < col; ++i) {
    for(int j = 0; j < col; ++j) {
      if(i == j) {
        diag(i,i) = -1;
      }
    }
  }
  
  for(int i = 0; i < (col + 2); ++i) {
    for(int j = 0; j < row; ++j) {
      if(i == 0) {
        if(j < (row - col)) {
          dummy(j,i) = 1;
        }
        else {
          dummy(j,i) = 0;
        }
      }
      else if(i == 1) {
        if(j < (row - col)) {
          dummy(j,i) = suffstat[j];
        }
        else {
          dummy(j,i) = 0;
        }
      }
      else{
        if(j < (row - col)) {
          dummy(j,i) = A(j,i-2);
        }
        else {
          dummy(j,i) = diag(j-A.nrow(),i-2);
        }
      }
      
    }
  }
  
  
  
  ///Finding the objectionfunction
  int counter = 1;
  IntegerVector objfun(col + 1);
  
  for(int i = 0; i < (col + 1); ++i) {
    if(counter == i) {
      objfun[i] = -1;
    }
    else{
      objfun[i] = 0;
    }
  }
  counter++; //this is needed when updating
  
  
  
  return dummy;
}


// You can include R code blocks in C++ files processed with sourceCpp
// (useful for testing and development). The R code will be automatically 
// run after the compilation.
//

/*** R
timesTwo(42)
*/

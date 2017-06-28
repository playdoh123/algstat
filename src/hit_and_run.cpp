#include <Rcpp.h>
using namespace Rcpp;

// [[Rcpp::export]]
IntegerVector HitnRun(IntegerVector current, IntegerVector move) {
  IntegerVector new_move = move[move != 0];
  IntegerVector new_current = current[move != 0];
  
  IntegerVector possibleC = (-1*new_current)/new_move;
  
  
  IntegerVector pos, neg;
  int Cmax, Cmin;
  
  IntegerVector proposedT, Crange, temp(1);
  int moveC;
  
  //Finding the positive and negative values in the possibleC
  pos = possibleC[possibleC > 0];
  if(pos.size() ==  0) {
    Cmax = -1;
  } else {
    Cmax = min(pos);
  }
  
  neg = possibleC[possibleC < 0];
  if(neg.size() ==0) {
    Cmin = 1;
  } else {
    Cmin = max(neg);
  }
  
  
  //Test to see if the boundary works...
  proposedT = current + Cmin*move;
  for(int i = 0; i < proposedT.size(); ++i) {
    if(proposedT[i] < 0) {
      Cmin = 1;
    }
  }
  
  proposedT = current + Cmax*move;
  for(int i = 0; i < proposedT.size(); ++i) {
    if(proposedT[i] < 0) {
      Cmax = -1;
    }
  }
  
  //Finding the range for C
  Crange = seq(Cmin, Cmax);
  
  //Finding the proposed table
  temp = sample(Crange, 1);
  moveC = Rcpp::as<int>(temp);
  
  while(moveC == 0) {
    temp = sample(Crange, 1);
    moveC = Rcpp::as<int>(temp);
  }
  
  proposedT = current + moveC*move;
  
  return proposedT;
}


//library(devtools)
//install_github("GrantInnerst/rcdd")

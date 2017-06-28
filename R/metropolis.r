#' The Metropolis Algorithm
#' 
#' Given a starting table (as a vector) and a collection of moves, 
#' run the Metropolis-Hastings algorithm starting with the starting 
#' table.
#' 
#' See Algorithm 1.1.13 in LAS, the reference below.
#' 
#' @param init the initial step
#' @param moves the moves to be used (the negatives will be added); 
#'   they are arranged as the columns of a matrix.
#' @param iter number of chain iterations
#' @param burn burn-in
#' @param thin thinning
#' @param dist steady-state distribution; "hypergeometric" (default)
#'   or "uniform"
#' @param engine C++ or R? (C++ yields roughly a 20-25x speedup)
#' @name metropolis
#' @return a list
#' @export metropolis
#' @author David Kahle
#' @references Drton, M., B. Sturmfels, and S. Sullivant (2009). 
#'   \emph{Lectures on Algebraic Statistics}, Basel: Birkhauser 
#'   Verlag AG.
#' @examples
#' 
#' \dontrun{
#' 
#' library(ggplot2); theme_set(theme_bw())
#' 
#' # move up and down integer points on the line y = 100 - x
#' # sampling from the hypergeometric distribution
#' init <- c(10,90)
#' moves <- matrix(c(1,-1), ncol = 1)
#' out <- metropolis(init, moves)
#' qplot(out$steps[1,])
#' 
#' # view convergence through trace plot
#' qplot(1:1000, out$steps[1,])
#' 
#' # sampling from the hypergeometric distribution
#' out <- metropolis(init, moves, dist = "uniform")
#' qplot(out$steps[1,])
#' 
#' # view convergence through trace plot
#' qplot(1:1000, out$steps[1,])
#' 
#' # look at autocorrelation
#' acf(out$steps[1,])
#' # thin
#' out <- metropolis(init, moves, dist = "uniform", thin = 2500)
#' acf(out$steps[1,])
#' qplot(out$steps[1,])
#' 
#' 
#' 
#' 
#' 
#' 
#' 
#' 
#' 
#' 
#' 
#' 
#' 
#' 
#' 
#' 
#' 
#' 
#' data(handy)
#' 
#' exp   <- loglin(handy, as.list(1:2), fit = TRUE)$fit
#' e <- unname(tab2vec(exp))
#' h <- t(t(unname(tab2vec(handy))))
#' chisq <- algstat:::computeX2sCpp(h, e)
#' 
#' out <- loglinear(~ Gender + Handedness, data = handy)
#' chisqs <- algstat:::computeX2sCpp(out$steps, e)
#' 
#' mean(chisqs >= chisq)
#' fisher.test(handy)$p.value
#' 
#' 
#' 
#' 
#' 
#' A <- hmat(c(2,2), as.list(1:2))
#' moves <- markov(A)
#' outC <- metropolis(tab2vec(handy), moves, 1e4, engine = "Cpp")
#' str(outC)
#' outR <- metropolis(tab2vec(handy), moves, 1e4, engine = "R", thin = 20)
#' str(outR)
#' 
#' # showSteps(out$steps)
#' 
#' 
#' library(microbenchmark)
#' microbenchmark(
#'   metropolis(tab2vec(handy), moves, engine = "Cpp"),
#'   metropolis(tab2vec(handy), moves, engine = "R")
#' )
#' 
#' # cpp ~ 20-25x faster
#' 
#' 
#' 
#' 
#' 
#' 
#' 
#' 
#' 
#' 
#' 
#' 
#' 
#' showSteps <- function(steps){
#'   apply(steps, 2, function(x){
#'     x <- format(x)
#'     tab <- vec2tab(x, dim(handy))
#'     message(
#'       paste(
#'         apply(tab, 1, paste, collapse = " "),
#'         collapse = " "
#'       )
#'     )
#'     message("
#' ", appendLF = F)
#'   })
#'   invisible()
#' }
#' # showSteps(out$steps)
#' 
#' 
#' 
#' 
#' 
#' 
#' 
#' 
#' }
#' 
#' 
metropolis <- function(init, moves, iter = 1E3, burn = 0, thin = 1,
  dist = c("hypergeometric","uniform"), engine = c("Cpp","R"), hit_and_run = FALSE
  
){

  ## preliminary checking
  ##################################################
  dist <- match.arg(dist)
  engine <- match.arg(engine)
  if(thin == 0){
    message("thin = 1 corresponds to no thinning, resetting thin = 0.")
    thin <- 1
  }
  

  ## in R
  ##################################################
  if(engine == "R"){

  nMoves <- ncol(moves)
  state  <- matrix(nrow = nrow(moves), ncol = iter)

  ## run burn-in

  current <- unname(init)
  unifs <- runif(burn)
  
  message("Running chain (R)... ", appendLF = FALSE)
  
  if(burn > 0) {
    for(k in 1:burn){

      move      <- sample(c(-1,1), 1) * moves[,sample(nMoves,1)]
      propState <- current + move
    
      if(any(propState < 0)){
        prob <- 0
      } else {
        if(dist == "hypergeometric"){
          prob <- exp( sum(lfactorial(current)) - sum(lfactorial(propState)) )
        } else { # dist == "uniform"
          prob <- 1
        }
      }
    
      if(unifs[k] < prob) current <- propState # else current
    
    }
    state[,1] <- current
  }

  ## run main sampler

  totalRuns <- 0
  probTotal <- 0
  unifs <- runif(iter*thin)  
  
  for(k in 2:iter){
  	
  	for(j in 1:thin){

      move      <-  moves[,sample(nMoves,1)]
      
      if(hit_and_run) {
        ##DO's code start here (hit and run)
        new_move <- move[move != 0]
        new_current <- current[move != 0]
        
        
        possibleC <- (-1*new_current)/new_move
        
        
        #Find th minimum and the maximum value of 0C
        if(any(possibleC > 0)) {
          pos <- possibleC[possibleC > 0]
          Cmax <- min(pos)
        } else {
          Cmax <- -1
        }
        
        if(any(possibleC < 0)) {
          neg <- possibleC[possibleC < 0]
          Cmin <- max(neg)
        } else {
          Cmin <- 1
        }
        
        #Test to see if the boundary works...
        propState <- current + Cmin*move
        if(any(propState < 0)) {
          Cmin <- 1
        }
        
        propState <- current + Cmax*move
        if(any(propState < 0)) {
          Cmax <- -1
        }
        
        #Finding the range for C(use of zero)
        if(Cmin == 1) {
          Crange <- c(1:Cmax)
        } else if(Cmax == -1) {
          Crange <- c(Cmin:-1)
        } else if(Cmin == 1 && Cmsx ==-1) {
          Crange <-c(-1,1)
        } else {
          Crange <- c(Cmin:-1,1:Cmax)
        }
        
        #Finding the proposed table
        moveC <- sample(Crange,1)
        propState <- current + moveC*move
        print(propState)  
        #END
      }
      
      propState <- current + move
    
      if(any(propState < 0)){
        prob <- 0
      } else {
        if(dist == "hypergeometric"){
          prob <- exp( sum(lfactorial(current)) - sum(lfactorial(propState)) )
        } else { # dist == "uniform"
          prob <- 1
        }
      }
      probTotal <- probTotal + min(1, prob)

      if(unifs[k*(thin-1)+j] < prob) current <- propState # else current
      
      totalRuns <- totalRuns + 1        
    }

    state[,k] <- current    
  }
  message("done.")  
  
  ## format output
  out <- list(
    steps = state, 
    moves = moves, 
    acceptProb = probTotal / totalRuns
  )
  
  
  

  }
  
  ## in Cpp
  ##################################################
  if(engine == "Cpp"){
    
  current   <- unname(init)  
  allMoves  <- cbind(moves, -moves)  
  sampler   <- if(dist == "hypergeometric") {
    metropolis_hypergeometric_cpp
  } else {
    metropolis_uniform_cpp
  }
  message("Running chain (C++)... ", appendLF = FALSE)  
  if (burn > 0) current <- sampler(current, allMoves, burn, 1,hit_and_run)$steps[,burn]
  out       <- sampler(current, allMoves, iter, thin,hit_and_run)
  out$moves <- moves
  message("done.")

  }


  ## return output
  ##################################################  

  out[c("steps", "moves", "acceptProb")]
}








#' @rdname metropolis
#' @export
rawMetropolis <- function(init, moves, iter = 1E3, dist = "hypergeometric", hit_and_run = FALSE){
  metropolis(init, moves, iter, burn = 0, thin = 1, dist = dist, hit_and_run) 
}


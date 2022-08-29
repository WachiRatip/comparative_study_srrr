# dependecies
library(MASS)
library(rrpack)
library(Metrics)

# set seed
set.seed(1)

# set parameters
n <- 64
p <- 64
q <- 8
r <- 4
p.0 <- 16
rho.x <- 0
rho.e <- 0

genData <- function(n,p,q,r,p.0,rho.x,rho.e) {
  # create the true target C from A and B matrices
  A <- rbind(matrix(rnorm((p-p.0)*r,mean=0,sd=1), p-p.0, r), matrix(0, p.0, r))
  B <- matrix(rnorm(q*r,mean=0,sd=1), q, r)
  P <- matrix(rbinom(p*q, size=1, 0.5), p, q)
  C <-(A %*% t(B)) * P
  
  # create Sigma for the predictor matrix: e_ij = rho^|i-j|
  predictor.Sigma <- matrix(rep(rho.x, p), p, p)^abs(t(replicate(p, seq(p)))-seq(p))
  
  # create n predictors
  X <- mvrnorm(n, rep(0,p), predictor.Sigma)
  
  # create Sigma for the error matrix: e_ij = rho^|i-j|
  error.Sigma <- matrix(rep(rho.e, q), q, q)^abs(t(replicate(q, seq(q)))-seq(q))
  
  # create the error matrix
  E <- mvrnorm(n, rep(0,q), error.Sigma)
  
  # create the response matrix
  Y <- X %*% C + E
  
  return(list(C=C, X=X, Y=Y))
}

# training functions
ols.model <- function(C,X,Y,nresponse) {
  # build a model
  C.est <- solve(t(X)%*%X)%*%t(X)%*%Y
  # model evaluation: MSE
  mse <- mse(C, C.est)
  # model evaluation: specificity; ratio between the number of correct deletion
  # and the total number of irrelevant variables
  specificity <- sum((rowSums(C.est==0)==nresponse)&(rowSums(C==0)==nresponse))/sum(rowSums(C==0)==q)
  # model evaluation: sensitivity; ratio between the number of correct selection 
  # and the total number of relevant variables
  sensitivity <- sum((rowSums(C.est!=0)>0)&(rowSums(C!=0)>0))/sum(rowSums(C!=0)>0)
  
  return(c(mse, specificity, sensitivity))
}

rrr.model <- function(C,X,Y,nresponse,nrank) {
  # build a model
  rrrfit <- rrr.fit(Y, X, nrank = nrank)
  C.est <- rrrfit$coef
  # model evaluation: MSE
  mse <- mse(C, C.est)
  # model evaluation: specificity; ratio between the number of correct deletion
  # and the total number of irrelevant variables
  specificity <- sum((rowSums(C.est==0)==nresponse)&(rowSums(C==0)==nresponse))/sum(rowSums(C==0)==q)
  # model evaluation: sensitivity; ratio between the number of correct selection 
  # and the total number of relevant variables
  sensitivity <- sum((rowSums(C.est!=0)>0)&(rowSums(C!=0)>0))/sum(rowSums(C!=0)>0)
  
  return(c(mse, specificity, sensitivity))
}

srrr.model <- function(C,X,Y,nresponse,nrank) {
  # build a model
  srrrfit <- srrr(Y, X, nrank = nrank, ic.type = "BIC")
  C.est <- coef(srrrfit)
  # model evaluation: MSE
  mse <- mse(C, C.est)
  # model evaluation: specificity; ratio between the number of correct deletion
  # and the total number of irrelevant variables
  specificity <- sum((rowSums(C.est==0)==nresponse)&(rowSums(C==0)==nresponse))/sum(rowSums(C==0)==q)
  # model evaluation: sensitivity; ratio between the number of correct selection 
  # and the total number of relevant variables
  sensitivity <- sum((rowSums(C.est!=0)>0)&(rowSums(C!=0)>0))/sum(rowSums(C!=0)>0)
  
  return(c(mse, specificity, sensitivity))
}

sofar.model <- function(C,X,Y,nresponse,nrank) {
  # build a model
  sofarfit <- sofar(Y, X, nrank = nrank, ic.type="AIC")
  C.est <- coef(sofarfit)
  # model evaluation: MSE
  mse <- mse(C, C.est)
  # model evaluation: specificity; ratio between the number of correct deletion
  # and the total number of irrelevant variables
  specificity <- sum((rowSums(C.est==0)==nresponse)&(rowSums(C==0)==nresponse))/sum(rowSums(C==0)==q)
  # model evaluation: sensitivity; ratio between the number of correct selection 
  # and the total number of relevant variables
  sensitivity <- sum((rowSums(C.est!=0)>0)&(rowSums(C!=0)>0))/sum(rowSums(C!=0)>0)
  
  return(c(mse, specificity, sensitivity))
}

# simulations
numSim <- 30
for (idx in 1:numSim) {
  # generate data
  data <- genData(n,p,q,r,p.0,rho.x,rho.e)
  C <- data$C
  X <- data$X
  Y <- data$Y
  
  ols <- ols.model(C,X,Y,q)
  rrr <- rrr.model(C,X,Y,q,r)
  srrr <- srrr.model(C,X,Y,q,r)
  sofar <- sofar.model(C,X,Y,q,r)
  
  if(idx==1){
    res <- rbind(ols,rrr,srrr,sofar)
  }
  else{
    res <- rbind(res, rbind(ols,rrr,srrr,sofar))
  }
}

# export results
df <- data.frame(
  model=rep(c("MLR", "RRR", "SRRR", "SOFAR"), numSim), 
  MSE=res[,1], 
  SPEC=res[,2],
  SENS=res[,3]
)

setwd("/home/wachi/Desktop/msc/code/results/")
save.path <- paste(n,p,q,r,p.0,rho.x,rho.e,"RothmanChenHuangLowrankHighdimRhostructures.csv", sep="-")
write.csv(df, save.path, row.names = FALSE)

# compute the mean and std of the three metrics; MSE,SP,SE
df.mean <- aggregate(df[,2:4], list(df$model), mean)
df.sd <- aggregate(df[,2:4], list(df$model), sd)
colnames(df.mean) <- c("model", "avgMSE", "avgSPEC", "avgSENS")
save.path <- paste(n,p,q,r,p.0,rho.x,rho.e,"RothmanChenHuangLowrankHighdimRhostructuresMEAN.csv", sep="-")
write.csv(df.mean, save.path, row.names = FALSE)
colnames(df.sd) <- c("model", "sdMSE", "sdSPEC", "sdSENS")
save.path <- paste(n,p,q,r,p.0,rho.x,rho.e,"RothmanChenHuangLowrankHighdimRhostructuresSD.csv", sep="-")
write.csv(df.sd, save.path, row.names = FALSE)
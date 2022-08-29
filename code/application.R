library(Metrics)

setwd("~/Desktop/msc/code")
p = 360
q = 28
r = min(p,q)

rrr.model <- function(C,X,Y,nrank) {
  # build a model
  rrrfit <- rrr.fit(Y, X, nrank = nrank)
  C.est <- rrrfit$coef
  
  # prediction step
  Y_pred <- X_test %*% C.est
  
  # evaluation step
  mse <- mse(Y_test, Y_pred)
  
  return(c(mse))
}

srrr.model <- function(C,X,Y,nrank) {
  # build a model
  srrrfit <- srrr(Y, X, nrank = nrank, ic.type = "AIC")
  C.est <- coef(srrrfit)
  
  # prediction step
  Y_pred <- X_test %*% C.est
  
  # evaluation step
  mse <- mse(Y_test, Y_pred)
  
  return(c(mse))
}

sofar.model <- function(C,X,Y,nrank) {
  # build a model
  sofarfit <- sofar(Y, X, nrank = nrank, ic.type="AIC")
  C.est <- coef(sofarfit)
  
  # prediction step
  Y_pred <- X_test %*% C.est
  
  # evaluation step
  mse <- mse(Y_test, Y_pred)
  
  return(c(mse))
}

res <- c()
for (branch in c("A1","A2","A3","A4","B1","B2","C1","C2","C3","C4")) {
  for (set in c("set_1","set_2","set_3")) {
    x_train <- read.csv(file = paste("..","data",branch,set,"x_train_normalized.csv", sep="/"))
    y_train <- read.csv(file = paste("..","data",branch,set,"y_train_normalized.csv", sep="/"))
    x_test <- read.csv(file = paste("..","data",branch,set,"x_test_normalized.csv", sep="/"))
    y_test <- read.csv(file = paste("..","data",branch,set,"y_test_normalized.csv", sep="/"))
    
    X <- data.matrix(x_train)
    Y <- data.matrix(y_train)
    X_test <- data.matrix(x_test)
    Y_test <- data.matrix(y_test)
    
    rrr <- rrr.model(C,X,Y,r)
    srrr <- srrr.model(C,X,Y,r)
    sofar <- sofar.model(C,X,Y,r)
    res <- rbind(res, c(branch, set, rrr, srrr, sofar))
    
    rm(x_train)
    rm(y_train)
    rm(x_test)
    rm(y_test)
  }
}

for (branch in c("C3","C4")) {
  for (set in c("set_1","set_2","set_3")) {
    x_train <- read.csv(file = paste("..","data",branch,set,"x_train_normalized.csv", sep="/"))
    y_train <- read.csv(file = paste("..","data",branch,set,"y_train_normalized.csv", sep="/"))
    x_test <- read.csv(file = paste("..","data",branch,set,"x_test_normalized.csv", sep="/"))
    y_test <- read.csv(file = paste("..","data",branch,set,"y_test_normalized.csv", sep="/"))
    
    X <- data.matrix(x_train)
    Y <- data.matrix(y_train)
    X_test <- data.matrix(x_test)
    Y_test <- data.matrix(y_test)
    
    rrr <- rrr.model(C,X,Y,r)
    tryCatch({srrr <- srrr.model(C,X,Y,r)}, error = function(e){srrr <- "N/A"})
    tryCatch({sofar <- sofar.model(C,X,Y,r)}, error = function(e){sofar <- "N/A"})
    res <- rbind(res, c(branch, set, rrr, srrr, sofar))
    
    rm(x_train)
    rm(y_train)
    rm(x_test)
    rm(y_test)
  }
}

write.csv(res, "/home/wachi/Desktop/msc/code/results/app.csv", row.names = FALSE)

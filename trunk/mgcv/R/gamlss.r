## (c) Simon N. Wood (2013,2014) distributed under GPL2
## Code for the gamlss families.
## idea is that there are standard functions converting
## derivatives w.r.t. mu to derivatives w.r.t. eta, given 
## given the links and derivatives. 
## Then there are standard routines to take the family 
## specific derivatives and the model matrices, and convert 
## these to the required gradient, hessian, etc...

## Storage convections:
## 1. A single model matrix is stored, along with a single param vector.
##    an index object associates columns with particular gamlss predictors.
## 2. Distribution specific derivatives are stored in d1l-d4l.  

## Need to somehow record block starts... 
## idea is that if n blocks are stored using loops with the 
## given l >= k >= j >= i structure then the block for index
## i,j,k,l starts at i4[i,j,k,l]*n+1, given symmetry over the indices. 

trind.generator <- function(K=2) {
## Generates index arrays for 'upper triangular' storage up to order 4
## Suppose you fill an array using code like...
## m = 0
## for (i in 1:K) for (j in i:K) for (k in j:K) for (l in k:K) {
##   a[,m] <- something; m <- m+1 }
## ... and do this because actually the same 'something' would 
## be stored for any permutation of the indices i,j,k,l.
## Clearly in storage we have the restriction l>=k>=j>=i,
## but for access we want no restriction on the indices.
## i4[i,j,k,l] produces the appropriate m for unrestricted 
## indices. i3 and i2 do the same for 3d and 2d arrays.
  i4 <- array(0,dim=c(K,K,K,K))
  m.start <- 1
  m <- m.start
  for (i in 1:K) for (j in i:K) for (k in j:K) for (l in k:K) {
    i4[i,j,k,l] <- i4[i,j,l,k] <- i4[i,k,l,j] <- i4[i,k,j,l] <- i4[i,l,j,k] <- 
    i4[i,l,k,j] <- 
    i4[j,i,k,l] <- i4[j,i,l,k] <- i4[j,k,l,i] <- i4[j,k,i,l] <- i4[j,l,i,k] <- 
    i4[j,l,k,i] <- 
    i4[k,j,i,l] <- i4[k,j,l,i] <- i4[k,i,l,j] <- i4[k,i,j,l] <- i4[k,l,j,i] <- 
    i4[k,l,i,j] <- 
    i4[l,j,k,i] <- i4[l,j,i,k] <- i4[l,k,i,j] <- i4[l,k,j,i] <- i4[l,i,j,k] <- 
    i4[l,i,k,j] <- m
    m <- m + 1
  }

  i3 <- array(0,dim=c(K,K,K))
  m <- m.start
  for (j in 1:K) for (k in j:K) for (l in k:K) {
    i3[j,k,l] <- i3[j,l,k] <- i3[k,l,j] <- i3[k,j,l] <- i3[l,j,k] <- 
    i3[l,k,j] <- m
    m <- m + 1
  }

  i2 <- array(0,dim=c(K,K))
  m <- m.start
  for (k in 1:K) for (l in k:K) {
    i2[k,l] <- i2[l,k] <- m
    m <- m + 1
  }
  
  list(i2=i2,i3=i3,i4=i4)
} ## trind.generator

gamlss.etamu <- function(l1,l2,l3=NULL,l4=NULL,ig1,g2,g3=NULL,g4=NULL,i2,i3=NULL,i4=NULL,deriv=0) {
## lj is the array of jth order derivatives of l
## gj[,k] contains the jth derivatives for the link of the kth lp
## ig1 is one over first deriv of link
## kth parameter. This routine transforms derivatives 
## w.r.t. the parameters (mu_1..mu_K) to derivatives
## w.r.t. the linear predictors (eta_1.. eta_K)
## i2, i3 and i4 are the upper triangular indexing arrays
## e.g. l4[,i4[i,j,l,m]] contains the partial w.r.t.  
## params indexed by i,j,l,m with no restriction on
## the index values except that they are in 1..K 
  K <- ncol(l1) ## number of parameters of distribution
  d1 <- l1
  for (i in 1:K) { ## first derivative loop
    d1[,i] <- l1[,i]*ig1[,i]
  }

  n <- length(ig1[,1])

  k <- 0
  d2 <- l2
  for (i in 1:K) for (j in i:K) {
    ## obtain the order of differentiation associated 
    ## with the i,j derivatives...
    ord <- rep(1,2);k <- k+1
    if (i==j) {ord[1] <- ord[1] + 1; ord[2] <- 0 }
    ## l2[,k] is derivative to transform
    mo <- max(ord)
    if (mo==2) { ## pure 2nd derivative transform
      d2[,k] <- (l2[,k] - l1[,i]*g2[,i]*ig1[,i])*ig1[,i]^2   
    } else { ## all first derivative
      d2[,k] <- l2[,k]*ig1[,i]*ig1[,j]
    }
  } ## 2nd order transform done


  k <- 0
  d3 <- l3
  if (deriv>0) for (i in 1:K) for (j in i:K) for (l in j:K) {
    ## obtain the order of differentiation associated 
    ## with the i,j,l derivatives...
    ord <- rep(1,3);k <- k+1
    if (i==j) {ord[1] <- ord[1] + 1; ord[2] <- 0 }
    if (i==l) {ord[1] <- ord[1] + 1; ord[3] <- 0 }
    if (ord[2]) {
      if (j==l) {ord[2] <- ord[2] + 1; ord[3] <- 0 }
    }
    ii <- c(i,j,l)
    ## l3[,k] is derivative to transform
    mo <- max(ord)
    if (mo==3) { ## pure 3rd derivative transform
      d3[,k] <- (l3[,k] - 3*l2[,i2[i,i]]*g2[,i]*ig1[,i] +
                l1[,i]*(3*g2[,i]^2*ig1[,i]^2 - g3[,i]*ig1[,i]))*ig1[,i]^3          
    } else if (mo==1) { ## all first derivative
      d3[,k] <- l3[,k]*ig1[,i]*ig1[,j]*ig1[,l]
    } else { ## 2,1 deriv
      k1 <- ii[ord==1] ## index of order 1 deriv
      k2 <- ii[ord==2] ## index of order 2 part
      d3[,k] <- (l3[,k] - l2[,i2[k2,k1]]*g2[,k2]*ig1[,k2])*
                ig1[,k1]*ig1[,k2]^2
    } 
  } ## 3rd order transform done
  
  k <- 0
  d4 <- l4
  if (deriv>2) for (i in 1:K) for (j in i:K) for (l in j:K) for (m in l:K) {
    ## obtain the order of differentiation associated 
    ## with the i,j,l & m derivatives...
    ord <- rep(1,4);k <- k+1
    if (i==j) {ord[1] <- ord[1] + 1; ord[2] <- 0 }
    if (i==l) {ord[1] <- ord[1] + 1; ord[3] <- 0 }
    if (i==m) {ord[1] <- ord[1] + 1; ord[4] <- 0 }
    if (ord[2]) {
      if (j==l) {ord[2] <- ord[2] + 1; ord[3] <- 0 }
      if (j==m) {ord[2] <- ord[2] + 1; ord[4] <- 0 }
    }
    if (ord[3]&&l==m) { ord[3] <- ord[3] + 1; ord[4] <- 0 }
    ii <- c(i,j,l,m)
    ## l4[,k] is derivative to transform
    mo <- max(ord)
    if (mo==4) { ## pure 4th derivative transform
    d4[,k] <-  (l4[,k] - 6*l3[,i3[i,i,i]]*g2[,i]*ig1[,i] + 
        l2[,i2[i,i]]*(15*g2[,i]^2*ig1[,i]^2 - 4*g3[,i]*ig1[,i]) - 
        l1[,i]*(15*g2[,i]^3*ig1[,i]^3 - 10*g2[,i]*g3[,i]*ig1[,i]^2 
         + g4[,i]*ig1[,i]))*ig1[,i]^4    
    } else if (mo==1) { ## all first derivative
      d4[,k] <- l4[,k]*ig1[,i]*ig1[,j]*ig1[,l]*ig1[,m]
    } else if (mo==3) { ## 3,1 deriv
      k1 <- ii[ord==1] ## index of order 1 deriv
      k3 <- ii[ord==3] ## index of order 3 part
      d4[,k] <- (l4[,k] - 3*l3[,i3[k3,k3,k1]]*g2[,k3]*ig1[,k3] +
        l2[,i2[k3,k1]]*(3*g2[,k3]^2*ig1[,k3]^2 - g3[,k3]*ig1[,k3])         
      )*ig1[,k1]*ig1[,k3]^3
    } else { 
      if (sum(ord==2)==2) { ## 2,2
        k2a <- (ii[ord==2])[1];k2b <- (ii[ord==2])[2]
        d4[,k] <- (l4[,k] - l3[,i3[k2a,k2b,k2b]]*g2[,k2a]*ig1[,k2a]
          -l3[,i3[k2a,k2a,k2b]]*g2[,k2b]*ig1[,k2b] + 
           l2[,i2[k2a,k2b]]*g2[,k2a]*g2[,k2b]*ig1[,k2a]*ig1[,k2b]
        )*ig1[,k2a]^2*ig1[,k2b]^2
      } else { ## 2,1,1
        k2 <- ii[ord==2] ## index of order 2 derivative
        k1a <- (ii[ord==1])[1];k1b <- (ii[ord==1])[2]
        d4[,k] <- (l4[,k] - l3[,i3[k2,k1a,k1b]]*g2[,k2]*ig1[,k2] 
                   )*ig1[,k1a]*ig1[,k1b]*ig1[,k2]^2
      }
    }
  } ## 4th order transform done

  list(l1=d1,l2=d2,l3=d3,l4=d4)
} # gamlss.etamu


gamlss.gH <- function(X,jj,l1,l2,i2,l3=0,i3=0,l4=0,i4=0,d1b=0,d2b=0,deriv=0,fh=NULL,D=NULL) {
## X[,jj[[i]]] is the ith model matrix.
## lj contains jth derivatives of the likelihood for each datum,
## columns are w.r.t. different combinations of parameters.
## ij is the symmetric array indexer for the jth order derivs...
## e.g. l4[,i4[i,j,l,m]] contains derivatives with 
## respect to parameters indexed by i,j,l,m
## d1b and d2b are first and second derivatives of beta w.r.t. sps.
## fh is a factorization of the penalized hessian, while D contains the corresponding
##    Diagonal pre-conditioning weights.
## deriv: 0 - just grad and Hess
##        1 - diagonal of first deriv of Hess
##        2 - first deriv of Hess
##        3 - everything.
  K <- length(jj)
  p <- ncol(X);n <- nrow(X)
  trHid2H <- d1H <- d2H <- NULL ## defaults

  ## the gradient...
  lb <- rep(0,p)
  for (i in 1:K) { ## first derivative loop
    lb[jj[[i]]] <- colSums(l1[,i]*X[,jj[[i]],drop=FALSE])
  }
  
  ## the Hessian...
  lbb <- matrix(0,p,p)
  for (i in 1:K) for (j in i:K) {
    lbb[jj[[i]],jj[[j]]] <- t(X[,jj[[i]],drop=FALSE])%*%(l2[,i2[i,j]]*X[,jj[[j]],drop=FALSE])
    lbb[jj[[j]],jj[[i]]] <- t(lbb[jj[[i]],jj[[j]]])
  } 

  if (deriv>0) {
    ## the first derivative of the Hessian, using d1b
    ## the first derivates of the coefficients wrt the sps
    m <- ncol(d1b) ## number of smoothing parameters
    ## stack the derivatives of the various linear predictors on top
    ## of each other...
    d1eta <- matrix(0,n*K,m)
    ind <- 1:n
    for (i in 1:K) { 
      d1eta[ind,] <- X[,jj[[i]],drop=FALSE]%*%d1b[jj[[i]],]
      ind <- ind + n
    }
  }

  if (deriv==1) { 
    d1H <- matrix(0,p,m) ## only store diagonals of d1H
    for (l in 1:m) {
      for (i in 1:K) {
        v <- rep(0,n);ind <- 1:n
        for (q in 1:K) { 
          v <- v + l3[,i3[i,i,q]] * d1eta[ind,l]
          ind <- ind + n
        }
        d1H[jj[[j]],l] <- colSums(X[,jj[[i]],drop=FALSE]*(v*X[,jj[[i]],drop=FALSE]))
      } 
    }
  } ## if deriv==1

  if (deriv>1) {
    d1H <- list()
    for (l in 1:m) {
      d1H[[l]] <- matrix(0,p,p)
      for (i in 1:K) for (j in i:K) {
        v <- rep(0,n);ind <- 1:n
        for (q in 1:K) { 
          v <- v + l3[,i3[i,j,q]] * d1eta[ind,l]
          ind <- ind + n
        }
        ## d1H[[l]][jj[[j]],jj[[i]]] <- 
        d1H[[l]][jj[[i]],jj[[j]]] <- t(X[,jj[[i]],drop=FALSE])%*%(v*X[,jj[[j]],drop=FALSE])
        d1H[[l]][jj[[j]],jj[[i]]] <- t(d1H[[l]][jj[[i]],jj[[j]]])
      } 
    }
  } ## if deriv>1

  if (deriv>2) {
    ## need tr(Hp^{-1} d^2H/drho_k drho_j)
    ## First form the expanded model matrix...
    VX <- Xe <- matrix(0,K*n,ncol(X))
    ind <- 1:n 
    for (i in 1:K) { 
      Xe[ind,jj[[i]]] <- X[,jj[[i]]]
      ind <- ind + n
    }
    ## Now form Hp^{-1} Xe'...
    if (is.list(fh)) { ## then the supplied factor is an eigen-decomposition
       d <- fh$values;d[d>0] <- 1/d[d>0];d[d<=0] <- 0
       Xe <- t(D*((fh$vectors%*%(d*t(fh$vectors)))%*%(D*t(Xe))))
    } else { ## the supplied factor is a choleski factor
       ipiv <- piv <- attr(fh,"pivot");ipiv[piv] <- 1:p
       Xe <- t(D*(backsolve(fh,forwardsolve(t(fh),(D*t(Xe))[piv,]))[ipiv,]))
    }
    ## now compute the required trace terms
    d2eta <- matrix(0,n*K,ncol(d2b))
    ind <- 1:n
    for (i in 1:K) { 
      d2eta[ind,] <- X[,jj[[i]],drop=FALSE]%*%d2b[jj[[i]],]
      ind <- ind + n
    }
    trHid2H <- rep(0,ncol(d2b))
    kk <- 0 ## counter for second derivatives
    for (k in 1:m) for (l in k:m) { ## looping over smoothing parameters...
      kk <- kk + 1
      for (i in 1:K) for (j in 1:K) {
        v <- rep(0,n);ind <- 1:n
        for (q in 1:K) { ## accumulate the diagonal matrix for X_i'diag(v)X_j
          v <- v + d2eta[ind,kk]*l3[,i3[i,j,q]]
          ins <- 1:n
          for (s in 1:K) { 
            v <- v + d1eta[ind,k]*d1eta[ins,l]*l4[,i4[i,j,q,s]]
            ins <- ins + n
          }
          ind <- ind + n
        }
        if (i==j) {
          rind <- 1:n + (i-1)*n
          VX[rind,jj[[i]]] <- v * X[,jj[[i]]]
        } else {
          rind1 <- 1:n + (i-1)*n
          rind2 <- 1:n + (j-1)*n
          VX[rind2,jj[[i]]] <- v * X[,jj[[i]]]
          VX[rind1,jj[[j]]] <- v * X[,jj[[j]]]
        }
      }
      trHid2H[kk] <- sum(Xe*VX)
    }
  } ## if deriv>2

  list(lb=lb,lbb=lbb,d1H=d1H,d2H=d2H,trHid2H=trHid2H)
} ## end of gamlss.gH


gaulss <- function(link=list("identity","logb"),b=0.01) {
## Extended family for Gaussian location scale model...
## so mu is mu1 and tau=1/sig is mu2
## tau = 1/(b + exp(eta)) eta = log(1/tau - b)
## 1. get derivatives wrt mu, tau
## 2. get required link derivatives and tri indices.
## 3. transform derivs to derivs wrt eta (gamlss.etamu).
## 4. get the grad and Hessian etc for the model
##    via a call to gamlss.gH  
## the first derivatives of the log likelihood w.r.t
## the first and second parameters...
  
  ## first deal with links and their derivatives...
  if (length(link)!=2) stop("gaulss requires 2 links specified as character strings")
  okLinks <- list(c("inverse", "log", "identity","sqrt"),"logb")
  stats <- list()
  if (link[[1]] %in% okLinks[[1]]) stats[[1]] <- make.link(link[[1]]) else 
  stop(link[[1]]," link not available for mu parameter of gaulss")
  fam <- structure(list(link=link[[1]],canonical="none",linkfun=stats[[1]]$linkfun,
           mu.eta=stats[[1]]$mu.eta),
           class="family")
  fam <- mgcv:::fix.family.link(fam)
  stats[[1]]$d2link <- fam$d2link
  stats[[1]]$d3link <- fam$d3link
  stats[[1]]$d4link <- fam$d4link
  if (link[[2]] %in% okLinks[[2]]) {
    stats[[2]] <- list()
    stats[[2]]$valideta <- function(eta) TRUE 
    stats[[2]]$link = link[[2]]
    stats[[2]]$linkfun <- eval(parse(text=paste("function(mu) log(1/mu -",b,")")))
    stats[[2]]$linkinv <- eval(parse(text=paste("function(eta) 1/(exp(eta) +",b,")")))
    stats[[2]]$mu.eta <- eval(parse(text=
                         paste("function(eta) { ee <- exp(eta); -ee/(ee +",b,")^2 }")))
    stats[[2]]$d2link <-  eval(parse(text=
    paste("function(mu) { mub <- 1 - mu *",b,";(2*mub-1)/(mub*mu)^2}" )))
    stats[[2]]$d3link <-  eval(parse(text=
    paste("function(mu) { mub <- 1 - mu *",b,";((1-mub)*mub*6-2)/(mub*mu)^3}" )))
    stats[[2]]$d4link <-  eval(parse(text=
    paste("function(mu) { mub <- 1 - mu *",b,";(((24*mub-36)*mub+24)*mub-6)/(mub*mu)^4}")))
  } else stop(link[[2]]," link not available for precision parameter of gaulss")
  
  residuals <- function(object,type=c("deviance","pearson","response")) {
      type <- match.arg(type)
      rsd <- object$y-object$fitted[,1]
      if (type=="response") return(rsd) else
      return((rsd*object$fitted[,2])) ## (y-mu)/sigma 
    }

  ll <- function(y,X,coef,wt,family,deriv=0,d1b=0,d2b=0,Hp=NULL,rank=0,fh=NULL,D=NULL) {
  ## function defining the gamlss Gaussian model log lik. 
  ## N(mu,sigma^2) parameterized in terms of mu and log(sigma)
  ## deriv: 0 - eval
  ##        1 - grad and Hess
  ##        2 - diagonal of first deriv of Hess
  ##        3 - first deriv of Hess
  ##        4 - everything.
    jj <- attr(X,"lpi") ## extract linear predictor index
    eta <- X[,jj[[1]],drop=FALSE]%*%coef[jj[[1]]]
    mu <- family$linfo[[1]]$linkinv(eta)
    eta1 <- X[,jj[[2]],drop=FALSE]%*%coef[jj[[2]]] 
    tau <-  family$linfo[[2]]$linkinv(eta1) ## tau = 1/sig here
    
    n <- length(y)
    l1 <- matrix(0,n,2)
    ymu <- y-mu;ymu2 <- ymu^2;tau2 <- tau^2
 
    l <- sum(-.5 * ymu2 * tau2 - .5 * log(2*pi) + log(tau))

    if (deriv>0) {

      l1[,1] <- tau2*ymu
      l1[,2] <- 1/tau - tau*ymu2  

      ## the second derivatives
    
      l2 <- matrix(0,n,3)
      ## order mm,ms,ss
      l2[,1] <- -tau2
      l2[,2] <- 2*l1[,1]/tau
      l2[,3] <- -ymu2 - 1/tau2

      ## need some link derivatives for derivative transform
      ig1 <- cbind(family$linfo[[1]]$mu.eta(eta),family$linfo[[2]]$mu.eta(eta1))
      g2 <- cbind(family$linfo[[1]]$d2link(mu),family$linfo[[2]]$d2link(tau))
    }
 
    l3 <- l4 <- g3 <- g4 <- 0 ## defaults

    if (deriv>1) {
      ## the third derivatives
      ## order mmm,mms,mss,sss
      l3 <- matrix(0,n,4) 
      ## l3[,1] <- 0
      l3[,2] <- -2*tau
      l3[,3] <- 2*ymu
      l3[,4] <- 2/tau^3 
      g3 <- cbind(family$linfo[[1]]$d3link(mu),family$linfo[[2]]$d3link(tau))
    }

    if (deriv>3) {
      ## the fourth derivatives
      ## order mmmm,mmms,mmss,msss,ssss
      l4 <- matrix(0,n,5) 
      ## l4[,1] <- 0
      ## l4[,2] <- 0
      l4[,3] <- -2
      #l4[,4] <- 0
      l4[,5] <- -6/tau2^2 
      g4 <- cbind(family$linfo[[1]]$d4link(mu),family$linfo[[2]]$d4link(tau))
    }
    if (deriv) {
      i2 <- family$tri$i2; i3 <- family$tri$i3
      i4 <- family$tri$i4
   
      ## transform derivates w.r.t. mu to derivatives w.r.t. eta...
      de <- gamlss.etamu(l1,l2,l3,l4,ig1,g2,g3,g4,i2,i3,i4,deriv-1)

      ## get the gradient and Hessian...
      ret <- gamlss.gH(X,jj,de$l1,de$l2,i2,l3=de$l3,i3=i3,l4=de$l4,i4=i4,
                      d1b=d1b,d2b=d2b,deriv=deriv-1,fh=fh,D=D) 
    } else ret <- list()
    ret$l <- l; ret
  } ## end ll gaulss

  initialize <- expression({
  ## idea is to regress g(y) on model matrix for mean, and then 
  ## to regress the corresponding log absolute residuals on 
  ## the model matrix for log(sigma) - may be called in both
  ## gam.fit5 and initial.spg... note that appropriate E scaling
  ## for full calculation may be inappropriate for initialization 
  ## which is basically penalizing something different here.
  ## best we can do here is to use E only as a regularizer.
      n <- rep(1, nobs)
      ## should E be used unscaled or not?..
      use.unscaled <- if (!is.null(attr(E,"use.unscaled"))) TRUE else FALSE
      if (is.null(start)) {
        jj <- attr(x,"lpi")
        start <- rep(0,ncol(x))
        yt1 <- if (family$link[[1]]=="identity") y else 
               family$linfo[[1]]$linkfun(abs(y)+max(y)*1e-7)
        x1 <- x[,jj[[1]],drop=FALSE]
        e1 <- E[,jj[[1]],drop=FALSE] ## square root of total penalty
        #ne1 <- norm(e1); if (ne1==0) ne1 <- 1
        if (use.unscaled) {
          qrx <- qr(rbind(x1,e1))
          x1 <- rbind(x1,e1)
          startji <- qr.coef(qr(x1),c(yt1,rep(0,nrow(E))))
          startji[!is.finite(startji)] <- 0       
        } else startji <- pen.reg(x1,e1,yt1)
        start[jj[[1]]] <- startji
        lres1 <- -log(abs(y-family$linfo[[1]]$linkinv(x[,jj[[1]],drop=FALSE]%*%start[jj[[1]]])))
        x1 <-  x[,jj[[2]],drop=FALSE];e1 <- E[,jj[[2]],drop=FALSE]
        #ne1 <- norm(e1); if (ne1==0) ne1 <- 1
        if (use.unscaled) {
          x1 <- rbind(x1,e1)
          startji <- qr.coef(qr(x1),c(lres1,rep(0,nrow(E))))   
          startji[!is.finite(startji)] <- 0
        } else startji <- pen.reg(x1,e1,lres1)
        start[jj[[2]]] <- startji
      }
  }) ## initialize gaulss

  structure(list(family="gaulss",ll=ll,link=paste(link),nlp=2,
    tri = trind.generator(2), ## symmetric indices for accessing derivative arrays
    initialize=initialize,residuals=residuals,
    linfo = stats, ## link information list
    d2link=1,d3link=1,d4link=1, ## signals to fix.family.link that all done    
    ls=1 ## signals that ls not needed here
    ),class = c("general.family","extended.family","family"))
} ## end gaulss

pen.reg <- function(x,e,y) {
## get coefficients of penalized regression of y on matrix x
## where e is a square root penalty. Idea is to use e mainly for 
## regularization, so that edf is close to rank of x.  
  if (sum(e==0)) { ## no penalization - easy
    b <- qr.coef(qr(x),y);b[!is.finite(b)] <- 0
    return(b)
  }
  ## need to adjust degree of penalization, so best to QR
  ## the x matrix up front...
  qrx <- qr(x,LAPACK=TRUE)
  R <- qr.R(qrx)
  r <- ncol(R)
  rr <- Rrank(R) ## rank of R/X
  R[,qrx$pivot] <- R ## unpivot
  Qy <- qr.qty(qrx,y)[1:ncol(R)]  
  ## now we want estimates with penalty weight low enough 
  ## EDF is k * rr where k is somewhere in e.g. (.7,.9)
  k <- .01 * norm(R)/norm(E)
  qrr <- qr(rbind(R,E*k));
  edf <- sum(qr.Q(qrr)[1:r,]^2) 
  while (edf > .9*rr) { ## increase penalization
    k <- k*10
    qrr <- qr(rbind(R,E*k));
    edf <- sum(qr.Q(qrr)[1:r,]^2)
  } 
  while (edf<.7*rr) { ## reduce penalization
    k <- k/20
    qrr <- qr(rbind(R,E*k));
    edf <- sum(qr.Q(qrr)[1:r,]^2)
  } 
  b <- qr.coef(qrr,c(Qy,rep(0,nrow(E))));b[!is.finite(b)] <- 0
  b
} ## pen.reg


ziplss <-  function(link=list("log","logit")) {
## Extended family for Zero Inflated Poisson fitted as gamlss 
## type model.
## mu1 is Poisson mean, while mu2 is zero inflation parameter.
  ## first deal with links and their derivatives...
  if (length(link)!=2) stop("ziplss requires 2 links specified as character strings")
  okLinks <- list(c("log", "identity","sqrt"),c("logit","probit"))
  stats <- list()
  param.names <- c("Poisson mean","binary probability")
  for (i in 1:2) {
    if (link[[i]] %in% okLinks[[i]]) stats[[i]] <- make.link(link[[i]]) else 
    stop(link[[i]]," link not available for ",param.names[i]," parameter of ziplss")
    fam <- structure(list(link=link[[i]],canonical="none",linkfun=stats[[i]]$linkfun,
           mu.eta=stats[[i]]$mu.eta),
           class="family")
    fam <- mgcv:::fix.family.link(fam)
    stats[[i]]$d2link <- fam$d2link
    stats[[i]]$d3link <- fam$d3link
    stats[[i]]$d4link <- fam$d4link
  }
  
  residuals <- function(object,type=c("deviance","response")) {
      type <- match.arg(type)
      rsd <- p <- object$fitted[,2];lam <- object$fitted[,1]

      if (type=="response") rsd <- object$y - p*lam
      else {
        ind <- object$y == 0 
        rsd[ind] <- - log(1-p[ind]*(1-exp(-lam[ind])))
        rsd[!ind] <- object$y[!ind]*(log(object$y[!ind])-log(lam[!ind])-1) - log(p[!ind]) + lam[!ind]
        rsd <- sqrt(rsd)
      }
      rsd
  }

  ll <- function(y,X,coef,wt,family,deriv=0,d1b=0,d2b=0,Hp=NULL,rank=0,fh=NULL,D=NULL) {
  ## function defining the gamlss ZIP model log lik. 
  ## Firt l.p. defines Poisson mean, given presence (lambda)
  ## Second l.p. defines probability of presence (p)
  ## deriv: 0 - eval
  ##        1 - grad and Hess
  ##        2 - diagonal of first deriv of Hess
  ##        3 - first deriv of Hess
  ##        4 - everything.
    jj <- attr(X,"lpi") ## extract linear predictor index
    eta <- X[,jj[[1]],drop=FALSE]%*%coef[jj[[1]]]
    lambda <- family$linfo[[1]]$linkinv(eta)
    eta1 <- X[,jj[[2]],drop=FALSE]%*%coef[jj[[2]]] 
    p <-  family$linfo[[2]]$linkinv(eta1) 
    
    n <- length(y)
    l1 <- matrix(0,n,2)
    
    zind <- y == 0 ## the index of the zeroes
    l <- y; enlz <- exp(-lambda[zind])
    l[zind] <- log(1-p[zind]*(1-enlz))    
    l[!zind] <- log(p[!zind]) + y[!zind]*log(lambda[!zind]) - lambda[!zind] - lgamma(y[!zind]+1)

    if (deriv>0) {

      llz <- p[zind]*enlz/(p[zind]*(enlz-1)+1)    ## l_lambda
      l1[zind,1] <- -llz
      l1[!zind,1] <- y[!zind]/lambda[!zind] - 1

      lpz <- l1[zind,2] <- (enlz-1)/(p[zind]*(enlz-1)+1)  ## l_p
      l1[!zind,2] <- 1/p[!zind]

      ## the second derivatives
    
      l2 <- matrix(0,n,3)
      ## order ll, lp, pp... 
 
      l2[zind,1] <- llz*(1-llz)    ## l_ll
      l2[!zind,1] <- -y[!zind]/lambda[!zind]^2
 
      l2[zind,2] <- llz*lpz - llz/p[zind]       ## l_lp

      l2[zind,3] <- -lpz^2         ## l_pp
      l2[!zind,3] <- -1/p[!zind]^2

      ## need some link derivatives for derivative transform
      ig1 <- cbind(family$linfo[[1]]$mu.eta(eta),family$linfo[[2]]$mu.eta(eta1))
      g2 <- cbind(family$linfo[[1]]$d2link(lambda),family$linfo[[2]]$d2link(p))
    }
 
    l3 <- l4 <- g3 <- g4 <- 0 ## defaults

    if (deriv>1) {
      ## the third derivatives
      ## order lll,llp,lpp,ppp
      l3 <- matrix(0,n,4) 
      l3[zind,1] <- -llz + 3*llz^2 - 2*llz^3 ## l_lll
      l3[!zind,1] <- 2*y[!zind]/lambda[!zind]^3

      l3[zind,2] <- (1/p[zind]-lpz)*llz*(1-2*llz)  ## l_llp
      l3[zind,3] <- 2*lpz*llz*(1/p[zind]-lpz)  ## l_ppl
      l3[zind,4] <- 2*lpz^3 ## l_ppp
      l3[!zind,4] <- 2/p[!zind]^3  
 
      g3 <- cbind(family$linfo[[1]]$d3link(lambda),family$linfo[[2]]$d3link(p))
    }

    if (deriv>3) {
      ## the fourth derivatives
      ## order llll,lllp,llpp,lppp,pppp
      l4 <- matrix(0,n,5) 
      l4[zind,1] <- llz - 7*llz^2 + 12*llz^3 -6*llz^4 ## l_llll
      l4[!zind,1] <- -6*y[!zind]/lambda[!zind]^4
      l4[zind,2] <- (1/p[zind] - lpz) * llz * (6*llz*(1-llz)-1) ## l_lllp
      l4[zind,3] <- 2*llz*((llz*(4*lpz-1/p[zind])-lpz)/p[zind]+lpz*llz*(1-3*lpz)) ## l_llpp
      l4[zind,4] <- 6*lpz^2*llz*(lpz-1/p[zind]) ## l_pppl 
      l4[zind,5] <- -6*lpz^4  ## l_pppp  
      l4[!zind,5] <- -6/p[!zind]^4
      g4 <- cbind(family$linfo[[1]]$d4link(lambda),family$linfo[[2]]$d4link(p))
    }
    if (deriv) {
      i2 <- family$tri$i2; i3 <- family$tri$i3
      i4 <- family$tri$i4
   
      ## transform derivates w.r.t. mu to derivatives w.r.t. eta...
      de <- gamlss.etamu(l1,l2,l3,l4,ig1,g2,g3,g4,i2,i3,i4,deriv-1)

      ## get the gradient and Hessian...
      ret <- gamlss.gH(X,jj,de$l1,de$l2,i2,l3=de$l3,i3=i3,l4=de$l4,i4=i4,
                      d1b=d1b,d2b=d2b,deriv=deriv-1,fh=fh,D=D) 
    } else ret <- list()
    ret$l <- sum(l); ret
  } ## end ll for ZIP

  initialize <- expression({ ## for ZIP
  ## idea is to regress binarized y on model matrix for p. 
  ## Then drop any y=0 with p<0.5 and regress g(y) on 
  ## the model matrix for lambda - may be called in both
  ## gam.fit5 and initial.spg... note that appropriate E scaling
  ## for full calculation may be inappropriate for initialization 
  ## which is basically penalizing something different here.
  ## best we can do here is to use E only as a regularizer.
      n <- rep(1, nobs)
      ## should E be used unscaled or not?..
      use.unscaled <- if (!is.null(attr(E,"use.unscaled"))) TRUE else FALSE
      if (is.null(start)) {
        jj <- attr(x,"lpi")
        start <- rep(0,ncol(x))
        x1 <- x[,jj[[2]],drop=FALSE]
        e1 <- E[,jj[[2]],drop=FALSE] ## square root of total penalty
        yt1 <- as.numeric(as.logical(y)) ## binarized response
        if (use.unscaled) {
          qrx <- qr(rbind(x1,e1))
          x1 <- rbind(x1,e1)
          startji <- qr.coef(qr(x1),c(yt1,rep(0,nrow(E))))
          startji[!is.finite(startji)] <- 0       
        } else startji <- pen.reg(x1,e1,yt1)
        start[jj[[2]]] <- startji
        p <- drop(x1[1:nobs,] %*% startji) ## probability of presence
        ind <- y==0 & p < 0.5 ## drop these for estimating lambda
        
        yt1 <- if (family$link[[1]]=="identity") y[!ind] else 
               family$linfo[[1]]$linkfun(abs(y[!ind])+max(y)*1e-7)
       
        x1 <-  x[!ind,jj[[1]],drop=FALSE];e1 <- E[,jj[[1]],drop=FALSE]
        if (use.unscaled) {
          x1 <- rbind(x1,e1)
          startji <- qr.coef(qr(x1),c(yt1,rep(0,nrow(E))))   
          startji[!is.finite(startji)] <- 0
        } else startji <- pen.reg(x1,e1,yt1)
        start[jj[[1]]] <- startji
      }
  }) ## initialize ziplss

  structure(list(family="ziplss",ll=ll,link=paste(link),nlp=2,
    tri = trind.generator(2), ## symmetric indices for accessing derivative arrays
    initialize=initialize,residuals=residuals,
    linfo = stats, ## link information list
    d2link=1,d3link=1,d4link=1, ## signals to fix.family.link that all done    
    ls=1 ## signals that ls not needed here
    ),class = c("general.family","extended.family","family"))
} ## ziplss





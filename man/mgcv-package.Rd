\name{mgcv-package}
\alias{mgcv-package}
\docType{package}
\title{
GAMs with GCV/AIC/REML smoothness estimation and GAMMs by REML/PQL
}
\description{
\code{mgcv} provides functions for generalized additive modelling  and
generalized additive mixed modelling. The term GAM is taken to include 
any GLM estimated by quadratically penalized (possibly quasi-) likelihood maximization.

Particular features of the package are facilities for automatic smoothness selection, 
and the provision of a variety of smooths of more than one variable. User defined 
smooths can be added. A Bayesian approach to confidence/credible interval calculation is
provided. Linear functionals of smooths, penalization of parametric model terms and linkage 
of smoothing parameters are all supported. Lower level routines for generalized ridge 
regression and penalized linearly constrained least squares are also available.
}

\details{ \code{mgcv} provides generalized additive modelling functions \code{\link{gam}},
\code{\link{predict.gam}} and \code{\link{plot.gam}}, which are very similar
in use to the S functions of the same name designed by Trevor Hastie (with some extensions). 
However the underlying representation and estimation of the models is based on a
penalized regression spline approach, with automatic smoothness selection. A
number of other functions  such as \code{\link{summary.gam}} and \code{\link{anova.gam}} 
are also provided, for extracting information from a fitted \code{\link{gamObject}}.

Use of \code{\link{gam}} is much like use of \code{\link{glm}}, except that
within a \code{gam} model formula, isotropic smooths of any number of predictors can be specified using
\code{\link{s}} terms, while scale invariant smooths of any number of
predictors can be specified using \code{\link{te}} terms. \code{\link{smooth.terms}} provides an 
overview of the built in smooth classes. Estimation is by
penalized likelihood or quasi-likelihood maximization, with smoothness
selection by GCV, GACV, gAIC/UBRE or (RE)ML. See \code{\link{gam}}, \code{\link{gam.models}}, 
\code{\link{linear.functional.terms}} and \code{\link{gam.selection}} for some discussion of model specification and
selection. For detailed control of fitting see \code{\link{gam.convergence}},
\code{\link{gam}} arguments \code{method} and \code{optimizer} and \code{\link{gam.control}}. For checking and
visualization see \code{\link{gam.check}}, \code{\link{choose.k}}, \code{\link{vis.gam}} and \code{\link{plot.gam}}.
While a number of types of smoother are built into the package, it is also
extendable with user defined smooths, see \code{\link{smooth.construct}}, for example.

A Bayesian approach to smooth modelling is used to derive standard errors on
predictions, and hence credible intervals. The Bayesian covariance matrix for
the model coefficients is returned in \code{Vp} of the
\code{\link{gamObject}}. See \code{\link{predict.gam}} for examples of how
this can be used to obtain credible regions for any quantity derived from the
fitted model, either directly, or by direct simulation from the posterior
distribution of the model coefficients. Approximate p-values can also be obtained for testing 
individual smooth terms for equality to the zero function, using similar ideas. Frequentist
approximations can be used for hypothesis testing based model comparison. See \code{\link{anova.gam}} and
\code{\link{summary.gam}} for more on hypothesis testing.

The package also provides a generalized additive mixed modelling function,
\code{\link{gamm}}, based on a PQL approach and  
\code{lme} from the \code{nlme} library. \code{gamm} is particularly useful
for modelling correlated data (i.e. where a simple independence model for the
residual variation is inappropriate). In addition, low level routine \code{\link{magic}}
can fit models to data with a known correlation structure.

Some underlying GAM fitting methods are available as low level fitting
functions: see \code{\link{magic}} and \code{\link{mgcv}}. But there is little functionality 
that can not be more conventiently accessed via \code{\link{gam}} . 
Penalized weighted least squares with linear equality and inequality constraints is provided by 
\code{\link{pcls}}.

For a complete list of functions type \code{library(help=mgcv)}.

}
\author{
Simon Wood <simon.wood@r-project.org>

with contributions and/or help from Kurt Hornik, Mike Lonergan, Henric Nilsson
and Brian Ripley. 

Maintainer: Simon Wood <simon.wood@r-project.org>

}
\references{
Wood, S.N. (2004) Stable and efficient multiple smoothing parameter estimation for
generalized additive models. J. Amer. Statist. Ass. 99:673-686. 

Wood, S.N. (2006) \emph{Generalized Additive Models: an introduction with R},
CRC

Wood, S.N. (2008) Fast stable direct fitting and smoothness selection for generalized
additive models. J.R.Statist.Soc.B 70(3):495-518 
}
\keyword{ package }
\keyword{models} 
\keyword{smooth} 
\keyword{regression}


\examples{
## see examples for gam and gamm
}
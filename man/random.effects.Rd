\name{random.effects}
\alias{random.effects}
\title{Random effects in GAMs}
\description{ The smooth components of GAMs can be viewed as random effects for estimation purposes. This means that more conventional 
random effects terms can be incorporated into GAMs in two ways. The first method converts all the smooths into fixed and random components 
suitable for estimation by standard mixed modelling software. Once the GAM is in this form then conventional random effects are easily added,
and the whole model is estimated as a general mixed model. \code{\link{gamm}} and \code{gamm4} from the \code{gamm4} package operate in this way.

The second method represents the conventional random effects in a GAM in the same way that the smooths are represented --- as penalized 
regression terms. This method can be used with \code{\link{gam}} by making use of \code{s(...,"re")} terms in a model: see 
\code{\link{smooth.construct.re.smooth.spec}}. Alternatively, but less straightforwardly, the \code{paraPen} argument to \code{\link{gam}} can be used: 
see \code{\link{gam.models}}. If smoothing parameter estimation is by ML or REML (e.g. \code{gam(...,method="REML")}) then this approach is 
a completely conventional likelihood based treatment of random effects.

\code{gam} can be slow for fitting models with large numbers of random effects, because it does not exploit the sparcity that is often a feature
of parametric random effects. It can not be used for models with more coefficients than data. However \code{gam} is often faster and more relaiable 
than \code{gamm} or \code{gamm4}, when the number of random effects is modest.

To facilitate the use of random effects with \code{gam}, \code{\link{gam.vcomp}} is a utility routine for converting 
smoothing parameters to variance components. It also provides confidence intervals, if smoothness estimation is by ML or REML.

}

\seealso{\code{\link{gam.vcomp}}, \code{\link{gam.models}}, \code{\link{smooth.terms}}, 
\code{\link{smooth.construct.re.smooth.spec}},
\code{\link{gamm}}}

\author{
Simon Wood <simon.wood@r-project.org>
}
\references{
Wood, S.N. (2008) Fast stable direct fitting and smoothness
 selection for generalized additive models. Journal of the Royal
 Statistical Society (B) 70(3):495-518

Wood, S.N. (2006) Low rank scale invariant tensor product smooths for
generalized additive mixed models. Biometrics 62(4):1025-1036

}

\examples{
## see also examples for gam.models, gam.vcomp and gamm

## simple comparison of lme and gam

require(nlme)
b0 <- lme(travel~1,data=Rail,~1|Rail,method="REML") 

b <- gam(travel~s(Rail,bs="re"),data=Rail,method="REML")

intervals(b0)
gam.vcomp(b)


}
\keyword{regression}
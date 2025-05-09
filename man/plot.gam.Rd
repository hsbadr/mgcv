\name{plot.gam}
\alias{plot.gam}
%- Also NEED an `\alias' for EACH other topic documented here.
\title{Default GAM plotting}
\description{ Takes a fitted \code{gam} object produced by \code{gam()} and plots the 
   component smooth functions that make it up, on the scale of the linear
   predictor. Optionally produces term plots for parametric model components
   as well.}
\usage{
\method{plot}{gam}(x,residuals=FALSE,rug=NULL,se=TRUE,pages=0,select=NULL,scale=-1,
         n=100,n2=40,n3=3,theta=30,phi=30,jit=FALSE,xlab=NULL,
         ylab=NULL,main=NULL,ylim=NULL,xlim=NULL,too.far=0.1,
         all.terms=FALSE,shade.col="gray80",shift=0,
         trans=I,seWithMean=FALSE,unconditional=FALSE,by.resids=FALSE,
         scheme=0,...)
}
%- maybe also `usage' for other objects documented here.
\arguments{ 
  
\item{x}{ a fitted \code{gam} object as produced by \code{gam()}.}

\item{residuals}{If \code{TRUE} then partial residuals are added to plots of 1-D smooths. If \code{FALSE} 
then no residuals are added. If this is an array of the correct length then it is used as the array of 
residuals to be used for producing partial residuals. If \code{TRUE} then the
residuals are the working residuals from the IRLS iteration weighted by the (square root)
IRLS weights, in order that they have constant variance if the model is correct. Partial residuals for a smooth term are the
residuals that would be obtained by dropping the term concerned from the model, while leaving all other 
estimates fixed (i.e. the estimates for the term plus the residuals).}

\item{rug}{When \code{TRUE} the covariate to which the plot applies is displayed as a rug plot
 at the foot of each plot of a 1-d smooth, and the locations of the
 covariates are plotted as points on the contour plot representing a 2-d
 smooth. The default of \code{NULL} sets \code{rug} to \code{TRUE} when the dataset size
 is <= 10000 and \code{FALSE} otherwise.} 
  
\item{se}{ when TRUE (default) upper and lower lines are added to the
  1-d plots at 2 standard errors
        above and below the estimate of the smooth being plotted while for
	2-d plots, surfaces at +1 and -1 standard errors are contoured
	and overlayed on the contour plot for the estimate. If a
	positive number is supplied then this number is multiplied by
	the standard errors when calculating standard error curves or
  surfaces. See also \code{shade}, below. }

\item{pages}{ (default 0) the number of pages over which to spread the output. For example, 
if \code{pages=1} then all terms will be plotted on one page with the layout performed automatically. 
Set to 0 to have the routine leave all graphics settings as they are. }

\item{select}{Allows the  plot for a single model term to be selected for printing. e.g. if you just want the plot for the second smooth term set \code{select=2}. }

\item{scale}{ set to -1 (default) to have the same y-axis scale for each plot, and to 0 for a 
          different y axis for each plot. Ignored if \code{ylim} supplied.}

\item{n}{ number of points used for each 1-d plot - for a nice smooth plot this needs to be several times the estimated 
  degrees of freedom for the smooth. Default value 100.}

\item{n2}{Square root of number of points used to grid estimates of 2-d
  functions for contouring.}
\item{n3}{Square root of number of panels to use when displaying 3 or 4 dimensional functions.}

\item{theta}{One of the perspective plot angles.}

\item{phi}{The other perspective plot angle.}

\item{jit}{Set to TRUE if you want rug plots for 1-d terms to be jittered.}

\item{xlab}{If supplied then this will be used as the x label for all plots.}

\item{ylab}{If supplied then this will be used as the y label for all plots.}

\item{main}{Used as title (or z axis label) for plots if supplied.}

\item{ylim}{If supplied then this pair of numbers are used as the y limits for each plot.}

\item{xlim}{If supplied then this pair of numbers are used as the x limits for each plot.}

\item{too.far}{If greater than 0 then this is used to determine when a location is too
far from data to be plotted when plotting 2-D smooths. This is useful since smooths tend to go wild away from data.
The data are scaled into the unit square before deciding what to exclude, and \code{too.far} is a distance 
within the unit square. Setting to zero can make plotting faster for large datasets, but care then needed with 
interpretation of plots.}

\item{all.terms}{if set to \code{TRUE} then the partial effects of parametric
model components are also plotted, via a call to \code{\link{termplot}}. Only
terms of order 1 can be plotted in this way. Also see warnings.}

\item{shade.col}{define the color used for shading confidence bands, for schemes that use this.}

\item{shift}{constant to add to each smooth (on the scale of the linear
predictor) before plotting. Can be useful for some diagnostics, or with \code{trans}.}

\item{trans}{monotonic function to apply to each smooth  (after any shift), before
plotting. Monotonicity is not checked, but default plot limits assume it.
\code{shift} and \code{trans} are occasionally
useful as a means for getting plots on the response scale, when the model consists only
of a single smooth. }

\item{seWithMean}{if \code{TRUE} the component smooths are shown with confidence 
intervals that include the uncertainty about the overall mean. If \code{FALSE} then the 
uncertainty relates purely to the centred smooth itself. If \code{seWithMean=2} then the
intervals include the uncertainty in the mean of the fixed effects (but not in the mean of any uncentred smooths or random effects).  Marra and Wood (2012) suggests 
that \code{TRUE} results in better coverage performance,
and this is also suggested by simulation.}

\item{unconditional}{if \code{TRUE} then the smoothing parameter uncertainty corrected 
covariance matrix is used to compute uncertainty bands, if available. Otherwise the bands
treat the smoothing parameters as fixed.}

\item{by.resids}{Should partial residuals be plotted for terms with \code{by} variables? 
Usually the answer is no, they would be meaningless.}

\item{scheme}{Integer or integer vector selecting a plotting scheme for each plot. See details.}

\item{...}{ other graphics parameters to pass on to plotting commands. See details for smooth plot specific options.}

}
\details{ Produces default plot showing the smooth components of a
  fitted GAM, and optionally parametric terms as well, when these can be
  handled by \code{\link{termplot}}.

For smooth  terms \code{plot.gam} actually calls plot method functions depending on the 
class of the smooth. Currently \code{\link{random.effects}}, Markov random fields (\code{\link{mrf}}), 
\code{\link{Spherical.Spline}}  and  \code{\link{factor.smooth.interaction}} terms have special methods 
(documented in their help files), the rest use the defaults described below. 

For plots of 1-d smooths, the x axis of each plot is labelled 
with the covariate name, while the y axis is labelled \code{s(cov,edf) } where \code{cov}
is the covariate name, and \code{edf} the estimated (or user defined for regression splines) 
degrees of freedom of the smooth. \code{scheme == 0} produces a smooth curve with dashed curves 
indicating 2 standard error bounds. \code{scheme == 1} illustrates the error bounds using a shaded
region.

For \code{scheme==0}, contour plots are produced for 2-d smooths with the x-axes labelled with the first covariate
name and the y axis with the second covariate name. The main title of
the plot is something like \code{s(var1,var2,edf)}, indicating the
variables of which the term is a function, and the estimated degrees of
freedom for the term. When \code{se=TRUE}, estimator variability is shown by overlaying
contour plots at plus and minus 1 s.e. relative to the main
estimate. If \code{se} is a positive number then contour plots are at plus or minus \code{se} multiplied
by the s.e. Contour levels are chosen to try and ensure reasonable
separation of the contours of the different plots, but this is not
always easy to achieve. Note that these plots can not be modified to the same extent as the other plot. 
   
For 2-d smooths \code{scheme==1} produces a perspective plot, while \code{scheme==2} produces a heatmap, 
with overlaid contours and \code{scheme==3} a greyscale heatmap (\code{contour.col} controls the
contour colour).

Smooths of 3 and 4 variables are displayed as tiled heatmaps with overlaid contours. In the 3 variable case the third variable is discretized and a contour plot of the first 2 variables is produced for each discrete value. The panels in the lower and upper rows are labelled with the corresponding third variable value. The lowest value is bottom left, and highest at top right. For 4 variables, two of the variables are coarsely discretized and a square array of image plots is produced for each combination of the discrete values. The first two arguments of the smooth are the ones used for the image/contour plots, unless a tensor product term has 2D marginals, in which case the first 2D marginal is image/contour plotted. \code{n3} controls the number of panels.
See also \code{\link{vis.gam}}. 

Fine control of plots for parametric terms can be obtained by calling
\code{\link{termplot}} directly, taking care to use its \code{terms} argument.

Note that, if \code{seWithMean=TRUE}, the confidence bands include the uncertainty about the overall mean. In other words 
although each smooth is shown centred, the confidence bands are obtained as if every other term in the model was 
constrained to have average 0, (average taken over the covariate values), except for the smooth concerned. This seems to correspond more closely to how most users interpret componentwise intervals in practice, and also results in intervals with
close to nominal (frequentist) coverage probabilities by an extension of Nychka's (1988) results presented in Marra and Wood (2012). There are two possible variants of this approach. In the default variant the extra uncertainty is in the mean of all other terms in the model (fixed and random, including uncentred smooths). Alternatively, if \code{seWithMean=2} then only the uncertainty in parametric fixed effects is included in the extra uncertainty (this latter option actually tends to lead to wider intervals when the model contains random effects).

Several smooth plots methods using \code{\link{image}} will accept an \code{hcolors} argument, which can be anything documented in \code{\link{heat.colors}} (in which case something like \code{hcolors=rainbow(50)} is appropriate), or the \code{\link{grey}} function (in which case somthing like \code{hcolors=grey(0:50/50)} is needed). Another option is \code{contour.col} which will set the contour colour for some plots. These options are useful for producing grey scale pictures instead of colour.

Sometimes you may want a small change to a default plot, and the arguments to \code{plot.gam} just won't let you do it. 
In this case, the quickest option is sometimes to clone the \code{smooth.construct} and \code{Predict.matrix} methods for 
the smooth concerned, modifying only the returned smoother class (e.g. to \code{foo.smooth}). 
Then copy the plot method function for the original class (e.g. \code{mgcv:::plot.mgcv.smooth}), modify the source code to plot exactly as you want and rename the plot method function (e.g. \code{plot.foo.smooth}). You can then use the cloned 
smooth in models (e.g. \code{s(x,bs="foo")}), and it will automatically plot using the modified plotting function. 

}

\value{ The functions main purpose is its side effect of generating plots. It also silently returns 
a list of the data used to produce the plots, which can be used to generate customized plots.
}

\references{

Chambers and Hastie (1993) Statistical Models in S. Chapman & Hall.

Marra, G and S.N. Wood (2012) Coverage Properties of Confidence Intervals for Generalized Additive
Model Components. Scandinavian Journal of Statistics.

Nychka (1988) Bayesian Confidence Intervals for Smoothing Splines. 
Journal of the American Statistical Association 83:1134-1143.

Wood S.N. (2017) Generalized Additive Models: An Introduction with R (2nd edition). Chapman
and Hall/CRC Press.

}
\author{ Simon N. Wood \email{simon.wood@r-project.org}

Henric Nilsson \email{henric.nilsson@statisticon.se} donated the code for the \code{shade} option.

The design is inspired by the S function of the same name described in
Chambers and Hastie (1993) (but is not a clone).

}

\section{WARNING }{ Note that the behaviour of this function is not identical to 
\code{plot.gam()} in S-PLUS.

Plotting can be slow for models fitted to large datasets. Set \code{rug=FALSE} to improve matters. 
If it's still too slow set \code{too.far=0}, but then take care not to overinterpret smooths away from 
supporting data.

Plots of 2-D smooths with standard error contours shown can not easily be customized.

\code{all.terms} uses \code{\link{termplot}} which looks for the original data in the environment of the fitted model object formula. Since \code{gam} resets this environment to avoid large saved model objects containing data in hidden environments, this can fail. 
} 

\seealso{  \code{\link{gam}}, \code{\link{predict.gam}}, \code{\link{vis.gam}}}

\examples{
library(mgcv)
set.seed(0)
## fake some data...
f1 <- function(x) {exp(2 * x)}
f2 <- function(x) { 
  0.2*x^11*(10*(1-x))^6+10*(10*x)^3*(1-x)^10 
}
f3 <- function(x) {x*0}

n<-200
sig2<-4
x0 <- rep(1:4,50)
x1 <- runif(n, 0, 1)
x2 <- runif(n, 0, 1)
x3 <- runif(n, 0, 1)
e <- rnorm(n, 0, sqrt(sig2))
y <- 2*x0 + f1(x1) + f2(x2) + f3(x3) + e
x0 <- factor(x0)

## fit and plot...
b<-gam(y~x0+s(x1)+s(x2)+s(x3))
plot(b,pages=1,residuals=TRUE,all.terms=TRUE,shade=TRUE,shade.col=2)
plot(b,pages=1,seWithMean=TRUE) ## better coverage intervals

## just parametric term alone...
termplot(b,terms="x0",se=TRUE)

## more use of color...
op <- par(mfrow=c(2,2),bg="blue")
x <- 0:1000/1000
for (i in 1:3) {
  plot(b,select=i,rug=FALSE,col="green",
    col.axis="white",col.lab="white",all.terms=TRUE)
  for (j in 1:2) axis(j,col="white",labels=FALSE)
  box(col="white")
  eval(parse(text=paste("fx <- f",i,"(x)",sep="")))
  fx <- fx-mean(fx)
  lines(x,fx,col=2) ## overlay `truth' in red
}
par(op)

## example with 2-d plots, and use of schemes...
b1 <- gam(y~x0+s(x1,x2)+s(x3))
op <- par(mfrow=c(2,2))
plot(b1,all.terms=TRUE)
par(op) 
op <- par(mfrow=c(2,2))
plot(b1,all.terms=TRUE,scheme=1)
par(op)
op <- par(mfrow=c(2,2))
plot(b1,all.terms=TRUE,scheme=c(2,1))
par(op)

## 3 and 4 D smooths can also be plotted
dat <- gamSim(1,n=400)
b1 <- gam(y~te(x0,x1,x2,d=c(1,2),k=c(5,15))+s(x3),data=dat)

## Now plot. Use cex.lab and cex.axis to control axis label size,
## n3 to control number of panels, n2 to control panel grid size,
## scheme=1 to get greyscale...

plot(b1,pages=1) 

}
\keyword{models} \keyword{smooth} \keyword{regression} \keyword{hplot}%-- one or more ...







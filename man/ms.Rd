
\name{ms.nprev}
\alias{ms.nprev}
\title{Logistic regression of two-stage data using second stage sample 
       and first stage sample sizes or proportions (prevalences) as input}
	   

\description{Weighted logistic regression using the Mean Score method \cr

\bold{BACKGROUND}

This algorithm will analyse the second stage data from a two-stage
design, incorporating as appropriate weights the first stage sample
sizes in each of the strata defined by the first-stage variables.
If the first-stage sample sizes are unknown, you can still get
estimates (but not standard errors) using estimated relative 
frequencies (prevalences)of the strata. To ensure that the sample
sizes or prevalences are provided in the correct order, it is 
advisable to first run the \code{\link[meanscore]{coding}} function.
}

\usage{

ms.nprev(x=x,y=y,z=z,n1="option",prev="option",factor=NULL,print.all=FALSE)
}

\arguments{

REQUIRED ARGUMENTS
\item{x}{matrix of predictor variables for regression model} 
\item{y}{response variable (should be binary 0-1)}
\item{z}{matrix of any surrogate or auxiliary variables which must be categorical , \cr 

and one of the following:}
\item{n1}{vector of the first stage sample sizes 
 for each (y,z) stratum: must be provided
 in the correct order (see \code{\link[meanscore]{coding}} function) \cr
OR}

\item{prev}{vector of the first-stage or population
 	  proportions (prevalences) for each (y,z) stratum:
          must be provided in the correct order 
          (see \code{\link[meanscore]{coding}} function) \cr 
	  

OPTIONAL ARGUMENTS}

\item{print.all}{logical value determining all output to be printed. 
		 The default is False (F).} 
\item{factor}{factor variables; if the columns of the matrix of
	  predictor variables have names, supply these names, 
	  otherwise supply the column numbers. MS.NPREV will fit 
	  separate coefficients for each level of the factor variables.}

}

\value{

If called with \code{prev} will return only:

	  A list called "table" containing the following:

\item{ylevel}{the distinct values (or levels) of y}
\item{zlevel}{the distinct values (or levels) of z}
\item{prev}{the prevalences for each \code{(ylevel,zlevel)} stratum}
\item{n2}{the sample sizes at the second stage in each stratum 
	  defined by \code{(ylevel,zlevel)} \cr

	  and a list called "parameters" containing:}

\item{est}{the Mean score estimates of the coefficients in the
	  logistic regression model \cr \cr
	
If called with \code{n1} it will return:

	  a list called "table" containing:}

\item{ylevel}{the distinct values (or levels) of y}
\item{zlevel}{the distinct values (or levels) of z}
\item{n1}{the sample size at the first stage in each \code{(ylevel,zlevel)} stratum}
\item{n2}{the sample sizes at the second stage in each stratum 
	  defined by \code{(ylevel,zlevel)} \cr

	  and a list called "parameters" containing:}

\item{est}{the Mean score estimates of the coefficients in the
	  logistic regression model}	
\item{se}{the standard errors of the Mean Score estimates}
\item{z}{Wald statistic for each coefficient}
\item{pvalue}{2-sided p-value (H0: coeff=0) \cr \cr

If print.all=TRUE, the following lists will also be returned:}

\item{Wzy}{the weight matrix used by the mean score algorithm,
	   for each \code{(ylevel,zlevel)} stratum: this will be in the same order 
	   as n1 and prev} 	
\item{varsi}{the variance of the score in each \code{(ylevel,zlevel)} stratum}
\item{Ihat}{the Fisher information matrix} 
}		   
               
\details{

	The response, predictor and surrogate variables 
	have to be numeric. If you have multiple columns of 
	z, say (z1,z2,..zn), these will be recoded into
      a single vector \code{new.z}

\tabular{rrrr}{
	z1 \tab z2 \tab z3 \tab new.z \cr
	0 \tab 0 \tab 0 \tab 1 \cr
	1 \tab	0 \tab 0 \tab 2 \cr
	0 \tab 1 \tab 0 \tab 3 \cr
	1 \tab 1 \tab 0 \tab 4 \cr
	0 \tab	0 \tab 1 \tab 5 \cr
	1 \tab 0 \tab 1 \tab 6 \cr
	0 \tab	1 \tab 1 \tab 7 \cr
	1 \tab 1 \tab 1 \tab 8 \cr
	}

	If some of the value combinations do not exist 
	in your data, the function will adjust accordingly. 
	For example if the combination (0,1,1) is absent,
	then (1,1,1) will be coded as 7.
}

\examples{

\dontrun{As an illustrative example, we use a simulated data set, simNA.
Use} 

data(simNA)        #to load the data
\dontrun{and}
help(simNA)        #for details


\dontrun{The "complete cases" (i.e. second-stage data) can be extracted by:}

complete_simNA[!is.na(simNA[,3]),]

\dontrun{Running a logistic regression analysis on the complete data:}

summary(glm(complete[,1]~complete[,3], family="binomial"))


\dontrun{gives the following result

Call:
glm(formula = complete[, 1] ~ complete[, 3], family = "binomial")

Coefficients:
              Estimate Std. Error z value Pr(>|z|)    
(Intercept)    0.05258    0.09879   0.532    0.595    
complete[, 3]  1.01942    0.12050   8.460   <2e-16 ***
}

\dontrun{The first and second stage sample sizes can be viewed by running
the "coding" function (see help(coding) for details)
}

coding(x=simNA[,3], y=simNA[,1], z=simNA[,2])
\dontrun{which gives the following:

 [1] "For calls to ms.nprev, input n1 or prev in the following order!!"
     ylevel z new.z  n1  n2
[1,]      0 0     0 310 150
[2,]      0 1     1 166  85
[3,]      1 0     0 177  86
[4,]      1 1     1 347 179
}

\dontrun{An analysis of all first- and second-stage data using Mean Score:}

# supply the first stage sample sizes in the correct order
n1_c(310,166,177,347)
ms.nprev(x=complete[,3],z=complete[,2],y=complete[,1],n1=n1)

\dontrun{gives the results:
[1] "please run coding function to see the order in which you"
[1] "must supply the first-stage sample sizes or prevalences"
[1] " Type ?coding for details!"
[1] "For calls to ms.nprev,input n1 or prev in the following order!!"
     ylevel z new.z  n2
[1,]      0 0     0 150
[2,]      0 1     1  85
[3,]      1 0     0  86
[4,]      1 1     1 179
[1] "Check sample sizes/prevalences"
$table
     ylevel zlevel  n1  n2
[1,]      0      0 310 150
[2,]      0      1 166  85
[3,]      1      0 177  86
[4,]      1      1 347 179

$parameters
                  est         se          z    pvalue
(Intercept) 0.0493998 0.07155138  0.6904103 0.4899362
x           1.0188437 0.10187094 10.0013188 0.0000000
}

\dontrun{If we supply the prevalances instead of first stage sample sizes}
p1_c(310,166,177,347)/1000
ms.nprev(x=complete[,3],z=complete[,2],y=complete[,1],prev=p1)

\dontrun{we get the output:

      ylevel zlevel  prev  n2
[1,]      0      0 0.310 150
[2,]      0      1 0.166  85
[3,]      1      0 0.177  86
[4,]      1      1 0.347 179

$parameters
                   est
(Intercept) 0.04939797
x           1.01885599
}


\dontrun{Note that the Mean Score algorithm produces smaller 
standard errors of estimates than the complete-case
analysis, due to the additional information in the
incomplete cases.}
}

\seealso{
\code{\link[meanscore]{meanscore}},\code{\link[meanscore]{coding}},
\code{\link[meanscore]{ectopic}},\code{\link[meanscore]{simNA}},\code{\link{glm}}.
}

\references{

	Reilly,M and M.S. Pepe. 1995. A mean score method for 
		missing and auxiliary covariate data in 
		regression models. \emph{Biometrika} \bold{82:}299-314
}
	
\keyword{regression}


	

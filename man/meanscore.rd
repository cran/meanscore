\name{meanscore}
\alias{meanscore}
\title{Mean Score Method for Missing Covariate Data in Logistic Regression Models}
\description{
Weighted logistic regression using the Mean Score method}

\usage{
	meanscore(x=x,y=y,z=z,factor=NULL,print.all=FALSE)
}



\arguments{

\item{x}{matrix of predictor variables, one column
	  of which contains some missing values (NA)}
\item{y}{response variable (binary 0-1)}
\item{z}{matrix of the surrogate or auxiliary variables 
          which must be categorical \cr
	  
OPTIONAL ARGUMENTS}

\item{print.all}{logical value determining all output to be printed. 
		 The default is False (F).} 
\item{factor}{factor variables; if the columns of the matrix of
	  predictor variables have names, supply these names, 
	  otherwise supply the column numbers. MS.NPREV will fit 
	  separate coefficients for each level of the factor variables.}
}
\value{

A list called "parameters" containing the following 
	will be returned:

\item{est}{the vector of estimates of the regression coefficients}
\item{se}{the vector of standard errors of the estimates}
\item{z}{Wald statistic for each coefficient}
\item{pvalue}{2-sided p-value (H0: coeff=0) \cr

when print.all = TRUE, it will also return the following lists:}

\item{Ihat}{the Fisher information matrix} 
\item{varsi}{variance of the score for each (ylevel,zlevel) stratum}
}

\details{
	The response, predictor and surrogate variables 
	must be numeric. The function will automatically
	call the CODING function to recode the z matrix 
      to give a \code{new.z} vector which takes a unique value
      for each combination (type help(\code{\link[meanscore]{coding}}) for further
      particulars), as follows:
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

	The values of this new.z are reported as \code{new.z} see 
	\code{\link[meanscore]{coding}}.
}
\examples{
\dontrun{
THE SIMULATED DATASET EXAMPLE}

\dontrun{We use the simulated dataset which is stored in the matrix simNA.
You can load the dataset using:}

data(simNA) 

help (simNA)
#gives a detailed description of the data.
      
\dontrun{To analyze this data using the meanscore function:}

meanscore(y=simNA[,1],z=simNA[,2],x=simNA[,3])

\dontrun{This will give the following:

[1] "For calls to ms.nprev, input n1 or prev in the following order!!"
     ylevel z new.z  n1  n2
[1,]      0 0     0 310 150
[2,]      0 1     1 166  85
[3,]      1 0     0 177  86
[4,]      1 1     1 347 179

$parameters
                  est         se          z    pvalue
(Intercept) 0.0493998 0.07155138  0.6904103 0.4899362
x           1.0188437 0.10187094 10.0013188 0.0000000
}
\dontrun{If you extract the complete cases (n=500) to a matrix called
"complete", using}

complete=simNA[!is.na(simNA[,3]),]

\dontrun{then} 
summary(glm(complete[,1]~complete[,3], family="binomial"))

\dontrun{gives the following results:}

\dontrun{Coefficients:
              Estimate Std. Error z value Pr(>|z|)    
(Intercept)    0.05258    0.09879   0.532    0.595    
complete[, 3]  1.01942    0.12050   8.460   <2e-16 ***
}

\dontrun{
Notice that the Mean Score estimates above had smaller 
standard errors, reflecting the additional information
in the incomplete observations used in the analysis.
Also note that since z is a surrogate for x, it is not 
used in the complete case analysis.
}
 

\dontrun{THE ECTOPIC DATASET EXAMPLE}

\dontrun{This is a real-data example of an application of Mean Score
to a case-control study of the association between ectopic 
pregnancy and sexually transmitted diseases (see Reilly and 
Pepe, 1995). To learn more about the dataset, type help(ectopic). 

The data frame called "ectopic" is in the data subfolder
of the meanscore library. You can load the data by typing:
}
data(ectopic)

\dontrun{The following lines will reproduce the results presented in Table 3 
of Reilly & Pepe (1995)}

# use gonnorhoea, contracept and sexpatr as auxiliary variables
ectopic.z=ectopic[,3:5]

# the auxiliary variables defined above and the chlamydia antibody status 
# are the predictor variables in the logistic regression model		
ectopic.x=ectopic[,2:5]    

meanscore(x=ectopic.x,z=ectopic.z,y=ectopic[,1])

}

\seealso{
\code{\link[meanscore]{ms.nprev}},\code{\link[meanscore]{coding}},
\code{\link[meanscore]{ectopic}},\code{\link[meanscore]{simNA}},\code{\link{glm}}.
}

\references{

Reilly,M and M.S. Pepe. 1995. A mean score method for missing and auxiliary \cr
             covariate data in regression models. \emph{Biometrika} \bold{82:}299-314
}

\keyword{regression}
	

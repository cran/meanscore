
\name{coding}
\alias{coding}
\title{combines two or more surrogate/auxiliary variables into a vector} 


\description{

   recodes a matrix of categorical variables into a vector which takes 
   a unique value for each combination \cr


\bold{BACKGROUND}

From the matrix Z of first-stage covariates, this function creates 
a vector which takes a unique value for each combination as follows:

	\tabular{rrrr}{
	z1 \tab z2 \tab z3 \tab new.z \cr
	0 \tab 0 \tab 0 \tab 1 \cr
	1 \tab 0 \tab 0 \tab 2 \cr
	0 \tab 1 \tab 0 \tab 3 \cr
	1 \tab 1 \tab 0 \tab 4 \cr
	0 \tab 0 \tab 1 \tab 5 \cr
	1 \tab 0 \tab 1 \tab 6 \cr
	0 \tab 1 \tab 1 \tab 7 \cr
	1 \tab 1 \tab 1 \tab 8 \cr
	}

If some of the combinations do not exist, the function will adjust
accordingly: for example if the combination (0,1,1) is absent above,
then (1,1,1) will be coded as 7. \cr

The values of this new.z are reported as \code{new.z} in the printed output 
(see \code{value} below) \cr

This function should be run on second stage data prior to using
the \code{\link[meanscore]{ms.nprev}} function, as it illustrates the order 
in which the call to ms.nprev expects the first-stage sample sizes to be provided.
}


\usage{
coding(x=x,y=y,z=z,return=FALSE)
}

\arguments{
REQUIRED ARGUMENTS

\item{y}{response variable (should be binary 0-1)}
\item{x}{matrix of predictor variables for regression model} 
\item{z}{matrix of any surrogate or auxiliary variables \cr


OPTIONAL ARGUMENTS}

\item{return}{logical value; if it's TRUE(T) the original surrogate
	  or auxiliary variables and the re-coded auxilliary 
	  variables will be returned.   
	  The default is FALSE (F). 
}
}
\value{
This function does not return any values \bold{except} if \code{return}=T. \cr

If used with only second stage (i.e. complete) data, it will print the 
following:
\item{ylevel}{the distinct values (or levels) of y}
\item{\eqn{\bold{z}1 \dots \bold{z}i}}{the distinct values of first stage variables 
\eqn{\bold{z}1 \dots \bold{z}i}}
\item{new.z}{recoded first stage variables. Each value represents a unique combination of 
first stage variable values.}
\item{n2}{second stage sample sizes in each (\code{ylevel},\code{new.z}) stratum. \cr

If used with combined first and second stage data (i.e. with NA for 
missing values), in addition to the above items, the function will also print the following:}

\item{n1}{first-stage sample sizes in each (\code{ylevel},\code{new.z}) stratum.}

}

\examples{

\dontrun{The ectopic data set has 3 categorical first-stage variables in columns 
3 to 5, which together with column 2 are the predictor variables of the
dichotomous outcome in column 1 (see help(ectopic) for further details). Typing
}
data(ectopic)
coding(x=ectopic[,2:5],y=ectopic[,1], z=ectopic[,3:5])

\dontrun{gives the following coding scheme and first-stage and second-stage 
sample sizes (n1 and n2 respectively)
}

\dontrun{
 ylevel gonnorhoea contracept sexpatr new.z  n1 n2
      0          0          0       0     1  56 13
      0          0          1       0     2 146 36
      0          0          0       1     3 119 33
      0          1          0       1     4  19  8
      0          0          1       1     5 344 93
      0          1          1       1     6  31  9
      1          0          0       0     1  26 11
      1          0          1       0     2   9  5
      1          0          0       1     3 160 79
      1          1          0       1     4  29 18
      1          0          1       1     5  35 20
      1          1          1       1     6   5  2
}
}

\seealso{
\code{\link[meanscore]{meanscore}},\code{\link[meanscore]{ms.nprev}},
\code{\link[meanscore]{ectopic}},\code{\link[meanscore]{simNA}},\code{\link{glm}}.
}

\keyword{utilities}

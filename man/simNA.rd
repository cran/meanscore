\name{simNA}
\alias{simNA}
\title{Simulated dataset for illustrating the meanscore function}


\description{

For this dataset, we generated 1000 observations of the 
predictor variable (X) from the standard normal distribution.
The response variable(Y) was then generated as a Bernoulli
random variable with \bold{p=exp(x)/(1+exp(x))}

A dichotomous surrogate variable for X, called Z, was 
generated as follows: 

	\eqn{Z=1, X >0} \cr
	\eqn{  0, otherwise}

We randomly deleted 500 of the X values (replacing them with NA),
and stored the data in the matrix simNA, described below.
}

\usage{data(simNA)}

\format{

There are 3 columns in the dataset. \cr

Column 1 is the response variable (Y), \cr

Column 2 is the surrogate variable (Z) \cr

Column 3 is the predictor variable (X) \cr

}

\keyword{datasets}

\name{ectopic}
\alias{ectopic}
\title{The Ectopic Pregnancy Dataset}

\description{

This dataset, which was analysed in Table 3 of Reilly and
Pepe (1995) is from a case-control study of the association
between ectopic pregnancy and sexually transmitted diseases(STDs). 
The total sample size is 979, 264 cases and 715 controls.
The  variables collected from the beginning of
the study included gonnorhoea, contraceptive use and sexual
partners (see \bold{Format}).

One year after the study began, the investigators started
collecting serum samples for determining chlamydia antibody
status in all cases and in a 50 percent subsample of controls. 
As a result, only 327 out of the 979 patients have measurements 
for chlamydia antibody.
}

\usage{
data(ectopic)
}

\format{

The dataset has 979 observations with 5 variables arranged in the
following columns: \cr

Column 1 (Pregnancy) \cr
The ectopic pregnancy status of patients at the time of interview \cr
(0 = No, 1 = Yes) \cr

Column 2 (Chlamydia) \cr
The chlamydia antibody status of patients (0 = No, 1 = Yes). \cr
There are some observations with missing values, indicating that
at the time these patients were enrolled, the investigators
had not yet started to record chlamydia antibody status.

Column 3 (Gonnorhoea) \cr
(0 = No, 1 = Yes) \cr

Column 4 (Contracept) \cr
The use of contraceptives \cr 
(0 = No, 1 = Yes) \cr

Column 5 (Sexpatr) \cr
Multiple sex partners (0 = No, 1 = Yes) \cr
}

\source{
Sherman,\emph{et.al.}(1990)
}

\references{
	Reilly,M and M.S. Pepe. 1995. A mean score method for 
		missing and auxiliary covariate data in 
		regression models. \emph{Biometrika} \bold{82}:299-314 \cr
	Sherman, K.J., \emph{et.al.} .1990. Sexually transmitted diseases
		and tubal pregnancy. \emph{Sex. Transm.Dis.} \bold{7}: 115-21
}

\keyword{datasets}



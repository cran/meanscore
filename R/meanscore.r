# This file contains 3 functions used for implementing the Mean Score method to
# estimate the coefficients in a logistic regression model from two-stage data.
#   1. MEANSCORE is called with the combined first- and second-stage data
#      (where the missing covariate values are represented by NA)
#   2. MS.NPREV is called with the second-stage (i.e. complete) data 
#      and the first-stage sample sizes (or prevalences). Prior to running
#      this function, the CODING function (3.) should be run to see the
#      order in which MS.NPREV expects the first-stage sample sizes
#      or prevalences to be provided.
#   3. CODING, which recodes multiple columns of Z into a single column of
#      "Z levels" and displays the coding scheme
#


# @@@@@@@@@@@@@@@@@@@@@@@   MEANSCORE    @@@@@@@@@@@@@@@@@@@@@@@@@

meanscore=function(x="matrix of covariates",y=y,z=z,factor=NULL,print.all=FALSE)
{	

	stop1=c("ARE NOT FOUND PLEASE CHECK COL NAMES OR ENTER COL NUMBER IN THE PREDICTOR MATRIX")
	code=coding(x=x,y=y,z=z,return=TRUE)
      z=code$z
        
	data<-data.frame(y,z,x)
	n1<-c(t(table(y,z)))
	Cdata<-na.omit(data)
	n2<-c(t(table(Cdata[,1],Cdata[,2])))
	
	N1<-sum(n1)
	N2<-sum(n2)

	y<-Cdata[,1]
	z<-Cdata[,2]
	rdata<-Cdata[,c(1,3:ncol(Cdata))]

	ylev<-as.numeric(levels(factor(y)))
	zlev<-as.numeric(levels(factor(z)))
	ylevel<-rep(ylev,rep(length(zlev),length(ylev)))
	zlevel<-rep(zlev,length(ylev))
        n2<-c(t(table(y,z)))

	if(min(n2)<2) {
		stop("WARNING: One or more strata with less than 2 obs!")  
	}

	w.MS <<- rep(1, length(y))
	wt<-n1/n2
	for(i in 1:length(wt)) {
		w.MS<<- ifelse(y == ylevel[i] & z == zlevel[i], wt[i], w.MS)
	}
 	

	# recode the factor variables
	if (length(factor) > 0) {
		
		if(is.character(factor)) {
		   for (i in 1:length(factor)) {
			ind=ifelse(colnames(rdata)==factor[i],1,0)
			if (sum(ind)==0) {
			 stop(paste(factor[i],stop1),call.=FALSE)
			 	}	
			varpost=order(ind)[ncol(rdata)]
			ff=factor(rdata[,varpost])
			factlev=levels(ff)
			dummy=as.data.frame(model.matrix(~ ff - 1)[,-1])
			colnames(dummy)=paste(colnames(rdata)[varpost], factlev[-1], sep = "")
			rdata=rdata[,-varpost]
			rdata=cbind(rdata,dummy)
			
			}
		    }

		else if (is.numeric(factor)){
		  varpost=factor+1
		  ind=ifelse(varpost>ncol(rdata),1,0)
		  if (sum(ind)>0) {
			stop("COLUMN NUMBER OF FACTOR VARIABLES IS OUT OF BOUND,PLEASE CHECK!")			  	}
		
		  for (i in 1:length(factor)) {
			ff=factor(rdata[,varpost[i]])
			factlev=levels(ff)
			dummy=as.data.frame(model.matrix(~ ff - 1)[,-1])
			colnames(dummy)=paste(colnames(rdata)[varpost[i]], factlev[-1], sep = "")
			rdata=rdata[,-varpost[i]]
			rdata=cbind(rdata,dummy)
			
			}
		    }

		}

	glm.MS <- glm(y ~ ., family = "binomial", weights = w.MS, data = rdata)	

	X <- cbind(1, rdata[,-1])
	pi.hat <- glm.MS$fitted.values
	Ihat <- (as.matrix(t(X)) %*% (as.matrix(X) * w.MS * pi.hat * (1 - pi.hat)))/N1

	wgt<-n1/n2*(n1-n2)
	S <- as.matrix(X) * (y - pi.hat)	

	varsi<-array(0,dim=c(nrow(Ihat),nrow(Ihat),length(wgt)))
	result <- 0
	for(i in 1:length(wgt)) {
		si <- S[y == ylevel[i] & z == zlevel[i],  ]
		if (!is.null(nrow(si))){
		varsi[,,i] <- var(si)
		result <- result + var(si) * wgt[i]}
		else {
		varsi[,,i] <- matrix(NA,nrow(Ihat),ncol(Ihat))
		result <- result + matrix(NA,nrow(Ihat),ncol(Ihat))}
	}

	Vhat <- result/N1	
	invI <- solve(Ihat)
	V <- (invI + invI %*% Vhat %*% invI)/N1
	

	z.value <- glm.MS$coef/sqrt(diag(V))
	p.value <- 2*(1-pnorm(abs(z.value)))

	if (print.all) 
		list(parameters=cbind(est=glm.MS$coef,se=sqrt(diag(V)),
		z=z.value,pvalue=p.value),Ihat=Ihat,varsi=varsi)

	else 
        list(parameters=cbind(est=glm.MS$coef,se=sqrt(diag(V)),z=z.value,pvalue=p.value))
	
}







#   @@@@@@@@@@@@@@@@@@@@@@@@@   MS.NPREV  FUNCTION  @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
#
"ms.nprev"=function(x="matrix of covariates",y=y,z=z,n1="option",prev="option",factor=NULL,print.all=FALSE)
{
# this function uses the second-stage (i.e. complete ) data and the first-stage
# sample sizes (or prevalences) to compute Mean Score estimates of the coefficients
# in a logistic regression model. The function requires the following input:
#
# x= the matrix of predictor variables in the regression model
#    defined as a data.frame (before calling the function)
#
# y= the outcome variable vector
#
# z= the surrogate variable vectors, defined as data.frame
#
# n1 OR prev where
#              n1=  the vector of first-stage sample sizes
#                   in the Y,Z strata in the same order as
#                   given by the table(y,z) command i.e.sorted by Y and Z(within Y)
#             prev= prevalence of the Y,Z strata in the same
#                   order as specified for n1
#
#
# The function called with "prev" returns only:
#          ylevel=  the distinct values (or levels) of y
#          zlevel=  the distinct values (or levels) of z
#              n2=  the sample sizes at the second stage at each stratum 
#                   defined by (ylevel,zlevel)
#             est=  the mean score estimates
#  and if called with n1 also returns:
#              se=  the standard errors of the MS estimates
#             Wzy=  the Wzy matrix  for each Y,Z stratum
#		    in the same order as n1 and prev 	
#           varsi=  the variance of score in each Y,Z stratum
#            Ihat=  the estimated information matrix
#              n2=  the second-stage sample sizes in each (Z,Y) stratum
#
#
print("please run coding function to see the order in which you")
print("must supply the first-stage sample sizes or prevalences")
print (" Type ?coding for details!")

stop1=c("ARE NOT FOUND PLEASE CHECK COL NAMES OR ENTER COL NUMBER IN THE PREDICTOR MATRIX")         
	z1=data.frame(z)
        z.old=as.matrix(z) 

        z=coding(x=x,y=y,z=z,return=TRUE)$z
  
        ylev<-as.numeric(levels(factor(y)))
	zlev<-as.numeric(levels(factor(z)))
	ylevel<-rep(ylev,rep(length(zlev),length(ylev)))
	zlevel<-rep(zlev,length(ylev))
        n2<-c(t(table(y,z)))

	if(min(n2)<2) {
		stop("WARNING: One or more strata with less than 2 obs!")  
	}

	w.MS <<- rep(1, length(y))
		
if (prev[1]!="option")
   {
	print("Check sample sizes/prevalences")
	#print(cbind(ylevel=ylevel,zlevel=zlevel,prev=prev,n2=n2))
	wt<-prev/n2
	for(i in 1:length(wt)) {
	w.MS<<- ifelse(y == ylevel[i] & z == zlevel[i], wt[i], w.MS)
				}
	rdata<-data.frame(y,x)

	# recode the factor variables
	if (length(factor) > 0) {
		
		if(is.character(factor)) {
		   for (i in 1:length(factor)) {
			ind=ifelse(colnames(rdata)==factor[i],1,0)
			if (sum(ind)==0) {
			 stop(paste(factor[i],stop1),call.=FALSE)
			 	}	
			varpost=order(ind)[ncol(rdata)]
			ff=factor(rdata[,varpost])
			factlev=levels(ff)
			dummy=as.data.frame(model.matrix(~ ff - 1)[,-1])
			colnames(dummy)=paste(colnames(rdata)[varpost], factlev[-1], sep = "")
			rdata=rdata[,-varpost]
			rdata=cbind(rdata,dummy)
			
			}
		    }

		else if (is.numeric(factor)){
		  varpost=factor+1
		  ind=ifelse(varpost>ncol(rdata),1,0)
		  if (sum(ind)>0) {
			stop("COLUMN NUMBER OF FACTOR VARIABLES IS OUT OF BOUND,PLEASE CHECK!")			  	}
		
		  for (i in 1:length(factor)) {
			ff=factor(rdata[,varpost[i]])
			factlev=levels(ff)
			dummy=as.data.frame(model.matrix(~ ff - 1)[,-1])
			colnames(dummy)=paste(colnames(rdata)[varpost[i]], factlev[-1], sep = "")
			rdata=rdata[,-varpost[i]]
			rdata=cbind(rdata,dummy)
			
			}
		    }

		}

	glm.MS <- glm(y ~ ., family = "binomial",weight=w.MS, data = rdata)			
	
	X <- cbind(1, rdata[,-1])
	pi.hat <- glm.MS$fitted.values
	Ihat <- (t(as.matrix(X)) %*% (as.matrix(X) * w.MS * pi.hat * (1 - pi.hat)))
	S <- X * (y - pi.hat)
	
	invI <- solve(Ihat)
	varsi<-ar<-array(0,dim=c(nrow(Ihat),nrow(Ihat),length(wt)))
	for(i in 1:length(wt)) {
		si <- S[y == ylevel[i] & z == zlevel[i],  ]
		varsi[,,i]<-var(si)
		ar[,,i]<-invI%*%varsi[,,i]%*%invI
		}

	if (print.all)
	list(table=cbind(ylevel=ylevel, zlevel=zlevel, prev=prev, n2=n2),
             parameters=cbind(est=glm.MS$coef),Wzy=ar,Ihat=Ihat,varsi=varsi)
	else list(table=cbind(ylevel=ylevel, zlevel=zlevel,prev=prev,n2=n2),                                  parameters=cbind(est=glm.MS$coef))

    }
		

else 
   { 
	print("Check sample sizes/prevalences")
	#print(cbind(ylevel,zlevel,n1,n2))
	N1<-sum(n1)
	prev<-n1/N1
	rdata<-data.frame(y,x)

	wt<-n1/n2
	for(i in 1:length(wt)) {
		w.MS<<- ifelse(y == ylevel[i] & z == zlevel[i], wt[i], w.MS)
				}


	# recode the factor variables
	if (length(factor) > 0) {
		
		if(is.character(factor)) {
		   for (i in 1:length(factor)) {
			ind=ifelse(colnames(rdata)==factor[i],1,0)
			if (sum(ind)==0) {
			 stop(paste(factor[i],stop1),call.=FALSE)
			 	}	
			varpost=order(ind)[ncol(rdata)]
			ff=factor(rdata[,varpost])
			factlev=levels(ff)
			dummy=as.data.frame(model.matrix(~ ff - 1)[,-1])
			colnames(dummy)=paste(colnames(rdata)[varpost], factlev[-1], sep = "")
			rdata=rdata[,-varpost]
			rdata=cbind(rdata,dummy)
			
			}
		    }

		else if (is.numeric(factor)){
		  varpost=factor+1
		  ind=ifelse(varpost>ncol(rdata),1,0)
		  if (sum(ind)>0) {
			stop("COLUMN NUMBER OF FACTOR VARIABLES IS OUT OF BOUND,PLEASE CHECK!")			  	}
		
		  for (i in 1:length(factor)) {
			ff=factor(rdata[,varpost[i]])
			factlev=levels(ff)
			dummy=as.data.frame(model.matrix(~ ff - 1)[,-1])
			colnames(dummy)=paste(colnames(rdata)[varpost[i]], factlev[-1], sep = "")
			rdata=rdata[,-varpost[i]]
			rdata=cbind(rdata,dummy)
			
			}
		    }

		}
 	
	glm.MS <- glm(y ~ ., family = "binomial", weights = w.MS, data = rdata)	

	X <- cbind(1, rdata[,-1])
	pi.hat <- glm.MS$fitted.values
	Ihat <- (t(as.matrix(X)) %*% (as.matrix(X) * w.MS * pi.hat * (1 - pi.hat)))/N1
	wgt<-n1/n2*(n1-n2)
	S <- X * (y - pi.hat)
	
	invI <- solve(Ihat)
	result <- 0
	varsi<-ar<-array(0,dim=c(nrow(Ihat),nrow(Ihat),length(wgt)))
	for(i in 1:length(wgt)) {
		si <- S[y == ylevel[i] & z == zlevel[i],  ]
		varsi[,,i]<-var(si)
		ar[,,i]<-invI%*%varsi[,,i]%*%invI
		result <- result + var(si) * wgt[i]
		}
	
	Vhat <- result/N1	
	
	V <- (invI + invI %*% Vhat %*% invI)/N1
	
	z.value <- glm.MS$coef/sqrt(diag(V))
	p.value <- 2*(1-pnorm(abs(z.value)))

	if (print.all)
	list(table=cbind(ylevel=ylevel, zlevel=zlevel, n1=n1, n2=n2),
        parameters=cbind(est=glm.MS$coef,se=sqrt(diag(V)),z=z.value,pvalue=p.value),
			Wzy=ar,Ihat=Ihat,varsi=varsi)
	else list(table=cbind(ylevel=ylevel, zlevel=zlevel,n1=n1,n2=n2),                                      parameters=cbind(est=glm.MS$coef,se=sqrt(diag(V)),z=z.value,pvalue=p.value))
  }

# close function call
}







# @@@@@@@@@@@@@@@@@@@@@@@     CODING FUNCTION @@@@@@@@@@@@@@@@@@@@@@@@@@@@

coding=function(x=x,y=y,z=z,return=FALSE)
### This function is used to combine multiple columns of z into one column
### If used with combined first and second stage data (i.e. with NA for missing
### values), it will return sample sizes for the first and second stage 
### for each (Y,Z) stratum. If used with only second stage (i.e. complete) data
### it will return the second stage sample sizes in each (Y,Z) stratum.
### This function should be run on second stage data prior to using
### the ms.nprev function, as it illustrates the order in which the call
### to ms.nprev expects the first-stage sample sizes to be provided.
{

z1=data.frame(z)

#	for (i in 1:ncol(z1)) {
#		if(!is.numeric(z1[,i])) {
#			z1[,i]=codes(factor(z1[,i]))
#		}
#	}

z.old=as.matrix(z)

  if (ncol(z1)>1){
  ncz<-ncol(z1)
  nrz<-nrow(z1)
  zlst<-leve<-NULL
  for (i in 1:ncz){
      zlst<-c(zlst,list(z1[,i]))
      leve<-c(leve,length(levels(as.factor(z1[,i]))))
      zlst[[i]]<-as.factor(zlst[[i]])
      levels(zlst[[i]])<-c(1:leve[i])
      }
      z1<-matrix(unlist(zlst),nrz,ncz)
        
	m<-max(leve)
	m1<-m^c(1:ncz)
	nz<-z1%*%m1	
	nz<-as.factor(nz)
	nlev<-length(as.numeric(levels(nz)))
	levels(nz)<-c(1:nlev)
	list(nz=as.numeric(nz),z=z1)
        z=as.numeric(nz)}
        levels(z)=1:length(levels(as.factor(z))) 
        
########  now prepare levels of new Z for printing        
        id=1:length(z)
        index=NULL
        nlev=length(levels(as.factor(z))) 
       
        for (i in 1:nlev){ 
            if (ncol(z1)>1){
            id1=id[z==levels(z)[i]]
            id1=sample(id1,1)
            index=c(index,id1)}
            
            else {
            id1=id[z==levels(as.factor(z))[i]]
            id1=sample(id1,1)
            index=c(index,id1)}
        }

        data<-data.frame(y,z,x)
	n1<-c(t(table(y,z)))
	Cdata<-na.omit(data)
	n2<-c(t(table(Cdata[,1],Cdata[,2])))

        ylev<-as.numeric(levels(factor(y)))
	zlev<-as.numeric(levels(factor(z)))
	ylevel<-rep(ylev,rep(length(zlev),length(ylev)))
	zlevel<-rep(zlev,length(ylev))
        index=rep(index,length(ylev))         

### now label the columns of z for printing

        if (is.null(colnames(z.old)))
        colnames(z.old)=paste("z",1:ncol(z.old),sep="") 

        if (ncol(z1)>1){
           if (sum(n1==n2)<length(n1)){ 
           print("For calls to ms.nprev, input n1 or prev in the following order!!")
           print(cbind(ylevel=ylevel,z.old[index,],new.z=zlevel,n1=n1,n2=n2))}
              else{
              print("If using ms.nprev you should input n1 or prev in this (ylevel,new z) order!!")
              print(cbind(ylevel=ylevel,z.old[index,],new.z=zlevel,n2=n2))}
           }
        else{ 
           if (sum(n1==n2)<length(n1)){
           print("For calls to ms.nprev, input n1 or prev in the following order!!")
           print(cbind(ylevel=ylevel,z=z.old[index],new.z=zlevel,n1=n1,n2=n2))}
              else{
              print("For calls to ms.nprev,input n1 or prev in the following order!!")
              print(cbind(ylevel=ylevel,z=z.old[index],new.z=zlevel,n2=n2))}
            }
######## end of code for printing original and recoded Z

if (return)
return(z=z,z.old=z.old)
}







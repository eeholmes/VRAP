#' @title Main
#' @description Runs VRAP. This function is largely specific to the R version of VRAP.
#' @param InFile The name of the .rav file
#' @param OutFileBase The basename for the .sum, .byr, and .esc output files
#' @param NRuns Number of runs to use in the simulations if the user wants to use something different than what is in the .rav file
#' @param NYears Number of years to project forward in the simulations if the user wants to use something different than what is in the .rav file
#' @param Title Title to use for the report if the user wants to use something different than what is in the .rav file
#' @param TargetStart Target ER to start simulations at if the user wants to use something different than what is in the .rav file
#' @param TargetEnd Target ER to end simulations at if the user wants to use something different than what is in the .rav file
#' @param TargetStep Target ER step sizes if the user wants to use something different than what is in the .rav file
#' @param ERecovery Recovery target if the user wants to use something different than what is in the .rav file
#' @param QET if the user wants to use something different than what is in the .rav file
#' @param ECrit if the user wants to use something different than what is in the .rav file
#' @param NewRavFileName A new .rav file is saved in case the user has changed any values from what is in the .rav file.
#' @param forceNewRav Force use of new rav file.  Needed for shiny app.
#' @param silent Whether to show progress bar.
#' @param lcores Number of cores to use.  Default is non-parallel so lcores=1
#' @param parallel.backend doParallel or doSNOW.  The latter allows the progress bar to appear.
#' @param save.output.as.files  If TRUE (default), then .sum, .byr, .esc and .rav files are saved using OutFileBase.  If FALSE, no files are saved and only the list is output.
#' @return list with output list from RunSims() and output time
Main = function(InFile=NULL, OutFileBase=NULL, 
                NRuns=-1, NYears=-1, Title=-1,
                TargetStart=-1, TargetEnd=-1, TargetStep=-1,
                ERecovery=-1, QET=-1, ECrit=-1, NewRavFileName="tmprav.rav",
                forceNewRav=NULL, silent=FALSE, lcores=1, parallel.backend="doParallel",
                save.output.as.files=TRUE){

  ## if not called with input file, then user is prompted to input one
  if(is.null(InFile)) InFile = file.choose()
  if(!file.exists(InFile)) stop("Specified input file does not exist.")
  if(is.null(OutFileBase)){
    tmp=strsplit(InFile,"\\\\")[[1]]
    InFileBase=tmp[length(tmp)]
    tmp=strsplit(InFileBase,"/")[[1]]
    InFileBase=tmp[length(tmp)]   
    if(str_detect(InFileBase,"[.]")){
      OutFileBase=strsplit(InFileBase,"[.]")[[1]][1]; 
    }else{
      OutFileBase=InFileBase;
    }
  }
  if(!parallel.backend %in% c("doParallel","doSNOW")) stop("parallel.backend must be doParallel or doSNOW (in quotes)")
  
  
  ## Two lists will be passed in and out of functions
  ##    inputs = list() ## is everything from the .rav file
  ##    staticvars = list() ## is anything computed from that; static
  
  ## 'READ INPUT DATA AND CALCULATE AEQs
  ## 'direct from .rav file or simple calculation from rav file inputs
  inputs=GetInput(InFile)
  
  # Check if any inputs will be changed
  newrav=FALSE
  if(NRuns>0){ inputs$NRuns=NRuns; newrav=TRUE }#NRuns passed in
  if(NYears>0){ inputs$NYears=NYears; newrav=TRUE } #NYears passed in
  if(Title != -1){ inputs$Title=NYears; newrav=TRUE } #NYears passed in
  if(TargetStart>0){ inputs$BufferStart=TargetStart/inputs$TargetU; newrav=TRUE }
  if(TargetEnd>0){ inputs$BufferEnd=TargetEnd/inputs$TargetU; newrav=TRUE }
  if(TargetStep>0){ inputs$BufferStep=TargetStep/inputs$TargetU; newrav=TRUE }
  if(QET>0){ inputs$DL2=QET; newrav=TRUE }
  if(ERecovery>0){ inputs$ERecovery=ERecovery; newrav=TRUE }
  if(ECrit>0){ inputs$ECrit=ECrit; newrav=TRUE }

  ## override newrav if desired
  if(!save.output.as.files) newrav <- FALSE
  newrav <- if(!is.null(forceNewRav) && !is.na(forceNewRav) &&
                 is.logical(forceNewRav)) {forceNewRav} else {newrav}
  
  #This was computed in GetInput(); need to recompute
  inputs$BufMax = round((inputs$BufferEnd - inputs$BufferStart) / inputs$BufferStep + 1)
  #Howard: I doubt this is ok for unix; needed a dir to save the new rav file
  if(newrav){
     WriteRavFile(inputs, paste(dirname(InFile),"/",NewRavFileName,sep=""))
  }
  
  ## add the output file names to the inputs
  inputs = SetOutFileNames(OutFileBase, inputs)
  
  c1 = makeCluster(lcores, outfile = NULL)
  if(parallel.backend=="doParallel") registerDoParallel(c1)
  if(parallel.backend=="doSNOW") registerDoSNOW(c1)
  
  out=RunSims(inputs, silent, parallel.backend=parallel.backend)
  
  stopCluster(c1)

  outtm <- proc.time()
  
  
  ## 'SAVE SUMMARY RESULTS .sum
  if(!silent) cat("Saving summary...\n")
  if(save.output.as.files) SaveSummary(out$inputs, out$SummaryStats, out$staticvars)

  ## 'SAVE ESCAPEMENT DATA .esc
  if(!silent) cat("Saving escapement data...\n")
  if(save.output.as.files) SaveEscpmntData(out$inputs, out$SummaryStats)
  
  ## 'SAVE BROOD YEAR EXPLOITATION RATE DATA .byr
  if(!silent) cat("Saving BYr year data...\n")
  if(save.output.as.files) SaveBYrData(out$inputs, out$SummaryStats)
  
  outtm <- proc.time() - outtm
  
  
  return(c(out,output.time=outtm[3]))
}

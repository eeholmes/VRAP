% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/RunSims.R
\name{RunSims}
\alias{RunSims}
\title{RunSims}
\usage{
RunSims(inputs, silent, parallel.backend = "doParallel")
}
\arguments{
\item{inputs}{Inputs from .rav file}

\item{silent}{Whether to show progress bar}
}
\value{
list with inputs, SummaryStats, staticvars, comp.time.
}
\description{
RunSims takes the input list and runs the VRAP functions
}

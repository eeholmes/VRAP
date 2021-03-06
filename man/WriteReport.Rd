% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/writeReport.R
\name{WriteReport}
\alias{WriteReport}
\title{Write a report}
\usage{
WriteReport(InFile = NULL, OutFileBase = NULL, show.file = FALSE)
}
\arguments{
\item{InFile}{the .rav input file.}

\item{OutFileBase}{If OutFileBase is NULL, the VRAP output files are assumed to be in the same directory as InFile and named InFile.sum, InFile.byr, InFile.esc.  Thus they have the same basename.  If this is not the case, then OutFileBase can be passed in.}

\item{show.file}{Whether to open the pdf after it is produced.}
}
\value{
Nothing. The pdf is made and saved.
}
\description{
Create a pdf with basic information about the VRAP output.
}
\details{
knit2pdf is used to create the pdf using Report-knitr-ER.xRnw or Report-knitr-Pop.xRnw (Sweave files) in inst/doc.
}

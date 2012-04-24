


#' GETs bedgraph from methylRaw, methylRawList and methylDiff objects
#'
#' Convert \code{methylRaw}, \code{methylRawList} or \code{methylDiff} object into a bedgraph format
#' @param methylObj a \code{methylRaw} or \code{methlRawList} object
#' @param file.name  Default: NULL, if given a bedgraph file will be written, if NULL a data.frame or a list of data frames will be returned
#' @param col.name   name of the column in \code{methylRaw}, \code{methylRawList} or \code{methylDiff} objects to be used as a score for the bedgraph.
#'                   For \code{methylDiff}, col.name must be one of the following 'pvalue','qvalue', 'meth.diff'. For \code{methylRaw} and \code{methylRawList}
#'                   it must be one of the following 'coverage', 'numCs','numTs', 'perc.meth'
#' @param unmeth     when working with \code{methylRaw} or \code{methylRawList} objects should you output unmethylated C percentage
#'                   this makes it easier to see the unmethylated bases because their % methylation values will be zero. Only invoked when file.name is not NULL.
#' @param log.transform Default FALSE, If TRUE the score column of the bedgraph wil be in log10 scale. Ignored when col.name='perc.meth'
#' @param negative Default FALSE, If TRUE, the score column of the bedgraph will be multiplied by -1. Ignored when col.name='perc.meth'
#' @param add.on additional string to be add on the track line of bedgraph. can be viewlimits,priority etc. Check bedgraph track line options at UCSC browser
#'
#' @return RETURNS a data.frame or list of data.frames if file.name=NULL, if a file.name given appropriate bed file will be written to that file
#' @usage bedgraph(methylObj,file.name=NULL,col.name,unmeth=FALSE,log.transform=FALSE,negative=FALSE,add.on="")
#' @export
#' @docType methods
#' @rdname bedgraph-methods
setGeneric("bedgraph", function(methylObj,file.name=NULL,col.name,unmeth=FALSE,log.transform=FALSE,
                                negative=FALSE,add.on="") standardGeneric("bedgraph") )


#' @rdname bedgraph-methods
#' @aliases bedgraph,methylDiff-method
setMethod("bedgraph", signature(methylObj="methylDiff"),
                    function(methylObj,file.name,col.name,unmeth,log.transform,negative,add.on){

                      if(! col.name %in% c('pvalue','qvalue', 'meth.diff') )
                      {
                        stop("col.name argument is not one of 'pvalue','qvalue', 'meth.diff'")
                      }
                      df=data.frame(chr=methylObj[,2],start=methylObj[,3]-1,end=methylObj[,4])
                      df=cbind(df, score=methylObj[col.name] )
                      if(log.transform){
                        df[,4]=log10(df[,4])
                      }
                      if(negative){
                        df[,4]=-1*(df[,4])
                      }
                      
                      if(is.null(file.name)){
                        return(df)
                      }else{
                        track.line=paste(
                        "track type=bedGraph name='",file.name,"' description='",col.name,
                        "' visibility=full color=255,0,255 altColor=102,205,170 maxHeightPixels=80:80:11 ",add.on,sep="")
                        
                        cat(track.line,"\n",file=file.name)
                        write.table(df,file=file.name,quote=FALSE,col.names=FALSE,row.names=FALSE,sep="\t",append=TRUE)
                      }
                      
                    }
)

#' @rdname bedgraph-methods
#' @aliases bedgraph,methylRaw-method
setMethod("bedgraph", signature(methylObj="methylRaw"),
                    function(methylObj,file.name,col.name,unmeth,log.transform,negative,add.on){
                      if(!col.name %in%  c('coverage', 'numCs','numTs','perc.meth') ){
                        stop("col.name argument is not one of 'coverage', 'numCs','numTs','perc.meth'")
                      }
                      df=data.frame(chr=methylObj[,2],start=methylObj[,3]-1,end=methylObj[,4])
                      if(col.name=="perc.meth"){
                        df=cbind(df, score=100*methylObj[,7]/methylObj[,6] )
                      }else{
                        df=cbind(df, score=methylObj[col.name] )
                        if(log.transform){
                          df[,4]=log10(df[,4])
                        }
                        if(negative){
                          df[,4]=-1*(df[,4])
                        }
                      }
                      
                      if(is.null(file.name)){
                        return(df)
                      }else{
                        
                        if(unmeth & col.name=="perc.meth")
                        {
                          track.line=paste(
                              "track type=bedGraph name='",methylObj@sample.id," METH Cs","' description='",methylObj@sample.id," METH Cs",
                              "' visibility=full color=255,0,0 maxHeightPixels=80:80:11 ",add.on,sep="")                        
                          cat(track.line,"\n",file=file.name)
                          write.table(df,file=file.name,quote=FALSE,col.names=FALSE,row.names=FALSE,sep="\t",append=TRUE)
                          track.line2=paste(
                              "track type=bedGraph name='",methylObj@sample.id," UNMETH Cs","' description='",methylObj@sample.id," UNMETH Cs",
                              "' visibility=full color=0,0,255 maxHeightPixels=80:80:11 ",add.on,sep="")
                          cat(track.line2,"\n",file=file.name,append=TRUE)
                          df[,4]=100-df[,4]
                          write.table(df,file=file.name,quote=FALSE,col.names=FALSE,row.names=FALSE,sep="\t",append=TRUE)
                          
                        }else{
                          
                        
                          track.line=paste(
                              "track type=bedGraph name='",methylObj@sample.id,col.name,"' description='",methylObj@sample.id,col.name,
                              "' visibility=full color=255,0,0 maxHeightPixels=80:80:11 ",add.on,sep="")                        
                          cat(track.line,"\n",file=file.name)
                          write.table(df,file=file.name,quote=FALSE,col.names=FALSE,row.names=FALSE,sep="\t",append=TRUE)
                        }
                      }
                       
                                            
                    }
          
          )


#' @rdname bedgraph-methods
#' @aliases bedgraph,methylRawList-method
setMethod("bedgraph", signature(methylObj="methylRawList"),
                    function(methylObj,file.name,col.name,unmeth,log.transform,negative,add.on){
                      if(!col.name %in%  c('coverage', 'numCs','numTs','perc.meth') ){
                        stop("col.name argument is not one of 'coverage', 'numCs','numTs','perc.meth' options")
                      }
                      
                      if( is.null(file.name) ){
                        
                        result=list()
                        for(i in 1:length(methylObj))
                        {
                          result[[ methylObj[[i]]@sample.id ]]=bedgraph(methylObj[[i]],file.name=NULL,
                                                                   col.name=col.name,unmeth=FALSE,log.transform=log.transform,
                                                                   negative=negative)
                        }
                        
                        return(result)
                      }else{
                        
                        if(unmeth & col.name=="perc.meth")
                        {
                          
                          df=bedgraph(methylObj[[1]],file.name=NULL,
                                                                   col.name=col.name,unmeth=FALSE,log.transform=log.transform,
                                                                   negative=negative)
                          track.line=paste(
                              "track type=bedGraph name='",methylObj[[1]]@sample.id," METH Cs","' description='",methylObj[[1]]@sample.id," METH Cs",
                              "' visibility=full color=255,0,0 maxHeightPixels=80:80:11 ",add.on,sep="")                        
                          cat(track.line,"\n",file=file.name)
                          write.table(df,file=file.name,quote=FALSE,col.names=FALSE,row.names=FALSE,sep="\t",append=TRUE)
                          track.line2=paste(
                              "track type=bedGraph name='",methylObj[[1]]@sample.id," UNMETH Cs","' description='",methylObj[[1]]@sample.id," UNMETH Cs",
                              "' visibility=full color=0,0,255 maxHeightPixels=80:80:11 ",add.on,sep="")
                          cat(track.line2,"\n",file=file.name,append=TRUE)
                          df[,4]=100-df[,4]
                          write.table(df,file=file.name,quote=FALSE,col.names=FALSE,row.names=FALSE,sep="\t",append=TRUE)

                          
                          for(i in 2:length(methylObj))
                          {
                            df=bedgraph(methylObj[[i]],file.name=NULL,
                                                                   col.name=col.name,unmeth=FALSE,log.transform=log.transform,
                                                                   negative=negative)
                            track.line=paste(
                              "track type=bedGraph name='",methylObj[[i]]@sample.id," METH Cs","' description='",methylObj[[i]]@sample.id," METH Cs",
                              "' visibility=full color=255,0,0 maxHeightPixels=80:80:11 ",add.on,sep="")                        
                            cat(track.line,"\n",file=file.name,append=TRUE)
                            write.table(df,file=file.name,quote=FALSE,col.names=FALSE,row.names=FALSE,sep="\t",append=TRUE)
                            track.line2=paste(
                              "track type=bedGraph name='",methylObj[[i]]@sample.id," UNMETH Cs","' description='",methylObj[[i]]@sample.id," UNMETH Cs",
                              "' visibility=full color=0,0,255 maxHeightPixels=80:80:11 ",add.on,sep="")
                            cat(track.line2,"\n",file=file.name,append=TRUE)
                            df[,4]=100-df[,4]
                            write.table(df,file=file.name,quote=FALSE,col.names=FALSE,row.names=FALSE,sep="\t",append=TRUE)

                          }
                        }else{
                          df=bedgraph(methylObj[[1]],file.name=NULL,
                                                                   col.name=col.name,unmeth=FALSE,log.transform=log.transform,
                                                                   negative=negative)
                          track.line=paste(
                              "track type=bedGraph name='",methylObj[[1]]@sample.id,col.name,"' description='",methylObj[[1]]@sample.id,col.name,
                              "' visibility=full color=255,0,0 maxHeightPixels=80:80:11 ",add.on,sep="")                        
                          cat(track.line,"\n",file=file.name)
                          write.table(df,file=file.name,quote=FALSE,col.names=FALSE,row.names=FALSE,sep="\t",append=TRUE)
                          for(i in 2:length(methylObj))
                          {
                            df=bedgraph(methylObj[[i]],file.name=NULL,
                                                                   col.name=col.name,unmeth=FALSE,log.transform=log.transform,
                                                                   negative=negative)
                            track.line=paste(
                              "track type=bedGraph name='",methylObj[[i]]@sample.id,col.name,"' description='",methylObj[[i]]@sample.id,col.name,
                              "' visibility=full color=255,0,0 maxHeightPixels=80:80:11 ",add.on,sep="")                        
                            cat(track.line,"\n",file=file.name,append=TRUE)
                            write.table(df,file=file.name,quote=FALSE,col.names=FALSE,row.names=FALSE,sep="\t",append=TRUE)
                          
                          
                        }

                        
                        
                      }
                  }
})
 
##############################################################
## Description: functions for varous plots for enrichment analysis
##
## Author: Jeff Xia, jeff.xia@mcgill.ca
## McGill University, Canada
## License: GNU GPL (>= 2)
###################################################

# view individual compounds related to a given metabolite set
PlotQEA.MetSet<-function(msetInx, format="png", dpi=72, width=NA){

    setNM <- rownames(analSet$qea.mat)[msetInx];
    # clean the name, some contains space and special characters, will
    # cause trouble as image name
    imgNM <- gsub("\\|", "_", setNM);
    imgNM <- gsub("/", "_", imgNM);
    imgNM <- gsub(" *", "", imgNM);
    if(nchar(imgNM) > 15){
        imgNM <-substr(imgNM, 0, 15);
    }
    imgName <- paste(imgNM, "dpi", dpi, ".", format, sep="");
    if(is.na(width)){
        w <- 7;
    }else if(width == 0){
        w <- 7;
        imgSet$qea.mset<<-imgName;
    }else{
        w <- width;
    }
    h <- w;

    Cairo(file = imgName, unit="in", dpi=dpi, width=w, height=h, type=format, bg="white");
    gt.obj<-analSet$qea.msea;
    inx <- which (names(gt.obj) == setNM);
    if(is.factor(dataSet$cls)){
        colors = unique(as.numeric(dataSet$cls))+1;
        features(gt.obj[inx], cex=0.8, what="s", colors=colors, cluster=F);
    }else{
        features(gt.obj[inx], cex=0.8, what="s", cluster=F);
    }
    dev.off();
    current.img <<- imgName;
    return(imgName);
}

# plot the compound concentration data compared to the reference concentration range
PlotConcRange<-function(inx, format="png", dpi=72, width=NA){

print(inx);
    lows<-analSet$ssp.lows[[inx]];

    if(length(lows)==1 && is.na(lows)){
        return();
    }

    conc<-dataSet$norm[inx];
    means<-analSet$ssp.means[[inx]];
    highs<-analSet$ssp.highs[[inx]];

    cmpdNm <- analSet$ssp.mat[inx,1];
    hmdbID <- analSet$ssp.mat[inx, 3];
    imgName <<- paste(hmdbID, "dpi", dpi, ".png", sep="");
    if(is.na(width)){
        w <- h <- 7;
    }else if(width == 0){
        w <- 7;
        imgSet$conc.range<<-imgName;
    }else{
        w <- h <- width;
    }

    rng<-range(lows, highs, conc);
    ext <- (rng[2]-rng[1])/8;
    max.rg <- rng[2]+ext;
    min.rg <- ifelse(rng[1]-ext>=0, rng[1]-ext, 0);
    unit <- "(umol)"
    if(dataSet$biofluid =="urine"){
        unit <- "(umol/mmol_creatine)"
    }

    Cairo(file = imgName, unit="in", dpi=dpi, width=w, height=h, type=format, bg="white");
    concplot(means, lows, highs, xlim=c(min.rg, max.rg), labels = paste("Study ", 1:length(lows)),
              main=cmpdNm, xlab=paste("Concentration Range", unit), ylab="Study Reference")
    abline(v=c(range(lows, highs), conc), col=c("lightgrey", "lightgrey", "orange"), lty=c(5, 5, 5), lwd=c(1,1,2));

    # label the measured the concentration to the side
    text(conc, 0, conc, pos=4, col="orange");
    # extend the left end of axis to look natural without labeling
    axis(1, at=c(min.rg-ext, min.rg), label=F, lwd.tick=0);

    dev.off();
    current.img <<- imgName;
    return(imgName);
}

PlotORA<-function(imgName, format="png", dpi=72, width=NA){
    #calculate the enrichment fold change
    folds <- analSet$ora.mat[,3]/analSet$ora.mat[,2];
    names(folds)<-GetShortNames(rownames(analSet$ora.mat));
    pvals <- analSet$ora.mat[,4];

    imgName = paste(imgName, "dpi", dpi, ".", format, sep="");
    if(is.na(width)){
        w <- 9;
    }else if(width == 0){
        w <- 7;
        imgSet$ora<<-imgName;
    }else{
        w <-width;
    }
    h <- w;

    if(format == "png"){
        bg = "transparent";
    }else{
        bg="white";
    }
    Cairo(file = imgName, unit="in", dpi=dpi, width=w, height=h, type=format, bg=bg);

    PlotMSEA.Overview(folds, pvals);

    dev.off();
    current.img <<- imgName;
}

PlotQEA.Overview <-function(imgName, format="png", dpi=72, width=NA){
    #calculate the enrichment fold change
    folds <- analSet$qea.mat[,3]/analSet$qea.mat[,4];
    names(folds)<-GetShortNames(rownames(analSet$qea.mat));
    pvals <- analSet$qea.mat[,6];
    imgName = paste(imgName, "dpi", dpi, ".", format, sep="");

    if(is.na(width)){
        w <- 9;
    }else if(width == 0){
        w <- 7;
        imgSet$qea<<-imgName;
    }else{
        w <- width;
    }
    h <- w;

    if(format == "png"){
        bg = "transparent";
    }else{
        bg="white";
    }

    Cairo(file = imgName, unit="in", dpi=dpi, width=w, height=h, type=format, bg=bg);
    PlotMSEA.Overview(folds, pvals);
    dev.off();
    current.img <<- imgName;
}

# barplot height is enrichment fold change
# color is based on p values
PlotMSEA.Overview<-function(folds, pvals){

    # due to space limitation, plot top 50 if more than 50 were given
    title <- "Metabolite Sets Enrichment Overview";
    if(length(folds) > 50){
        folds <- folds[1:50];
        pvals <- pvals[1:50];
        title <- "Enrichment Overview (top 50)";
    }

    op<-par(mar=c(5,20,4,6), oma=c(0,0,0,4));
    ht.col <- rev(heat.colors(length(folds)));

    barplot(rev(folds), horiz=T, col=ht.col,
            xlab="Fold Enrichment", las=1, cex.name=0.75, space=c(0.5, 0.5),
            main= title);

    minP <- min(pvals);
    maxP <- max(pvals);
    medP <- (minP+maxP)/2;

    axs.args <- list(at=c(minP, medP, maxP), labels=format(c(maxP, medP, minP), scientific=T, digit=1), tick = F);
    image.plot(legend.only=TRUE, zlim=c(minP, maxP), col=ht.col,
                axis.args=axs.args,legend.shrink = 0.4, legend.lab="P value");
    par(op);
}

GetCurrentImg<-function(){
    return (current.img);
}

concplot <- function(mn, lower, upper, labels=NULL,
		      xlab = "Odds ratio", ylab = "Study Reference",
		      xlim = NULL, line.col = "blue", text.col="forestgreen",
		      xaxt="s", ... ) {

    n <- length( mn );
    nxlim <- xlim;
    nxlim[1] <- nxlim[1] - 0.25 * (nxlim[2] - nxlim[1] );
    par(xaxt = "n",yaxt = "n")
    plot(nxlim,c(1,-n-2),
          type = "n", bty = "n", xaxt = "n", yaxt = "n",
          xlab=xlab, ylab=ylab,... );

    text(rep(nxlim[1], n ), -( 1:n ), labels,..., col=rep(text.col,length.out=n),adj=0);
    par( xaxt = "s")
    ats<-pretty(xlim, 6);
    axis(1, at=ats)

    for ( i in 1:n ){
        if ( is.na( lower[i]+upper[i] ) )
            next
         arrows(lower[i], -i, upper[i], -i, lwd = 1, code=3, col=line.col, angle=90, length=0.04);
         points(mn[i], -i, pch=15, col='magenta');
    }
}

# Plot strip of color key by figure side
# Adapted from the image.plot in fields package to correct label
# so that small p value is bigger, located in top of the color key
image.plot <- function(..., add = FALSE, nlevel = 64,
    horizontal = FALSE, legend.shrink = 0.9, legend.width = 1.2,
    legend.mar = ifelse(horizontal, 3.1, 5.1), legend.lab = NULL,
    graphics.reset = FALSE, bigplot = NULL, smallplot = NULL,
    legend.only = FALSE, col = tim.colors(nlevel), lab.breaks = NULL,
    axis.args = NULL, legend.args = NULL, midpoint = FALSE) {

    old.par <- par(no.readonly = TRUE)
    #  figure out zlim from passed arguments
    info <- image.plot.info(...)
    if (add) {
        big.plot <- old.par$plt
    }
    if (legend.only) {
        graphics.reset <- TRUE
    }
    if (is.null(legend.mar)) {
        legend.mar <- ifelse(horizontal, 3.1, 5.1)
    }
    #
    # figure out how to divide up the plotting real estate.
    #
    temp <- image.plot.plt(add = add, legend.shrink = legend.shrink,
        legend.width = legend.width, legend.mar = legend.mar,
        horizontal = horizontal, bigplot = bigplot, smallplot = smallplot)
    #
    # bigplot are plotting region coordinates for image
    # smallplot are plotting coordinates for legend
    smallplot <- temp$smallplot
    bigplot <- temp$bigplot
    #
    # draw the image in bigplot, just call the R base function
    # or poly.image for polygonal cells note logical switch
    # for poly.grid parsed out of call from image.plot.info
    if (!legend.only) {
        if (!add) {
            par(plt = bigplot)
        }
        if (!info$poly.grid) {
            image(..., add = add, col = col)
        }
        else {
            poly.image(..., add = add, col = col, midpoint = midpoint)
        }
        big.par <- par(no.readonly = TRUE)
    }
    ##
    ## check dimensions of smallplot
    if ((smallplot[2] < smallplot[1]) | (smallplot[4] < smallplot[3])) {
        par(old.par)
        stop("plot region too small to add legend\n")
    }
    # Following code draws the legend using the image function
    # and a one column image.
    # calculate locations for colors on legend strip
    ix <- 1
    minz <- info$zlim[1]
    maxz <- info$zlim[2]
    binwidth <- (maxz - minz)/nlevel
    midpoints <- seq(minz + binwidth/2, maxz - binwidth/2, by = binwidth)
    iy <- midpoints
    iz <- matrix(iy, nrow = 1, ncol = length(iy))
    # extract the breaks from the ... arguments
    # note the breaks delineate intervals of common color
    breaks <- list(...)$breaks
    # draw either horizontal or vertical legends.
    # using either suggested breaks or not -- a total of four cases.
    #
    # next par call sets up a new plotting region just for the legend strip
    # at the smallplot coordinates
    par(new = TRUE, pty = "m", plt = smallplot, err = -1)
    # create the argument list to draw the axis
    #  this avoids 4 separate calls to axis and allows passing extra
    # arguments.
    # then add axis with specified lab.breaks at specified breaks
    if (!is.null(breaks) & !is.null(lab.breaks)) {
        # axis with labels at break points
        axis.args <- c(list(side = ifelse(horizontal, 1, 4),
            mgp = c(3, 1, 0), las = ifelse(horizontal, 0, 2),
            at = breaks, labels = lab.breaks), axis.args)
    }
    else {
        # If lab.breaks is not specified, with or without breaks, pretty
        # tick mark locations and labels are computed internally,
        # or as specified in axis.args at the function call
        axis.args <- c(list(side = ifelse(horizontal, 1, 4),
            mgp = c(3, 1, 0), las = ifelse(horizontal, 0, 2)),
            axis.args)
    }
    #
    # draw color scales the four cases are horizontal/vertical breaks/no breaks
    # add a label if this is passed.
    if (!horizontal) {
        if (is.null(breaks)) {
            image(ix, iy, iz, xaxt = "n", yaxt = "n", xlab = "",
                ylab = "", col = col)
        }
        else {
            image(ix, iy, iz, xaxt = "n", yaxt = "n", xlab = "",
                ylab = "", col = col, breaks = breaks)
        }
    }
    else {
        if (is.null(breaks)) {
            image(iy, ix, t(iz), xaxt = "n", yaxt = "n", xlab = "",
                ylab = "", col = col)
        }
        else {
            image(iy, ix, t(iz), xaxt = "n", yaxt = "n", xlab = "",
                ylab = "", col = col, breaks = breaks)
        }
    }

    #
    # now add the axis to the legend strip.
    # notice how all the information is in the list axis.args
    #
    do.call("axis", axis.args)

    # add a box around legend strip
    box()

    #
    # add a label to the axis if information has been  supplied
    # using the mtext function. The arguments to mtext are
    # passed as a list like the drill for axis (see above)
    #
    if (!is.null(legend.lab)) {
        legend.args <- list(text = legend.lab, side = ifelse(horizontal,
            1, 3), line = 1)
    }
    #
    # add the label using mtext function
    if (!is.null(legend.args)) {
        do.call(mtext, legend.args)
    }
    #
    #
    # clean up graphics device settings
    # reset to larger plot region with right user coordinates.
    mfg.save <- par()$mfg
    if (graphics.reset | add) {
        par(old.par)
        par(mfg = mfg.save, new = FALSE)
        invisible()
    }
    else {
        par(big.par)
        par(plt = big.par$plt, xpd = FALSE)
        par(mfg = mfg.save, new = FALSE)
        invisible()
    }
}


"image.plot.info" <- function(...) {
    temp <- list(...)
    #
    xlim <- NA
    ylim <- NA
    zlim <- NA
    poly.grid <- FALSE
    #
    # go through various cases of what these can be
    #
    ##### x,y,z list is first argument
    if (is.list(temp[[1]])) {
        xlim <- range(temp[[1]]$x, na.rm = TRUE)
        ylim <- range(temp[[1]]$y, na.rm = TRUE)
        zlim <- range(temp[[1]]$z, na.rm = TRUE)
        if (is.matrix(temp[[1]]$x) & is.matrix(temp[[1]]$y) &
            is.matrix(temp[[1]]$z)) {
            poly.grid <- TRUE
        }
    }
    ##### check for polygrid first three arguments should be matrices
    #####
    if (length(temp) >= 3) {
        if (is.matrix(temp[[1]]) & is.matrix(temp[[2]]) & is.matrix(temp[[3]])) {
            poly.grid <- TRUE
        }
    }
    #####  z is passed without an  x and y  (and not a poly.grid!)
    #####
    if (is.matrix(temp[[1]]) & !poly.grid) {
        xlim <- c(0, 1)
        ylim <- c(0, 1)
        zlim <- range(temp[[1]], na.rm = TRUE)
    }
    ##### if x,y,z have all been passed find their ranges.
    ##### holds if poly.grid or not
    #####
    if (length(temp) >= 3) {
        if (is.matrix(temp[[3]])) {
            xlim <- range(temp[[1]], na.rm = TRUE)
            ylim <- range(temp[[2]], na.rm = TRUE)
            zlim <- range(temp[[3]], na.rm = TRUE)
        }
    }
    #### parse x,y,z if they are  named arguments
    # determine if  this is polygon grid (x and y are matrices)
    if (is.matrix(temp$x) & is.matrix(temp$y) & is.matrix(temp$z)) {
        poly.grid <- TRUE
    }
    xthere <- match("x", names(temp))
    ythere <- match("y", names(temp))
    zthere <- match("z", names(temp))
    if (!is.na(zthere))
        zlim <- range(temp$z, na.rm = TRUE)
    if (!is.na(xthere))
        xlim <- range(temp$x, na.rm = TRUE)
    if (!is.na(ythere))
        ylim <- range(temp$y, na.rm = TRUE)
    # overwrite zlims with passed values
    if (!is.null(temp$zlim))
        zlim <- temp$zlim
    if (!is.null(temp$xlim))
        xlim <- temp$xlim
    if (!is.null(temp$ylim))
        ylim <- temp$ylim
    list(xlim = xlim, ylim = ylim, zlim = zlim, poly.grid = poly.grid)
}

# fields, Tools for spatial data
# Copyright 2004-2007, Institute for Mathematics Applied Geosciences
# University Corporation for Atmospheric Research
# Licensed under the GPL -- www.gpl.org/licenses/gpl.html
image.plot.plt <- function(x, add = FALSE, legend.shrink = 0.9,
    legend.width = 1, horizontal = FALSE, legend.mar = NULL,
    bigplot = NULL, smallplot = NULL, ...) {
    old.par <- par(no.readonly = TRUE)
    if (is.null(smallplot))
        stick <- TRUE
    else stick <- FALSE
    if (is.null(legend.mar)) {
        legend.mar <- ifelse(horizontal, 3.1, 5.1)
    }
    # compute how big a text character is
    char.size <- ifelse(horizontal, par()$cin[2]/par()$din[2],
        par()$cin[1]/par()$din[1])
    # This is how much space to work with based on setting the margins in the
    # high level par command to leave between strip and big plot
    offset <- char.size * ifelse(horizontal, par()$mar[1], par()$mar[4])
    # this is the width of the legned strip itself.
    legend.width <- char.size * legend.width
    # this is room for legend axis labels
    legend.mar <- legend.mar * char.size
    # smallplot is the plotting region for the legend.
    if (is.null(smallplot)) {
        smallplot <- old.par$plt
        if (horizontal) {
            smallplot[3] <- legend.mar
            smallplot[4] <- legend.width + smallplot[3]
            pr <- (smallplot[2] - smallplot[1]) * ((1 - legend.shrink)/2)
            smallplot[1] <- smallplot[1] + pr
            smallplot[2] <- smallplot[2] - pr
        }
        else {
            smallplot[2] <- 1 - legend.mar
            smallplot[1] <- smallplot[2] - legend.width
            pr <- (smallplot[4] - smallplot[3]) * ((1 - legend.shrink)/2)
            smallplot[4] <- smallplot[4] - pr
            smallplot[3] <- smallplot[3] + pr
        }
    }
    if (is.null(bigplot)) {
        bigplot <- old.par$plt
        if (!horizontal) {
            bigplot[2] <- min(bigplot[2], smallplot[1] - offset)
        }
        else {
            bottom.space <- old.par$mar[1] * char.size
            bigplot[3] <- smallplot[4] + offset
        }
    }
    if (stick & (!horizontal)) {
        dp <- smallplot[2] - smallplot[1]
        smallplot[1] <- min(bigplot[2] + offset, smallplot[1])
        smallplot[2] <- smallplot[1] + dp
    }
    return(list(smallplot = smallplot, bigplot = bigplot))
}
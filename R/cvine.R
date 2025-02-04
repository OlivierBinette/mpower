#' Citation:
#' Daniel Lewandowski, Dorota Kurowicka, Harry Joe,
#' Generating random correlation matrices based on vines and extended onion method,
#' Journal of Multivariate Analysis,
#' Volume 100, Issue 9,
#' 2009,
#' Pages 1989-2001,
#' ISSN 0047-259X,
#' https://doi.org/10.1016/j.jmva.2009.04.008.
#' Reference code: https://stats.stackexchange.com/questions/124538/how-to-generate-a-large-full-rank-random-correlation-matrix-with-some-strong-cor
#' Nother useful reference: https://www.sciencedirect.com/science/article/pii/S0047259X05000886:
#'         generates a positive definite correlation matrix
#' @export
cvine <- function(d, alpha=10, beta=10, S=NULL, m=100){
  if (length(S)==1 & is.numeric(d)) {
    S <- matrix(S, nrow = d, ncol = d)
    diag(S) <- 1
  } else {
    stop("Input `S` is missing or not a numeric matrix", call. = FALSE)
  }

  if (!is.null(S)) P0 <- cor2partial(S)
  P <- matrix(0, d, d)
  R <- diag(1, d, d)
  for (k in 1:(d-1)) {
    for (i in (k+1):d) {
      if (!is.null(S)) {
        alpha <- m * (P0[k,i]/2 + 0.5)
        beta <- m - alpha
      }
      P[k,i] <- rbeta(1, alpha, beta)  # sample partial correlation from Beta Distribution
      P[k,i] <- (P[k,i]-0.5)*2         # shift to [-1, 1]
      p <- P[k,i]
      if (k > 1) {
        for (l in seq(k-1, 1, -1)) {    # converting partial correlation to raw correlation
          p <- p * sqrt((1-P[l,i]^2)*(1-P[l,k]^2)) + P[l,i]*P[l,k]
        }
      }
      R[k,i] <- p
      R[i,k] <- p
    }
  }

  return(R)
}

#' @export
cor2partial <- function(r) {
  d <- nrow(r)
  if (d <= 2) return(r)
  pcor <- diag(1, d)
  for (k in 2:d) {
    pcor[1, k] <- r[1, k]
    pcor[k, 1] <- r[1, k]
  }
  for (k in 2:(d-1)) {
    for (i in (k+1):d) {
      pcor[k, i] <- partial(r, x=c(k,i), y=seq(1, k-1))[1,2]
      pcor[i, k] <- pcor[k, i]
    }
  }
  return(pcor)
}

#' @export
partial <- function(r, x, y) {
  rr <- r[c(x, y),][, c(x, y)]
  rx <- 1:length(x)
  ry <- (length(x)+1):(ncol(rr))
  Cx <- rr[rx, rx] - rr[rx, ry] %*% MASS::ginv(rr[ry, ry]) %*% rr[ry, rx]

  return(cov2cor(Cx))

}










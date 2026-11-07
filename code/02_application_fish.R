# Clear environment
rm(list = ls())

# Libraries
library(MASS)
library(pscl)
library(dplyr)

# === Load Data ===
fish <- read.csv("data/fish.csv")

# Response and predictors
y <- fish$count
X <- as.matrix(fish %>% select(nofish, livebait, camper, persons, child, xb, zg))
p <- ncol(X)

# === Reference beta from eigen decomposition ===
# === Reference beta set to 1 ===
beta_ref <- rep(1, p)        # vector of ones
# (optional) normalize to unit length
# beta_ref <- beta_ref / sqrt(sum(beta_ref^2))

# === Ridge Projection helper ===
ridge_projection <- function(X, beta_mle, lambda) {
  p <- ncol(X)
  XtX <- t(X) %*% X
  ridge_mat <- solve(XtX + lambda * diag(p)) %*% XtX
  beta_ridge <- ridge_mat %*% beta_mle
  return(as.vector(beta_ridge))
}

# === Ridge Poisson Estimation ===
ridge_poisson_weights <- function(X, y, lambda) {
  p <- ncol(X)
  XtX <- t(X) %*% X
  XtY <- t(X) %*% y
  beta_ridge <- solve(XtX + lambda * diag(p), XtY)
  return(beta_ridge)
}

# === Cross-validated Ridge Poisson ===
cv_ridge_poisson <- function(X, y, lambdas = 10^seq(-4, 2, length.out = 10), k = 5) {
  n <- nrow(X)
  folds <- sample(rep(1:k, length.out = n))
  mse_mat <- matrix(NA, nrow = k, ncol = length(lambdas))
  
  for (i in 1:k) {
    test_idx <- which(folds == i)
    train_idx <- setdiff(1:n, test_idx)
    X_train <- X[train_idx, ]
    y_train <- y[train_idx]
    X_test <- X[test_idx, ]
    y_test <- y[test_idx]
    
    for (j in seq_along(lambdas)) {
      beta <- ridge_poisson_weights(X_train, y_train, lambdas[j])
      y_pred <- exp(X_test %*% beta)
      mse_mat[i, j] <- mean((y_test - y_pred)^2)
    }
  }
  lambda_best <- lambdas[which.min(colMeans(mse_mat))]
  return(lambda_best)
}

# === Store results ===
mse_res <- data.frame(
  ZIP = NA, ZINB = NA, HurdlePoisson = NA,
  RidgeZIP = NA, HurdleNB = NA, RidgeZINB = NA, RidgeHurdleNB = NA
)

# ZIP
fit1 <- try(zeroinfl(count ~ . | 1, data = fish, dist = "poisson"), silent = TRUE)
if (!inherits(fit1, "try-error")) {
  b <- coef(fit1)[grep("^count_", names(coef(fit1)))]
  mse_res$ZIP <- mean((b[1:p] - beta_ref)^2)
}

# ZINB
fit2 <- try(zeroinfl(count ~ . | 1, data = fish, dist = "negbin"), silent = TRUE)
if (!inherits(fit2, "try-error")) {
  b <- coef(fit2)[grep("^count_", names(coef(fit2)))]
  mse_res$ZINB <- mean((b[1:p] - beta_ref)^2)
}

# Hurdle Poisson
try({
  count_fit <- glm(count ~ ., data = fish[fish$count > 0, ], family = poisson)
  b <- coef(count_fit)[-1]
  if (length(b) == p) mse_res$HurdlePoisson <- mean((b - beta_ref)^2)
}, silent = TRUE)

# Hurdle Negative Binomial
try({
  count_fit <- glm.nb(count ~ ., data = fish[fish$count > 0, ])
  b <- coef(count_fit)[-1]
  if (length(b) == p) mse_res$HurdleNB <- mean((b - beta_ref)^2)
}, silent = TRUE)

# Ridge ZIP
try({
  glm_zip <- glm(count ~ ., family = poisson, data = fish)
  beta_zip_mle <- coef(glm_zip)[-1]
  lambda_zip <- cv_ridge_poisson(X, y)
  beta_ridge_zip <- ridge_projection(X, beta_zip_mle, lambda_zip)
  mse_res$RidgeZIP <- mean((beta_ridge_zip - beta_ref)^2)
}, silent = TRUE)

# Ridge ZINB
try({
  b <- coef(fit2)[grep("^count_", names(coef(fit2)))]
  if (length(b) >= p) {
    lambda_nb <- cv_ridge_poisson(X, y)
    beta_ridge <- ridge_projection(X, b[1:p], lambda_nb)
    mse_res$RidgeZINB <- mean((beta_ridge - beta_ref)^2)
  }
}, silent = TRUE)

# Ridge Hurdle NB
try({
  y_pos <- y > 0
  glm_nb <- glm.nb(count ~ ., data = fish[y_pos, ])
  beta_nb_mle <- coef(glm_nb)[-1]
  lambda_nb <- cv_ridge_poisson(X[y_pos, ], y[y_pos])
  beta_ridge_nb <- ridge_projection(X[y_pos, ], beta_nb_mle, lambda_nb)
  mse_res$RidgeHurdleNB <- mean((beta_ridge_nb - beta_ref)^2)
}, silent = TRUE)

# === Save results ===
dir.create("results", showWarnings = FALSE)
write.csv(mse_res,
          "results/fish_mse_results.csv",
          row.names = FALSE)

print(mse_res)

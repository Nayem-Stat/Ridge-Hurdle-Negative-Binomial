# ================== Clear environment ==================
rm(list = ls())

# Libraries
library(MASS)      # for glm.nb
library(pscl)      # for ZIP, ZINB, Hurdle
library(dplyr)     # for select

# === Load Data ===
nmes <- read.csv("data/NMES1988_new.csv")

# Response and predictors
y <- nmes$novisits
X <- as.matrix(nmes %>% select(-novisits))
p <- ncol(X)


# ================== Condition Number ==================
# Design matrix should include intercept for proper check
X_design <- cbind(1, X)  
cond_number <- kappa(X_design, exact = TRUE)  
print(paste("Condition Number:", cond_number))

# ================== Correlation Matrix & Plot ==================
# ================== Correlation Matrix & Plot (with numbers) ==================

# ================== Histogram of Response ==================
dir.create("results", showWarnings = FALSE)
png("results/histogram_NMES1988_novisits.png", width = 800, height = 600)
hist(y,
     main = "Histogram of Response (y = novisits)",
     xlab = "Number of Visits (y)",
     ylab = "Frequency",
     col = "skyblue",
     border = "white")
dev.off()










# === Reference beta: vector of ones ===
#beta_ref <- rep(1, p)

# === Reference beta from eigen decomposition ===
XtX <- t(X) %*% X
eig <- eigen(XtX)
beta_ref <- eig$vectors[,1]   # eigenvector of largest eigenvalue
beta_ref <- beta_ref / sqrt(sum(beta_ref^2))  # normalize

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
  lambda_best <- lambdas[which.min(colMeans(mse_mat, na.rm = TRUE))]
  return(lambda_best)
}

# === Initialize results ===
mse_res <- data.frame(
  ZIP = NA, ZINB = NA, HurdlePoisson = NA,
  RidgeZIP = NA, HurdleNB = NA, RidgeZINB = NA, RidgeHurdleNB = NA
)

# ZIP
fit1 <- try(zeroinfl(novisits ~ . | 1, data = nmes, dist = "poisson"), silent = TRUE)
if (!inherits(fit1, "try-error")) {
  b <- coef(fit1)[grep("^count_", names(coef(fit1)))]
  mse_res$ZIP <- mean((b[1:p] - beta_ref)^2)
}

# ZINB
fit2 <- try(zeroinfl(novisits ~ . | 1, data = nmes, dist = "negbin"), silent = TRUE)
if (!inherits(fit2, "try-error")) {
  b <- coef(fit2)[grep("^count_", names(coef(fit2)))]
  mse_res$ZINB <- mean((b[1:p] - beta_ref)^2)
}

# Hurdle Poisson
try({
  count_fit <- glm(novisits ~ ., data = nmes[nmes$novisits > 0, ], family = poisson)
  b <- coef(count_fit)[-1]
  if (length(b) == p) mse_res$HurdlePoisson <- mean((b - beta_ref)^2)
}, silent = TRUE)

# Hurdle Negative Binomial
try({
  count_fit <- glm.nb(novisits ~ ., data = nmes[nmes$novisits > 0, ])
  b <- coef(count_fit)[-1]
  if (length(b) == p) mse_res$HurdleNB <- mean((b - beta_ref)^2)
}, silent = TRUE)

# Ridge ZIP
try({
  glm_zip <- glm(novisits ~ ., family = poisson, data = nmes)
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
  glm_nb <- glm.nb(novisits ~ ., data = nmes[y_pos, ])
  beta_nb_mle <- coef(glm_nb)[-1]
  lambda_nb <- cv_ridge_poisson(X[y_pos, ], y[y_pos])
  beta_ridge_nb <- ridge_projection(X[y_pos, ], beta_nb_mle, lambda_nb)
  mse_res$RidgeHurdleNB <- mean((beta_ridge_nb - beta_ref)^2)
}, silent = TRUE)

# === Save results ===
write.csv(mse_res,
          "results/NMES1988_mse_results.csv",
          row.names = FALSE)

print(mse_res)

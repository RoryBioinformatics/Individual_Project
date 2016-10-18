# Full Processing Steps for the Statistical analysis of metabolomic datasets



# Applied NA function to dataset
sdremove <- function(j) {
  
  if (j > under||j < over || j = 0){
    j <- NA
  }
  return (j)
}

df  <- data.frame()
for (i in 1:nrow(HILIC_wo_nolcqc.clean)){
  SD <- sd(as.numeric(HILIC_wo_nolcqc.clean[i,]))
  SD3 <- (SD*3)
  mean <- mean(as.numeric(HILIC_wo_nolcqc.clean[i,]))
  over <- (mean - SD3)
  under <- (mean + SD3)
  ret <- lapply(as.matrix(HILIC_wo_nolcqc.clean[i,]),sdremove)
  #print (ret)
  df <- rbind(df, ret)
}
write.csv (df, file='HILIC_wo_nolcqc.clean.NA.csv')



# Used to rank inverse normalise transform
df  <- data.frame()
for (i in 1:nrow(Test_NA)){
  var2int <- Test_NA[i,]
  int<-qnorm((rank(var2int,na.last="keep")-0.5)/sum(!is.na(var2int)))
  df <- rbind(df, int)
}
write.csv (df, file='Test_NA_rank.csv')



# Model given table rows
library(plyr)
df <-data.frame()
eGFR <-(as.numeric(egfr["eGFR",]))
Age <-(as.numeric(Test_cat["Age",]))
Sex <-(as.numeric(Test_cat["Sex",]))
SBP <-(as.numeric(Test_cat["SBP",]))
BNP <-(as.numeric(Test_cat["BNP",]))

for (i in 1:nrow(HILIC_wo_nolcqcdead.clean.NA.rank)){
  check <-(as.numeric(HILIC_wo_nolcqcdead.clean.NA.rank[i,]))
  model = lm(check~Dead_Age+Dead_BNP+Dead_eGFR+Dead_Sex,na.action=na.omit)
  coe <-summary(model)$coefficients
  df <- rbind(df, coe)
  rsq <-summary(model)$r.squared
  df <- rbind(df, rsq)
  Identifier <- rownames(HILIC_wo_nolcqcdead.clean.NA.rank[i,])
  df <- rbind(df, Identifier)
}
print(summary(model)$call)
write.csv (df, file='pval_dead_hilic.csv')



# FDR adjust
p <- pval_dead_hilic.csv.pval$P.Value
fdr <-p.adjust(p, method = "fdr")
bon <-p.adjust(p, method = "bonferroni")